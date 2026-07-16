// pump.swift — the libuv pump (ADR-0056 mechanism (c), the Electron helper-thread shape).
//
// Services Node's libuv loop as a guest on AppKit's thread 0: a dedicated helper thread blocks on
// `poll(uv_backend_fd, uv_backend_timeout)`; on wake it signals a `kCFRunLoopCommonModes` runloop
// source on the main thread and waits on a semaphore; the source runs ONE `uv_run(NOWAIT)` pass
// (via the V8-scoped `aw_rl_pump_v8`, pump_shim.cc — finding A) and posts the semaphore. Strict
// lock-step (one poll ↔ one uv_run) means the two threads never touch the loop concurrently, and the
// stale-`uv_backend_timeout` hazard self-corrects (the helper re-reads the timeout every pass).
//
// Reusable native core (ADR-0060 §1): the shipped `bundle-typescript` launcher starts the same pump.
// The mechanism is k6-decided (`libuv-runloop-primacy-spike-k6`); do NOT re-open the fork — (b)
// CFFileDescriptor is a documented future optimisation only. Ported from that spike's `Bridge.swift`
// (helper leg), now Swift-native + embedder-owned (the loop pointer comes from the C++ embedder's
// `CommonEnvironmentSetup::event_loop()`, not `napi_get_uv_event_loop`). CoreFoundation only — no
// AppKit dependency here; the harness/launcher owns the app lifecycle.

import Foundation

// ── libuv embedding API, resolved from the loaded/linked libnode via RTLD_DEFAULT ──────────────────
private let RTLD_DEFAULT_PTR = UnsafeMutableRawPointer(bitPattern: -2)

private func uvsym(_ name: String) -> UnsafeMutableRawPointer {
    guard let p = dlsym(RTLD_DEFAULT_PTR, name) else {
        FileHandle.standardError.write("[pump] FATAL: libuv symbol \(name) absent\n".data(using: .utf8)!)
        fatalError("missing libuv symbol \(name)")
    }
    return p
}

private typealias UvBackendFdFn      = @convention(c) (UnsafeMutableRawPointer) -> Int32
private typealias UvBackendTimeoutFn = @convention(c) (UnsafeMutableRawPointer) -> Int32
private typealias UvAsyncInitFn      = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer, UnsafeMutableRawPointer?) -> Int32
private typealias UvAsyncSendFn      = @convention(c) (UnsafeMutableRawPointer) -> Int32
private typealias UvRunFn            = @convention(c) (UnsafeMutableRawPointer, Int32) -> Int32
private typealias UvCloseFn          = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer?) -> Void

private let uv_backend_fd      = unsafeBitCast(uvsym("uv_backend_fd"),      to: UvBackendFdFn.self)
private let uv_backend_timeout = unsafeBitCast(uvsym("uv_backend_timeout"), to: UvBackendTimeoutFn.self)
private let uv_async_init      = unsafeBitCast(uvsym("uv_async_init"),      to: UvAsyncInitFn.self)
private let uv_async_send      = unsafeBitCast(uvsym("uv_async_send"),      to: UvAsyncSendFn.self)
private let uv_run             = unsafeBitCast(uvsym("uv_run"),             to: UvRunFn.self)
private let uv_close           = unsafeBitCast(uvsym("uv_close"),           to: UvCloseFn.self)
private let UV_RUN_NOWAIT: Int32 = 2

// ── Pump state (single instance — one embedded Node per process) ────────────────────────────────────
private final class PumpState {
    var loop: UnsafeMutableRawPointer!
    var pumpV8: (@convention(c) (UnsafeMutableRawPointer) -> Void)?  // aw_rl_pump_v8 (pump_shim.cc)

    var embedClosed = false
    var helper: pthread_t?
    var source: CFRunLoopSource?
    let sem = DispatchSemaphore(value: 0)
    var asyncHandle: UnsafeMutableRawPointer?  // uv_async_t* (over-allocated), teardown/stale-timeout wake

    // counters (read via aw_rl_pump_stats)
    var uvRunPasses: Int64 = 0
    var helperPolls: Int64 = 0
    var sourceFires: Int64 = 0
    var lastTimeout: Int64 = 0
    var nestedStart: Int64 = 0
    var nestedEnd: Int64 = 0
}
private let S = PumpState()

private var mainRL: CFRunLoop { CFRunLoopGetMain() }

// The single uv_run(NOWAIT) pass, always on the main/loop thread, through the V8-scoped shim.
private func pumpOnce() {
    S.uvRunPasses += 1
    if let loop = S.loop, let pump = S.pumpV8 { pump(loop) }
}

// The main-runloop source: exactly one uv_run per helper signal, then release the helper (lock-step).
private let sourcePerform: @convention(c) (UnsafeMutableRawPointer?) -> Void = { _ in
    S.sourceFires += 1
    pumpOnce()
    S.sem.signal()
}

// The helper thread: block on the backend fd, wake the main runloop, wait for its single uv_run pass.
private let helperMain: @convention(c) (UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? = { _ in
    while !S.embedClosed {
        let fd = uv_backend_fd(S.loop)
        let timeout = uv_backend_timeout(S.loop)   // re-read every pass (libuv contract; stale-timeout fix)
        S.lastTimeout = Int64(timeout)
        var pfd = pollfd(fd: fd, events: Int16(POLLIN), revents: 0)
        _ = poll(&pfd, 1, timeout)
        if S.embedClosed { break }
        S.helperPolls += 1
        if let src = S.source {
            CFRunLoopSourceSignal(src)
            CFRunLoopWakeUp(mainRL)
            S.sem.wait()   // block until the main thread has run its single uv_run pass
        }
    }
    return nil
}

private func initAsync() {
    // uv_async_t is < 512 bytes on 64-bit; over-allocate + zero to be safe.
    let buf = UnsafeMutableRawPointer.allocate(byteCount: 512, alignment: 16)
    buf.initializeMemory(as: UInt8.self, repeating: 0, count: 512)
    let noop: @convention(c) (UnsafeMutableRawPointer?) -> Void = { _ in }
    _ = uv_async_init(S.loop, buf, unsafeBitCast(noop, to: UnsafeMutableRawPointer.self))
    S.asyncHandle = buf
}

// ── @_cdecl surface (the harness / launcher calls these) ────────────────────────────────────────────

/// Start the mechanism-(c) pump on `loopPtr` (the embedder's `CommonEnvironmentSetup::event_loop()`),
/// driving each pass through `pumpV8` (aw_rl_pump_v8). Call once, on thread 0, before NSApp.run().
@_cdecl("aw_rl_pump_start")
public func aw_rl_pump_start(
    _ loopPtr: UInt,
    _ pumpV8: @convention(c) @escaping (UnsafeMutableRawPointer) -> Void
) {
    S.loop = UnsafeMutableRawPointer(bitPattern: loopPtr)
    S.pumpV8 = pumpV8
    S.embedClosed = false
    initAsync()
    var ctx = CFRunLoopSourceContext()
    ctx.perform = sourcePerform
    let src = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &ctx)!
    S.source = src
    CFRunLoopAddSource(mainRL, src, .commonModes)   // survives AppKit's nested modal/menu/resize runloops
    var tid = pthread_t(bitPattern: 0)
    pthread_create(&tid, nil, helperMain, nil)
    S.helper = tid
}

/// Nudge the loop (uv_async_send) — the teardown wake + the belt-and-suspenders stale-timeout poke.
@_cdecl("aw_rl_pump_nudge")
public func aw_rl_pump_nudge() {
    if let h = S.asyncHandle { _ = uv_async_send(h) }
}

/// Basic clean teardown: stop the helper without deadlock (double-wake-before-join), drain the
/// semaphore, invalidate the source, and close our own `uv_async` handle so the embedder's
/// `uv_loop_close` (CommonEnvironmentSetup's destructor) does not abort on an open handle. The
/// *hardened* full drain (uv_walk over all handles + `uv_run(UV_RUN_DEFAULT)` + `uv_loop_close`,
/// verified deadlock-free) is a later `libuv-pump-k41` sibling; this closes only what the pump owns,
/// which is enough for the harness to exit cleanly.
@_cdecl("aw_rl_pump_teardown")
public func aw_rl_pump_teardown() {
    S.embedClosed = true
    S.sem.signal()          // release a helper parked on the semaphore
    aw_rl_pump_nudge()      // break a helper parked in poll(timeout=-1)
    if let h = S.helper { pthread_join(h, nil) }
    while S.sem.wait(timeout: .now()) == .success {}   // drain leftover posts
    if let src = S.source { CFRunLoopSourceInvalidate(src); S.source = nil }
    // Close + reclaim our async handle. No concurrency remains (helper joined), so this bare uv_run
    // is safe (not the forbidden steady-state nested pump) — it is the ADR-0056 §4 teardown drain,
    // minimal form: run passes until the close callback has fired.
    if let h = S.asyncHandle, let loop = S.loop {
        uv_close(h, nil)
        for _ in 0..<8 { _ = uv_run(loop, UV_RUN_NOWAIT) }
        h.deallocate()
        S.asyncHandle = nil
    }
}

/// Record uvRunPasses at entry to a nested runloop window (the nested-runloop-survival measurement).
@_cdecl("aw_rl_pump_mark_nested_start")
public func aw_rl_pump_mark_nested_start() { S.nestedStart = S.uvRunPasses }

/// Record uvRunPasses at exit from a nested runloop window.
@_cdecl("aw_rl_pump_mark_nested_end")
public func aw_rl_pump_mark_nested_end() { S.nestedEnd = S.uvRunPasses }

/// Fill [uvRunPasses, helperPolls, sourceFires, lastTimeout, nestedStart, nestedEnd].
@_cdecl("aw_rl_pump_stats")
public func aw_rl_pump_stats(_ out: UnsafeMutablePointer<Int64>) {
    out[0] = S.uvRunPasses
    out[1] = S.helperPolls
    out[2] = S.sourceFires
    out[3] = S.lastTimeout
    out[4] = S.nestedStart
    out[5] = S.nestedEnd
}
