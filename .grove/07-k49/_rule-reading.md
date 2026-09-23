# rule-reading-k49 — brief

## Goal

Make the existing canonical rule pages understandable when read directly by
adding explained examples, language-model diagrams and selected railroad
views beside their introductions. Preserve the normative wording and grammar.

## Contract

The structure brief is §9.7 of
`semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`.
Its §4–§6 govern examples, prose and figures; §7 governs the documentation
checks. The human's verbatim assessment is `first-path-reading-k48`, D2.
H5 concerns local/imported declarations and members; H6 concerns notation
introduced without its model or containing context.

## Decomposition

Two draft sessions, then copy-edit → art → proof. The first draft handles
`language.md` L1–L6 and the common model/syntax examples; the second handles
`contracts.md` C1–C8 and `profiles.md` A1–A5/F1. Only the second cuts copy-edit.
Later stages read all three pages. All stage leaves use the stem rule-reading.
Record needed figures in a Handed forward section for art.

This is the first editorial pipeline for these reading aids. It is separate
from, and precedes, the human-directed second corrections in orientation,
concepts and tutorial. A defect that would send this work back is recorded for
`first-path-reading-k64`; do not start a further unattended cycle.

## Done when

- The three canonical pages supply local context and explained snippets as
  constructs are introduced, with a page-one block and labelled reading aids.
- The language model locates packages, declarations, imports, members and
  callable slots; concrete examples distinguish every reference form cited
  in the human's L2 feedback, including a named receiver and bare type names.
- G9/G10 and any necessary detail figures have sources and regenerated SVGs,
  keys, reading order, adjacent explanation and grammar/rule traceability.
- The original normative text, stable rule anchors, grammar and fixture
  catalogue are preserved and their preservation is checked explicitly.
- `task docs:check` passes; snippets match committed fragments and examples
  have truthful scope labels. Direct rule entry and overview-to-rule routes
  were inspected. No semantic-validator or human-comprehension claim follows.
- The following document corrections can reuse the actual landed examples
  and figures; their paths and boundaries are carried into the root brief.

## Notes

The human requests examples at the quoted L2 paragraphs themselves. A link to
a future reference entry alone does not meet that requirement. Keep explanatory
additions distinct from requirements and introduce one relationship at a time.
Complete examples remain complete; a partial teaching fragment states its
omitted context. No new language feature or runtime test seam is in scope.
