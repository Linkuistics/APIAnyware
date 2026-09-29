# reference-k22

## Goal

Draft the clause entries for callable effects and input obligations, including buffers and strings.

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

D1 — The structure brief is plan §9.4: reader/outcome is “Any reader looking
up an exact fact”; the section plan requires “one entry per clause, grouped
by scope, alphabetical within each file”; emphasis is “Uniform fields and
completeness against the enumerated inventory”, with “No new rules, no
rewording of normative text” as non-goals. The disposition list assigns 15
entries to this leaf. Preserve those anchors and their model concepts.

D2 — Reuse the committed rule-reading example regions, with their enclosing
packages and explicit omissions. Cover both callable and callback-use scopes
in executor, concurrency and reentrancy, and both requires constructors.
Keep provider-dependent alternatives conditional; F1 supplies neither async
entry nor variadic signatures. Add lookup links inside existing reading aids,
leaving the canonical rule text and grammar unchanged.

## Verification

- `task docs:check` passed: 26 checked Markdown files, 24 reachable pages,
  example/source agreement, all 26 SVGs reproduced, and 229 inventory
  candidates with zero coverage errors. All 15 k22 entries are ready;
  the 20 pending entries belong to reference-k23.
- Read every new entry against L1/L5, C1–C8, the relevant provider rules and
  F1. Checked the committed rule-reading fragments against their source and
  the complete buffers/callbacks fixtures. Every entry has the ordered §9.4
  fields and a rule citation in its rejection field. Dynamic extent checks
  remain runtime obligations; no parser or native conformance run is claimed.
- Removing paired reading-aid blocks leaves `language.md`, `contracts.md`
  and `profiles.md` byte-identical to the parent revision; `grammar.ebnf`
  is unchanged. Added canonical-page routes stay inside the bordered aids.
- Before/after SHA-256 digests matched for 116 subjects: the specification
  tree (including examples and figures), documentation tools and dispositions,
  Taskfile, plan and audit. The gate ran with no concurrent edits.
- Tier 2 graph coverage was checked at generation 2026-09-23T09:55:55Z.
  Design/tools/examples are excluded and edited Markdown is stale or
  untracked, so document evidence came from direct source reads. No code
  structure claim relies on that graph.

The existing notation/model views suffice; no new figure slot or unresolved
technical question arose. The live reference-k23 sibling finishes the draft
set and grows copy-edit, as the node's decomposition requires.
