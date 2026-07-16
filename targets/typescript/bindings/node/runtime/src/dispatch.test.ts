import { beforeEach, expect, test } from 'vitest';
import {
  type NativeDispatch,
  __cfstr,
  __class,
  __installDispatch,
  __sel,
  __selName,
} from './dispatch.js';

/** A spyable stub native backend — Step 4 provides the real addon. */
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
});

test('__installDispatch swaps the backend the runtime dispatches through', () => {
  // __class routes through whichever backend is currently installed.
  __installDispatch(stub({ getClass: () => 42n }));
  expect(__class('installSwapProbe')).toBe(42n);
});

test('__sel interns — one native getSelector call per distinct name', () => {
  let calls = 0;
  __installDispatch(
    stub({
      getSelector: (n) => {
        calls++;
        return BigInt(n.length);
      },
    }),
  );
  const a = __sel('internSelProbe:');
  const b = __sel('internSelProbe:');
  expect(a).toBe(b);
  expect(calls).toBe(1);
});

test('__class interns — one native getClass call per distinct name', () => {
  let calls = 0;
  __installDispatch(
    stub({
      getClass: (n) => {
        calls++;
        return BigInt(n.length);
      },
    }),
  );
  const a = __class('InternClassProbe');
  const b = __class('InternClassProbe');
  expect(a).toBe(b);
  expect(calls).toBe(1);
});

test('distinct selector names each hit the native backend once', () => {
  let calls = 0;
  __installDispatch(
    stub({
      getSelector: (n) => {
        calls++;
        return BigInt(n.length);
      },
    }),
  );
  __sel('distinctSelProbeA:');
  __sel('distinctSelProbeB:');
  expect(calls).toBe(2);
});

// --- __cfstr: the CFSTR macro over the native cfstr primitive (ADR-0058 §Scope) ---------

test('__cfstr builds a +1 owned NSString id via the native cfstr primitive', () => {
  __installDispatch(stub({ cfstr: (s) => BigInt(s.length) }));
  // Unlike __class/__sel, __cfstr does NOT intern JS-side — CFSTR is interned natively, so
  // each call crosses (the caller wraps the +1 owned id with __wrapOwned(NSString, …)).
  expect(__cfstr('Hello, TestKit')).toBe(BigInt('Hello, TestKit'.length));
});

// --- __sel / __selName: the SEL crossing, both directions (ADR-0055 §3) -----------------

test('__sel maps null to the nil SEL — and an empty string is NOT the nil SEL', () => {
  // A `SEL _Nullable` param (`-[NSControl setAction:nil]` clears the action) must reach ObjC as
  // the nil SEL. The trap this closes: `sel_registerName("")` returns a real, NON-nil selector,
  // so treating `''` as the nil sentinel would bind a garbage empty selector instead of clearing.
  // Only `null` short-circuits; `''` goes to the runtime like any other name.
  const interned: string[] = [];
  __installDispatch(
    stub({
      getSelector: (n) => {
        interned.push(n);
        return 99n;
      },
    }),
  );
  expect(__sel(null)).toBe(0n);
  expect(interned).toEqual([]); // null never reaches the runtime

  expect(__sel('')).toBe(99n); // '' interns as a real selector
  expect(interned).toEqual(['']);
});

test('__selName maps a SEL handle back to its selector name, and the nil SEL to null', () => {
  // The return direction: ADR-0055 §3 keeps selectors `string`s at the TS surface, so a SEL
  // return must come back as its name rather than as the raw handle it used to.
  __installDispatch(stub({ selectorName: (s) => (s === 7n ? 'doThing:' : 'other') }));
  expect(__selName(7n)).toBe('doThing:');
  // The nil SEL (`-[NSControl action]` with no action set) is null, not a bogus name.
  expect(__selName(0n)).toBeNull();
});

test('__selName memoizes — selectors are permanent, so a name never goes stale', () => {
  let calls = 0;
  __installDispatch(
    stub({
      selectorName: (s) => {
        calls += 1;
        return `sel${s}`;
      },
    }),
  );
  expect(__selName(11n)).toBe('sel11');
  expect(__selName(11n)).toBe('sel11');
  expect(calls).toBe(1);
});
