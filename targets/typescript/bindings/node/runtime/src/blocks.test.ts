// Unit tests for the NS_NOESCAPE block *policy* half (block-noescape-on-main-k39, ADR-0059 §2): the
// register → makeBlock → body → releaseBlock + release-registry bracket, the "held only for the call's
// duration" lifetime (the fn resolvable during `body`, dropped after), the finally-releases-on-throw
// guarantee, and the un-installed-signature (0n) hard error — all against a spy stub `__dispatch`. The
// native *mechanism* (a real `@convention(block)` block, its typed trampoline invoke, the boundary
// `@catch`) is proven separately by the integration harness (`native/test/block.mjs`).

import { beforeEach, expect, test } from 'vitest';
import { __makeEscapingBlock, __withNoescapeBlock } from './blocks.js';
import { __resolveCallback } from './callbacks.js';
import { type NativeDispatch, __installDispatch } from './dispatch.js';

/** One recorded native call — name + args — so tests can assert the bracket sequence. */
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

let calls: Call[];
beforeEach(() => {
  calls = [];
  __installDispatch(recordingStub(calls));
});

// ── The bracket sequence + return-value passthrough ───────────────────────────────────────────────

test('__withNoescapeBlock runs makeBlock → body → releaseBlock in order', () => {
  __withNoescapeBlock(
    () => {},
    'PQP_v',
    () => {},
  );
  const seq = calls.map((c) => c.name).filter((n) => n === 'makeBlock' || n === 'releaseBlock');
  expect(seq).toEqual(['makeBlock', 'releaseBlock']);
});

test('__withNoescapeBlock passes the signature to makeBlock and the block-pointer to the body', () => {
  let received: bigint | undefined;
  __withNoescapeBlock(
    () => {},
    'PQP_v',
    (block) => {
      received = block;
    },
  );
  const mk = calls.find((c) => c.name === 'makeBlock');
  expect(mk?.args[1]).toBe('PQP_v');
  expect(received).toBe(0xb10cn); // the stub's makeBlock return, handed to the body verbatim
  const rel = calls.find((c) => c.name === 'releaseBlock');
  expect(rel?.args[0]).toBe(0xb10cn); // the same block-pointer is released
});

test('__withNoescapeBlock returns whatever the body returns (composes with a value-returning call)', () => {
  const out = __withNoescapeBlock(
    () => {},
    'PQP_v',
    () => 42,
  );
  expect(out).toBe(42);
});

// ── The NS_NOESCAPE lifetime: fn registered for the body, dropped after ────────────────────────────

test('the JS fn is registered for the body and dropped after (held only for the call)', () => {
  const fn = (): void => {};
  let idDuring: bigint | undefined;
  __withNoescapeBlock(fn, 'PQP_v', () => {
    // makeBlock has run and recorded the minted id; the fn must be resolvable now.
    idDuring = calls.find((c) => c.name === 'makeBlock')?.args[0] as bigint;
    expect(__resolveCallback(idDuring)).toBe(fn);
  });
  // After the bracket, the registry entry is gone (no tsfn holder — the fast path).
  expect(idDuring).toBeDefined();
  expect(__resolveCallback(idDuring as bigint)).toBeUndefined();
});

test('the block is released and the fn dropped even if the body throws (finally)', () => {
  const fn = (): void => {};
  let idDuring: bigint | undefined;
  expect(() =>
    __withNoescapeBlock(fn, 'PQP_v', () => {
      idDuring = calls.find((c) => c.name === 'makeBlock')?.args[0] as bigint;
      throw new Error('outbound boom');
    }),
  ).toThrow('outbound boom');
  expect(calls.some((c) => c.name === 'releaseBlock')).toBe(true);
  expect(__resolveCallback(idDuring as bigint)).toBeUndefined();
});

// ── The un-installed-signature (0n) hard error ─────────────────────────────────────────────────────

test('an un-installed block signature (0n) throws, drops the registry entry, never calls the body', () => {
  let mintedId: bigint | undefined;
  __installDispatch(
    recordingStub(calls, {
      makeBlock: (id: bigint) => {
        mintedId = id;
        return 0n; // no native trampoline installed for this signature.
      },
    }),
  );
  let bodyCalled = false;
  expect(() =>
    __withNoescapeBlock(
      () => {},
      'ZZ_v',
      () => {
        bodyCalled = true;
      },
    ),
  ).toThrow(/no inbound block trampoline/);
  expect(bodyCalled).toBe(false);
  expect(mintedId).toBeDefined();
  expect(__resolveCallback(mintedId as bigint)).toBeUndefined(); // dropped, not leaked
  expect(calls.some((c) => c.name === 'releaseBlock')).toBe(false); // nothing to release
});

// ── The ESCAPING default path (block-escaping-off-main-k45, ADR-0059 §2): pinned, not bracketed ────────

test('__makeEscapingBlock registers the fn, calls makeEscapingBlock, and keeps the fn pinned (no finally release)', () => {
  const fn = (): void => {};
  const block = __makeEscapingBlock(fn, '0_v');
  expect(block).toBe(0xeb10cn); // the stub's makeEscapingBlock return, handed back to the emitted call site
  const mk = calls.find((c) => c.name === 'makeEscapingBlock');
  expect(mk?.args[1]).toBe('0_v'); // the signature reaches the native maker
  const id = mk?.args[0] as bigint;
  // Unlike __withNoescapeBlock, the fn stays registered after the call — pinned while the block is live
  // (the framework may invoke it later, off thread 0). Teardown is native-driven, not a JS `finally`.
  expect(__resolveCallback(id)).toBe(fn);
  expect(calls.some((c) => c.name === 'releaseBlock')).toBe(false); // an escaping block is not bracket-released
});

// (The `installBlockReleaseDeliverer` wiring — the ADR-0059 §2 off-main teardown seam — is proven by the
// integration harness (`native/test`/the k42 embedder), since `__ensureInbound`'s once-only module guard
// makes the install call unobservable in a shared-module unit test that ran an earlier inbound test first.)

test('an un-installed escaping-block signature (0n) throws and drops the just-minted registry entry', () => {
  let mintedId: bigint | undefined;
  __installDispatch(
    recordingStub(calls, {
      makeEscapingBlock: (id: bigint) => {
        mintedId = id;
        return 0n; // no native escaping trampoline installed for this signature.
      },
    }),
  );
  expect(() => __makeEscapingBlock(() => {}, 'ZZ_v')).toThrow(
    /no inbound escaping-block trampoline/,
  );
  expect(mintedId).toBeDefined();
  expect(__resolveCallback(mintedId as bigint)).toBeUndefined(); // dropped, not leaked (no block to release)
});
