# reference-k16

## Goal

Draft `reference/README.md`, `notation.md`, `types.md` and `declarations.md` with the applicability table. Add page-one blocks to the normative and supporting files, and add `task docs:coverage` with its enumerated inventory.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §9.4. It states the reader and outcome, the ordered
  sections with their purposes, and the emphasis and non-goals. Quote it
  rather than re-deriving it.
- Prose contract, labels, figures and checks: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §4–§7.
- Evidence: the audit (`semantic/docs/research/interface-language-documentation-audit.md`) and the survey's §9 criteria D1–D8.

## Done when

- `task docs:coverage` builds the inventory from the sources: productions,
  clause names from the normative tables' first columns, rule identifiers and
  mutation IDs. It has been seen to fail on a missing entry, and it lists
  which entries the next three sessions own.
- Declaration and type entries use the §9.4 fields that apply.
- Page-one blocks are the only change to the normative files.
- The plan's §2 clause-file split is confirmed or amended against the entry
  count.
- `task docs:check` passes.

## Notes

Until the clause files exist, `docs:coverage` may report their entries as pending; make that state explicit rather than passing silently.

A later draft sibling finishes this document, so do not cut `copy-edit` here: the last draft session does.
