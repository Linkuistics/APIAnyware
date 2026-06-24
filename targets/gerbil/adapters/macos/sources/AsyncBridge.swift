// AsyncBridge.swift — the `async` → completion-callback trampoline, main-thread
// aware (gerbil; ADR-0030 addendum A1/A2, ported from APIAnywareChez/Racket).
//
// A Swift-native `async` method cannot be called synchronously across the C ABI.
// The method-trampoline layer (ADR-0030) gives each `async` API a non-blocking
// trampoline: it takes a C completion callback + an opaque context, kicks off a
// `Task` that awaits the API, and invokes the callback with the marshalled result.
//
// gerbil's free-function async bucket was **empty** (ADR-0029 §5: no Swift-native
// async *free functions* exist), so the method frontier is the **first gerbil async
// path** — exactly as it was for chez.
//
// The load-bearing constraint mirrors chez/racket: a Scheme callback invoked from a
// non-main OS thread is unsafe. A `Task`'s continuation resumes on the cooperative
// thread pool — a foreign thread — so the callback must be invoked on the **main
// thread**. This bridge hops via `MainActor.run` before calling back; under the
// gerbil app's main run loop (the ADR-0022 main-thread bounce) the callback fires on
// the main thread.
//
// Swift 6 strict concurrency forces the shape: everything crossing the `Task` /
// `MainActor.run` hop must be `Sendable`. The generic payload `P` is `Sendable` and
// the generated `operation` closure does its **marshalling to the C rep on the
// cooperative thread**, leaving only a Sendable C rep to cross to the main thread.
//
// Per ADR-0011 this shares no native substrate with chez's/racket's
// `AsyncBridge.swift` — it is the deliberate hermetic per-target duplication, renamed
// under the `awGerbil*` namespace. The gerbil async surface (`aw-async-call` in
// runtime/async-bridge.ss) binds the generated callback-form method bindings against
// this.
//
// Same-module Swift (the closures are not C-representable; called from generated
// `@_cdecl` bodies that adapt the C callback into the Swift closures):
//   awGerbilAsyncDispatch — run an async op, deliver its Sendable payload on the
//     main thread.
//   AwGerbilAsyncOutcome — the Sendable payload for an `async throws` op (value rep +
//     retained-NSError rep), so the throwing case is just `P = AwGerbilAsyncOutcome`.

import Foundation

/// Run an `async` operation, then deliver its already-marshalled Sendable payload to
/// `completion` **on the main thread** (so the Scheme callback inside `completion`
/// does not run on a foreign thread).
///
/// `operation` runs on the cooperative pool and must return a Sendable C rep — the
/// generated trampoline marshals the API's result to that rep inside the closure.
/// `completion` runs on the main actor and invokes the C callback.
public func awGerbilAsyncDispatch<P: Sendable>(
    _ operation: @escaping @Sendable () async -> P,
    _ completion: @escaping @Sendable (P) -> Void
) {
    Task {
        let payload = await operation()
        await MainActor.run { completion(payload) }
    }
}

/// The Sendable payload for an `async throws` (or pointer-valued `async`) trampoline:
/// exactly one of `value` (the marshalled success C rep) or `error` (a +1-retained
/// `NSError *`, as `awGerbilWriteError` produces) is set. The generated completion
/// delivers `value` to the result callback or raises `error`.
///
/// `@unchecked Sendable`, not `Sendable`: the fields are raw pointers (not `Sendable`
/// in Swift 6), but the whole point of the outcome is to hand ownership of those
/// pointers across the cooperative-pool → main-thread hop. The transfer is deliberate
/// and single-consumer, so the unchecked conformance is honest. It then also satisfies
/// `awGerbilAsyncDispatch`'s `P: Sendable`, so a pointer-valued (non-throwing) async
/// result rides the same carrier with `error == nil` — no second wrapper.
public struct AwGerbilAsyncOutcome: @unchecked Sendable {
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
    /// `NSError *` — the same marshalling the synchronous `throws` bridge
    /// (`awGerbilWriteError`) uses, so the success and throwing async paths agree. The
    /// generated `operation` closure calls this in its `catch`.
    @inlinable public static func failure(_ error: Error) -> AwGerbilAsyncOutcome {
        AwGerbilAsyncOutcome(error: Unmanaged.passRetained(error as NSError).toOpaque())
    }
}
