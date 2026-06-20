// CallbackBounce.swift — the foreign-thread → main-thread bounce (ADR-0035).
//
// THE ADR-0035 SPINE: a foreign OS thread (a GCD worker, a framework completion
// thread SBCL never created) must **never** run Lisp directly. The threading spike
// crashed 5/5 when concurrent foreign threads ran a consing `define-alien-callable`
// under GC pressure — a fatal `ENOTSUP` inside `GC-STOP-THE-WORLD`, because SBCL
// cannot stop-the-world-suspend a thread it merely *attached* for a callback (only
// threads it created). So every callback that may originate off-main — a subclass
// IMP (SubclassSynth), a block invoke (leaf 060), an async completion (AsyncBridge)
// — must hop to the **main thread** (SBCL-native, suspendable, owner of the AppKit
// run loop) before any Lisp runs.
//
// This file is the native bounce primitive. SubclassSynth's `forwardInvocation:`
// IMP calls `awSbclOnMain` before invoking the Lisp dispatcher; the block makers of
// leaf 060 will call it from each block body. It is the SBCL counterpart of gerbil's
// `native_block.c` `aw_on_main` (ADR-0022) — gerbil kept this in its ObjC-in-gsc
// home; SBCL has no such second native home, so it converges here, in the sole
// native unit (ADR-0038 §1, the broader-than-gerbil consolidation).
//
// ## Why UNIFORM `dispatch_sync`, not sync-for-value / async-for-void
//
// ADR-0035 sketches "`dispatch_sync` for value-returning, `dispatch_async` for void
// completions". The build refines that with gerbil's hard-won implementation lesson
// (`native_block.c`): a framework frees a callback's `id` ARGUMENTS the instant the
// call returns, so an *async* hop would run the Lisp work against freed objects —
// a use-after-free. The IMP/callback path BORROWS the framework's arguments, so it
// must be **synchronous**: the framework call stays blocked until the bounce
// completes, preserving both argument lifetime and the return value. The deadlock
// caveat (a value the main thread is itself synchronously awaiting) is rare and
// documented (ADR-0035). `dispatch_async`/`MainActor.run` is reserved for the
// AsyncBridge path, which OWNS its payload (already marshalled + retained on the
// cooperative thread before the hop) and so has no borrowed-arg hazard.
//
// On the main thread already (the UI common case — AppKit delegates fire on main),
// every bounce calls inward directly: zero hop, no deadlock window. `pthread_main_np`
// is the on-main check.

import Foundation

/// Run `work` on the main thread and block until it finishes. Direct call when
/// already on main (avoids a needless hop and the deadlock window). The synchronous
/// hop preserves the lifetime of any framework-owned arguments `work` reads (see the
/// file header) and any value it must return to the framework.
@inlinable
public func awSbclOnMain(_ work: () -> Void) {
    if pthread_main_np() != 0 {
        work()
    } else {
        // `withoutActuallyEscaping`: `dispatch_sync` does not escape `work` (it runs
        // and returns before the call completes), but the GCD shim is typed escaping.
        withoutActuallyEscaping(work) { escapable in
            DispatchQueue.main.sync(execute: escapable)
        }
    }
}

/// C-ABI bounce entry the Lisp runtime binds via `sb-alien`: run `fn(ctx)` on the
/// main thread synchronously. The general "do this on main" primitive — the Lisp
/// runtime hands down a `define-alien-callable` pointer + an opaque context (e.g. to
/// schedule a release-queue drain at the pool boundary, ADR-0036, or to marshal a
/// main-thread-affine call). `fn` runs on main, so it is GC-safe to enter Lisp from
/// it; calling this *from* Lisp (already on a safe thread) is fine — the hazard is a
/// FOREIGN thread entering Lisp, which this prevents by construction.
@_cdecl("aw_sbcl_on_main_run")
public func aw_sbcl_on_main_run(
    _ fn: @convention(c) (UnsafeMutableRawPointer?) -> Void,
    _ ctx: UnsafeMutableRawPointer?
) {
    awSbclOnMain { fn(ctx) }
}

/// Diagnostic the runtime can bind to assert main-thread affinity (e.g. in the
/// startup re-resolution pass or the release-queue drain). Returns 1 on the main
/// thread, 0 otherwise.
@_cdecl("aw_sbcl_is_main_thread")
public func aw_sbcl_is_main_thread() -> Int32 {
    pthread_main_np() != 0 ? 1 : 0
}
