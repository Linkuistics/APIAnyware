import Testing
import Foundation
import ObjectiveC
@testable import APIAnywareSbcl

// Swift-side smoke for `libAPIAnywareSbcl` (ADR-0038, leaf 050/010). The dylib is
// the SBCL target's sole native unit; SBCL is not needed to prove the native half
// resolves, runs, and marshals across the flat C ABI. The full end-to-end (these
// entries reached from a real SBCL image, under a live AppKit run loop with the
// cross-thread bounce exercised) is a later runtime + VM-verify leaf.

// ─── Hermetic helpers (ports of the gerbil dylib, renamed `awSbcl*`) ─────────

/// The opaque value box round-trips an arbitrary non-bridged Swift value and the
/// one uniform free reclaims it (exported as `aw_sbcl_box_free`).
@Test func opaqueValueBoxRoundTrips() {
    struct Pair { let a: Int; let b: String }
    let handle = awSbclBox(Pair(a: 7, b: "x"))
    let back = awSbclUnbox(handle, as: Pair.self)
    #expect(back.a == 7)
    #expect(back.b == "x")
    awSbclBoxFree(handle)
}

/// The throws bridge returns the body's value on success and the fallback (after
/// writing a retained `NSError *`) on throw.
@Test func throwsBridgeWritesErrorAndReturnsFallback() {
    enum E: Error { case boom }
    var cell: UnsafeMutableRawPointer? = nil
    let ok = withUnsafeMutablePointer(to: &cell) { p -> Int in
        awSbclTry(UnsafeMutableRawPointer(p), -1) { 99 }
    }
    #expect(ok == 99)
    #expect(cell == nil)

    let fallback = withUnsafeMutablePointer(to: &cell) { p -> Int in
        awSbclTry(UnsafeMutableRawPointer(p), -1) { throw E.boom }
    }
    #expect(fallback == -1)
    #expect(cell != nil)
    if let e = cell { Unmanaged<NSError>.fromOpaque(e).release() }
}

// ─── CallbackBounce (ADR-0035) ────────────────────────────────────────────────

/// `aw_sbcl_on_main_run` invokes its callback, and on the main thread it runs there
/// directly (the UI common case — no GCD hop, no deadlock window). Pinned to
/// `@MainActor` so `pthread_main_np()` is true and the direct path is taken.
@MainActor @Test func onMainRunInvokesCallbackOnTheMainThread() {
    var observed: Int32 = -1
    withUnsafeMutablePointer(to: &observed) { p in
        aw_sbcl_on_main_run({ ctx in
            // Records whether the callback body sees itself on the main thread.
            ctx!.assumingMemoryBound(to: Int32.self).pointee = aw_sbcl_is_main_thread()
        }, UnsafeMutableRawPointer(p))
    }
    #expect(observed == 1)
    #expect(aw_sbcl_is_main_thread() == 1)
}

// ─── SubclassSynth: the NSInvocation-forwarding round-trip (the headline) ─────
//
// Stands in for the Lisp dispatcher with a Swift `@convention(c)` one and proves the
// whole mechanism: `_objc_msgForward` install, the `methodSignatureForSelector:`
// override (built reflectively from the encoding), the `forwardInvocation:` override
// + bounce, the dispatcher reading the arg via `NSInvocation`, and the return value
// propagating back through the forwarding machinery. ABI-correct for any signature.

// NSInvocation is NS_SWIFT_UNAVAILABLE — drive it via an @objc protocol + bitcast,
// with explicit selectors matching the real ones.
@objc private protocol AwTestInvocation {
    var selector: Selector { get }
    @objc(getArgument:atIndex:) func getArgument(_ p: UnsafeMutableRawPointer, at idx: Int)
    @objc(setReturnValue:) func setReturnValue(_ p: UnsafeMutableRawPointer)
}

// The dispatcher can't capture (it is `@convention(c)`), so it records into a shared
// holder. The whole round-trip funnels through the main thread synchronously, so no
// further locking is needed for the test's observation.
private final class AwTestObservation: @unchecked Sendable {
    var sawArg: Int32 = -777
    var sawSelector: String = ""
}
private let awTestObs = AwTestObservation()

private let awTestDispatcher: AwSbclInvocationDispatcher = { _, invPtr in
    guard let invPtr else { return }
    let inv = unsafeBitCast(
        Unmanaged<AnyObject>.fromOpaque(invPtr).takeUnretainedValue(),
        to: AwTestInvocation.self)
    awTestObs.sawSelector = NSStringFromSelector(inv.selector)
    var x: Int32 = 0
    inv.getArgument(&x, at: 2)          // index 0=self, 1=_cmd, 2=first real arg
    awTestObs.sawArg = x
    var r = x &+ 1
    inv.setReturnValue(&r)
}

// ─── BlockBridge (ADR-0035): a Lisp closure projected as an ObjC block ────────
//
// Proves the block ABI end-to-end on the DIRECT (on-main) path: the universal
// `(void*,void*,void*) -> void*` block is built, invoked as the framework would, the
// dispatcher runs (on main → no hop), the integer-class args cross in and the result
// crosses back through x0. The off-main FOREIGN bounce under a live run loop and GC
// pressure — the 5/5-crash regression gate — is the Lisp smoke's job
// (`smoke-threading-callbacks.lisp`), which needs a real SBCL image + main run loop.

private final class AwTestBlockObs: @unchecked Sendable {
    var sawMain: Int32 = -1
    var sawA1: Int = 0
    var sawA2: Int = 0
}
private let awTestBlockObs = AwTestBlockObs()

// Stands in for the Lisp `aw-block-dispatcher`: records main-ness + the first two
// integer-class args, returns `a1 + a2` as the block's result (rides x0 back).
private let awTestBlockDispatcher: AwSbclBlockDispatcher = { _bid, a1, a2, _a3 in
    awTestBlockObs.sawMain = aw_sbcl_is_main_thread()
    let i1 = Int(bitPattern: a1)
    let i2 = Int(bitPattern: a2)
    awTestBlockObs.sawA1 = i1
    awTestBlockObs.sawA2 = i2
    return UnsafeMutableRawPointer(bitPattern: i1 + i2)
}

@MainActor @Test func makeBlockProjectsClosureAndReturnsValueOnMain() {
    aw_sbcl_block_register_dispatcher(
        unsafeBitCast(awTestBlockDispatcher, to: UnsafeMutableRawPointer.self))
    guard let raw = aw_sbcl_make_block(7) else {
        Issue.record("aw_sbcl_make_block returned nil (dispatcher unregistered?)")
        return
    }
    // Reconstitute the block pointer as a callable and invoke it with three
    // integer-class args, as a framework block-call would (arm64: x0–x2).
    typealias Blk = @convention(block) (
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?
    ) -> UnsafeMutableRawPointer?
    let blk = unsafeBitCast(raw, to: Blk.self)
    let r = blk(UnsafeMutableRawPointer(bitPattern: 40),
                UnsafeMutableRawPointer(bitPattern: 2),
                nil)
    #expect(awTestBlockObs.sawMain == 1)      // ran on main — the direct path, no hop
    #expect(awTestBlockObs.sawA1 == 40)       // arg 1 crossed
    #expect(awTestBlockObs.sawA2 == 2)        // arg 2 crossed
    #expect(Int(bitPattern: r) == 42)         // value-returning block: result via x0
    // Balance the +1 the maker handed out (no framework copy in this test).
    Unmanaged<AnyObject>.fromOpaque(raw).release()
}

// ─── AsyncBridge (ADR-0035): async completion delivered on the main thread ────
//
// `awSbclAsyncDispatch` runs the op on the cooperative pool, then hops to the main
// actor before invoking the completion — so the Lisp continuation a generated async
// trampoline would call (the deferred async-trampoline leaf) runs main-side, GC-safe.

@Test func asyncDispatchDeliversCompletionOnTheMainThread() async {
    let outcome: (onMain: Bool, value: Int) = await withCheckedContinuation { cont in
        awSbclAsyncDispatch({ () async -> Int in 42 }) { value in
            cont.resume(returning: (aw_sbcl_is_main_thread() == 1, value))
        }
    }
    #expect(outcome.onMain)        // completion ran on the main thread (ADR-0035)
    #expect(outcome.value == 42)   // the marshalled payload crossed the hop intact
}

@MainActor @Test func synthesizedSubclassForwardsToTheDispatcher() {
    aw_sbcl_subclass_register_dispatcher(
        unsafeBitCast(awTestDispatcher, to: UnsafeMutableRawPointer.self))

    // Synthesize  AwSbclSmokeSub : NSObject  with a forwarded  awSmokeAddOne:(int).
    let name = "AwSbclSmokeSub"
    let cls: AnyClass = NSClassFromString(name)
        ?? objc_allocateClassPair(NSObject.self, name, 0)!
    let needsRegister = NSClassFromString(name) == nil
    let sel = sel_registerName("awSmokeAddOne:")
    let enc = "i@:i"   // int result, self(@), _cmd(:), int arg
    enc.withCString { types in
        aw_sbcl_subclass_add_forward(
            unsafeBitCast(cls, to: UnsafeMutableRawPointer.self),
            unsafeBitCast(sel, to: UnsafeMutableRawPointer.self),
            types)
    }
    if needsRegister { objc_registerClassPair(cls) }

    // Installing _objc_msgForward makes the class respond to the selector.
    let obj = (cls as! NSObject.Type).init()
    #expect(obj.responds(to: sel))

    // Drive the full path with a typed objc_msgSend (reflective; NS_SWIFT_UNAVAILABLE).
    let msgSend = dlsym(UnsafeMutableRawPointer(bitPattern: -2), "objc_msgSend")!
    typealias MsgI_I = @convention(c) (AnyObject, Selector, Int32) -> Int32
    let send = unsafeBitCast(msgSend, to: MsgI_I.self)
    let result = send(obj, sel, 41)

    #expect(awTestObs.sawSelector == "awSmokeAddOne:")
    #expect(awTestObs.sawArg == 41)        // arg read through NSInvocation
    #expect(result == 42)                  // return set + propagated back
}
