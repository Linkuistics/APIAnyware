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

## Decisions (running log)

- Read the index and all five parts in full against plan §9.3, §§4–7,
  the survey's stage criteria and the glossary. Each part supplies the
  ordered goal, obligation, steps, complete checkpoint, observations,
  questions/answers and rule-cited invalid variant. The repeated complete
  packages intentionally expose authoring burden. Reference inventory
  coverage belongs to the later reference node, not this tutorial.
- Compared the teaching claims and displayed packages directly with
  grammar.ebnf, L1–L5, C1–C6/C8 and A1–A5/F1. Creation's valid null carries
  no obligation; destruction consumes at entry; refresh invalidates the
  owner-scoped Label borrow at entry; copying requires eight allocated
  elements and exposes no initialized output on failure. Watch retention
  and scalar notifications neither retain Card nor extend Label validity.
  Quiescence is at destructor return, with outside_callback excluding
  self-wait. No delivery or eventual completion is promised.
- The exact finished/owned package diff matches the guided change:
  publication identity/surface, outcome name, owned give, removal of the
  invalidator and the distinct synthetic symbol. The independent snapshot
  uses Label's existing unique destructor, with unchanged input validity,
  buffer and callback contracts. No allocator profile or nullable failure
  branch is introduced. The five invalid variants agree with their cited
  rules (C2, C1, C4, C6 and C5 respectively).
- No substantive correction or new language ambiguity emerged from the
  whole-document read. No correction run is warranted; the node has no
  handed-forward entry. These are inspection findings, not AIL validation,
  native execution or evidence of human comprehension.
- Read the four tutorial figure sources and shared visual vocabulary;
  rendered their SVGs and the reused G1 SVG to temporary PNGs for visual
  inspection. Labels, keys, event order and captions agree. The buffer
  figure separates seven text elements from the eighth terminator; the
  callback activation visibly crosses destruction entry but ends before
  return. The part-5 comparison preserves the two independent package
  identities. No figure correction was needed.
- Walked the index-to-parts route and each part's prerequisite, rule,
  checkpoint, return and next links. The landing map and all four concept
  pages link the tutorial index. Each tutorial entry states its proposal
  status and prerequisites; the final page routes to existing conformance
  and design-question pages. The scheduled first-path reading remains the
  human comprehension check.
- Evidence is Tier 2 with direct document reads. Coverage checked every
  relied-on path against project
  Users-antony-Development-APIAnyware.improve-api-interface-language-docs,
  fast generation 2026-09-23T09:55:55Z. Rules/glossary metadata match;
  tutorial/grammar/figure metadata are untracked, navigation metadata have
  changed, and examples/research/design are excluded. Source reads, the
  package diff, rendered images and the fence comparison supply the
  evidence; no graph completeness claim is made.
- Final `task docs:check` exited 0: links checked 19 files with 17 pages
  reachable, examples checked 19 files, and all eleven named diagram SVGs
  regenerated identically. SHA-256 manifests before and after matched for
  58 files: every rg-visible file under interface-language/ and
  semantic/specification/tools/, plus Taskfile.yml, the documentation plan
  and audit. Manifest digest:
  db28e893bb60c5babf25c4affeff091ad078774c305b2f5eaaa1704d78282c79.
  No measurement subject changed during the run. The gate checks links,
  fences and figure regeneration, not AIL semantics or native behaviour.
- Tutorial-k7's Done when is satisfied: the index/five parts and complete
  checkpoint packages exist; both draft leaves retain their per-package
  grammar/rule inspection notes; navigation is live; no unresolved
  ambiguity or handoff remains. Promote the API boundaries and proof
  outcome to the root brief when retiring this last live child. Root
  siblings remain live, so the cascade stops there. No architecture or
  terminology decision requires an ADR or glossary change.
