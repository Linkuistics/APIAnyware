// BlockBridge.swift — a Lisp closure projected as an ObjC block, with the
// foreign-thread → main-thread bounce in the block body (ADR-0035, leaf 050/060).
//
// ## Why the block maker lives HERE (not in Lisp, unlike the rest of `aw-block`)
//
// SBCL cannot author an ObjC block: a block is a clang `^`-literal ABI object, and
// SBCL compiles neither ObjC nor C inline. So — exactly as the MOP object model stays
// in Lisp but the *native* concerns converge in the dylib (ADR-0038 §1) — the block
// FACTORY is native here, while the closure registry + dispatch live Lisp-side
// (`threading.lisp`). This is the SBCL analogue of gerbil's `native_block.c` block
// makers; gerbil kept them in its ObjC-in-`gsc` home, SBCL has none, so they land in
// the sole native unit.
//
// ## ONE universal block, not gerbil's four return-kind makers
//
// gerbil's emitter hands `make-objc-block` the block's FFI tokens, so it picks one of
// `aw_make_block_{void,id,bool,long}` and coerces per-arg. The SBCL emitter emits a
// token-less `(aw-block <closure>)` (it carries no signature to the call site) — so a
// single universal block must serve EVERY bridgeable signature. The arm64 ABI makes
// that exact: every bridgeable block slot is integer-class (a pointer, a `BOOL`, an
// `NSUInteger`/`NSInteger`, an `NSComparisonResult`), and integer-class args/results all
// travel in the general registers (x0–x7; result in x0). So one prototype
// `(void*, void*, void*) -> void*` is ABI-correct for all of them — the block-side twin
// of SubclassSynth's "one NSInvocation trampoline, not per-signature codegen". A block
// the framework calls with fewer than three args simply leaves the upper registers
// unread; a `void`-returning block leaves x0 unread. (The emitter's
// `is_bridgeable_block` already excludes the cases this prototype could NOT carry —
// by-value structs and `c-string` — so an un-bridgeable block keeps its method
// deferred and never reaches here.)
//
// ## The bounce — UNIFORM `dispatch_sync`, in the block body
//
// A block the framework invokes off-main (a GCD completion, an enumeration on a
// concurrent queue) is the precise scenario the threading spike crashed 5/5 on
// (`ENOTSUP` in `GC-STOP-THE-WORLD` — SBCL cannot suspend a foreign thread for GC).
// So the block body hops to main via `awSbclOnMain` (CallbackBounce) BEFORE the Lisp
// dispatcher runs: the foreign thread never enters Lisp, it blocks in `dispatch_sync`
// while the main thread (SBCL-native, suspendable, owner of the run loop) runs the
// closure. The hop is synchronous — like the IMP path and for the same reason
// (CallbackBounce.swift header): a block BORROWS its framework-owned `id` arguments for
// the call's dynamic extent only, so an async hop would run Lisp against freed objects.
// Synchronous also lets a value-returning block return its result across the hop. On
// main already (the UI common case) `awSbclOnMain` calls straight in — zero hop.
//
// The Lisp dispatcher (`aw-block-dispatcher`, a `define-alien-callable`) is registered
// ONCE; each block captures only its integer block-id, and the dispatcher routes the id
// to the registered closure. The dispatcher is therefore only ever entered on the main
// thread (post-bounce), so entering Lisp from it is GC-safe by construction — never
// `class_addMethod` it or call it from a foreign thread directly.

import Foundation
import os

/// The one Lisp block dispatcher: `(blockId, a1, a2, a3) -> result`, all raw pointers
/// (integer-class args ride in as pointer-width values; the result rides out in x0).
/// Invoked ONLY on the main thread — each block body bounces first — so it is GC-safe
/// to enter Lisp from it.
public typealias AwSbclBlockDispatcher =
    @convention(c) (Int32, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?)
    -> UnsafeMutableRawPointer?

// The one registered dispatcher, guarded by an unfair lock. Registration happens once
// at runtime load (main thread); `aw_sbcl_make_block` reads it, possibly from a
// background `sb-thread` building a block — so the access is genuinely cross-thread.
// (Struct-in-lock mirrors SubclassSynth: a bare `@convention(c)` global is not Sendable.)
private struct AwSbclBlockState {
    var dispatcher: AwSbclBlockDispatcher?
}
private let awSbclBlockState = OSAllocatedUnfairLock(initialState: AwSbclBlockState())

/// Register the one Lisp block dispatcher. Called once when the runtime loads, with a
/// `define-alien-callable` pointer of signature `(int32, id, id, id) -> id`. It is only
/// ever invoked on the main thread (the block bodies bounce first).
@_cdecl("aw_sbcl_block_register_dispatcher")
public func aw_sbcl_block_register_dispatcher(_ dispatcher: UnsafeMutableRawPointer) {
    let fn = unsafeBitCast(dispatcher, to: AwSbclBlockDispatcher.self)
    awSbclBlockState.withLock { $0.dispatcher = fn }
}

/// Make an ObjC block for the Lisp closure registered under `bid`, returning a
/// +1-retained, heap-stable block pointer (the framework copies/retains it from there;
/// Lisp holds the +1 and — matching gerbil — does not release it, so the closure +
/// block live for the process: a bounded cost for app-lifetime callbacks).
///
/// The block captures only `bid` and the registered dispatcher; its body bounces to
/// main, then calls `dispatcher(bid, a1, a2, a3)`. Returns nil if no dispatcher is
/// registered yet (the runtime registers it at load, before any block is made).
@_cdecl("aw_sbcl_make_block")
public func aw_sbcl_make_block(_ bid: Int32) -> UnsafeMutableRawPointer? {
    guard let dispatcher = awSbclBlockState.withLock({ $0.dispatcher }) else { return nil }
    let block: @convention(block) (
        UnsafeMutableRawPointer?, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?
    ) -> UnsafeMutableRawPointer? = { a1, a2, a3 in
        var result: UnsafeMutableRawPointer?
        // The bounce: off-main → hop to main synchronously (preserving the borrowed
        // `id` args + the return value); on-main → straight in. Only then does Lisp run.
        awSbclOnMain { result = dispatcher(bid, a1, a2, a3) }
        return result
    }
    // `as AnyObject` bridges the `@convention(block)` value to its underlying block
    // object, heap-copying it (Swift's block bridging is a `Block_copy`); `passRetained`
    // takes the +1 we hand to Lisp. Without this the block could be a stack block freed
    // at return, before the framework reads it.
    return Unmanaged.passRetained(block as AnyObject).toOpaque()
}
