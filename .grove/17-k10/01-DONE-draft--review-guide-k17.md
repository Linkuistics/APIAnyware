# review-guide-k17

## Goal

Draft `review/walkthroughs.md`, a clause-by-clause reading of `buffers.ail`, `callbacks.ail` and `objects.ail` with trace questions.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §9.5 (the `review/walkthroughs.md` part). It states the reader and outcome, the ordered
  sections with their purposes, and the emphasis and non-goals. Quote it
  rather than re-deriving it.
- Prose contract, labels, figures and checks: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §4–§7.
- Evidence: the audit (`semantic/docs/research/interface-language-documentation-audit.md`) and the survey's §9 criteria D1–D8.

## Done when

- Every declaration in the three examples is read clause by clause, with its
  clauses grouped by plan §10 model concept and each group naming and linking
  its concept; code is quoted by line range through `docs:examples`.
- Trace questions have expected observations after them, checked against the
  rules.
- Under the staging rule in the plan's §3: the landing page's map links
  `review/walkthroughs.md` directly, since `review/README.md` does not exist
  yet; the page has a return route and a next route to existing pages.
- `task docs:check` passes.

## Notes

The examples are frozen conformance inputs. Never edit them to make a walkthrough easier.

A later draft sibling finishes this document, so do not cut `copy-edit` here: the last draft session does.

## Decisions (running log)

D1 — Structure brief confirmed in the named plan §9.5. Reader/outcome:
“The primary reader, who has taken the guided route or arrives with orientation
only. They can evaluate AIL along the six dimensions in §1 and give feedback
that cites examples and rules.” Ordered work: “One section each for
`buffers.ail`, `callbacks.ail` and `objects.ail`”, each with “the purpose”,
“a clause-by-clause reading of each declaration, grouped by obligation”,
“the plain-language view”, and “trace questions, with expected observations
after them.” Emphasis: “The reviewer's real tasks, criticism-inviting prompts
and expected observations that can be checked by inspection.” Non-goals:
“No leading questions that presume the design is right, and no invented tool
output. No satisfaction ratings.” The model-first addition requires concept
names and links at every clause group. These quotations satisfy all three
draft preconditions.

D2 — Own only walkthroughs and the landing map's interim direct route. Keep
all three fixtures frozen; quote exact line ranges through the existing
`docs:examples` convention. Explain declarations in concept groups, with
publication and provider facts explicit, followed by plain-language views and
rule-grounded trace answers. The live k24 sibling owns the review index,
task collection and copy-edit handoff. Human feedback in k64 and k73 keeps
the model first, familiar punctuation unexplained and railroad views at the
grammar reference. No new diagram is needed to draft these readings; the
art stage will assess existing semantic views alongside the whole guide.

D3 — Tier 2 evidence uses direct source for this documentation task. Graph
project `Users-antony-Development-APIAnyware.improve-api-interface-language-docs`
is ready, coverage generation `2026-09-23T09:55:55Z`; the exact-path coverage
check reports changed/untracked Markdown and excluded documentation/example
subtrees. Read the named brief, rules, grammar and fixtures directly; no code
structure or negative claim depends on graph completeness. The existing
Taskfile provides the final gate; no runtime or parser tests are implied.

D4 — Drafted all 17 declarations: buffers (`Store`, `create`, `destroy`,
`view`, `copy_bytes`, `lifetime`, `store_lifetime`); callbacks (`Subscription`,
`Handler`, `subscribe`, `unsubscribe`); objects (`Counter`, `read_count`,
`write_count`, `count`, `fixed_bytes`, `pointer_value`). Each package has its
purpose, located source extracts, linked concept groups, plain-language view
and trace questions with expected observations and rule citations. Exact-range
enumeration covers every source line once except each final package-closing
brace. Removing the opening range in a scratch control makes that comparison
fail. `docs:examples` confirms the quoted bytes. The page has the requested
direct landing-map entry, return route and existing next destinations.

D5 — Spent the one in-session reviewer allowance on the claim that these
readings preserve caller obligations, particularly null ownership, borrow
ending, retained callback lifetime/quiescence, serial versus nested entry,
and load versus address. The fresh context received the artifact and its
contract, frozen sources, canonical rules and coverage limitations with an
adversarial prompt. It returned no actionable findings and no substantive
clause/declaration coverage gaps. No review findings require classification
or follow-up; this is a bounded semantic review, not a human comprehension
assessment. The page's comparisons preserve these differences and keep
criticism of their notation open; no language ambiguity needed a new question.

D6 — Final `task docs:check` passed: links and examples checked 29 files,
27 site pages reachable, all 26 SVGs regenerated identically, reference
coverage 229 candidates with no pending entries or errors. The 119 subjects
(the interface-language tree, checker files excluding Python caches,
Taskfile, plan and audit) match before/after item by item. Manifest SHA-256:
`e0149b67cf70112b2b72b0b537df6fccfb3154e9769e1c731869fca3d0170f8f`.
The three canonical rule files, grammar and all three frozen fixtures are
byte-identical to parent `5b9657af`. A scratch preservation comparator first
compared Ruby UTF-8 and binary strings and falsely reported a mismatch;
equal byte lengths/digests isolated that encoding mismatch. Re-running with
binary comparison passed each file and detected a deliberately appended-byte
control. No subject or repository checker changed during that diagnosis.

D7 — The node remains live through review-guide-k24, which owns the remaining
two pages and successor cut. No node-close cascade or ADR change is needed.
Copy-edit owns the first-use glossary-link cleanup recorded in the node brief.
The subsequent art/proof stages remain responsible for the whole guide.
