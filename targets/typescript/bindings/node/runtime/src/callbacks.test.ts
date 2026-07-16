import { beforeEach, expect, test, vi } from 'vitest';
import {
  type CallbackErrorContext,
  type InboundResult,
  __deliverDealloc,
  __deliverValueReturning,
  __invokeCallback,
  __registerCallback,
  __releaseCallback,
  __resolveCallback,
  onCallbackError,
} from './callbacks.js';
import { type NativeDispatch, __installDispatch } from './dispatch.js';

// `process` is a Node global; typed locally to avoid an @types/node devDependency (matching the
// runtime's own dependency-free access via globalThis in callbacks.ts).
const nodeProcess = (
  globalThis as unknown as { process: { emit(event: string, error: unknown): boolean } }
).process;

function stub(overrides: Partial<NativeDispatch> = {}): NativeDispatch {
  return {
    release: () => {},
    // The inbound wrap/return primitives (ADR-0057 §2/§4): identity by default — a test that
    // cares about retain accounting overrides them.
    retain: (handle: bigint) => handle,
    retainAutorelease: (handle: bigint) => handle,
    getClass: (n: string) => BigInt(n.length),
    getSelector: (n: string) => BigInt(n.length),
    selectorName: (s: bigint) => `sel${s}`,
    className: (c: bigint) => `cls${c}`,
    classOf: () => 0n,
    superclassOf: () => 0n,
    pushAutoreleasePool: () => 0n,
    popAutoreleasePool: () => {},
    cfstr: (s: string) => BigInt(s.length),
    postCallbackCompletion: () => {},
    defineSubclass: () => 0n,
    allocInit: () => 0n,
    allocInitWithObject: () => 0n,
    setBackRef: () => {},
    defineForwarder: () => 0n,
    setRespondsBits: () => {},
    associate: () => {},
    installCallbackInvoker: () => {},
    installDeallocDeliverer: () => {},
    installValueReturningDeliverer: () => {},
    makeBlock: () => 0n,
    releaseBlock: () => {},
    makeEscapingBlock: () => 0n,
    installBlockReleaseDeliverer: () => {},
    ...overrides,
  };
}

beforeEach(() => {
  __installDispatch(stub());
  onCallbackError(null); // restore the Node uncaughtException default between tests
});

// --- registry: register / resolve / release (ADR-0059 §6, Decision 2) -------------------------

test('__registerCallback mints a distinct non-zero id per registration; __resolveCallback finds it', () => {
  const fn = () => 1;
  const a = __registerCallback(fn);
  const b = __registerCallback(() => 2);
  expect(a).not.toBe(0n); // 0n is never a valid id (the native "no callback" sentinel)
  expect(b).not.toBe(a); // monotonic, never reused
  expect(__resolveCallback(a)).toBe(fn);
});

test('__releaseCallback drops the JS-side keep-alive — a later resolve is undefined', () => {
  const id = __registerCallback({ tag: 1 });
  expect(__resolveCallback(id)).not.toBeUndefined();
  __releaseCallback(id);
  expect(__resolveCallback(id)).toBeUndefined();
});

// --- __deliverDealloc: run the override (if any) + drop the keep-alive (ADR-0059 §4) ----------

test('__deliverDealloc runs the JS dealloc override and returns true (native must NOT chain super)', () => {
  const order: string[] = [];
  const target = {
    dealloc(this: unknown) {
      order.push('dealloc'); // the override runs; it is obligated to chain this.$super.dealloc()
    },
  };
  const id = __registerCallback(target);
  const hadOverride = __deliverDealloc(id);
  expect(order).toEqual(['dealloc']);
  expect(hadOverride).toBe(true); // native side leaves [super dealloc] to the JS override
});

test('__deliverDealloc with no override returns false (native chains [super dealloc] itself)', () => {
  const id = __registerCallback({ tag: 1 }); // no dealloc method
  expect(__deliverDealloc(id)).toBe(false);
});

test('__deliverDealloc drops the registry keep-alive — closing the k37/k38 loop', () => {
  const id = __registerCallback({ dealloc() {} });
  expect(__resolveCallback(id)).not.toBeUndefined(); // pinned while bound
  __deliverDealloc(id);
  expect(__resolveCallback(id)).toBeUndefined(); // released on dealloc
});

test('__deliverDealloc on a stale/unregistered id is a no-op that returns false, never a crash', () => {
  expect(__deliverDealloc(0xdead_beefn)).toBe(false);
});

test('__deliverDealloc contains a throwing override: reports, still releases, still reports hadOverride', () => {
  const reported: CallbackErrorContext[] = [];
  onCallbackError((_e, context) => reported.push(context));
  const boom = {
    dealloc() {
      throw new Error('dealloc boom');
    },
  };
  const id = __registerCallback(boom);

  let hadOverride = false;
  expect(() => {
    hadOverride = __deliverDealloc(id); // contract-bound never to throw across the C ABI
  }).not.toThrow();

  expect(hadOverride).toBe(true); // an override existed (it just threw) → native must NOT chain super
  expect(reported).toHaveLength(1);
  expect(reported[0].selector).toBe('dealloc'); // context carries the dealloc selector
  expect(__resolveCallback(id)).toBeUndefined(); // released despite the throw
});

// --- __invokeCallback: block invoke (no selector) ---------------------------------------------

test('__invokeCallback invokes a block (no selector) with the args and returns its value', () => {
  const id = __registerCallback((a: number, b: number) => a + b);
  const r = __invokeCallback({ id, args: [2, 3] });
  expect(r).toEqual({ threw: false, value: 5 });
});

// --- __invokeCallback: delegate/override dispatch by injective selector→name, this-bound -------

test('__invokeCallback dispatches a selector by the injective :→_ map with `this` bound to the target', () => {
  const delegate = {
    rows: 7,
    // selector tableView:numberOfRowsInSection: → method name tableView_numberOfRowsInSection_
    tableView_numberOfRowsInSection_(this: { rows: number }, _table: unknown, _section: number) {
      return this.rows; // proves `this` is the delegate, not the module
    },
  };
  const id = __registerCallback(delegate);
  const r = __invokeCallback({
    id,
    selector: 'tableView:numberOfRowsInSection:',
    args: [{}, 0],
  });
  expect(r).toEqual({ threw: false, value: 7 });
});

// --- __invokeCallback: containment — catch → report → typed-default signal (ADR-0059 §7) -------

test('a JS-throwing callback is contained: returns {threw:true} AND reports via onCallbackError', () => {
  const reported: { error: unknown; context: CallbackErrorContext }[] = [];
  onCallbackError((error, context) => reported.push({ error, context }));
  const boom = new Error('callback boom');
  const id = __registerCallback(() => {
    throw boom;
  });

  const r = __invokeCallback({ id, args: [] });

  expect(r).toEqual({ threw: true }); // native substitutes its typed nil/0 default
  expect(reported).toHaveLength(1);
  expect(reported[0].error).toBe(boom);
  expect(reported[0].context.id).toBe(id);
});

test('an unregistered/stale id is contained (report + threw), never a crash', () => {
  const reported: unknown[] = [];
  onCallbackError((error) => reported.push(error));
  const r = __invokeCallback({ id: 0xdead_beefn, args: [] });
  expect(r).toEqual({ threw: true });
  expect(reported).toHaveLength(1);
  expect(reported[0]).toBeInstanceOf(Error);
});

test('a delegate missing the selector method is contained, carrying the selector in the context', () => {
  const reported: CallbackErrorContext[] = [];
  onCallbackError((_e, context) => reported.push(context));
  const id = __registerCallback({}); // implements nothing
  const r = __invokeCallback({ id, selector: 'windowDidResize:', args: [{}] });
  expect(r).toEqual({ threw: true });
  expect(reported[0].selector).toBe('windowDidResize:');
});

// --- onCallbackError: default routes to Node uncaughtException (ADR-0059 §7) -------------------

test('the default onCallbackError routes to process.emit(uncaughtException) without crashing', () => {
  const emit = vi.spyOn(nodeProcess, 'emit').mockImplementation(() => true);
  try {
    const boom = new Error('defaulted boom');
    const id = __registerCallback(() => {
      throw boom;
    });
    __invokeCallback({ id, args: [] });
    expect(emit).toHaveBeenCalledWith('uncaughtException', boom);
  } finally {
    emit.mockRestore();
  }
});

// --- onCallbackError: guarded — a throw inside the handler is swallowed, never propagated ------

test('a throw inside the onCallbackError handler is swallowed, never re-thrown across the boundary', () => {
  onCallbackError(() => {
    throw new Error('handler itself threw');
  });
  const id = __registerCallback(() => {
    throw new Error('original callback error');
  });
  // __invokeCallback is contract-bound never to throw — the guarded report must not leak the
  // handler's own throw across the C-ABI boundary.
  expect(() => __invokeCallback({ id, args: [] })).not.toThrow();
});

// --- __deliverValueReturning: the off-main value-returning always-complete discipline (§5/§7) --

test('__deliverValueReturning posts {threw:false,value} on a clean value return', () => {
  const posts: { completion: bigint; result: InboundResult }[] = [];
  __installDispatch(
    stub({ postCallbackCompletion: (completion, result) => posts.push({ completion, result }) }),
  );
  const id = __registerCallback(() => 42);
  __deliverValueReturning(0x99n, { id, args: [] });
  expect(posts).toEqual([{ completion: 0x99n, result: { threw: false, value: 42 } }]);
});

test('__deliverValueReturning ALWAYS posts (threw) when the JS side throws, and reports it', () => {
  const reported: unknown[] = [];
  onCallbackError((e) => reported.push(e));
  const posts: InboundResult[] = [];
  __installDispatch(stub({ postCallbackCompletion: (_c, result) => posts.push(result) }));
  const id = __registerCallback(() => {
    throw new Error('value-returning boom');
  });

  __deliverValueReturning(0x1n, { id, args: [] });

  expect(posts).toEqual([{ threw: true }]); // the blocked bg thread is released with the default
  expect(reported).toHaveLength(1); // and the throw is surfaced, not silent
});

test('__deliverValueReturning coerces an async-in-value-slot return to the default AND reports', () => {
  const reported: unknown[] = [];
  onCallbackError((e) => reported.push(e));
  const posts: InboundResult[] = [];
  __installDispatch(stub({ postCallbackCompletion: (_c, result) => posts.push(result) }));
  // An `async` method used where a value is needed cannot deliver synchronously (ADR-0056 finding C).
  const id = __registerCallback(async () => 1);

  __deliverValueReturning(0x2n, { id, args: [] });

  expect(posts).toEqual([{ threw: true }]);
  expect(reported).toHaveLength(1);
});

test('__deliverValueReturning posts exactly once per delivery (never a hang, never a double-post)', () => {
  let postCount = 0;
  __installDispatch(stub({ postCallbackCompletion: () => postCount++ }));
  const id = __registerCallback(() => 'ok');
  __deliverValueReturning(0x3n, { id, args: [] });
  expect(postCount).toBe(1);
});
