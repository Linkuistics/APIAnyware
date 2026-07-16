// Unit tests for the delegate *policy* half (ADR-0059 §3/§6): the per-protocol memoization, the
// set-time `respondsToSelector:` bit snapshot, the responds-bound guard, and — the k84 surface —
// `__protocolArg`'s three arms (null / wrapped object / JS literal), the associate-vs-skip keep-alive,
// the balanced alloc `+1`, and `__protocolAdopt`'s initializer case. All against a spy stub
// `__dispatch`; the native *mechanism* (real forwarding class, real `respondsToSelector:` IMP, real
// association) is proven by the integration harness (`native/test/delegate.mjs`).

import { beforeEach, expect, test } from 'vitest';
import {
  type DelegateSpec,
  MAX_PROTOCOL_METHODS,
  __forwarderClass,
  __protocolAdopt,
  __protocolArg,
  __respondsBits,
} from './delegate.js';
import { type NativeDispatch, __installDispatch } from './dispatch.js';
import { NSObject } from './lifetime.js';
import type { SubclassOverride } from './subclass.js';

/** One recorded native call — name + args — so tests can assert the set-time sequence. */
interface Call {
  readonly name: string;
  readonly args: readonly unknown[];
}

/** A recording stub backend: every method appends to `calls`; overridable per test. */
function recordingStub(calls: Call[], overrides: Partial<NativeDispatch> = {}): NativeDispatch {
  const rec =
    <T extends unknown[], R>(name: string, ret: (...a: T) => R) =>
    (...a: T): R => {
      calls.push({ name, args: a });
      return ret(...a);
    };
  return {
    release: rec('release', () => {}),
    // The inbound wrap/return primitives (ADR-0057 §2/§4): identity by default — a test that
    // cares about retain accounting overrides them.
    retain: (handle: bigint) => handle,
    retainAutorelease: (handle: bigint) => handle,
    getClass: rec('getClass', (n: string) => BigInt(n.length)),
    getSelector: rec('getSelector', (n: string) => BigInt(n.length)),
    selectorName: rec('selectorName', (s: bigint) => `sel${s}`),
    className: rec('className', (c: bigint) => `cls${c}`),
    classOf: rec('classOf', () => 0n),
    superclassOf: rec('superclassOf', () => 0n),
    pushAutoreleasePool: rec('pushAutoreleasePool', () => 0n),
    popAutoreleasePool: rec('popAutoreleasePool', () => {}),
    cfstr: rec('cfstr', (s: string) => BigInt(s.length)),
    postCallbackCompletion: rec('postCallbackCompletion', () => {}),
    defineSubclass: rec('defineSubclass', () => 0n),
    allocInit: rec('allocInit', () => 0xa11c1n),
    allocInitWithObject: rec('allocInitWithObject', () => 0xa11c2n),
    setBackRef: rec('setBackRef', () => {}),
    defineForwarder: rec('defineForwarder', () => 0xc1a55n),
    setRespondsBits: rec('setRespondsBits', () => {}),
    associate: rec('associate', () => {}),
    installCallbackInvoker: rec('installCallbackInvoker', () => {}),
    installDeallocDeliverer: rec('installDeallocDeliverer', () => {}),
    installValueReturningDeliverer: rec('installValueReturningDeliverer', () => {}),
    makeBlock: rec('makeBlock', () => 0xb10cn),
    releaseBlock: rec('releaseBlock', () => {}),
    makeEscapingBlock: rec('makeEscapingBlock', () => 0xeb10cn),
    installBlockReleaseDeliverer: rec('installBlockReleaseDeliverer', () => {}),
    ...overrides,
  };
}

const M: readonly SubclassOverride[] = [
  ['numberOfItems', 'q@:'],
  ['titleForItem:', '@@:q'],
];

/** The emitted shape: per PROTOCOL only. The setter, the key and the associate arm ride the slot. */
function spec(over: Partial<DelegateSpec> = {}): DelegateSpec {
  return {
    protocol: 'AWTestDataSource',
    methods: M,
    ...over,
  };
}

const OWNER = 0x0117n;
const KEY = 'setDataSource:#0';

let calls: Call[];
beforeEach(() => {
  calls = [];
  __installDispatch(recordingStub(calls));
});

// ── __respondsBits: the exact @optional snapshot (the load-bearing correctness point) ─────────────

test('__respondsBits sets a bit per implemented, injective-mapped (`:`→`_`) method', () => {
  const both = { numberOfItems: () => 3, titleForItem_: (_i: number) => 'x' };
  // bit 0 (numberOfItems) + bit 1 (titleForItem:) → 0b11.
  expect(__respondsBits(both, M)).toBe(0b11n);
});

test('__respondsBits clears the bit for an unimplemented optional method (no false YES)', () => {
  const onlyCount = { numberOfItems: () => 3 }; // titleForItem_ absent → bit 1 clear.
  expect(__respondsBits(onlyCount, M)).toBe(0b01n);
});

test('__respondsBits ignores a non-function property of the mapped name', () => {
  const shadowed = { numberOfItems: 42, titleForItem_: () => 'x' }; // numberOfItems not callable.
  expect(__respondsBits(shadowed, M)).toBe(0b10n);
});

// ── __forwarderClass: per-protocol memoization + the responds bound ───────────────────────────────

// NB: `forwarders` (the per-protocol memo) is module-global and persists across tests in this
// file, so any test asserting a `defineForwarder` *count* uses a protocol id unique to that test;
// the recorded `calls` array is per-test (reset in beforeEach), so counting within it is clean.

test('__forwarderClass synthesizes once per protocol and memoizes', () => {
  const h1 = __forwarderClass(spec({ protocol: 'AWMemoProto' }));
  const h2 = __forwarderClass(spec({ protocol: 'AWMemoProto' })); // memo hit, no second synthesis.
  expect(h1).toBe(h2);
  expect(calls.filter((c) => c.name === 'defineForwarder')).toHaveLength(1);
});

test('__forwarderClass synthesizes a distinct class per distinct protocol', () => {
  __forwarderClass(spec({ protocol: 'AWTwoA' }));
  __forwarderClass(spec({ protocol: 'AWTwoB' }));
  expect(calls.filter((c) => c.name === 'defineForwarder')).toHaveLength(2);
});

test('__forwarderClass forwards `<selector>|<encoding>` overrides to the native synthesizer', () => {
  __forwarderClass(spec({ protocol: 'AWOverrides' }));
  const df = calls.find((c) => c.name === 'defineForwarder');
  expect(df?.args[0]).toBe('AWOverrides');
  expect(df?.args[2]).toEqual(['numberOfItems|q@:', 'titleForItem:|@@:q']);
});

test('__forwarderClass throws before allocating a class for an oversized protocol', () => {
  const tooMany: SubclassOverride[] = Array.from(
    { length: MAX_PROTOCOL_METHODS + 1 },
    (_v, i) => [`m${i}`, 'v@:'] as SubclassOverride,
  );
  expect(() => __forwarderClass(spec({ protocol: 'AWHuge', methods: tooMany }))).toThrow(
    /exceeding the 64-method/,
  );
  // Failed loudly — no class was synthesized.
  expect(calls.some((c) => c.name === 'defineForwarder')).toBe(false);
});

// ── __protocolArg: the three arms every bound `id<P>` slot in the corpus routes through ────────────

test('a JS literal mints a forwarder: alloc → setBackRef → setRespondsBits → associate, in order', () => {
  const handle = __protocolArg(OWNER, KEY, { numberOfItems: () => 1 }, spec(), true);
  expect(handle).toBe(0xa11c1n); // the forwarder's handle is what crosses to ObjC

  const seq = calls.map((c) => c.name);
  const iAlloc = seq.indexOf('allocInit');
  const iBack = seq.indexOf('setBackRef');
  const iBits = seq.indexOf('setRespondsBits');
  const iAssoc = seq.indexOf('associate');
  expect(iAlloc).toBeGreaterThanOrEqual(0);
  expect(iAlloc).toBeLessThan(iBack);
  expect(iBack).toBeLessThan(iBits);
  expect(iBits).toBeLessThan(iAssoc);
  // The snapshot is computed from the JS object: only bit 0 (`titleForItem_` is absent).
  expect(calls.find((c) => c.name === 'setRespondsBits')?.args[1]).toBe(0b01n);
});

test('the associate arm keeps exactly one owner: the association, alloc +1 balanced', () => {
  __protocolArg(OWNER, KEY, { numberOfItems: () => 1 }, spec({ protocol: 'AWAssoc' }), true);
  const assoc = calls.find((c) => c.name === 'associate');
  expect(assoc?.args).toEqual([OWNER, KEY, 0xa11c1n]);
  // The association took its own +1, so the alloc's is released — leaving the association as the
  // sole owner (it lives exactly as long as `owner`, and a re-set releases it).
  expect(calls.filter((c) => c.name === 'release').map((c) => c.args[0])).toEqual([0xa11c1n]);
  expect(calls.some((c) => c.name === 'retainAutorelease')).toBe(false);
});

test('the SKIP arm hands over a +0 autoreleased forwarder — the ObjC contract, not a dangle', () => {
  // A declared-`strong` slot (`NSURLSessionTask.setDelegate:` — the one slot k82 measured where the
  // declaration flips the retain axis). The framework will retain during the send — but the send has
  // not happened yet when this returns, so dropping the forwarder here would hand ObjC a dead object.
  // `retainAutorelease` is the real ObjC +0 contract: alive for this turn, which spans the call.
  const calls2: Call[] = [];
  __installDispatch(recordingStub(calls2, { retainAutorelease: (h: bigint) => h }));
  __protocolArg(OWNER, KEY, { numberOfItems: () => 1 }, spec({ protocol: 'AWSkip' }), false);
  expect(calls2.some((c) => c.name === 'associate')).toBe(false);
  expect(calls2.filter((c) => c.name === 'release').map((c) => c.args[0])).toEqual([0xa11c1n]);
});

test('a WRAPPED ObjC object unwraps to its handle and mints nothing', () => {
  // The other thing the bound type admits (ADR-0055 §4b). It owns itself; there is no forwarder.
  const wrapped = new NSObject(0xbeefn);
  expect(__protocolArg(OWNER, KEY, wrapped, spec(), true)).toBe(0xbeefn);
  expect(calls.some((c) => c.name === 'allocInit')).toBe(false);
  // …and it *clears* the slot: a wrapper replacing a JS delegate must not leave the old forwarder
  // pinned by a stale association.
  expect(calls.find((c) => c.name === 'associate')?.args).toEqual([OWNER, KEY, 0n]);
});

test('null clears the slot and its forwarder — no alloc, nil handle', () => {
  expect(__protocolArg(OWNER, KEY, null, spec(), true)).toBe(0n);
  expect(calls.some((c) => c.name === 'allocInit')).toBe(false);
  expect(calls.find((c) => c.name === 'associate')?.args).toEqual([OWNER, KEY, 0n]);
});

test('a skip-arm slot never clears an association it could not have made', () => {
  __protocolArg(OWNER, KEY, null, spec(), false);
  expect(calls.some((c) => c.name === 'associate')).toBe(false);
});

// ── __protocolAdopt: the initializer case — the owner is the RESULT, not the receiver ─────────────

test('__protocolAdopt associates the forwarder onto the object the initializer returned', () => {
  // `[[NSFilePromiseProvider alloc] initWithFileType:delegate:]` stores its delegate on the object
  // `init` hands back — and ObjC lets that differ from the one `alloc` produced. So the arg is
  // handed over with NO owner (0n → the +0 autorelease arm), and adopted once `__ret` exists.
  const arg = __protocolArg(0n, KEY, { numberOfItems: () => 1 }, spec({ protocol: 'AWInit' }), true);
  expect(calls.some((c) => c.name === 'associate')).toBe(false); // nothing to associate onto yet

  __protocolAdopt(0xf00dn, KEY, { numberOfItems: () => 1 }, arg, true);
  expect(calls.find((c) => c.name === 'associate')?.args).toEqual([0xf00dn, KEY, 0xa11c1n]);
});

test('__protocolAdopt is a no-op for a wrapper, a nil result, and a skip-arm slot', () => {
  const wrapped = new NSObject(0xbeefn);
  __protocolAdopt(0xf00dn, KEY, wrapped, 0xbeefn, true); // owns itself — nothing to adopt
  __protocolAdopt(0n, KEY, { numberOfItems: () => 1 }, 0xa11c1n, true); // init returned nil
  __protocolAdopt(0xf00dn, KEY, { numberOfItems: () => 1 }, 0xa11c1n, false); // framework retains
  expect(calls.some((c) => c.name === 'associate')).toBe(false);
});
