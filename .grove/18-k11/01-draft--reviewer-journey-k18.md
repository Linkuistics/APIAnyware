# reviewer-journey-k18

## Goal

Integrate navigation across the finished set and append the Step 2 index to the audit.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §9.6. It states the reader and outcome, the ordered
  sections with their purposes, and the emphasis and non-goals. Quote it
  rather than re-deriving it.
- Prose contract, labels, figures and checks: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §4–§7.
- Evidence: the audit (`semantic/docs/research/interface-language-documentation-audit.md`) and the survey's §9 criteria D1–D8.

## Done when

- Every page has an inbound link from the map or its parent index. Links
  between rules, entries, explanations, tutorial parts and review tasks run
  both ways, and so do the model routes: the model page's concept sections and
  map rows link their reference entries and review tasks, which link back.
- The final syntax routes follow model-reading-k73: G10 embeds and the
  grammar description live in `reference/notation.md`; every other page's
  syntax links reach the relevant section while its local example context
  remains. Walk this from explanations, tutorial, canonical aids and review.
- The audit's "Step 2: refactored output" section maps F1–F12 to their
  resolving pages, gives the status of Q1–Q6 and any added questions, and
  names what remains unresolved.
- `task docs:check` passes.

## Notes

This is navigation work. Rewording elsewhere is limited to what a broken journey forces, and anything larger is handed back as a correction run to the owning document.

This is the node's last draft session, so its last act is `leaf-add` of the `copy-edit` leaf, unless a live later sibling already holds one.
