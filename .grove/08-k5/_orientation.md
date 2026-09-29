# orientation-k5 — brief

## Goal

Land the orientation document: the landing `README.md`,
`explanation/unsaid.md` and `glossary.md`. A language designer new to API
binding can then state what AIL is and its status, explain the caller's and
implementer's obligations through concrete operations, and choose a path
through the documentation (plan outcome 1).

## Contract

The structure brief is the documentation plan's §9.1, at `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`. It states
the reader and their outcome, the ordered sections and the purpose of each,
and the emphasis and non-goals. The same plan's §4 (prose contract), §5
(page-one block and example labels), §6 (figures) and §7 (checks) govern
every stage. The gate is `task docs:check`, plus any task this document adds.

## Pipeline

`draft` → `copy-edit` → `art` → `proof`, cut lazily: each stage's last act
adds the next unless a live later sibling already holds it. Stage leaves carry
this document's bare stem as their slug. Defects a later stage owns go under
`## Handed forward` in this brief; the list is created by the first stage that
needs it. Figure slots that `draft` leaves for `art` go there too.

## Done when

- The three pages exist and meet §9.1. Every domain term in the root brief
  has a defining location and a glossary entry with a familiar-meaning warning
  where one applies.
- The landing page links every page that exists when this lands, and the
  existing normative and supporting pages remain reachable from it.
- Figure G1 (context) is committed as source plus SVG and reused as the map;
  the page's G4 slot is drawn or explicitly handed on to `concepts`.
- `proof` has walked the landing page to the domain explanation to the
  normative files, from a cold start and from a direct entry.

## Figure assets

G1 is `figures/g1-context.puml` plus its SVG, embedded in the landing page and
linked as the publication map from the domain explanation. G4 is
`figures/g4-ownership.puml` plus its SVG, embedded in the ownership section and
available for reuse by `explanation/contracts.md`. Both use
`figures/style/ail.puml`; the vocabulary and regeneration commands are in
`figures/style/vocabulary.txt`. These paths are relative to
`semantic/specification/interface-language/`.

`task docs:check` includes `docs:diagrams`, which compares regenerated SVG bytes.
Use `task docs:diagrams:write` after source or style edits, then inspect the SVGs.

G11 uses two linked views: `figures/g11-calls.{puml,svg}` for the call layer
and `figures/g11-description.{puml,svg}` for the description and access layer.
Both are embedded in `explanation/model.md` under *The model at a glance*,
with alt text and captions. The outcome-to-responsibility arrow concerns
returned obligations; the watch lifetime and callback schedules remain
alternative contracts. G1 and G4 now use the model's concept names in their
titles and orientation captions. G9 retains its language-containment role.

## Model-first run

The human's 2026-09-29 direction (first-path-reading-k64, D12–D13) makes the
model the organizing structure: explain it, then describe AIL by reference to
it, because the language is a tool. model-first-documentation-k68 gave this
node the canonical model account: the new `explanation/model.md` with figure
G11 (plan §9.8), plus routing edits to `README.md`, `explanation/unsaid.md` and
`glossary.md` (plan §9.1, *Model-first run*). The concept set, anchors and
construct map are plan §10.

This new human direction authorizes exactly one ordered run, orientation-k69
(draft) through orientation-k72 (proof), all four queued now. It is new scope,
not a reset of the two earlier correction runs below, and it authorizes no
correction run inside it: residue that would send work back to an earlier
stage is recorded for `model-reading`, the checkpoint that follows this node.

Done when, for this run: the model page meets §9.8 with every §10 anchor;
G11 is committed as source plus SVG; the landing page, domain page and
glossary route to the model page; the k64 residues named in orientation-k69
are repaired; proof walks landing → domain → model and two direct concept
entries; `task docs:check` passes.

## Current human-directed correction

The 2026-09-28 human response in first-path-reading-k48 (D2–D5) requires
examples as constructs are introduced, plus language-model and selected
railroad diagrams that give syntax a containing context. Apply the updated
plan §4–§6 and §9.1 across `README.md`, `explanation/unsaid.md` and `glossary.md`.
Rule-reading-k49 lands the canonical reading aids first; reuse them where
they help this document's reader.

This document already completed its first correction run. The new request
reaches Grove's second-re-run escalation boundary. The human explicitly said,
"These two points should be generally applied and then let's review again."
That instruction authorizes this one bounded draft → copy-edit → art → proof
run, orientation-k52 through orientation-k55. Its four stages are already
queued. No further automatic rerun is authorized; record unresolved residue
for first-path-reading-k64 and seek human direction when necessary.

The new checkpoint follows all three corrected documents and precedes reference
and review-guide drafting. The k48 response identifies language.md L2; it does
not establish that this document was read or that its first correction failed.
Keep the reported reading extent and proposed remedies distinct.

## First human reading correction

The first human read (`first-path-reading-k8`, D4–D6) found the prose too
compressed and requested positive framing. `orientation-k36` through
`orientation-k39` form the first correction run. The revised plan §4–§6 and
§9.1 govern it, including the title *Using an API across languages*. Explain
the publication workflow through people, tools and actions before naming its
abstractions. Apply that treatment across all three pages and shared figures.
The follow-up human checkpoint is `first-path-reading-k48`.

## Follow-up reading

Proof closed both art handoffs: the three pages supply their own context, and
the captions, tables and G1/G4 figures agree with the explanations. Two remaining
compressed summaries were expanded in proof: deployment/support limits and
callback lifetimes/teardown. The glossary retains its reference form.
The follow-up human checkpoint owns whether these explanations are now
understandable; editorial inspection alone does not establish that outcome.

The human-directed second correction is proofed in orientation-k55. The
overview routes to L1/L2; glossary fragments locate declaration identity,
imports, members, callables and slots in the shared geometry/canvas examples.
G9 is reused beside the glossary example, and its slot table distinguishes
position's result from Filter's result and qualified references from local
places. The domain page keeps its separate watch examples and domain-first
route. Whole-document proof found no actionable defect or outstanding handoff.
The node's document, glossary, figure and navigation obligations are satisfied;
first-path-reading-k64 still owns the human comprehension assessment.

The model-first run is proofed in orientation-k72. All four pages meet the
run's structure and routing contract; the eleven concept anchors and map rows
match §10. G11's two views, G1/G4 and the glossary's G9 agree with the prose.
The original examples and anchors remain intact, the k64 presentation residues
are repaired, and `task docs:check` passes. There is no outstanding handoff or
residue for another stage. model-reading-k73 owns the human assessment.
