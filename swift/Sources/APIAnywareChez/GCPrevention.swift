// GCPrevention.swift — Reference registry for the Swift-side dylib.
//
// Decision (leaf 050/060): Chez Scheme's `lock-object` already prevents the
// foreign-callable code object from being collected on the Scheme side, so
// the Scheme runtime does not need to call into this registry. However, the
// Swift-side BlockBridge needs a per-block handle that is released
// asynchronously by the ObjC dispose helper — so a registry is still
// required, just driven entirely from Swift internals.
//
// The @_cdecl exports are kept for parity with APIAnywareRacket — they are
// free to ship and let later targets (gerbil, etc.) opt in without
// re-implementing the machinery. The chez runtime itself does not link
// against them.
//
// Exports: aw_chez_prevent_gc, aw_chez_allow_gc, aw_chez_gc_count

import Foundation

private nonisolated(unsafe) var gcLock = os_unfair_lock()
private nonisolated(unsafe) var registry: [Int64: UnsafeMutableRawPointer] = [:]
private nonisolated(unsafe) var nextHandle: Int64 = 0

/// Register a pointer to prevent its backing memory from being released.
/// Returns a handle that must be passed to `aw_chez_allow_gc`.
@_cdecl("aw_chez_prevent_gc")
public func chezPreventGC(_ pointer: UnsafeMutableRawPointer) -> Int64 {
    os_unfair_lock_lock(&gcLock)
    let handle = nextHandle
    nextHandle += 1
    registry[handle] = pointer
    os_unfair_lock_unlock(&gcLock)
    return handle
}

/// Release a previously registered handle. No-op if the handle is unknown.
@_cdecl("aw_chez_allow_gc")
public func chezAllowGC(_ handle: Int64) {
    os_unfair_lock_lock(&gcLock)
    registry.removeValue(forKey: handle)
    os_unfair_lock_unlock(&gcLock)
}

/// Number of active prevent-gc entries. For testing/debugging.
@_cdecl("aw_chez_gc_count")
public func chezGCPreventionCount() -> Int64 {
    os_unfair_lock_lock(&gcLock)
    let count = Int64(registry.count)
    os_unfair_lock_unlock(&gcLock)
    return count
}
