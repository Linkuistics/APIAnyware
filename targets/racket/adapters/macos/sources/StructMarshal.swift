// StructMarshal.swift — Pack/unpack geometry structs for FFI transport.
//
// Each struct type has three exports:
//   aw_racket_pack_{type}   — write components into a byte buffer
//   aw_racket_unpack_{type} — read components from a byte buffer
//   aw_racket_sizeof_{type} — query buffer size needed
//
// Callers allocate a buffer of sizeof_{type} bytes, pass it to pack/unpack.
// Buffers must be aligned to 8 bytes (malloc satisfies this).

import Foundation

// MARK: - CGPoint (16 bytes: x, y as Double)

@_cdecl("aw_racket_pack_cgpoint")
public func packCGPoint(_ x: Double, _ y: Double, _ out: UnsafeMutableRawPointer) {
    out.storeBytes(of: CGPoint(x: x, y: y), as: CGPoint.self)
}

@_cdecl("aw_racket_unpack_cgpoint")
public func unpackCGPoint(
    _ bytes: UnsafeRawPointer,
    _ outX: UnsafeMutablePointer<Double>,
    _ outY: UnsafeMutablePointer<Double>
) {
    let point = bytes.load(as: CGPoint.self)
    outX.pointee = point.x
    outY.pointee = point.y
}

@_cdecl("aw_racket_sizeof_cgpoint")
public func sizeofCGPoint() -> Int { MemoryLayout<CGPoint>.size }

// MARK: - CGSize (16 bytes: width, height as Double)

@_cdecl("aw_racket_pack_cgsize")
public func packCGSize(_ width: Double, _ height: Double, _ out: UnsafeMutableRawPointer) {
    out.storeBytes(of: CGSize(width: width, height: height), as: CGSize.self)
}

@_cdecl("aw_racket_unpack_cgsize")
public func unpackCGSize(
    _ bytes: UnsafeRawPointer,
    _ outWidth: UnsafeMutablePointer<Double>,
    _ outHeight: UnsafeMutablePointer<Double>
) {
    let size = bytes.load(as: CGSize.self)
    outWidth.pointee = size.width
    outHeight.pointee = size.height
}

@_cdecl("aw_racket_sizeof_cgsize")
public func sizeofCGSize() -> Int { MemoryLayout<CGSize>.size }

// MARK: - CGRect (32 bytes: x, y, width, height as Double)

@_cdecl("aw_racket_pack_cgrect")
public func packCGRect(
    _ x: Double, _ y: Double, _ width: Double, _ height: Double,
    _ out: UnsafeMutableRawPointer
) {
    let rect = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
    out.storeBytes(of: rect, as: CGRect.self)
}

@_cdecl("aw_racket_unpack_cgrect")
public func unpackCGRect(
    _ bytes: UnsafeRawPointer,
    _ outX: UnsafeMutablePointer<Double>,
    _ outY: UnsafeMutablePointer<Double>,
    _ outWidth: UnsafeMutablePointer<Double>,
    _ outHeight: UnsafeMutablePointer<Double>
) {
    let rect = bytes.load(as: CGRect.self)
    outX.pointee = rect.origin.x
    outY.pointee = rect.origin.y
    outWidth.pointee = rect.size.width
    outHeight.pointee = rect.size.height
}

@_cdecl("aw_racket_sizeof_cgrect")
public func sizeofCGRect() -> Int { MemoryLayout<CGRect>.size }

// MARK: - NSRange (16 bytes: location, length as UInt64)

@_cdecl("aw_racket_pack_nsrange")
public func packNSRange(_ location: UInt64, _ length: UInt64, _ out: UnsafeMutableRawPointer) {
    out.storeBytes(of: NSMakeRange(Int(location), Int(length)), as: NSRange.self)
}

@_cdecl("aw_racket_unpack_nsrange")
public func unpackNSRange(
    _ bytes: UnsafeRawPointer,
    _ outLocation: UnsafeMutablePointer<UInt64>,
    _ outLength: UnsafeMutablePointer<UInt64>
) {
    let range = bytes.load(as: NSRange.self)
    outLocation.pointee = UInt64(range.location)
    outLength.pointee = UInt64(range.length)
}

@_cdecl("aw_racket_sizeof_nsrange")
public func sizeofNSRange() -> Int { MemoryLayout<NSRange>.size }

// MARK: - NSEdgeInsets (32 bytes: top, left, bottom, right as Double)

@_cdecl("aw_racket_pack_nsedgeinsets")
public func packNSEdgeInsets(
    _ top: Double, _ left: Double, _ bottom: Double, _ right: Double,
    _ out: UnsafeMutableRawPointer
) {
    out.storeBytes(
        of: NSEdgeInsets(top: top, left: left, bottom: bottom, right: right),
        as: NSEdgeInsets.self
    )
}

@_cdecl("aw_racket_unpack_nsedgeinsets")
public func unpackNSEdgeInsets(
    _ bytes: UnsafeRawPointer,
    _ outTop: UnsafeMutablePointer<Double>,
    _ outLeft: UnsafeMutablePointer<Double>,
    _ outBottom: UnsafeMutablePointer<Double>,
    _ outRight: UnsafeMutablePointer<Double>
) {
    let insets = bytes.load(as: NSEdgeInsets.self)
    outTop.pointee = insets.top
    outLeft.pointee = insets.left
    outBottom.pointee = insets.bottom
    outRight.pointee = insets.right
}

@_cdecl("aw_racket_sizeof_nsedgeinsets")
public func sizeofNSEdgeInsets() -> Int { MemoryLayout<NSEdgeInsets>.size }
