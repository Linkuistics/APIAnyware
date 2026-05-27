# 030-runtime-ffi-objc

**Kind:** work

## Goal
Fill `runtime/ffi.sls` and `runtime/objc.sls` end-to-end:
- `ffi.sls`: mandatory `libAPIAnywareChez.dylib` load (hard error if absent),
  the libobjc surface (`objc_getClass`, `objc_msgSend`, `objc_retain`,
  `objc_release`, `objc_autoreleasePoolPush/Pop`, the class-allocation
  surface), and libdispatch's `dispatch_async`/`dispatch_get_main_queue` if
  needed by `cocoa`.
- `objc.sls`: the `objc-object` record, the `objc-guardian` parameter,
  `wrap-objc-object` / `borrow-objc-object` / `unwrap-objc-object`,
  the `with-autorelease-pool` macro, `drain-objc-guardian`, the
  `define-entry-point` macro, the `nserror` record + `(values result error)`
  helpers per ADR-0006.

## Context
- ADR-0007 (lifetime model) and ADR-0006 (NSError shape).
- `generation/targets/racket/runtime/objc-base.rkt` for the
  retain/release/wrap shape (semantics, not source).
- `generation/targets/racket/runtime/swift-helpers.rkt` for the dylib
  symbol set — but with `with-handlers` removed (mandatory dylib means we
  just `(load-shared-object …)` and fail hard).
- The Swift-side `aw_common_*` symbol names in
  `swift/Sources/APIAnywareCommon/` — same symbols, called from chez.
- Chez foreign-procedure docs and guardian docs.

## Done when
- `(import (apianyware runtime objc))` loads, creates a guardian, and a
  smoke test wraps an `NSObject` via `objc_getClass` + `objc_msgSend`
  alloc/init through it.
- A unit-test-style demo at
  `generation/targets/chez/runtime/tests/smoke-objc.sls` constructs an
  `NSObject`, lets GC collect the wrapper, drains the guardian, and
  observes the release count incrementing.
- `(with-autorelease-pool …)` exercises an autoreleased string round-trip.
- `(define-entry-point demo () (with-autorelease-pool …))` expands and
  runs without leaking.

## Notes
- `libAPIAnywareChez.dylib` may not exist yet (its leaf is 060). For this
  leaf, point the dylib loader at the existing `libAPIAnywareCommon`
  symbols inside `libAPIAnywareRacket.dylib` for the `aw_common_*`
  surface — they're the same symbols. Switch to the chez-specific dylib
  once 060 produces it. This is the only point of cross-target borrowing
  in the chez bring-up; it disappears once 060 lands.
