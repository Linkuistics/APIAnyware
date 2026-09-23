# tutorial-k46

## Goal

Make the document's figures understandable in the same concrete terms as its
corrected prose.

## Context

All document and figure paths here are relative to
`semantic/specification/interface-language/`. The document is `tutorial/README.md` and tutorial parts 1–5.

- Human findings H1–H2 and proxy finding P7 are recorded in
  `first-path-reading-k8`, decisions D2–D6, in that leaf's committed record.
- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`, §9.3.
  Its revised §4–§6 govern comprehension, framing and figures; §7 governs checks.
- This is the first correction run for this document after its original
  editorial pipeline. It runs through draft, copy-edit, art and proof in order.

## Work

Review the four tutorial-specific diagrams, the part-5 comparison, and the tutorial's uses of G1. Explain their reading order and label actors and actions in the revised prose's vocabulary. A route to the overview can replace an unhelpful repeated full figure. Preserve borrow invalidation at refresh entry, owner consumption at destruction entry and quiescence at return; keep source and generated SVG together.

The diagram's prose explanation supplies its meaning for readers using text
alone. Explain the shown scope directly and retain material limitations. Apply
§6's hierarchy across the reading route while assessing whether each repeated
context view helps its page.

## Done when

- Figure titles, labels, keys, captions and alt text agree with the revised
  prose and preserve the contract facts.
- Each figure has a clear role on its page and a route to the broader context.
- Regenerated SVGs match their sources, visual inspection is recorded, and
  `task docs:check` passes.

## Notes

The later stages of this correction run are already queued. Read the live
siblings and keep the existing run; each stage uses the editorial procedure
for any additional finding. A second re-run of the same stage on this document
requires escalation. The human requested corrections before further feedback;
`first-path-reading-k48` follows all three corrected documents and precedes
reference drafting. Keep the synthetic examples and proposed-language status
explicit throughout.

## Decisions (running log)

- D1. Keep the four existing PlantUML views and the part-5 comparison. Their
  state, timing and storage relations fit their current media. Rewrite labels,
  keys, captions and alt text around the program, library and named values;
  retain the exact entry/return boundaries and synthetic scope. The mandated
  correction and approved figure contract already settle the design direction.
- D2. Declined figure — editorial judgement: keep links to the overview's G1
  instead of repeating it in the tutorial. The index introduces the author's
  task, each detail caption links back, and part 5 links the consumer's task.
  Repetition would interrupt the local exercise. This is neither a contract
  prohibition nor evidence that the medium cannot carry the relation.
- D3. Add a small part-5 access-clause table so readers can recover the mapping
  from each clause to the tool's action after reading its explanation. Keep the
  existing ownership table, replacing abstract obligations with caller actions.
- D4. The first rendered inspection found all four figures legible and their
  event labels attached correctly. The callback view was wider than necessary;
  break its long messages and notes to make the three participants easier to
  compare at documentation-page width. Keep the shared shapes and arrow styles.
- D5. The completed figure work closes the node brief's art handoff. No earlier
  stage correction or additional proof leaf is needed: `tutorial-k47` remains
  live immediately after this leaf. These reversible presentation choices need
  no ADR and do not change the existing documentation-placement decision.

## Verification

- Read the tutorial index and all five parts, including checkpoint fences,
  questions and tables. Checked the figure boundaries against C1, C2, C3, C5
  and C6: refresh invalidates at entry; destruction responsibility transfers
  at entry; the subscription is quiescent at destructor return. The access
  table summarizes the existing explanation and selects no new provider facts.
- Regenerated all SVGs through `task docs:diagrams:write`. Viewed rasterizations
  of the four actual tutorial SVGs with `rsvg-convert` and the image viewer.
  Inspected the callback view again after wrapping its messages. Titles,
  labels, keys and note boxes fit without clipping or overlap; the callback
  view now fits a 741-pixel-wide image. The borrow's two cases and storage's
  two outcomes remain visibly separate. Colour carries no unique meaning.
- The table on the tutorial index still maps each part to its checkpoint and
  states its navigation role. Both part-5 tables have adjacent reading guidance.
  Every detail figure retains its source and overview links. Declining a
  repeated G1 is recorded in D2, rather than treated as a medium limitation.
- `task docs:check` passed: 19 files passed link and example checks, 17 pages
  were reachable, and all 11 diagram SVGs reproduced byte for byte. SHA-256
  manifests before and after the run matched for the interface-language tree,
  documentation checker directory, documentation plan, audit and root Taskfile.
  The diff contains only figure presentation, its surrounding text/tables and
  Grove bookkeeping; the AIL examples and normative rules are unchanged.
- Graph generation `2026-09-23T09:55:55Z` reported changed/untracked editorial
  metadata and excluded documentation/tool directories. Evidence here comes
  from direct file reads and rendered inspection, not graph completeness.
  Mechanical checks and editorial inspection establish neither runtime
  conformance nor human comprehension; the latter remains for
  `first-path-reading-k48`.
