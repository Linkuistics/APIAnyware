# BlockBridge Swift-test flake — root cause and fix

**Date:** 2026-05-21
**Status:** DONE
**Scope:** `swift/Tests/APIAnywareRacketTests/`

## Symptom

`swift test` (in `swift/`) failed intermittently — roughly 1 run in 3 — with a
BlockBridge test failure. It passed in isolation and on re-run. The Swift
Testing run executes the three Racket-bridge suites (`BlockBridge`,
`GCPrevention`, `DelegateBridge`) in parallel.

## Investigation

An 8-run reproduction loop failed 2/8, every failure identical:

```
Test "Block can be invoked as a C function" recorded an issue at
BlockBridgeTests.swift:48:9: Expectation failed: (voidBlockCallCount → 2) == 1
```

This is `invokeBlock`. The fix attempt below then exposed a **second, distinct**
race in a 20-run loop (1/20):

```
Test "Active GC prevention count" recorded an issue at GCPreventionTests.swift:64:9:
Expectation failed: (afterAdd1 → 2) > (beforeAdd1 → 2)
```

## Root cause

Both failures are the same class of bug: **tests assert on process-global
mutable state while other tests mutate it concurrently.**

1. **`voidBlockCallCount` (intra-suite).** `invokeBlock` resets the file-global
   `voidBlockCallCount` to 0, invokes one block, and expects `== 1`.
   `multipleBlocks` also invokes `voidBlockInvoke` (which increments the same
   counter). The `BlockBridge` suite had no `.serialized` trait, so its tests
   ran in parallel and `invokeBlock` observed the count perturbed to 2.

2. **GC-prevention count (cross-suite).** `GCPrevention.activeCount`,
   `BlockBridge.blockGCLifecycle` and `DelegateBridge.delegateGCLifecycle` each
   assert on the delta of the process-global GC-prevention registry count
   (`gcPreventionCount()`). Every block/delegate/GC test mutates that registry.
   `.serialized` only serializes tests *within* one suite, so a test in one
   suite still raced a registry mutation in another.

`GCPrevention` and `DelegateBridge` already carried per-suite `.serialized`,
which is why the dominant, frequent flake landed in the only non-serialized
suite, `BlockBridge`. But per-suite `.serialized` never addressed the
cross-suite registry race.

## Fix

Nest all three suites under one `.serialized` parent suite,
`RacketBridgeSuites` (`RacketBridgeSuites.swift`). `.serialized` on a suite
serializes its entire subtree, so no two tests across the three suites run
concurrently — both the intra-suite and cross-suite races are eliminated by a
single mechanism. The now-redundant per-suite `.serialized` traits were
removed, and the stale "other suites may run concurrently" comment in
`activeCount` was corrected.

## Verification

Post-fix the reproduction loop ran 40/40 clean (pre-fix rates were ~25% and
~5%), and `swift test` output confirms the suites execute sequentially.
