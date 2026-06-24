// swift-residual-fixture.swift — a committed, buildable stand-in for the emitter's
// gitignored `Generated/Trampolines.swift`, for the 050/080 integration smoke's
// §6d (Swift-native residual) gate.
//
// WHY A FIXTURE, NOT THE REAL EMITTER OUTPUT. The real `aw_sbcl_swift_*` trampolines
// are written by `generate --target sbcl` from the enriched IR, which is gitignored
// (16–90 MB, reproducible only by re-running the full collect→analyse→annotate
// pipeline). A real trampoline body `import`s a system framework and calls a real
// Swift-native API by name, so it cannot be reconstructed for a synthetic framework.
// This fixture instead defines its OWN self-contained Swift-native "FixtureKit" APIs
// — one per §6d shape — and wraps each in an `@_cdecl aw_sbcl_swift_*` entry whose
// SIGNATURE + MARSHALLING match the emitter's output exactly (cross-checked against
// `emit-sbcl/src/trampoline.rs`'s `emit_fn`/`emit_const`/`emit_method_tramp`/
// `emit_init_tramp` + the `render_binding` Lisp side). It `import`s `APIAnywareSbcl`
// so it shares the REAL dylib bridges — `awSbclBox`/`aw_sbcl_box_free` (one box type),
// `awSbclTry`/`awSbclWriteError` (the ThrowsBridge) — so the Lisp side exercises the
// genuine runtime helpers, not a re-implementation. Compiled at smoke time into a
// separate test dylib (mirroring `smoke-threading-callbacks.c`'s clang harness).
//
// The §6d invariant itself (51 fn + 7 const + 576 init + 554 method trampolines) is
// the emitter's, proven by `emit-sbcl/tests/` against the IR. This fixture proves the
// RUNTIME side links + calls through, BY SHAPE, which the emitter tests cannot.

import Foundation
import APIAnywareSbcl

// ─── FixtureKit — the self-contained Swift-native API surface (one per shape) ─────
// These stand in for the `objc_exposed == false` Swift-native delta a real framework
// carries. Each is reached ONLY through its `@_cdecl` trampoline below — the thing a
// Lisp `objc_msgSend` structurally cannot call (ADR-0038).

enum FixtureKit {
    // shape 1 — a Swift-native free function (scalar in/out).
    static func scale(_ x: Double) -> Double { x * 2.0 }

    // shape 2 — a Swift-native String-valued global constant.
    static let greeting: String = "hello from FixtureKit"

    // shape 5 — a non-bridged Swift value type (no Foundation bridge, not an ObjC
    // object): crosses the C ABI only as an opaque `AwSbclValueBox` handle.
    struct Pair { let a: Int64; let b: Int64 }

    // shape 6 — a Swift-native `throws` function: returns a String on success, throws
    // a populated NSError on failure (the ThrowsBridge → `ns:cocoa-error` path).
    static func risky(_ shouldThrow: Bool) throws -> String {
        if shouldThrow {
            throw NSError(domain: "FixtureKitErrorDomain", code: 42,
                          userInfo: [NSLocalizedDescriptionKey: "fixture asked to throw"])
        }
        return "ok"
    }
}

// ─── shape 1: function trampoline — aw_sbcl_swift_<Fw>_<name> ─────────────────────
// Emitter shape: `public func <entry>(_ a0: Double) -> Double { return FixtureKit.scale(a0) }`.
@_cdecl("aw_sbcl_swift_FixtureKit_scale")
public func aw_sbcl_swift_FixtureKit_scale(_ x: Double) -> Double {
    return FixtureKit.scale(x)
}

// ─── shape 2: constant trampoline — aw_sbcl_swift_const_<Fw>_<name> ───────────────
// A String global crosses as a +1-retained NSString id (Lisp `aw-swift-string-result`
// copies the bytes + releases the +1).
@_cdecl("aw_sbcl_swift_const_FixtureKit_greeting")
public func aw_sbcl_swift_const_FixtureKit_greeting() -> UnsafeMutableRawPointer? {
    return Unmanaged.passRetained(FixtureKit.greeting as NSString).toOpaque()
}

// ─── shape 3: class-owner method trampoline — aw_sbcl_swift_m_<Fw>_<Owner>_<base> ─
// A Swift-native method on a BOUND ObjC class (045): the receiver crosses as its `id`
// handle (`aw-ptr self`), reconstructed here borrowed. Returns a scalar. (NSString
// stands in for the bound owner so the smoke drives it against a real receiver.)
@_cdecl("aw_sbcl_swift_m_FixtureKit_NSString_swiftDoubleLength")
public func aw_sbcl_swift_m_FixtureKit_NSString_swiftDoubleLength(
    _ selfPtr: UnsafeMutableRawPointer
) -> Int64 {
    let s = Unmanaged<NSString>.fromOpaque(selfPtr).takeUnretainedValue()
    return Int64(s.length) * 2
}

// ─── shape 4: class-owner init trampoline — aw_sbcl_swift_init_<Fw>_<Owner> ───────
// A Swift-native initializer on a bound owner (045): returns a +1-retained id the
// Lisp `make-<owner>` constructor `aw-wrap`s (+1). Builds a real NSString.
@_cdecl("aw_sbcl_swift_init_FixtureKit_NSString")
public func aw_sbcl_swift_init_FixtureKit_NSString(_ value: Int64) -> UnsafeMutableRawPointer? {
    return Unmanaged.passRetained(NSString(string: "fixture-\(value)")).toOpaque()
}

// ─── shape 5: value/opaque return — boxed through AwSbclValueBox ──────────────────
// A non-bridged value return crosses as an opaque +1 handle (the REAL `awSbclBox` from
// the imported dylib, so the Lisp `aw-box-free` → `aw_sbcl_box_free` reclaims it).
@_cdecl("aw_sbcl_swift_FixtureKit_makePair")
public func aw_sbcl_swift_FixtureKit_makePair(_ a: Int64, _ b: Int64) -> UnsafeMutableRawPointer? {
    return awSbclBox(FixtureKit.Pair(a: a, b: b))
}

// A companion accessor proving the boxed value survived the crossing (unbox is the
// same-module read the emitter uses for a value-struct param, where the concrete type
// is nameable). Returns a.b summed.
@_cdecl("aw_sbcl_swift_m_FixtureKit_Pair_sum")
public func aw_sbcl_swift_m_FixtureKit_Pair_sum(_ handle: UnsafeMutableRawPointer) -> Int64 {
    let pair = awSbclUnbox(handle, as: FixtureKit.Pair.self)
    return pair.a + pair.b
}

// ─── shape 6: throws — ThrowsBridge → ns:cocoa-error ─────────────────────────────
// A trailing caller-allocated `NSError**` out-cell; on throw, `awSbclTry` writes a
// +1-retained NSError + returns the fallback (nil). The Lisp side (`aw-swift-call/error`,
// the 050/050 ThrowsBridge consumer) reads the cell, releases the +1, signals
// `ns:cocoa-error`. On success returns a +1 NSString.
@_cdecl("aw_sbcl_swift_FixtureKit_risky")
public func aw_sbcl_swift_FixtureKit_risky(
    _ shouldThrow: Int64,
    _ awErrOut: UnsafeMutableRawPointer?
) -> UnsafeMutableRawPointer? {
    return awSbclTry(awErrOut, nil) {
        Unmanaged.passRetained(try FixtureKit.risky(shouldThrow != 0) as NSString).toOpaque()
    }
}
