# tutorial-k20

## Goal

Draft tutorial parts 4 and 5: callbacks and teardown, access paths, the finished package, and the guided change from a borrowed to an owned result.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §9.3 (parts 4–5). It states the reader and outcome, the ordered
  sections with their purposes, and the emphasis and non-goals. Quote it
  rather than re-deriving it.
- Prose contract, labels, figures and checks: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §4–§7.
- Evidence: the audit (`semantic/docs/research/interface-language-documentation-audit.md`) and the survey's §9 criteria D1–D8.

## Done when

- Parts 4 and 5 follow §9.3's per-part order, and the final package is
  complete under draft 0.1 by inspection, with an inspection note in this
  leaf's decision log.
- The guided change lists every clause and rule it touches, as observations
  that can be checked by inspection.
- The landing page and the concept pages link to the tutorial, and the
  tutorial index links parts 4 and 5, replacing its plain-text entries and
  part 3's interim next route (plan §3, *Staging*).
- `task docs:check` passes.

## Notes

The tutorial API's design is in `tutorial/README.md`, from the previous session. Extend it; do not redesign it. If redesign is unavoidable, it is a correction run of part 1.

This is the node's last draft session, so its last act is `leaf-add` of the `copy-edit` leaf, unless a live later sibling already holds one.
