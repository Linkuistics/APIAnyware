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
