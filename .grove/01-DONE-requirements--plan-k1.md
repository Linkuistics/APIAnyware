# plan-k1

## Goal

Establish the reader outcomes, scope, editorial contract and acceptance criteria
for documentation that lets language designers evaluate the proposed API
Interface Language and provide informed feedback.

## Context

- The user: "I want to improve the quality of the documentation to provide
  tutorial, guide, and reference for the language you previously developed."
- Existing language draft: `semantic/specification/interface-language/`.
- The user's supplied editorial prompt requires an explicit structural/style
  audit before rewritten Markdown, Diátaxis separation, technical accuracy,
  condition-before-action instructions, active voice, clear noun references,
  meaningful examples, imperative procedural steps and code typography.

## Done when

- The intended audience and reader outcomes are clear.
- The scope, document structure, editorial rules and verification expectations
  are recorded for subsequent work.
- The work has an appropriately sized next leaf, with the user's decisions
  carried into its brief.

## Notes

The existing README calls AIL a proposed normative draft, not APIAnyware's
implemented format, and explicitly says no parser or executable conformance
suite is delivered. Documentation must preserve that distinction.

## Decisions (running log)

D1. The user requests improved tutorial, guide and reference documentation for
the existing API Interface Language. The supplied editorial prompt establishes
an audit-before-rewrite process and separates tutorial, how-to, reference and
explanation content. This is documentation work; no language or runtime change
has been requested.

D2. The user asks us to examine the books referenced in Richard Rabil's
"The Best Books on Technical Writing: An In-Depth Analysis":
https://richardrabil.com/2024/08/18/the-best-books-on-technical-writing-an-in-depth-analysis/.
The dedicated research leaf must inspect the relevant books through available
primary material, distinguish previews/summaries from full-text reading, and
turn the evidence into practical editorial criteria.

D3. The user explicitly says this is a multi-step Grove involving web search.
This requirements session establishes the brief and queues research followed
by planning; it does not collapse the documentation rewrite into this sitting.

D4. The user clarifies the purpose: "I want these documents so we can evaluate
the suggested language and provide feedback." The readers are "unfamiliar with
the domain but familiar with language design, aesthetics and the target
audience expectations." The existing material "provides not enough context,
nor explanation and is too dense for review" by those readers. This replaces
the assistant's earlier provisional API-author audience. Domain introduction,
design rationale, progressively explained examples and an evaluative reading
path are central deliverables, not optional additions to a reference cleanup.

D5. The root brief records the settled audience and review purpose, initial
conceptual order, editorial contract and verification boundaries. Detailed
editorial choices remain with research and planning. The next leaves are
`documentation-basis-k2` (web/literature research) and
`reviewer-documentation-k3` (audit, information architecture, structure briefs
and editorial decomposition), in that order. There is no full grilling:
the human has already settled the load-bearing requirements. The earlier
optional audience question is answered by D4, not left pending.
