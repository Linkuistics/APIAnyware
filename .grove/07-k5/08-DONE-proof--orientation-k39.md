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

## Decisions (running log)

- D1. The whole-page read found two remaining compressed summaries: README's
  deployment/support paragraph and the domain page's callback-support summary.
  Expand them into connected explanations of configurations, source-built calls,
  callback lifetimes and teardown. Preserve L3–L4, A1–A4 and C2/C6 semantics.
  These are bounded proof repairs; no second editorial correction run is needed.
- D2. Read all three orientation pages and the canonical L1–L6, C1–C8 and
  A1–A5/F1 rules directly. Graph generation 2026-09-23T09:55:55Z reports changed
  Markdown metadata and untracked figure sources; source reads, not graph
  completeness, establish the documentary evidence. G1/G4 captions, alt text,
  sources and domain comparison tables agree on the separate synthetic cases.
- D3. Walked README → domain explanation → canonical rules and direct entry
  through the domain page and glossary. Inspected rendered G1/G4 and the shared
  concepts caption. The non-reference pages develop the comparisons before
  their tables; the glossary remains a reference. Both art handoffs are closed.
  No language decision or ADR change follows from these prose repairs.
- D4. `task docs:check` passes: 19 files checked for links and examples,
  17 Markdown pages reachable, all 11 diagram SVGs reproduce byte-for-byte.
  SHA-256 inventories before and after the final run match for all files under
  `semantic/specification/interface-language/` and `semantic/specification/tools/`,
  plus `Taskfile.yml`, the documentation plan and audit. External links were
  reported, not fetched; these checks neither parse AIL nor validate semantics.
- D5. The orientation node's done conditions hold: its pages, vocabulary,
  canonical routes and figures are present and the entry routes were walked.
  Promote the correction's scope and inspection limits into the root brief for
  `first-path-reading-k48`. That human checkpoint remains the assessment of
  comprehension. The root still has live concepts/tutorial and later work.
