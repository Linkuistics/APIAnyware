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

## Decisions (running log)

D1 — Keep the eight-page structure, entry order, anchors and technical scope.
Correct stale completion wording, the package example's omission label,
ambiguous uses of closure, repeated declaration-field prose and inconsistent
identifier typography. Link domain terms to the existing glossary rather than
adding definitions. These are copy-edit corrections under plan §4 and §9.4;
normative files, grammar, example sources and figures remain untouched.

## Verification

- Read the complete eight-page reference against the glossary, plan §4–§7
  and §9.4, model-concept names in §10 and survey C1–C10. Corrected the
  identified sentence, terminology, omission-label and typography defects;
  the changes preserve the reference's structure and technical distinctions.
- `task docs:check` passed: 28 Markdown files, 26 reachable pages,
  example/source agreement, all 26 SVGs reproduced, and 229 reference
  candidates with zero pending entries and zero errors. The separate
  `docs_coverage.py ... --require-complete` gate also passed.
- Compared every reference page with the parent: fenced examples, explicit
  anchors, headings, field order and example markers are unchanged. The
  three normative Markdown files and grammar are unchanged; a deliberate
  preservation-control mutation was detected.
- Before/after SHA-256 digests matched for all 119 subjects in the specification
  tree, documentation tools/dispositions, Taskfile, plan and audit. No subject
  changed during validation. The initial link check caught one malformed
  multiline link introduced by editing; it was fixed before the full gates.
- Tier 2 coverage at generation 2026-09-23T09:55:55Z reports the reference
  pages as untracked and supporting documentation as stale or excluded.
  Evidence comes from current direct reads, not graph completeness. These
  checks do not claim parser, semantic-validator or native execution.

No structural or technical defect is handed back. The art successor is
reference-k87; reference-k9 remains live for art and proof, so no parent
closure or promotion is due. This editorial change establishes no new ADR.
