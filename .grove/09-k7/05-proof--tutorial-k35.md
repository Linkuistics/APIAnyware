# tutorial-k35

## Goal

Read the whole tutorial against its document contract and complete the proof
stage under `grove-proof`, including the checkpoints and figures.

## Context

- Document: `semantic/specification/interface-language/tutorial/README.md`
  and parts `01-lifetime.md` through `05-access-and-change.md`; complete
  checkpoint packages are in `examples/tutorial/`.
- Structure brief: documentation plan
  `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`
  §9.3. Its §§4–7 and the research basis §9 supply the prose, figure and
  verification contracts. The node brief carries the synthetic API boundary.
- Art added `figures/tutorial-{lifetime,borrow,storage,callbacks}.puml` and
  generated SVGs, reused G1 on all six pages, and added part 5's caller-obligation
  comparison. Sources use `figures/style/ail.puml` and `vocabulary.txt`.
- Part 2's Label is an owner-scoped resource-handle borrow. Part 5's separate
  owned package gives an independent snapshot and an existing destructor
  obligation, with no new nullable result. Watch is independent of Card and
  label validity. Preserve the distinction between destructor entry and return.
- Art's gate passed and its direct source comparison found unchanged code
  fences and heading order. Its one reviewer found no material figure defect;
  this does not replace the whole-document proof. Art cleared all handoffs.

## Done when

- The whole index and five parts satisfy the proof charter and §9.3, including
  direct-entry navigation, checkpoint labels and canonical rule citations.
- Inspection distinguishes grammar/contract evidence from unexecuted native
  behaviour; the synthetic fixture labels and proposal status stay accurate.
- Figures and captions agree with the prose and complete packages, with no
  promised callback delivery or termination and no raw-pointer ownership model
  introduced by the owned Label change.
- `task docs:check` passes, with any fixes made under the editorial procedure.
- Retire this leaf and check the tutorial node's Done when; promote relevant
  context if the node closes. The scheduled first-path reading checkpoint is
  the human comprehension check, not something to perform in this proof leaf.

## Notes

No ordinary successor is needed. If a defect belongs to an earlier stage,
follow the editorial correction-run procedure rather than absorbing its work.
