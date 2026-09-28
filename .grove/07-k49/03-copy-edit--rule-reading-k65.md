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
