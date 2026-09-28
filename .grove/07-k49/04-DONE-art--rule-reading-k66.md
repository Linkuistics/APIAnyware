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

## Decisions (running log)

- D1: Use the pinned PlantUML renderer's native EBNF railroads, with exact
  productions copied from `grammar.ebnf`, shared style and a local reading key.
  This preserves grammar alternatives/repetition without introducing a parser
  or a new medium. Split shell, values, names/import, callable, places and
  provider details so each view serves its adjacent example.
- D2: G9 uses package folders containing sibling declaration boxes and a
  separately labelled member arrow. Callable compartments own the named slots.
  Keep the import arrow between the packages; type labels use the same Geometry,
  Canvas, position and Filter names as the fragments.
- D3: Use both optional details: `environment` exposes its named clause block;
  `pattern`/`role`/`instance` expose distinct body nesting and independent kind
  and cardinality choices. The generic shell does not expand these structures.
- D4: Reuse `g10-places.svg` at L2 and C1, with C1's concrete path table.
  C5, C6 and A2 link the full callable track and add their own small detail.
  Declined duplicate full provider and callback-timing figures by editorial
  judgement: the existing linked G3 and G7 explanations already carry those
  relations. No fix was forbidden by the contract or impossible in the medium.

## Verification

- Read the three-page set against the art charter, node handoffs and plan §4–§7
  and §9.7. All named figure slots were replaced. Source/SVG pairs and adjacent
  explanations retain the example names and syntax-versus-validity boundary.
- `task docs:diagrams:write` generated the figures; final `task docs:check`
  passed: links and reachability, checked snippets and byte-identical SVG
  regeneration. SHA-256 digests before/after the final check matched for every
  enumerated input: specification `.md/.ail/.ebnf/.puml/.svg/.txt` files,
  documentation tool `.py` files, Taskfile, documentation plan and audit.
- After the final document edit, stripping complete paired reading-aid blocks
  (closing marker plus blank separator included) recovered all three pages
  byte-for-byte from `87221b8c`. Grammar, conformance record and the frozen
  buffers/objects/callbacks files also matched that revision. The first scratch
  comparison exposed Ruby string-encoding inequality; binary comparisons and
  a direct diff confirmed identical bytes, with no document repair needed.
- Each G10 production body was compared exactly with `grammar.ebnf`. Inspected
  the rendered paths, including empty/repeated bodies, optional parameters and
  throws, both callable keywords, every value branch, nonempty access lists,
  and the place/role alternatives. This is syntax correspondence, not an AIL
  parser or semantic-validator result.
- Inspected temporary headless-browser Markdown previews of each figure-bearing
  aid beside its existing examples and prose, enabling table rendering for the
  references, places and callback comparison. No figure clipping or relation
  ambiguity was found at the inspected desktop width. The complete Handler
  extracts at A2/C6 still cover `callbacks.ail` lines 19–37.
- Followed the overview's canonical-rule links and direct L2/C1/A1/A2 entry
  routes in source; checked the local model/detail/example links and visible
  reading-aid boundaries. The repository link checker confirms destinations
  and anchors. This does not establish human comprehension; k64 owns that read.
- Graph project generation was `2026-09-23T09:55:55Z`. Coverage reported changed
  or untracked documentation and excluded tool/design/fixture scopes, so the
  evidence above uses direct files, exact comparisons and rendered artifacts,
  not graph completeness. No earlier-stage defect or unresolved art handoff
  was identified. Proof remains required.
