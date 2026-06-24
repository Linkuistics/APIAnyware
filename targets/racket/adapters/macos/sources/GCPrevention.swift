// GCPrevention.swift — Reference registry preventing GC collection of live callbacks.
//
// When Racket (or Chez/Gerbil) creates a C function pointer via its FFI,
// the underlying closure can be garbage-collected if the language runtime
// doesn't see any references to it. If ObjC holds that pointer (e.g., as
// a block invoke or delegate IMP), the GC'd pointer becomes a dangling
// reference -> crash.
//
// This module provides a simple registry: store a raw pointer with a handle,
// retrieve it later, and release when no longer needed.
//
// Note: this registry does NOT retain ObjC objects (no Unmanaged.retain).
// It stores raw pointer values to prevent the *language runtime's GC* from
// collecting the backing allocation. The caller manages ObjC refcounting
// separately via aw_racket_retain/aw_racket_release.
//
// Exports: aw_racket_prevent_gc, aw_racket_allow_gc, aw_racket_gc_count

import Foundation

// MARK: - Registry state

/// Lock protecting registry and nextHandle from concurrent access.
private nonisolated(unsafe) var gcLock = os_unfair_lock()

/// Maps handle -> stored pointer.
private nonisolated(unsafe) var registry: [Int64: UnsafeMutableRawPointer] = [:]

/// Next handle to assign.
private nonisolated(unsafe) var nextHandle: Int64 = 0

// MARK: - Public API

/// Register a pointer to prevent its backing memory from being GC'd.
///
/// Returns a handle that must be passed to `aw_racket_allow_gc` when the
/// pointer is no longer needed by ObjC.
///
/// The same pointer can be registered multiple times; each registration
/// returns a distinct handle and must be released independently.
@_cdecl("aw_racket_prevent_gc")
public func preventGC(_ pointer: UnsafeMutableRawPointer) -> Int64 {
    os_unfair_lock_lock(&gcLock)
    let handle = nextHandle
    nextHandle += 1
    registry[handle] = pointer
    os_unfair_lock_unlock(&gcLock)
    return handle
}

/// Release a previously registered GC-prevention handle.
///
/// After this call, the language runtime is free to collect the backing
/// allocation. Does nothing if the handle is not found.
@_cdecl("aw_racket_allow_gc")
public func allowGC(_ handle: Int64) {
    os_unfair_lock_lock(&gcLock)
    registry.removeValue(forKey: handle)
    os_unfair_lock_unlock(&gcLock)
}

/// Return the number of active GC-prevention entries. For testing/debugging.
@_cdecl("aw_racket_gc_count")
public func gcPreventionCount() -> Int64 {
    os_unfair_lock_lock(&gcLock)
    let count = Int64(registry.count)
    os_unfair_lock_unlock(&gcLock)
    return count
}
