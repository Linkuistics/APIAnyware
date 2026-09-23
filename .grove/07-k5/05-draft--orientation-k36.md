# orientation-k36

## Goal

Correct the document's explanatory structure and prose after the human's first
reading identified compressed abstractions and negative framing.

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

Start with the overview's sentence "every producer crosses the same publication boundary". Explain who writes an AIL description, what a validator would check, and what other tools do with it. Introduce the technical terms through those actions. Rewrite the whole three-page set at that level of explanation. Retitle the domain page *Using an API across languages* while retaining its path. Give headings positive subjects and develop concepts through concrete cases. Update affected link text and heading-derived anchors throughout the existing set; stable explicit aliases are acceptable where needed.

Read the whole document, including its tables and opening summaries. Preserve
normative semantics, rule identities, AIL code and synthetic example contracts.
The human asked for understandable explanation before giving more feedback;
replacing a few reported phrases is insufficient.

## Done when

- The whole document explains the relevant actors, actions and consequences
  before relying on technical shorthand.
- Headings and explanatory framing state their subjects positively, while
  exact conditions, limitations and obligations remain recoverable.
- The revised structure brief is satisfied and `task docs:check` passes.
- Work belonging to later stages is recorded in the node's handed-forward list.

## Notes

The later stages of this correction run are already queued. Read the live
siblings and keep the existing run; each stage uses the editorial procedure
for any additional finding. A second re-run of the same stage on this document
requires escalation. The human requested corrections before further feedback;
`first-path-reading-k48` follows all three corrected documents and precedes
reference drafting. Keep the synthetic examples and proposed-language status
explicit throughout.
