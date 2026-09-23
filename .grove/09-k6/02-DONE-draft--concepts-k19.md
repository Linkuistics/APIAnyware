# concepts-k19

## Goal

Draft `explanation/packages.md` and `explanation/choices.md`, and add the concept pages to the landing page's map and their terms to the glossary.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §9.2 (the `explanation/packages.md` and `explanation/choices.md` parts). It states the reader and outcome, the ordered
  sections with their purposes, and the emphasis and non-goals. Quote it
  rather than re-deriving it.
- Prose contract, labels, figures and checks: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §4–§7.
- Evidence: the audit (`semantic/docs/research/interface-language-documentation-audit.md`) and the survey's §9 criteria D1–D8.

## Done when

- Both pages follow §9.2's section order. Every choice section names at
  least one alternative and one cost.
- The open-question register holds audit Q1–Q6 and every item from the node
  brief's `## Questions found`, each with where it arises and why it matters;
  that note is then cleared.
- Under the staging rule in the plan's §3: the landing page's map links the two new pages;
  each has a return route and a next route to existing pages; and plain-text
  mentions of them on landed pages are now links. The landing page links all
  three concept pages, and the glossary covers their terms.
- `task docs:check` passes.

## Notes

The design proposal's syntax sketch is a historical fragment and must be labelled so. Do not supply a rationale for the ownership-in-clauses decision (Q3). Report that none is recorded.

This is the node's last draft session, so its last act is `leaf-add` of the `copy-edit` leaf, unless a live later sibling already holds one.

## Decisions (running log)

- Structure precondition: plan §9.2 says the reader is “The primary reader,
  after orientation”, able to “tell a domain constraint from an AIL choice”.
  Its ordered sections run from “Four identities” to “One contract, several
  views” for packages, and from “How to read this page” to “Open questions”
  for choices. Its emphasis is “Honest trade-offs”; its non-goals include
  “No exhaustive clause coverage” and “No proposed fixes for open questions”.
  Both pages retain that order.
- Explain required core facts and known absence, without a blanket ban on
  defaults: A1 explicitly admits profile-defined defaults while forbidding
  unknown facts from becoming authoritative defaults. This is a precision
  correction to §9.2's shorthand, not a language change.
- Use the synthetic `objects.read_count` access alternatives for the identity
  and access explanation; use the frozen `buffers.view` body for a clause
  count whose scope includes nested outcome and access clauses.
- Q1–Q6 stay open. There is no `Questions found` section in the current node
  brief to migrate. G2 and G3 will be handed to art; prose supplies their facts.

## Verification

- Structure: both page heading sequences match §9.2. Each substantive choice
  has a concrete comparison, an alternative and a cost. The ownership sketch
  is labelled historical and distinguished from the immutable fixture API;
  no rationale is invented. Q1–Q6 each retain question, location and consequence.
- Technical truth: directly read L1–L6, C1–C8, A1–A5/F1, the grammar, the
  three frozen examples, conformance interpretations/pressure cases/two views,
  design §2–§9 and audit Q1–Q6. Claims trace to those documents. No structural
  implementation exploration or graph-coverage claim was needed for this leaf.
- `view` in `buffers.ail` lines 72–100 has 23 clause statements: 14 in its
  body, five in `viewed`, four in `direct`. Enumerated the statements and
  checked the grouping; constructors and block headers are excluded.
- `task docs:check` passed: links in 13 files, 11 reachable pages, examples
  in 13 files, and byte-identical regeneration of G1 and G4. The first example
  check exposed an off-by-one source marker on the getter extract; correcting
  it to `objects.ail` lines 44–55 made the exact comparison pass.
- SHA-256 inventories before and after the final gate matched by path (sorted
  before comparison because filesystem enumeration order differed) for all files
  enumerated under `semantic/specification/interface-language/` and
  `semantic/specification/tools/`, plus `Taskfile.yml`, the documentation plan
  and audit. No checked subject changed during the run.
- Landing map and existing orientation/contract footers now link the landed
  pages; packages leads to choices, which leads to the existing conformance
  examples pending the tutorial. Glossary definitions cover publication/access
  terms and link all three concept pages.
- No AIL semantic validator or native runtime was run. Structure and technical
  truth were checked by inspection; copy-edit, G2/G3/G5–G7 and proof remain
  the subsequent stages. No additional language ambiguity was found.
