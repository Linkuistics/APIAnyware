# reference-k88

## Goal

Read the complete reference set under the proof charter, fix remaining defects
and verify exact lookup from the model, syntax, declaration and clause routes.

## Context

- Structure brief: documentation plan §9.4 at
  `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`.
  Prose, page-one, figures and checks are §4–§7; model concepts are §10.
- Read all eight pages in `semantic/specification/interface-language/reference/`
  and the node brief's full acceptance conditions, including the canonical,
  supporting, explanation, tutorial and glossary lookup routes.
- Art converted prose mappings into tables for type categories, role counts,
  runtime operands, sharing, enum/flags domains, direction, retention, regions,
  output states, predicates and compatibility. It added reader-task sentences
  beside the existing indexes and G9. `bind` links to the role cardinality table.
- G9 and all eleven G10 sources/SVGs are unchanged. G9 is language containment;
  G11 is the API model. Railroads stay with grammar in notation, keep unboxed
  non-normative captions and assume railroad fluency.
- No unresolved art finding is handed forward. Art's checks passed:
  `task docs:check`, complete coverage (229 candidates, zero pending/errors),
  and preservation of headings, anchors, examples and entry-field order across
  all eight pages. Canonical rules and grammar match `e2cbf79f` byte-for-byte.
  Treat these as consistency checks, not evidence of human comprehension.

## Done when

- Whole-set proof and the node's lookup/coverage acceptance conditions hold.
- `task docs:check` and
  `python3 semantic/specification/tools/docs_coverage.py semantic/specification/interface-language --require-complete`
  pass, with canonical wording, grammar and example contracts preserved.
- Retire and commit this leaf, settling any justified parent-chain close
  through the ordinary Grove procedure. Proof cuts no ordinary successor.

## Notes

Preserve callback declaration versus registration-schedule scope; output clauses
in globals and accessed constants; optional fixture facts with no specified
defaults; N11's implementation-truth and N14's runtime-size qualifications.
Keep explicit anchors and model-concept names. The art changes are presentation
of existing facts, with their rule citations and remaining constraints in place.

## Decisions (running log)

- The integer-production lookup reaches the grammar introduction but supplies
  no integer-token entry. Add a located, non-normative lexical entry citing L1,
  distinguish signed literals from unsigned type arguments, and update its
  disposition and model index together. Preserve grammar and example sources.
- Remove the glossary link on the ordinary phrase “in place of”; it incorrectly
  sends a prose replacement idiom to the callable-place concept.
- Name Operations and their values alongside The published description in the
  shared names/reference entry, matching the slot-reference concept recorded
  by the disposition and model index. No language decision or ADR changes.

## Verification and node close

- Read all eight reference pages, the canonical rules without their reading
  aids, the grammar, mutation catalogue and dispositions. Checked entries,
  tables and summaries for scope, requiredness, defaults and cross-page
  consistency. Compared G9's named relationships and every G10 production
  with the surrounding examples and grammar. Figures remain unchanged.
- Walked the reference index's model/rule/mutation/clause routes, notation
  to declarations/types, declaration applicability to clause entries, and
  each clause page's example/rationale/canonical-rule routes. Checked the
  incoming canonical, supporting, explanation, tutorial and glossary routes.
  The integer lookup gap and two terminology/concept issues above are fixed;
  no unresolved item is handed forward or sent back.
- `task docs:check` passed: 28 Markdown files checked, 26 pages reachable,
  example/source agreement, all 26 SVGs reproduced, and complete reference
  coverage. The separate required `docs_coverage.py ... --require-complete`
  run reported 229 candidates, zero pending and zero errors.
- The three canonical Markdown files, grammar, example sources and figure
  assets are unchanged from `e2cbf79f` (`jj diff`: zero files changed).
  The same diff command shows the expected reference changes against the
  parent. Existing anchors and examples survive; the integer entry reuses a
  committed enum fragment. Before/after SHA-256 manifests match item by item
  for 118 files under the specification and documentation tools, plus
  Taskfile, documentation plan and audit. No measured subject changed during
  the checks.
- Tier 2 graph generation is `2026-09-23T09:55:55Z`; reference paths are
  untracked by its metadata, canonical Markdown is changed, and design/tool
  paths are excluded. Findings use current direct reads, not graph
  completeness. Validation does not parse AIL, execute native contracts or
  establish human comprehension.

The reference node's acceptance conditions hold: the classified inventory is
complete; entries use the declared fields with rule-linked rejection and
non-normative meaning; lookup routes are connected; canonical text is preserved.
There is no Handed forward list or surviving defect. Close `reference-k9` with
this leaf, promoting reference lookup context to the root brief. The root still
has live review-guide, reviewer-journey and reading-checkpoint work. No ordinary
successor, correction run or ADR is needed.
