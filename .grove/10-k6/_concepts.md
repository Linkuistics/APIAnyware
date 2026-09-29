# concepts-k6 — brief

## Goal

Land the three concept explanations: `explanation/contracts.md`,
`explanation/packages.md` and `explanation/choices.md`. The reader can then
explain how AIL states each obligation, tell domain constraints from AIL's
choices, and see its alternatives, limits and open questions (plan outcomes 2,
in part, and 3).

## Contract

The structure brief is the documentation plan's §9.2, at `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`. It states
the reader and their outcome, the ordered sections and the purpose of each,
and the emphasis and non-goals. The same plan's §4 (prose contract), §5
(page-one block and example labels), §6 (figures) and §7 (checks) govern
every stage. The gate is `task docs:check`, plus any task this document adds.

## Full-set source/platform correction

Full-set-reading-k12 records the human's positive verdict, with one present
correction: both the API model and AIL serve source languages and platforms
beyond Swift/Apple. Plan §1 and §9.2 carry the resulting contract. The human
explicitly places a more conversational presentation and clause-specific
syntax exploration later; Q7 records the latter without changing the grammar.

This run's document is `README.md`, `explanation/model.md` and
`explanation/choices.md`, plus any directly affected summary/route text found
by inspecting the published set. Make intended source/consumer breadth clear,
distinguish described typed contracts from consumer languages, and recast the
dedicated-syntax comparison without privileging Swift. Preserve accurate
source-specific references, synthetic `swift_like` examples, the eleven model
concepts, canonical rule text, grammar and frozen packages. The ecosystem
list is an intended scope, not a provider-support or common-C-ABI claim.

The human's direction authorizes exactly one ordered run: concepts-k95 draft,
concepts-k96 copy-edit, concepts-k97 art and concepts-k98 proof. Its later
stages are already queued. This adds scope at the human checkpoint; it does
not reset the previous correction history or authorize another unattended
run. Every stage reads the whole bounded document and fixes only its charter.
Exit: the scope is clear in orientation/model/rationale and their affected
summaries, the existing rules/examples are preserved, and `task docs:check`
passes. Proof updates the audit's record of the supplied correction and then
closes the node if these conditions hold. Unresolved residue returns to the
human, with no automatic new reading checkpoint.

## Pipeline

`draft` → `copy-edit` → `art` → `proof`, cut lazily: each stage's last act
adds the next unless a live later sibling already holds it. Stage leaves carry
this document's bare stem as their slug. Defects a later stage owns go under
`## Handed forward` in this brief; the list is created by the first stage that
needs it. Figure slots that `draft` leaves for `art` go there too.

## Done when

- The three pages exist and meet §9.2. Every normative claim cites a rule, and
  every AIL block carries its label.
- The open-question register in `explanation/choices.md` holds audit Q1–Q6,
  plus any question drafting found. None is resolved by the text.
- Figures G2–G7 that these pages need are committed as source plus SVG, under
  the shared visual vocabulary.
- The landing page and glossary link the new pages and terms. Each page was
  linked from the landing map in the session that landed it (plan §3,
  *Staging*).

## Decomposition

Two draft sessions, in order. The first drafts `explanation/contracts.md`, the
largest page and the one the other two lean on, and links it from the
landing page's map with its return and next routes. The second drafts
`explanation/packages.md` and `explanation/choices.md`, links them the same
way, and completes the glossary for all three pages. Each session converts
the plain-text mentions of the pages it lands into links. Only the second
draft's last act cuts `copy-edit`. The first finds its later sibling live and
cuts nothing.

## Model-first run

The human's 2026-09-29 direction (first-path-reading-k64, D12–D13): explain
the model, then describe AIL by reference to it, because the language is a
tool. After orientation lands the canonical model page and `model-reading`
assesses it, this node's three pages become the account of how AIL writes each
model concept down (plan §9.2, *Model-first run*; concepts in plan §10).

This run also owns the canonical pages' model-concept routes (plan §9.7 item
7). They cannot sit under rule-reading-k49, which the walk visits before the
model page exists, and they point at the concepts this run's pages introduce.
Model-reading-k73 adds an example-led refinement: explain the examples'
AIL-specific meaning, omit obvious punctuation commentary, and keep railroads
with the grammar description in `reference/notation.md`. Link there from
other pages. For this run the document is the three explanation pages, the
new grammar page, the non-normative canonical aids and the affected glossary
and landing-page prose/routes. Each stage reads these changes; the existing
canonical preservation check protects every rule paragraph.

This human direction authorizes exactly one ordered run: four draft
sessions (concepts-k85 grammar home and canonical figure links, first;
concepts-k74 contracts; concepts-k75 packages and choices;
concepts-k76 canonical prose/model routes and glossary), then concepts-k77 copy-edit, concepts-k78 art
and concepts-k79 proof, all queued now. It is new scope, not a reset of the
earlier correction runs below, and it authorizes no correction run inside it:
residue that would send work back is recorded for the full-set checkpoint.

Done when, for this run: the contracts page follows §10's order with a concept
opening on every notation-introducing section; packages opens with the
description-layer concepts before the shell; choices judges each choice by how
it serves the model; every canonical rule section routes to its concept with
the rule text byte-identical; every construct introduction is enumerated with
its concept; all eleven G10 views are with the grammar and linked from their
former locations; examples and semantic diagrams remain; non-normative prose
omits familiar punctuation lessons; `task docs:check` passes. Reference-k16
extends the grammar page later without replacing it or its anchors.

Grammar routes from concepts-k85 are now at `reference/notation.md`, with
explicit anchors `shell`, `clause`, `names`, `callable`, `places`, `environment`,
`pattern`, `outcome`, `callback-use`, `dependency` and `access`. The k85 task
records the old-to-new route table. Canonical aids link there and retain all
examples and incoming anchors. Following explanation and tutorial drafts can
replace their own G10 embeds with these same section links; k76 still owns
the canonical aids' meaning-focused prose revision. Reference-k16 extends the
page with conventions and index routes while preserving these anchors.

## Second human reading correction (completed)

The 2026-09-28 human response in first-path-reading-k48 (D2–D5) requires
examples as constructs are introduced, plus language-model and selected
railroad diagrams that give syntax a containing context. Apply the updated
plan §4–§6 and §9.2 across `explanation/contracts.md`, `explanation/packages.md` and `explanation/choices.md`.
Rule-reading-k49 lands the canonical reading aids first; reuse them where
they help this document's reader.

This document already completed its first correction run. The new request
reaches Grove's second-re-run escalation boundary. The human explicitly said,
"These two points should be generally applied and then let's review again."
That instruction authorizes this one bounded draft → copy-edit → art → proof
run, concepts-k56 through concepts-k59. Its four stages are already
queued. No further automatic rerun is authorized; record unresolved residue
for first-path-reading-k64 and seek human direction when necessary.

The new checkpoint follows all three corrected documents and precedes reference
and review-guide drafting. The k48 response identifies language.md L2; it does
not establish that this document was read or that its first correction failed.
Keep the reported reading extent and proposed remedies distinct.

## First human reading correction

The first human read (`first-path-reading-k8`, D4–D6) found compressed
abstractions and negative framing throughout the path. `concepts-k40` through
`concepts-k43` form the first correction run, after orientation's correction.
The revised plan §4–§6 and §9.2 govern the whole three-page set. Develop each
relationship through concrete actors, actions and examples before technical
shorthand. State each subject positively, preserving the exact contract,
alternatives, limits and Q1–Q6. The follow-up human checkpoint is
`first-path-reading-k48`.
