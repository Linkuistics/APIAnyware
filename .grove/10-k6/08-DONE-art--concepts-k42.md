# concepts-k42

## Goal

Make the document's figures understandable in the same concrete terms as its
corrected prose.

## Context

All document and figure paths here are relative to
`semantic/specification/interface-language/`. The document is `explanation/contracts.md`, `explanation/packages.md` and `explanation/choices.md`.

- Human findings H1–H2 and proxy finding P7 are recorded in
  `first-path-reading-k8`, decisions D2–D6, in that leaf's committed record.
- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`, §9.2.
  Its revised §4–§6 govern comprehension, framing and figures; §7 governs checks.
- This is the first correction run for this document after its original
  editorial pipeline. It runs through draft, copy-edit, art and proof in order.

## Work

Review G2, G3, G5, G6 and G7, their titles, keys, captions and alt text, and the uses of shared G1/G4. Bring labels into agreement with the revised concrete explanations. Choose overview links or reuse according to the page's task. Preserve all ownership, validity and scheduling distinctions, with source and generated SVG together.

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

- D1. Keep G2/G3 as structure diagrams, G5/G7 as sequences and G6 as a state
  diagram. Rewrite labels and adjacent explanations around the tool or caller's
  actions, preserving their contract boundaries and synthetic scope.
- D2. Retain the existing G1 overview links on all three pages. Decline another
  embedded G1 as an editorial judgement: these pages explain individual
  contracts and language choices, and already provide a route to publication
  context. Reuse G4 because its three watch cases connect the earlier domain
  explanation to ownership clauses; keep the watch/Store distinction explicit.
- D3. Add narrow comparison tables for the domain/API/language distinction and
  ownership notation on choices.md. Other central sequences, partitions and
  mappings already have diagrams or tables; retain their adjacent role statements.
- D4. The later proof leaf concepts-k43 is live. Keep the correction run as
  queued; this art stage adds no successor. The approved structure brief and
  correction mandate settle the design and authorize the editorial work.
- D5. Graph project Users-antony-Development-APIAnyware.improve-api-interface-language-docs
  reports generation 2026-09-23T09:55:55Z, fast index. Coverage reports changed
  or untracked documentation and excluded SVG/design material. Evidence here
  comes from direct document/source reads and rendered visual inspection,
  not structural graph completeness claims.
- D6. Decline extra diagrams for the choices page as an editorial judgement:
  its comparisons fit narrow Markdown tables. No contract prohibition or
  inability of the permitted medium prevented a needed figure. The ownership
  table names `replace` as the earlier cutoff and leaves the alternative's
  owner-destruction spelling in its explanatory example.
- D7. Visual inspection caught G7's long notes extending past the left edge.
  Wrapping text and giving the program participant a descriptive label restored
  full note boundaries. Retain the two separate traces and the termination
  qualification; do not compress them into an implied guaranteed schedule.

## Verification

- Read all three concept pages for the art charter. Their existing tables carry
  place traversal, regions, outcome partitions, storage, concurrency, pattern
  roles, identities, dependency pins, access clauses and authoring costs.
  Added tables carry the remaining two central comparisons in choices.md.
  Each new or revised figure has an adjacent role statement and explanation.
- Regenerated the committed SVGs with `task docs:diagrams:write`. Inspected
  G1–G7 by rasterizing the generated SVGs with `rsvg-convert` and viewing each
  image. Re-inspected G7 after its layout correction and G2 after its final
  availability wording change. Final labels, note boundaries, keys and arrow
  endpoints are readable without clipping or overlapping text. G3's crossing
  dependency arrows remain traceable by their separate labels and endpoints.
  G1/G4 and the tutorial figures regenerated without a committed byte change.
- Checked the sensitive boundaries against C1/C2/C3/C5/C6: ownership transfer
  at entry; invalidation at invalidator entry; destruction before destructor
  return; callbacks finished and unable to start at quiescent return; callback
  counts conditional on eventual scope end. Constructed examples remain
  distinct from the synthetic fixtures, and no eventual completion is promised.
- `task docs:check` exited 0: links checked 19 files with 17 pages reachable;
  examples checked 19 files; every one of the 11 named SVGs matched regeneration.
  The external RFC link was listed but not fetched. These checks establish
  document consistency, not AIL semantic validation or runtime behaviour.
- SHA-256 manifests before and after that run matched item for item (`cmp`,
  exit 0). Subjects: all files enumerated under
  `semantic/specification/interface-language/` and `semantic/specification/tools/`,
  plus `Taskfile.yml`, the documentation plan and documentation audit. The
  manifest digest was
  `f3df811f652016f2306732bc31c452c997cec6ffca16dc2d5ff493e489d55d70`.
- Cleared the node's two art handoffs. No outside-charter finding needs a
  correction run. Proof remains queued as concepts-k43; the node therefore
  remains live. Human comprehension is still for first-path-reading-k48.
