// Bridge.swift — THROWAWAY spike dylib for libuv-runloop-primacy-spike-k6.
//
// De-risks the two candidate libuv↔CFRunLoop integration mechanisms of ADR-0056 §2,
// head-to-head, under NSApplication.run() owning thread 0:
//
//   (c) helper thread  — a thread blocks on poll(uv_backend_fd, uv_backend_timeout);
//       on wake it CFRunLoopSourceSignal + CFRunLoopWakeUp the main runloop and waits
//       on a semaphore; the main-runloop source runs one uv_run(NOWAIT) then posts the
//       semaphore (lock-step). This is Electron's proven shape (the ADR baseline).
//
//   (b) CFFileDescriptor — register uv_backend_fd as a CFFileDescriptor runloop source
//       in kCFRunLoopCommonModes + a CFRunLoopTimer armed to uv_backend_timeout (re-armed
//       each turn by a kCFRunLoopBeforeWaiting observer); on wake, uv_run(NOWAIT) then
//       re-enable the one-shot CFFileDescriptor. The DECISIVE unknown: does CFFileDescriptor
//       actually fire on the kqueue backend fd on current macOS? (libuv warns kqueue-in-kqueue
//       "never generates events" on some platforms.)
//
// libuv is embedded in the host (Node) as libuv.1.dylib; its embedding symbols are resolved
// once via dlsym(RTLD_DEFAULT, ...) — the same trick the substrate spike used for objc_msgSend.
// The napi-rs addon owns napi_get_uv_event_loop + the threadsafe-function bounce and hands the
// uv_loop_t* here as a UInt.

import Foundation
import AppKit
import CoreGraphics
import Darwin

private func plog(_ s: String) {
    FileHandle.standardError.write(("[swift] " + s + "\n").data(using: .utf8)!)
}

// ============================================================================
// libuv embedding API, resolved from the loaded libuv.1.dylib via RTLD_DEFAULT.
// ============================================================================
private let RTLD_DEFAULT_PTR = UnsafeMutableRawPointer(bitPattern: -2)

private func sym(_ name: String) -> UnsafeMutableRawPointer {
    guard let p = dlsym(RTLD_DEFAULT_PTR, name) else {
        plog("FATAL: dlsym(\(name)) returned NULL — libuv embedding symbol absent")
        fatalError("missing libuv symbol \(name)")
    }
    return p
}

// Nullable resolver — for the Deno leg, where the symbols are expected ABSENT.
@_cdecl("aw_rl_has_symbol")
public func aw_rl_has_symbol(_ name: UnsafePointer<CChar>) -> Bool {
    return dlsym(RTLD_DEFAULT_PTR, String(cString: name)) != nil
}

private typealias UvRunFn            = @convention(c) (UnsafeMutableRawPointer, Int32) -> Int32
private typealias UvBackendFdFn      = @convention(c) (UnsafeMutableRawPointer) -> Int32
private typealias UvBackendTimeoutFn = @convention(c) (UnsafeMutableRawPointer) -> Int32
private typealias UvLoopAliveFn      = @convention(c) (UnsafeMutableRawPointer) -> Int32
private typealias UvAsyncInitFn      = @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer, UnsafeMutableRawPointer?) -> Int32
private typealias UvAsyncSendFn      = @convention(c) (UnsafeMutableRawPointer) -> Int32

private let uv_run             = unsafeBitCast(sym("uv_run"),             to: UvRunFn.self)
private let uv_backend_fd      = unsafeBitCast(sym("uv_backend_fd"),      to: UvBackendFdFn.self)
private let uv_backend_timeout = unsafeBitCast(sym("uv_backend_timeout"), to: UvBackendTimeoutFn.self)
private let uv_loop_alive      = unsafeBitCast(sym("uv_loop_alive"),      to: UvLoopAliveFn.self)
private let uv_async_init      = unsafeBitCast(sym("uv_async_init"),      to: UvAsyncInitFn.self)
private let uv_async_send      = unsafeBitCast(sym("uv_async_send"),      to: UvAsyncSendFn.self)

private let UV_RUN_NOWAIT: Int32 = 2

// ============================================================================
// Shared spike state (single instance — a spike, not a library).
// ============================================================================
private final class RLState {
    var loop: UnsafeMutableRawPointer!         // uv_loop_t*
    var mechanism: Int32 = 0                    // 1 = (c) helper, 2 = (b) cffd
    var commonModes = true                      // false = default-mode-only control

    // counters (read by tests via aw_rl_get_stats)
    var uvRunPasses: Int64 = 0
    var fdFires: Int64 = 0
    var timerFires: Int64 = 0
    var helperPolls: Int64 = 0
    var sourceFires: Int64 = 0
    var timeoutZeroPolls: Int64 = 0     // helper polls where uv_backend_timeout == 0 (busy-spin signal)
    var lastTimeout: Int64 = 0
    var nestedStart: Int64 = 0          // uvRunPasses at entry to a nested runloop (test #3)
    var nestedEnd: Int64 = 0            // uvRunPasses at exit from the nested runloop

    var embedClosed = false

    // (c) helper-thread machinery
    var helper: pthread_t?
    var source: CFRunLoopSource?
    let sem = DispatchSemaphore(value: 0)

    // (b) CFFileDescriptor machinery
    var cffd: CFFileDescriptor?
    var fdSource: CFRunLoopSource?
    var timer: CFRunLoopTimer?
    var observer: CFRunLoopObserver?

    // uv_async self-pipe (stale-timeout nudge + teardown wake) — ADR-0056 §2
    var asyncHandle: UnsafeMutableRawPointer?  // uv_async_t* (over-allocated)

    // background nudge pinger (drives the nested-runloop-survival measurement)
    var pinger: pthread_t?
    var pingerStop = false
    var pingerIntervalMs: Int32 = 50

    // The pump: a Rust callback that wraps uv_run(NOWAIT) in a napi handle+callback scope
    // (the napi equivalent of Electron's node::InternalCallbackScope in UvRunOnce). A bare
    // uv_run from a CFRunLoop callback crashes in node::Environment::CheckImmediate (no
    // v8::HandleScope) on the first setImmediate — so the pump MUST be scoped, in the addon.
    var pumpCb: (@convention(c) () -> Void)?
}
private let S = RLState()

private var mainRL: CFRunLoop { CFRunLoopGetMain() }
private func activeMode() -> CFRunLoopMode { S.commonModes ? .commonModes : .defaultMode }

// ---- the single uv_run pass, always on the main/loop thread ---------------
// Delegates to the Rust scoped pump (uv_run inside a napi handle+callback scope). Counting
// stays here so tests can read pass counts regardless of which mechanism drove the pass.
private func pumpOnce() {
    S.uvRunPasses += 1
    S.pumpCb?()
}

// ============================================================================
// App setup / run  (reused shape from the substrate spike)
// ============================================================================
private var _spikeWindow: NSWindow?

@_cdecl("aw_rl_setup_app")
public func aw_rl_setup_app() -> Bool {
    let onMain = Thread.isMainThread
    let app = NSApplication.shared
    app.setActivationPolicy(.regular)
    let win = NSWindow(
        contentRect: NSRect(x: 100, y: 100, width: 420, height: 260),
        styleMask: [.titled, .closable, .resizable],
        backing: .buffered, defer: false)
    win.title = "ts-runloop-spike"
    win.backgroundColor = .systemIndigo
    win.makeKeyAndOrderFront(nil)
    app.activate(ignoringOtherApps: true)
    _spikeWindow = win
    plog("setup_app: onMain=\(onMain) window visible=\(win.isVisible)")
    return onMain
}

@_cdecl("aw_rl_run_app")
public func aw_rl_run_app(_ seconds: Double) {
    plog("run_app: onMain=\(Thread.isMainThread), NSApplication.run(); autoquit in \(seconds)s")
    if seconds > 0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            NSApplication.shared.stop(nil)
            let ev = NSEvent.otherEvent(with: .applicationDefined, location: .zero,
                modifierFlags: [], timestamp: 0, windowNumber: 0, context: nil,
                subtype: 0, data1: 0, data2: 0)!
            NSApplication.shared.postEvent(ev, atStart: true)
        }
    }
    NSApplication.shared.run()
    plog("run_app: NSApplication.run() returned")
}

// ============================================================================
// Mechanism (c) — helper thread + lock-stepped main-runloop source
// ============================================================================
private let sourcePerform: @convention(c) (UnsafeMutableRawPointer?) -> Void = { _ in
    S.sourceFires += 1
    pumpOnce()          // exactly one uv_run(NOWAIT) per helper signal
    S.sem.signal()      // release the helper (lock-step: one poll ↔ one uv_run)
}

private let helperMain: @convention(c) (UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? = { _ in
    plog("helper: started (poll uv_backend_fd)")
    while !S.embedClosed {
        let fd = uv_backend_fd(S.loop)
        let timeout = uv_backend_timeout(S.loop)   // recomputed every iteration (libuv contract)
        S.lastTimeout = Int64(timeout)
        if timeout == 0 { S.timeoutZeroPolls += 1 }
        var pfd = pollfd(fd: fd, events: Int16(POLLIN), revents: 0)
        _ = poll(&pfd, 1, timeout)
        if S.embedClosed { break }
        S.helperPolls += 1
        if let src = S.source {
            CFRunLoopSourceSignal(src)
            CFRunLoopWakeUp(mainRL)
            S.sem.wait()   // wait until the main thread has run its single uv_run pass
        }
    }
    plog("helper: exiting")
    return nil
}

private func startHelperMechanism() {
    var ctx = CFRunLoopSourceContext()
    ctx.perform = sourcePerform
    let src = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &ctx)!
    S.source = src
    CFRunLoopAddSource(mainRL, src, activeMode())
    var tid = pthread_t(bitPattern: 0)
    pthread_create(&tid, nil, helperMain, nil)
    S.helper = tid
    plog("(c) helper mechanism started; source in \(S.commonModes ? "commonModes" : "defaultMode")")
}

// ============================================================================
// Mechanism (b) — CFFileDescriptor on uv_backend_fd + re-armed timer
// ============================================================================
private let fdCallback: CFFileDescriptorCallBack = { (cffd, _, _) in
    S.fdFires += 1
    pumpOnce()
    // CFFileDescriptor callbacks are one-shot — re-enable for the next event.
    if let cffd = cffd { CFFileDescriptorEnableCallBacks(cffd, kCFFileDescriptorReadCallBack) }
}

private let timerCallback: CFRunLoopTimerCallBack = { (_, _) in
    S.timerFires += 1
    pumpOnce()
}

// Re-arm the timer to uv_backend_timeout each time the runloop is about to sleep.
// This is what keeps timer work alive when the fd only signals I/O (the stale-timeout fix).
private let observerCallback: CFRunLoopObserverCallBack = { (_, _, _) in
    guard let timer = S.timer else { return }
    let t = uv_backend_timeout(S.loop)   // ms; -1 = infinite
    if t < 0 {
        CFRunLoopTimerSetNextFireDate(timer, .greatestFiniteMagnitude)   // effectively disarmed
    } else {
        CFRunLoopTimerSetNextFireDate(timer, CFAbsoluteTimeGetCurrent() + Double(t) / 1000.0)
    }
}

private func startCffdMechanism() {
    let fd = uv_backend_fd(S.loop)
    var ctx = CFFileDescriptorContext()
    let cffd = CFFileDescriptorCreate(kCFAllocatorDefault, fd, false /*don't close fd on invalidate*/,
                                      fdCallback, &ctx)!
    S.cffd = cffd
    CFFileDescriptorEnableCallBacks(cffd, kCFFileDescriptorReadCallBack)
    let fdSrc = CFFileDescriptorCreateRunLoopSource(kCFAllocatorDefault, cffd, 0)!
    S.fdSource = fdSrc
    CFRunLoopAddSource(mainRL, fdSrc, activeMode())

    let timer = CFRunLoopTimerCreate(kCFAllocatorDefault, .greatestFiniteMagnitude,
                                     0 /*one-shot; re-armed by observer*/, 0, 0, timerCallback, nil)!
    S.timer = timer
    CFRunLoopAddTimer(mainRL, timer, activeMode())

    let obs = CFRunLoopObserverCreate(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue,
                                      true, 0, observerCallback, nil)!
    S.observer = obs
    CFRunLoopAddObserver(mainRL, obs, activeMode())
    plog("(b) CFFileDescriptor mechanism started on kqueue fd=\(fd); source in \(S.commonModes ? "commonModes" : "defaultMode")")
}

// ============================================================================
// Mechanism (3) — the 4 ms polling-timer BASELINE (probe 2c's shape), for head-to-head
// ============================================================================
private let pollTimerCallback: CFRunLoopTimerCallBack = { (_, _) in pumpOnce() }

private func startPollBaselineMechanism() {
    let timer = CFRunLoopTimerCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + 0.004,
                                     0.004 /*repeating every 4ms*/, 0, 0, pollTimerCallback, nil)!
    S.timer = timer
    CFRunLoopAddTimer(mainRL, timer, activeMode())
    plog("(baseline) 4ms poll timer started; in \(S.commonModes ? "commonModes" : "defaultMode")")
}

// ============================================================================
// uv_async self-pipe (stale-timeout nudge + teardown wake) — allocated on the loop thread
// ============================================================================
private let asyncNoop: @convention(c) (UnsafeMutableRawPointer?) -> Void = { _ in /* wake only */ }

private func initAsync() {
    // uv_async_t is < 512 bytes on 64-bit; over-allocate + zero to be safe.
    let buf = UnsafeMutableRawPointer.allocate(byteCount: 512, alignment: 16)
    buf.initializeMemory(as: UInt8.self, repeating: 0, count: 512)
    let rc = uv_async_init(S.loop, buf, unsafeBitCast(asyncNoop, to: UnsafeMutableRawPointer.self))
    if rc != 0 { plog("uv_async_init failed rc=\(rc)") }
    S.asyncHandle = buf
}

@_cdecl("aw_rl_nudge")
public func aw_rl_nudge() {
    if let h = S.asyncHandle { _ = uv_async_send(h) }
}

// ============================================================================
// Start / teardown / nested-runloop / pinger / stats — the test control surface
// ============================================================================

// mechanism: 1 = (c) helper, 2 = (b) cffd, 3 = 4ms poll baseline.
// commonModes: false = default-mode control.  pump = Rust scoped uv_run(NOWAIT) callback.
@_cdecl("aw_rl_start")
public func aw_rl_start(_ loopPtr: UInt, _ mechanism: Int32, _ commonModes: Bool,
                        _ pump: @convention(c) @escaping () -> Void) {
    S.loop = UnsafeMutableRawPointer(bitPattern: loopPtr)
    S.mechanism = mechanism
    S.commonModes = commonModes
    S.embedClosed = false
    S.pumpCb = pump
    initAsync()
    switch mechanism {
    case 1: startHelperMechanism()
    case 2: startCffdMechanism()
    case 3: startPollBaselineMechanism()
    default: plog("unknown mechanism \(mechanism)")
    }
}

@_cdecl("aw_rl_teardown")
public func aw_rl_teardown() {
    plog("teardown: mechanism=\(S.mechanism)")
    S.embedClosed = true
    if S.mechanism == 1 {
        // Double-wake-before-join: the helper may be blocked on EITHER the semaphore OR poll.
        S.sem.signal()                 // release a helper parked on sem
        aw_rl_nudge()                  // uv_async_send breaks a poll(timeout=-1)
        if let h = S.helper { pthread_join(h, nil) }
        // drain any leftover semaphore posts (non-blocking)
        while S.sem.wait(timeout: .now()) == .success {}
        if let src = S.source { CFRunLoopSourceInvalidate(src) }
    } else {
        if let obs = S.observer { CFRunLoopObserverInvalidate(obs) }
        if let timer = S.timer { CFRunLoopTimerInvalidate(timer) }
        if let src = S.fdSource { CFRunLoopSourceInvalidate(src) }
        if let cffd = S.cffd { CFFileDescriptorInvalidate(cffd) }
    }
    plog("teardown: complete (no deadlock)")
}

// Run a NESTED runloop in a non-default mode for `seconds` — reproduces AppKit's
// modal/tracking behaviour (menu tracking = NSEventTrackingRunLoopMode; modal =
// NSModalPanelRunLoopMode). Directly tests the kCFRunLoopCommonModes requirement.
@_cdecl("aw_rl_run_nested")
public func aw_rl_run_nested(_ mode: Int32, _ seconds: Double) {
    let m: CFRunLoopMode = (mode == 1)
        ? CFRunLoopMode("NSModalPanelRunLoopMode" as CFString)
        : CFRunLoopMode("NSEventTrackingRunLoopMode" as CFString)
    S.nestedStart = S.uvRunPasses
    plog("run_nested: entering \(m.rawValue) for \(seconds)s (main thread blocked in nested runloop)")
    CFRunLoopRunInMode(m, seconds, false)
    S.nestedEnd = S.uvRunPasses
    plog("run_nested: exited nested mode; passes during window = \(S.nestedEnd - S.nestedStart)")
}

// Schedule a nested runloop to begin `delayMs` into NSApp.run() (on the main queue), so the
// nested-runloop-survival test can trigger it while AppKit owns thread 0.
@_cdecl("aw_rl_schedule_nested")
public func aw_rl_schedule_nested(_ delayMs: Int32, _ mode: Int32, _ seconds: Double) {
    DispatchQueue.main.asyncAfter(deadline: .now() + Double(delayMs) / 1000.0) {
        aw_rl_run_nested(mode, seconds)
    }
}

// Background pinger: uv_async_send every intervalMs, generating loop wake-ups so the
// nested-runloop measurement has libuv work to service. Runs until aw_rl_stop_pinger.
private let pingerMain: @convention(c) (UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? = { _ in
    while !S.pingerStop {
        aw_rl_nudge()
        usleep(useconds_t(S.pingerIntervalMs) * 1000)
    }
    return nil
}

@_cdecl("aw_rl_start_pinger")
public func aw_rl_start_pinger(_ intervalMs: Int32) {
    S.pingerStop = false
    S.pingerIntervalMs = intervalMs
    var tid = pthread_t(bitPattern: 0)
    pthread_create(&tid, nil, pingerMain, nil)
    S.pinger = tid
}

@_cdecl("aw_rl_stop_pinger")
public func aw_rl_stop_pinger() {
    S.pingerStop = true
    if let p = S.pinger { pthread_join(p, nil) }
    S.pinger = nil
}

// Fill [uvRunPasses, fdFires, timerFires, helperPolls, sourceFires].
@_cdecl("aw_rl_get_stats")
public func aw_rl_get_stats(_ out: UnsafeMutablePointer<Int64>) {
    out[0] = S.uvRunPasses
    out[1] = S.fdFires
    out[2] = S.timerFires
    out[3] = S.helperPolls
    out[4] = S.sourceFires
    out[5] = S.timeoutZeroPolls
    out[6] = S.lastTimeout
    out[7] = S.nestedStart
    out[8] = S.nestedEnd
}

// ============================================================================
// Background-thread callback → tsfn poke (reused from substrate spike probe 3)
// ============================================================================
@_cdecl("aw_rl_dispatch_bg")
public func aw_rl_dispatch_bg(_ cb: @convention(c) @escaping (UInt64) -> Void, _ token: UInt64) {
    DispatchQueue.global().async { cb(token) }
}

// A repeating background pinger that pokes a tsfn every intervalMs (JS-observable liveness).
private var _tsfnPinger: DispatchSourceTimer?
@_cdecl("aw_rl_start_tsfn_pinger")
public func aw_rl_start_tsfn_pinger(_ cb: @convention(c) @escaping (UInt64) -> Void, _ intervalMs: Int32) {
    let t = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
    t.schedule(deadline: .now() + .milliseconds(Int(intervalMs)),
               repeating: .milliseconds(Int(intervalMs)))
    var n: UInt64 = 0
    t.setEventHandler { n += 1; cb(n) }
    t.resume()
    _tsfnPinger = t
}

@_cdecl("aw_rl_stop_tsfn_pinger")
public func aw_rl_stop_tsfn_pinger() {
    _tsfnPinger?.cancel()
    _tsfnPinger = nil
}
