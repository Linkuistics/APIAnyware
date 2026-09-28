# rule-reading-k66

## Goal

Add the language-model and selected syntax figures to the reading aids on
`language.md`, `contracts.md` and `profiles.md`, following the node brief's
specific G9/G10 handoffs and preserving every original normative byte.

## Context

- Structure brief: documentation plan §9.7; prose/examples/figures: §4–§6.
- The node brief inventories all figure slots, their named EBNF productions,
  exact example regions and permitted reuse. Read the whole three-page set.
- Copy-edit `rule-reading-k65` retained all snippets and slots. The common
  model uses Geometry/Canvas/position/Filter; contract/provider examples use
  Store/Counter/Subscription. Keep those names and their relationships.
- Canonical pre-draft revision for all three pages: `87221b8c`. Remove each
  complete paired reading-aid block, including its trailing blank separator,
  to recover the original page. Grammar, F1 catalogue, conformance record and
  frozen buffers/objects/callbacks fixtures remain unchanged.

## Work

Resolve the G9 model and G10 syntax slots according to the node brief. Keep
the function and its nominal owner as package-level siblings; show the member
relation separately. Pair each view with the named example, a reading key and
adjacent explanation. Railroad paths describe syntax; retain the explanations
of name resolution, required clauses, type checking and semantic validity.

Use the established notation/style and source-plus-generated-SVG workflow.
Inspect the rendered figures with their nearby examples. Preserve the
placeholder import digest and synthetic F1 token/provider limits. The Handler
extract at A2 and C6 is exactly lines 19–37 of `callbacks.ail`; preserve its
complete declaration boundary if any nearby material moves.

Run `task docs:diagrams:write` for intentional new/changed figures, then
`task docs:check`. Repeat canonical byte comparisons after the final edit,
inspect direct rule-entry and overview-to-rule routes, and clear each resolved
art handoff from the node brief. The existing prose is independent of the
figures and remains within the paired reading-aid boundaries.

## Done when

- Required G9/G10 views and any justified reuse fulfil the node brief; optional
  slots are either used or removed with their reuse decision recorded.
- Every figure has source, generated SVG, accessible adjacent prose and a
  reading key; rendered paths agree with the named grammar productions.
- Original normative text and anchors, grammar and frozen fixtures are
  preserved; `task docs:check` passes.
- A proof leaf with bare stem `rule-reading` is queued under this node unless
  a live later sibling already holds that stage.

## Notes

The node's human-directed bound sends substantive earlier-stage defects to
`first-path-reading-k64`, not another unattended correction cycle. Verification
establishes consistency, not human comprehension. That checkpoint owns the
human assessment; this stage owns only the figures and their explanations.
