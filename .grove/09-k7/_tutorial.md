# tutorial-k7 — brief

## Goal

Land the five-part tutorial and its checkpoint packages in
`examples/tutorial/`. By describing one small synthetic API, the reader
writes, reads and changes a complete AIL package without any tooling (plan
outcome 2).

## Contract

The structure brief is the documentation plan's §9.3, at `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`. It states
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

- `tutorial/README.md` and five parts exist and meet §9.3. Every checkpoint is
  a labelled complete package kept in step by `docs:examples`, and every
  invalid variant cites its rule.
- Each checkpoint was checked by inspection against `grammar.ebnf` and every
  applicable rule, and the check notes are recorded in the draft leaves.
- Any unclear rule met while designing the API is in the open-question
  register, and the tutorial uses a supported alternative.
- The landing page and concept pages link the tutorial.

## Decomposition

Two draft sessions, in order. The first designs the synthetic API and drafts
`tutorial/README.md` and parts 1–3 with their checkpoints. The second drafts
parts 4–5, the final package and the guided change. Only the second cuts
`copy-edit`.
