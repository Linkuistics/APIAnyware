import Testing
import Foundation
@testable import APIAnywareGerbil

// Swift-side tests for the generated Swift-native trampolines (ADR-0029, leaf
// 070/020) and the hermetic marshalling helpers. The generated `@_cdecl`
// trampolines are `public func`s, so `@testable import` calls them by their
// reconstructed C-entry name — proving they resolve, run, and marshal the §6a
// exemplars across the flat C ABI. (The full gerbil-side end-to-end — the same
// entries reached through `define-c-lambda` from a gerbil exe — is the CLI smoke
// `runtime/tests/smoke-swift-trampoline.ss`; the VM-verify is leaf 030.)

/// §6a exemplar — a Swift-native scalar free function with no C symbol. The
/// trampoline returns its time-derived `Int` directly.
@Test func timestampSeedTrampolineReturnsPositiveInt() {
    let seed = aw_gerbil_swift_CreateML_timestampSeed()
    #expect(seed > 0)
}

/// §6a exemplar — a Swift-native `String` global. The constant trampoline returns
/// a +1-retained `NSString` `id`; bridging it (the gerbil seam does this with
/// `aw-swift-string-result`) yields `"com.apple.CreateML"`.
@Test func errorDomainConstantTrampolineBridgesToExpectedString() {
    let raw = aw_gerbil_swift_const_CreateML_MLCreateErrorDomain()
    #expect(raw != nil)
    let domain = Unmanaged<NSString>.fromOpaque(raw!).takeRetainedValue() as String
    #expect(domain == "com.apple.CreateML")
}

/// The hermetic value box round-trips an arbitrary non-bridged Swift value and
/// the uniform free reclaims it.
@Test func opaqueValueBoxRoundTrips() {
    struct Pair { let a: Int; let b: String }
    let handle = awGerbilBox(Pair(a: 7, b: "x"))
    let back = awGerbilUnbox(handle, as: Pair.self)
    #expect(back.a == 7)
    #expect(back.b == "x")
    // The uniform free is exported under the C symbol `aw_gerbil_box_free`; its
    // Swift name is `awGerbilBoxFree`.
    awGerbilBoxFree(handle)
}

/// The throws bridge returns the body's value on success and the fallback (after
/// writing a retained `NSError *`) on throw.
@Test func throwsBridgeWritesErrorAndReturnsFallback() {
    enum E: Error { case boom }
    var cell: UnsafeMutableRawPointer? = nil
    let ok = withUnsafeMutablePointer(to: &cell) { p -> Int in
        awGerbilTry(UnsafeMutableRawPointer(p), -1) { 99 }
    }
    #expect(ok == 99)
    #expect(cell == nil)

    let fallback = withUnsafeMutablePointer(to: &cell) { p -> Int in
        awGerbilTry(UnsafeMutableRawPointer(p), -1) { throw E.boom }
    }
    #expect(fallback == -1)
    #expect(cell != nil)
    // Reclaim the +1-retained NSError the bridge wrote.
    if let e = cell { Unmanaged<NSError>.fromOpaque(e).release() }
}
