# reviewer-journey-k11 — brief

## Goal

Integrate navigation across the finished set and present Step 2. Every page
is then reachable, with a return path, from each direct-entry type. The
audit's closing section traces each finding to the pages that resolve it.

## Contract

The structure brief is the documentation plan's §9.6, at `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`. It states
the reader and their outcome, the ordered sections and the purpose of each,
and the emphasis and non-goals. The same plan's §4 (prose contract), §5
(page-one block and example labels), §6 (figures) and §7 (checks) govern
every stage. The gate is `task docs:check`, plus any task this document adds.

## Pipeline

`draft` → `copy-edit` → `art` → `proof`, cut lazily: each stage's last act
adds the next unless a live later sibling already holds it. Stage leaves carry
this document's bare stem as their slug. Defects a later stage owns go under
`## Handed forward` in this brief; the list is created by the first stage that
needs it. Figure slots that `draft` leaves for `art` go there too.

## Done when

- Every page has an inbound link from the landing page's map or its parent
  index. Links between rules, entries, explanations, tutorial parts and
  review tasks run both ways.
- The audit ends with "Step 2: refactored output", as §9.6 specifies.
- `proof` has walked the reviewer journey from every entry type in the plan's
  §3, and the survey's R1–R5 criteria hold for the whole set.
