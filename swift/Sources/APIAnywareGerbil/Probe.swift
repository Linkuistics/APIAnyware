// Probe.swift — DISPOSABLE build-integration probe (grove leaf 070/010).
//
// This file's ONLY job is to prove the ADR-0029 build path end-to-end before any
// trampoline codegen exists: that a Swift `@_cdecl` compiled into
// `libAPIAnywareGerbil.dylib` resolves and runs when a gerbil exe links
// `-lAPIAnywareGerbil` and the bundled `.app` relocates the dylib (ADR-0009
// self-containment). Leaf 070/020 generates the real `Generated/Trampolines.swift`
// entries and DELETES this file — keep it minimal and hand-written.
//
// Two probes, escalating in evidence:
//   aw_gerbil_probe         — pure link/load proof: returns a known Int with no
//                             framework or Swift-runtime dependency beyond cdecl.
//   aw_gerbil_probe_domain  — Swift-ABI + framework proof: reaches a real
//                             Swift-native constant (CreateML's error domain, a
//                             070 §6a exemplar) through the dylib and bridges it
//                             to a C string the gerbil seam can read.

import Foundation
import CreateML

/// Pure link/load probe: a known constant, no framework call. If a gerbil exe
/// can call this through `-lAPIAnywareGerbil`, the dylib resolved and loaded.
@_cdecl("aw_gerbil_probe")
public func aw_gerbil_probe() -> Int {
    42
}

/// Swift-ABI probe: read CreateML's Swift-native error-domain constant and hand
/// it back as a heap-allocated C string (caller frees with `aw_gerbil_probe_free`).
/// Proves the dylib can reach a genuine Swift-native framework symbol — the thing
/// `gsc` structurally cannot do — and marshal it across the flat C ABI.
@_cdecl("aw_gerbil_probe_domain")
public func aw_gerbil_probe_domain() -> UnsafeMutablePointer<CChar>? {
    strdup(MLCreateErrorDomain)
}

/// Free a C string returned by `aw_gerbil_probe_domain`.
@_cdecl("aw_gerbil_probe_free")
public func aw_gerbil_probe_free(_ p: UnsafeMutablePointer<CChar>?) {
    free(p)
}
