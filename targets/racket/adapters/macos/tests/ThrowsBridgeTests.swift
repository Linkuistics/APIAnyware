import Testing
import Foundation
@testable import APIAnywareRacket

// `throws` → NSError out-param bridge (ThrowsBridge.swift). The trampoline writes
// a +1-retained NSError* through a trailing out-buffer, exactly as the generated
// dispatch table does; these verify that contract directly.

/// Allocate a fresh `NSError **`-shaped out cell, run `body` with it, and free
/// the cell. The cell starts nil.
private func withErrorCell(_ body: (UnsafeMutableRawPointer, _ read: () -> UnsafeMutableRawPointer?) -> Void) {
    let cell = UnsafeMutablePointer<UnsafeMutableRawPointer?>.allocate(capacity: 1)
    cell.initialize(to: nil)
    defer { cell.deinitialize(count: 1); cell.deallocate() }
    body(UnsafeMutableRawPointer(cell), { cell.pointee })
}

@Test func writeErrorStoresRetainedNSError() {
    withErrorCell { out, read in
        awRacketWriteError(out, NSError(domain: "AwTest", code: 7))
        let stored = read()
        #expect(stored != nil)
        // takeRetainedValue consumes the +1 the bridge added — balances it.
        let err = Unmanaged<NSError>.fromOpaque(stored!).takeRetainedValue()
        #expect(err.domain == "AwTest")
        #expect(err.code == 7)
    }
}

@Test func writeErrorNilBufferIsNoOp() {
    // A caller that did not ask for the error passes nil; must not crash.
    awRacketWriteError(nil, NSError(domain: "AwTest", code: 1))
}

@Test func tryReturnsValueOnSuccess() {
    withErrorCell { out, read in
        let r = awRacketTry(out, -1) { 42 }
        #expect(r == 42)
        #expect(read() == nil) // no error written on the success path
    }
}

@Test func tryWritesErrorAndReturnsFallbackOnThrow() {
    struct Boom: Error {}
    withErrorCell { out, read in
        let r = awRacketTry(out, -1) { () throws -> Int in throw Boom() }
        #expect(r == -1) // fallback
        let stored = read()
        #expect(stored != nil)
        let err = Unmanaged<NSError>.fromOpaque(stored!).takeRetainedValue()
        // A Swift error bridged to NSError carries a non-empty domain + code.
        #expect(!err.domain.isEmpty)
    }
}

@Test func tryWithPointerFallbackReturnsNilOnThrow() {
    struct Boom: Error {}
    withErrorCell { out, read in
        let r: UnsafeMutableRawPointer? = awRacketTry(out, nil) {
            () throws -> UnsafeMutableRawPointer? in throw Boom()
        }
        #expect(r == nil)
        let stored = read()
        #expect(stored != nil)
        _ = Unmanaged<NSError>.fromOpaque(stored!).takeRetainedValue() // balance +1
    }
}
