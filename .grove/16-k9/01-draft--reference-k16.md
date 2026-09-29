# reference-k16

## Goal

Draft `reference/README.md`, `types.md` and `declarations.md` with the
applicability table; extend the existing `notation.md` with entry conventions
and index routes. Verify and extend the normative pages' existing reading
routes, add page-one blocks to the supporting files, and add `task
docs:coverage` with its enumerated inventory.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §9.4. It states the reader and outcome, the ordered
  sections with their purposes, and the emphasis and non-goals. Quote it
  rather than re-deriving it.
- Prose contract, labels, figures and checks: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §4–§7.
- Evidence: the audit (`semantic/docs/research/interface-language-documentation-audit.md`) and the survey's §9 criteria D1–D8.
- Read first-path-reading-k48 and first-path-reading-k64 for the human's
  assessments, then model-reading-k73's example-led refinement. Rule-reading-k49
  supplies the normative pages' context blocks, local examples and language
  model; concepts-k85 supplies the grammar/railroad home. Preserve and reuse
  them, with syntax figures kept on `reference/notation.md`.

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
- The existing grammar description, all eleven G10 views, section anchors
  and incoming links survive the extension of `notation.md`. The reference
  index adopts this already-landed page. Other entries show their forms and
  examples, link to its grammar sections, and omit elementary punctuation
  narration while explaining AIL-specific meaning.
- Normative wording, anchors and grammar remain unchanged. Existing labelled
  reading aids remain available; only their context/navigation is extended
  to the new reference. The entries illustrate local/imported declarations,
  a member and receiver, and declaration/slot/place references in context.
- The plan's §2 clause-file split is confirmed or amended against the entry
  count.
- The disposition list records the plan §10 model concept of every
  entry-class item, and `docs:coverage` has been seen to fail on an entry with
  no concept or a concept that is not an anchor on `explanation/model.md`.
  Every §10 concept has an entry or a recorded reason.
- Declaration and type entries carry the *Expresses* field (plan §9.4), and
  `reference/README.md` has a model-concept index covering the entries that
  exist, with the pending clause entries named.
- `task docs:check` passes.

## Notes

Until the clause files exist, `docs:coverage` may report their entries as pending; make that state explicit rather than passing silently.

A later draft sibling finishes this document, so do not cut `copy-edit` here: the last draft session does.
