// ClassLookup.swift — ObjC class and selector lookup.
// Exports: aw_racket_get_class, aw_racket_sel_register

import Foundation

/// Look up an ObjC class by name. Returns nil if the class is not loaded.
@_cdecl("aw_racket_get_class")
public func getClass(_ name: UnsafePointer<CChar>) -> UnsafeMutableRawPointer? {
    guard let cls = NSClassFromString(String(cString: name)) else { return nil }
    return Unmanaged.passUnretained(cls as AnyObject).toOpaque()
}

/// Register (or look up) an ObjC selector by name. Always succeeds.
@_cdecl("aw_racket_sel_register")
public func registerSelector(_ name: UnsafePointer<CChar>) -> UnsafeMutableRawPointer {
    unsafeBitCast(sel_registerName(name), to: UnsafeMutableRawPointer.self)
}
