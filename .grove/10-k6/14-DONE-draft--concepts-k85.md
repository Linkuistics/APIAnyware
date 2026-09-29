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

## Decisions (running log)

- D1: Use the eleven G10 file stems as explicit section anchors in
  `reference/notation.md`: shell, clause, names, callable, places, environment,
  pattern, outcome, callback-use, dependency and access. Keep the plan's order.
  Each section connects the model concept to a checked example, the named
  productions and canonical rules. The generic clause/vocabulary boundary
  follows the views, as §9.4 specifies.
- D2: Reuse existing example regions and figure files. Canonical aids retain
  their examples and explanations; replace embeds and redirect syntax-view
  links to the new anchors. The meaning-focused prose revision remains k76's
  work. The queued copy-edit, art and proof leaves discharge the successor rule.

## Syntax routes for following drafts

All destinations below are in
`semantic/specification/interface-language/reference/notation.md`. The stable
section anchors match the G10 stems so k74–k76 and reference-k16 can link
without inventing another naming scheme. Canonical reading-aid anchors remain
in place for their examples; the old locations below now link to the grammar
section instead of embedding its SVG.

| Old embedded view / canonical location | New section | Named productions |
|---|---|---|
| G10 shell / language L1 `l1-shell` aid | `#shell` | `document`, `item`, `clause` |
| G10 clause / language L1 `l1-clauses` aid | `#clause` | `clause`, `arguments`, `value`, `constructor`, `list` |
| G10 names / language L2 `l2-references` aid | `#names` | `import`, `reference`, `name` |
| G10 callable / language L2 `l2-references` aid | `#callable` | `callable`, `parameters`, `parameter` |
| G10 places / language L2 `l2-references`, contracts C1 `c1-places` aids | `#places` | `place` |
| G10 environment / language L3 `l3-publication` aid | `#environment` | `environment` |
| G10 pattern / language L6 `l6-roles` aid | `#pattern` | `pattern`, `role`, `instance` |
| G10 outcome / contracts C5 `c5-outcomes` aid | `#outcome` | `outcome` |
| G10 callback-use / contracts C6 `c6-schedule` aid | `#callback-use` | `callback_use` |
| G10 dependency / profiles A1 `a1-dependencies` aid | `#dependency` | `dependency` |
| G10 access / profiles A2 `a2-paths` aid | `#access` | `access` |

The table's aid names are paired source-comment identifiers, not URL
fragments. Incoming public anchors are unchanged. Callable-body and value-view
links within the canonical aids now point directly to `#callable` and
`#clause`; the C1 place-view link points to `#places`. The landing map has a
direct grammar-reference row while the reference index is still absent.

The new section openings map shell/clause/names/environment/dependency to
the published description, callable/places to operations and values, pattern
to entity relationships (with the slot example's narrower purpose explicit),
outcome to how a call finishes, callback-use to callbacks and their schedules,
and access to reaching the code. Each opening links the canonical model.

## Verification

- `task docs:check` passed: links and example checks covered 21 files, all 19
  reader pages were reachable, and all 26 SVGs reproduced. SHA-256 digests
  before/after covered 106 files: the interface-language tree, documentation
  tools excluding `__pycache__`, Taskfile, plan and audit. No subject moved.
- Removing paired reading-aid blocks and their trailing blank separator
  recovered `language.md`, `contracts.md` and `profiles.md` byte-for-byte from
  `87221b8c`. Mutating a canonical `MUST` to `SHOULD` in memory made each
  comparison fail, checking the preservation instrument.
- Every G10 source production matched its named `grammar.ebnf` production
  after whitespace normalization. All eleven views occur in notation;
  canonical-page image inventories contain no G10 embeds. The same inventory
  found embeds in each parent-revision canonical page, in the still-unmigrated
  explanation page and in an injected image, supplying positive controls.
- Canonical explicit anchors and AIL fence bodies are identical to parent
  `c01884c8`. The grammar, every existing `.ail` example and all figure
  source/SVG/style files are byte-identical to that parent.
- One bounded fresh-context technical reviewer checked the full new page
  against the grammar, canonical rules and draft contract and returned no
  substantive findings. No second reviewer or correction run was created.
- Graph generation `2026-09-23T09:55:55Z` reports excluded examples/design
  documents and stale or untracked documentation/figure metadata. Technical
  conclusions use direct source reads and byte/production comparisons, not
  graph completeness. These checks establish document consistency and
  preservation, not runtime conformance or human comprehension.

The later draft, copy-edit, art and proof leaves remain live under this node;
no successor or parent-chain closure is needed for this increment.
