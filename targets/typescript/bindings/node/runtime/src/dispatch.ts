// The native dispatch seam (ADR-0054) — the boundary between the pure-TS runtime and
// the Swift N-API addon (Step 4). The emitted per-framework modules call the addon's
// per-signature entries through the `__dispatch` object; the runtime itself calls the
// fixed native primitives (retain/release, class/selector lookup, autorelease pools).
//
// Until the addon exists (Step 4), `__dispatch` is a throwing sentinel; tests inject a
// stub via `__installDispatch` (dependency injection, not module-resolution mocking).

import type { InboundCall, InboundResult } from './callbacks.js';

/**
 * One open per-signature dispatch entry (`aw_ts_msg_<codes>`, `aw_ts_fn_<name>`,
 * `aw_ts_const_<code>`). This is the FFI boundary: the entry set is open and both args and
 * return are genuinely untyped here — the *emitted* wrappers impose the real types (they
 * annotate the return, pass the result to a typed `__wrap*`, or `as`-cast an enum). This is
 * the one place `any` is correct; `any` args are also what let the precisely-typed native
 * primitives below (`getClass`, `release`, …) coexist with this string index signature.
 */
// biome-ignore lint/suspicious/noExplicitAny: FFI boundary — generated wrappers impose the type.
export type NativeEntry = (...args: any[]) => any;

/** The native addon surface (Step 4 provides the bodies; the stub mirrors it for tests). */
export interface NativeDispatch {
  /** Intern/look up an ObjC `Class` by name → its runtime handle. */
  getClass(name: string): bigint;
  /** Register/look up a `SEL` by name → its interned selector handle. */
  getSelector(name: string): bigint;
  /** `sel_getName` — a `SEL` handle → its selector name. The inverse of `getSelector`. */
  selectorName(sel: bigint): string;
  /**
   * `class_getName` — a `Class` handle → its ObjC runtime name. The inverse of `getClass`, and the
   * key `__classCtor` (classes.ts) resolves a returned `Class` through.
   */
  className(cls: bigint): string;
  /**
   * `object_getClass` — an **instance** handle → its `Class` handle. `getClass` goes name→class and
   * `className` class→name; this is the third edge, and without it an `id` the IR names no class for
   * could only ever wrap as the root `NSObject` (`dynamic-class-wrap-k88`). Composed with
   * `__classCtor` it yields the object's **real** bound constructor. Nil-safe (`0n` → `0n`).
   */
  classOf(id: bigint): bigint;
  /**
   * `class_getSuperclass` — a `Class` handle → its superclass's, `0n` at the root. Walked by the
   * **nearest bound ancestor** resolution (classes.ts): Cocoa's class clusters mean an object's own
   * class is usually private (`__NSCFString`, `__NSArrayI`) and no binding declares it, so the wrap
   * boundary climbs to the nearest ancestor one does.
   */
  superclassOf(cls: bigint): bigint;
  /** `objc_release` (ADR-0057 §4) — the dispose/FR paths call this on thread 0. */
  release(handle: bigint): void;
  /**
   * `objc_retain` → the same handle, +1 (ADR-0057 §2, the **borrowed** wrap). An inbound object arg
   * reaches a JS callback at +0 (the ObjC caller owns it), so `__wrapBorrowed`'s fresh mint takes its
   * own +1 here — reconstructing the store-time retain ARC inserts and JS cannot. The outbound +0 path
   * avoids this crossing by folding the retain into its dispatch entry; an inbound trampoline cannot
   * fold, because its ABI signature collapses `id`/`SEL`/`Class` into one pointer code. Null-safe.
   */
  retain(handle: bigint): bigint;
  /**
   * `objc_retainAutorelease` → the same handle, +1 with a pending autorelease (ADR-0057 §4, the
   * inbound-**return** arm): the +0-return convention an object returned from a JS callback must
   * satisfy — the caller owns nothing and the reference is valid until the pool drains, independent
   * of the JS wrapper's +1. A +1-convention selector (an overridden `copyWithZone:`/`init`) uses
   * `retain` instead. Null-safe.
   */
  retainAutorelease(handle: bigint): bigint;
  /** Push an autorelease pool, returning its handle (ADR-0057 §8). */
  pushAutoreleasePool(): bigint;
  /** Drain and pop the autorelease pool identified by `handle`. */
  popAutoreleasePool(handle: bigint): void;
  /** The CFSTR macro (ADR-0058): build a +1 owned `NSString` id from a JS string literal. */
  cfstr(str: string): bigint;
  /**
   * Synthesize one ObjC subclass of `baseClass` named `name` (once per JS class; memoized by the
   * caller), installing the back-ref ivar and a generated typed inbound trampoline IMP per override
   * (ADR-0059 §1/§3). Each override is `"<selector>|<objcTypeEncoding>"`; returns the new `Class`
   * handle (`0n` on allocation failure, e.g. a duplicate name). Thread-0 only.
   */
  defineSubclass(baseClass: bigint, name: string, overrides: readonly string[]): bigint;
  /** `[[cls alloc] init]` → the +1 owned instance id, for constructing a synthesized subclass (ADR-0059 §3). */
  allocInit(cls: bigint): bigint;
  /** `[[cls alloc] <initSel>: arg]` → the +1 owned instance id — a one-object-arg designated
   *  initializer (e.g. `initForWritingWithMutableData:`). No retain fold (init already returns +1). */
  allocInitWithObject(cls: bigint, initSel: bigint, arg: bigint): bigint;
  /** Stamp the JS `CallbackId` into a synthesized instance's back-ref ivar so its trampolines can reach JS (ADR-0059 §3). */
  setBackRef(instance: bigint, callbackId: bigint): void;
  /**
   * Synthesize one **per-protocol** forwarding ObjC class (base `NSObject`) named `name`,
   * memoized by the caller (ADR-0059 §3, delegate surface): install the back-ref ivar, a responds
   * bitset ivar, a generated typed inbound trampoline IMP per `"<selector>|<objcTypeEncoding>"`
   * override, and a `respondsToSelector:` override that answers from the per-instance snapshot;
   * best-effort `class_addProtocol(objc_getProtocol(protocol))`. Returns the `Class` handle (`0n` on
   * allocation failure). Thread-0 only. `protocol` names the ObjC `Protocol` for conformance.
   */
  defineForwarder(protocol: string, name: string, overrides: readonly string[]): bigint;
  /**
   * Stamp the set-time `respondsToSelector:` snapshot into a forwarder instance's bitset ivar
   * (ADR-0059 §3): bit `i` set iff the JS delegate implements protocol method `i`. The forwarder's
   * `respondsToSelector:` IMP reads this — exact `@optional` fidelity, no live off-main JS consult.
   */
  setRespondsBits(instance: bigint, bits: bigint): void;
  /**
   * `objc_setAssociatedObject(owner, key, obj, OBJC_ASSOCIATION_RETAIN)` — the delegate keep-alive
   * (ADR-0059 §6), thread-0. A strong association under an interned per-`key` pointer, so the
   * associated object lives exactly as long as `owner`, and re-associating the same key **releases
   * the previous object** (which is what makes re-setting a delegate slot leak-free). `obj === 0n`
   * clears the key. `owner` is any object handle — an instance, or a `Class` for a static slot.
   *
   * A bare primitive, deliberately: the k38 compound op it replaces (`bindDelegate` — send + associate
   * + balance, in one native call) only fitted a *setter*, and ADR-0055 §4b binds `id<P>` in every
   * param position (`emitted-delegate-spec-k84`). Ordering the association against the ObjC send is
   * now `delegate.ts`'s job, which is where the rest of the policy already lives.
   */
  associate(owner: bigint, key: string, obj: bigint): void;
  /**
   * Hand the runtime's `__invokeCallback` to the native side, capturing the thread-0 `napi_env` +
   * a `napi_ref` so env-less inbound IMPs can deliver on thread 0 (ADR-0059 §5). Idempotent; the
   * subclass machinery calls it once before the first synthesis.
   */
  installCallbackInvoker(invoke: (call: InboundCall) => InboundResult): void;
  /**
   * Hand the runtime's `__deliverDealloc` to the native side, capturing a `napi_ref` so the env-less
   * `dealloc` IMP can deliver on thread 0 (ADR-0059 §4). Installed alongside `installCallbackInvoker`
   * at first synthesis. The deliverer returns whether a JS `dealloc` override ran (so the native IMP
   * knows whether to chain `[super dealloc]` itself). Idempotent.
   */
  installDeallocDeliverer(deliver: (id: bigint) => boolean): void;
  /**
   * Hand the runtime's `__deliverValueReturning` to the native side, capturing a `napi_ref` so the
   * off-main value-returning tsfn bounce can invoke it on thread 0 (ADR-0056 §3 / ADR-0059 §5). The
   * native tsfn callback calls it with `(completion, call)`; `__deliverValueReturning` invokes the JS
   * side and — always, in a `finally` — posts the result back through `postCallbackCompletion`. Installed
   * alongside `installCallbackInvoker` at first synthesis; also the point the native side creates its
   * singleton bounce `napi_threadsafe_function` (thread 0). Idempotent.
   */
  installValueReturningDeliverer(deliver: (completion: bigint, call: InboundCall) => void): void;
  /**
   * Build a real ObjC block (ADR-0059 §2) whose invoke is the generated typed inbound trampoline for
   * `signature`, capturing `callbackId` — returns a heap block-pointer handle the emitted call site
   * passes as the block argument to the ordinary outbound dispatch entry (a block crosses as an `id`,
   * the same shape as `P`). A block has **no selector** and **no back-ref ivar**: the id is captured in
   * the `@convention(block)` closure, so `__invokeCallback` reads `call.selector === undefined` → the
   * registered target *is* the callable. `signature` content-addresses the block ABI shape (the shared
   * inbound code alphabet, `InboundSig::code_string` — the same codes that name the `aw_ts_inb_*`
   * trampolines), e.g. `'PQP_v'` = `void (^)(id, NSUInteger, BOOL *)`
   * (`-enumerateObjectsUsingBlock:` — the `BOOL* stop` out-pointer crosses as a raw handle `P`);
   * returns `0n` for an un-installed signature. The block is
   * `_Block_copy`'d to the heap so it survives the make→dispatch JS round-trip; `releaseBlock` drops
   * that +1. For `NS_NOESCAPE` it is invoked synchronously on thread 0 and released right after the
   * enclosing call (no tsfn — the baseline fast path). Thread-0 only.
   */
  makeBlock(callbackId: bigint, signature: string): bigint;
  /** `_Block_release` the heap block `makeBlock` returned (ADR-0059 §2); balances its `_Block_copy` +1. Null-safe. */
  releaseBlock(block: bigint): void;
  /**
   * Build a real **escaping** ObjC block (ADR-0059 §2 default/correctness-first path) whose invoke is
   * the generated typed inbound trampoline for `signature`, capturing `callbackId` — returns a heap
   * block-pointer handle. Unlike `makeBlock` (the `NS_NOESCAPE` fast path, released synchronously in a
   * `finally`), an escaping block **outlives the enclosing call** and may fire **off thread 0** (a stored
   * completion handler invoked on a GCD queue), so the JS function is **pinned by the registry** while
   * the block is live and delivery reuses the on-thread-0 direct invoke / off-main `napi_threadsafe_function`
   * bounce. Teardown is native-driven: when the framework does the last `_Block_release` (on **any**
   * thread) the block's captured holder routes the registry-drop to thread 0 (the ADR-0057
   * release-on-thread-0 seam) — so the caller does **not** bracket/release the registry entry. `signature`
   * content-addresses the block ABI (`'0_v'` = `void (^)(void)`, `'P_v'` = `void (^)(id)`, `'P_b'` =
   * `BOOL (^)(id)` — the shared inbound code alphabet); returns `0n` for an un-installed signature.
   * Thread-0 only.
   */
  makeEscapingBlock(callbackId: bigint, signature: string): bigint;
  /**
   * Hand the runtime's `__releaseCallback` to the native side, capturing a `napi_ref` so an escaping
   * block's off-main teardown can drop the registry keep-alive **on thread 0** (ADR-0059 §2 / ADR-0057).
   * The native side calls it (via the singleton bounce's release path) with the escaping block's
   * `callbackId` when the block is torn down. Installed alongside `installCallbackInvoker` at first
   * inbound use. Idempotent.
   */
  installBlockReleaseDeliverer(release: (id: bigint) => void): void;
  /**
   * Post the result of an off-main value-returning inbound callback (ADR-0059 §5) — marshal
   * `result` to the C-ABI return (or the typed nil/0 default on `threw`) and post the completion
   * semaphore the blocked bg thread waits on. `completion` is the opaque native round-trip handle.
   */
  postCallbackCompletion(completion: bigint, result: InboundResult): void;
  /** The open per-signature entries the emitted modules call. */
  readonly [entry: string]: NativeEntry;
}

const notLoaded = (): never => {
  throw new Error(
    '@apianyware/runtime: native addon not loaded — Step 4 provides it. ' +
      'In tests, inject a backend with __installDispatch().',
  );
};

/** The throwing default: any access fails loudly rather than silently no-op'ing. */
const NOT_LOADED: NativeDispatch = new Proxy({} as NativeDispatch, {
  get: notLoaded,
});

// ESM live binding: importers (emitted modules and the runtime's own code) read the
// current backend on every access, so __installDispatch swaps it atomically.
export let __dispatch: NativeDispatch = NOT_LOADED;

/** Install the native backend (the loaded `.node` addon in production; a stub in tests). */
export function __installDispatch(backend: NativeDispatch): void {
  __dispatch = backend;
}

// --- interned handle lookups ------------------------------------------------------------
// The addon's getClass/getSelector are the source of truth; the runtime caches by name so
// a hot call site pays the native crossing only once per distinct Class/SEL.

const classCache = new Map<string, bigint>();
const selCache = new Map<string, bigint>();
const selNameCache = new Map<bigint, string>();

/** The `Class` handle for `name`, interned JS-side (ADR-0055 §2). */
export function __class(name: string): bigint {
  const cached = classCache.get(name);
  if (cached !== undefined) return cached;
  const handle = __dispatch.getClass(name);
  classCache.set(name, handle);
  return handle;
}

/**
 * The interned `SEL` handle for `name`, interned JS-side. Serves both roles a `SEL` plays: the
 * selector of every dispatch (`__sel('setAction:')`) and a `SEL`-typed **argument** crossing from
 * JS (`setAction_(action: string)` → `__sel(action)`), which is why it takes `null` — the nil `SEL`.
 * Note `''` is NOT nil: `sel_registerName("")` interns a real, empty selector.
 */
export function __sel(name: string | null): bigint {
  if (name === null) return 0n;
  const cached = selCache.get(name);
  if (cached !== undefined) return cached;
  const handle = __dispatch.getSelector(name);
  selCache.set(name, handle);
  return handle;
}

/**
 * The selector name of a `SEL` handle crossing **out** of ObjC (ADR-0055 §3 keeps selectors
 * `string`s at the TS surface, so a `SEL` return must come back as its name) — the inverse of
 * [`__sel`]. `0n` → `null`, the nil `SEL` (`-[NSControl action]` with no action set). Memoized:
 * selectors are permanent, so a name never goes stale.
 */
export function __selName(sel: bigint): string | null {
  if (sel === 0n) return null;
  const cached = selNameCache.get(sel);
  if (cached !== undefined) return cached;
  const name = __dispatch.selectorName(sel);
  selNameCache.set(sel, name);
  return name;
}

/**
 * The CFSTR macro (ADR-0058): a +1 owned `NSString` id built from a JS string literal, for the
 * emitted `NSString`-valued constants (`export const TKGreeting = __wrapOwned(NSString,
 * __cfstr('…'))!`). Unlike `__class`/`__sel` it is NOT interned JS-side — CFSTR is interned in
 * the native runtime, and the caller takes ownership of the returned +1 via `__wrapOwned`.
 */
export function __cfstr(str: string): bigint {
  return __dispatch.cfstr(str);
}
