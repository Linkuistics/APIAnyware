# review-guide-k91

## Goal

Read and finish the complete review guide against the whole document contract.

## Context

- The document is `semantic/specification/interface-language/review/README.md`,
  `walkthroughs.md` and `tasks.md`. Plan §9.5 supplies its structure brief;
  §4–§7 govern presentation and checks, and §10 fixes the model concepts.
- Art added thirteen local tables for validity durations, outcome partitions,
  roles/accessors, callback boundaries, access paths, address versus load,
  the tagged input, historical comparison and the 17-clause authoring count.
  It reused G9 beside Trace's canvas fragment. Inspect each role sentence and
  the table against its surrounding prose; keep task answers under Expected
  observations and keep observations separate from design judgement.
- G9 includes Filter and Point details beyond the fragment; its caption
  explains those details. Its source/SVG are unchanged, with full-size visual
  inspection and regeneration checked by art. Grammar views remain linked to
  reference/notation.md, not embedded here.
- Preserve the frozen conformance contracts, non-0.1 historical sketch label,
  placeholder import pin, lifetime-only Author assumptions, cancellation versus
  acknowledgement, no-delivery/no-eventual-return qualifications, and Model
  fit's L6 checked release relationship.
- Art passed `task docs:check`: 31 files, 29 reachable pages, 26 SVGs and 229
  coverage candidates with no pending entries or errors. The gate's 122 input
  files had identical before/after digests. Canonical rules, grammar, conformance
  record and frozen packages matched a1e22077. This is consistency evidence,
  not human comprehension or runtime validation.

## Done when

- Read all three pages as a whole, including direct task/walkthrough entry,
  local examples, figures, expected observations, model links and onward routes.
- Resolve defects within the proof charter and follow the editorial-family
  rule for any earlier-stage defect. No unresolved item is currently handed on.
- `task docs:check` passes and canonical/frozen material remains preserved.
- Check the document node's Done when; if satisfied, close review-guide-k10
  through the retirement cascade and promote only useful current context.

## Notes

The next work is the already-queued reviewer journey; the later human checkpoint
owns comprehension evidence. Do not infer that a clean editorial pass supplies it.

## Decisions (running log)

D1 — Whole-document inspection found no actionable defect. Read all three
pages, their thirteen local comparison/count tables, seven tasks and the
clause-by-clause readings of all three frozen packages. Checked the expected
observations against L1–L6, C1–C8 and A1–A5/F1, including N07, L6's release
relationship, the seven added pointer clauses and Author's 17 statements.
The input/output validity distinction, null ownership, output-state partitions,
callback entry/return boundaries and address/load distinction agree across
the pages. Preserve the existing prose and examples.

D2 — The landing map and guided route lead to the guide index; the index
offers walkthrough/task/reference routes, and both direct-entry pages supply
prerequisites and return routes. Model names agree with the model map. G9's
rendered image agrees with its source, caption and Trace fragment, including
the explicitly additional Filter and Point details. No hand-forward list or
unfilled figure slot remains in the document brief. These are editorial
consistency observations, not human comprehension or runtime evidence.

D3 — Graph project and generation were confirmed at Tier 2:
`Users-antony-Development-APIAnyware.improve-api-interface-language-docs`,
`2026-09-23T09:55:55Z`. Coverage reports excluded design/research/example
subtrees and stale or untracked documentation metadata. The proof therefore
uses direct document/source reads and the repository checks, not a claim of
complete graph coverage; no implementation structure was investigated.

D4 — `task docs:check` passed: links and examples checked 31 files,
29 site pages were reachable, all 26 SVGs reproduced identically, and coverage
reported 229 candidates with zero pending entries or errors. The 122 input
files (specification tree, documentation tools excluding Python cache files,
Taskfile, documentation plan and audit) retained identical per-file SHA-256
digests before and after the run. The sorted digest manifest hashes to
`d48668556638f8e1f00c312b171dc8553028dfea54dbc7adc6584e1b68562f69`.
Byte comparisons against `a1e22077` confirmed preservation of language.md,
contracts.md, profiles.md, grammar.ebnf, conformance.md and the frozen
buffers/callbacks/objects packages.

D5 — The document node's Done when is satisfied: the three pages meet plan
§9.5, every task has grounded expected observations and criticism-inviting
prompts, every frozen declaration is read clause by clause, and the landing
map and guided route reach the guide. Close review-guide-k10 with this leaf;
promote its useful navigation and exercise boundaries to the root brief.
The already-live reviewer journey and human checkpoint keep the root open.
No correction run, ADR change or new process-effectiveness claim is warranted.
