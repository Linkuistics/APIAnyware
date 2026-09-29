# tutorial-k33

## Goal

Copy-edit the whole five-part tutorial and its index for sentences,
terminology and the document's prose contract.

## Context

- Document: `semantic/specification/interface-language/tutorial/README.md`
  and parts `01-lifetime.md`, `02-lending.md`, `03-storage.md`,
  `04-callbacks.md`, `05-access-and-change.md` in the same directory.
- Structure brief and prose/label contract:
  `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`
  §9.3 and §§4–5. Survey criteria: `semantic/docs/research/documentation-basis-a.md`
  §9's copy-edit criteria. The glossary is the terminology authority.
- Checkpoint sources: `semantic/specification/interface-language/examples/tutorial/`.
  Keep every excerpt matched to its source and distinguish complete packages
  from the part 5 operation fragment and each invalid variant.
- The node brief's continuation context and Handed forward list apply to the
  whole tutorial. Art owns the figure slots; do not absorb them.

## Done when

- The whole tutorial meets the prose contract within copy-edit's charter:
  explicit actors, conditions before actions, defined/linked domain terms,
  labelled examples, rule citations, and consistent draft/synthetic status.
- Questions remain before answers; full checkpoint clauses remain visible.
  The part 5 table remains precise about changed and retained obligations.
- `task docs:check` passes. Technical or structural defects are routed under
  the editorial procedure rather than silently changed.

## Notes

Watch the distinction between synchronous callback invocation and registration
schedule, consumption at destructor entry versus quiescence at return, and
retention versus input ownership. A Watch never keeps a Card or borrowed Label
alive. The owned Label variant is a separate synthetic contract with a distinct
publication and symbol; it adds no nullable failure mode.

At the end, add the `art` leaf with bare slug `tutorial` unless a live later
sibling already holds it, following the editorial family procedure.

## Decisions (running log)

- Keep the existing section order, checkpoint clauses and synthetic API
  contracts. Copy-edit first-use glossary links, explicit actors, conditional
  wording and code typography across the index and all five parts. The
  existing figure handoffs remain owned by art.
- Use direct Markdown reads for editorial evidence. The graph reports
  generation `2026-09-23T09:55:55Z`, but the tutorial paths have untracked
  freshness and the design/research and example subtrees are excluded.
  No code-structure or graph-completeness claim is needed for this edit.
- Preserve zero-delivery wording in the callback summary: any notifications
  start after registration returns; no notification is promised. Name the
  destructor as the consumer at entry and the callee as the retaining actor.

## Verification

- Read all six tutorial pages against the plan's prose and label contract,
  the glossary and the survey's copy-edit criteria. Corrected terminology
  links, actor references, conditional wording and identifier typography.
- Compared each page with the parent commit: all code fences and heading
  order are byte-for-byte unchanged. Complete checkpoints, the operation
  fragment, invalid variants and questions before answers remain visible.
- `task docs:check` passed: links checked 19 files with 17 reachable pages;
  examples checked 19 files; all seven existing diagrams regenerated cleanly.
  SHA-256 comparisons before and after that run confirmed unchanged subjects
  across the interface-language tree, documentation tools, Taskfile,
  documentation plan and audit. The external RFC link was not fetched.
- These checks verify documentation consistency, not AIL semantic validation
  or runtime behaviour. Art's five existing figure handoffs remain open in
  the node brief, and `tutorial-k34` carries the art stage next.
