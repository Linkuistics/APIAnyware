# 020-async-method

**Kind:** work (likely opens with a short grilling on the blocking-await surface)

## Goal

Wire the **async receiver-handle method trampoline** for racket and prove the
grove's headline: a real recovered `async` method resolves and runs end-to-end.
Builds on `010-build`'s sync structural core (receiver unbox, by-name call,
marshalling, routing). Resolves **R4** — the blocking racket await surface — which
the measure-first step flagged as undesigned.

## Context

Read first: `010-build`'s landed ADR + spec sections, node `BRIEF.md` (D5), and
`docs/specs/2026-06-15-racket-trampoline.md` §3a (`AsyncBridge.swift`:
`awRacketAsyncDispatch`, `AwAsyncOutcome`, main-thread delivery) and §5b (why async
is a method-level effect, spun to this grove).

**Exemplar (measure-first, D7):** pop-A headline **`URLSession.data(from:)`** —
`async throws`, receiver `URLSession` (`objc_exposed=true` → `id`), param `NSURL`
(object, R1), returns `(Data, URLResponse)` tuple (boxed handle). Deterministic over
a `file://`/bundled source. Confirm the exact symbol + that URLSession accepts the
local source; fall back to another recovered bindable-async method if not.

**R4 — the open design (grill before wiring):** `awRacketAsyncDispatch` is
**non-blocking** (kicks a `Task`, delivers the marshalled result to a completion
callback **on the main thread** via `MainActor.run`). A synchronous racket call site
wants a value back. So racket needs a **blocking await**: call the async trampoline,
then block until the main-thread callback fires — *while the main run loop keeps
servicing the main queue* (else the callback never runs and it deadlocks). The spec
§5b named "a blocking `aw-async-await` wrapper" as the chosen surface but did not
design it. Candidate shapes to grill: a racket semaphore posted from the callback +
pumping the run loop; a `CFRunLoop`-driven wait; or exposing the callback form
directly. Interacts with `main-thread.rkt` and ADR-0014.

## Done when

- **Async codegen (D5):** the `@_cdecl` adapts the C completion callback into the
  `@Sendable operation` closure that **captures the opaque receiver pointer**, unboxes
  inside, `await receiver.method(args)` (auto-hops onto the method's actor), and
  **marshals the result to its Sendable C rep inside the closure** (`AwAsyncOutcome`
  for the `async throws` + tuple case). Swift 6 Sendable-checking compiles clean over
  the real frameworks.
- **R4 resolved:** a blocking `aw-async-await` racket surface (design landed inline /
  thin ADR addendum), driving `awRacketAsyncDispatch` without deadlock.
- **In-process smoke:** `URLSession.data(from:)` (or the fallback) resolves through
  `libAPIAnywareRacket` and returns a real `(Data, URLResponse)` from a deterministic
  local source.
- `swift build` green; `cargo test --workspace` green; racket-local assertion tests.
- ADR/spec extended with the async-method + blocking-await design.

## Notes

Reuses all of `010-build`'s machinery; only the async adaptation + R4 surface are
new. Full cold rerun + VM-verify of both sync and async paths is `030-rerun-verify`.
