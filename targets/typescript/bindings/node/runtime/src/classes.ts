// The ObjC `Class` value surface (ADR-0055 §1) — how a `Class` metatype crosses in each
// direction. The dual of `__sel`/`__selName` (dispatch.ts) for the *other* pointer kind that
// is NOT a retainable object: a `Class` is pointer-shaped at the ABI, but it is never wrapped,
// never retained, never disposed (ADR-0057 §4 — retaining a class leaks). It is not a third
// handle population; it resolves to the **bound TS constructor** the emitter already generates.
//
// ## Why a registry (and why that is not a "call-time metadata consult")
//
// ADR-0055 §2's dumb-runtime rule bars the NativeScript tax: consulting a *metadata table* to
// discover a method's signature on every dispatch. It does not bar name-keyed maps — the runtime
// already leans on several (`wrappers` in lifetime.ts, mandated by ADR-0057 §3; `classCache` /
// `selCache` in dispatch.ts; `forwarders`; `synthesized`). Resolving a `Class` handle to its
// constructor is the same shape as the wrap boundary's `Map<id, WeakRef>`, and it is the
// established cross-target convention: gerbil's `register-objc-class!` emitted inline right after
// each `defclass` (ADR-0020), sbcl's `*objc-class-registry*` (ADR-0034).
//
// ## Registration is lazy and tree-shake-safe
//
// Each emitted class registers itself from an ES2022 **static block** in its own class body —
// `static { __registerClass('NSScanner', NSScanner); }`. A static block runs at class definition,
// is retained by any bundler that keeps the class, and does not appear in the `.d.ts` (so the
// declaration surface stays free of dispatch internals — the ADR-0055 §2 contract a bare
// top-level `__registerClass(...)` statement would have risked a tree-shaker dropping).
//
// Registration records a **thunk**, never a resolved handle, so importing a framework barrel costs
// zero native crossings — the `Class` is resolved on first use, through `__class`'s existing memo.

import { __class, __dispatch, __sel } from './dispatch.js';
import { NSObject, __installCtorResolver, __unwrap, __wrapOwned } from './lifetime.js';
import { __synthesizedClass } from './subclass.js';

/** A bound ObjC class: the emitted constructor (or the runtime root / a stand-in). */
export type ObjCClass = typeof NSObject;

/** ObjC runtime name → the bound TS constructor. Populated by `__registerClass` at class definition. */
const ctors = new Map<string, ObjCClass>();

/**
 * Constructor → its lazy `Class`-handle thunk. The constructor→handle direction, kept here rather
 * than read off a `__cls` static, so the runtime's `NSObject` — and therefore every emitted `.d.ts`
 * that extends it — carries no dispatch internals (ADR-0055 §2).
 */
const handles = new Map<ObjCClass, () => bigint>();

/** `Class` handle → the resolved constructor. Memoizes the `className` crossing (classes are permanent). */
const resolved = new Map<bigint, ObjCClass>();

/** Stand-ins minted for unregistered classes — provisional, so they can upgrade (see `__classCtor`). */
const standIns = new WeakSet<ObjCClass>();

/**
 * Register an emitted class under its ObjC runtime name (the name `class_getName` reports — the
 * IR keys on it precisely so a registry matches; see CONTEXT.md *ObjC runtime class name*). Called
 * from the class's own static block. Idempotent; records a **thunk**, so no native crossing happens
 * until the class is actually used.
 */
export function __registerClass(name: string, ctor: ObjCClass): void {
  ctors.set(name, ctor);
  handles.set(ctor, () => __class(name));
}

/**
 * The `Class` handle for a constructor crossing as a **`Class` argument** — the param dual of
 * `__unwrap` (which handles instances). `null` → the nil `Class`, `0n`.
 *
 * A JS class the user derived from a bound class (`class MyView extends NSView` — ADR-0059 §3) is
 * NOT its parent: its ObjC class is *synthesized*, so it resolves through the subclass machinery's
 * memo. Before its first instantiation no ObjC class exists for it yet, and an unbound constructor
 * has no handle at all — both **throw** rather than silently handing ObjC the *parent's* `Class`
 * (which is what reading an inherited `__cls` off the prototype chain would have done).
 */
export function __classArg(cls: ObjCClass | null): bigint {
  if (cls === null) return 0n;
  const thunk = handles.get(cls);
  if (thunk !== undefined) return thunk();
  const synthesized = __synthesizedClass(cls);
  if (synthesized !== undefined) return synthesized;
  throw new Error(
    `@apianyware/runtime: ${cls.name || '<anonymous>'} is not a bound ObjC class. Pass a generated class (imported from its framework module). A JS subclass of one has no ObjC class until it is first instantiated.`,
  );
}

/**
 * `+alloc` (ADR-0055 §6 "faithful alloc/init") — the public creation path every emitted class's
 * own `init…` instance method assumes (`lifetime.ts`'s `NSObject` constructor doc). Not emitted
 * per class: `+alloc` is declared exactly once, on the ObjC root, so every receiver dispatches
 * through the SAME fixed `Class -> id` shape (`aw_ts_msg_0_P`) the emitter already generates for
 * any zero-arg object-returning class method — one shared runtime primitive rather than one
 * generated copy per class (the `NSProxy.alloc()` special case is the one exception: NSProxy is a
 * ROOT class with no ObjC `NSObject` to inherit `alloc` from, so the emitter gives it its own).
 * Returns an **owned, uninitialized** instance — call one of `Cls`'s own `init…` methods on the
 * result before using it; the `init…` call's own return (not this one) is the real object (ADR-0057
 * §2 — `init` may return a different pointer than `alloc` did).
 */
export function __alloc<T extends NSObject>(cls: new (handle: bigint) => T): T {
  const id = __dispatch.aw_ts_msg_0_P(__classArg(cls as unknown as ObjCClass), __sel('alloc'));
  // A resolved Class's own +alloc returns freshly allocated memory, never nil (nsproxy.ts's
  // generated `alloc()` asserts the same for the one class that carries its own copy).
  // biome-ignore lint/style/noNonNullAssertion: alloc on a resolved Class cannot return nil.
  return __wrapOwned(cls, id)!;
}

/**
 * `-init` (ADR-0055 §6 "faithful alloc/init") — the instance-side dual of [`__alloc`]: the exact
 * fixed `id -> id` dispatch shape (`aw_ts_msg_0_P_o`) any class's own generated `init()` body
 * already calls (`NSResponder.init()`, e.g.), reused here as one shared runtime primitive rather
 * than a per-class generated copy — for the classes whose real ObjC ancestry never redeclares
 * `-init` itself. The true ObjC root `NSObject`'s own `-init` is never itself extracted as a
 * declared entity anywhere in the IR (ADR-0055 §1/§7 — the runtime's `NSObject` is a
 * branded-handle stand-in, never a generated file), so a class with no init-redeclaring ancestor
 * has no real call site to inherit from `extends`. `emit-typescript` emits a synthetic
 * `init(): this { return __init(this); }` for exactly those classes
 * (`nsobject-plain-init-surface-gap-k122`). Dynamic ObjC dispatch resolves the message send
 * correctly regardless of which class this is called on: a genuine override anywhere in the real
 * chain still fires — this is only a stand-in for a class whose chain has none.
 */
export function __init<T extends NSObject>(obj: T): T {
  const id = __dispatch.aw_ts_msg_0_P_o(__unwrap(obj), __sel('init'));
  // biome-ignore lint/style/noNonNullAssertion: init on a non-nil receiver cannot return nil.
  return __wrapOwned<T>(id)!;
}

/**
 * The constructor for a `Class` handle crossing **out** of ObjC — the return dual of `__classArg`.
 * `0n` → `null` (the nil `Class`).
 *
 * A handle whose class is not registered — its framework module was never imported, or the class is
 * private and absent from the IR entirely (`-[@"x" class]` is `__NSCFConstantString`, which no
 * binding declares) — resolves to a **stand-in**: a real `NSObject` subclass carrying the true
 * handle, so it round-trips (`NSStringFromClass` of it reports the right name) and keeps a stable
 * `===` identity. A stand-in is provisional: if its module is imported later, the next lookup
 * upgrades to the genuine bound constructor. A stand-in handed out *before* that import stays a
 * sound-but-stale alias of the same ObjC class — the unavoidable cost of asking about a class you
 * had not imported.
 */
export function __classCtor(cls: bigint): ObjCClass | null {
  if (cls === 0n) return null;
  const memo = resolved.get(cls);
  // A genuine registration is final; a stand-in re-checks the registry (a map hit, no crossing) in
  // case the owning module has since been imported.
  if (memo !== undefined && !standIns.has(memo)) return memo;

  const name = __dispatch.className(cls);
  const bound = ctors.get(name);
  if (bound !== undefined) {
    resolved.set(cls, bound);
    return bound;
  }
  if (memo !== undefined) return memo; // still unregistered — keep the stable stand-in

  const stand: ObjCClass = class extends NSObject {};
  Object.defineProperty(stand, 'name', { value: name });
  standIns.add(stand);
  handles.set(stand, () => cls);
  resolved.set(cls, stand);
  return stand;
}

/** An object's runtime `Class` → the ctor it wraps through. Memoizes the ancestor walk below. */
const objectCtors = new Map<bigint, ObjCClass>();

/**
 * The constructor an object wraps into — the registry applied at the **instance** wrap boundary rather
 * than to a `Class` *value* (`dynamic-class-wrap-k88`). This is what lets the runtime wrap an `id` the IR
 * names no class for into a wrapper that really carries the object's methods:
 * `NSArray.array().objectAtIndex_(0)` yields a real `NSString`, not a bare root object with none of them.
 *
 * ## Nearest bound ancestor — because of class clusters
 *
 * An object's *own* class is usually **not** one any binding declares, and that is not an edge case: it is
 * how Cocoa is built. A string is a `__NSCFString` or an `NSTaggedPointerString`, an array an `__NSArrayI`,
 * a dictionary an `__NSDictionaryI` — class-cluster privates, absent from every header and so from the IR.
 * Resolving to the object's literal class would therefore hand back a **stand-in with no methods** for
 * almost every real object: the very lie this exists to remove (measured first-hand — the negative control
 * in `test/dynamic-class.mjs` is what caught it).
 *
 * So the walk climbs `class_getSuperclass` to the nearest ancestor the binding **does** declare —
 * `__NSCFString` → `NSMutableString` → `NSString` — and mints that. Every method it exposes is one the
 * object genuinely responds to, because ObjC inheritance says so. This is the **gerbil "nearest bound
 * ancestor"** rule (ADR-0020), which `class_binding.rs` already applies to a *type reference*; here it is
 * the same rule at the *value* boundary.
 *
 * With no bound ancestor at all, §5b's **stand-in** is still the answer: a real `NSObject` subclass carrying
 * the true handle, so the object round-trips with a stable identity and the right name.
 *
 * ## Cost
 *
 * Memoized on the object's runtime `Class` (classes are permanent), so the walk runs once per distinct
 * runtime class — and it is only ever reached from `mint`, so a live wrapper still costs **zero** native
 * crossings. A memo taken before a nearer ancestor's module was imported stays a *sound but less specific*
 * alias — the same trade-off §5b already documents for a stand-in handed out before its import.
 */
function ctorForObject(id: bigint): ObjCClass {
  const own = __dispatch.classOf(id);
  const memo = objectCtors.get(own);
  if (memo !== undefined) return memo;

  for (let cls = own; cls !== 0n; cls = __dispatch.superclassOf(cls)) {
    const bound = ctors.get(__dispatch.className(cls));
    if (bound !== undefined) {
      objectCtors.set(own, bound);
      return bound;
    }
  }
  // Nothing on the chain is bound (a wholly private hierarchy, or no framework module imported yet).
  const stand = __classCtor(own) ?? NSObject;
  objectCtors.set(own, stand);
  return stand;
}

// Installed into lifetime.ts's mint path rather than imported by it — classes.ts already imports NSObject
// from there, and importing back would close an ESM cycle (the `__installDispatch` seam shape).
__installCtorResolver(ctorForObject);
