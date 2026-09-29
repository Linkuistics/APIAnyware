# reference-k16

## Goal

Draft `reference/README.md`, `types.md` and `declarations.md` with the
applicability table; extend the existing `notation.md` with entry conventions
and index routes. Verify and extend the normative pages' existing reading
routes, add page-one blocks to the supporting files, and add `task
docs:coverage` with its enumerated inventory.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §9.4. It states the reader and outcome, the ordered
  sections with their purposes, and the emphasis and non-goals. Quote it
  rather than re-deriving it.
- Prose contract, labels, figures and checks: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §4–§7.
- Evidence: the audit (`semantic/docs/research/interface-language-documentation-audit.md`) and the survey's §9 criteria D1–D8.
- Read first-path-reading-k48 and first-path-reading-k64 for the human's
  assessments, then model-reading-k73's example-led refinement. Rule-reading-k49
  supplies the normative pages' context blocks, local examples and language
  model; concepts-k85 supplies the grammar/railroad home. Preserve and reuse
  them, with syntax figures kept on `reference/notation.md`.

## Done when

- `task docs:coverage` extracts candidates from every normative source and
  checks them against a committed disposition list, as the plan's §7
  specifies. The extraction covers running prose as well as tables. Every
  prose-defined clause named in audit F5 appears as a candidate, and the list
  classifies all of them.
- It has been seen to fail on an unclassified candidate, on a missing entry
  in a landed file, and on a disposition naming nothing in the sources. It
  lists by name which entries the next three sessions own, as pending.
- Under the staging rule in the plan's §3, the landing map links
  `reference/README.md`, which links every reference page that exists and
  names the clause files as plain text until they land.
- Declaration and type entries use the §9.4 fields that apply.
- The existing grammar description, all eleven G10 views, section anchors
  and incoming links survive the extension of `notation.md`. The reference
  index adopts this already-landed page. Other entries show their forms and
  examples, link to its grammar sections, and omit elementary punctuation
  narration while explaining AIL-specific meaning.
- Normative wording, anchors and grammar remain unchanged. Existing labelled
  reading aids remain available; only their context/navigation is extended
  to the new reference. The entries illustrate local/imported declarations,
  a member and receiver, and declaration/slot/place references in context.
- The plan's §2 clause-file split is confirmed or amended against the entry
  count.
- The disposition list records the plan §10 model concept of every
  entry-class item, and `docs:coverage` has been seen to fail on an entry with
  no concept or a concept that is not an anchor on `explanation/model.md`.
  Every §10 concept has an entry or a recorded reason.
- Declaration and type entries carry the *Expresses* field (plan §9.4), and
  `reference/README.md` has a model-concept index covering the entries that
  exist, with the pending clause entries named.
- `task docs:check` passes.

## Notes

Until the clause files exist, `docs:coverage` may report their entries as pending; make that state explicit rather than passing silently.

A later draft sibling finishes this document, so do not cut `copy-edit` here: the last draft session does.

## Decisions (running log)

D1 — The named structure brief is plan §9.4: “Any reader looking up an exact
fact” is to find syntax, operands, applicability, requiredness, repeatability,
defaults, constraints and rejection conditions. Its ordered sections are the
reference map/indexes, notation, types, declarations/applicability and grouped
clauses, then canonical/supporting context. Its emphasis is “Uniform fields
and completeness against the enumerated inventory”; its non-goals are “No new
rules, no rewording of normative text, and no resolution of open questions.”
The existing approved plan and this mandated draft authorize that design.

D2 — Preserve the grammar home and all G10 views. Add model-linked fixed-field
type/declaration entries and reuse the canonical language-containment example.
The coverage command is a standard-library lexical inventory and disposition
checker, not an AIL parser. Its classifications live outside reader-facing
pages, in the specification tools directory. It reports future clause entries
by name and owner; a landed file cannot retain pending entries. Contract tests
exercise the required failures before the checker is relied on.

D3 — Inventory classification found 229 candidates and 64 clause entries:
29 package/common/nominal, 15 callable/input/storage, 9 outcome/schedule and
11 access/pattern/fixture. Keep the four-file split and record exact filenames
and shared-scope spellings in plan §2. The TSV owns target anchors, concepts,
classification reasons and the three later draft owners. Pending is explicit;
all eleven model concepts have entries (landed or pending).

D4 — One fresh-context adversarial review of the type and declaration summaries
against the normative corpus returned two actionable qualifier omissions:
L5 permits provider-defined receiver types as well as the owner type; C6 owner
scope requires an owned returned object/resource. Re-read both source rules
and restored the exact qualifiers in the applicability table and callback-use
constraint. Neither changes the structure or introduces a new interpretation;
no further review is needed for these direct wording corrections. There were
no contract-misread, trade-off or noise findings. The leaf-wide review allowance
is spent. Sentence polish remains for the later copy-edit stage.

D5 — Final verification passed: `task docs:check` checked links and examples
in 24 files, with 22 site pages reachable; all 26 SVGs regenerated identically.
Coverage classified 229 candidates, reporting all 64 future clause entries by
name and owner with zero errors. The strict `--require-complete` gate correctly
rejects that pending state. `task docs:coverage:test` passed 14 contract tests;
Ruff and strict Pyright reported no errors. Before implementation, eleven
contract tests failed against the empty checker scaffold for their intended
missing behaviours; the positive existing-entry case supplied the control.

Against the actual inventory, separate mutations were rejected for an
unclassified candidate, missing entry anchor, disposition absent from sources,
missing concept, non-anchor concept and a pending entry in a landed file.
Every prose-defined clause enumerated in audit F5 is present and classified.
The fixture does not validate AIL syntax or native behaviour; reference snippets
are labelled fragments and checked against new committed `.ail` sources.

The preservation comparison verified its baselines against parent commit
c30b36c7, then confirmed byte-identical normative text after removing marked
reading aids, unchanged rule/aid anchors, unchanged grammar, and the existing
notation page's text, examples, syntax-section anchors and eleven G10 links.
That comparison first detected lookup text placed outside a reading-aid marker;
the insertion assumed an HTML blockquote in the page-context block, which uses
Markdown blockquote lines instead. The corrected Lookup line is inside the
existing page-context marker and border. The comparison then passed; deliberate
normative-token and labelled-aid controls verified what it detects/excludes.

The final run froze 121 subjects: all interface-language files and documentation
tools (excluding Python caches), root Taskfile, plan, audit, the two temporary
verification scripts and five parent-baseline files. Before/after paths and
SHA-256 hashes matched item for item. Manifest SHA-256:
`a56da7a02e003e3d727cfffbe210e0770e8e266ae0f518ba6ea57ac8cfae716a`.
External URLs were not fetched; no parser, semantic validator, implementation
execution or human comprehension result is claimed.

D6 — Graph evidence remained Tier 2 at generation 2026-09-23T09:55:55Z.
The bounded tool search returned no nodes (pagination complete); tools and
research/design sources are excluded, examples excluded, and current reference
and normative Markdown metadata is untracked or changed. Coverage was checked
for the relied-on paths and all material claims use direct source reads. No
code-structure completeness conclusion is drawn from the graph.

D7 — Retire reference-k16 with the reference landing map, ten type-family
entries, declaration/block entries and applicability table, notation conventions,
canonical/supporting lookup routes and checked inventory in one commit. The
remaining three drafts own the 64 explicitly pending clause entries and final
indexes. Their inventory handoff is in the node brief; no new figure is needed.
The node still has live draft siblings, so there is no parent close and no
copy-edit leaf is cut by this session. The last draft retains that responsibility.
