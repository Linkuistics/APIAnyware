# orientation-k37

## Goal

Edit the corrected document's sentences and terminology so readers can follow
each relationship in ordinary language.

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

Apply the revised prose contract (§4–§5) to the whole document, including
headings, first sentences, tables, status statements and example labels. Check
that the reader can identify who acts, what changes, and why it matters without
decoding an unexplained abstraction. Use connected explanations and positive
framing. Preserve the distinctions the specification requires; judge length by
what the reader needs. Structural teaching gaps belong to draft and figure work
to art: use the editorial handoff procedure for those findings.

## Done when

- Sentences, terminology and example surroundings satisfy the revised prose
  contract across the whole document.
- A headings-and-first-sentences read introduces the actual subjects clearly.
- `task docs:check` passes and each out-of-charter finding has an owner.

## Notes

The later stages of this correction run are already queued. Read the live
siblings and keep the existing run; each stage uses the editorial procedure
for any additional finding. A second re-run of the same stage on this document
requires escalation. The human requested corrections before further feedback;
`first-path-reading-k48` follows all three corrected documents and precedes
reference drafting. Keep the synthetic examples and proposed-language status
explicit throughout.

## Decisions (running log)

- D1: Keep the corrected section structure. Clarify remaining sentence-level
  shorthand, introduce the overview's watch example, and link domain terms to
  their glossary entries. Preserve the normative rules and synthetic examples.
- D2: Keep the existing art and proof siblings (`orientation-k38` and
  `orientation-k39`). G1/G4 sources, SVGs and alt text remain owned by art under
  the node brief's existing handoff; no duplicate successor is needed.

## Verification

- Read all three pages against plan §4–§5 and §9.1, including their headings,
  opening sentences, tables, status statements and example surroundings.
  No additional structural correction was identified. The existing G1/G4
  handoff remains for art, followed by the queued whole-document proof.
- `task docs:check` passed: 19 files passed the link and example checks,
  17 pages were reachable, and all 11 SVGs regenerated without differences.
  External links were reported but not fetched. These checks establish document
  consistency, not runtime behaviour or human comprehension.
- Evidence came from direct Markdown/configuration reads. Graph coverage at
  generation `2026-09-23T09:55:55Z` reported changed metadata for the document
  and excluded the design-documents subtree; no structural code claim relies
  on that graph.
