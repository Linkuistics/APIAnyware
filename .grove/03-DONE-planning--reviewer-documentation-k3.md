# reviewer-documentation-k3

## Goal

Turn the settled reviewer purpose and `documentation-basis-k2` research into an
audited documentation architecture and a focused editorial task tree. Make the
AIL proposal reviewable by language designers unfamiliar with API bindings.

## Context

- Read `semantic/docs/research/documentation-basis-a.md` after the preceding
  research leaf delivers it.
- The root brief states the human's audience, intended outcomes, initial
  conceptual order, editorial contract and technical limits. Do not re-interview
  settled decisions or restore the earlier API-author-first assumption.
- Existing AIL material is under `semantic/specification/interface-language/`;
  `semantic/docs/README.md` currently links the specification. Follow ADR-0024
  for co-location and keep one canonical normative rule source.

## Work

1. Inventory the existing reader-facing pages, grammar, fixtures and relevant
   entry links. Audit actual problems with evidence: missing domain context,
   unexplained concepts, density, mixed purposes, difficult navigation,
   example usability and sentence-level defects. Do not invent flaws merely
   because the user's prompt supplies a category.
2. Deliver the requested **STEP 1: LINTING & STRUCTURAL AUDIT** as a concise
   report at `semantic/docs/research/interface-language-documentation-audit.md`.
   Anchor observations to the inspected revision and documents. Classify each
   page by intended purpose, preserve useful material, and distinguish
   presentation defects from possible issues in the language itself.
3. Establish reader journeys, page homes and exact section outlines for the
   tutorial, review/task guides, explanations and reference. Use the root
   brief's initial order, with research-backed refinements. Choose page sizes
   that restore context and reduce cognitive load without fragmenting every
   definition into its own page. Account for direct entry as well as guided
   reading. Make the rationale for non-obvious structural choices explicit.
4. Identify the smallest independently useful document increments, ordered by
   what later pages depend on. Keep each increment's navigation usable when
   it lands; avoid writing all fragments before any reader path works.
5. Cut bounded document nodes and initial `draft` leaves. Each must name a
   structure-brief artifact with reader/outcome, ordered section purposes,
   emphasis and non-goals, plus technical sources and verification method.
   Grow the remaining `copy-edit` -> `art` -> `proof` stages lazily through
   their predecessor sessions, as Grove's editorial procedure requires.
6. Specify how the completed document set will be presented as **STEP 2:
   REFACTORED OUTPUT**, linking the actual clean Markdown rather than prefixing
   every reader-facing page with process narration.

## Done when

- The evidence-based audit exists before any rewrite.
- Every necessary subject has a canonical home and a clear purpose; the plan
  covers introductory domain explanation and evaluative tasks as fully as it
  covers tutorial and exact reference lookup.
- Every new draft leaf has a complete, explicitly named structure brief and
  can execute without inventing an audience or required section order.
- Acceptance checks reach the complete reviewer journey, reference coverage,
  examples, local links/anchors, semantic fidelity and visual accessibility.
  Identify any real reusable documentation checks; do not claim the historical
  disposable EBNF recognizer or existing `.apiw` validator verifies this work.
- Technical ambiguity discovered during the audit is visible and is not
  silently "fixed" by changing the language under an editorial mandate.
- The tree contains meaningful document work with appropriate dependencies,
  with no speculative implementation, website deployment or language redesign.

## Notes

The human wants to evaluate the suggested language and provide feedback. A
brief that optimises only time-to-first-API-call, passive voice or word count
misses the task. Explanations must distinguish genuine domain obligations from
AIL's contingent design choices, and review prompts must permit critical answers.

This is a documentation workstream already authorised as a multi-step Grove.
Keep it coherent in this tree; split document work into bounded editorial nodes
as needed. No new runtime seam is requested. Consult the root brief's Taskfile
recommendation only if a concrete repeatable documentation check earns one.

## Decisions (running log)

D1. Format (human, 2026-09-23): the documentation set is GitHub-flavoured
Markdown, consistent with the rest of the repository. Code shown on pages is
kept in step with committed `.ail` files by a repeatable check, not by an
include mechanism. This settles the root brief's open format question (P7).
AsciiDoc, DocBook and Typst are not used now; a published edition would be new
work that this tree does not schedule.

D2. Reader testing (human, 2026-09-23): "There is only me (and I am an
experienced language designer)." No cold readers new to the domain are
available, so survey criteria T1, T3 and T5 cannot be run as written. The plan
uses the human's own review read at two checkpoints plus a model-based reader
that is labelled as a proxy (T4), and states this limit wherever reader
outcomes are claimed. The human knows the domain, so the curse-of-knowledge
evidence (Hinds 1999; Camerer et al. 1989) means their read cannot certify
newcomer comprehension. The proxy reader is briefed as a language designer new
to binding. It does not replace human evidence either.

D3. Placement: the whole reader-facing set lives with its subject in
`semantic/specification/interface-language/` (ADR-0024). New pages go in
`explanation/`, `tutorial/`, `review/`, `reference/` and `figures/`
subdirectories, with the README as the landing page. The normative files
(`language.md`, `contracts.md`, `profiles.md`, `grammar.ebnf`) and the
supporting files (`baseline.md`, `conformance.md`, `examples/`) keep their
paths, because the design proposal, its plan and `semantic/docs/README.md`
link to them. No new top-level `docs/` tree is created.

D4. One canonical rule source: the normative L, C, A and F text. Reference
entries are a lookup layer. They are labelled non-normative, link each fact to
its rule identifier, and yield to the rule when the two disagree. Explanation
pages state no rule force of their own; they cite the rule. This follows the
survey's §4.2 application. The AARM-style alternative, with annotations beside
the rules, is rejected because it would rewrite the normative files.

D5. The audit's F10 (lowercase *must* in normative files) is a language
question (Q1), not an editorial fix. The rework neither changes case nor
restates force.

D6. The L3 subset rule (L3; README lines 48–51) permits a package that
describes a named subset with its whole dependency closure. Each tutorial
checkpoint can therefore be a complete package for a narrower declared
`surface`. This confirms the survey's §4.3 assumption.

D7. No ADR. Markdown is the repository's default format, so recording it
fails the "surprising without context" test. The diagram-medium convention is
recorded in the documentation plan, which outlives the grove, and cited from
the root brief.

D8. Increments, in dependency order. Each one leaves every landed page
navigable:
- documentation foundation (explicit rule anchors, link and example checks);
- orientation (landing page, domain explanation, glossary);
- concepts (the contract model, packages and access, design choices);
- tutorial;
- a first human reading of that path, with a labelled proxy reader;
- reference;
- review guide;
- cross-set navigation and the Step 2 index;
- a second reading of the whole set.
The reference precedes the review guide, which is the capstone that uses
every other document.

D9. Step 2 presentation: the landing README is the entry to the rewritten
Markdown. The cross-set navigation increment appends a "Step 2: refactored
output" section to the audit. It maps each finding F1–F12 to the pages that
resolve it and gives the status of Q1–Q6. No reader page carries process
narration.

D10. Review chain: this decomposition drives about thirty sessions, so a
`review-planning` leaf (`reviewer-documentation-k25`) sits immediately after
this leaf and ahead of all execution. It carries seven specific doubts. With a
scheduled review beside it, this session spent no in-session reviewer. The
tree holds 12 `draft` sessions across six document nodes, one `impl` leaf and
two `requirements` reading checkpoints. The 12 are orientation 1, concepts 2,
tutorial 2, reference 4, review guide 2 and reviewer journey 1.
