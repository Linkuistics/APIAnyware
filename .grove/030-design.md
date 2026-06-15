# 030-design

**Kind:** planning

## Goal

Turn the foundational directions (D1–D5, in `010-plan`) plus the CCL research
(020) into a concrete, buildable design. This planning leaf grills the open
design questions and **decomposes** into sub-leaves — at minimum a **contract
spec** sub-leaf and a **SBCL MOP realization** sub-leaf (and likely separate
ones for dispatch, lifetime/threading, callbacks, conditions). It also raises the
**new ADR** for the CL-family interface-sharing axis (D5) and any ADRs the MOP /
lifetime / dispatch decisions warrant.

## Context

Read first: `010-plan` running log (D1–D5), the 020 research doc + its
"Synthesis for 030", `CONTEXT.md` "SBCL target toolchain", and the precedent ADRs
(0005, 0009, 0010, 0011, 0015, 0017, 0020). The chez/gerbil design specs are the
worked models (`generation/targets/{chez,gerbil}/docs/design/`).

## Open questions to grill (interdependent — sequence them)

1. **Contract authoring** — adopt CCL's `ns:`/metaclass/`#/` conventions vs
   define our own; what exactly is normative in the contract (packages, class
   names, generic-fn naming, metaclass protocol, condition hierarchy); where the
   spec doc lives (main-tier, since it spans the CL family — D5a).
2. **New ADR for the CL-family interface-sharing axis** (D5) — scopes an
   exception to ADR-0011 for same-language families.
3. **MOP realization** — the `objc-class` metaclass design; the **static-emit
   (class graph) vs runtime-MOP-hooks** split (D3 reconciliation); how SBCL's
   MOP (AMOP conformance, `sb-mop`) supports the hooks needed.
4. **Dispatch** — selector → generic-function naming; per-signature `sb-alien`
   typed call sites (arm64 variadic cast); how generics forward to the FFI core.
5. **Lifetime / memory** — `sb-ext:finalize` vs weak pointers vs a guardian
   analogue; entry-point autoreleasepool convention (CONTEXT.md term, currently
   chez-specific — does it generalize?).
6. **Callbacks / threading** — `define-alien-callable` trampolines; foreign-thread
   activation with `sb-thread`; main-thread bounce for AppKit (racket ADR-0014 /
   gerbil ADR-0022 vs chez ADR-0016 — which model fits SBCL?).
7. **Native core** — does SBCL need a `libAPIAnywareSbcl` dylib (block/delegate
   bridges, dynamic-class synthesis), or can `sb-alien` + a separately-compiled
   ObjC `.dylib` suffice? (gerbil avoided a dylib via ObjC-in-gsc; SBCL can't
   compile ObjC inline, so likely a small ObjC/Swift dylib — ADR-0011 lets it
   differ.)
8. **Error handling** — the condition hierarchy for `NSError**` (part of the
   contract): condition classes, restarts, vs `(values result error)`.

## Done when

- Each question settled with a recorded decision; ADRs raised where warranted
  (the CL-family axis ADR at minimum).
- A SBCL target design spec written to
  `generation/targets/sbcl/docs/design/YYYY-MM-DD-sbcl-target-design.md`, and the
  CL-family contract spec to its decided location.
- The tree is grown: build leaves (040–070) refined / decomposed in light of the
  settled design.

## Notes

- Watch the "runaway tree" anti-pattern — decompose lazily as questions settle,
  not all at once.
