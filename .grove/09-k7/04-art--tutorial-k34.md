# tutorial-k34

## Goal

Add the tutorial's figures under art's charter, reading the whole index and
five parts as copy-edit left them.

## Context

- Document: `semantic/specification/interface-language/tutorial/README.md`
  and parts `01-lifetime.md` through `05-access-and-change.md`.
- Contract: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`
  §9.3 and §§4–7; art criteria in
  `semantic/docs/research/documentation-basis-a.md` §9.
- The node brief's five **Handed forward** entries identify each figure's
  relationship and the existing G3/G5/G6/G7 precedents. Read those entries
  before choosing sources and clear the entries this stage closes.
- Copy-edit preserved every code fence and heading order. The examples are
  complete synthetic packages except for the explicitly labelled operation
  fragment and invalid variants. `task docs:check` passes.

## Done when

- Figures make the creation split, borrow invalidation, buffer extent,
  callback schedule and borrowed/owned comparison visible, following the
  node brief. Prose continues to carry each figure's facts.
- Sources and tool-generated SVGs are committed together, with accessible
  descriptions and the existing shared visual vocabulary.
- Callback figures distinguish invocation from registration, consumption at
  destructor entry from quiescence at return, and permitted notification
  starts from guaranteed delivery. A Watch keeps neither a Card nor a
  borrowed Label alive.
- The owned Label snapshot has an independent `destroy_label` obligation;
  its separate synthetic contract adds no nullable failure mode.
- `task docs:check` passes after intentional diagram regeneration and visual
  inspection.

## Notes

Keep the full checkpoint clauses and question-before-answer ordering. Route
findings outside art's charter through the editorial family procedure.
At the end, add the `proof` leaf with bare slug `tutorial` unless a live later
sibling already holds it.
