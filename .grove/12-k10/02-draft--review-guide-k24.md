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

- Both pages follow §9.5. Every task has a goal, conditions, steps, expected
  observations and a feedback prompt. Every prompt cites a rule, example or
  page and invites criticism.
- The landing page links the review guide as the end of the guided route,
  with `review/README.md` as its entry. The index links the walkthroughs and
  the tasks, and the map's interim direct link to the walkthroughs is
  replaced (plan §3, *Staging*).
- `task docs:check` passes.

## Notes

Prompts must permit the answer "this design is wrong". A prompt that presumes the design is right is a defect.

This is the node's last draft session, so its last act is `leaf-add` of the `copy-edit` leaf, unless a live later sibling already holds one.
