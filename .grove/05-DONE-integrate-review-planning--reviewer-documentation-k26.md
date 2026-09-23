# reviewer-documentation-k26

**Integrates:** reviewer-documentation-k25

## Goal

Triage the review of the documentation plan and apply the findings that hold,
keeping the audit, plan and executable task tree coherent before drafting starts.

## Context

- Read the findings from the commit for `reviewer-documentation-k25`. Its
  report is `semantic/docs/design/2026-09-23-interface-language-documentation-plan-review.md`.
- The reviewed producer is `reviewer-documentation-k3`, commit `8103dd6b`.
  Report locations are coordinates in that commit; use stable task handles
  when locating leaves after this insertion's mechanical renumbering.
- The root brief remains the requirements authority. This is integration of
  a planning review, not authorization to change AIL semantics.

## Done when

- Every review finding has an evidence-based disposition, including reasons
  for any rejected finding.
- Accepted corrections are reflected in every affected planning artifact and
  task contract, with appropriate verification recorded.
- The resulting tree can execute from the next leaf without unresolved
  contradictions introduced by the integration.

## Notes

The review is evidence to assess, not a mandatory fix list. Follow the
`integrate-review-planning` procedure for triage, corrections and verification.

## Decisions (running log)

- **R1 — real issue; fix the audit, plan and reference contracts.** Reproduced:
  `surface`, `exports` (`language.md` L3), `target`, `platform`, `toolchain`,
  `runtime`, `feature`, `available` (L3), `values` (L4), `extent`, `contents`
  (C4), `callback_abi`, `representation` (A2) are defined in prose, and
  `grammar.ebnf`'s generic `clause` production cannot recover them. A
  code-span `` `name( `` sweep of the three rule files yields about 70
  candidates, mixing clauses with value constructors (`owner(`, `null(`), so a
  bare list cannot be the inventory. Correction: enumerate-then-classify.
  `docs:coverage` extracts candidates from every normative source (tables,
  prose code spans, grammar, clause heads in the `.ail` examples); a committed
  disposition list classifies each; an unclassified candidate or an entry-class
  item with no entry fails. Pending is allowed only for items assigned to a
  later reference session.
- **R2 — real issue; fix the staging contract and the draft leaves.**
  Reproduced: `concepts-k14`, `tutorial-k15` and `review-guide-k17` land pages
  with no inbound-link duty, and `docs:links` checks destinations only.
  Correction: plan §3 gains one staging rule (each increment links its landed
  pages from the landing map or a linked parent index, gives each a return and
  next route to existing pages, and writes routes to absent pages as unlinked
  text that the landing increment converts); `docs-foundation-k4` adds a
  mechanical reachability check from `README.md`, so an orphan fails
  `docs:check`. Leaves and node decompositions updated to match.
- **R3 — real issue (a contract stated too strongly); fix the audit and
  the notation brief.** Reproduced: RFC 8174 §2 keeps lowercase words' ordinary
  meaning, which can still state a requirement; `README.md` names all three rule
  files and the grammar as normative. F10's "changing the case of a word
  changes its normative force" does not follow. Correction: F10 and Q1 recast
  as inconsistent presentation plus an author-confirmation question with a
  limited premise; plan §9.4 states the convention as written without claiming
  lowercase text lacks force. The restriction on editing normative wording
  stands. The done producer leaf's D5 is history and is not edited; the audit
  is the artifact later leaves read.
- **Review note on L3 subsets — contract stated unclearly; clarify §9.3.**
  A2 requires `access` blocks on every function, so part 5 defers their
  explanation, not their presence. One sentence added to §9.3.
- **Verification.** No documentation check exists yet (`docs-foundation-k4`
  builds the first), so nothing ran mechanically. The R1 counterexamples were
  confirmed against the rule text before being written into the audit.
  A sweep of the plan, the audit and every live leaf and brief for the
  superseded wording ("first columns", "only in prose tables", "changes its
  normative force", "updates the landing", "are not linked.") came back
  clean. A positive control (the new "Staging"/"classified inventory" wording)
  hit in the expected files, and the same pattern hit the review report, so
  the control was seen dirty. The first sweep ran under zsh without word
  splitting and read nothing; it was discarded and re-run under bash.
  The next leaf, `docs-foundation-k4`, can execute as written.
