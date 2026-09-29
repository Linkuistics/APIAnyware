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
