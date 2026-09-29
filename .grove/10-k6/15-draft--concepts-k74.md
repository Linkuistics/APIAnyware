# concepts-k74

## Goal

Revise `explanation/contracts.md` so it describes AIL by reference to the
model: each section names the model concept it writes down, recalls its case,
and then shows how AIL expresses it, in the model's concept order.

## Context

- Structure brief: plan §9.2, *Model-first run* block (the revised section
  order for this page governs where it conflicts with the older list).
- Concept names, anchors and the construct map: plan §10. Prose contract:
  plan §4 (*Make the model the main thread*, *Two models, one purpose*,
  *Domain before notation*).
- The landed model page `explanation/model.md` and the outcome of
  `model-reading`: use the concept set as the human left it.
- Model-reading-k73's example-led refinement, plan §9.2. Concepts-k85 lands
  the grammar/railroad sections in `reference/notation.md` before this leaf.

## Done when

- The page follows the revised order: operations and values (two sections),
  outcomes, entities and their lifecycles, release responsibility, validity,
  storage, execution, callbacks, patterns and laws (or kept in the entities
  section, with the reason recorded here), profiles.
- Every notation-introducing section opens with its concept's `model.md` name
  and link and the reader's task, recalls the concrete case in a sentence or
  two, and only then shows a located snippet. No section re-teaches the model.
- Every construct introduction on the page is enumerated in this leaf with its
  §10 concept.
- The prose explains AIL-specific meaning and model consequences. Remove the
  quoted punctuation walkthrough in *From signature to contract* and similar
  elementary syntax narration elsewhere, retaining useful explanations of
  reference/place meaning and context.
- Existing examples, figures G4–G7, rule citations and anchors are kept.
  Replace G10 embeds with links to the relevant grammar-reference sections;
  moved or renamed headings keep their old slugs via explicit
  anchors, and incoming links across the set still resolve.
- The model page's closing map links the renamed sections.
- `task docs:check` passes.

## Notes

Second of four draft sessions in the one bounded model-first run authorized by
the human's 2026-09-29 direction (node brief). Later drafts, copy-edit, art
and proof are already queued, so cut nothing at the end. Do not change rule
semantics or examples' contracts; a model/rule mismatch becomes a question in
`explanation/choices.md`.
