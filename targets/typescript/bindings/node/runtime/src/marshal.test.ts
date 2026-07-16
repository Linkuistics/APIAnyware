import { beforeEach, expect, test } from 'vitest';
import { __invokeCallback, __registerCallback, onCallbackError } from './callbacks.js';
import { __registerClass } from './classes.js';
import { type NativeDispatch, __installDispatch } from './dispatch.js';
import { NSObject, __wrapRetained } from './lifetime.js';
import { CLS, OBJ, RAW, RET_OBJ, SEL, __blockMarshal, __methodMarshal } from './marshal.js';

/** Records every retain/release/retainAutorelease crossing so ownership is *measured*, not asserted. */
function recordingStub(overrides: Partial<NativeDispatch> = {}) {
  const calls: string[] = [];
  const dispatch: NativeDispatch = {
    release: (h) => {
      calls.push(`release:${h}`);
    },
    retain: (h) => {
      calls.push(`retain:${h}`);
      return h;
    },
    retainAutorelease: (h) => {
      calls.push(`retainAutorelease:${h}`);
      return h;
    },
    getClass: (n: string) => BigInt(n.length),
    getSelector: (n: string) => BigInt(n.length + 100),
    selectorName: (s: bigint) => (s === 42n ? 'doCommand:' : `sel${s}`),
    className: (c: bigint) => (c === 7n ? 'TKWidget' : `cls${c}`),
    // The DYNAMIC class of every inbound handle in this file (k88): `className(7n)` is 'TKWidget',
    // which `__registerClass` below has bound — so the class-less wrap resolves the object's real
    // class rather than a declared one. That is exactly the reconciliation ADR-0059 §8 took: the
    // `obj` kind no longer names a class, because the object's own is at least as specific.
    classOf: () => 7n,
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
  __installDispatch(dispatch);
  return calls;
}

/** A stand-in "emitted class" — registered under its ObjC runtime name, as a static block would. */
class TKWidget extends NSObject {}
__registerClass('TKWidget', TKWidget);

beforeEach(() => {
  recordingStub();
  onCallbackError(null);
});

// --- args in: the declared type, not a bigint (ADR-0059 §8) ------------------------------

test('an object arg arrives as a WRAPPER of its real class, borrowed (+1 taken once)', () => {
  // "Its real class", not "its declared class" — ADR-0059 §8 as reconciled by `dynamic-class-wrap-k88`.
  // §8 had the `obj` kind name the declared class because the class-less wrap used to mint a stand-in
  // for anything unregistered; k88 made it climb to the nearest bound ancestor instead, so the
  // object's own class is now always at least as specific as the declared one (a declared `NSString`
  // that is really an `NSMutableString` wraps as one). The declared class bought nothing — and cost
  // the emitted spec module a value import of every arg class, which is a barrel cycle waiting to
  // happen. So `OBJ` carries no class at all.
  const calls = recordingStub();
  let received: unknown;
  const id = __registerCallback(
    {
      widgetDidChange_: (w: unknown) => {
        received = w;
      },
    },
    __methodMarshal({ 'widgetDidChange:': { args: [OBJ], ret: RAW } }),
  );

  const r = __invokeCallback({ id, selector: 'widgetDidChange:', args: [0x3001n] });

  expect(r.threw).toBe(false);
  expect(received).toBeInstanceOf(TKWidget);
  expect(calls).toEqual(['retain:12289']); // 0x3001 — the borrowed mint's own +1
});

test('the same object redelivered is the SAME wrapper — `sender === this.button` holds', () => {
  const calls = recordingStub();
  const seen: unknown[] = [];
  const id = __registerCallback(
    { widgetDidChange_: (w: unknown) => seen.push(w) },
    __methodMarshal({ 'widgetDidChange:': { args: [OBJ], ret: RAW } }),
  );

  __invokeCallback({ id, selector: 'widgetDidChange:', args: [0x3002n] });
  calls.length = 0; // the mint's +1 is accounted; now measure the second delivery.
  __invokeCallback({ id, selector: 'widgetDidChange:', args: [0x3002n] });

  expect(seen[1]).toBe(seen[0]);
  expect(calls).toEqual([]); // no retain, no release — a hot event stream does not leak per event
});

test('a SEL arg arrives as its selector-name string (ADR-0055 §3)', () => {
  let received: unknown;
  const id = __registerCallback(
    {
      doCommandBySelector_: (s: unknown) => {
        received = s;
      },
    },
    __methodMarshal({ 'doCommandBySelector:': { args: [SEL], ret: RAW } }),
  );
  __invokeCallback({ id, selector: 'doCommandBySelector:', args: [42n] });
  expect(received).toBe('doCommand:');
});

test('a Class arg arrives as the bound constructor (ADR-0055 §5b)', () => {
  let received: unknown;
  const id = __registerCallback(
    {
      useClass_: (c: unknown) => {
        received = c;
      },
    },
    __methodMarshal({ 'useClass:': { args: [CLS], ret: RAW } }),
  );
  __invokeCallback({ id, selector: 'useClass:', args: [7n] }); // className(7n) === 'TKWidget'
  expect(received).toBe(TKWidget);
});

test('a scalar arg and a nil object arg cross untouched', () => {
  const args: unknown[] = [];
  const id = __registerCallback(
    { rows_for_: (...a: unknown[]) => args.push(...a) },
    __methodMarshal({ 'rows:for:': { args: [RAW, OBJ], ret: RAW } }),
  );
  __invokeCallback({ id, selector: 'rows:for:', args: [17n, 0n] });
  expect(args).toEqual([17n, null]); // the scalar passes through; the nil handle is `null`
});

// --- return out: the retain axis (ADR-0057 §4) --------------------------------------------

test('a +0-convention object return is retain-autoreleased (the real ObjC contract)', () => {
  // The load-bearing case: a callback that MINTS an object and returns it. The wrapper's +1 is
  // JS's, not the caller's — so the return must carry its own, autoreleased, reference.
  const calls = recordingStub();
  const menu = __wrapRetained(TKWidget, 0x4001n);
  calls.length = 0;
  const id = __registerCallback(
    { dockMenu: () => menu },
    __methodMarshal({ dockMenu: { args: [], ret: RET_OBJ() } }),
  );

  const r = __invokeCallback({ id, selector: 'dockMenu', args: [] });

  expect(r).toEqual({ threw: false, value: 0x4001n }); // a raw handle reaches the trampoline
  expect(calls).toEqual(['retainAutorelease:16385']);
});

test('a +1-convention object return (an overridden copy/init) is retained, NOT autoreleased', () => {
  const calls = recordingStub();
  const copy = __wrapRetained(TKWidget, 0x4002n);
  calls.length = 0;
  const id = __registerCallback(
    { copyWithZone_: () => copy },
    __methodMarshal({ 'copyWithZone:': { args: [RAW], ret: RET_OBJ('owned') } }),
  );

  const r = __invokeCallback({ id, selector: 'copyWithZone:', args: [0n] });

  expect(r).toEqual({ threw: false, value: 0x4002n });
  expect(calls).toEqual(['retain:16386']); // the caller OWNS it — an autorelease would under-retain
});

test('a null object return is the nil handle, taking no retain at all', () => {
  const calls = recordingStub();
  const id = __registerCallback(
    { dockMenu: () => null },
    __methodMarshal({ dockMenu: { args: [], ret: RET_OBJ() } }),
  );
  const r = __invokeCallback({ id, selector: 'dockMenu', args: [] });
  expect(r).toEqual({ threw: false, value: 0n });
  expect(calls).toEqual([]);
});

test('a SEL / Class return converts back and is NEVER retained', () => {
  // Retaining a Class leaks; objc_retain on a SEL is undefined behaviour (ADR-0057 §4).
  const calls = recordingStub();
  const id = __registerCallback(
    { action: () => 'fire:', classForPage: () => TKWidget },
    __methodMarshal({
      action: { args: [], ret: SEL },
      classForPage: { args: [], ret: CLS },
    }),
  );

  const sel = __invokeCallback({ id, selector: 'action', args: [] });
  const cls = __invokeCallback({ id, selector: 'classForPage', args: [] });

  expect(sel).toEqual({ threw: false, value: 105n }); // getSelector('fire:') → len + 100
  expect(cls).toEqual({ threw: false, value: 8n }); // getClass('TKWidget') → len
  expect(calls).toEqual([]);
});

// --- blocks (no selector) ------------------------------------------------------------------

test('a block receives its declared types — the target IS the callable, no selector', () => {
  const seen: unknown[] = [];
  const id = __registerCallback(
    (obj: unknown, index: unknown) => {
      seen.push(obj, index);
      return true;
    },
    __blockMarshal({ args: [OBJ, RAW], ret: RAW }),
  );
  const r = __invokeCallback({ id, args: [0x5001n, 3n] });
  expect(r).toEqual({ threw: false, value: true });
  expect(seen[0]).toBeInstanceOf(TKWidget);
  expect(seen[1]).toBe(3n);
});

// --- containment: a descriptor fault fails like a JS throw, never a C-ABI unwind -----------

test('an uncovered selector is a LOUD spec bug, contained (never a silently-raw handle)', () => {
  // Silently passing the raw bigint through under a declared `TKWidget` is the exact lie this
  // module exists to remove — so a partial descriptor throws, is reported, and defaults.
  const reported: unknown[] = [];
  onCallbackError((e) => reported.push(e));
  const id = __registerCallback(
    { somethingElse: () => 1n },
    __methodMarshal({ dockMenu: { args: [], ret: RET_OBJ() } }),
  );

  const r = __invokeCallback({ id, selector: 'somethingElse', args: [] });

  expect(r).toEqual({ threw: true });
  expect(reported).toHaveLength(1);
  expect(String(reported[0])).toContain('no inbound value descriptor for somethingElse');
});

test('returning a DISPOSED wrapper is contained, not a use-after-free', () => {
  const reported: unknown[] = [];
  onCallbackError((e) => reported.push(e));
  const dead = __wrapRetained(TKWidget, 0x6001n) as TKWidget;
  dead[Symbol.dispose]();
  const id = __registerCallback(
    { dockMenu: () => dead },
    __methodMarshal({ dockMenu: { args: [], ret: RET_OBJ() } }),
  );

  const r = __invokeCallback({ id, selector: 'dockMenu', args: [] });

  expect(r).toEqual({ threw: true }); // native substitutes its typed nil default
  expect(reported).toHaveLength(1);
});

test('an async method in a value slot keeps its precise ADR-0059 §7 diagnostic', () => {
  // Without the guard, conversion would fail as a mystery unwrap of a Promise. The rule is the
  // same either way (report + typed default), but the message must still say what went wrong.
  const reported: unknown[] = [];
  onCallbackError((e) => reported.push(e));
  const id = __registerCallback(
    { dockMenu: async () => null },
    __methodMarshal({ dockMenu: { args: [], ret: RET_OBJ() } }),
  );

  const r = __invokeCallback({ id, selector: 'dockMenu', args: [] });

  expect(r).toEqual({ threw: true });
  expect(String(reported[0])).toContain('async callback cannot return a value synchronously');
});

test('an async VOID method is legitimate — a raw return slot does not guard', () => {
  // §5: a callback needing async work schedules it. Its return is ignored natively.
  const reported: unknown[] = [];
  onCallbackError((e) => reported.push(e));
  const id = __registerCallback(
    { widgetDidChange_: async () => {} },
    __methodMarshal({ 'widgetDidChange:': { args: [OBJ], ret: RAW } }),
  );

  const r = __invokeCallback({ id, selector: 'widgetDidChange:', args: [0x7001n] });

  expect(r.threw).toBe(false);
  expect(reported).toEqual([]);
});

// --- the no-descriptor path (every pre-k79 battery depends on it) --------------------------

test('a callback registered WITHOUT a marshal still traffics in raw handles', () => {
  const seen: unknown[] = [];
  const id = __registerCallback({
    widgetDidChange_: (w: unknown) => {
      seen.push(w);
      return 5n;
    },
  });
  const r = __invokeCallback({ id, selector: 'widgetDidChange:', args: [0x8001n] });
  expect(seen).toEqual([0x8001n]);
  expect(r).toEqual({ threw: false, value: 5n });
});
