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

## Decisions (running log)

- Follow the approved figure plan with PlantUML: adapt G6 for Card creation,
  G5 for Label invalidation and G7 for Watch teardown; add a storage layout
  showing seven text elements and the eighth terminator. Reuse shared styles.
- Use a comparison table for part 5's borrowed versus owned caller obligations.
  Declined an additional sequence diagram by editorial judgement: the table
  compares the same events directly without repeating part 2's timeline. This
  is neither a contract prohibition nor a limitation of the medium.
- Reuse G1 before detail on all six tutorial pages, with captions locating
  each part in the proposed publication flow. Add role sentences to the index
  tables. Preserve section order, checkpoint bytes and questions before answers.
- Declined a further access-path diagram by editorial judgement: the existing
  four-clause table and linked G3 explanation already carry that mapping.
  No medium limitation was encountered.
- Review claim: the new figures preserve each contract's event boundaries and
  obligations without relying on colour or an unstated interpretation of an
  arrow. A wrong boundary would teach unsafe use despite byte-perfect examples.
  Spend the leaf's one reviewer on the figure sources and captions against C1–C6
  and the visual contract, independently of the surrounding tutorial narrative.
- Extend the shared key for buffer grids only: cells are indexed scalar storage;
  X marks invalid output, never a stored value. Use complete clause spellings
  in the layout legend so its annotations cannot be mistaken for new syntax.
- The independent reviewer found no material issue in the sources, captions,
  ownership table or context-map reuse against the canonical rules and visual
  contract. No findings required classification or another review cycle.

## Verification

- `task docs:check` passed: 19 files in the link and example checks, 17 pages
  reachable, and all eleven SVGs reproduced byte-for-byte.
- SHA-256 manifests matched before and after the gate for all discovered files
  under `semantic/specification/interface-language/` and
  `semantic/specification/tools/`, plus `Taskfile.yml`, the documentation plan
  and documentation audit. No checked subject changed during the run.
- Inspected rasterized renders of all four new SVGs, including the final buffer
  legend. Labels, table cells, arrows and local keys are readable without colour.
- Compared every tutorial page's code fences and heading sequence with `@-`;
  all are unchanged. The diff adds figures and their role/description prose,
  a caller-obligation comparison, and role sentences for the index tables.
- Graph project was ready at generation `2026-09-23T09:55:55Z` (fast index).
  Coverage marks the plan/research/tool subtree excluded and newer tutorial
  artifacts untracked; direct document and source reads supplied the evidence.
  No production-code structural claims were made.
- These checks establish documentation consistency and figure reproducibility,
  not AIL semantic conformance, native behaviour or human comprehension.
