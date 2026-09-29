# review-guide-k10 — brief

## Goal

Land the review guide: `review/README.md`, `review/walkthroughs.md` and
`review/tasks.md`. The reader can then evaluate AIL along the six dimensions
and give feedback tied to examples and rules (plan outcome 4).

## Contract

The structure brief is the documentation plan's §9.5, at `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`. It states
the reader and their outcome, the ordered sections and the purpose of each,
and the emphasis and non-goals. The same plan's §4 (prose contract), §5
(page-one block and example labels), §6 (figures) and §7 (checks) govern
every stage. The gate is `task docs:check`, plus any task this document adds.

The 2026-09-28 requirements in first-path-reading-k48 apply to task prompts
and walkthroughs: show the introduced syntax in a small explained snippet with
its enclosing declaration/package, and use the existing model/railroad views
where they help. Include concrete tasks following imported versus local
declarations and a member's owner and callable slots. Preserve open design
questions and expected observations by inspection. The next checkpoint,
first-path-reading-k64, precedes this node; read its actual assessment and
incorporate its decisions before drafting.

Assume familiarity with railroad diagrams (first-path-reading-k64). Use syntax
views to support the AIL task and explain its names, relationships and contract;
omit generic instruction on how to follow railroad tracks and branches and
the associated legend boxes.

The human's 2026-09-29 priority is the model and how AIL serves it. Plan
§9.5, revised by model-first-documentation-k68, states the review question as
how well AIL serves as a tool for describing the model in
`explanation/model.md`, restates each of the six dimensions against the plan
§10 concepts, starts every task from a model question about a named example,
groups walkthrough clauses by concept, and adds a *Model fit* task. Use §10's
concept names exactly as the model page does, including any change
`model-reading` made. Preserve the visually bordered non-normative aids and
their stable anchors.

## Pipeline

`draft` → `copy-edit` → `art` → `proof`, cut lazily: each stage's last act
adds the next unless a live later sibling already holds it. Stage leaves carry
this document's bare stem as their slug. Defects a later stage owns go under
`## Handed forward` in this brief; the list is created by the first stage that
needs it. Figure slots that `draft` leaves for `art` go there too.

## Done when

- The three pages exist and meet §9.5. Every task has expected observations
  that were checked against the rules, and every prompt cites something
  concrete and invites criticism.
- The walkthroughs cover all three conformance examples clause by clause.
- The landing page links the guide as the destination of the guided route.
  Each page was reachable from the landing map in the session that landed it
  (plan §3, *Staging*).

## Decomposition

Two draft sessions, in order. The first drafts `review/walkthroughs.md`,
which the tasks build on, and links it directly from the landing map,
because the guide's index does not exist yet. The second drafts
`review/README.md` and `review/tasks.md`, makes the index the map's entry to
the guide, and links the walkthroughs from it. Only the second cuts
`copy-edit`.
