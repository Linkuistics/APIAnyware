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

## Decisions (running log)

- Retain G9 and the eleven G10 views with their existing sources and SVGs.
  Their named grammar productions agree with `grammar.ebnf`; grammar figures
  stay in notation, and G9 stays the language-containment view.
- Use small Markdown tables for multiway classifications and operand mappings
  currently carried by prose: type categories, role cardinalities, sharing,
  enum/flags domains, direction, retention, regions, output states, predicates
  and compatibility. Keep entry fields, examples and anchors in their order.
  Add explicit reader tasks beside existing indexes and G9.
- Declined additional lifecycle, callback and access diagrams: editorial
  judgement. Located examples and links to the existing semantic figures
  already carry those relationships; repeating full explanation diagrams
  would displace exact lookup. Neither a contract prohibition nor a medium
  limitation motivated this choice.
- The shared `runtime` spelling also needs an operand comparison by scope;
  table it in the existing operands field. Link `bind` to the role cardinality
  table rather than repeat the same mapping in prose.
- Keep the existing narrow lookup indexes and applicability/mechanism tables.
  Their rows carry the cross-entry mappings; individual binary examples do not
  need an additional diagram where their located code already shows the relation.
- Inspected all twelve reference SVGs as rendered images. Retain their layout,
  shared vocabulary, G9 key and unboxed railroad captions. The linked EBNF is
  the exact textual alternative to the railroad paths. These inspections are
  consistency and legibility evidence, not a human comprehension assessment.
- Graph generation `2026-09-23T09:55:55Z` has untracked/changed documentation
  metadata and excludes `semantic/docs`; coverage checked for the evidence
  paths. Findings use direct Markdown, grammar and diagram-source reads plus
  rendered SVG inspection; no structural code claim relies on the graph.

## Validation

- `task docs:check`: passed, including byte-identical regeneration of all 26
  SVGs, links/reachability, example synchronization and reference coverage.
- Required complete coverage: 229 candidates, zero pending, zero errors.
- Compared all eight reference pages with parent `e2cbf79f`: headings,
  explicit anchors, fenced examples and entry-field order are unchanged.
  `language.md`, `contracts.md`, `profiles.md` and `grammar.ebnf` are
  byte-identical to that parent. No example or diagram asset was edited.
- SHA-256 manifests before and after the final checks match. Subjects were
  all files enumerated under `semantic/specification/interface-language/`
  and `semantic/specification/tools/`, plus root `Taskfile.yml`, the
  documentation plan and the documentation audit. No subject changed during
  the measured run. The reference Markdown has no trailing whitespace or
  conflict markers.
- No unresolved finding is handed forward. Added proof successor
  `reference-k88`; `reference-k9` remains live, so no parent close applies.
