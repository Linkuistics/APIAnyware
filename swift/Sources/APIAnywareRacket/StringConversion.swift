// StringConversion.swift — NSString <-> UTF-8 C string conversion.
// Exports: aw_racket_string_to_nsstring, aw_racket_nsstring_to_string

import Foundation

/// Convert a UTF-8 C string to an NSString. Returns a retained (+1) pointer.
/// The caller must release the returned object when done.
@_cdecl("aw_racket_string_to_nsstring")
public func stringToNSString(_ cString: UnsafePointer<CChar>) -> UnsafeMutableRawPointer {
    let nsString = NSString(utf8String: cString)!
    return Unmanaged.passRetained(nsString).toOpaque()
}

/// Convert an NSString to a UTF-8 C string. The returned pointer is valid
/// until the NSString is deallocated or the current autorelease pool drains.
/// The caller should copy the string if it needs to outlive these scopes.
/// Returns nil if the NSString cannot be represented as UTF-8.
///
/// Ownership (design §8 open item 1, settled by leaf 050/030): the result is
/// **+0/borrowed** — `-utf8String` is autoreleased, never freed by the caller.
/// The Racket seam reads it through ffi2's `string_t` (or `_string`), which
/// copies the bytes into a Racket string immediately and does not free the C
/// buffer. This is the contract every returned `string_t` in the binding obeys.
@_cdecl("aw_racket_nsstring_to_string")
public func nsstringToString(_ nsString: UnsafeMutableRawPointer) -> UnsafePointer<CChar>? {
    let str = Unmanaged<NSString>.fromOpaque(nsString).takeUnretainedValue()
    return str.utf8String
}

/// Get the length (number of UTF-16 code units) of an NSString.
@_cdecl("aw_racket_nsstring_length")
public func nsstringLength(_ nsString: UnsafeMutableRawPointer) -> UInt64 {
    let str = Unmanaged<NSString>.fromOpaque(nsString).takeUnretainedValue()
    return UInt64(str.length)
}
