// ChezRuntime.swift — chez target's self-contained ObjC runtime primitives.
//
// Absorbed from the former APIAnywareCommon (ADR-0011, hermetic isolation):
// the four files chez actually used — ClassLookup, MemoryManagement,
// AutoreleasePool, StringConversion — folded into one file and re-exported
// under chez's own `aw_chez_*` ABI prefix (honest hermetic naming; matches
// the existing `aw_chez_create_block` family). Chez never used MessageSend /
// StructMarshal / ObservationBridge, so they were not carried.
//
// These `@_cdecl` symbols are what `(apianyware runtime ffi)`'s
// `foreign-procedure`s resolve out of libAPIAnywareChez.dylib.

import Foundation

// MARK: - ClassLookup — ObjC class and selector lookup.

/// Look up an ObjC class by name. Returns nil if the class is not loaded.
@_cdecl("aw_chez_get_class")
public func getClass(_ name: UnsafePointer<CChar>) -> UnsafeMutableRawPointer? {
    guard let cls = NSClassFromString(String(cString: name)) else { return nil }
    return Unmanaged.passUnretained(cls as AnyObject).toOpaque()
}

/// Register (or look up) an ObjC selector by name. Always succeeds.
@_cdecl("aw_chez_sel_register")
public func registerSelector(_ name: UnsafePointer<CChar>) -> UnsafeMutableRawPointer {
    unsafeBitCast(sel_registerName(name), to: UnsafeMutableRawPointer.self)
}

// MARK: - MemoryManagement — ObjC reference counting: retain and release.

/// Retain an ObjC object (+1 ref count). Returns the same pointer for chaining.
@_cdecl("aw_chez_retain")
public func retainObject(_ object: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {
    _ = Unmanaged<AnyObject>.fromOpaque(object).retain()
    return object
}

/// Release an ObjC object (-1 ref count). The pointer may become invalid.
@_cdecl("aw_chez_release")
public func releaseObject(_ object: UnsafeMutableRawPointer) {
    Unmanaged<AnyObject>.fromOpaque(object).release()
}

// MARK: - AutoreleasePool — push/pop via ObjC runtime.

@_silgen_name("objc_autoreleasePoolPush")
private func _autoreleasePoolPush() -> UnsafeMutableRawPointer

@_silgen_name("objc_autoreleasePoolPop")
private func _autoreleasePoolPop(_ pool: UnsafeMutableRawPointer)

/// Push a new autorelease pool. Returns an opaque token to pass to pop.
@_cdecl("aw_chez_autorelease_push")
public func autoreleasePoolPush() -> UnsafeMutableRawPointer {
    _autoreleasePoolPush()
}

/// Pop (drain) an autorelease pool. All objects autoreleased since the
/// matching push are released.
@_cdecl("aw_chez_autorelease_pop")
public func autoreleasePoolPop(_ pool: UnsafeMutableRawPointer) {
    _autoreleasePoolPop(pool)
}

// MARK: - StringConversion — NSString <-> UTF-8 C string conversion.

/// Convert a UTF-8 C string to an NSString. Returns a retained (+1) pointer.
/// The caller must release the returned object when done.
@_cdecl("aw_chez_string_to_nsstring")
public func stringToNSString(_ cString: UnsafePointer<CChar>) -> UnsafeMutableRawPointer {
    let nsString = NSString(utf8String: cString)!
    return Unmanaged.passRetained(nsString).toOpaque()
}

/// Convert an NSString to a UTF-8 C string. The returned pointer is valid
/// until the NSString is deallocated or the current autorelease pool drains.
/// The caller should copy the string if it needs to outlive these scopes.
/// Returns nil if the NSString cannot be represented as UTF-8.
@_cdecl("aw_chez_nsstring_to_string")
public func nsstringToString(_ nsString: UnsafeMutableRawPointer) -> UnsafePointer<CChar>? {
    let str = Unmanaged<NSString>.fromOpaque(nsString).takeUnretainedValue()
    return str.utf8String
}

/// Get the length (number of UTF-16 code units) of an NSString.
@_cdecl("aw_chez_nsstring_length")
public func nsstringLength(_ nsString: UnsafeMutableRawPointer) -> UInt64 {
    let str = Unmanaged<NSString>.fromOpaque(nsString).takeUnretainedValue()
    return UInt64(str.length)
}
