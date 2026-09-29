# review-guide-k89

## Decisions (running log)

- Keep the three pages' structure, task inventories and examples intact. Add
  first-use glossary routes and revise sentences that compress actors or
  conditions; qualify callback captures separately from dependency closure.
- Use direct document reads as evidence. Graph generation
  `2026-09-23T09:55:55Z` is ready, but coverage reports the plan/research
  subtree excluded and the review pages untracked; no code-structure claim
  relies on that index.
- The full-document copy-edit closes both glossary/prose handoffs. No
  structural correction or unresolved technical finding was found. Art
  remains mandatory and is queued as `review-guide-k90`; the node stays live.

## Verification

- `task docs:check` passed: 31 files checked for links and examples, 29 pages
  reachable, all 26 SVGs reproduced, 229 coverage candidates with no pending
  entries or errors. External links were listed, not fetched.
- Compared all three review pages against parent `d6b7407b`: headings, code
  fences, example markers and explicit anchors are unchanged. Read the prose
  diff against C1–C10, retaining all seven task structures and their expected
  observations, including the 17-clause count and L6 release relationship.
- `language.md`, `contracts.md`, `profiles.md`, `grammar.ebnf`,
  `conformance.md`, the three complete conformance packages and
  `examples/review/tasks.ail` are byte-identical to the parent.
- SHA-256 digests before and after the final gate match for 123 files:
  the interface-language documentation tree, documentation checker files,
  root Taskfile, documentation plan and audit. The check establishes document
  consistency and preservation, not human comprehension or runtime safety.


## Goal

Copy-edit the complete review guide for clear sentences, consistent terms
and the declared prose contract, preserving its model-based review tasks.



## Context

- Read all three pages under
  `semantic/specification/interface-language/review/`: `README.md`,
  `walkthroughs.md` and `tasks.md`. Drafts review-guide-k17 and
  review-guide-k24 now complete the planned set.
- Structure brief: documentation plan §9.5 at
  `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md`;
  prose/page-one/figure/check contracts: §4–§7; model names: §10.
- The document-node brief's `## Handed forward` lists first-use glossary
  routing across all three pages. Apply the survey's C1–C10 criteria.
- The new fragment regions are `examples/review/tasks.ail`. Other snippets
  reuse existing regions or frozen conformance examples. The authoring task
  is a lifetime-only watch case, with no stored callbacks, not a complete
  mapping of the domain header. Compare deliberately shows historical
  non-0.1 syntax as `text` and distinguishes the APIs' different behaviour.

## Done when

- All three pages meet the prose contract: explain domain relationships,
  keep conditions before actions, use model concept names consistently,
  link glossary terms at first use, and avoid punctuation lessons.
- Preserve each task's goal, conditions, steps, expected observations and
  open criticism prompt; keep the six dimensions and feedback template.
  Preserve the borrowed/consumed input distinction, 17-clause authoring
  count, callback cancellation boundary and Model fit's L6 relationship.
- Example labels retain enclosing context, synthetic status and omitted
  facts. Grammar links remain at the reference; existing language-model
  and scheduling views are linked where useful.
- `task docs:check` passes, with canonical rules, grammar and conformance
  packages unchanged. Clear handed-forward entries that this stage closes.
- Add the mandatory art successor under the editorial-family rule unless
  a live later sibling already holds it.

## Notes

The bounded draft reviewer found one omission in Model fit's expected
inventory: the typed pattern roles, release law and instance bindings. The
draft added that checked relationship to the existing destructor; it creates
no new release authority. No unresolved technical finding was handed forward.
The linked figures are existing G9/contract views; no new figure slot is
reserved. Copy-edit owns prose and terminology across the full set.
