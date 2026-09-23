# orientation-k38

## Goal

Make the document's figures understandable in the same concrete terms as its
corrected prose.

## Context

All document and figure paths here are relative to
`semantic/specification/interface-language/`. The document is `README.md`, `explanation/unsaid.md` and `glossary.md`.

- Human findings H1–H2 and proxy finding P7 are recorded in
  `first-path-reading-k8`, decisions D2–D6, in that leaf's committed record.
- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`, §9.1.
  Its revised §4–§6 govern comprehension, framing and figures; §7 governs checks.
- This is the first correction run for this document after its original
  editorial pipeline. It runs through draft, copy-edit, art and proof in order.

## Work

Review G1 and G4, their shared vocabulary, labels, keys, captions and alt text. Use the concrete actors and actions established by the revised prose. Keep the overview useful as an entry point; later pages can link it. Reconcile changes to shared figures with all current uses, and keep source and generated SVG together.

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

- D1: Keep G1 as the overview's workflow map. Replace its abstract labels with
  people, tools and actions, preserving exact dependency selection and the
  distinction between checking a description and establishing library behaviour.
- D2: Use the domain page's synthetic watch operations in G4, with separate
  borrowing, consuming and owned-result cases. Keep the general consumption
  rule explicit, including every outcome and an explicitly returned obligation.
- D3: Replace the nine repeated G1 embeds on concept/tutorial pages with links
  explaining how each page fits the overview. This is an editorial judgement:
  those pages teach contract details or an exercise, and the full workflow adds
  no new relation there. The medium can carry it and the contract permits it.
- D4: Add compact comparisons for borrow lifetime, failure output and callback
  storage/teardown in the domain page. Keep glossary entries as linked lookup
  definitions: additional glossary figures would repeat their defining pages
  (editorial judgement, not a contract restriction or medium limitation).
- D5: Keep the already-live proof sibling, orientation-k39; the correction run
  needs no additional successor.
- D6: The human added a shared requirement during this session: limit semantic
  density outside reference and make documents independent of Grove, process
  history and ADRs. Update the shared contract now, remove orientation's
  process/design-history links, and ask the queued proof to assess the full
  orientation against this requirement. Later documents inherit it through
  the root brief and plan; this is new direction, not a second correction run.

## Verification

- Read README, the domain explanation and glossary as a whole for the art
  charter. G1 supplies the workflow; G4 supplies the ownership cases; the
  navigation, buffer and execution-dimension tables retain their roles. Added
  comparisons carry borrow lifetime, failure output and callback teardown.
  Prose remains alongside each figure to explain its facts and takeaway.
- Visually inspected both regenerated SVGs by rendering them to temporary PNGs
  with `rsvg-convert`. G1's first layout was too wide; the final layout fits the
  workflow and definition branch in roughly 840 pixels. Labels, arrowheads,
  keys and notes are readable without overlap or clipping. G4 keeps three
  separate cases, clear arrow directions and the retention limitation. No
  bitmap assets were added to the repository.
- Inspected the shared embeds and their surrounding text. G1 is embedded in
  the overview; concept and tutorial pages link to that explanation. Both G4
  embeds name the synthetic watch cases and link back to the overview. Its
  general rules remain separate from any claim that the watch header is a
  complete fixture or implementation.
- `task docs:check` passed: 19 files passed links and examples, 17 pages were
  reachable, and all 11 SVGs regenerated byte-for-byte. External links were
  reported but not fetched. These checks establish document consistency, not
  execution or human comprehension.
- SHA-256 manifests before and after the full check matched for Taskfile.yml,
  all files under the interface-language documentation and documentation-tools
  directories, the documentation plan and the documentation audit. The later
  plan-only wording change also passed focused links and examples checks.
- Evidence is direct Markdown, PlantUML and configuration reading, normative
  rule checks (L2–L3, C2–C3, C5, C8, A1), and visual inspection. Graph generation
  `2026-09-23T09:55:55Z` reported changed/untracked documentation metadata and
  excluded design/research documents and SVGs. No structural code claim relies
  on the graph; these non-code surfaces were read directly.
