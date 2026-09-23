# orientation-k39

## Goal

Read the whole corrected document and verify the human's two reported defect
classes before handing the path back for human assessment.

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

Apply the proof charter to the whole document against the revised §4–§6 and
§9.1. Check explanations, headings, table summaries, figure text, navigation,
examples and exact semantic claims. Start at the landing page and also try a
direct entry. Verify that technical names follow understandable explanations,
that positive framing leads the text, and that a reader can trace actors,
actions and consequences. Distinguish this inspection from evidence of human
comprehension: the scheduled human checkpoint owns that assessment.

## Done when

- The whole document and its direct-entry routes satisfy the revised contract.
- Example contracts and rule identities are preserved; links and anchors work.
- `task docs:check` passes and the node's handed-forward list is cleared or
  escalated through the editorial procedure.
- The node's close carries forward what the follow-up human read needs.

## Notes

This proof is the last stage of the queued correction run. Use the editorial
procedure for any additional finding. A second re-run of the same stage on this document
requires escalation. The human requested corrections before further feedback;
`first-path-reading-k48` follows all three corrected documents and precedes
reference drafting. Keep the synthetic examples and proposed-language status
explicit throughout.
