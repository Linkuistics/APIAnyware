import { beforeEach, expect, test } from 'vitest';
import { type NativeDispatch, __installDispatch } from './dispatch.js';
import { ObjectDisposedError } from './errors.js';
import {
  type Finalization,
  NSObject,
  __frCleanup,
  __installFinalization,
  __unwrap,
  __wrapBorrowed,
  __wrapOwned,
  __wrapRetained,
  withAutoreleasePool,
} from './lifetime.js';

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
    // `object_getClass` (k88). The nil Class by default, so a class-less `id` falls back to the root
    // NSObject exactly as it did before the dynamic-wrap arm — a test that exercises the real class
    // resolution overrides it.
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

/** A recording finalization backend (DI) so the FR path is deterministic without GC. */
function recordingFinalization() {
  const registered = new Map<object, bigint>();
  const fin: Finalization = {
    register: (_target, held, token) => registered.set(token, held),
    unregister: (token) => registered.delete(token),
  };
  return { fin, registered };
}

beforeEach(() => {
  __installDispatch(stub());
  __installFinalization(recordingFinalization().fin);
});

// --- wrap / unwrap / uniquing (ADR-0057 §2/§3) -----------------------------------------

test('__unwrap returns the native handle; 0n for null', () => {
  expect(__unwrap(null)).toBe(0n);
  const o = __wrapRetained(NSObject, 0x1002n);
  expect(o).not.toBeNull();
  expect(__unwrap(o)).toBe(0x1002n);
});

// A plain JS object reaching a protocol-typed slot no longer arrives HERE at all: k89 guarded
// `__unwrap` with a named TypeError because the literal path was reachable-but-unbuilt, and
// `emitted-delegate-spec-k84` built it — every bound `id<P>` slot in the corpus now routes through
// `__protocolArg`, which discriminates wrapper-from-literal and bridges the literal through its
// generated `DelegateSpec` (see delegate.test.ts's three arms). So the guard is gone: `__unwrap` takes
// an `NSObject`, and anything else is once again an internal invariant violation.

test('__wrapRetained and __wrapOwned return null for the null handle (0n)', () => {
  expect(__wrapRetained(NSObject, 0n)).toBeNull();
  expect(__wrapOwned(NSObject, 0n)).toBeNull();
});

test('__wrapRetained uniques — the same id yields the same wrapper', () => {
  const a = __wrapRetained(NSObject, 0x1001n);
  const b = __wrapRetained(NSObject, 0x1001n);
  expect(a).toBe(b);
});

test('__wrapRetained releases the fold on a live duplicate (uniform +1, ADR-0057 §2/§4)', () => {
  // A +0 object return arrives with the native fold's +1 (ADR-0057 §4). When uniquing hits a
  // live wrapper, that fold is redundant — the live wrapper already owns the one +1 — so it must
  // be released (else the second re-fetch of an already-wrapped id leaks the fold). Symmetric
  // with __wrapOwned's live-duplicate release.
  const released: bigint[] = [];
  __installDispatch(stub({ release: (h) => released.push(h) }));
  const a = __wrapRetained(NSObject, 0x1004n);
  const b = __wrapRetained(NSObject, 0x1004n);
  expect(b).toBe(a);
  expect(released).toEqual([0x1004n]);
});

test('__wrapOwned releases the extra +1 when a live wrapper already exists', () => {
  const released: bigint[] = [];
  __installDispatch(stub({ release: (h) => released.push(h) }));
  const first = __wrapRetained(NSObject, 0x1003n);
  const second = __wrapOwned(NSObject, 0x1003n);
  expect(second).toBe(first);
  expect(released).toEqual([0x1003n]);
});

// --- __wrapBorrowed: the inbound (+0, no incoming +1) primitive (ADR-0057 §2) -------------

test('__wrapBorrowed mints by taking its OWN +1 (nothing folded one in)', () => {
  // The inbound asymmetry: an object arg reaches a JS callback at +0 — the ObjC caller owns it,
  // no dispatch entry folded a retain, and the method's convention gave none away. So the fresh
  // mint must retain (ADR-0057 §2's no-ARC argument: `this.lastSender = sender` must be sound),
  // and there is nothing to release.
  const retained: bigint[] = [];
  const released: bigint[] = [];
  __installDispatch(
    stub({
      retain: (h) => {
        retained.push(h);
        return h;
      },
      release: (h) => released.push(h),
    }),
  );
  const o = __wrapBorrowed(NSObject, 0xb001n);
  expect(o).not.toBeNull();
  expect(__unwrap(o)).toBe(0xb001n);
  expect(retained).toEqual([0xb001n]);
  expect(released).toEqual([]);
});

test('__wrapBorrowed on a live wrapper costs ZERO native crossings', () => {
  // The common inbound case — the same `sender` on every event. Unlike __wrapRetained/__wrapOwned
  // (which must release a redundant *incoming* +1), a borrowed id carries none, so a live wrapper
  // needs neither a retain nor a release: the hit is pure map lookup.
  const retained: bigint[] = [];
  const released: bigint[] = [];
  __installDispatch(
    stub({
      retain: (h) => {
        retained.push(h);
        return h;
      },
      release: (h) => released.push(h),
    }),
  );
  const first = __wrapBorrowed(NSObject, 0xb002n);
  retained.length = 0; // the mint's +1 — accounted above; now measure the re-delivery.
  const second = __wrapBorrowed(NSObject, 0xb002n);
  expect(second).toBe(first);
  expect(retained).toEqual([]);
  expect(released).toEqual([]);
});

test('__wrapBorrowed uniques with the outbound primitives — one wrapper per id, either way in', () => {
  // The three primitives share ONE uniquing map (ADR-0057 §3), so an object the callback receives
  // and the same object fetched outbound are the same wrapper — `sender === this.button` holds.
  const released: bigint[] = [];
  __installDispatch(stub({ release: (h) => released.push(h) }));
  const inbound = __wrapBorrowed(NSObject, 0xb003n);
  const outbound = __wrapRetained(NSObject, 0xb003n); // +0 return, entry folded a +1
  expect(outbound).toBe(inbound);
  // The fold's +1 is redundant against the borrowed wrapper's — released, as for any duplicate.
  expect(released).toEqual([0xb003n]);
});

test('__wrapBorrowed returns null for the null handle, taking no retain', () => {
  const retained: bigint[] = [];
  __installDispatch(
    stub({
      retain: (h) => {
        retained.push(h);
        return h;
      },
    }),
  );
  expect(__wrapBorrowed(NSObject, 0n)).toBeNull();
  expect(retained).toEqual([]);
});

// --- dispose (ADR-0057 §6) --------------------------------------------------------------

test('dispose releases the handle then throws ObjectDisposedError on further use', () => {
  const released: bigint[] = [];
  __installDispatch(stub({ release: (h) => released.push(h) }));
  const o = __wrapRetained(NSObject, 0x2001n);
  expect(o).not.toBeNull();
  (o as NSObject)[Symbol.dispose]();
  expect(released).toEqual([0x2001n]);
  expect(() => __unwrap(o)).toThrow(ObjectDisposedError);
});

test('the handle is still live while release runs during dispose (ADR-0057 §6 ordering)', () => {
  const o = __wrapRetained(NSObject, 0x2002n) as NSObject;
  let handleDuringRelease: bigint | null = null;
  __installDispatch(
    stub({
      release: () => {
        handleDuringRelease = __unwrap(o); // must not throw — flag flips AFTER release
      },
    }),
  );
  o[Symbol.dispose]();
  expect(handleDuringRelease).toBe(0x2002n);
});

test('dispose is idempotent — a second dispose does not double-release', () => {
  const released: bigint[] = [];
  __installDispatch(stub({ release: (h) => released.push(h) }));
  const o = __wrapRetained(NSObject, 0x2003n) as NSObject;
  o[Symbol.dispose]();
  o[Symbol.dispose]();
  expect(released).toEqual([0x2003n]);
});

test('dispose removes the uniquing slot — re-wrapping the id mints a fresh wrapper', () => {
  const o = __wrapRetained(NSObject, 0x2004n);
  (o as NSObject)[Symbol.dispose]();
  const o2 = __wrapRetained(NSObject, 0x2004n);
  expect(o2).not.toBe(o);
});

test('dispose unregisters the FR token so no stale finalizer fires later', () => {
  const { fin, registered } = recordingFinalization();
  __installFinalization(fin);
  const o = __wrapRetained(NSObject, 0x2005n) as NSObject;
  expect(registered.size).toBe(1); // mint registered it
  o[Symbol.dispose]();
  expect(registered.size).toBe(0); // dispose unregistered it
});

// --- FinalizationRegistry backstop + the FR-lag guard (ADR-0057 §3/§5) ------------------

test('__frCleanup releases the id unconditionally', () => {
  const released: bigint[] = [];
  __installDispatch(stub({ release: (h) => released.push(h) }));
  __frCleanup(0x3001n);
  expect(released).toEqual([0x3001n]);
});

test('a stale __frCleanup preserves a live newer wrapper in the slot (FR-lag guard)', () => {
  const released: bigint[] = [];
  __installDispatch(stub({ release: (h) => released.push(h) }));
  const live = __wrapRetained(NSObject, 0x3002n); // live wrapper occupies the slot
  __frCleanup(0x3002n); // a stale FR from an older, already-collected wrapper
  expect(released).toEqual([0x3002n]); // still releases its own +1 (unconditional)
  const again = __wrapRetained(NSObject, 0x3002n);
  expect(again).toBe(live); // the newer wrapper's slot was NOT evicted (guarded removal)
});

// --- withAutoreleasePool (ADR-0057 §8) --------------------------------------------------

test('withAutoreleasePool pushes then pops a native pool around fn, returning its value', () => {
  const events: string[] = [];
  __installDispatch(
    stub({
      pushAutoreleasePool: () => {
        events.push('push');
        return 7n;
      },
      popAutoreleasePool: (p) => {
        events.push(`pop:${p}`);
      },
    }),
  );
  const result = withAutoreleasePool(() => {
    events.push('body');
    return 42;
  });
  expect(result).toBe(42);
  expect(events).toEqual(['push', 'body', 'pop:7']);
});

test('withAutoreleasePool pops the pool even when fn throws', () => {
  const events: string[] = [];
  __installDispatch(
    stub({
      pushAutoreleasePool: () => {
        events.push('push');
        return 9n;
      },
      popAutoreleasePool: (p) => {
        events.push(`pop:${p}`);
      },
    }),
  );
  expect(() =>
    withAutoreleasePool(() => {
      throw new Error('boom');
    }),
  ).toThrow('boom');
  expect(events).toEqual(['push', 'pop:9']);
});
