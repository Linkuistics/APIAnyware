// BlockBridge.swift — Create ObjC blocks from C function pointers.
//
// Chez Scheme produces C-callable entry points via `foreign-callable` +
// `foreign-callable-entry-point`. The pointer this yields is a plain C
// function pointer with the block-invoke calling convention
// (block_ptr, arg1, arg2, ...) — structurally identical to what Racket's
// `_cprocedure` produces. The block ABI machinery is therefore identical
// to APIAnywareRacket/BlockBridge.swift; only the exported symbol names
// and the prevent_gc target dylib differ.
//
// Layout (arm64, see APIAnywareRacket/BlockBridge.swift for full detail):
//   Block_literal       = { isa(8), flags(4), reserved(4), invoke(8), descriptor(8) } = 32
//   Block_descriptor_1  = { reserved(8), size(8), copy_helper(8), dispose_helper(8) } = 32
//
// We use _NSConcreteGlobalBlock (Block_copy returns the same pointer —
// no memcpy invalidating the original) and set BLOCK_HAS_COPY_DISPOSE so
// the ObjC runtime drives our copy/dispose helpers for refcounting.
// When the dispose helper drives refcount to 0, we call allow_gc to
// release the chez-side GC-prevention handle for the foreign-callable.
//
// Exports: aw_chez_create_block, aw_chez_release_block

import Foundation

// MARK: - Block ABI constants

private let blockLiteralSize = 32
private let blockDescriptorWithHelpersSize = 32

private let isaOffset = 0
private let flagsOffset = 8
private let reservedOffset = 12
private let invokeOffset = 16
private let descriptorOffset = 24

private let blockHasCopyDispose: Int32 = 1 << 25

private nonisolated(unsafe) let nsConcreteGlobalBlock: UnsafeMutableRawPointer = {
    dlsym(UnsafeMutableRawPointer(bitPattern: -2)!, "_NSConcreteGlobalBlock")!
}()

// MARK: - Block refcount tracking

private nonisolated(unsafe) var blockRefcountLock = os_unfair_lock()

private nonisolated(unsafe) var blockRefcounts: [Int: (refcount: Int, gcHandle: Int64)] = [:]

// MARK: - Copy/Dispose helpers

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
        chezAllowGC(gcHandle)
    } else {
        blockRefcounts[key] = entry
        os_unfair_lock_unlock(&blockRefcountLock)
    }
}

private nonisolated(unsafe) let sharedDescriptorWithHelpers: UnsafeMutableRawPointer = {
    let desc = UnsafeMutableRawPointer.allocate(
        byteCount: blockDescriptorWithHelpersSize, alignment: 8
    )
    desc.storeBytes(of: UInt64(0), as: UInt64.self)
    desc.advanced(by: 8).storeBytes(of: UInt64(blockLiteralSize), as: UInt64.self)
    desc.advanced(by: 16).storeBytes(
        of: unsafeBitCast(blockCopyHelper, to: UnsafeMutableRawPointer.self),
        as: UnsafeMutableRawPointer.self
    )
    desc.advanced(by: 24).storeBytes(
        of: unsafeBitCast(blockDisposeHelper, to: UnsafeMutableRawPointer.self),
        as: UnsafeMutableRawPointer.self
    )
    return desc
}()

// MARK: - Public API

/// Create an ObjC block wrapping a C function pointer obtained from
/// Chez's `foreign-callable-entry-point`.
///
/// The block uses `_NSConcreteGlobalBlock` isa + `BLOCK_HAS_COPY_DISPOSE`,
/// enabling automatic lifecycle management. We register a GC-prevention
/// handle on `invoke` so the Swift side can hold a stable pointer until
/// the dispose helper fires; the chez side independently keeps its
/// foreign-callable code object locked via `lock-object` (dispatch.sls).
///
/// For synchronous-only APIs (no Block_copy), the caller invokes
/// `aw_chez_release_block` explicitly after the method returns.
@_cdecl("aw_chez_create_block")
public func chezCreateBlock(_ invoke: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
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

    let gcHandle = chezPreventGC(invoke)

    let key = Int(bitPattern: block)
    os_unfair_lock_lock(&blockRefcountLock)
    blockRefcounts[key] = (refcount: 0, gcHandle: gcHandle)
    os_unfair_lock_unlock(&blockRefcountLock)

    return block
}

/// Release a block created by `aw_chez_create_block`. Idempotent-ish:
/// if the dispose helper has already fired, this is a no-op on the GC
/// side and just deallocates the block literal storage.
@_cdecl("aw_chez_release_block")
public func chezReleaseBlock(_ block: UnsafeMutableRawPointer) {
    let key = Int(bitPattern: block)

    os_unfair_lock_lock(&blockRefcountLock)
    let entry = blockRefcounts.removeValue(forKey: key)
    os_unfair_lock_unlock(&blockRefcountLock)

    if let entry = entry {
        chezAllowGC(entry.gcHandle)
    }

    block.deallocate()
}
