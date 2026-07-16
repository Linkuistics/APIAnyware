// bounce.swift — the background→main callback bounce (ADR-0056 §3) + `postCallbackCompletion`
// (tsfn-bounce-k43). The off-main delivery half every non-thread-0 inbound path routes through.
//
// A callback arriving on any NON-main thread (a GCD worker, a framework completion thread, a libuv
// threadpool thread) must NEVER re-enter JS off-main: JS runs on the loop thread, which is AppKit's
// thread 0. It bounces there via a singleton **`napi_threadsafe_function`** (tsfn) created once on
// thread 0. Two modes (ADR-0056 §3):
//
//   • void            — a blocking-mode tsfn call (backpressure, no silent drop); the bg thread does
//                       NOT wait. Thread 0 runs `__invokeCallback` and ignores the return.
//   • value-returning — a blocking-mode tsfn call PLUS a completion semaphore the JS side posts (the
//                       `dispatch_sync`-to-main analogue): the bg thread blocks until thread 0 has
//                       produced the return. Thread 0 runs the runtime's `__deliverValueReturning`,
//                       which ALWAYS posts back through `postCallbackCompletion` (ADR-0059 §7).
//   • dealloc         — a SYNCHRONOUS bounce (a completion semaphore, like value-returning): the
//                       DEALLOCATING thread blocks until thread 0 has run the runtime's `__deliverDealloc`
//                       (the JS `dealloc` override + the registry release), returning `hadOverride`. NEVER
//                       async — an async dealloc lets ObjC `-dealloc` free the object BEFORE the override
//                       runs → UAF of the JS back-ref (ADR-0059 §4). The off-main dual of inbound.swift's
//                       on-thread-0 `deliverDealloc`; thread-0 delivery delegates to that same function.
//
// The deadlock caveat (ADR-0056 §3): a value-returning bounce while thread 0 is *synchronously
// blocked* deadlocks (thread 0 cannot run the tsfn callback) — the `dispatch_sync` analogue. Void
// bounces are immune (the bg thread never waits). No `await` in a sync value-returning callback
// (finding C; the runtime reports+defaults an async-in-value-slot return).
//
// Off-main we CANNOT touch napi at all (napi_value creation needs the thread-0 env): the bg thread
// carries the call as raw C values (id handles / scalars) in a heap `BounceCall`, and the tsfn's
// call_js marshals them to napi values ON thread 0. Ownership: the `BounceCall` is `passRetained`
// into the tsfn `data` and reclaimed (`takeRetainedValue`) by call_js; the `BounceCompletion` stays
// owned by the blocked bg thread (a strong local), so call_js/`postCallbackCompletion` reach it
// unretained while it is guaranteed alive.

import AppKit  // NSDirectionalEdgeInsets — the rest of the POD geometry family (ADR-0042), matching napi_support.swift's own import
import Foundation

// ── Captured value-returning deliverer (installValueReturningDeliverer; thread 0) ───────────
/// The `napi_ref` to the runtime's `__deliverValueReturning` — the value-returning tsfn path's
/// thread-0 entry (the void path uses `gInvokeRef` from inbound.swift). Captured at install time.
private var gDeliverValueReturningRef: napi_ref?

/// The `napi_ref` to the runtime's `__releaseCallback` — the escaping-block off-main teardown seam
/// (ADR-0059 §2 / ADR-0057 release-on-thread-0). When the framework tears down a stored escaping block,
/// its native holder's `deinit` (on any thread) routes the registry-drop here, run on thread 0 by the
/// release path of `bounceCallJs`. Captured at install time (`installBlockReleaseDeliverer`).
private var gReleaseCallbackRef: napi_ref?

/// The singleton bounce tsfn (created on thread 0 at install; services every off-main bounce). One
/// per process — one embedded Node, one thread 0. `nil` until installed, so a bounce before install
/// is a safe no-op (returns the typed default; nothing hangs).
private var gBounceTsfn: napi_threadsafe_function?

// ── The bounce wire model (raw C values — no napi off thread 0) ─────────────────────────────

/// The ABI return shape of a value-returning bounce — enough for `postCallbackCompletion` to read
/// `result.value` with the right napi accessor, and for the bg thread to reinterpret the slot
/// (`uint64` travels as-is, `double` as its IEEE-754 bit pattern in the `UInt64` slot).
/// Module-internal: the reusable bounce API (`awBounceValue`) the inbound trampolines route through.
enum BounceReturnKind { case void, int64, handle, bool, uint64, double }

/// One pre-marshalled C-ABI argument the bg thread carries; the tsfn call_js re-marshals to napi on
/// thread 0. `handle` covers every ObjC id / pointer-width value (crosses as `bigint`, like the
/// outbound side); `int64`/`uint64` the integer scalars; `double` both float widths (JS numbers are
/// doubles); `bool` the ObjC BOOL (crosses as a JS boolean); the nine geometry cases carry a real
/// by-value POD struct (`inbound-struct-arg-surface-k123`, ADR-0055 §5a — param-only; nothing
/// constructs these for a return) — the real Swift geometry type, not a decomposed scalar tuple,
/// so `napiFromBounceArgs` marshals it through the SAME `napiMake<Stem>` helper the outbound
/// tables already use (`napi_support.swift`), one struct ⇄ JS-object convention either direction.
/// Module-internal: part of the reusable bounce API the inbound trampolines route through.
enum BounceArg {
    case handle(UInt)
    case int64(Int64)
    case uint64(UInt64)
    case double(Double)
    case bool(Bool)
    case rect(CGRect)
    case point(CGPoint)
    case size(CGSize)
    case range(NSRange)
    case edgeInsets(NSEdgeInsets)
    case directionalEdgeInsets(NSDirectionalEdgeInsets)
    case affineTransformStruct(NSAffineTransformStruct)
    case affineTransform(CGAffineTransform)
    case vector(CGVector)
}

/// The completion round-trip handle for a value-returning bounce: the semaphore the bg thread blocks
/// on, the ABI return kind, and the slot `postCallbackCompletion` writes the marshalled return into.
/// `deliveredOnMain` records that the post ran on thread 0 (evidence the bounce delivered on main).
private final class BounceCompletion {
    let sem = DispatchSemaphore(value: 0)
    let kind: BounceReturnKind
    var slot: UInt64 = 0
    var deliveredOnMain = false
    var posted = false  // thread-0-only guard: post exactly once (deliver path OR the call_js fallback)
    init(_ kind: BounceReturnKind) { self.kind = kind }
}

/// One inbound call in flight across the bg→thread-0 bounce. `completion == nil` is a void bounce.
/// `release == true` is not a call at all but an escaping-block **registry teardown** (ADR-0059 §2): drop
/// the JS-side keep-alive for `callbackId` on thread 0 (no args, no completion) — reusing the singleton
/// tsfn's any-thread enqueue as the release-on-thread-0 seam an off-main block dispose needs. `dealloc ==
/// true` (with a `completion`) is the off-main synchronous **dealloc** bounce (ADR-0059 §4): run the JS
/// `dealloc` override + the registry release on thread 0 via `deliverDealloc`, returning `hadOverride`
/// through the completion slot (no args, no `InboundCall` — dealloc is not an ordinary callback).
private final class BounceCall {
    let callbackId: UInt
    let selectorName: String?
    let args: [BounceArg]
    let completion: BounceCompletion?
    let release: Bool
    let dealloc: Bool
    init(
        _ callbackId: UInt, _ selectorName: String?, _ args: [BounceArg],
        _ completion: BounceCompletion?, release: Bool = false, dealloc: Bool = false
    ) {
        self.callbackId = callbackId
        self.selectorName = selectorName
        self.args = args
        self.completion = completion
        self.release = release
        self.dealloc = dealloc
    }
}

/// Marshal the raw, napi-free `[BounceArg]` a bg thread carried into `[napi_value?]` on thread 0 — shared
/// by `bounceCallJs` and inbound.swift's on-thread-0 escaping-block delivery, so both build identical args.
/// Must run on thread 0 (napi_value creation needs the thread-0 env).
func napiFromBounceArgs(_ env: napi_env?, _ args: [BounceArg]) -> [napi_value?] {
    return args.map { arg in
        switch arg {
        case .handle(let h): return napiMakeHandle(env, h)
        case .int64(let v): return napiMakeInt64(env, v)
        case .uint64(let v): return napiMakeUInt64(env, v)
        case .double(let v): return napiMakeDouble(env, v)
        case .bool(let v): return napiMakeBool(env, v)
        case .rect(let v): return napiMakeRect(env, v)
        case .point(let v): return napiMakePoint(env, v)
        case .size(let v): return napiMakeSize(env, v)
        case .range(let v): return napiMakeRange(env, v)
        case .edgeInsets(let v): return napiMakeEdgeInsets(env, v)
        case .directionalEdgeInsets(let v): return napiMakeDirectionalEdgeInsets(env, v)
        case .affineTransformStruct(let v): return napiMakeAffineTransformStruct(env, v)
        case .affineTransform(let v): return napiMakeAffineTransform(env, v)
        case .vector(let v): return napiMakeVector(env, v)
        }
    }
}

// ── The thread-0 tsfn callback: marshal, then invoke the runtime on thread 0 ─────────────────

/// The tsfn call_js — invoked by libuv on the loop thread (thread 0) during a pump `uv_run` pass, one
/// per enqueued bounce. Reclaims the `BounceCall`, marshals its raw args to napi values, and delivers:
/// a void bounce through `__invokeCallback` (result ignored); a value-returning bounce through
/// `__deliverValueReturning(completion, call)`, which ALWAYS posts via `postCallbackCompletion`. Every
/// early-out still posts a waiting completion (the bg thread must never hang) — including the `env ==
/// nil` teardown call N-API makes when the tsfn is destroyed with items still queued.
private let bounceCallJs:
    @convention(c) (napi_env?, napi_value?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void = {
    env, _, _, data in
    guard let data else { return }
    let call = Unmanaged<BounceCall>.fromOpaque(data).takeRetainedValue()  // reclaim the passRetained +1

    // Teardown (env == nil) or a scope failure: never leave the bg thread blocked — post the default.
    func postDefault() {
        if let c = call.completion, !c.posted { c.posted = true; c.sem.signal() }
    }
    guard let env else { postDefault(); return }
    var scope: napi_handle_scope?
    guard napi_open_handle_scope(env, &scope) == napi_ok else { postDefault(); return }
    defer { napi_close_handle_scope(env, scope) }

    // Escaping-block teardown (ADR-0059 §2): drop the registry keep-alive on thread 0. No args, no
    // completion — return before building an InboundCall. Contained if the release ref is missing.
    if call.release {
        if let ref = gReleaseCallbackRef, let releaseFn = napiRefValue(env, ref) {
            _ = napiCallFunction(env, releaseFn, [napiMakeHandle(env, call.callbackId)])
        }
        return
    }

    // Off-main synchronous dealloc (ADR-0059 §4): the deallocating thread is blocked in `awBounceDealloc`
    // waiting for thread 0 to run the JS `dealloc` override + drop the registry keep-alive. Delegate to
    // inbound.swift's `deliverDealloc` (which owns `gDeallocRef` / `__deliverDealloc` — the same thread-0
    // delivery the on-thread-0 IMP runs directly), write `hadOverride` into the completion slot, and post
    // the semaphore exactly once. Not an ordinary callback — no InboundCall, no args. Always-post: a fault
    // leaves the slot at the default `0` = `hadOverride` false, so the IMP chains `[super dealloc]` itself
    // (never a leak, never a hung deallocating thread).
    if call.dealloc {
        if let completion = call.completion {
            completion.slot = deliverDealloc(call.callbackId) ? 1 : 0
            if !completion.posted {
                completion.posted = true
                completion.sem.signal()
            }
        }
        return
    }

    let argValues = napiFromBounceArgs(env, call.args)
    let callObj = napiBuildInboundCall(env, call.callbackId, call.selectorName, argValues)

    if let completion = call.completion {
        // Value-returning: route through the runtime's always-post `__deliverValueReturning`, which
        // calls back into `postCallbackCompletion` (below) to marshal the return + post the semaphore.
        guard let ref = gDeliverValueReturningRef, let deliver = napiRefValue(env, ref) else {
            postDefault(); return
        }
        let completionHandle = UInt(bitPattern: Unmanaged.passUnretained(completion).toOpaque())
        _ = napiCallFunction(env, deliver, [napiMakeHandle(env, completionHandle), callObj])
        // Normal path: `__deliverValueReturning` already posted in its `finally`. Fallback (a hard napi
        // fault before it ran, so `posted` is still false) posts the default so the bg thread unblocks.
        postDefault()
    } else {
        // Void: fire-and-forget; a JS throw is already contained + reported inside `__invokeCallback`.
        if let ref = gInvokeRef, let invoke = napiRefValue(env, ref) {
            _ = napiCallFunction(env, invoke, [callObj])
        }
    }
}

// ── The bg-thread bounce entry points (callable from any non-main thread) ────────────────────

/// Bounce a **void** callback to thread 0 (blocking-mode enqueue — backpressure, never a silent drop)
/// and return immediately; the bg thread does not wait for a return (ADR-0056 §3). No-op if the tsfn
/// is not yet installed.
func awBounceVoid(_ callbackId: UInt, _ selectorName: String?, _ args: [BounceArg]) {
    guard let tsfn = gBounceTsfn else { return }
    let call = BounceCall(callbackId, selectorName, args, nil)
    let data = Unmanaged.passRetained(call).toOpaque()
    if napi_call_threadsafe_function(tsfn, data, napi_tsfn_blocking) != napi_ok {
        Unmanaged<BounceCall>.fromOpaque(data).release()  // tsfn closing — reclaim; nothing waits
    }
}

/// Bounce a **registry release** to thread 0 (ADR-0059 §2 escaping-block teardown): drop the JS-side
/// keep-alive for `callbackId` on thread 0 — the ADR-0057 release-on-thread-0 seam. Callable from **any**
/// thread: an escaping block's holder `deinit` fires on whatever thread the framework does the last
/// `_Block_release`, and `napi_call_threadsafe_function` is thread-safe. Fire-and-forget (no completion).
/// No-op if the tsfn is not yet installed / is closing (the registry is going away regardless).
func awBounceReleaseCallback(_ callbackId: UInt) {
    guard let tsfn = gBounceTsfn else { return }
    let call = BounceCall(callbackId, nil, [], nil, release: true)
    let data = Unmanaged.passRetained(call).toOpaque()
    if napi_call_threadsafe_function(tsfn, data, napi_tsfn_blocking) != napi_ok {
        Unmanaged<BounceCall>.fromOpaque(data).release()  // tsfn closing — reclaim; nothing waits
    }
}

/// Bounce a **value-returning** callback to thread 0 and BLOCK until thread 0 has produced the return
/// (the `dispatch_sync`-to-main analogue, ADR-0056 §3). Returns the marshalled C-ABI return in the
/// completion slot (reinterpreted per `kind` by the caller) and whether it was delivered on thread 0.
/// On a threw/stale-id/fault path the runtime's always-post discipline still unblocks us with the
/// typed default `0`. MUST run off thread 0 (calling it while thread 0 is synchronously blocked
/// deadlocks — the documented caveat).
func awBounceValue(
    _ callbackId: UInt, _ selectorName: String?, _ args: [BounceArg], _ kind: BounceReturnKind
) -> (slot: UInt64, deliveredOnMain: Bool) {
    guard let tsfn = gBounceTsfn else { return (0, false) }
    let completion = BounceCompletion(kind)
    let call = BounceCall(callbackId, selectorName, args, completion)
    let data = Unmanaged.passRetained(call).toOpaque()
    if napi_call_threadsafe_function(tsfn, data, napi_tsfn_blocking) != napi_ok {
        Unmanaged<BounceCall>.fromOpaque(data).release()
        return (0, false)  // never enqueued → nothing will post; return the typed default
    }
    completion.sem.wait()  // block until thread 0's call_js / postCallbackCompletion posts
    return (completion.slot, completion.deliveredOnMain)
}

/// Bounce a **dealloc** to thread 0 and BLOCK until thread 0 has run the JS `dealloc` override + dropped
/// the registry keep-alive (`__deliverDealloc`), returning `hadOverride` (ADR-0059 §4). The off-main dual
/// of the on-thread-0 `deliverDealloc`: when the framework drops an instance's LAST ref off thread 0 (a
/// superview released on a bg/GCD queue), its JS override must still run on thread 0 **before** ObjC
/// `-dealloc` frees the object — so this is a **synchronous** bounce (never async: an async dealloc would
/// free the object before the override runs → UAF of the JS back-ref). On any fault (tsfn not installed /
/// closing, missing deliverer, napi fault) the always-post discipline unblocks the deallocating thread
/// with `false` → the IMP chains `[super dealloc]` itself (no ObjC-storage leak, no hung thread). A fault
/// means the runtime is uninstalled or tearing down, so the JS registry drop (`__deliverDealloc`'s
/// `__releaseCallback`) is skipped — but the registry is going away regardless (matching the other
/// `awBounce*` fault paths). MUST run off thread 0 (a synchronous dealloc bounce while thread 0 is
/// synchronously blocked deadlocks — ADR-0056 §3 / §5; broader than the value path — the ADR-0059 §4 note).
func awBounceDealloc(_ callbackId: UInt) -> Bool {
    guard let tsfn = gBounceTsfn else { return false }  // not installed → chain [super dealloc] ourselves
    let completion = BounceCompletion(.bool)
    let call = BounceCall(callbackId, nil, [], completion, dealloc: true)
    let data = Unmanaged.passRetained(call).toOpaque()
    if napi_call_threadsafe_function(tsfn, data, napi_tsfn_blocking) != napi_ok {
        Unmanaged<BounceCall>.fromOpaque(data).release()
        return false  // never enqueued → nothing will post; chain [super dealloc] ourselves
    }
    completion.sem.wait()  // block the deallocating thread until thread 0 ran __deliverDealloc
    return completion.slot != 0
}

// ── The N-API entries (registered by awRegisterBounce) ───────────────────────────────────────

/// `installValueReturningDeliverer(fn)` — capture the thread-0 `napi_env` and a strong `napi_ref` to
/// the runtime's `__deliverValueReturning`, and create the singleton bounce tsfn (thread 0). Called by
/// `__ensureInbound` alongside `installCallbackInvoker`. Idempotent (a prior ref/tsfn is kept/replaced).
private func aw_installValueReturningDeliverer(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 1)
    gEnv = env
    if let old = gDeliverValueReturningRef {
        _ = napi_delete_reference(env, old)
        gDeliverValueReturningRef = nil
    }
    var ref: napi_ref?
    _ = napi_create_reference(env, a[0], 1, &ref)
    gDeliverValueReturningRef = ref
    ensureBounceTsfn(env)
    return napiUndefined(env)
}

/// `installBlockReleaseDeliverer(fn)` — capture the thread-0 `napi_env` and a strong `napi_ref` to the
/// runtime's `__releaseCallback`, so an escaping block's off-main teardown can drop the registry keep-alive
/// on thread 0 (ADR-0059 §2 / ADR-0057). Called by `__ensureInbound` alongside the other install entries.
/// Idempotent (a prior ref is replaced). Does not itself create the tsfn (the value-returning installer does).
private func aw_installBlockReleaseDeliverer(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 1)
    gEnv = env
    if let old = gReleaseCallbackRef {
        _ = napi_delete_reference(env, old)
        gReleaseCallbackRef = nil
    }
    var ref: napi_ref?
    _ = napi_create_reference(env, a[0], 1, &ref)
    gReleaseCallbackRef = ref
    return napiUndefined(env)
}

/// Create the singleton bounce tsfn on thread 0 (once). `func == nil` — call_js drives delivery; the
/// per-signature return type lives in the `BounceCompletion`, not a JS function. `max_queue_size 0` =
/// unlimited, so blocking-mode enqueue never drops and never blocks on backpressure. Base thread count
/// 1 is permanent (any bg thread may call without `napi_acquire`, since the count never reaches 0). It
/// is `unref`'d so it does not itself keep the loop alive — the pump owns liveness — and so a plain
/// `node test/*.mjs` (which uses `uv_run(DEFAULT)`) still exits after installing inbound delivery.
private func ensureBounceTsfn(_ env: napi_env?) {
    guard gBounceTsfn == nil, let env else { return }
    let name = napiMakeString(env, "aw_bounce_tsfn")
    var tsfn: napi_threadsafe_function?
    let status = napi_create_threadsafe_function(
        env, nil, nil, name, 0, 1, nil, nil, nil, bounceCallJs, &tsfn)
    guard status == napi_ok, let created = tsfn else { return }
    _ = napi_unref_threadsafe_function(env, created)
    gBounceTsfn = created
}

/// `postCallbackCompletion(completion, result)` (ADR-0056 §3 / ADR-0059 §5) — the native counterpart
/// of the runtime's `__deliverValueReturning`. Runs on thread 0. Read the `InboundResult`
/// (`{threw:false, value} | {threw:true}`): on a clean return marshal `value` into the completion slot
/// per its ABI kind; on `threw` leave the slot at the typed default `0` (the native side alone knows
/// the return type). Then record thread-0 delivery and post the semaphore the blocked bg thread waits
/// on — exactly once (the `posted` guard coordinates with the call_js fallback; both are on thread 0).
private func aw_postCallbackCompletion(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 2)
    guard let ptr = UnsafeRawPointer(bitPattern: napiReadHandle(env, a[0])) else {
        return napiUndefined(env)
    }
    let completion = Unmanaged<BounceCompletion>.fromOpaque(ptr).takeUnretainedValue()
    if !napiGetBool(env, napiGetNamed(env, a[1], "threw")) {
        let value = napiGetNamed(env, a[1], "value")
        switch completion.kind {
        case .void: break
        case .int64: completion.slot = UInt64(bitPattern: napiReadInt64(env, value))
        case .handle: completion.slot = UInt64(napiReadHandle(env, value))
        case .bool: completion.slot = napiGetBool(env, value) ? 1 : 0
        case .uint64: completion.slot = napiReadUInt64(env, value)
        case .double: completion.slot = napiReadDouble(env, value).bitPattern
        }
    }
    completion.deliveredOnMain = pthread_main_np() != 0
    if !completion.posted {
        completion.posted = true
        completion.sem.signal()
    }
    return napiUndefined(env)
}

/// `isMainThread() -> boolean` — true iff called on the process main thread (AppKit's thread 0). A
/// general diagnostic the harness uses to prove a bounced callback reached JS on thread 0, not off-main.
private func aw_isMainThread(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    return napiMakeBool(env, pthread_main_np() != 0)
}

// ── First-hand exercise (test-only): drive the bounce from a real GCD bg thread ──────────────
// Not a production entry — the real off-main trampolines (which detect off-main and bounce) are grown
// in `inbound-trampolines-k36` item 4. This proves the mechanism first-hand under the k42 embedder
// harness: originate on a genuine bg thread, value-round-trip a JS return through the semaphore, hold
// the always-post discipline on a JS throw, and deliver both modes on thread 0.

private struct BounceProbe {
    var originOffMain = false      // the bg thread confirmed it was NOT the main thread
    var valueReturned: Int64 = 0   // the value the JS callback returned, read back on the bg thread
    var valueDeliveredOnMain = false  // the value bounce's post ran on thread 0
    var throwReturned: Int64 = -1  // the throwing callback's return — must be the typed default 0
    var throwUnblocked = false     // the bg thread got past the throwing value bounce (never hung)
}
private var gProbe = BounceProbe()

/// `aw_test_bounce(valueId, throwId, notifyId)` — run the whole bounce sequence off a real GCD bg
/// thread and report via a final void bounce. Returns immediately (thread 0 stays free to PUMP — the
/// no-sync-block-on-thread-0 discipline the value-returning path needs). The bg thread: (1) a
/// value-returning bounce to `valueId(41)` → expects 42 back through the semaphore; (2) a
/// value-returning bounce to `throwId` whose JS throws → the always-post discipline unblocks it with
/// the typed default 0; (3) a void bounce to `notifyId` (delivered on thread 0) so JS reads the probe.
private func aw_test_bounce(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let a = napiCallbackArgs(env, info, 3)
    let valueId = napiReadHandle(env, a[0])
    let throwId = napiReadHandle(env, a[1])
    let notifyId = napiReadHandle(env, a[2])
    gProbe = BounceProbe()
    DispatchQueue.global().async {
        gProbe.originOffMain = pthread_main_np() == 0
        let v = awBounceValue(valueId, nil, [.int64(41)], .int64)
        gProbe.valueReturned = Int64(bitPattern: v.slot)
        gProbe.valueDeliveredOnMain = v.deliveredOnMain
        let t = awBounceValue(throwId, nil, [.int64(0)], .int64)
        gProbe.throwReturned = Int64(bitPattern: t.slot)
        gProbe.throwUnblocked = true
        awBounceVoid(notifyId, nil, [])
    }
    return napiUndefined(env)
}

/// `aw_test_bounce_result() -> { originOffMain, valueReturned, valueDeliveredOnMain, throwReturned,
/// throwUnblocked }` — read the probe the bg bounce sequence filled in (called by the notify callback).
private func aw_test_bounce_result(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let obj = napiNewObject(env)
    napiSetNamed(env, obj, "originOffMain", napiMakeBool(env, gProbe.originOffMain))
    napiSetNamed(env, obj, "valueReturned", napiMakeInt64(env, gProbe.valueReturned))
    napiSetNamed(env, obj, "valueDeliveredOnMain", napiMakeBool(env, gProbe.valueDeliveredOnMain))
    napiSetNamed(env, obj, "throwReturned", napiMakeInt64(env, gProbe.throwReturned))
    napiSetNamed(env, obj, "throwUnblocked", napiMakeBool(env, gProbe.throwUnblocked))
    return obj
}

/// Register the bounce N-API entries on the module `exports` (called from `napi_register_module_v1`).
/// The two seam entries (`postCallbackCompletion`, `installValueReturningDeliverer`) plus the
/// `isMainThread` diagnostic and the two test-only drivers.
func awRegisterBounce(_ env: napi_env?, _ exports: napi_value?) {
    napiDefine(env, exports, "postCallbackCompletion", aw_postCallbackCompletion)
    napiDefine(env, exports, "installValueReturningDeliverer", aw_installValueReturningDeliverer)
    napiDefine(env, exports, "installBlockReleaseDeliverer", aw_installBlockReleaseDeliverer)
    napiDefine(env, exports, "isMainThread", aw_isMainThread)
    napiDefine(env, exports, "aw_test_bounce", aw_test_bounce)
    napiDefine(env, exports, "aw_test_bounce_result", aw_test_bounce_result)
}
