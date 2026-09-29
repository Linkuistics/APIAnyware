# reference-k86


## Goal

Copy-edit the complete reference set for sentence clarity, terminology and
the declared prose contract, preserving its exact technical distinctions.



## Context

- Structure brief and entry fields: documentation plan §9.4 at
  `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`;
  prose/page-one/figure/check contracts are §4–§7.
- Read the whole `semantic/specification/interface-language/reference/` set:
  README, notation, types, declarations and all four clause files. All entries
  are now ready. The index includes every model concept, canonical rule,
  N01–N33 mutation and all 64 clause entries.
- Canonical-page additions are lookup routes inside existing reading aids.
  Tutorial/explanation changes add links only; glossary entries have clause
  lookup routes. Preserve their anchors and the normative text outside the
  aid boundaries.
- Most examples reuse committed teaching regions and frozen fixtures. The
  `fixture::actor` entry adds a labelled constructed region in
  `examples/rule-reading/providers.ail`. Example labels identify omitted
  enclosing context and the synthetic providers.

## Done when

- The whole set meets the survey's C1–C10 criteria and plan's prose contract,
  with entry fields in order, readable operand/constraint explanations and
  consistent model-concept names. Preserve reference precision and the
  boundary between summaries and canonical rules.
- `task docs:check` and
  `python3 semantic/specification/tools/docs_coverage.py semantic/specification/interface-language --require-complete`
  pass. Normative wording and grammar remain unchanged.
- Grow the mandatory art successor under the editorial-family rule, unless
  a live later sibling already holds it.

## Notes

No unresolved technical finding or figure slot was handed forward. Preserve
the distinction between a callback declaration and a registration schedule,
the global/constant scope of output clauses, optional fixture facts with no
specified defaults, and N11/N14's implementation/runtime qualifications.
Reference figures reuse G9 and the existing G10 views.
