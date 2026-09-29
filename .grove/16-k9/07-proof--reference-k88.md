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
