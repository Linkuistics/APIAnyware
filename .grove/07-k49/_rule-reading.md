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
pre-edit normative file byte for byte. Each body has a visible non-normative
heading and “End of reading aid.” boundary (the page-one block is separate).
The second draft uses this convention in contracts/profiles and preserves it
through later stages. Compare canonical content against the pre-draft revision,
not a stripped text reconstructed from an already modified rule.

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

## Handed forward

- **Copy-edit — whole set.** Read all of `language.md`, `contracts.md` and
  `profiles.md`, applying plan §4–§6 only inside the marked aids. Preserve the
  canonical text outside them exactly. Check connected explanations, positive
  framing and terminology in captions, labels, tables and snippet commentary;
  keep fragment labels and provider limits explicit. The technical reviewer
  found one A2 Handler extraction error, now corrected to `callbacks.ail`
  lines 19–37; there is no unresolved technical finding from that bounded read.
  Readability and human understanding have not been assessed by that review.
- **Art — C1 `G10-places`.** Reuse or expand the L2 place view if it can show
  `$selection.canvas`, `$items[]`, `$point.*.x` and `$result.x` without overload.
  Pair it with `contracts.ail` region `places`. `[]` is uniform array/buffer
  element selection, not an index expression; `.*` requires the single-pointee
  extent when addressing pointer storage. Grammar repetition does not perform
  type checking. Keep the geometry/canvas model reachable from this detail.
- **Art — C5 `G10-outcome` and C6 `G10-callback-use`.** Show the nesting of
  `outcome` and `callback_use` inside `callable`, using `copy_bytes` and
  `subscribe` respectively. A combined callable-body overview plus small
  details is allowed. Preserve the distinction between `callback Handler(...)`
  (a declaration with its own slots) and `callback $handler { ... }` (the
  registration's schedule). Pair with `contracts.ail` regions `outcomes` and
  `callback-use`, and the frozen Handler declaration. C5 checks partitions;
  C6 checks schedule/retention/quiescence relationships. A railroad proves
  neither. The existing G7 timing explanation remains linked through the
  concepts callback section; no new timing figure is required by this draft.
- **Art — A1 `G10-dependency`, A2 `G10-access`.** Draw the `dependency` choice
  `use profile`/`use abi` using the declared aliases `fixture`/`native`; pair
  with `providers.ail` region `dependencies`. The `access` production pairs
  with region `paths`: path name, nonempty `in [test]` list, clause block.
  Show how it sits inside `read_count`; use or link G3 for the provider
  relationships instead of duplicating that whole structure. The generic
  grammar permits repeated clauses; A2 defines the required singular clauses.
  Reuse existing G10 views where they already teach the needed syntax, with
  adjacent reading keys and rule links. Every surviving slot is resolved by
  a figure or an explicit justified reuse; no dangling slot comments remain.

- **Art — G9, L2 `G9-model` slot.** Show containment from the two named/versioned
  packages to their declarations, the canvas → geometry import labelled
  `Geometry`, and `position` → `Canvas` member ownership. `Canvas` and
  `position` are siblings; no visual nesting that makes the function part of
  the resource body. Show `position`'s named `canvas` parameter and Point result,
  and `Filter`'s `point` parameter and Boolean result, as slots owned by their
  respective callables. A second detail view beside `l2-references` is allowed
  if putting all slots in the main view overloads it. The prose carries these
  facts, including the difference between declaration references, bare type
  names and callable-local `$` places. Keep the diagram before the model's
  member snippet; it may move earlier to precede alias-dependent notation.
- **Art — G10 shell, L1 `G10-shell` slot.** Railroad paths for `document`,
  `item` and `clause`, with `arguments`/`value`/`list` expanded only as needed.
  Pair with `syntax.ail` region `shell`. The grammar's version token is a
  general `string`; the prose separately states the required `"0.1"` value.
  Its repetition permits zero items syntactically; L3's mandatory content
  remains a semantic rule. Show literal tokens, nonterminals and repetition
  distinctly and explain the reading direction and key.
- **Art — G10 values, L1 `G10-clause` slot.** `clause`, `arguments`, `value`
  and `constructor`, paired with `syntax.ail` region `clause` and the prose's
  `deprecated(no)` comparison. Semicolon belongs to the clause, not the
  nested `since("2")` constructor. Reuse the shell figure if it already
  teaches this distinction clearly; do not silently lose the case.
- **Art — G10 names, L2 `G10-names` slot.** `import`, `reference`, `name`,
  `callable`, `parameters`, `parameter` and `place`; split into small views
  where needed. Use `Geometry::Point`, `@Canvas`, `@position::canvas`,
  `@position::result`, `@Filter::point`, `@Filter::result`, `$canvas` and
  `$result.x`, with exact surrounding examples from `canvas.ail`. The grammar
  admits `@name` uniformly; package/slot resolution is semantic, not a
  railroad branch that the grammar itself distinguishes. Preserve callback
  and optional `throws` paths when depicting the full `callable` production.
- **Art — optional G10 details at L3/L6.** The `G10-environment` and
  `G10-pattern` slots identify `environment`/`clause` and
  `pattern`/`role`/`instance` respectively. Add a detail only if the shell,
  names view and located examples leave a syntactic relationship unexplained;
  otherwise remove these optional slot comments. Examples: `canvas.ail`
  region `publication`; `patterns.ail` regions `slots`, `cardinalities` and
  `ordering`; the unchanged buffers lifetime extract. Check every rendered
  path against the named EBNF production, add a reading key and adjacent
  explanation, and regenerate SVGs with the established workflow.
