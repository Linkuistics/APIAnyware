# review-guide-k10 — brief

## Goal

Land the review guide: `review/README.md`, `review/walkthroughs.md` and
`review/tasks.md`. The reader can then evaluate AIL along the six dimensions
and give feedback tied to examples and rules (plan outcome 4).

## Contract

The structure brief is the documentation plan's §9.5, at `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`. It states
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

- The three pages exist and meet §9.5. Every task has expected observations
  that were checked against the rules, and every prompt cites something
  concrete and invites criticism.
- The walkthroughs cover all three conformance examples clause by clause.
- The landing page links the guide as the destination of the guided route.

## Decomposition

Two draft sessions, in order. The first drafts `review/walkthroughs.md`,
which the tasks build on. The second drafts `review/README.md` and
`review/tasks.md`. Only the second cuts `copy-edit`.
