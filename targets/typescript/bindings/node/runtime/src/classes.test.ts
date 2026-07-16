import { beforeEach, expect, test } from 'vitest';
import { __alloc, __classArg, __classCtor, __init, __registerClass } from './classes.js';
import { type NativeDispatch, __installDispatch } from './dispatch.js';
import { NSObject, __wrapBorrowed, __wrapOwned, __wrapRetained } from './lifetime.js';

/**
 * A stub whose `getClass`/`className` are mutually inverse over a fixed name↔handle table — the
 * property the real libobjc pair has, and the one the registry's reverse lookup rests on.
 */
const TABLE: ReadonlyArray<readonly [string, bigint]> = [
  ['NSView', 100n],
  ['NSScanner', 200n],
  ['NSApplication', 300n],
  ['__NSCFConstantString', 400n], // a private class no binding declares — the stand-in case
  ['NSMemoProbe', 500n],
];

function stub(overrides: Partial<NativeDispatch> = {}): NativeDispatch {
  return {
    release: () => {},
    // The inbound wrap/return primitives (ADR-0057 §2/§4): identity by default — a test that
    // cares about retain accounting overrides them.
    retain: (handle: bigint) => handle,
    retainAutorelease: (handle: bigint) => handle,
    getClass: (n: string) => TABLE.find(([name]) => name === n)?.[1] ?? 0n,
    getSelector: (n: string) => BigInt(n.length),
    selectorName: (s: bigint) => `sel${s}`,
    className: (c: bigint) => TABLE.find(([, handle]) => handle === c)?.[0] ?? '',
    // `object_getClass` (k88): the fixture's instance handles are `<class handle> * 1000 + n`, so an
    // object's class is recoverable — that is what lets the dynamic-wrap tests below resolve a real class.
    classOf: (id: bigint) => id / 1000n,
    // The class-cluster walk (k88): the fixture's classes are a flat hierarchy, so the
    // superclass of any of them is the root — nothing further to climb.
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

// The emitted shape: a bound class registers itself from its own static block.
class NSView extends NSObject {
  static {
    __registerClass('NSView', NSView);
  }
}
class NSScanner extends NSObject {
  static {
    __registerClass('NSScanner', NSScanner);
  }
}
class NSMemoProbe extends NSObject {
  static {
    __registerClass('NSMemoProbe', NSMemoProbe);
  }
}

beforeEach(() => {
  __installDispatch(stub());
});

test('a Class param resolves its constructor to the ObjC Class handle', () => {
  // The param direction — the defect that made `NSStringFromClass(NSView)` pass a JS
  // constructor object into a bigint slot.
  expect(__classArg(NSView)).toBe(100n);
  expect(__classArg(NSScanner)).toBe(200n);
  // nil Class — the `__unwrap(null) === 0n` analogue.
  expect(__classArg(null)).toBe(0n);
});

test('__alloc dispatches +alloc on the receiver Class and wraps the owned result', () => {
  // `+alloc` is not emitted per class (only NSProxy, the one root class with no NSObject to
  // inherit it from, gets its own) — every other receiver shares this ONE runtime primitive.
  const calls: Array<[bigint, bigint]> = [];
  __installDispatch(
    stub({
      aw_ts_msg_0_P: (cls: bigint, sel: bigint) => {
        calls.push([cls, sel]);
        return cls * 1000n + 1n; // an id "of" the receiver class, mirroring the fixture's shape
      },
    }),
  );
  const instance = __alloc(NSView);
  expect(instance).toBeInstanceOf(NSView);
  expect(calls).toEqual([[100n, BigInt('alloc'.length)]]);
});

test('__init dispatches -init on the receiver and wraps the +1 owned result', () => {
  // The instance-side dual of `__alloc` (nsobject-plain-init-surface-gap-k122): the ABI-generic
  // `aw_ts_msg_0_P_o` shape any class's own generated `init()` body already calls
  // (`NSResponder.init()`, e.g.), reused for a class whose real ancestry never redeclares
  // `-init` itself. Built via `__alloc` first — the real `__alloc(Cls).init()` call shape a
  // synthetic `init(): this` body's `this` always is — so the fixture needs no null assertion.
  const calls: Array<[bigint, bigint]> = [];
  __installDispatch(
    stub({
      aw_ts_msg_0_P: () => 999n, // +alloc: a fresh, uninitialized id
      aw_ts_msg_0_P_o: (recv: bigint, sel: bigint) => {
        calls.push([recv, sel]);
        return recv; // the true root's own -init just returns self
      },
    }),
  );
  const instance = __alloc(NSView);
  const initialized = __init(instance);
  expect(initialized).toBe(instance);
  expect(calls).toEqual([[999n, BigInt('init'.length)]]);
});

test('registration records a THUNK, so importing a class costs no native crossing', () => {
  let crossings = 0;
  __installDispatch(
    stub({
      getClass: (n: string) => {
        crossings += 1;
        return TABLE.find(([name]) => name === n)?.[1] ?? 0n;
      },
    }),
  );
  class NSLate extends NSObject {
    static {
      __registerClass('NSLate', NSLate);
    }
  }
  // Defining (i.e. importing) the class resolved nothing.
  expect(crossings).toBe(0);
  __classArg(NSLate);
  expect(crossings).toBe(1);
  // …and `__class` memoizes, so a second use does not cross again.
  __classArg(NSLate);
  expect(crossings).toBe(1);
});

test('a Class return resolves to the bound constructor, and round-trips', () => {
  // The return direction: a raw handle becomes the very class the emitter generated, so
  // `===` and static-method access both work (what a stand-alone handle wrapper could not give).
  expect(__classCtor(100n)).toBe(NSView);
  expect(__classCtor(200n)).toBe(NSScanner);
  // Round-trip: out and back in.
  expect(__classArg(__classCtor(100n))).toBe(100n);
  // The nil Class.
  expect(__classCtor(0n)).toBeNull();
});

test('the resolved constructor is memoized, so the className crossing is paid once', () => {
  // A dedicated handle: the registry is module-level (one per process, as in production), so a
  // handle another test already resolved would be memoized before this one runs.
  let lookups = 0;
  __installDispatch(
    stub({
      className: (c: bigint) => {
        lookups += 1;
        return TABLE.find(([, handle]) => handle === c)?.[0] ?? '';
      },
    }),
  );
  expect(__classCtor(500n)).toBe(NSMemoProbe);
  expect(__classCtor(500n)).toBe(NSMemoProbe);
  expect(lookups).toBe(1);
});

test('an unregistered class resolves to a stand-in that carries the true handle', () => {
  // `-[@"x" class]` is `__NSCFConstantString` — a private class absent from the IR, so nothing
  // registers it. It must still round-trip: the stand-in carries the real handle, so passing it
  // back reaches the SAME ObjC class. (Returning `NSObject` here would silently substitute the
  // WRONG class; returning null would lose a perfectly good Class.)
  const stand = __classCtor(400n);
  expect(stand).not.toBeNull();
  expect(stand).not.toBe(NSObject);
  expect(__classArg(stand)).toBe(400n);
  // Identity is stable — a second lookup is the same object, so `===` is meaningful.
  expect(__classCtor(400n)).toBe(stand);
  // It carries the ObjC name, so it is debuggable rather than anonymous.
  expect(stand?.name).toBe('__NSCFConstantString');
});

test('a stand-in UPGRADES to the genuine constructor once its module is imported', () => {
  // A program that resolves a Class before importing the framework that binds it gets a
  // provisional stand-in; importing the module later must not leave the registry permanently
  // shadowed by it.
  const provisional = __classCtor(300n);
  expect(provisional?.name).toBe('NSApplication');

  class NSApplication extends NSObject {
    static {
      __registerClass('NSApplication', NSApplication);
    }
  }
  expect(__classCtor(300n)).toBe(NSApplication);
  expect(__classCtor(300n)).not.toBe(provisional);
  // The stale stand-in stays SOUND — it still names the same ObjC class.
  expect(__classArg(provisional)).toBe(300n);
});

test('a class that is not a bound ObjC class throws rather than passing the wrong Class', () => {
  // A user-derived JS subclass inherits nothing usable: its ObjC class is *synthesized* on first
  // instantiation (ADR-0059 §3). Before that it has no Class at all, and reading an inherited
  // static off the prototype chain would have handed ObjC the PARENT's Class — silently binding
  // the wrong class. Loud beats silent.
  class MyView extends NSView {}
  expect(() => __classArg(MyView)).toThrow(/not a bound ObjC class/);
  // A plain JS class is likewise rejected.
  class Unrelated extends NSObject {}
  expect(() => __classArg(Unrelated)).toThrow(/not a bound ObjC class/);
});

// ── The dynamic class wrap (`dynamic-class-wrap-k88`) ───────────────────────────────────────
//
// The registry applied at the *instance* wrap boundary rather than to a `Class` value. Before this,
// an `id` the IR names no class for minted a bare `NSObject`: `NSArray.array().objectAtIndex_(0)`
// came back with none of `NSString`'s methods, so a protocol-qualified slot could not honestly be
// typed by its interface (`protocol-binding-surface-k89`). The fixture's instance handles are
// `<class handle> * 1000 + n`, mirroring `object_getClass`.

test('a class-less id wraps into the class the object ACTUALLY is', () => {
  // The whole point: no declared class (the one-arg arm), yet the wrapper is a real NSView — it
  // carries NSView's methods, and `instanceof` holds. A bare `NSObject` would carry neither.
  const view = __wrapRetained(100_001n);
  expect(view).toBeInstanceOf(NSView);
  expect(view?.constructor).toBe(NSView);

  // Every wrap primitive takes the arm — the +1 (owned) and the inbound borrowed one too.
  expect(__wrapOwned(200_001n)).toBeInstanceOf(NSScanner);
  expect(__wrapBorrowed(500_001n)).toBeInstanceOf(NSMemoProbe);

  // A nil id is still null, in the class-less arm exactly as in the declared one.
  expect(__wrapRetained(0n)).toBeNull();
});

test('a DECLARED class still wins over the object’s real class', () => {
  // Deliberate, and the reason is in marshal.ts: the IR knows what the runtime does not say. A
  // declared `NSString` is really a `__NSCFString`, and no binding declares *that* — so where the IR
  // named a class, we mint it and never ask the object.
  let asked = 0;
  __installDispatch(
    stub({
      classOf: (id: bigint) => {
        asked += 1;
        return id / 1000n;
      },
    }),
  );
  // Handle 400_001n is really a `__NSCFConstantString`; declared as NSView, it mints NSView.
  const obj = __wrapRetained(NSView, 400_001n);
  expect(obj).toBeInstanceOf(NSView);
  expect(asked).toBe(0);
});

test('the live-wrapper path costs ZERO extra native crossings', () => {
  // The constraint that put the resolution inside `mint` rather than at the call site. The common
  // case — the same `sender` on every event — must not get more expensive than it was: a live
  // wrapper is returned as-is, so the object never gets asked for its class.
  let asked = 0;
  __installDispatch(
    stub({
      classOf: (id: bigint) => {
        asked += 1;
        return id / 1000n;
      },
    }),
  );
  const first = __wrapBorrowed(100_007n);
  expect(first).toBeInstanceOf(NSView);
  expect(asked).toBe(1); // the fresh mint asked, once

  const again = __wrapBorrowed(100_007n);
  expect(again).toBe(first); // same wrapper (ADR-0057 §3 uniquing)
  expect(asked).toBe(1); // …and it did NOT ask again
});

test('THE NEGATIVE CONTROL: an unregistered class lands on the stand-in, not a lie', () => {
  // `__NSCFConstantString` is in the runtime but no binding declares it — the *common* case for a
  // class-less id, not an edge case. It must not throw, and it must not silently claim to be some
  // other class: it gets §5b's stand-in, a real NSObject subclass carrying the true handle, with a
  // stable identity that upgrades if the owning module is ever imported.
  // NB distinct handles per test: the uniquing map (ADR-0057 §3) is module-scoped and outlives a
  // single `test`, so re-using a handle another test wrapped would return *that* wrapper.
  const obj = __wrapRetained(400_005n);
  expect(obj).toBeInstanceOf(NSObject);
  expect(obj?.constructor.name).toBe('__NSCFConstantString');

  // Stable identity: a second, distinct object of the same unregistered class wraps through the SAME
  // stand-in constructor — so `a.constructor === b.constructor` holds, as it does for a bound class.
  const other = __wrapRetained(400_006n);
  expect(other?.constructor).toBe(obj?.constructor);

  // And it is genuinely the stand-in, not one of the bound classes.
  expect(obj).not.toBeInstanceOf(NSView);
  expect(obj).not.toBeInstanceOf(NSScanner);
});
