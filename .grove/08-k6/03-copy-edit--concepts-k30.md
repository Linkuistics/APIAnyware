# concepts-k30

## Goal

Copy-edit all three concept explanations and their glossary/navigation additions
against the documentation plan's prose contract, to a green final validation.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`
  §9.2. Prose, page-one blocks and labels: §4–§5; checks: §7. Apply the
  survey's copy-edit criteria to the whole set.
- Read `explanation/contracts.md`, `explanation/packages.md` and
  `explanation/choices.md` in `semantic/specification/interface-language/`,
  together with their glossary entries and navigation in `README.md` and
  `explanation/unsaid.md`.
- Preserve Q1–Q6 in the choices register. Q3 has no recorded rationale;
  benefits/costs assessed from rules are not the authors' historical reasons.
- Keep the qualification on explicitness: required core facts have no guessed
  fallback, while L5 has optional clauses and A1 admits defined profile defaults.
- The choices page counts `buffers.view` as 23 clause statements (14 body,
  five outcome, four access), excluding nested constructors and package context.
  Its historical `read` sketch differs from the immutable fixture contract and
  is labelled as historical text, not draft 0.1 syntax.
- Example extracts match frozen `.ail` files. Their surrounding synthetic
  labels and omitted-context labels carry meaning; retain them.
- Figures G2/G3/G5–G7 are handed to art in the node brief. No figure is needed
  for copy-edit to run; every relation is already in prose.

## Done when

- The whole concept set has been read and sentence/terminology defects within
  the copy-edit charter fixed; technical or structural findings use the
  editorial family's correction mechanism rather than silent redesign.
- First-use term links, explicit actors, sentence-case headings and example
  labels follow the prose contract; alternatives and costs remain visible.
- `task docs:check` passes. This checks links, exact example extracts and
  existing diagram regeneration, not AIL semantic conformance or human comprehension.
- Add the next `art` leaf with bare stem `concepts`, unless one is already
  queued, under the editorial family procedure.

## Notes

The preceding drafts completed structure and technical-truth inspection without
claiming parser, validator, runtime or reader-test results. All three concept
pages now have landing-map links and existing next/return routes. The tutorial
and review guide are still forthcoming.
