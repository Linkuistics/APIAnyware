import Testing
import Foundation
@testable import APIAnywareRacket

// MARK: - Block creation and invocation tests

/// Test helper: a C function that matches ObjC block invoke signature.
/// Block invoke convention: (block_ptr, params...) -> return
/// This one takes (block_ptr) -> void, i.e. a void block with no params.
private let voidBlockInvoke: @convention(c) (UnsafeMutableRawPointer) -> Void = { _ in
    voidBlockCallCount += 1
}
private nonisolated(unsafe) var voidBlockCallCount: Int = 0

/// Block invoke: (block_ptr, id) -> void — one-arg void block.
private let voidBlock1Invoke: @convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer?) -> Void = { _, arg in
    lastReceivedArg = arg
}
private nonisolated(unsafe) var lastReceivedArg: UnsafeMutableRawPointer? = nil

/// Block invoke: (block_ptr) -> UnsafeMutableRawPointer? — returns an id.
private let idBlockInvoke: @convention(c) (UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? = { blockSelf in
    return blockSelf
}

// Nested under RacketBridgeSuites so the whole Racket-bridge group runs
// serially — see RacketBridgeSuites.swift. Without it, `invokeBlock` and
// `multipleBlocks` race on the file-global `voidBlockCallCount`.
extension RacketBridgeSuites {

@Suite("BlockBridge")
struct BlockBridgeTests {

    @Test("Create and release a block")
    func createAndRelease() {
        let invokePtr = unsafeBitCast(voidBlockInvoke, to: UnsafeMutableRawPointer.self)
        let block = createBlock(invokePtr)
        #expect(block != nil, "Block creation should return non-nil")
        releaseBlock(block!)
    }

    @Test("Block can be invoked as a C function")
    func invokeBlock() {
        voidBlockCallCount = 0
        let invokePtr = unsafeBitCast(voidBlockInvoke, to: UnsafeMutableRawPointer.self)
        let block = createBlock(invokePtr)!

        // The block's invoke field is at offset 16 (after isa:8, flags:4, reserved:4)
        let invokeFieldPtr = block.advanced(by: 16).load(as: UnsafeMutableRawPointer.self)
        let invoke = unsafeBitCast(invokeFieldPtr, to: (@convention(c) (UnsafeMutableRawPointer) -> Void).self)
        invoke(block)

        #expect(voidBlockCallCount == 1, "Block invoke should have been called once")

        releaseBlock(block)
    }

    @Test("Block passes arguments through")
    func blockPassesArguments() {
        let invokePtr = unsafeBitCast(voidBlock1Invoke, to: UnsafeMutableRawPointer.self)
        let block = createBlock(invokePtr)!

        let str = ("test" as NSString)
        let strPtr = Unmanaged.passUnretained(str).toOpaque()

        lastReceivedArg = nil
        let invokeFieldPtr = block.advanced(by: 16).load(as: UnsafeMutableRawPointer.self)
        let invoke = unsafeBitCast(invokeFieldPtr,
            to: (@convention(c) (UnsafeMutableRawPointer, UnsafeMutableRawPointer?) -> Void).self)
        invoke(block, strPtr)

        #expect(lastReceivedArg == strPtr, "Block should receive the argument")

        releaseBlock(block)
    }

    @Test("Block with id return type")
    func blockReturnsId() {
        let invokePtr = unsafeBitCast(idBlockInvoke, to: UnsafeMutableRawPointer.self)
        let block = createBlock(invokePtr)!

        let invokeFieldPtr = block.advanced(by: 16).load(as: UnsafeMutableRawPointer.self)
        let invoke = unsafeBitCast(invokeFieldPtr,
            to: (@convention(c) (UnsafeMutableRawPointer) -> UnsafeMutableRawPointer?).self)
        let result = invoke(block)

        #expect(result == block, "Block should return its own pointer as sentinel")

        releaseBlock(block)
    }

    @Test("Block uses _NSConcreteGlobalBlock isa")
    func blockUsesGlobalBlockIsa() {
        let invokePtr = unsafeBitCast(voidBlockInvoke, to: UnsafeMutableRawPointer.self)
        let block = createBlock(invokePtr)!

        // isa is at offset 0
        let isa = block.load(as: UnsafeMutableRawPointer.self)
        let expectedIsa = dlsym(UnsafeMutableRawPointer(bitPattern: -2)!, "_NSConcreteGlobalBlock")!
        #expect(isa == expectedIsa, "Block isa should be _NSConcreteGlobalBlock")

        releaseBlock(block)
    }

    @Test("Block has BLOCK_HAS_COPY_DISPOSE flag")
    func blockHasCopyDisposeFlag() {
        let invokePtr = unsafeBitCast(voidBlockInvoke, to: UnsafeMutableRawPointer.self)
        let block = createBlock(invokePtr)!

        // flags at offset 8
        let flags = block.advanced(by: 8).load(as: Int32.self)
        let expectedFlag: Int32 = 1 << 25
        #expect(flags & expectedFlag != 0, "Block flags should include BLOCK_HAS_COPY_DISPOSE")

        releaseBlock(block)
    }

    @Test("Block create registers GC prevention, release frees it")
    func blockGCLifecycle() {
        let invokePtr = unsafeBitCast(voidBlockInvoke, to: UnsafeMutableRawPointer.self)
        let beforeCreate = gcPreventionCount()

        let block = createBlock(invokePtr)!
        let afterCreate = gcPreventionCount()
        #expect(afterCreate > beforeCreate, "createBlock should register GC prevention")

        let beforeRelease = gcPreventionCount()
        releaseBlock(block)
        let afterRelease = gcPreventionCount()
        #expect(afterRelease < beforeRelease, "releaseBlock should free GC prevention")
    }

    @Test("Multiple blocks are independent")
    func multipleBlocks() {
        let invokePtr = unsafeBitCast(voidBlockInvoke, to: UnsafeMutableRawPointer.self)
        let block1 = createBlock(invokePtr)!
        let block2 = createBlock(invokePtr)!

        #expect(block1 != block2, "Each block should be a distinct allocation")

        // Invoke block1 only, check that count increments by exactly 1
        let before = voidBlockCallCount
        let invoke1Ptr = block1.advanced(by: 16).load(as: UnsafeMutableRawPointer.self)
        let invoke1 = unsafeBitCast(invoke1Ptr, to: (@convention(c) (UnsafeMutableRawPointer) -> Void).self)
        invoke1(block1)

        #expect(voidBlockCallCount == before + 1)

        releaseBlock(block1)
        releaseBlock(block2)
    }
}

}
