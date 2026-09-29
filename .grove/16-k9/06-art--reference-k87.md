# reference-k87
## Goal

Read the complete reference set under the art charter and check that its
figures serve the examples, model relationships and exact-lookup tasks.

## Context

- Structure brief: documentation plan §9.4 at
  `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`.
  Prose, page-one, figure and check contracts are §4–§7; model names are §10.
- Read all eight pages in `semantic/specification/interface-language/reference/`.
  The reference reuses G9 in declarations and eleven G10 views in notation.
  No new figure slot or unresolved technical finding is handed forward.
- Copy-edit corrected stale lookup wording, ambiguous closure terminology,
  the package omission label, repeated declaration-field prose, glossary routes
  and identifier typography. Examples, headings, anchors and field order are
  unchanged. Normative files and grammar remain unchanged.
- Keep railroad views with grammar, their unboxed non-normative captions and
  the user's assumed railroad fluency. Preserve source-plus-generated-SVG
  pairs and the shared visual vocabulary. Distinguish the G9 language
  containment view from the API model.

## Done when

- Figures, captions, placement and accessible alternatives meet the art
  charter and plan §6 across the full reference set.
- `task docs:check` and
  `python3 semantic/specification/tools/docs_coverage.py semantic/specification/interface-language --require-complete`
  pass; normative wording, grammar, example contracts and anchors are preserved.
- Add the mandatory proof successor under the editorial-family rule unless
  a live later sibling already holds it.

## Notes

Preserve callback declaration versus registration-schedule distinctions,
global/constant output-clause scope, optional fixture facts with no specified
defaults, and N11/N14's implementation/runtime qualifications. Art owns figures;
sentence-level copy editing is complete. Reference-k9 remains live.
