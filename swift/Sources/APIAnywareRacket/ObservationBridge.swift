// ObservationBridge.swift — Bridge Swift Observation framework to C FFI.
//
// Pattern: C function pointer + context for each Swift closure parameter.
// This is the proof-of-concept for bridging Swift-only APIs to C-callable
// functions, establishing the pattern for future Swift API bridges.
//
// Exports: aw_racket_observation_track

import Observation

/// Bridge `withObservationTracking` to C function pointers.
///
/// Tracks which `@Observable` properties are accessed during `applyFn`,
/// then calls `changedFn` once when any of them change (on an arbitrary thread).
/// Observation is one-shot: the consumer must call this again to re-register.
///
/// - Parameters:
///   - applyContext: Opaque pointer passed back to `applyFn` (caller's environment).
///   - applyFn: Called synchronously to establish observation. Access observable
///     properties here to register them for tracking.
///   - changedContext: Opaque pointer passed back to `changedFn`.
///   - changedFn: Called once, on an arbitrary thread, when a tracked property changes.
@_cdecl("aw_racket_observation_track")
public func observationTrack(
    _ applyContext: UnsafeMutableRawPointer,
    _ applyFn: @convention(c) (UnsafeMutableRawPointer) -> Void,
    _ changedContext: UnsafeMutableRawPointer,
    _ changedFn: @convention(c) @Sendable (UnsafeMutableRawPointer) -> Void
) {
    // Capture the context as Int (Sendable) for the @Sendable onChange closure.
    // UnsafeMutableRawPointer is not Sendable in Swift 6, but the raw bit
    // pattern round-trips losslessly. Thread safety is the FFI consumer's
    // responsibility — this pointer is an opaque passthrough.
    let changedBits = Int(bitPattern: changedContext)
    withObservationTracking {
        applyFn(applyContext)
    } onChange: {
        changedFn(UnsafeMutableRawPointer(bitPattern: changedBits)!)
    }
}
