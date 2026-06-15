# 020-record-the-model

**Kind:** work

## Goal

Record the **complete-API binding model** durably, at the stable abstract level
(D3). The model is user-confirmed (charter); this is recording, not deciding.

## Context

Refines ADR-0010 / ADR-0011. The three glossary terms are **already** in
`CONTEXT.md` (added in 010-plan: *complete-API binding model*, *trampoline*,
*trampoline elision*). This leaf does the remaining two founding recording acts.

## Done when

- **ADR-0025** written (`docs/adr/0025-complete-api-model-and-trampoline-elision.md`):
  refines ADR-0010 with the complete-API model + the trampoline-elision
  optimisation. Frame the current targets as the **fully-elided limit**, not an
  ObjC-only deviation. Cite the charter and the **traced file:line evidence** from
  the root BRIEF Notes (drop filter `declaration_mapping.rs:164-175`; dead `source`
  / `provenance.rs`; merge.rs; un-walked Macro/TypeAlias/AssociatedType). Keep it
  at the model level — IR-shape (030) and trampoline-structure (040) decisions get
  their **own** ADRs/specs later; this ADR must not pre-empt them.
- **README** design-goal preamble states the model (per charter act 3).

## Notes

- Allocate **0025** (last ADR is 0024). Verify no race before writing.
- CONTEXT terms done — do **not** re-add; cross-check wording matches the ADR.
