# review-guide-k24

## Goal

Draft `review/README.md` (the six dimensions and the feedback template) and `review/tasks.md` (trace, predict, change, compare, stretch and author tasks).

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §9.5. It states the reader and outcome, the ordered
  sections with their purposes, and the emphasis and non-goals. Quote it
  rather than re-deriving it.
- Prose contract, labels, figures and checks: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §4–§7.
- Evidence: the audit (`semantic/docs/research/interface-language-documentation-audit.md`) and the survey's §9 criteria D1–D8.

## Done when

- Both pages follow §9.5, including its model-first framing: each dimension
  is stated against the plan §10 concepts, every task starts from a model
  question about a named example, and `review/tasks.md` includes the *Model
  fit* task. Every task has a goal, conditions, steps, expected observations
  and a feedback prompt. Every prompt cites a rule, example or page and
  invites criticism, including of how well AIL serves the model.
- The landing page links the review guide as the end of the guided route,
  with `review/README.md` as its entry. The index links the walkthroughs and
  the tasks, and the map's interim direct link to the walkthroughs is
  replaced (plan §3, *Staging*).
- `task docs:check` passes.

## Notes

Prompts must permit the answer "this design is wrong". A prompt that presumes the design is right is a defect.

This is the node's last draft session, so its last act is `leaf-add` of the `copy-edit` leaf, unless a live later sibling already holds one.

## Decisions (running log)

D1 — The structure precondition is met by the named plan §9.5: the reader
"can evaluate AIL along the six dimensions" and give feedback citing rules;
the ordered index runs from the page-one block through purpose, dimensions,
feedback, open questions and limits, followed by seven self-contained task
types. Its emphasis is "The reviewer's real tasks, criticism-inviting prompts
and expected observations that can be checked by inspection"; non-goals
include leading questions, invented tool output and satisfaction ratings.
Keep the model concept names and example-led presentation established by
model-reading-k73. This is the remaining planned draft, not a correction run.

D2 — Use the existing canvas fragment to trace local/imported declarations,
member ownership and callable slots. Use the conformance packages for N07
prediction, a borrowed pointer parameter addition, callback cancellation
pressure and cross-example validity mapping. The authoring exercise uses
`watch_close` from the domain header with explicit synthetic assumptions;
its draft is a fragment, since this task supplies no complete watch package
or native implementation. A borrowed-to-owned pointer exercise would require
an allocator/release profile that F1 does not supply (C5/F1).

D3 — Spent the one in-session reviewer allowance on task truth and
completeness against the canonical rules and §9.5. Its one finding is valid
and actionable: Model fit's inventory omitted the `lifetime` pattern and
`store_lifetime` instance despite asking for cross-declaration relationships.
Added their typed roles, release law and bindings, explicitly as a check on
the already declared destructor (L6), not another ownership authority. This
is an enumerated-source omission with a direct L6 correction, not a new
semantic design requiring another review. The reviewer found no other
actionable factual, precondition, source-fidelity or task-structure defects.

## Verification

- Checked the named structure brief's six index sections, six model-based
  dimensions and seven task types. Each task has its named example/model
  question, goal, conditions, imperative steps, expected observations and
  concrete criticism-inviting prompt. Read the existing walkthroughs and
  retain their readings, adding routes to the new index and tasks.
- Checked expected observations against L1–L6, C1–C8, A1–A5/F1, the grammar,
  the three conformance packages, the canvas fragment and the earlier design
  sketch. The constructed tagged-copy and lifetime-only watch cases state
  their assumptions and omissions. Enumerating the `watch_close` clause
  statements gives 17, matching its grouped count. No native execution or
  semantic-validator result is claimed.
- After the review correction, `task docs:check` passed: links and examples
  checked 31 files, 29 pages were reachable, all 26 SVGs reproduced, and
  coverage reported 229 candidates, no pending entries and no errors.
  External URLs were not fetched. Before/after subject lists and SHA-256
  hashes matched item by item across 122 files: the interface-language tree,
  documentation checker files excluding caches, root Taskfile, plan and audit.
  Manifest SHA-256:
  `d6fd91401e5911f71d3e3df9e3f9daa0945026b7aa773c2a122f2c86c51c63c5`.
- Rechecked links with the externally located earlier design sketch also
  included in the frozen source manifest: all 123 before/after hashes
  matched. No canonical rule, grammar or original conformance package changed.
- Graph project `Users-antony-Development-APIAnyware.improve-api-interface-language-docs`
  is ready at generation `2026-09-23T09:55:55Z`, Tier 2. Coverage reports the
  design/research and example subtrees excluded, with current Markdown
  metadata changed or untracked. Claims use direct source reads, not graph
  completeness. The checks establish document consistency, not human
  comprehension or production-provider support.
- The node has no live copy-edit sibling. Queue that mandatory successor
  with the whole three-page set and the brief's terminology handoff; its
  existence keeps the node live, so this retirement closes no ancestor.
