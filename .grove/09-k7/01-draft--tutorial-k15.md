# tutorial-k15

## Goal

Design the tutorial's synthetic API and draft `tutorial/README.md` and parts 1–3, with their checkpoint packages in `examples/tutorial/`.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §9.3. It states the reader and outcome, the ordered
  sections with their purposes, and the emphasis and non-goals. Quote it
  rather than re-deriving it.
- Prose contract, labels, figures and checks: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §4–§7.
- Evidence: the audit (`semantic/docs/research/interface-language-documentation-audit.md`) and the survey's §9 criteria D1–D8.

## Done when

- The API design is recorded in `tutorial/README.md`, and it differs on the
  surface from the conformance examples.
- Parts 1–3 follow §9.3's per-part order. Each checkpoint is a complete
  package for a narrower declared `surface`, using region markers, and each
  part has an invalid variant that cites its rule.
- For each checkpoint, a note in this leaf's decision log records its
  inspection against the grammar and each applicable rule.
- Every checkpoint, from part 1 on, carries the `access` blocks A2 requires
  on its functions, with their provider dependencies (plan §9.3).
- Under the staging rule in the plan's §3: the landing page's map and the concept pages link
  `tutorial/README.md`; the index links parts 1–3 and names parts 4–5 as
  plain text; each part has a return route and a next route to an existing
  page.
- `task docs:check` passes.

## Notes

If an unclear rule blocks the natural design, choose a construct the rules settle and add the question to `explanation/choices.md`'s register. Do not invent a rule.

A later draft sibling finishes this document, so do not cut `copy-edit` here: the last draft session does.
