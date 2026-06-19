# 030-lifetime-threading-conditions

**Kind:** planning

## Goal

Settle the three areas 020 left **un-de-risked by prior art** — lifetime (D1),
threading/callbacks (D2), and the `NSError**` condition hierarchy (C2/Q8) — and
raise the ADR(s). Bundled because all three are small, first-principles, and
interrelated (the callback path and the condition path both cross the FFI seam).

## Context

Read: `done/010-plan` (D1/D2 distinctives), `done/020-…` research **§D (D1/D2
absence finding), §C2 (conditions absence)**, and the in-repo precedents which do
more here than the prior-art survey:

- **Lifetime:** chez **ADR-0007** (guardian) + gerbil **ADR-0019** (Gambit wills +
  entry-point autoreleasepool). SBCL options: `sb-ext:finalize` vs weak pointers
  vs a guardian analogue. Resolve the **entry-point autoreleasepool** convention
  (CONTEXT.md term — currently chez-specific; decide whether it generalizes).
- **Threading/callbacks:** racket **ADR-0014** + gerbil **ADR-0022** (main-thread
  bounce for AppKit) vs chez **ADR-0016** (foreign-thread activation). Choose the
  model that fits SBCL: `define-alien-callable` trampolines + `sb-thread`
  foreign-thread activation + main-thread bounce.
- **Conditions:** chez **ADR-0006** (chez NSError shape) is the in-repo precedent;
  gerbil's `ThrowsBridge` (ADR-0029) bridges `throws`/`NSError**` on the
  trampoline path. CL idiom: errors are **signalled conditions** (+ restarts),
  not `(values result error)` — this is part of the contract (010 leaf declares
  it; this leaf designs the hierarchy).

## What to design first-hand

- Read CCL's `with-autorelease-pool`, `terminate-when-unreachable`, and the
  `performSelectorOnMainThread` / event-loop machinery (020 §D pointer) — for
  ideas, not as a portable mechanism.
- Decide: SBCL lifetime primitive; the autoreleasepool boundary convention;
  the callback thread-activation + main-thread-bounce model; the condition class
  hierarchy for `NSError**` (class names, restarts, signalled vs returned).

## Done when

- Lifetime, threading/callbacks, and the condition hierarchy each settled with a
  recorded decision; ADR(s) raised.
- The condition hierarchy is concrete enough for the `010` contract spec to
  reference as the contract's error-handling surface.
- Feeds the SBCL target design spec (assembled in `040`).

## Notes

- If any one area proves big enough to need its own session, split it out then —
  do not pre-split.
