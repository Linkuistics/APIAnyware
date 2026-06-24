// RacketBridgeSuites.swift — serialization parent for the Racket-bridge test suites.
//
// BlockBridge, GCPrevention and DelegateBridge each exercise process-global
// state: the GC-prevention registry behind `gcPreventionCount()`, the block
// refcount table, the delegate dispatch table, and the file-global call
// counters the C trampolines write (`voidBlockCallCount`, `delegateCallLog`).
// Several tests assert on the registry's *absolute* count
// (`afterAdd > beforeAdd`, `afterRelease < beforeRelease`), which is only
// sound when no other test mutates that state concurrently.
//
// The `.serialized` trait only serializes tests *within* the suite it is
// applied to, so a per-suite `.serialized` cannot stop a test in one suite
// from racing a registry mutation in another. Nesting all three suites under
// this one `.serialized` parent makes the whole group run with no two of their
// tests concurrent, so the shared-state assertions are deterministic.

import Testing

@Suite(.serialized)
enum RacketBridgeSuites {}
