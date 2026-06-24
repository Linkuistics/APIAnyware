// ObservationBridgeTests.swift — Tests for withObservationTracking C bridge.

import Foundation
import Testing
import Observation
@testable import APIAnywareRacket

// MARK: - Test fixture

@Observable
final class Counter: @unchecked Sendable {
    var count: Int = 0
    var label: String = "default"
}

// MARK: - Thread-safe helper

/// A simple thread-safe box for coordinating between observation callbacks.
final class LockedBox<T: Sendable>: @unchecked Sendable {
    private var value: T
    private let lock = NSLock()

    init(_ value: T) { self.value = value }

    func get() -> T {
        lock.lock()
        defer { lock.unlock() }
        return value
    }

    func set(_ newValue: T) {
        lock.lock()
        defer { lock.unlock() }
        value = newValue
    }
}

/// Holds both an observable object and a changed flag for C callback contexts.
final class TrackingContext: @unchecked Sendable {
    let counter: Counter
    let changed: LockedBox<Bool>

    init(_ counter: Counter, _ changed: LockedBox<Bool>) {
        self.counter = counter
        self.changed = changed
    }
}

// MARK: - Tests

@Test func observationTrackFiresOnMutation() async {
    let counter = Counter()
    let changed = LockedBox(false)
    let trackingContext = TrackingContext(counter, changed)

    let applyCtx = Unmanaged.passUnretained(trackingContext).toOpaque()
    let changedCtx = Unmanaged.passUnretained(trackingContext).toOpaque()

    observationTrack(
        applyCtx,
        { ctx in
            let tc = Unmanaged<TrackingContext>.fromOpaque(ctx).takeUnretainedValue()
            _ = tc.counter.count
        },
        changedCtx,
        { ctx in
            let tc = Unmanaged<TrackingContext>.fromOpaque(ctx).takeUnretainedValue()
            tc.changed.set(true)
        }
    )

    counter.count = 1
    try? await Task.sleep(for: .milliseconds(50))
    #expect(changed.get())
}

@Test func observationTrackIsOneShot() async {
    let counter = Counter()
    let callCount = LockedBox(0)
    let trackingContext = TrackingContext(counter, LockedBox(false))
    let applyCtx = Unmanaged.passUnretained(trackingContext).toOpaque()
    let countCtx = Unmanaged.passUnretained(callCount).toOpaque()

    observationTrack(
        applyCtx,
        { ctx in
            let tc = Unmanaged<TrackingContext>.fromOpaque(ctx).takeUnretainedValue()
            _ = tc.counter.count
        },
        countCtx,
        { ctx in
            let box = Unmanaged<LockedBox<Int>>.fromOpaque(ctx).takeUnretainedValue()
            box.set(box.get() + 1)
        }
    )

    // First mutation should fire
    counter.count = 1
    try? await Task.sleep(for: .milliseconds(50))
    #expect(callCount.get() == 1)

    // Second mutation should NOT fire (one-shot)
    counter.count = 2
    try? await Task.sleep(for: .milliseconds(50))
    #expect(callCount.get() == 1)
}

@Test func observationTrackIgnoresUnobservedProperty() async {
    let counter = Counter()
    let changed = LockedBox(false)
    let trackingContext = TrackingContext(counter, changed)
    let applyCtx = Unmanaged.passUnretained(trackingContext).toOpaque()
    let changedCtx = Unmanaged.passUnretained(changed).toOpaque()

    observationTrack(
        applyCtx,
        { ctx in
            let tc = Unmanaged<TrackingContext>.fromOpaque(ctx).takeUnretainedValue()
            _ = tc.counter.count  // Only observe count
        },
        changedCtx,
        { ctx in
            let box = Unmanaged<LockedBox<Bool>>.fromOpaque(ctx).takeUnretainedValue()
            box.set(true)
        }
    )

    // Mutating label (unobserved) should NOT fire
    counter.label = "changed"
    try? await Task.sleep(for: .milliseconds(50))
    #expect(!changed.get())

    // Mutating count (observed) SHOULD fire
    counter.count = 42
    try? await Task.sleep(for: .milliseconds(50))
    #expect(changed.get())
}
