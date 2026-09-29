# concepts-k40

## Goal

Correct the document's explanatory structure and prose after the human's first
reading identified compressed abstractions and negative framing.

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

Read the revised orientation first. Rewrite all three explanations so a reader learns the concrete relationship before its technical name: for example, which declarations a package needs, how exact dependency versions are selected, and what a tool does to call an operation. Develop the ownership, output, callback and access examples in connected prose. Give the scope and choice sections positive subjects. Preserve Q1–Q6, including the unrecorded ownership-placement rationale in Q3; keep alternatives and current limitations explicit. Update affected links and anchors throughout the existing set.

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

## Decisions (running log)

- D1. Retain the ordered section plan in plan §9.2 and the existing AIL
  fragments. Expand the prose around them so each relationship starts with
  caller, library or tool actions. The brief supplies the reader/outcome,
  ordered purposes and emphasis/non-goals; this is correction of that approved
  design, not a new language or document design.
- D2. Make the choices page self-contained: explain alternatives locally and
  retain Q1–Q6, including the absent ownership-placement rationale, without
  requiring readers to follow planning, proposal-history or audit links.
- D3. Keep existing section anchors where headings change. The live
  copy-edit/art/proof siblings already discharge the correction-run successor
  rule. Figure labels, captions and alt text belong to the queued art stage;
  record specific figure concerns in the document brief.
- D4. Replace the pressure-case summary table with connected explanations by
  capability. Distinguish unsupported generic/async/throwing fixture cases from
  core receiver effects and other already-expressible contracts. Rewrite all
  fragment labels to introduce their subject and name the required surrounding
  context, linking complete fixture files where available.
- D5. The leaf's one in-session reviewer examined the ownership, borrow,
  outcome and callback sections against C1–C6, F1 and the two fixtures. It
  reported no actionable mismatches. Its check covered entry consumption and
  invalidation, failure outputs, prospective owner retention, quiescence at
  return and the absence of termination guarantees. There were no findings to
  classify or a substantive repair requiring another review. This narrow
  technical read is not evidence of human comprehension; the queued checkpoint
  remains the human assessment.
- D6. Final validation passed: `task docs:check` checked 19 Markdown files,
  reached 17 pages, verified example fences and regenerated all 11 SVGs without
  differences. Before/after SHA-256 inventories matched for every file under
  `semantic/specification/interface-language/` and `semantic/specification/tools/`,
  plus `Taskfile.yml`, the documentation plan and the audit. A separate comparison
  with the parent change confirmed all 27 AIL fences byte-identical, every
  former section target retained, Q1–Q6 present and `view`'s 23-clause count.
  These checks establish document consistency, not semantic validator execution
  or native behaviour. Technical claims were read against L1–L6, C1–C8, A1–A5,
  F1, the grammar and fixtures; the whole three-page set was read against §9.2.
  Graph coverage (Tier 2, generation 2026-09-23T09:55:55Z) reports excluded
  design/research and fixture subtrees and changed document metadata; evidence
  for this Markdown-only task therefore comes from direct source reads, with
  no claim of structural graph completeness. No normative rule, fixture file
  or recorded architecture decision changed.
