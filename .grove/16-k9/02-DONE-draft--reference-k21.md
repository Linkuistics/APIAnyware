# reference-k21

## Goal

Draft the clause entries for package, environment and common declaration scope.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §9.4, and the entry list `docs:coverage` assigns to this file. It states the reader and outcome, the ordered
  sections with their purposes, and the emphasis and non-goals. Quote it
  rather than re-deriving it.
- Prose contract, labels, figures and checks: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §4–§7.
- Evidence: the audit (`semantic/docs/research/interface-language-documentation-audit.md`) and the survey's §9 criteria D1–D8.

## Done when

- Every clause assigned to this file has an entry with the §9.4 fields in
  order, including *Expresses* with its plan §10 concept, and each fact
  matches its rule text.
- `reference/README.md` links this clause file, replacing its plain-text
  mention (plan §3, *Staging*).
- `task docs:check` passes.

## Notes

The classified inventory from `reference-k16` decides the entry list. Do not add or drop clauses by memory.

A later draft sibling finishes this document, so do not cut `copy-edit` here: the last draft session does.

## Decisions (running log)

D1 — The named structure brief is plan §9.4. Its reader is “Any reader
looking up an exact fact, including the secondary readers”; its outcome is
finding syntax, operands, applicability, requiredness, repeatability, defaults,
constraints and rejection conditions with canonical links. Its section plan
requires “one entry per clause, grouped by scope, alphabetical within each
file.” Its emphasis is “Uniform fields and completeness against the enumerated
inventory, with links both ways”; its non-goals are “No new rules, no rewording
of normative text, and no resolution of open questions.” All three structure
preconditions are explicit in that artifact.

D2 — Use the 29 entry rows assigned to reference-k21 in
`reference-dispositions.tsv`, preserving their anchors and concept assignments.
Cover both environment and lifecycle uses of `runtime` in its one entry.
Examples are independent, located fragments adapted from the existing teaching
fragments and object fixture, with omitted context stated locally. Publish
the file through the reference map and model index, add rule lookup routes
inside the existing bordered aids, and leave canonical text unchanged.

D3 — Tier 2 graph context is generation `2026-09-23T09:55:55Z`.
Coverage reports changed/untracked Markdown and excluded design, tools and
example subtrees. Evidence is direct source reading of the relevant briefs,
plan, grammar, L1–L6, C1–C8, A1–A5/F1 and conformance mutations; no code
structure or graph-completeness claim is needed for this documentation leaf.

D4 — Drafted `reference/clauses-package.md` with all assigned entries in
alphabetical order and marked those disposition rows ready. The companion
`examples/reference/clauses-package.ail` holds independent fragments; environment
refinements explicitly require hypothetical provider definitions beyond F1.
The reference map, model index and applicability table now link the entries.
Lookup routes were added inside the existing L3/L4/L5 and C2/C7 reading aids.
No new figure is needed: member/reference entries route to the existing G9
containment view and all forms route to the grammar home.

D5 — Structure and technical-truth read completed against the source rules.
Checked the 29 entry names against the assigned inventory, field order,
concept links, cited rejection rules, example markers and both incoming index
routes individually. The accessor rejection wording explicitly permits a
`none` setter. The runtime entry covers both scopes and operand types;
property storage remains a consistency assertion, and optional environment
facts acquire no invented defaults. These are source-inspection results,
not evidence of a running AIL parser, semantic validator or native API.

D6 — Final `task docs:check` passed: links/examples for 25 checked files,
23 reachable pages, all 26 SVGs reproduced, and coverage of 229 candidates
with zero errors. The 35 remaining pending entries belong to k22/k23;
none belongs to this leaf. All 116 verification subjects matched their
before/after SHA-256 digests item by item: the interface-language tree,
documentation tools excluding caches, Taskfile, plan and audit. Manifest
SHA-256: `77cd1e9890d3f1e3db7d4fe9973d6635a0f52cd329fe84db52963af70392179a`.
Canonical text, after stripping paired reading aids, matches parent `00d7715b`;
grammar and every pre-existing `.ail` example are byte-identical. A deliberate
change to L3's package-clause requirement failed the preservation comparison.
External links were not fetched, and no human-comprehension result is claimed.

D7 — No outstanding later-charter defect or figure slot was identified.
The live reference-k22 and reference-k23 siblings continue the declared draft
decomposition. This leaf grows no copy-edit successor; k23 owns that action.
Retirement leaves reference-k9 live, so no parent-chain close or promotion is
due. No language decision or ADR change follows from this lookup increment.
