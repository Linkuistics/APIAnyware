# 3-[3]-design — brief

Turn the foundational directions (D1–D5, `done/010-plan`) plus the CCL research
(`done/020-…`) into a concrete, buildable design for the **sbcl** target. This
node was a single planning leaf; the 2026-06-20 session grilled the headline
fork (dispatch), absorbed a major upstream reset (the complete-API model merged
from `main`), recorded the settled decisions below, and **decomposed** into the
ordered child leaves. The heavy authoring — the CL-family contract spec, the SBCL
target design spec, and the per-area ADRs — is the work of those children.

## The reset (2026-06-20 — merge + inbox, both incorporated)

This branch was 40 commits behind `main`; `main` was merged in. The
`add-swift-native-{api,method}-coverage` groves landed the **complete-API binding
model** (ADR-0025/0026) and per-target trampoline structures (ADR-0027–0032).
Consequences that **reframe this node's questions**:

- The shared IR now carries **`objc_exposed: bool`** on all 8 declaration nodes;
  Swift-native top-level funcs/constants are **retained** (not dropped); method-
  trampoline fields exist. **The shared analysis now feeds sbcl Swift-native IR**
  — the inbox prerequisite is met (verified in `collection/crates/types/src/ir.rs`
  + `extract-swift/src/declaration_mapping.rs`).
- The brief's **Q1/Q7** are no longer about a bespoke Swift coverage library. The
  sbcl Swift library **is the trampoline layer** of the complete-API model. ObjC
  is **direct** (`objc_msgSend`, trampoline elided); only the Swift-native residual
  trampolines through `libAPIAnywareSbcl`. See CONTEXT.md
  *`libAPIAnywareSbcl` / sbcl trampoline layer*.

## Settled in this session (recorded; ADRs authored in the child leaves)

- **D6 — Dispatch (grilled, user-chosen):** per-selector `defgeneric`/`defmethod`
  **specialized on the receiver** over the real metaclass-backed class graph.
  Idiomatic subclass override + `call-next-method` + method combination; **not**
  literal multiple-argument dispatch (ObjC is single-receiver). Holds D3's line
  against the single-dispatch veneer of all prior CL bridges, dodging the
  "vacuous" critique the gerbil-ADR-0020 way (dispatch over a *real* graph).
  **Carry-forward risk:** generic-function explosion + compile cost — gerbil hit
  5h→8.4min and sharded (ADR-0023). Manage in the object-model child leaf.
- **Q7 fork — settled by precedent:** the trampoline layer is **per-target
  hermetic**, *not* a family-shared substrate (ADR-0011 + gerbil ADR-0029, which
  closed the identical fork). SBCL grows a **trampoline-only `libAPIAnywareSbcl`
  dylib** because — like gerbil's `gsc` — SBCL cannot compile Swift inline; the
  dylib does **not** absorb the MOP runtime.
- **Q1 surface — pre-judged by 020 §7.2:** adopt CCL's conventions wholesale
  (`ns:` package, **acronym-aware** kebab-case naming, keyword-list selectors,
  `#/`/`@` reader macros). Inventing our own buys nothing and forfeits de-facto
  portability with existing CL-Cocoa code.
- **Contract spec placement (D5a open item — decided):** **main-tier**
  (`docs/specs/`), since the contract is *cross-target* within the CL family
  (not a per-target unit — ADR-0024).

## What stays genuinely open (child-leaf design content)

020 §6/§7 left these *un-de-risked by prior art* — design first-hand (read CCL
source + `sb-mop`; lean on in-repo ADRs), do **not** assume:

- SBCL's own **AMOP conformance** for the hooks the projection needs (§6.1).
- The **slot/ivar mechanism** (§5.1 refuted the assumed `slot-value-using-class`).
- ~~**`NSError**` → condition hierarchy** (C2 — zero prior-art evidence).~~
  **CLOSED** by leaf 030 → ADR-0037 (`ns:objc-error` flat hierarchy; back-fills
  contract §3.7).
- ~~**Lifetime** (D1) and **threading/callbacks** (D2).~~ **CLOSED** by leaf 030 →
  ADR-0036 (lifetime: `sb-ext:finalize` + main-thread release queue) and ADR-0035
  (threading: bounce-always — chez activation rejected, **spiked** 5/5 crash).
- **Static-emit + startup re-resolution** (§B5): a dumped image carries baked
  class metadata but **stale foreign `Class`/`SEL` pointers**; needs a CCL
  `revive-objc-classes`-equivalent startup pass — load-bearing for `070`
  `save-lisp-and-die`.
- **LispWorks divergence** (§7.6): non-metaclass model — does the contract
  privilege the metaclass shape or abstract over both?

## Child leaves (ordered)

- **010-contract-and-family-adr** — author the CL-family interface contract spec
  (adopt CCL conventions; resolve the LispWorks-divergence question) **and** raise
  the family-axis ADR (D5; cite Objective-CL's per-impl-breakage post-mortem,
  020 §C3). Defines the contract's **two layers** (upper `ns:`/CLOS surface; lower
  `libAPIAnywareSbcl` C-ABI).
- **020-object-model** — the MOP realization: `objc-class` metaclass, re-derive
  the slot mechanism first-hand against `sb-mop`, AMOP-conformance check, dispatch
  per **D6** (incl. the generic-explosion/compile-cost mitigation), static-emit
  class graph + the startup re-resolution pass (§B5). Raise object-model + dispatch
  ADR(s).
- **030-lifetime-threading-conditions** — D1 lifetime (`sb-ext:finalize`/weak/
  guardian + entry-point autoreleasepool), D2 threading/callbacks
  (`define-alien-callable` + `sb-thread` + main-thread bounce — choose model),
  C2/Q8 conditions (`NSError**` → condition hierarchy; chez ADR-0006 precedent;
  gerbil `ThrowsBridge` for the trampoline path). Raise ADR(s).
- **040-trampoline-layer** — Q7 lower layer in detail: `libAPIAnywareSbcl`
  trampoline-only dylib (port gerbil ADR-0029), typed `sb-alien` binding of the
  C-ABI residual, interaction with `save-lisp-and-die` + the startup
  re-resolution. Raise the sbcl-trampoline ADR. Authors / finalizes the **SBCL
  target design spec** (`generation/targets/sbcl/docs/design/…-sbcl-target-design.md`)
  as the synthesis of 010–040.

## Done when

- Each open question settled with a recorded decision; ADRs raised (family-axis at
  minimum, plus object-model/dispatch, lifetime/threading/conditions, trampoline).
- CL-family contract spec written (main-tier); SBCL target design spec written.
- The build leaves (040–080) refined in light of the settled design.

## Notes

- Decompose lazily — these four children are the *known breadth* of the design
  (enumerated by the parent brief + 020), not speculative depth. Let each grow
  further leaves only if its own grilling reveals the need.
