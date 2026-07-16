import { beforeEach, expect, test } from 'vitest';
import { __registerClass } from './classes.js';
import { type NativeDispatch, __installDispatch } from './dispatch.js';
import { NSObject, __unwrap } from './lifetime.js';
import { OBJ, RAW, RET_OBJ, RET_RAW } from './marshal.js';
import type { OverridableMethod } from './super.js';
import { __allocSubclass, __detectOverrides } from './super.js';

/** A stub covering exactly what super.ts + subclass.ts reach for. */
function stub(overrides: Partial<NativeDispatch> = {}): NativeDispatch {
  return {
    release: () => {},
    retain: (handle: bigint) => handle,
    retainAutorelease: (handle: bigint) => handle,
    getClass: (n: string) => TABLE.find(([name]) => name === n)?.[1] ?? 0n,
    getSelector: (n: string) => BigInt(n.length + 1000),
    selectorName: (s: bigint) => `sel${s}`,
    className: (c: bigint) => TABLE.find(([, handle]) => handle === c)?.[0] ?? '',
    classOf: (id: bigint) => id / 1000n,
    superclassOf: () => 0n,
    pushAutoreleasePool: () => 0n,
    popAutoreleasePool: () => {},
    cfstr: (s: string) => BigInt(s.length),
    postCallbackCompletion: () => {},
    defineSubclass: (_base, _name, overridesArg) => {
      lastDefineSubclassOverrides = [...overridesArg];
      return 900n;
    },
    allocInit: (cls: bigint) => (cls === 900n ? 900_001n : cls * 1000n + 1n),
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

const TABLE: ReadonlyArray<readonly [string, bigint]> = [
  ['NSView', 100n],
  ['NSResponder', 50n],
];

let lastDefineSubclassOverrides: readonly string[] = [];

beforeEach(() => {
  lastDefineSubclassOverrides = [];
  __installDispatch(stub());
});

// The emitted shape: NSResponder < NSView, each with its OWN overridable catalogue — mirroring how
// bound_methods (emit-typescript) is per-class-own, never accumulated.
class NSResponder extends NSObject {
  static {
    __registerClass('NSResponder', NSResponder);
  }
  static readonly __overridable: readonly OverridableMethod[] = [
    {
      name: 'mouseDown_',
      selector: 'mouseDown:',
      encoding: 'v@:@',
      superEntry: 'aw_ts_super_P_v',
      args: [OBJ],
      ret: RET_RAW,
    },
  ];
}
class NSView extends NSResponder {
  static {
    __registerClass('NSView', NSView);
  }
  // Shadows NSResponder's own static of the same name — real emitted subclasses redeclare it too
  // (each class's catalogue is its OWN methods, never accumulated — module doc).
  static override readonly __overridable: readonly OverridableMethod[] = [
    {
      name: 'drawRect_',
      selector: 'drawRect:',
      encoding: 'v@:q',
      superEntry: 'aw_ts_super_q_v',
      args: [RAW],
      ret: RET_RAW,
    },
  ];
}

test('the catalogue merges the WHOLE ancestor chain, not just the immediate parent', () => {
  // MyView extends NSView (drawRect_) which extends NSResponder (mouseDown_) — both selectors must
  // be detectable from MyView, since ObjC subclassing can override any reachable ancestor method.
  class MyView extends NSView {
    drawRect_(_r: number): void {}
    mouseDown_(_e: NSObject | null): void {}
  }
  const overrides = __detectOverrides(MyView);
  const selectors = overrides.map(([sel]) => sel).sort();
  expect(selectors).toEqual(['drawRect:', 'mouseDown:']);
});

test('only what the JS class ITSELF redeclares is detected — inherited-but-not-overridden is not', () => {
  class Base extends NSView {
    drawRect_(_r: number): void {}
  }
  class Derived extends Base {} // declares neither drawRect_ nor mouseDown_ itself
  expect(__detectOverrides(Base).map(([sel]) => sel)).toEqual(['drawRect:']);
  expect(__detectOverrides(Derived)).toEqual([]);
});

test('a plain hand-written class with no __overridable static contributes nothing, harmlessly', () => {
  class Intermediate extends NSView {} // no static __overridable of its own
  class Leaf extends Intermediate {
    drawRect_(_r: number): void {}
  }
  expect(__detectOverrides(Leaf).map(([sel]) => sel)).toEqual(['drawRect:']);
});

test('__allocSubclass installs exactly the detected overrides, not the whole catalogue', () => {
  class MyView extends NSView {
    drawRect_(_r: number): void {}
  }
  const handle = __allocSubclass(MyView);
  expect(handle).toBe(900_001n);
  expect(lastDefineSubclassOverrides).toEqual(['drawRect:|v@:q']);
});

test('$super dispatches through the right generated entry, converting args and the return', () => {
  let captured: unknown[] = [];
  __installDispatch(
    stub({
      aw_ts_super_P_P_o: (...args: unknown[]) => {
        captured = args;
        return 42n; // a fresh +1 owned return
      },
    } as Partial<NativeDispatch>),
  );
  class NSThing extends NSObject {
    static {
      __registerClass('NSThing', NSThing);
    }
  }
  class NSWidget extends NSThing {
    static {
      __registerClass('NSWidget', NSWidget);
    }
    static readonly __overridable: readonly OverridableMethod[] = [
      {
        name: 'copyWith_',
        selector: 'copyWith:',
        encoding: '@@:@',
        superEntry: 'aw_ts_super_P_P_o',
        args: [OBJ],
        ret: RET_OBJ('owned'),
      },
    ];
  }
  __installDispatch(
    stub({
      getClass: (n: string) => (n === 'NSThing' ? 700n : n === 'NSWidget' ? 800n : 0n),
      className: (c: bigint) => (c === 700n ? 'NSThing' : c === 800n ? 'NSWidget' : ''),
      aw_ts_super_P_P_o: (...args: unknown[]) => {
        captured = args;
        return 42n;
      },
    } as Partial<NativeDispatch>),
  );

  // A minimal $super shape — real emitted classes declare `copyWith_` as an actual method
  // (dispatching through `aw_ts_msg_*`), which is what makes `this.$super: this` well-typed in
  // production; this fixture only needs the ONE overridden member, so it types just that.
  interface SuperShape {
    copyWith_(zone: NSObject | null): NSWidget;
  }
  class MyWidget extends NSWidget {
    copyWith_(zone: NSObject | null): NSWidget {
      return (this as unknown as { $super: SuperShape }).$super.copyWith_(zone);
    }
  }
  const handle = __allocSubclass(MyWidget);
  const instance = new (MyWidget as unknown as new (h: bigint) => MyWidget)(handle);
  const zone = new (NSThing as unknown as new (h: bigint) => NSThing)(55n);

  const ret = instance.copyWith_(zone);

  // recv, superClass (NSWidget's own handle — the immediate JS parent), sel, then the converted arg.
  expect(captured[0]).toBe(handle);
  expect(captured[1]).toBe(800n);
  expect(captured[3]).toBe(__unwrap(zone));
  expect(__unwrap(ret)).toBe(42n);
});

test('a name not on the reachable catalogue throws rather than guessing', () => {
  class MyView extends NSView {}
  const handle = __allocSubclass(MyView);
  const instance = new (MyView as unknown as new (h: bigint) => MyView)(handle);
  expect(() =>
    (instance as unknown as { $super: Record<string, () => void> }).$super.nope(),
  ).toThrow(/not a \$super-overridable member/);
});
