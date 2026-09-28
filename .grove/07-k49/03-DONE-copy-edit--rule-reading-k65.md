# rule-reading-k65

## Goal

Copy-edit the non-normative reading aids across the complete language, contract
and provider rule pages, making their examples and explanations readable under
the document's prose contract while preserving every original normative byte.

## Context

- Structure brief: documentation plan §9.7; prose/examples/figures: §4–§6.
- Pages under `semantic/specification/interface-language/`: `language.md`
  L1–L6, `contracts.md` C1–C8, and `profiles.md` A1–A5/F1.
- Drafts rule-reading-k50 and rule-reading-k51, checked sources under
  `examples/rule-reading/`, and the node brief's conventions/Handed forward.
- Technical authorities: original rules, `grammar.ebnf`, glossary and frozen
  buffers/objects/callbacks examples. Canonical pre-draft revision: `87221b8c`.

## Work

Read all three pages, changing only the copy-edit charter's material within
paired reading-aid markers. Apply the human's positive framing and
action-before-abstraction requirements, with enough connected prose to teach
the relationship. Include labels, tables, captions and surrounding snippet
explanations in that read. Preserve fragment omissions, synthetic digest/provider
limits, and every statement separating grammar from semantic validity.

Keep identifiers aligned across the snippets and prose. The two-package model
uses Geometry/Canvas/position/Filter. Contract examples use the existing Store,
Counter and Subscription fixtures; constructed alternatives identify their
missing context. The A2 Handler extract is lines 19–37 of `callbacks.ail`;
inspect its boundaries as well as its equality. A previous shifted range was
fixed during draft. That bounded technical review found no other concrete
finding; it did not assess human comprehension.

Preserve all original rule wording and anchors. Removing each full paired
reading-aid block, including its trailing blank separator, must reproduce the
corresponding page from `87221b8c` exactly. Keep grammar, F1 catalogue and frozen
fixtures unchanged. The node brief gives the art slots, examples and EBNF
productions for G9/G10; pass that material forward without rendering it here.

Run `task docs:check`, inspect direct-entry and rule-link routes, and repeat
canonical-preservation comparisons after the last prose edit. Clear the
copy-edit handoff in the node brief when discharged. Art owns the remaining
figure handoffs.

## Done when

- The entire three-page set has been read against the copy-edit charter;
  context and example scope remain clear at direct rule entries.
- Canonical text/anchors, grammar and frozen fixture contracts are preserved;
  modified fences still match their checked source.
- `task docs:check` passes; source/semantic/human-assessment limits remain
  explicit in task evidence.
- The next art leaf is queued under rule-reading-k49 with bare stem
  rule-reading, unless a live later sibling already owns that stage.

## Notes

This is one pipeline for the reading aids. Do not absorb draft or art work.
The node's human-directed bound routes substantive earlier-stage defects to
first-path-reading-k64 instead of starting another unattended correction run.
The later orientation/concepts/tutorial corrections reuse this material after
this node completes its ordinary copy-edit → art → proof chain.

## Decisions (running log)

- D1: Keep the existing section order, examples and figure slots. Copy edits
  develop the concrete action before the term, clarify actors and scope, and
  link glossary-owned terms. All document changes stay within paired aids;
  no normative wording, snippet or source fixture needs changing.
- D2: Use direct Markdown, grammar and fixture reads as evidence. The graph's
  generation is `2026-09-23T09:55:55Z`; coverage reports changed Markdown
  metadata and excluded example/design directories. No structural-code or
  graph-completeness claim is needed for this prose-only task.

## Verification

- Read all three pages: L1–L6, C1–C8 and A1–A5/F1, including the rule text,
  tables, snippet labels and explanations. Kept section order, all AIL fences,
  fragment omissions, synthetic pins and provider limits. Glossary links now
  accompany the expanded explanations; `recognise` spelling is consistent in
  the changed profile aid. No structural correction was identified.
- Walked the Markdown routes from the overview's rule list and citations to
  L2, C1, C5, C6, A1 and A2. Direct entries locate the relevant declarations or
  full source package, name omitted context and offer explanation/glossary
  routes. `docs:links` checked destinations and reachability of all 17 pages.
  This was a source/navigation read, not a rendered-browser or human test.
- After the last prose edit, stripped every paired aid with its trailing blank
  separator: 17 blocks in language, 14 in contracts and 9 in profiles. Each
  result matched the corresponding `87221b8c` file byte for byte. A scratch
  mutation of retained normative text failed equality on each page. This also
  preserves the original rule anchors and F1 catalogue.
- Compared grammar, conformance record and frozen buffers/objects/callbacks
  files with `87221b8c`: byte-identical. Every AIL fence body in the three pages
  also equals its session-parent version. Inspected Handler lines 19–37:
  starts at `callback Handler(value: u64) -> unit {`, ends at its matching
  closing brace, includes the complete outcome. Both extracts use this range.
- `task docs:check` passed: links and examples checked 19 files; all eleven
  committed SVGs regenerated identically. SHA-256 digests before/after the run
  agreed for 67 input files: the full interface-language and documentation-tool
  trees excluding Python bytecode, root Taskfile, documentation plan and audit.
- These checks establish source consistency and preservation. The prose was
  inspected against the rules, glossary and frozen fixtures; no semantic
  validator or runtime was executed, and no human-comprehension result is
  claimed. Art owns G9/G10 and the remaining figure handoffs in the node brief.
