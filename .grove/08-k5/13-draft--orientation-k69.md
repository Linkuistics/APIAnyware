# orientation-k69

## Goal

Draft `explanation/model.md`, the canonical account of the model of API
behaviour and binding obligations, and make the orientation pages lead to it.
A reader finishing the domain page can then name the entities a description
records, how they relate, and which question each concept answers, before
meeting any AIL notation.

## Context

- Structure briefs: plan §9.8 (the model page) and §9.1's *Model-first run*
  block (landing page, domain page, glossary), in
  `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`.
- The concept set, order, anchors and construct map: plan §10. The learning
  route: plan §3. The prose contract, including *Two models, one purpose* and
  *Make the model the main thread*: plan §4. G11: plan §6.
- The human's direction and rationale: first-path-reading-k64, D12–D13.
- Existing material to reuse, not replace: the watch API and the six
  obligation sections of `explanation/unsaid.md`; the landing page's workflow
  and G1; G4–G7 and G9 for names and relations.

## Done when

- `explanation/model.md` exists with §9.8's ordered sections and an explicit
  anchor for every §10 concept, in §10 order. Its concept sections show no AIL
  snippets; construct names appear only in the closing map.
- The closing map links, for each concept, the concept-page section and
  tutorial part that introduce its notation *as they exist today* (for
  example, *Lifecycles and patterns* until the concepts run splits it), and
  cites its rules. The concepts and tutorial runs update those links when they
  rename sections.
- G11's slot is recorded under this node's `## Handed forward` for `art`,
  with the entities and relations the prose establishes. The prose carries
  every fact the figure will show.
- The landing page links the model page from its map and paths table, and the
  domain page's obligation sections and *Where next* route to it (plan §3,
  *Staging*). The glossary links concept anchors as §9.1 states.
- The two k64 residues are repaired: the "railroad reading key" link text in
  `README.md` and `glossary.md`, and the "explicit end marker" description of
  reading aids in `README.md`.
- Existing explanations, examples, figures and anchors on the orientation
  pages are preserved; a renamed heading keeps its old slug.
- `task docs:check` passes.

## Notes

This is the first leaf of the one bounded model-first run authorized by the
human's 2026-09-29 direction (see the node brief). Copy-edit, art and proof
are already queued behind it, so cut nothing at the end.

If the concept set in §10 proves wrong while drafting — a concept the model
page cannot state affirmatively, or one construct with no concept — record
the change and its reason in this leaf, update §10 and the anchors in the same
session, and say so for `model-reading`. Do not change language semantics:
a mismatch between the model and the rules becomes an open question in
`explanation/choices.md`.

If the model page and the three routing edits do not fit one session, land
the model page with its landing-map link first and decompose.
