# concepts-k14

## Goal

Draft `explanation/contracts.md`, the explanation of AIL's semantic core, owning its structure and technical truth.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §9.2 (the `explanation/contracts.md` part). It states the reader and outcome, the ordered
  sections with their purposes, and the emphasis and non-goals. Quote it
  rather than re-deriving it.
- Prose contract, labels, figures and checks: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §4–§7.
- Evidence: the audit (`semantic/docs/research/interface-language-documentation-audit.md`) and the survey's §9 criteria D1–D8.

## Done when

- The page follows §9.2's section order. Each section follows the pattern of
  domain obligation, two cases, principle, AIL's choice and alternative, and
  rule links.
- Every normative claim cites a rule, and every AIL block is labelled and kept
  in step by `docs:examples` or marked as a fragment.
- Any ambiguity met is added to a `## Questions found` note in the node brief,
  for the next session to place in the register.
- Under the staging rule in the plan's §3: the landing page's map links
  `explanation/contracts.md`; the page has a return route and a next route to
  existing pages; and plain-text mentions of it on landed pages are now links.
  The glossary gains entries for terms this page defines that it does not yet
  hold.
- `task docs:check` passes.

## Notes

Examples come from the three conformance packages wherever possible, so that later walkthroughs build on them. Where you need a second, contrasting case, keep it a labelled fragment.

A later draft sibling finishes this document, so do not cut `copy-edit` here: the last draft session does.
