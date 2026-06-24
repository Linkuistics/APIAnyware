// SubclassSynth.swift — native ObjC-subclass IMP installation via NSInvocation
// forwarding (ADR-0034 §5; the bounce-shim IMP open item, resolved here).
//
// ## The open item this file resolves (design spec §8, leaf 010 done-bar)
//
// A user's `define-objc-subclass` (contract §3.4) overrides framework selectors
// (`drawRect:`, `mouseDown:`, delegate methods, …) with Lisp `define-objc-method`
// handlers. AppKit must dispatch those selectors into Lisp — so each overridden
// selector needs a real ObjC IMP on the synthesized class. That IMP:
//   1. is a `@convention(c)` function (an ObjC IMP), and a `@convention(c)` IMP is
//      **signature-specific** — its ABI is fixed at compile time; Swift cannot build
//      one per-signature at runtime (no libffi-closure analogue, unlike racket); and
//   2. is the FOREIGN-THREAD entry point — it must bounce to main BEFORE running any
//      Lisp (ADR-0035), so it cannot be a raw `define-alien-callable`.
//
// **Decision: NSInvocation forwarding — ONE reflective trampoline, not generated
// per selector-signature.** Rather than the emitter generating a `@convention(c)`
// shim per overridable signature (gerbil's fixed-family approach — see below — does
// not generalize: on arm64 a `void*`-typed shim cannot receive a struct/float arg,
// which lives in a different register bank), we install the libobjc forwarding
// trampoline `_objc_msgForward` for each overridden selector and override the two
// NSObject forwarding hooks once per class:
//
//   • `methodSignatureForSelector:` → returns the selector's `NSMethodSignature`
//     (built from the baked ObjC type encoding the runtime hands down). Pure Swift,
//     NO Lisp, NO bounce — it runs on the (possibly foreign) calling thread before
//     forwarding proceeds, so it must not touch Lisp.
//   • `forwardInvocation:` → bounces to main (CallbackBounce), then calls the ONE
//     registered Lisp dispatcher with the `NSInvocation`. On main, Lisp reads the
//     args (`getArgument:atIndex:`), routes on `[inv selector]` + the receiver's
//     class to the right `define-objc-method` handler, and writes the result
//     (`setReturnValue:`). The ObjC runtime reifies args/return per the signature,
//     so this single trampoline is ABI-correct for EVERY selector shape — structs
//     (`NSRect`), floats (`CGFloat`), everything — with no per-selector codegen and
//     NO coupling to which selectors an app overrides.
//
// **Why not generated-per-selector-signature (the other option):** it would couple
// the dylib (or `Generated/`) to the overridable surface — either every overridable
// AppKit selector (infeasible) or only the app-used ones (couples the runtime dylib
// to sample apps, which it must not be). And the fixed-family variant (gerbil
// `native_block.c`'s `void*`-tail shims keyed by return type) is **not ABI-correct
// for struct/float args** on arm64. NSInvocation forwarding is general, correct, and
// uncoupled — at the cost of a per-call `NSInvocation` allocation, negligible for UI
// callbacks. This matches the contract's "the runtime drives conformance" posture
// (it already reads `protocol_getMethodDescription` live).
//
// **Refinement of ADR-0038 §4:** the ADR sketched "Lisp passes its
// `define-alien-callable` pointer PER overridden selector"; with forwarding the Lisp
// side registers ONE dispatcher (not per-selector) and routes by selector itself —
// simpler on both sides. ADR-0038 §4 / design §8 explicitly left this a 050 choice.
//
// NSInvocation and NSMethodSignature are `NS_SWIFT_UNAVAILABLE`, so this file drives
// them via the ObjC runtime: a class-method IMP call builds the signature; the
// `forwardInvocation:` trampoline treats the invocation as an opaque `id` and hands
// it to Lisp (which uses raw `objc_msgSend` and does not care). The whole round-trip
// is verified in `APIAnywareSbclTests`.
//
// The Lisp side (`define-objc-subclass` / `register-objc-protocol` consumption, the
// `objc_allocateClassPair`/`objc_registerClassPair` calls driven via `sb-alien`, and
// the dispatcher that reads the NSInvocation) is leaf 050/040-subclass-and-conformance.
// This file is the Swift IMP-builder half it installs into.

import Foundation
import ObjectiveC
import os

/// The single Lisp forwarding dispatcher: `(self, invocation)`, both raw `id`s. Runs
/// on the main thread (the `forwardInvocation:` trampoline bounces first). Lisp reads
/// `[inv selector]` + the receiver class to route to the right `define-objc-method`.
public typealias AwSbclInvocationDispatcher =
    @convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void

// ─── The forwarding registry ────────────────────────────────────────────────
// Maps each synthesized class's forwarded selectors to their ObjC type encodings
// (so `methodSignatureForSelector:` can answer without Lisp), caches the built
// `NSMethodSignature`s, tracks which classes already carry the two override IMPs,
// and holds the one Lisp dispatcher. Guarded by an unfair lock: writes happen at
// class-setup time, but `methodSignatureForSelector:` reads can land on a foreign
// thread before the bounce, so the access is genuinely cross-thread.

private struct AwSbclForwardingState {
    /// (class) → (selector → ObjC type encoding).
    var encodings: [ObjectIdentifier: [Selector: String]] = [:]
    /// ObjC type encoding → the +1-retained `NSMethodSignature` pointer, as an `Int`
    /// bit pattern (raw pointers are Sendable-unavailable; `Int` keeps the whole state
    /// Sendable for the lock). The +1 retain is never released — ObjC classes live for
    /// the process lifetime, so one cached signature per distinct encoding is bounded
    /// and permanent.
    var signatures: [String: Int] = [:]
    /// Classes that already have the two forwarding-hook IMPs installed.
    var installed: Set<ObjectIdentifier> = []
    /// The one Lisp dispatcher (registered once at runtime load).
    var dispatcher: AwSbclInvocationDispatcher?
}

private let awSbclForwarding = OSAllocatedUnfairLock(initialState: AwSbclForwardingState())

/// Build an `NSMethodSignature*` from an ObjC type-encoding string, reflectively
/// (the Swift type is `NS_SWIFT_UNAVAILABLE`). Calls `+[NSMethodSignature
/// signatureWithObjCTypes:]` through its class-method IMP. Returns a +0 (autoreleased)
/// object; the caller caches it (which retains it), so the autorelease is harmless.
private func awSbclBuildSignature(_ encoding: String) -> AnyObject? {
    guard let cls: AnyClass = NSClassFromString("NSMethodSignature") else { return nil }
    let sel = sel_registerName("signatureWithObjCTypes:")
    guard let m = class_getClassMethod(cls, sel) else { return nil }
    typealias Factory =
        @convention(c) (AnyObject, Selector, UnsafePointer<CChar>) -> Unmanaged<AnyObject>?
    let fn = unsafeBitCast(method_getImplementation(m), to: Factory.self)
    return encoding.withCString { fn(cls, sel, $0)?.takeUnretainedValue() }
}

/// The libobjc forwarding trampoline `_objc_msgForward`, obtained without `dlsym`:
/// `class_getMethodImplementation` on a selector NSObject does not implement returns
/// the forwarding IMP (documented behaviour). Installed per overridden selector so
/// any message to it routes through `methodSignatureForSelector:` + `forwardInvocation:`.
// `nonisolated(unsafe)`: an immutable function pointer computed once. `IMP`
// (OpaquePointer) is not Sendable, so a plain global `let` is rejected under strict
// concurrency; the value is genuinely a constant shared read-only, so the opt-out is
// honest.
nonisolated(unsafe) private let awSbclForwardingIMP: IMP = {
    let probe = sel_registerName("__apianyware_sbcl_probe_unimplemented_selector__:")
    return class_getMethodImplementation(NSObject.self, probe)!
}()

// ─── The two forwarding-hook IMPs (installed once per synthesized class) ──────

/// `methodSignatureForSelector:` override. Pure Swift, no Lisp, no bounce — it runs
/// on the calling thread before forwarding proceeds. Returns the cached signature for
/// a forwarded selector; otherwise falls through to the superclass's implementation
/// (via its IMP, not `objc_msgSend`, to avoid re-entering this override).
private let awSbclMethodSignatureForSelectorIMP:
    @convention(c) (AnyObject, Selector, Selector) -> Unmanaged<AnyObject>? = { obj, _cmd, sel in
        let cls: AnyClass = object_getClass(obj)!
        let key = ObjectIdentifier(cls)
        // Carries the cached signature's pointer out as an `Int` bit pattern — raw
        // pointers are Sendable-unavailable, so they cannot cross `withLock`; the
        // signature is built once per distinct encoding and retained permanently, so
        // handing it back +0 is safe.
        let hitBits: Int? = awSbclForwarding.withLock { state -> Int? in
            guard let enc = state.encodings[key]?[sel] else { return nil }
            if let cached = state.signatures[enc] { return cached }
            guard let built = awSbclBuildSignature(enc) else { return nil }
            let bits = Int(bitPattern: Unmanaged.passRetained(built).toOpaque())
            state.signatures[enc] = bits
            return bits
        }
        if let hitBits, let p = UnsafeMutableRawPointer(bitPattern: hitBits) {
            return Unmanaged<AnyObject>.fromOpaque(p)
        }
        // Not ours — defer to the superclass implementation.
        let supImp = class_getMethodImplementation(class_getSuperclass(cls), _cmd)!
        typealias Super =
            @convention(c) (AnyObject, Selector, Selector) -> Unmanaged<AnyObject>?
        return unsafeBitCast(supImp, to: Super.self)(obj, _cmd, sel)
    }

/// `forwardInvocation:` override. The foreign-thread entry: bounce to main
/// (CallbackBounce, synchronous so the invocation + its borrowed framework args
/// outlive the hop), then call the one Lisp dispatcher with the invocation. Lisp,
/// on main, reads args / routes / sets the return value.
private let awSbclForwardInvocationIMP:
    @convention(c) (AnyObject, Selector, AnyObject) -> Void = { obj, _cmd, invocation in
        let dispatcher = awSbclForwarding.withLock { $0.dispatcher }
        guard let dispatcher else { return }   // no handler registered — drop (the
                                                // default NSObject behaviour would raise;
                                                // a registered runtime always sets this).
        let selfPtr = Unmanaged.passUnretained(obj).toOpaque()
        let invPtr = Unmanaged.passUnretained(invocation).toOpaque()
        awSbclOnMain { dispatcher(selfPtr, invPtr) }
    }

/// Install the two forwarding-hook IMPs on `cls`, once. Idempotent.
private func awSbclEnsureForwardingHooks(on cls: AnyClass) {
    let need: Bool = awSbclForwarding.withLock { state in
        state.installed.insert(ObjectIdentifier(cls)).inserted
    }
    guard need else { return }
    _ = class_addMethod(cls, sel_registerName("methodSignatureForSelector:"),
                        unsafeBitCast(awSbclMethodSignatureForSelectorIMP, to: IMP.self), "@@::")
    _ = class_addMethod(cls, sel_registerName("forwardInvocation:"),
                        unsafeBitCast(awSbclForwardInvocationIMP, to: IMP.self), "v@:@")
}

// ─── The C-ABI entries the Lisp runtime binds via `sb-alien` ──────────────────

/// Register the one Lisp forwarding dispatcher. Called once when the runtime loads.
/// `dispatcher` is a `define-alien-callable` pointer of signature `(id self, id inv)`;
/// it is only ever invoked on the main thread (the `forwardInvocation:` bounce).
@_cdecl("aw_sbcl_subclass_register_dispatcher")
public func aw_sbcl_subclass_register_dispatcher(_ dispatcher: UnsafeMutableRawPointer) {
    let fn = unsafeBitCast(dispatcher, to: AwSbclInvocationDispatcher.self)
    awSbclForwarding.withLock { $0.dispatcher = fn }
}

/// Route one overridden selector on a synthesized class through the Lisp dispatcher.
/// Lisp calls this between `objc_allocateClassPair` and `objc_registerClassPair`
/// (both driven Lisp-side via `sb-alien`, ADR-0038 §4), once per overridden selector.
/// Records the encoding (for `methodSignatureForSelector:`), installs `_objc_msgForward`
/// for the selector, and ensures the two forwarding hooks are on the class.
///
/// `cls`/`sel` are the raw `Class`/`SEL` pointers; `types` is the selector's ObjC type
/// encoding (e.g. `"v@:{CGRect=...}"` for `drawRect:`), which Lisp reads from the live
/// superclass/protocol (`method_getTypeEncoding` / `protocol_getMethodDescription`).
@_cdecl("aw_sbcl_subclass_add_forward")
public func aw_sbcl_subclass_add_forward(
    _ cls: UnsafeMutableRawPointer,
    _ sel: UnsafeMutableRawPointer,
    _ types: UnsafePointer<CChar>
) {
    let klass: AnyClass = unsafeBitCast(cls, to: AnyClass.self)
    let selector = unsafeBitCast(sel, to: Selector.self)
    let encoding = String(cString: types)
    awSbclForwarding.withLock { state in
        state.encodings[ObjectIdentifier(klass), default: [:]][selector] = encoding
    }
    _ = class_addMethod(klass, selector, awSbclForwardingIMP, types)
    awSbclEnsureForwardingHooks(on: klass)
}
