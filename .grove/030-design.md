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

Read first: `010-plan` running log (D1–D5), the 020 research doc
(`docs/research/cl-cocoa-bridges-across-the-family.md`) + its
"Synthesis for 030" (§7) + the gaps it flags as **not** de-risked (C2 conditions,
D1 lifetime, D2 threading, SBCL's own AMOP conformance — budget first-hand CCL
source reading + in-repo ADRs for these), `CONTEXT.md` "SBCL target toolchain",
and the precedent ADRs
(0005, 0009, 0010, 0011, 0015, 0017, 0020). The chez/gerbil design specs are the
worked models (`generation/targets/{chez,gerbil}/docs/design/`).

## Design input — Swift library as coverage + convergence mechanism (user, 2026-06-15)

A major intended differentiator vs **all** prior CL-Cocoa bridges (CCL,
LispWorks, MCL — every one is `libobjc`/`objc_msgSend`-based and therefore
**ObjC-only**): APIAnyware should give **100% coverage of both ObjC *and*
newer Swift-only APIs** (frameworks with no ObjC class/selector surface) by
routing through a **per-target Swift library** that calls the Swift APIs
directly and exports a flat **C ABI**. Swift-only APIs are structurally
invisible to a message-send bridge; a Swift library is the only way to reach
them. The 020 research should confirm the ObjC-only ceiling of the existing
bridges (treat it as a found gap, not a feature tour).

Crucially, the user proposes this per-target Swift library **may also be the
mechanism that lets all CL variants present the same interface** — i.e. the
implementation basis of the CL-family contract, not just a coverage device.
This reframes **Q7 (native core)** and binds it to **Q1/Q2 (the contract)**.
Grill it as a two-layer contract:

- **Upper layer** — the CL surface spec (`ns:` package, class names, generics,
  condition hierarchy): what application authors see.
- **Lower layer** — the Swift library's **exported C ABI**: what each impl's
  FFI binds to, the artifact that *forces* convergence and *delivers* Swift
  coverage. Itself **emitted** from the shared API analysis (D3 static emit),
  so convergence is doubly guaranteed: same analysis → same C ABI → same CL
  surface (modulo each impl's FFI syntax).

**The fork to settle (ADR-0011 scoping):** is the Swift library
**one-per-impl, built from shared Swift source, exposing an identical C ABI**
(hermetic — no shared binary; the C-ABI spec is the normative artifact), or a
**single family-shared substrate** (a larger exception — it reintroduces the
"common native substrate" that `APIAnywareCommon` is being dissolved to
eliminate)? "per-target" leans hermetic; "all CL variants, same interface"
hints shared. **Not pre-judged here** — it is a 030 decision and likely its
own ADR alongside the D5 family-axis ADR.

## Open questions to grill (interdependent — sequence them)

1. **Contract authoring** — adopt CCL's `ns:`/metaclass/`#/` conventions vs
   define our own; what exactly is normative in the contract (packages, class
   names, generic-fn naming, metaclass protocol, condition hierarchy); where the
   spec doc lives (main-tier, since it spans the CL family — D5a). The contract is
   designed against the **four-member roster (SBCL, CCL, AllegroCL, LispWorks)**,
   not just SBCL+CCL.
   - **Risk to resolve:** AMOP conformance and ObjC-bridge maturity vary across
     the four (esp. commercial AllegroCL/LispWorks with their own MOPs + FFIs
     `ff:`/`fli:`). Decide from the 020 findings whether a single MOP-based
     contract is viable across all four, or whether a non-MOP fallback / tiered
     conformance is needed. Build still targets **SBCL only** (D5a).
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
7. **Native core** — see the *Swift-library* design input above: the native
   core is not merely a block/delegate-bridge dylib but the **Swift library
   exporting the C ABI** that gives Swift-API coverage and (per the user)
   may be the contract's convergence layer. Settle: per-impl-from-shared-source
   vs family-shared substrate (ADR-0011 scoping); what the C ABI must export;
   how `sb-alien` binds it; how much (block/delegate bridges, dynamic-class
   synthesis) lives in Swift vs Lisp. (gerbil avoided a dylib via ObjC-in-gsc;
   SBCL can't compile ObjC/Swift inline, so a real library is expected.)
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
