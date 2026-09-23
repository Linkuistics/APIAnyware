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

- `task docs:coverage` extracts candidates from every normative source and
  checks them against a committed disposition list, as the plan's §7
  specifies. The extraction covers running prose as well as tables. Every
  prose-defined clause named in audit F5 appears as a candidate, and the list
  classifies all of them.
- It has been seen to fail on an unclassified candidate, on a missing entry
  in a landed file, and on a disposition naming nothing in the sources. It
  lists by name which entries the next three sessions own, as pending.
- Under the staging rule in the plan's §3, the landing map links
  `reference/README.md`, which links every reference page that exists and
  names the clause files as plain text until they land.
- Declaration and type entries use the §9.4 fields that apply.
- Page-one blocks are the only change to the normative files.
- The plan's §2 clause-file split is confirmed or amended against the entry
  count.
- `task docs:check` passes.

## Notes

Until the clause files exist, `docs:coverage` may report their entries as pending; make that state explicit rather than passing silently.

A later draft sibling finishes this document, so do not cut `copy-edit` here: the last draft session does.
