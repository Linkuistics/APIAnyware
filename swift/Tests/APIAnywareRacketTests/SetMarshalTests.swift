import Testing
import Foundation
@testable import APIAnywareRacket

// Set ⇄ NSSet bridge (CollectionMarshal.swift, added leaf 040/010). Mirrors the
// NSArray tests' shape; verifies the +1/unretained ownership contract, dedup,
// and nil-skipping.

/// Run `body` with the NSSet built from `items`, then release the +1 set.
private func withNSSet(
    _ items: [UnsafeMutableRawPointer?],
    _ body: (UnsafeMutableRawPointer) -> Void
) {
    let setPtr = items.withUnsafeBufferPointer { listToNSSet($0.baseAddress, $0.count) }
    body(setPtr)
    Unmanaged<NSSet>.fromOpaque(setPtr).release()
}

/// Read all elements back as Swift strings (the elements are NSStrings here).
private func readBackStrings(_ setPtr: UnsafeMutableRawPointer) -> Set<String> {
    let n = nssetCount(setPtr)
    var out = [UnsafeMutableRawPointer?](repeating: nil, count: n)
    out.withUnsafeMutableBufferPointer { buf in
        if let base = buf.baseAddress { nssetGetAll(setPtr, buf.count, base) }
    }
    return Set(out.compactMap { $0 }.map {
        Unmanaged<NSString>.fromOpaque($0).takeUnretainedValue() as String
    })
}

@Test func listToNSSetRoundTrip() {
    let a = "x" as NSString, b = "y" as NSString
    withExtendedLifetime((a, b)) {
        let pa = Unmanaged.passUnretained(a).toOpaque()
        let pb = Unmanaged.passUnretained(b).toOpaque()
        withNSSet([pa, pb]) { setPtr in
            #expect(nssetCount(setPtr) == 2)
            #expect(readBackStrings(setPtr) == ["x", "y"])
        }
    }
}

@Test func listToNSSetDeduplicates() {
    let a = "dup" as NSString
    withExtendedLifetime(a) {
        let pa = Unmanaged.passUnretained(a).toOpaque()
        withNSSet([pa, pa, pa]) { setPtr in
            #expect(nssetCount(setPtr) == 1)
            #expect(readBackStrings(setPtr) == ["dup"])
        }
    }
}

@Test func listToNSSetSkipsNilSlots() {
    let a = "p" as NSString, b = "q" as NSString
    withExtendedLifetime((a, b)) {
        let pa = Unmanaged.passUnretained(a).toOpaque()
        let pb = Unmanaged.passUnretained(b).toOpaque()
        withNSSet([pa, nil, pb]) { setPtr in
            #expect(nssetCount(setPtr) == 2)
        }
    }
}

@Test func emptyListGivesEmptySet() {
    withNSSet([]) { setPtr in
        #expect(nssetCount(setPtr) == 0)
        #expect(readBackStrings(setPtr).isEmpty)
    }
}

@Test func getAllClampsToBufferCount() {
    let a = "a" as NSString, b = "b" as NSString, c = "c" as NSString
    withExtendedLifetime((a, b, c)) {
        let ps = [a, b, c].map { Unmanaged.passUnretained($0).toOpaque() as UnsafeMutableRawPointer? }
        withNSSet(ps) { setPtr in
            #expect(nssetCount(setPtr) == 3)
            // Ask for fewer than present — must not overflow the buffer.
            var out = [UnsafeMutableRawPointer?](repeating: nil, count: 2)
            out.withUnsafeMutableBufferPointer { buf in
                nssetGetAll(setPtr, buf.count, buf.baseAddress!)
            }
            #expect(out.compactMap { $0 }.count == 2)
        }
    }
}
