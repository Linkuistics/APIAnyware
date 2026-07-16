// The object-model root (ADR-0055 §7) + lifetime spine (ADR-0057): the branded, disposable
// NSObject handle, uniform-+1 uniqued wrappers, deterministic Symbol.dispose primary, and
// a FinalizationRegistry best-effort backstop with the FR-lag-race guard. Pure TS — the
// retain/release *mechanism* is native (folded into dispatch, ADR-0057 §4); this owns the
// *policy* (uniquing, the disposed flag, when to release).

import { __dispatch } from './dispatch.js';
import { ObjectDisposedError } from './errors.js';

/** Per-wrapper state, kept off the instance so [Symbol.dispose] is its only public member. */
interface Cell {
  handle: bigint;
  disposed: boolean;
  /** FR unregister token — a dedicated object, never the wrapper (which must stay collectable). */
  readonly token: object;
}

const state = new WeakMap<NSObject, Cell>();

/** At most one live wrapper per ObjC `id` (ADR-0057 §3). The wrapper's +1 pins the id. */
const wrappers = new Map<bigint, WeakRef<NSObject>>();

/** The finalization backstop (DI seam) — defaults to the platform FinalizationRegistry. */
export interface Finalization {
  register(target: object, heldValue: bigint, token: object): void;
  unregister(token: object): void;
}

let finalization: Finalization = new FinalizationRegistry<bigint>(__frCleanup);

/** Swap the finalization backend (production: the platform FR; tests: a recording fake). */
export function __installFinalization(backend: Finalization): void {
  finalization = backend;
}

function cellOf(obj: NSObject): Cell {
  const cell = state.get(obj);
  if (cell === undefined) {
    throw new Error('@apianyware/runtime: untracked wrapper (internal invariant violated)');
  }
  return cell;
}

/**
 * The `this.$super` accessor's backing factory (ADR-0059 §4) — installed by `super.ts`, which
 * cannot be imported here without closing an ESM cycle (`super.ts` imports `NSObject`/`__unwrap`
 * from this module; the `__installCtorResolver` seam shape). Builds a proxy typed as the
 * superclass interface, one per `$super` access — see `super.ts` for the merge + dispatch logic.
 */
let superProxyFactory: ((instance: NSObject) => unknown) | undefined;

/** `super.ts` installs the `$super` proxy factory (module doc on `superProxyFactory`). */
export function __installSuperProxyFactory(factory: (instance: NSObject) => unknown): void {
  superProxyFactory = factory;
}

/**
 * The branded-handle root every bound ObjC class extends (ADR-0055 §1/§7). Emitted
 * subclasses declare neither the constructor nor the dispose hook — they inherit both.
 */
export class NSObject {
  // Nominal root brand (ADR-0055 §7): a plain object is not assignable to NSObject. Declared
  // (type-only, no runtime field); mutable state lives in the module WeakMap so [Symbol.dispose]
  // stays the ONLY public instance member and does not pollute every emitted subclass's surface.
  protected declare readonly __brand: undefined;

  /** Internal — wraps a native handle. The public creation path is alloc/init (emitter, ADR-0055 §6). */
  constructor(handle: bigint) {
    state.set(this, { handle, disposed: false, token: {} });
  }

  /**
   * `this.$super.<method>(…)` (ADR-0059 §4) — a proxy typed as the superclass interface (`this`,
   * so every inherited signature is checked at the call site) that dispatches through
   * `objc_msgSendSuper`, beginning lookup at the JS-declared parent's ObjC class — the type-safe
   * analogue of sbcl's `call-super`. `protected`: meaningful only from within a JS subclass's own
   * override body (native `super.` cannot drive ObjC super-chaining — module doc on
   * `superProxyFactory`), never from outside. Only reachable once `@apianyware/runtime`'s subclass
   * surface has loaded (always true once anything imports the package's public barrel).
   */
  protected get $super(): this {
    if (superProxyFactory === undefined) {
      throw new Error(
        '@apianyware/runtime: $super used before the subclass surface loaded (ADR-0059 §4)',
      );
    }
    return superProxyFactory(this) as this;
  }

  /**
   * Deterministic release (ADR-0057 §1 primary). Ordering (§6): release — and any synchronous
   * dealloc it triggers — completes BEFORE the disposed flag flips, so a re-entrant unwrap of
   * self during release still sees a live handle. Map removal is unconditional (a reachable
   * wrapper is necessarily its slot's occupant); the FR token is unregistered so no stale
   * finalizer double-fires.
   */
  [Symbol.dispose](): void {
    const cell = state.get(this);
    if (cell === undefined || cell.disposed) return;
    __dispatch.release(cell.handle);
    cell.disposed = true;
    wrappers.delete(cell.handle);
    finalization.unregister(cell.token);
  }
}

/**
 * The native handle of `obj`; `0n` for `null`; throws `ObjectDisposedError` on a disposed handle.
 *
 * Only ever reached with a **wrapped ObjC object**. A protocol-bound slot
 * (`setDelegate_(d: NSApplicationDelegate)` — ADR-0055 §4b) admits a plain JS object too, but such a
 * slot does not route here: the emitter renders it through [`__protocolArg`](./delegate.js), which
 * discriminates wrapper-from-literal and bridges the literal through its generated `DelegateSpec`
 * (`emitted-delegate-spec-k84`). k89 briefly guarded this entry with a named `TypeError` because the
 * literal path was reachable-but-unbuilt; it is built, so the guard is gone and a non-wrapper here is
 * once again what it always was — an internal invariant violation (`cellOf`).
 */
export function __unwrap(obj: NSObject | null): bigint {
  if (obj === null) return 0n;
  const cell = cellOf(obj);
  if (cell.disposed) throw new ObjectDisposedError();
  return cell.handle;
}

/** The constructor shape the wrap primitives mint through. */
type Ctor<T extends NSObject = NSObject> = new (handle: bigint) => T;

/**
 * Resolves an `id` to the constructor of its **real** ObjC class — installed by classes.ts, which owns
 * the ADR-0055 §5b ctor registry. Injected rather than imported (the `__installDispatch` /
 * `__installFinalization` seam shape) because classes.ts already imports `NSObject` from here; importing
 * back would close an ESM cycle.
 *
 * Uninstalled is not a degradation, it is the correct answer: without classes.ts there *is* no registry,
 * so the root is the only class anything could resolve to.
 */
let resolveCtor: ((id: bigint) => Ctor) | undefined;

/** classes.ts installs the id → real-ctor resolver (module doc on `resolveCtor`). */
export function __installCtorResolver(resolver: (id: bigint) => Ctor): void {
  resolveCtor = resolver;
}

/**
 * Mint the wrapper for `id`. `Cls` is the class the **IR declared** for the slot, or `null` when it
 * declared none — every `id` / `id<P>` return and every inbound object arg on an unqualified slot
 * (`dynamic-class-wrap-k88`).
 *
 * `null` resolves the object's **real** ObjC class through the registry, so the wrapper carries the
 * methods the object actually has. Before this, a class-less `id` minted a bare `NSObject`:
 * `NSArray.array().objectAtIndex_(0)` came back with none of `NSString`'s methods, and a protocol-typed
 * slot could not be honestly typed by its interface (`protocol-binding-surface-k89`).
 *
 * A **declared** class still wins, and deliberately: the IR knows what the real runtime does not say —
 * a declared `NSString` arg is really a `__NSCFString`, and no binding declares *that* (marshal.ts).
 *
 * The resolution lives **here**, on the mint path alone, so a live wrapper still costs zero extra
 * native crossings — the common case (the same `sender` on every event) must not get more expensive.
 */
function mint<T extends NSObject>(Cls: Ctor<T> | null, id: bigint): T {
  const C = (Cls ?? resolveCtor?.(id) ?? NSObject) as Ctor<T>;
  const obj = new C(id);
  wrappers.set(id, new WeakRef(obj));
  finalization.register(obj, id, cellOf(obj).token);
  return obj;
}

/**
 * Normalize the two call shapes every wrap primitive accepts: `(Cls, id)` — the IR declared the slot's
 * class — and `(id)` — it declared none, so the object's own class is resolved on the mint path. The
 * arity *is* the fact, so a call site cannot forget to say which it knows.
 */
function wrapArgs(a: Ctor | bigint, b?: bigint): [Ctor | null, bigint] {
  return typeof a === 'bigint' ? [null, a] : [a, b as bigint];
}

/**
 * Wrap a +0 (autoreleased) return whose native entry **folded a +1** in (ADR-0057 §4, so the
 * incoming `id` carries exactly one +1). A live wrapper already exists → **`release(id)` to
 * balance the fold's redundant +1** (uniform-+1: the live wrapper owns the one +1), then return
 * it; otherwise mint, keeping the fold's +1. `null` for the null handle. This is symmetric with
 * [`__wrapOwned`] — the two differ only in *where* the incoming +1 came from (the native fold for
 * +0, the method's own convention for +1); the existing-wrapper release is identical. The
 * existing wrapper's JS class may differ from `Cls`, but ObjC dispatch is dynamic, so returning
 * it typed as `T` is sound (ADR-0057 §3).
 */
export function __wrapRetained<T extends NSObject>(Cls: Ctor<T>, id: bigint): T | null;
/**
 * The IR declares no class for this slot: mint into the object's **real** class (`mint`).
 *
 * `T` is the **declared conformance** the emitter carries over from the IR, defaulting to
 * `NSObject` (so an unqualified `id` reads exactly as before). A slot the header declares
 * `id<P>` is emitted as `____wrapRetained<P & NSObject>(id)`, because its signature promises `P & NSObject`
 * and the class-less arm can only *statically* promise the root — the ObjC declaration is what
 * makes it true, and it is a fact the type system cannot check for itself
 * (`protocol-binding-surface-k89`, ADR-0055 §4b). The runtime behaviour is identical either way:
 * the class comes from the object, never from `T`.
 */
export function __wrapRetained<T extends NSObject = NSObject>(id: bigint): T | null;
export function __wrapRetained(a: Ctor | bigint, b?: bigint): NSObject | null {
  const [Cls, id] = wrapArgs(a, b);
  if (id === 0n) return null;
  const existing = wrappers.get(id)?.deref();
  if (existing !== undefined) {
    __dispatch.release(id);
    return existing;
  }
  return mint(Cls, id);
}

/**
 * Wrap a +1 (owned) return: an existing live wrapper triggers a `release(id)` to balance the
 * redundant incoming +1 (the `[immutableString copy]`-returns-self case, ADR-0057 §2), then is
 * returned; otherwise mint, keeping the +1. `null` for the null handle.
 */
export function __wrapOwned<T extends NSObject>(Cls: Ctor<T>, id: bigint): T | null;
/**
 * The IR declares no class for this slot: mint into the object's **real** class (`mint`).
 *
 * `T` is the **declared conformance** the emitter carries over from the IR, defaulting to
 * `NSObject` (so an unqualified `id` reads exactly as before). A slot the header declares
 * `id<P>` is emitted as `____wrapOwned<P & NSObject>(id)`, because its signature promises `P & NSObject`
 * and the class-less arm can only *statically* promise the root — the ObjC declaration is what
 * makes it true, and it is a fact the type system cannot check for itself
 * (`protocol-binding-surface-k89`, ADR-0055 §4b). The runtime behaviour is identical either way:
 * the class comes from the object, never from `T`.
 */
export function __wrapOwned<T extends NSObject = NSObject>(id: bigint): T | null;
export function __wrapOwned(a: Ctor | bigint, b?: bigint): NSObject | null {
  const [Cls, id] = wrapArgs(a, b);
  if (id === 0n) return null;
  const existing = wrappers.get(id)?.deref();
  if (existing !== undefined) {
    __dispatch.release(id);
    return existing;
  }
  return mint(Cls, id);
}

/**
 * Wrap a **borrowed** (+0) `id` — the third wrap primitive (ADR-0057 §2), and the only one on the
 * **inbound** side: the object args an ObjC caller hands a JS delegate / block / subclass override.
 * Nothing folded a +1 in and the method's convention gave none away: the caller owns the object and
 * JS owns nothing of it. So the two cases are exactly the *opposite* of the other two primitives'
 * — there is no redundant incoming +1 to balance:
 *
 * - **existing live wrapper → return it, no crossing at all.** The common case: the same `sender` on
 *   every event, the same `NSApplication` on every delegate call. Cheaper than the +0 outbound path.
 * - **fresh → take our own `+1` (`retain`), then mint.** This reconstructs the store-time retain ARC
 *   would insert and JS cannot (ADR-0057 §2's no-ARC argument, which applies identically here): a
 *   delegate that does `this.lastSender = sender` must not be holding a dangling handle once the
 *   caller's pool drains.
 *
 * Converges on the same invariant as `__wrapRetained`/`__wrapOwned`: **one wrapper owning exactly
 * one +1**, released by dispose or the FR backstop. A hot enumeration block over N distinct objects
 * mints N wrappers, reclaimed by FR — identical to an outbound loop, not a new cost.
 */
export function __wrapBorrowed<T extends NSObject>(Cls: Ctor<T>, id: bigint): T | null;
/**
 * The IR declares no class for this slot: mint into the object's **real** class (`mint`).
 *
 * `T` is the **declared conformance** the emitter carries over from the IR, defaulting to
 * `NSObject` (so an unqualified `id` reads exactly as before). A slot the header declares
 * `id<P>` is emitted as `____wrapBorrowed<P & NSObject>(id)`, because its signature promises `P & NSObject`
 * and the class-less arm can only *statically* promise the root — the ObjC declaration is what
 * makes it true, and it is a fact the type system cannot check for itself
 * (`protocol-binding-surface-k89`, ADR-0055 §4b). The runtime behaviour is identical either way:
 * the class comes from the object, never from `T`.
 */
export function __wrapBorrowed<T extends NSObject = NSObject>(id: bigint): T | null;
export function __wrapBorrowed(a: Ctor | bigint, b?: bigint): NSObject | null {
  const [Cls, id] = wrapArgs(a, b);
  if (id === 0n) return null;
  const existing = wrappers.get(id)?.deref();
  if (existing !== undefined) return existing;
  __dispatch.retain(id);
  return mint(Cls, id);
}

/**
 * The FinalizationRegistry backstop (ADR-0057 §5). Releases the id's +1 unconditionally, then
 * removes the uniquing slot ONLY if it still holds a dead `WeakRef` — the guard that closes the
 * FR-lag race (§3): a stale finalizer firing after the slot was re-taken by a live wrapper
 * releases its own +1 but must not evict the newer wrapper. The held value is the raw id, so the
 * callback never claims to know whose slot it holds — it reclaims only when nothing live occupies it.
 */
export function __frCleanup(id: bigint): void {
  __dispatch.release(id);
  if (wrappers.get(id)?.deref() === undefined) {
    wrappers.delete(id);
  }
}

/**
 * Run `fn` inside a native autorelease pool (ADR-0057 §8) — for hot synchronous JS loops on main
 * that never yield, and worker-thread ObjC work the ambient AppKit pool does not cover. Pops even
 * when `fn` throws.
 */
export function withAutoreleasePool<T>(fn: () => T): T {
  const pool = __dispatch.pushAutoreleasePool();
  try {
    return fn();
  } finally {
    __dispatch.popAutoreleasePool(pool);
  }
}
