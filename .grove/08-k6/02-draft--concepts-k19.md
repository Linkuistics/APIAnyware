# concepts-k19

## Goal

Draft `explanation/packages.md` and `explanation/choices.md`, and add the concept pages to the landing page's map and their terms to the glossary.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §9.2 (the `explanation/packages.md` and `explanation/choices.md` parts). It states the reader and outcome, the ordered
  sections with their purposes, and the emphasis and non-goals. Quote it
  rather than re-deriving it.
- Prose contract, labels, figures and checks: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §4–§7.
- Evidence: the audit (`semantic/docs/research/interface-language-documentation-audit.md`) and the survey's §9 criteria D1–D8.

## Done when

- Both pages follow §9.2's section order. Every choice section names at
  least one alternative and one cost.
- The open-question register holds audit Q1–Q6 and every item from the node
  brief's `## Questions found`, each with where it arises and why it matters;
  that note is then cleared.
- The landing page links all three concept pages, and the glossary covers
  their terms.
- `task docs:check` passes.

## Notes

The design proposal's syntax sketch is a historical fragment and must be labelled so. Do not supply a rationale for the ownership-in-clauses decision (Q3). Report that none is recorded.

This is the node's last draft session, so its last act is `leaf-add` of the `copy-edit` leaf, unless a live later sibling already holds one.
