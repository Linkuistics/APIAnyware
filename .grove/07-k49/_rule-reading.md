# rule-reading-k49 — brief

## Goal

Make the existing canonical rule pages understandable when read directly by
adding explained examples, language-model diagrams and selected railroad
views beside their introductions. Preserve the normative wording and grammar.

## Contract

The structure brief is §9.7 of
`semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`.
Its §4–§6 govern examples, prose and figures; §7 governs the documentation
checks. The human's verbatim assessment is `first-path-reading-k48`, D2.
H5 concerns local/imported declarations and members; H6 concerns notation
introduced without its model or containing context.

## Decomposition

Two draft sessions, then copy-edit → art → proof. The first draft handles
`language.md` L1–L6 and the common model/syntax examples; the second handles
`contracts.md` C1–C8 and `profiles.md` A1–A5/F1. Only the second cuts copy-edit.
Later stages read all three pages. All stage leaves use the stem rule-reading.
Record needed figures in a Handed forward section for art.

This is the first editorial pipeline for these reading aids. It is separate
from, and precedes, the human-directed second corrections in orientation,
concepts and tutorial. A defect that would send this work back is recorded for
`first-path-reading-k64`; do not start a further unattended cycle.

## Done when

- The three canonical pages supply local context and explained snippets as
  constructs are introduced, with a page-one block and labelled reading aids.
- The language model locates packages, declarations, imports, members and
  callable slots; concrete examples distinguish every reference form cited
  in the human's L2 feedback, including a named receiver and bare type names.
- G9/G10 and any necessary detail figures have sources and regenerated SVGs,
  keys, reading order, adjacent explanation and grammar/rule traceability.
- The original normative text, stable rule anchors, grammar and fixture
  catalogue are preserved and their preservation is checked explicitly.
- `task docs:check` passes; snippets match committed fragments and examples
  have truthful scope labels. Direct rule entry and overview-to-rule routes
  were inspected. No semantic-validator or human-comprehension claim follows.
- The following document corrections can reuse the actual landed examples
  and figures; their paths and boundaries are carried into the root brief.

## Notes

The human requests examples at the quoted L2 paragraphs themselves. A link to
a future reference entry alone does not meet that requirement. Keep explanatory
additions distinct from requirements and introduce one relationship at a time.
Complete examples remain complete; a partial teaching fragment states its
omitted context. No new language feature or runtime test seam is in scope.

## Draft conventions and reuse

The first draft's additions in `language.md` use paired HTML comments:
`<!-- reading-aid: ID -->` and `<!-- /reading-aid -->`. The closing marker
includes the blank line following it. Removing each full block recovers the
pre-edit normative file byte for byte. At first-path-reading-k64, the human
requested a visual boundary: each body now has a blockquote's left border,
bold non-normative labels and explicit anchors preserving its former heading
links. The visible end marker is removed (the page-one block is separate).
This convention applies to all three canonical pages. Compare canonical content
against the pre-draft revision, not a stripped text reconstructed from an already
modified rule.

Checked sources live in
`semantic/specification/interface-language/examples/rule-reading/`:
`syntax.ail`, `geometry.ail`, `canvas.ail`, `types.ail`, `clauses.ail`,
`patterns.ail` and `invalid.ail`. Region files are collections of independent
teaching fragments, not concatenable or complete packages. Named regions drive
the existing `ail-example` comparison. Frozen `objects.ail` and `buffers.ail`
extracts use line ranges; those originals have not been edited.

The common model is `example::geometry` version `1`, declaring `Point`, and
`example::canvas` version `1`, importing it as `Geometry` and declaring
`Canvas`, member function `position(canvas: Canvas) -> Geometry::Point`, and
callback `Filter(point: Geometry::Point) -> bool`. The all-zero import digest
is a deliberately labelled placeholder; no new complete package or fixture
provider is claimed. The source/access extract borrows F1's synthetic
`fixture`/`native` pair. Its three identities are the tuple
`(example::canvas, "1", position)`, source `"Canvas.position"`, and symbol
`"canvas_position"`. `direct` names an access path, not a declaration.

The L4 hypothetical `collections::Sequence<i32>` has no supplied profile and
is explicitly outside F1 support. L5's nominal relations and L6's session-order
example are constructed sketches whose omitted contracts still need to establish
compatibility/lifetime/availability. Do not promote them to complete examples.
The existing full fixture and tutorial packages retain that separate purpose.

The second draft adds `examples/rule-reading/contracts.ail` and `providers.ail`.
These also hold independent named fragments, not complete packages. The Store,
Counter and Subscription extracts preserve the frozen examples' facts. The
additional canvas inspection, text input and reference replacement are constructed
fragments with omitted context. The optional Panel member explicitly requires a
provider beyond F1. Inline copy/weak/unretained storage, artifact compatibility
and actor variants are conditional illustrations, not added fixture capabilities.
The canonical pre-draft comparison revision for **all three** pages is
`87221b8c`. Strip entire paired reading-aid blocks, including the newline after
the closing marker and its blank separator, then compare bytes with that revision.
The grammar, conformance record and frozen buffers/objects/callbacks packages
also remain byte-identical to that revision. Preserve those boundaries during
copy-edit and art. Checks of snippet equality do not establish that a line range
contains the entire declaration it claims: inspect the first/last lines too.

Copy-edit read the complete three-page set and expanded action-first accounts
of slots, dependency closure, roles, lifetime, concurrency, mapping and
representation. The examples and figure slots are unchanged. The A2 and C6
Handler extracts both include the complete declaration at `callbacks.ail`
lines 19–37. Canonical preservation and `task docs:check` passed after the final
prose edit. These are editorial and consistency checks; the human reading at
`first-path-reading-k64` still owns assessment of understanding.

## Figure reuse

Art supplied G9 at `figures/g9-model.{puml,svg}` and G10 at
`figures/g10-{shell,clause,names,callable,places,environment,pattern,outcome,callback-use,dependency,access}.{puml,svg}`
under `semantic/specification/interface-language/`. The model uses the existing
Geometry/Canvas/position/Filter examples. Its callable compartments own the
slots; Canvas and position remain sibling declarations. The syntax figures use
exact productions from `grammar.ebnf`, the shared style and the unboxed status
caption in `railroad-caption.puml`. The human's railroad fluency makes
instructional legend boxes unnecessary.
All required and optional slots are resolved; there is no outstanding art handoff.

L2 and C1 reuse the same place figure with local examples. C5, C6 and
A2 link the callable overview and supply their own nested-block detail. The
existing G3 provider and G7 timing explanations remain linked rather than
being duplicated. Environment and pattern details were retained because the
shell does not expose their inner structure. Later correction sessions can
reuse these sources/SVGs and the existing checked fragments; retain the
placeholder-import and synthetic-provider limits. Proof should promote these
paths and boundaries to the root brief when the node closes.
