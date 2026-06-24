// BlockBridge.swift — Create ObjC blocks from C function pointers.
//
// ObjC blocks on arm64 have this ABI layout:
//   struct Block_literal {
//     void *isa;            // _NSConcreteGlobalBlock (8 bytes)
//     int32 flags;          // BLOCK_HAS_COPY_DISPOSE  (4 bytes)
//     int32 reserved;       // 0                       (4 bytes)
//     void (*invoke)(...);  // C function pointer      (8 bytes)
//     void *descriptor;     // Block_descriptor ptr     (8 bytes)
//   };                      // Total: 32 bytes
//
//   struct Block_descriptor_with_helpers {
//     uint64 reserved;      // 0                       (8 bytes)
//     uint64 size;          // sizeof(Block_literal)    (8 bytes)
//     void (*copy_helper)(Block_literal *dst, Block_literal *src);
//     void (*dispose_helper)(Block_literal *src);
//   };                      // Total: 32 bytes
//
// The invoke function's first argument is always the block pointer itself:
//   return_type invoke(block_ptr, param1, param2, ...)
//
// Key design: We use _NSConcreteGlobalBlock (not Stack) because our blocks are
// heap-allocated with no captured state. Stack isa causes Block_copy to memcpy
// to a new location, invalidating the original pointer. Global isa tells the
// runtime the block is stable and Block_copy returns the same pointer.
//
// The BLOCK_HAS_COPY_DISPOSE flag (bit 25) causes the ObjC runtime to call
// our copy/dispose helpers. We maintain a per-block refcount in a dictionary.
// When refcount hits 0, the dispose helper calls allow_gc to release the
// GC prevention handle for the language-side callback.
//
// Exports: aw_racket_create_block, aw_racket_release_block

import Foundation

// MARK: - Block ABI constants

private let blockLiteralSize = 32
private let blockDescriptorWithHelpersSize = 32

// Offsets within Block_literal
private let isaOffset = 0
private let flagsOffset = 8
private let reservedOffset = 12
private let invokeOffset = 16
private let descriptorOffset = 24

// Block flags
private let blockHasCopyDispose: Int32 = 1 << 25

/// _NSConcreteGlobalBlock — the isa pointer for global blocks.
/// Our blocks are heap-allocated with no captures. Using global isa ensures
/// Block_copy returns the same pointer (no memcpy to a new location).
private nonisolated(unsafe) let nsConcreteGlobalBlock: UnsafeMutableRawPointer = {
    dlsym(UnsafeMutableRawPointer(bitPattern: -2)!, "_NSConcreteGlobalBlock")!
}()

// MARK: - Block refcount tracking

/// Lock protecting blockRefcounts.
private nonisolated(unsafe) var blockRefcountLock = os_unfair_lock()

/// Per-block refcount: maps block pointer (as Int) -> (refcount, gc_handle).
/// The gc_handle is from prevent_gc, called when the block is created.
private nonisolated(unsafe) var blockRefcounts: [Int: (refcount: Int, gcHandle: Int64)] = [:]

// MARK: - Copy/Dispose helpers

/// Copy helper: called by Block_copy. Increments our internal refcount.
/// Signature: void copy_helper(Block_literal *dst, Block_literal *src)
private let blockCopyHelper: @convention(c) (
    UnsafeMutableRawPointer, UnsafeMutableRawPointer
) -> Void = { dst, _ in
    let key = Int(bitPattern: dst)
    os_unfair_lock_lock(&blockRefcountLock)
    if var entry = blockRefcounts[key] {
        entry.refcount += 1
        blockRefcounts[key] = entry
    }
    os_unfair_lock_unlock(&blockRefcountLock)
}

/// Dispose helper: called by Block_release. Decrements refcount.
/// When refcount hits 0, calls allow_gc to release the GC prevention handle.
/// Signature: void dispose_helper(Block_literal *src)
private let blockDisposeHelper: @convention(c) (
    UnsafeMutableRawPointer
) -> Void = { src in
    let key = Int(bitPattern: src)
    os_unfair_lock_lock(&blockRefcountLock)
    guard var entry = blockRefcounts[key] else {
        os_unfair_lock_unlock(&blockRefcountLock)
        return
    }
    entry.refcount -= 1
    if entry.refcount <= 0 {
        let gcHandle = entry.gcHandle
        blockRefcounts.removeValue(forKey: key)
        os_unfair_lock_unlock(&blockRefcountLock)
        // Release GC prevention — callback can now be collected
        allowGC(gcHandle)
    } else {
        blockRefcounts[key] = entry
        os_unfair_lock_unlock(&blockRefcountLock)
    }
}

/// Shared block descriptor with copy/dispose helpers.
/// All our blocks have the same size and use the same helpers.
private nonisolated(unsafe) let sharedDescriptorWithHelpers: UnsafeMutableRawPointer = {
    let desc = UnsafeMutableRawPointer.allocate(
        byteCount: blockDescriptorWithHelpersSize, alignment: 8
    )
    // reserved = 0
    desc.storeBytes(of: UInt64(0), as: UInt64.self)
    // size = sizeof(Block_literal)
    desc.advanced(by: 8).storeBytes(of: UInt64(blockLiteralSize), as: UInt64.self)
    // copy_helper
    desc.advanced(by: 16).storeBytes(
        of: unsafeBitCast(blockCopyHelper, to: UnsafeMutableRawPointer.self),
        as: UnsafeMutableRawPointer.self
    )
    // dispose_helper
    desc.advanced(by: 24).storeBytes(
        of: unsafeBitCast(blockDisposeHelper, to: UnsafeMutableRawPointer.self),
        as: UnsafeMutableRawPointer.self
    )
    return desc
}()

// MARK: - Public API

/// Create an ObjC block wrapping a C function pointer.
///
/// The `invoke` parameter is a C function pointer with the block calling convention:
///   return_type invoke(block_ptr, param1, param2, ...)
/// The first argument will be the block pointer itself when ObjC invokes the block.
///
/// The block uses `_NSConcreteGlobalBlock` isa and `BLOCK_HAS_COPY_DISPOSE` flag,
/// enabling automatic lifecycle management via Block_copy/Block_release.
///
/// The GC prevention handle is managed automatically:
/// - `prevent_gc` is called during block creation
/// - `allow_gc` is called when the dispose helper fires (refcount -> 0)
///
/// For synchronous-only APIs (no Block_copy), call `aw_racket_release_block`
/// explicitly after the method returns.
///
/// Returns: pointer to the Block_literal struct, or nil on failure.
@_cdecl("aw_racket_create_block")
public func createBlock(_ invoke: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
    let block = UnsafeMutableRawPointer.allocate(byteCount: blockLiteralSize, alignment: 8)

    block.advanced(by: isaOffset).storeBytes(
        of: nsConcreteGlobalBlock, as: UnsafeMutableRawPointer.self
    )
    block.advanced(by: flagsOffset).storeBytes(of: blockHasCopyDispose, as: Int32.self)
    block.advanced(by: reservedOffset).storeBytes(of: Int32(0), as: Int32.self)
    block.advanced(by: invokeOffset).storeBytes(of: invoke, as: UnsafeMutableRawPointer.self)
    block.advanced(by: descriptorOffset).storeBytes(
        of: sharedDescriptorWithHelpers, as: UnsafeMutableRawPointer.self
    )

    // Register GC prevention for the callback
    let gcHandle = preventGC(invoke)

    // Initialize refcount tracking
    let key = Int(bitPattern: block)
    os_unfair_lock_lock(&blockRefcountLock)
    blockRefcounts[key] = (refcount: 0, gcHandle: gcHandle)
    os_unfair_lock_unlock(&blockRefcountLock)

    return block
}

/// Release a block created by `aw_racket_create_block`.
///
/// This is the explicit free path for synchronous-only block APIs where
/// ObjC does not call Block_copy (and thus the dispose helper never fires).
///
/// After this call, the block pointer is invalid and must not be used.
@_cdecl("aw_racket_release_block")
public func releaseBlock(_ block: UnsafeMutableRawPointer) {
    let key = Int(bitPattern: block)

    // Release GC prevention if we still own it
    os_unfair_lock_lock(&blockRefcountLock)
    let entry = blockRefcounts.removeValue(forKey: key)
    os_unfair_lock_unlock(&blockRefcountLock)

    if let entry = entry {
        allowGC(entry.gcHandle)
    }

    block.deallocate()
}
