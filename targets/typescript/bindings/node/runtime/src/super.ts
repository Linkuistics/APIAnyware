// `this.$super` (ADR-0059 §4) — the typed super-send accessor, and the automatic subclass
// construction it shares its catalogue with. The runtime *policy* half; the native
// `aw_ts_super_<code>` entries it dispatches through are generated (`emitted-subclass-surface-k96`,
// `super-send-table-k63`) — one per distinct inbound ABI signature, content-addressed exactly like
// the outbound `aw_ts_msg_*` table.
//
// ## Where the catalogue lives, and why merging it is cheap
//
// Every emitted class carries a `static readonly __overridable: readonly OverridableMethod[]` —
// its OWN bindable instance methods that have an installable inbound trampoline (the identical
// frontier `InboundTable`'s per-class walk generates the native side from, so a `superEntry` this
// module dispatches to always exists). A JS class may subclass any ANCESTOR's method, not just its
// immediate parent's own, so [`overridableCatalogue`] walks the constructor chain
// (`Object.getPrototypeOf`, exactly the ES6 `extends` link) merging each level's own catalogue —
// memoized per constructor, so the walk is paid once per distinct class, not once per instance.
//
// ## One catalogue, three consumers
//
// A cataloged entry is looked up by its **own class's** `hasOwnProperty` to decide whether a JS
// subclass overrides it ([`__detectOverrides`] — feeds `__subclassAlloc`'s native override-install
// list), and by name to build the `$super` proxy's per-member dispatcher ([`__makeSuperProxy`]).
// One record, two readers — the k57 discipline, now on the inbound side's third surface.
//
// ## Why args/return convert differently than an inbound callback's (marshal.ts)
//
// A `$super` send is an OUTBOUND call shape (ADR-0059 §4): `this.$super.drawRect_(r)` sends FROM JS
// TO ObjC, the mirror of an ordinary emitted call site, not of an inbound trampoline. So its
// argument conversion is the plain outbound one (`__unwrap`, no retain — the callee does not take
// ownership merely because it received a reference) and its return conversion is the plain outbound
// one (the ADR-0057 §4 retain-axis wrap). Both are the *opposite* of `marshal.ts`'s `argIn`/`retOut`,
// which serve the INBOUND direction (a callback's raw args in, its JS return out) and so wrap an
// object argument as *borrowed* and read no ownership off a return at all. Same `ArgKind`/`RetKind`
// vocabulary (one wire format, `arg_kind`/`ret_kind` in the emitter); different conversion, because
// the direction is different.

import { type ObjCClass, __classArg, __classCtor } from './classes.js';
import { __dispatch, __sel, __selName } from './dispatch.js';
import {
  type NSObject,
  __installSuperProxyFactory,
  __unwrap,
  __wrapOwned,
  __wrapRetained,
} from './lifetime.js';
import type { ArgKind, RetKind } from './marshal.js';
import { type SubclassOverride, __subclassAlloc } from './subclass.js';

/**
 * One class's own overridable instance method (ADR-0059 §4) — everything `__detectOverrides` and
 * `$super` need, derived by the emitter from the same [`InboundSig`]/`method_retain_axis` the native
 * super-send table is generated from, so `superEntry` always names a real `aw_ts_super_*` napi entry.
 */
export interface OverridableMethod {
  /** The injective TS method name (`:` → `_`) — the property `this.$super.<name>(…)` and a JS
   *  subclass's own override are both keyed by. */
  readonly name: string;
  /** The raw ObjC selector — what installs as the native subclass IMP / the `$super` send's `_cmd`. */
  readonly selector: string;
  /** The ObjC type encoding — `class_addMethod`'s types string (`__detectOverrides`'s native install list). */
  readonly encoding: string;
  /** The generated `aw_ts_super_<code>[_o|_n]` entry name `$super` dispatches through. */
  readonly superEntry: string;
  /** One kind per visible C-ABI param (the full list — a fallible method's trailing `NSError**`
   *  cell is just a raw pointer arg at this ABI, `InboundSig::from_method`'s treatment). */
  readonly args: readonly ArgKind[];
  readonly ret: RetKind;
}

/** A JS class value (a constructor) — the same shape `subclass.ts`'s private `JSClass` names. */
// biome-ignore lint/complexity/noBannedTypes: a JS class is exactly a constructor Function here.
type JSClass = Function;

/** Per-constructor merged catalogue (module doc) — paid once per distinct class. */
const catalogueCache = new WeakMap<JSClass, ReadonlyMap<string, OverridableMethod>>();

/**
 * The full overridable catalogue reachable from `ctor` — its own `static __overridable` merged
 * over every ancestor's, walking the `extends` chain (`Object.getPrototypeOf` on constructors,
 * exactly the ES6 link) up to (not including) `Function.prototype`. A plain, hand-written JS class
 * in the chain (no static `__overridable`) simply contributes nothing at its level — harmless,
 * since its own overrides already installed on *its own* synthesized ObjC class and are reached by
 * ordinary ObjC inheritance from there, not by this catalogue (`__detectOverrides`'s module doc).
 */
function overridableCatalogue(ctor: JSClass): ReadonlyMap<string, OverridableMethod> {
  const cached = catalogueCache.get(ctor);
  if (cached !== undefined) return cached;
  const parent = Object.getPrototypeOf(ctor) as JSClass | null;
  const merged = new Map<string, OverridableMethod>(
    parent !== null && parent !== Function.prototype ? overridableCatalogue(parent) : undefined,
  );
  const own = (ctor as { __overridable?: readonly OverridableMethod[] }).__overridable;
  if (own !== undefined) {
    for (const m of own) merged.set(m.name, m);
  }
  catalogueCache.set(ctor, merged);
  return merged;
}

/**
 * Which of `jsClass`'s catalogued (ancestor-reachable) methods it actually overrides — the native
 * `defineSubclass` override-install list (`[selector, encoding]`, ADR-0059 §3). Tested by
 * `hasOwnProperty` on `jsClass.prototype`, not by walking the whole catalogue: a method `jsClass`
 * does NOT itself redeclare is left uninstalled on `jsClass`'s own synthesized ObjC class, and ObjC
 * inheritance reaches an ANCESTOR JS class's override (already installed on that ancestor's own
 * synthesized class) exactly as it reaches any other inherited IMP — no accumulation needed here.
 */
export function __detectOverrides(jsClass: JSClass): readonly SubclassOverride[] {
  const parent = Object.getPrototypeOf(jsClass) as JSClass;
  const catalogue = overridableCatalogue(parent);
  const overrides: SubclassOverride[] = [];
  for (const m of catalogue.values()) {
    if (Object.prototype.hasOwnProperty.call(jsClass.prototype, m.name)) {
      overrides.push([m.selector, m.encoding]);
    }
  }
  return overrides;
}

/**
 * Allocate a `+1` owned instance of `jsClass`'s synthesized ObjC subclass, auto-detecting which
 * catalogued methods it overrides (`__detectOverrides`) — the ergonomic front door to
 * `__subclassAlloc` (`subclass.ts`), which otherwise needs the override list hand-supplied. The
 * base ObjC class is `jsClass`'s own JS-declared parent (`__classArg`, which already resolves BOTH a
 * bound emitted class and a previously-instantiated JS-subclass parent — `classes.ts`); a parent
 * that is a JS subclass never itself instantiated has no ObjC class yet and this throws, exactly as
 * `__classArg` documents.
 *
 * ```ts
 * class MyView extends NSView {
 *   constructor() {
 *     super(__allocSubclass(MyView));
 *     __bindSubclass(this);
 *   }
 *   drawRect_(dirtyRect: NSRect): void { … this.$super.drawRect_(dirtyRect); … }
 * }
 * ```
 */
export function __allocSubclass(jsClass: JSClass): bigint {
  const parent = Object.getPrototypeOf(jsClass) as ObjCClass;
  const baseClass = __classArg(parent);
  return __subclassAlloc(jsClass, baseClass, __detectOverrides(jsClass));
}

/** Convert one JS argument to the raw value `$super`'s native entry expects — the plain OUTBOUND
 *  param crossing (module doc): no retain, matching an ordinary emitted call site's param arm. */
function superArgOut(kind: ArgKind, value: unknown): unknown {
  switch (kind.k) {
    case 'raw':
      return value;
    case 'sel':
      return __sel(value as string | null);
    case 'cls':
      return __classArg(value as ObjCClass | null);
    case 'obj':
      return __unwrap(value as NSObject | null);
  }
}

/** Convert `$super`'s native raw return to its declared TS value — the plain OUTBOUND return
 *  crossing (module doc): the ADR-0057 §4 retain-axis wrap, class-less (dynamic-class-wrap-k88) so
 *  the wrapper carries the object's real class rather than a statically-named one. */
function superRetIn(kind: RetKind, raw: unknown): unknown {
  switch (kind.k) {
    case 'raw':
      return raw;
    case 'sel':
      return __selName(raw as bigint);
    case 'cls':
      return __classCtor(raw as bigint);
    case 'obj':
      return kind.axis === 'owned' ? __wrapOwned(raw as bigint) : __wrapRetained(raw as bigint);
  }
}

/**
 * Build `instance`'s `$super` proxy (ADR-0059 §4, `NSObject`'s `$super` getter — installed via
 * `__installSuperProxyFactory` to avoid an ESM cycle, module doc). One per access (cheap: the
 * catalogue and `__classArg` are memoized; only the `Proxy` and the receiver's live handle are
 * fresh), keyed by the ancestor catalogue reachable from `instance`'s JS-declared parent.
 */
export function __makeSuperProxy(instance: NSObject): unknown {
  const parent = Object.getPrototypeOf(instance.constructor) as ObjCClass;
  const superClass = __classArg(parent);
  const catalogue = overridableCatalogue(parent as unknown as JSClass);
  const recv = __unwrap(instance);
  return new Proxy(Object.create(null) as Record<string, unknown>, {
    get(_target, prop) {
      if (typeof prop !== 'string') return undefined;
      const m = catalogue.get(prop);
      if (m === undefined) {
        throw new TypeError(
          `@apianyware/runtime: '${prop}' is not a $super-overridable member (ADR-0059 §4)`,
        );
      }
      return (...args: readonly unknown[]): unknown => {
        const raw: unknown[] = [recv, superClass, __sel(m.selector)];
        for (let i = 0; i < m.args.length; i++) raw.push(superArgOut(m.args[i], args[i]));
        const entry = __dispatch[m.superEntry];
        return superRetIn(m.ret, entry(...raw));
      };
    },
  });
}

__installSuperProxyFactory(__makeSuperProxy);
