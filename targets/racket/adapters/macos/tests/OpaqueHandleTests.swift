import Testing
import Foundation
@testable import APIAnywareRacket

// Opaque value-handle infra (OpaqueHandle.swift): box any non-bridged Swift
// value, read it back by its concrete type, free it through the one uniform
// `aw_racket_box_free`. These exercise the runtime primitives the generated
// per-type accessors (leaf 040/020) build on.

// MARK: - round-trip across the taxonomy rows that share the box rep

private struct Pair: Equatable {
    var a: Int
    var b: String
}

private enum Shape: Equatable {
    case circle(radius: Double)
    case rect(w: Int, h: Int)
}

@Test func boxUnboxStructRoundTrip() {
    let handle = awRacketBox(Pair(a: 7, b: "seven"))
    defer { awRacketBoxFree(handle) }
    #expect(awRacketUnbox(handle, as: Pair.self) == Pair(a: 7, b: "seven"))
}

@Test func boxUnboxPayloadEnumRoundTrip() {
    let handle = awRacketBox(Shape.rect(w: 3, h: 4))
    defer { awRacketBoxFree(handle) }
    #expect(awRacketUnbox(handle, as: Shape.self) == .rect(w: 3, h: 4))
}

@Test func boxUnboxTupleRoundTrip() {
    let handle = awRacketBox((42, 3.5))
    defer { awRacketBoxFree(handle) }
    let (i, d) = awRacketUnbox(handle, as: (Int, Double).self)
    #expect(i == 42)
    #expect(d == 3.5)
}

@Test func boxUnboxExistentialRoundTrip() {
    // A value-backed existential — the case Unmanaged cannot box but AwValueBox
    // can, because it stores `Any`.
    let handle = awRacketBox(Shape.circle(radius: 1.0) as any Equatable)
    defer { awRacketBoxFree(handle) }
    let back = awRacketUnbox(handle, as: (any Equatable).self)
    #expect((back as? Shape) == .circle(radius: 1.0))
}

// MARK: - unbox does not consume the handle

@Test func unboxDoesNotConsumeHandle() {
    let handle = awRacketBox(Pair(a: 1, b: "one"))
    defer { awRacketBoxFree(handle) }
    // Two reads must both succeed — the box stays alive until freed.
    #expect(awRacketUnbox(handle, as: Pair.self) == Pair(a: 1, b: "one"))
    #expect(awRacketUnbox(handle, as: Pair.self) == Pair(a: 1, b: "one"))
}

// MARK: - free actually releases the boxed value

private final class DeinitWitness {
    let onDeinit: () -> Void
    init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
    deinit { onDeinit() }
}

@Test func boxFreeReleasesBoxedValue() {
    var deinited = false
    let handle = awRacketBox(DeinitWitness { deinited = true })
    // The only strong reference now lives inside the box.
    #expect(deinited == false)
    awRacketBoxFree(handle)
    #expect(deinited == true)
}
