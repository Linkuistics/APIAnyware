import { beforeEach, expect, test } from 'vitest';
import { type NativeDispatch, __installDispatch } from './dispatch.js';
import { NSErrorError, NSExceptionError } from './errors.js';
import { type Finalization, NSObject, __installFinalization, __unwrap } from './lifetime.js';
import {
  type NativeErrorResult,
  __resultOwned,
  __resultRetained,
  __resultScalar,
  __resultScalarValue,
  unwrap,
} from './result.js';

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

function recordingFinalization(): Finalization {
  const registered = new Map<object, bigint>();
  return {
    register: (_t, held, token) => registered.set(token, held),
    unregister: (token) => registered.delete(token),
  };
}

beforeEach(() => {
  __installDispatch(stub());
  __installFinalization(recordingFinalization());
});

// The `…_e` wire discriminant the Step 4 native entry produces (this child defines it).
const ok = (primary: bigint | number | boolean): NativeErrorResult => ({
  thrown: false,
  primary,
  error: 0n,
});
const failed = (error: bigint): NativeErrorResult => ({ thrown: false, primary: 0n, error });
const raised = (exception: bigint, reason: string): NativeErrorResult => ({
  thrown: true,
  exception,
  reason,
});

// --- __resultRetained / __resultOwned: object primary, keyed on the primary return (ADR-0058) ---

test('__resultRetained keys ok:true on a non-nil primary and wraps it', () => {
  const r = __resultRetained(NSObject, ok(0x5001n));
  expect(r.ok).toBe(true);
  if (r.ok) {
    expect(r.value).toBeInstanceOf(NSObject);
    expect(__unwrap(r.value)).toBe(0x5001n);
  }
});

test('__resultRetained keys ok:false on a nil primary and wraps the NSError', () => {
  const r = __resultRetained(NSObject, failed(0x5002n));
  expect(r.ok).toBe(false);
  if (!r.ok) {
    expect(r.error).toBeInstanceOf(NSObject);
    expect(__unwrap(r.error)).toBe(0x5002n);
  }
});

test('__resultRetained does not release a fresh +0 primary (retain folded into dispatch)', () => {
  const released: bigint[] = [];
  __installDispatch(stub({ release: (h) => released.push(h) }));
  const r = __resultRetained(NSObject, ok(0x5003n));
  expect(r.ok).toBe(true);
  expect(released).toEqual([]);
});

test('__resultOwned wraps a +1 primary, releasing the extra +1 on a live duplicate', () => {
  const released: bigint[] = [];
  __installDispatch(stub({ release: (h) => released.push(h) }));
  const first = __wrapFor(0x5004n); // an existing live wrapper occupies the slot
  const r = __resultOwned(NSObject, ok(0x5004n));
  expect(r.ok).toBe(true);
  if (r.ok) expect(r.value).toBe(first);
  expect(released).toEqual([0x5004n]); // the redundant incoming +1 is balanced
});

// --- __resultScalar: BOOL primary (Apple's NSError** scalar is always BOOL) ------------------

test('__resultScalar keys ok:true on a YES (true) primary', () => {
  const r = __resultScalar(ok(true));
  expect(r).toEqual({ ok: true, value: true });
});

test('__resultScalar keys ok:false on a NO (false) primary and wraps the NSError', () => {
  const r = __resultScalar(failed(0x5005n));
  expect(r.ok).toBe(false);
  if (!r.ok) expect(__unwrap(r.error)).toBe(0x5005n);
});

// --- __resultScalarValue: non-BOOL scalar primary (k101 — the real value rides through) ------

test('__resultScalarValue keys ok:true on a nonzero primary and carries the real value', () => {
  // NSJSONSerialization.writeJSONObject(_:toStream:options:error:) -> Int (bytes written): the
  // success value is DATA, not a flag — unlike __resultScalar, it must not be hard-coded.
  const r = __resultScalarValue(ok(42));
  expect(r).toEqual({ ok: true, value: 42 });
});

test('__resultScalarValue keys ok:false on a zero primary and wraps the NSError', () => {
  const r = __resultScalarValue(failed(0x5009n));
  expect(r.ok).toBe(false);
  if (!r.ok) expect(__unwrap(r.error)).toBe(0x5009n);
});

// --- native @catch → thrown NSExceptionError (all four helpers) ------------------------------

test('a thrown discriminant escalates to NSExceptionError carrying the reason + wrapper', () => {
  expect(() =>
    __resultRetained(NSObject, raised(0x5006n, 'NSRangeException: out of bounds')),
  ).toThrow(NSExceptionError);
  expect(() => __resultScalarValue(raised(0x500an, 'NSRangeException: out of bounds'))).toThrow(
    NSExceptionError,
  );

  // Capture-then-assert (not a bare catch) so a non-throw fails loudly rather than silently passing.
  let caught: unknown;
  try {
    __resultScalar(raised(0x5007n, 'NSRangeException: out of bounds'));
  } catch (e) {
    caught = e;
  }
  expect(caught).toBeInstanceOf(NSExceptionError);
  const ex = caught as NSExceptionError;
  expect(ex.message).toBe('NSRangeException: out of bounds');
  expect(__unwrap(ex.exception)).toBe(0x5007n);
});

// --- unwrap: the opt-in bridge from a Result failure to the throw channel (ADR-0058 §3) ------

test('unwrap returns the value on the ok arm', () => {
  expect(unwrap<number>({ ok: true, value: 42 })).toBe(42);
});

test('unwrap escalates a failure to a thrown NSErrorError carrying the error', () => {
  const r = __resultRetained(NSObject, failed(0x5008n));
  expect(r.ok).toBe(false);
  try {
    unwrap(r);
    throw new Error('unwrap should have thrown');
  } catch (e) {
    expect(e).toBeInstanceOf(NSErrorError);
    expect(__unwrap((e as NSErrorError).error)).toBe(0x5008n);
  }
});

/** Local helper: wrap an id as a live NSObject via the runtime's own +0 primitive. */
function __wrapFor(id: bigint): NSObject {
  const r = __resultRetained(NSObject, ok(id));
  if (!r.ok) throw new Error('expected ok');
  return r.value;
}
