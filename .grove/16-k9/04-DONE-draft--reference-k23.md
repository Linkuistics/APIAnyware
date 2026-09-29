# reference-k23

## Goal

Draft the clause entries for outcomes, callback use, access paths, patterns and the fixture profile, and complete the mutation-to-rule and alphabetical indexes.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §9.4, and the entry list `docs:coverage` assigns to this file. It states the reader and outcome, the ordered
  sections with their purposes, and the emphasis and non-goals. Quote it
  rather than re-deriving it.
- Prose contract, labels, figures and checks: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §4–§7.
- Evidence: the audit (`semantic/docs/research/interface-language-documentation-audit.md`) and the survey's §9 criteria D1–D8.

## Done when

- Every remaining clause has an entry, and `task docs:coverage` passes with
  nothing pending.
- The indexes in `reference/README.md`, including the model-concept index,
  are complete, and the concept pages,
  tutorial and glossary link to entries where they name a clause.
- `reference/README.md` links this clause file, replacing its plain-text
  mention (plan §3, *Staging*).
- `task docs:check` passes.

## Notes

The classified inventory from `reference-k16` decides the entry list. Do not add or drop clauses by memory.

This is the node's last draft session, so its last act is `leaf-add` of the `copy-edit` leaf, unless a live later sibling already holds one.

## Decisions (running log)

D1 — The named structure brief is plan §9.4. Its reader is “Any reader
looking up an exact fact”; its ordered clause plan is “one entry per clause,
grouped by scope, alphabetical within each file”; its emphasis is “Uniform
fields and completeness against the enumerated inventory”, and its non-goals
are “No new rules, no rewording of normative text”. The disposition list assigns
20 entries to this leaf; keep their anchors and model concepts.

D2 — Reuse committed teaching fragments and frozen fixture extracts, with
their enclosing context and omissions stated. Cover global/constant output
clauses alongside outcome clauses, and distinguish callback invocation facts
from registration schedules. Complete all three remaining index routes from
the disposition list and N01–N33, preserving N11's implementation-truth and
N14's dynamic-size qualifications. Normative-page lookup additions stay inside
the existing reading-aid boundaries.

## Verification

- `task docs:check` passed: 28 checked Markdown files, 26 reachable pages,
  example/source agreement, all 26 SVGs reproduced, and 229 inventory
  candidates with zero pending entries and zero errors. The separate
  `docs_coverage.py ... --require-complete` gate also passed.
- The alphabetical index matches all 64 clause-entry dispositions item by
  item; its removed-entry control fails. The mutation index matches N01–N33
  in order, preserving the N11 implementation-truth and N14 runtime-size
  qualifications. All 20 new entries have the ordered §9.4 fields and a
  canonical rule citation in their rejection field.
- Read every new entry against L5/L6, C1/C5/C6/C7, A1–A4 and F1, with the
  frozen buffers/callbacks/objects examples, teaching regions and grammar.
  Checked the optional actor fragment against F1's five permitted declaration
  kinds and isolation agreement. The reference supplies exact lookup while
  its Expresses/rationale/example routes preserve the model-first learning path.
- Removing paired reading-aid blocks leaves language.md, contracts.md and
  profiles.md byte-identical to the parent; grammar.ebnf is unchanged. A
  deliberate canonical-text mutation is detected by the comparison. Existing
  explanation/tutorial prose and examples are unchanged apart from lookup links.
- Before/after SHA-256 digests matched for 118 subjects: the specification
  tree, examples, figures, documentation tools/dispositions, Taskfile, plan
  and audit. No subject was edited while the gate ran.
- Tier 2 graph coverage was checked at generation 2026-09-23T09:55:55Z.
  Design/tools/examples are excluded; current Markdown is stale or untracked.
  Technical evidence therefore comes from direct source reads, not graph
  completeness. No parser, semantic validator or native conformance execution
  is claimed.

The reference draft is complete. Copy-edit follows under reference-k9; G9
and the existing G10 views suffice, with no new figure slot or unresolved
technical question to hand forward. The reference node remains live for its
mandatory editorial successors.
