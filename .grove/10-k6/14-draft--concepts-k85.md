# concepts-k85

## Goal

Give exact syntax a single reader-facing home: land the grammar description
and the eleven existing G10 railroad views in `reference/notation.md`, then
link to it from the landing page and canonical reading aids.

## Context

- Human direction: model-reading-k73, D6–D8. Preserve its distinction between
  explaining AIL-specific meaning and narrating familiar punctuation.
- Structure brief: plan §9.2, *Example-led refinement*, and §9.4's grammar
  portion. Plan §4–§7 govern prose, labels, figures and checks.
- `grammar.ebnf` is authoritative; the existing `figures/g10-*.puml` and SVGs
  are non-normative views. Reuse them and the checked examples.
- Canonical aid conventions: rule-reading-k49's brief, paired reading-aid
  comments, blockquote borders, bold labels and explicit anchors; stripping
  aids recovers revision `87221b8c`.

## Done when

- `reference/notation.md` has a page-one block, a short model route, a link to
  the exact grammar and its EBNF dialect, and all eleven G10 views: shell,
  clause, names, callable, places, environment, pattern, outcome, callback-use,
  dependency and access. Each has a stable section anchor, named productions,
  a rule route and an example route. Explain the grammar's boundary, including
  generic clause syntax versus vocabulary and constraints supplied by rules;
  omit elementary punctuation and railroad-reading lessons.
- The landing map links this page directly while `reference/README.md` is
  absent; the new page's return and onward routes lead to existing pages.
- Replace every G10 embed in the non-normative aids of `language.md`,
  `contracts.md` and `profiles.md` with a link to the relevant new section.
  Preserve every local example, meaningful explanation and stable anchor.
  The later explanation/tutorial drafts will migrate their own embeds.
- Stripping reading aids still reproduces the three rule pages byte for byte
  from `87221b8c`; the grammar, frozen fixtures and existing figure source/SVG
  pairs are unchanged. Check each railroad against its named productions.
- Record the eleven section anchors and the old-to-new syntax routes here
  for concepts-k74–k76 and reference-k16; `task docs:check` passes.

## Notes

First of four drafts in the existing bounded concepts run. Concepts-k74–k76,
copy-edit, art and proof are already queued; cut nothing. This is a complete
grammar-lookup increment, not the later clause inventory or indexed reference.
Reference-k16 extends this page with entry conventions and reference indexes.
Hand figure defects to the queued art stage; do not create a new correction run.
