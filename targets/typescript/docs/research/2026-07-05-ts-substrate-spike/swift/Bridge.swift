// Bridge.swift — THROWAWAY spike dylib for ts-substrate-spike-k3.
//
// Mirrors the ADR-0013 generated-typed-dispatch mechanism by hand:
//   dlsym(RTLD_DEFAULT, "objc_msgSend")  (Swift's ObjectiveC overlay marks it
//   unavailable), then unsafeBitCast to a concrete @convention(c) shape per
//   distinct ABI signature. Each aw_ts_* entry is one such generated-style entry.
//
// These @_cdecl functions are the C-ABI surface the napi-rs addon links against.
// Pointers (id / SEL / Class) cross to Rust as UInt (the raw address), which the
// addon surfaces to JS as BigInt "opaque handles".

import Foundation
import AppKit
import CoreGraphics
import Darwin

// objc_msgSend, fetched once (ADR-0013 impl note).
private let msgSendAddr: UnsafeMutableRawPointer = dlsym(UnsafeMutableRawPointer(bitPattern: -2) /* RTLD_DEFAULT */, "objc_msgSend")!

// ---- helpers: class + selector lookup (plain libobjc) --------------------

@_cdecl("aw_ts_get_class")
public func aw_ts_get_class(_ name: UnsafePointer<CChar>) -> UInt {
    guard let cls = objc_getClass(name) else { return 0 }
    return unsafeBitCast(cls as AnyObject, to: UInt.self)
}

@_cdecl("aw_ts_sel")
public func aw_ts_sel(_ name: UnsafePointer<CChar>) -> UInt {
    let sel = sel_registerName(name)   // Selector is a pointer-sized SEL
    return unsafeBitCast(sel, to: UInt.self)
}

// ---- generated-style dispatch entries, one per ABI signature -------------

// (id, SEL) -> id     e.g. [NSScreen mainScreen]
@_cdecl("aw_ts_msg_id__id_sel")
public func aw_ts_msg_id__id_sel(_ recv: UInt, _ sel: UInt) -> UInt {
    typealias Fn = @convention(c) (UInt, UInt) -> UInt
    let f = unsafeBitCast(msgSendAddr, to: Fn.self)
    return f(recv, sel)
}

// (id, SEL, const char*) -> id   e.g. [NSString stringWithUTF8String:]
@_cdecl("aw_ts_msg_id__id_sel_cstr")
public func aw_ts_msg_id__id_sel_cstr(_ recv: UInt, _ sel: UInt, _ cstr: UnsafePointer<CChar>) -> UInt {
    typealias Fn = @convention(c) (UInt, UInt, UnsafePointer<CChar>) -> UInt
    let f = unsafeBitCast(msgSendAddr, to: Fn.self)
    return f(recv, sel, cstr)
}

// (id, SEL) -> UInt64    e.g. -[NSString length]  (scalar return)
@_cdecl("aw_ts_msg_u64__id_sel")
public func aw_ts_msg_u64__id_sel(_ recv: UInt, _ sel: UInt) -> UInt64 {
    typealias Fn = @convention(c) (UInt, UInt) -> UInt64
    let f = unsafeBitCast(msgSendAddr, to: Fn.self)
    return f(recv, sel)
}

// (id, SEL) -> CGRect    e.g. -[NSScreen frame]  (arm64 x8 struct-by-value return)
@_cdecl("aw_ts_msg_rect__id_sel")
public func aw_ts_msg_rect__id_sel(_ recv: UInt, _ sel: UInt) -> CGRect {
    typealias Fn = @convention(c) (UInt, UInt) -> CGRect
    let f = unsafeBitCast(msgSendAddr, to: Fn.self)
    return f(recv, sel)
}

// Convenience: read the 4 doubles of a CGRect the addon received, into an
// out-buffer — a second, independent path to cross-check the struct return.
@_cdecl("aw_ts_rect_probe")
public func aw_ts_rect_probe(_ recv: UInt, _ sel: UInt, _ out: UnsafeMutablePointer<Double>) {
    typealias Fn = @convention(c) (UInt, UInt) -> CGRect
    let f = unsafeBitCast(msgSendAddr, to: Fn.self)
    let r = f(recv, sel)
    out[0] = r.origin.x; out[1] = r.origin.y; out[2] = r.size.width; out[3] = r.size.height
}

// ---- probe 2: AppKit owns thread 0 ---------------------------------------

// Log helper visible from Node stderr.
private func plog(_ s: String) { FileHandle.standardError.write(("[swift] " + s + "\n").data(using: .utf8)!) }

// Build NSApp + a visible window, but do NOT run the loop. Safe to call from
// Node's main thread. Returns whether we are on the main thread.
@_cdecl("aw_ts_setup_app")
public func aw_ts_setup_app() -> Bool {
    let onMain = Thread.isMainThread
    let app = NSApplication.shared
    app.setActivationPolicy(.regular)
    let win = NSWindow(
        contentRect: NSRect(x: 100, y: 100, width: 420, height: 260),
        styleMask: [.titled, .closable, .resizable],
        backing: .buffered, defer: false)
    win.title = "ts-substrate-spike"
    win.backgroundColor = .systemTeal
    win.makeKeyAndOrderFront(nil)
    app.activate(ignoringOtherApps: true)
    plog("setup_app: onMain=\(onMain) window=\(win) visible=\(win.isVisible)")
    _spikeWindow = win
    return onMain
}
private var _spikeWindow: NSWindow?

// Cede thread 0 to NSApplication.run(). Blocks until the app terminates.
// Schedules an auto-terminate after `seconds` so the spike process exits.
@_cdecl("aw_ts_run_app")
public func aw_ts_run_app(_ seconds: Double) {
    plog("run_app: onMain=\(Thread.isMainThread), calling NSApplication.run(); autoquit in \(seconds)s")
    if seconds > 0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            plog("run_app: autoquit firing -> NSApp.stop + terminate")
            NSApplication.shared.stop(nil)
            // stop() only takes effect after the next event; post one.
            let ev = NSEvent.otherEvent(with: .applicationDefined, location: .zero,
                modifierFlags: [], timestamp: 0, windowNumber: 0, context: nil,
                subtype: 0, data1: 0, data2: 0)!
            NSApplication.shared.postEvent(ev, atStart: true)
        }
    }
    NSApplication.shared.run()
    plog("run_app: NSApplication.run() returned")
}

// Integrated model: NSApplication.run() genuinely owns thread 0, and a main-runloop
// timer pumps libuv (via the supplied C callback -> uv_run(NOWAIT)) every ~4ms, so
// Node's loop (timers, promises, threadsafe-function async handles) stays serviced.
@_cdecl("aw_ts_run_app_integrated")
public func aw_ts_run_app_integrated(_ loopPtr: UInt, _ seconds: Double,
                                     _ pump: @convention(c) @escaping (UInt) -> Void) {
    plog("run_app_integrated: onMain=\(Thread.isMainThread), pumping uv every 4ms under NSApp.run(); autoquit in \(seconds)s")
    let t = Timer(timeInterval: 0.004, repeats: true) { _ in pump(loopPtr) }
    RunLoop.main.add(t, forMode: .common)
    if seconds > 0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            plog("run_app_integrated: autoquit firing")
            t.invalidate()
            NSApplication.shared.stop(nil)
            let ev = NSEvent.otherEvent(with: .applicationDefined, location: .zero,
                modifierFlags: [], timestamp: 0, windowNumber: 0, context: nil,
                subtype: 0, data1: 0, data2: 0)!
            NSApplication.shared.postEvent(ev, atStart: true)
        }
    }
    NSApplication.shared.run()
    plog("run_app_integrated: NSApplication.run() returned")
}

// Manual co-operative pump: drain pending Cocoa events without ceding the thread.
// Returns the number of events processed. Lets Node keep its own loop and call
// this on a timer (the "pump both loops" mechanism).
@_cdecl("aw_ts_pump")
public func aw_ts_pump(_ maxEvents: Int32) -> Int32 {
    var n: Int32 = 0
    let app = NSApplication.shared
    while n < maxEvents,
          let ev = app.nextEvent(matching: .any, until: nil, inMode: .default, dequeue: true) {
        app.sendEvent(ev)
        n += 1
    }
    return n
}

// ---- probe 3: background-thread callback bounced toward main -------------

// Dispatch a block on a GCD *global* (background) queue; from that bg thread,
// invoke the supplied C callback (a napi threadsafe-function poke in Rust),
// passing the token back. This is the real ObjC-callback shape: work arrives on
// a framework/GCD thread and must reach JS on the loop thread.
@_cdecl("aw_ts_dispatch_bg")
public func aw_ts_dispatch_bg(_ cb: @convention(c) @escaping (UInt64) -> Void, _ token: UInt64) {
    DispatchQueue.global().async {
        let onMain = Thread.isMainThread   // expected: false (we are on a GCD worker)
        plog("dispatch_bg: invoking cb from bg thread onMain=\(onMain) token=\(token)")
        cb(token)
    }
}

// Variant that bounces to the MAIN queue itself before poking the callback —
// the ADR-0014/0035 native-bounce shape (native reaches main before touching
// the runtime). Requires the main runloop to be running (probe 2).
@_cdecl("aw_ts_dispatch_bg_then_main")
public func aw_ts_dispatch_bg_then_main(_ cb: @convention(c) @escaping (UInt64) -> Void, _ token: UInt64) {
    DispatchQueue.global().async {
        plog("dispatch_bg_then_main: on bg (main=\(Thread.isMainThread)), hopping to main queue")
        DispatchQueue.main.async {
            plog("dispatch_bg_then_main: on main (main=\(Thread.isMainThread)), invoking cb")
            cb(token)
        }
    }
}
