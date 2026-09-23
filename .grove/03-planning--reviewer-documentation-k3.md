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
