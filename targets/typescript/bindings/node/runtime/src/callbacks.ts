// The inbound callback / delivery half of @apianyware/runtime (ADR-0056/0059) — the runtime-side
// machinery the Step-4 native inbound trampolines call *into*. It is the **inbound dual** of the
// outbound direction: ADR-0054 sends JS→ObjC through generated typed native dispatch; here ObjC
// calls back out to JS through generated typed native trampolines, and this module is the pure-TS
// boundary they land on. Everything C-ABI (the @_cdecl trampolines, blocks, objc_allocateClassPair,
// associated objects, the napi_threadsafe_function, the completion semaphore) is native (Step 4);
// this owns the *policy* — the keep-alive registry, exception containment, and the always-complete
// delivery discipline.
//
// ── The inbound wire contract (Decision 1; the dual of k32's NativeErrorResult) ──────────────────
// A native trampoline that has marshalled its C-ABI args into JS values calls the runtime with an
// `InboundCall` = {callback-id, optional selector, args}. The runtime looks the JS side up in the
// registry, invokes it (a block → the function itself; a delegate/override → the injective
// selector→name method), and hands back an `InboundResult` = {threw:false, value} | {threw:true}.
// On `threw:true` the JS side already threw and was reported (ADR-0059 §7) — the *native* side
// substitutes its typed nil/0 default (it alone knows the ABI return type). The three ADR-0059 §5
// delivery paths map onto the two runtime entries below:
//   • on thread 0 (direct)           → native calls __invokeCallback, reads .value (or ignores it)
//   • off-main, void                 → native calls __invokeCallback (blocking tsfn), ignores .value
//   • off-main, value-returning      → native calls __deliverValueReturning(completion, call), which
//                                      ALWAYS posts the completion the blocked bg thread waits on
// Registry identity (Decision 2): the callback-id is a **JS-minted monotonic bigint token**, minted
// here at registration and carried by the native side (a block context / a forwarder back-ref ivar).
// It is a distinct token space from ADR-0057's Map<id, WeakRef> (which uniques *outbound* wrappers by
// ObjC id) — so it neither collides with nor couples to that uniquing; the only shared discipline is
// release-on-thread-0. Monotonic-never-reused closes the stale-id race: a native call bearing a
// released id resolves to `undefined` and is contained (report + default), never mis-dispatched.

import { __dispatch } from './dispatch.js';

// ── The wire-contract types ──────────────────────────────────────────────────────────────────────

/** The registry token the native side keys on. JS-minted, monotonic; `0n` is never a valid id. */
export type CallbackId = bigint;

/** A registered JS callable — a closure (block), a delegate object, or a subclass instance. */
// biome-ignore lint/suspicious/noExplicitAny: callback boundary — the native trampoline imposes the ABI-derived signature.
export type CallbackFn = (...args: any[]) => unknown;

/**
 * One inbound call the native trampoline hands to the runtime. `selector` is the **raw ObjC
 * selector** for a delegate/override dispatch (the runtime applies the ADR-0055 §3 injective
 * `:`→`_` map); absent for a block invoke (the registered target is the callable itself). `args`
 * are the C-ABI arguments already marshalled to JS values by the native trampoline.
 */
export interface InboundCall {
  readonly id: CallbackId;
  readonly selector?: string;
  readonly args: readonly unknown[];
}

/**
 * What the runtime hands back to the native trampoline. `threw:false` carries the JS return value
 * to marshal; `threw:true` signals the JS side threw (or could not deliver) — already reported via
 * `onCallbackError` — so the native side substitutes its typed nil/0 default (ADR-0059 §7).
 */
export type InboundResult =
  | { readonly threw: false; readonly value: unknown }
  | { readonly threw: true };

/**
 * The **inbound value surface** of one registered callback (ADR-0059 §8) — how its raw C-ABI args
 * become the types the emitted interface declares, and how its JS return becomes the handle ObjC
 * expects. Structural on purpose: this module declares the shape but **imports nothing** to build
 * one (marshal.ts does, from the kind descriptors), so the registry funnel stays free of the
 * uniquing map / ctor registry it would otherwise have to reach for — and the module graph stays
 * acyclic.
 *
 * Optional per callback: a target registered **without** one traffics in raw `bigint` handles, which
 * is the pre-descriptor behaviour every native-level battery is written against. The emitter never
 * produces a partial descriptor (a covered method set that misses one of its own selectors throws —
 * marshal.ts), so "no marshal" and "fully marshalled" are the only two states a generated call site
 * can be in.
 */
export interface CallbackMarshal {
  /** Convert the raw C-ABI args the trampoline delivered into the declared TS types. */
  in(selector: string | undefined, args: readonly unknown[]): unknown[];
  /** Convert the JS return into the raw handle/scalar the trampoline hands back to ObjC. */
  out(selector: string | undefined, value: unknown): unknown;
}

/** The shared "JS side threw / could not deliver" signal — immutable, so a single instance is safe. */
const THREW: InboundResult = { threw: true };

// ── onCallbackError: the settable, guarded reporting hook (ADR-0059 §7) ───────────────────────────

/** Context carried to the error hook: which callback threw, and (for a delegate/override) which selector. */
export interface CallbackErrorContext {
  readonly id: CallbackId;
  readonly selector?: string;
}

/** The reporting hook signature. A throw *inside* a handler is swallowed-and-logged, never propagated. */
export type CallbackErrorHandler = (error: unknown, context: CallbackErrorContext) => void;

/** Node's `process.emit('uncaughtException', …)`, typed locally to avoid an `@types/node` dependency. */
interface UncaughtEmitter {
  emit(event: 'uncaughtException', error: Error): boolean;
}

function uncaughtEmitter(): UncaughtEmitter | undefined {
  const p = (globalThis as { process?: unknown }).process;
  if (typeof p === 'object' && p !== null && typeof (p as UncaughtEmitter).emit === 'function') {
    return p as UncaughtEmitter;
  }
  return undefined;
}

/**
 * The default hook (ADR-0059 §7): route to Node's `uncaughtException` — the same channel an
 * unhandled throw on the main path surfaces through, *without* tearing down the GUI app (the
 * rejected propagate/abort option). `process.emit` runs any registered listeners; with none it is a
 * no-op — deliberately non-fatal. On a non-Node engine (`process` absent) the report is a silent
 * no-op; containment (catch + typed default) still holds — only the surfacing is Node-specific.
 */
const defaultHandler: CallbackErrorHandler = (error) => {
  uncaughtEmitter()?.emit(
    'uncaughtException',
    error instanceof Error ? error : new Error(String(error)),
  );
};

let handler: CallbackErrorHandler = defaultHandler;

/**
 * Install the callback-error reporting hook (ADR-0059 §7). Pass `null` to restore the Node
 * `uncaughtException` default. The whole GUI app must not die on one callback bug, so a handler
 * that itself throws is contained (see `reportCallbackError`), never allowed to unwind the C ABI.
 */
export function onCallbackError(fn: CallbackErrorHandler | null): void {
  handler = fn ?? defaultHandler;
}

/** Best-effort log via `console.error` if present — dependency-free and defensive. */
function safeLog(message: string, detail: unknown): void {
  const c = (globalThis as { console?: { error?: (...a: unknown[]) => void } }).console;
  try {
    c?.error?.(message, detail);
  } catch {
    // console itself faulted — nothing safe remains to do.
  }
}

/** The minimal error context for a call — omits `selector` when absent (exactOptionalPropertyTypes). */
function contextOf(call: InboundCall): CallbackErrorContext {
  return call.selector === undefined ? { id: call.id } : { id: call.id, selector: call.selector };
}

/** Report a contained callback error via the hook, guarding a throw *inside* the hook (ADR-0059 §7). */
function reportCallbackError(error: unknown, context: CallbackErrorContext): void {
  try {
    handler(error, context);
  } catch (nested) {
    safeLog('@apianyware/runtime: onCallbackError handler threw', nested);
  }
}

// ── The keep-alive / callback registry (ADR-0059 §6) ──────────────────────────────────────────────
// A *strong* Map — its entry IS the JS-side keep-alive that pins the callable alive while registered
// (the JS half of the native associated-object / tsfn keep-alive). Contrast ADR-0057's `wrappers`
// map, which holds WeakRefs precisely so wrappers stay collectable; here the intent is the opposite.
// Registry mutation (register/release) and `nextId` advance are **thread-0-only** (ADR-0059
// Mechanics: napi_ref/Map mutation off thread 0 crashes); every off-main path routes its JS-side
// register/release to thread 0 via the tsfn. This is a documented contract the pure-TS side cannot
// itself enforce.

/** One registry entry: the JS side, plus how its values cross the seam (ADR-0059 §8; optional). */
interface Entry {
  readonly target: object;
  readonly marshal?: CallbackMarshal | undefined;
}

const callbacks = new Map<CallbackId, Entry>();
let nextId: CallbackId = 1n;

/**
 * Register a JS callable/object/instance; returns the monotonic id the native side carries.
 * `marshal` — the [`CallbackMarshal`] built from the emitted value-kind descriptors (marshal.ts) —
 * is what makes the callback's declared types real; omitted, its values cross as raw handles.
 */
export function __registerCallback(target: object, marshal?: CallbackMarshal): CallbackId {
  const id = nextId++;
  callbacks.set(id, { target, marshal });
  return id;
}

/** Resolve the JS side a native trampoline holds by id; `undefined` if released (a stale id). */
export function __resolveCallback(id: CallbackId): object | undefined {
  return callbacks.get(id)?.target;
}

/**
 * Drop the JS-side keep-alive for `id` (the native association + tsfn refcount are released
 * separately, natively). Must run on thread 0 (ADR-0057 release-on-thread-0, shared discipline); the
 * native forwarder/block dealloc — which can fire off-main — routes this JS-touching drop to thread 0.
 */
export function __releaseCallback(id: CallbackId): void {
  callbacks.delete(id);
}

/** Look the method up by the ADR-0055 §3 injective `:`→`_` selector map (no elision, no rename table). */
function methodFor(target: object, selector: string): CallbackFn {
  const name = selector.replace(/:/g, '_');
  const fn = (target as Record<string, unknown>)[name];
  if (typeof fn !== 'function') {
    throw new TypeError(`callback target does not implement ${name} (selector ${selector})`);
  }
  return fn as CallbackFn;
}

// ── The trampoline-facing invoke helper — catch → report → typed-default (ADR-0059 §7) ────────────

/**
 * The universal inbound boundary the native trampoline calls (on thread 0, whether reached directly
 * or via the tsfn bounce). Resolves the JS side, **converts its args to the declared types**
 * (ADR-0059 §8 — an object handle becomes a borrowed wrapper, a `SEL` its name, a `Class` its bound
 * constructor), invokes it — a block as the callable itself, a delegate/override by its injective
 * selector→name method with `this` bound to the target — **converts the return back** to the raw
 * handle ObjC expects (carrying the ADR-0057 §4 retain axis), and **contains every JS throw**: no
 * exception crosses the C ABI into the framework's runloop (the ADR-0058 native-`@catch` mirror;
 * unwinding would corrupt the pump).
 *
 * Both conversions run **inside** the containment, so a descriptor bug (an uncovered selector, a
 * disposed wrapper returned) fails exactly like a JS throw: reported via `onCallbackError`,
 * `{threw:true}`, native substitutes its typed nil/0 default. This function is contract-bound to
 * **never throw**.
 */
export function __invokeCallback(call: InboundCall): InboundResult {
  const entry = callbacks.get(call.id);
  if (entry === undefined) {
    // A native call bearing a released/unknown id — a native lifetime bug or a teardown race.
    // Contain it (report + default) rather than dereferencing nothing.
    reportCallbackError(new Error(`callback ${call.id} is not registered`), contextOf(call));
    return THREW;
  }
  const { target, marshal } = entry;
  try {
    const args = marshal === undefined ? call.args : marshal.in(call.selector, call.args);
    const returned =
      call.selector === undefined
        ? (target as CallbackFn)(...args)
        : methodFor(target, call.selector).call(target, ...args);
    const value = marshal === undefined ? returned : marshal.out(call.selector, returned);
    return { threw: false, value };
  } catch (error) {
    reportCallbackError(error, contextOf(call));
    return THREW;
  }
}

function isThenable(v: unknown): boolean {
  return (
    (typeof v === 'object' || typeof v === 'function') &&
    v !== null &&
    typeof (v as { then?: unknown }).then === 'function'
  );
}

/**
 * The thread-0 landing for an **off-main value-returning** callback (ADR-0059 §5): the native tsfn
 * callback bounces the call to thread 0, invokes the JS side here, and this **always** posts the
 * `completion` the blocked bg thread waits on — the always-complete discipline (ADR-0059 §7) that is
 * policy here even though the semaphore/tsfn primitives are native. `completion` is the opaque native
 * round-trip handle; `postCallbackCompletion` marshals the result and posts the semaphore.
 *
 * Two non-happy paths still post, so the bg thread never hangs: a contained JS throw (already
 * `{threw:true}` from `__invokeCallback`), and an **async-in-value-slot** return — an `async` method
 * used where a value is needed cannot deliver synchronously (ADR-0056 finding C forbids inline
 * `await`), so it is reported and coerced to the typed default (not silent). A native enqueue-failure
 * before this runs is the native side's dual obligation (it posts the default itself, ADR-0059 §7).
 */
export function __deliverValueReturning(completion: bigint, call: InboundCall): void {
  // Default to THREW so that even an unexpected fault below still posts a typed default — never hang.
  let result: InboundResult = THREW;
  try {
    const invoked = __invokeCallback(call);
    if (!invoked.threw && isThenable(invoked.value)) {
      reportCallbackError(
        new Error('async callback cannot return a value synchronously'),
        contextOf(call),
      );
    } else {
      result = invoked;
    }
  } finally {
    __dispatch.postCallbackCompletion(completion, result);
  }
}

/**
 * Deliver a native `dealloc` for the instance registered under `id` (ADR-0059 §4), on thread 0. Runs
 * the JS `dealloc` override if the target defines one — contained (a throw is reported via
 * `onCallbackError`, never crosses the C ABI) — then **drops the registry keep-alive**
 * (`__releaseCallback`) so the JS side is no longer pinned: this is the k37/k38 loop close (a bound
 * subclass/delegate whose strong `callbacks` entry was, until now, never released). Returns whether a
 * JS override ran: `true` means the override is obligated to have chained `this.$super.dealloc()`
 * itself (as ObjC requires `[super dealloc]`; forgetting it leaks, as in ObjC) — so the native IMP
 * must NOT chain super; `false` means the native IMP chains `[super dealloc]` itself. The selector is
 * `dealloc` (the injective `:`→`_` map is identity — no colon), so the override is the `dealloc`
 * method. Contract-bound never to throw. The dealloc-triggering `release` runs before the ADR-0057 §6
 * `disposed` flip, so the override sees a **live** handle (that ordering lives in `lifetime.ts`).
 */
export function __deliverDealloc(id: CallbackId): boolean {
  const target = callbacks.get(id)?.target;
  let hadOverride = false;
  if (target !== undefined) {
    const fn = (target as Record<string, unknown>).dealloc;
    if (typeof fn === 'function') {
      hadOverride = true;
      try {
        (fn as CallbackFn).call(target);
      } catch (error) {
        reportCallbackError(error, { id, selector: 'dealloc' });
      }
    }
  }
  __releaseCallback(id);
  return hadOverride;
}

// ── Inbound install: hand the runtime's delivery entries to the native side (once, thread 0) ───────
// Every inbound surface (subclass, delegate, block) needs the native side to hold `napi_ref`s to the
// runtime's delivery entries before any trampoline / dealloc IMP can fire (the env-less-IMP crux,
// ADR-0059 §4/§5). Install both once — idempotent natively, and gated here by a module flag so the
// three surfaces share one install. Thread-0 only.

let inboundInstalled = false;

/** Install the inbound delivery bridge (`__invokeCallback` + `__deliverDealloc` + the off-main
 *  value-returning deliverer + the escaping-block registry-release deliverer) once. Thread-0 only. */
export function __ensureInbound(): void {
  if (inboundInstalled) return;
  __dispatch.installCallbackInvoker(__invokeCallback);
  __dispatch.installDeallocDeliverer(__deliverDealloc);
  __dispatch.installValueReturningDeliverer(__deliverValueReturning);
  // The escaping-block off-main teardown (ADR-0059 §2): the native holder's dispose routes the
  // registry-drop to thread 0 via the singleton bounce's release path, which calls this on thread 0.
  __dispatch.installBlockReleaseDeliverer(__releaseCallback);
  inboundInstalled = true;
}
