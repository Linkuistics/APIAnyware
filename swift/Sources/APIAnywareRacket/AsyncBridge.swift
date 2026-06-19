// AsyncBridge.swift — the `async` → completion-callback trampoline, main-thread
// aware.
//
// A Swift-native `async` function cannot be called synchronously across the C
// ABI. The trampoline layer (ADR-0027 / spec §3) gives each `async` API a
// non-blocking trampoline: it takes a C completion callback (a Racket
// `_cprocedure`) + an opaque context, kicks off a `Task` that awaits the API,
// and invokes the callback with the marshalled result.
//
// The load-bearing constraint (emit_functions.rs SIGILL note + main-thread.rkt):
// a Racket CS `_cprocedure` **SIGILLs when invoked from a non-main OS thread**.
// A `Task`'s continuation resumes on the cooperative thread pool — a foreign
// thread. So the callback must be invoked on the **main thread**. This bridge
// hops via `MainActor.run` before calling back; under `nsapplication-run` the
// main run loop services the main queue, so the callback fires on the main
// thread (the same guarantee main-thread.rkt relies on, from the Swift side).
//
// Swift 6 strict concurrency (this package's language mode) forces the shape:
// everything crossing into the `Task` / `MainActor.run` hop must be `Sendable`.
// A raw Swift API result is generally not — so the generic payload `P` is
// `Sendable` and the generated `operation` closure does its **marshalling to the
// C rep on the cooperative thread**, leaving only a Sendable C rep
// (`UnsafeMutableRawPointer?`, a scalar, or `AwAsyncOutcome`) to cross to the
// main thread. (Consequence: an `async` result is marshalled off-main; safe for
// value/Foundation reps. Revisit only if a real async API must marshal a
// main-thread-only object — see spec §3.)
//
// Same-module Swift (the closures are not C-representable; called from generated
// `@_cdecl` bodies that adapt the C callback into the Swift closures):
//   awRacketAsyncDispatch — run an async op, deliver its Sendable payload on the
//     main thread.
//   AwAsyncOutcome — the Sendable payload for an `async throws` op (value rep +
//     retained-NSError rep), so the throwing case is just `P = AwAsyncOutcome`.

import Foundation

/// Run an `async` operation, then deliver its already-marshalled Sendable
/// payload to `completion` **on the main thread** (so a Racket `_cprocedure`
/// callback inside `completion` does not SIGILL on a foreign thread).
///
/// `operation` runs on the cooperative pool and must return a Sendable C rep —
/// the generated trampoline marshals the API's result to that rep inside the
/// closure. `completion` runs on the main actor and invokes the C callback.
public func awRacketAsyncDispatch<P: Sendable>(
    _ operation: @escaping @Sendable () async -> P,
    _ completion: @escaping @Sendable (P) -> Void
) {
    Task {
        let payload = await operation()
        await MainActor.run { completion(payload) }
    }
}

/// The Sendable payload for an `async throws` (or pointer-valued `async`)
/// trampoline: exactly one of `value` (the marshalled success C rep) or `error`
/// (a +1-retained `NSError *`, as `awRacketWriteError` produces) is set. The
/// generated completion delivers `value` to the result callback or raises
/// `error`.
///
/// `@unchecked Sendable`, not `Sendable`: the fields are raw pointers (not
/// `Sendable` in Swift 6), but the whole point of the outcome is to hand
/// ownership of those pointers across the cooperative-pool → main-thread hop.
/// The transfer is deliberate and single-consumer, so the unchecked conformance
/// is honest. It then also satisfies `awRacketAsyncDispatch`'s `P: Sendable`, so
/// a pointer-valued (non-throwing) async result rides the same carrier with
/// `error == nil` — no second wrapper.
public struct AwAsyncOutcome: @unchecked Sendable {
    /// Marshalled success rep (e.g. a bridged `id`, a boxed handle), or nil.
    public var value: UnsafeMutableRawPointer?
    /// A +1-retained `NSError *` on the throwing path, or nil on success.
    public var error: UnsafeMutableRawPointer?

    @inlinable public init(
        value: UnsafeMutableRawPointer? = nil,
        error: UnsafeMutableRawPointer? = nil
    ) {
        self.value = value
        self.error = error
    }

    /// Build a failure outcome by marshalling a thrown `Error` to a retained
    /// `NSError *` — the same marshalling `awRacketWriteError` uses, so the
    /// success and throwing async paths agree with the synchronous `throws`
    /// bridge. The generated `operation` closure calls this in its `catch`.
    @inlinable public static func failure(_ error: Error) -> AwAsyncOutcome {
        AwAsyncOutcome(error: Unmanaged.passRetained(error as NSError).toOpaque())
    }
}
