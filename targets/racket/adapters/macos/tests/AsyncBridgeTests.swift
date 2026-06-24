import Testing
import Foundation
@testable import APIAnywareRacket

// `async` → completion-callback bridge (AsyncBridge.swift). The load-bearing
// guarantee is that the completion fires **on the main thread** (a Racket
// `_cprocedure` SIGILLs on a foreign thread). These run off the main actor (the
// swift-testing default), so the main actor executor is free to service the hop.

@Test func asyncDispatchDeliversPayloadOnMainThread() async {
    let onMainWithRightValue: Bool = await withCheckedContinuation { cont in
        awRacketAsyncDispatch({ () async -> Int in 42 }) { value in
            cont.resume(returning: Thread.isMainThread && value == 42)
        }
    }
    #expect(onMainWithRightValue)
}

@Test func asyncDispatchCarriesPointerOutcome() async {
    // Pointer payloads ride AwAsyncOutcome (raw pointers aren't Sendable). Use a
    // bit-pattern so the @Sendable operation captures an Int, not a pointer.
    let bits = 0xBEEF
    let got: UnsafeMutableRawPointer? = await withCheckedContinuation { cont in
        awRacketAsyncDispatch({ AwAsyncOutcome(value: UnsafeMutableRawPointer(bitPattern: bits)) }) { outcome in
            cont.resume(returning: outcome.value)
        }
    }
    #expect(got == UnsafeMutableRawPointer(bitPattern: bits))
}

@Test func asyncOutcomeFailureMarshalsRetainedNSError() {
    // The throwing-async outcome marshals an Error exactly like the sync throws
    // bridge: a +1-retained NSError* in `error`, `value` nil.
    let outcome = AwAsyncOutcome.failure(NSError(domain: "AwAsync", code: 9))
    #expect(outcome.value == nil)
    #expect(outcome.error != nil)
    let err = Unmanaged<NSError>.fromOpaque(outcome.error!).takeRetainedValue()
    #expect(err.domain == "AwAsync")
    #expect(err.code == 9)
}

@Test func asyncDispatchDeliversThrowingOutcomeOnMainThread() async {
    // End-to-end throwing shape: operation does its own do/catch into an outcome
    // on the cooperative thread; the completion delivers it on the main thread.
    struct Boom: Error {}
    let raisedOnMain: Bool = await withCheckedContinuation { cont in
        awRacketAsyncDispatch({ () async -> AwAsyncOutcome in
            do {
                _ = try { () throws -> Int in throw Boom() }()
                return AwAsyncOutcome(value: nil)
            } catch {
                return AwAsyncOutcome.failure(error)
            }
        }) { outcome in
            let hasError = outcome.error != nil
            if let e = outcome.error {
                _ = Unmanaged<NSError>.fromOpaque(e).takeRetainedValue() // balance +1
            }
            cont.resume(returning: Thread.isMainThread && hasError)
        }
    }
    #expect(raisedOnMain)
}
