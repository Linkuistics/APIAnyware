# 030-background-thread-callback-safety

**Kind:** work

## Goal
Implement ADR-0016: make Chez `foreign-callable` callbacks safe on background OS
threads by `Sactivate_thread`-wrapping the native trampolines, so callbacks that
fire off the main thread (NSURLSession completions, `dispatch_async` compute)
don't crash — without forcing a main-thread bounce for non-UI work.

## Context
- Design: `docs/specs/2026-06-02-chez-native-binding-design.md` §4; ADR-0016
  (extends ADR-0007). Spike evidence: `docs/research/2026-06-02-chez-dispatch-spike/`
  `FINDINGS.md` §C — a `foreign-callable` from any unregistered OS thread crashes;
  `Sactivate_thread`/`Sdeactivate_thread` (threaded Chez) fixes it.
- Surfaces: `DelegateBridge.swift`, `BlockBridge.swift` (native trampolines) and
  the `dispatch.sls` `foreign-callable` wrappers (Scheme side).

## Done when
- The native trampolines (and/or the `foreign-callable` entry wrappers) activate
  the calling thread (`Sactivate_thread`) before entering Scheme and deactivate
  after — only when not already on a Scheme-registered thread.
- `Sactivate_thread` bookkeeping handled: reactivation vs new-context (the `int`
  return); new contexts cleaned up (`Sdestroy_thread`) to avoid leaks across many
  short-lived worker callbacks.
- Per-thread `@autoreleasepool` pushed in the activated callback; process-wide
  guardian-drain timing not assumed (ADR-0007 interaction resolved).
- A synthetic test exercises a callback on a `dispatch_async` background queue and
  passes (no crash; correct result; no thread-context leak).

## Notes
- **Gate (grove laziness):** if no current chez sample app exercises a genuinely
  background callback, this may narrow to "wire the activation + synthetic test"
  or be deferred via `grove-llm inbox-add` to a future grove. The ADR-0016
  decision stands regardless; this leaf is the *wiring*.
- Measure `Sactivate_thread` per-callback cost only if a hot background path
  appears (none today).
