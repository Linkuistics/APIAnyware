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
