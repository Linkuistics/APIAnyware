# 020-async-functions

**Kind:** work

## Goal

Trampoline the `deferred_async` bucket — Swift-native `async` (and `async throws`)
free functions — so they bind from racket. The runtime (`AsyncBridge.swift`) is
already built; this leaf adds the **callback `@_cdecl` codegen** and the racket
**`_cprocedure` main-thread binding**.

## Context

- Why deferred (spec §5): the runtime supports it, but the callback `@_cdecl`
  shape + racket `_cprocedure` main-thread binding were left as a follow-up leaf.
- Runtime ready (040/010, spec §3a): `awRacketAsyncDispatch<P: Sendable>(operation:completion:)`
  runs the async op on the cooperative pool and delivers a Sendable payload to
  `completion` **on the main thread** via `MainActor.run` (so the racket
  `_cprocedure` callback doesn't SIGILL); `AwAsyncOutcome` (`@unchecked Sendable`
  value/error carrier) covers `async throws` and pointer/throwing results.
- **Constraint to honour (spec §3a):** the generated `operation` closure must be
  `@Sendable` and must **marshal the result to its C rep inside the closure** (on
  the cooperative thread) — only Sendable C reps (a scalar, or `AwAsyncOutcome`
  for pointer/throwing results) may cross the main-thread hop.
- Codegen: `emit-racket/src/trampoline.rs` (async row); racket side:
  `runtime/swift-trampoline.rkt` + the existing `runtime/main-thread.rkt`
  machinery for the `_cprocedure` callback.

## Done when

- The codegen emits the completion-callback `@_cdecl` per async residual decl over
  `awRacketAsyncDispatch`; the emitter binds it from racket with a
  main-thread-aware `_cprocedure` and surfaces the result/error to the caller
  (sync-looking blocking wait or a continuation — decide in-leaf, record in spec).
- A clean `--target racket` generate **reduces** the `deferred_async` count
  (report before/after); anything still unwireable stays recorded with a reason.
- Builds green (`swift build` + `cargo test --workspace`, snapshots updated); a
  **real** recovered `async` decl resolves and runs from racket, returning the
  awaited value (extend the 040/030 smoke).

## Notes

- Main-thread correctness is the sharp edge — verify the callback actually lands
  on the main thread and the result marshalling happens off-main per §3a.
- If the racket-facing async surface (block vs. continuation) needs a design call,
  grill it and record in the spec rather than guessing.
