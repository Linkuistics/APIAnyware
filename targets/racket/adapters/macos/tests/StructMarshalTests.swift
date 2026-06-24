import Testing
import Foundation
@testable import APIAnywareRacket

// MARK: - CGPoint

@Test func packUnpackCGPoint() {
    var buf = [UInt8](repeating: 0, count: sizeofCGPoint())
    packCGPoint(10.5, 20.5, &buf)
    var x = 0.0, y = 0.0
    unpackCGPoint(&buf, &x, &y)
    #expect(x == 10.5)
    #expect(y == 20.5)
}

@Test func sizeofCGPointIs16() {
    #expect(sizeofCGPoint() == 16)
}

// MARK: - CGSize

@Test func packUnpackCGSize() {
    var buf = [UInt8](repeating: 0, count: sizeofCGSize())
    packCGSize(100.0, 200.0, &buf)
    var w = 0.0, h = 0.0
    unpackCGSize(&buf, &w, &h)
    #expect(w == 100.0)
    #expect(h == 200.0)
}

@Test func sizeofCGSizeIs16() {
    #expect(sizeofCGSize() == 16)
}

// MARK: - CGRect

@Test func packUnpackCGRect() {
    var buf = [UInt8](repeating: 0, count: sizeofCGRect())
    packCGRect(10.0, 20.0, 300.0, 400.0, &buf)
    var x = 0.0, y = 0.0, w = 0.0, h = 0.0
    unpackCGRect(&buf, &x, &y, &w, &h)
    #expect(x == 10.0)
    #expect(y == 20.0)
    #expect(w == 300.0)
    #expect(h == 400.0)
}

@Test func sizeofCGRectIs32() {
    #expect(sizeofCGRect() == 32)
}

// MARK: - NSRange

@Test func packUnpackNSRange() {
    var buf = [UInt8](repeating: 0, count: sizeofNSRange())
    packNSRange(5, 10, &buf)
    var loc: UInt64 = 0, len: UInt64 = 0
    unpackNSRange(&buf, &loc, &len)
    #expect(loc == 5)
    #expect(len == 10)
}

@Test func sizeofNSRangeIs16() {
    #expect(sizeofNSRange() == 16)
}

// MARK: - NSEdgeInsets

@Test func packUnpackNSEdgeInsets() {
    var buf = [UInt8](repeating: 0, count: sizeofNSEdgeInsets())
    packNSEdgeInsets(1.0, 2.0, 3.0, 4.0, &buf)
    var top = 0.0, left = 0.0, bottom = 0.0, right = 0.0
    unpackNSEdgeInsets(&buf, &top, &left, &bottom, &right)
    #expect(top == 1.0)
    #expect(left == 2.0)
    #expect(bottom == 3.0)
    #expect(right == 4.0)
}

@Test func sizeofNSEdgeInsetsIs32() {
    #expect(sizeofNSEdgeInsets() == 32)
}

// MARK: - Raw byte layout verification

@Test func cgPointMatchesMemoryLayout() {
    #expect(sizeofCGPoint() == MemoryLayout<CGPoint>.size)
}

@Test func cgRectMatchesMemoryLayout() {
    #expect(sizeofCGRect() == MemoryLayout<CGRect>.size)
}

@Test func nsRangeMatchesMemoryLayout() {
    #expect(sizeofNSRange() == MemoryLayout<NSRange>.size)
}
