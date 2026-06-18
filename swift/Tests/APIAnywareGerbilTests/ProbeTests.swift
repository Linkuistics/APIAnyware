import Testing
import Foundation
@testable import APIAnywareGerbil

// Disposable probe tests (grove leaf 070/010). Deleted with Probe.swift in 020.

@Test func probeReturnsKnownConstant() {
    #expect(aw_gerbil_probe() == 42)
}

@Test func probeDomainBridgesCreateMLConstant() {
    let p = aw_gerbil_probe_domain()
    #expect(p != nil)
    defer { aw_gerbil_probe_free(p) }
    #expect(String(cString: p!) == "com.apple.CreateML")
}
