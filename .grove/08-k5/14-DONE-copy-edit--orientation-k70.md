# orientation-k70

## Goal

Copy-edit the orientation document after its model-first draft: the new
`explanation/model.md`, and the routing edits to `README.md`,
`explanation/unsaid.md` and `glossary.md`.

## Context

- Draft: orientation-k69 and its commit. Structure briefs: plan §9.8 and
  §9.1's *Model-first run* block; concept names and anchors: plan §10.
- Prose contract: plan §4, especially *Two models, one purpose*, *Make the
  model the main thread*, density and positive framing.
- The node brief's `## Handed forward` list.

## Done when

- The model page reads as a synthesis the primary reader can follow without
  AIL: each concept section develops one relationship at a time, names actors
  and consequences, and uses the concept's §10 name consistently. "Model"
  unqualified always means the API model; G9 is called the language-
  containment view wherever it is mentioned.
- The same concept names are used, unchanged, in the domain page's routing
  sentences, the glossary links and the landing page.
- Headings, table cells and link text follow §4. Concept anchors are unchanged.
- `task docs:check` passes.

## Notes

Charter: sentences, terminology and consistency, not structure. A structural
defect goes to the node brief's `## Handed forward` for proof or, if it would
send work back to draft, is recorded for `model-reading`; the run's bound
authorizes no correction run. Art and proof are already queued, so cut
nothing at the end.

## Decisions (running log)

- D1: Keep the eleven concept names, section order and anchors. Standardize
  G9's remaining orientation labels as the language-containment view, and use
  the model's full concept names in routing sentences.
- D2: Clarify actors and referents in the model's output, lifetime, callback
  and validation explanations. Link glossary-owned terms where first used;
  preserve the separate watch contracts and the existing technical claims.
  These are sentence-level changes, with no new structure or language rule.

## Verification

- Read the four orientation pages against plan §4, §9.1, §9.8 and §10 and
  the glossary. The edits clarify output initialization, release responsibility,
  callback state and validation; the concept set and watch alternatives remain.
  No new structural finding or later-stage defect was identified. The existing
  G11 handoff remains for art; no additional stage is cut.
- `task docs:check` passed: 20 Markdown files checked, 18 pages reachable,
  AIL examples matched their sources and all 24 existing SVGs reproduced.
  SHA-256 manifests before and after the run match item by item for the
  interface-language tree, documentation tools, `Taskfile.yml`, documentation
  plan and audit (Python caches excluded).
- Compared all four pages with parent revision `d843bd96`: headings, explicit
  anchors, fenced examples and image embeds are unchanged. Removing an item
  from each nonempty extracted list made the equality control fail as expected.
  Enumerated concept-route links in the four pages and checked their labels
  against the model's eleven concept headings; every such label matches.
- Graph coverage was checked at generation `2026-09-23T09:55:55Z`. Relevant
  Markdown metadata is stale or untracked and the design directory is excluded;
  direct reads supplied the evidence. No code-structure claim was made.
- These checks establish consistency, not human comprehension. Art and proof
  remain live under orientation-k5, so this retirement closes no parent node.
