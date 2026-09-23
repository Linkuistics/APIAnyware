# orientation-k13

## Goal

Draft `README.md` (a rewrite as the landing page), `explanation/unsaid.md` and `glossary.md` from their sources, owning their structure and technical truth.

## Context

- Structure brief: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §9.1. It states the reader and outcome, the ordered
  sections with their purposes, and the emphasis and non-goals. Quote it
  rather than re-deriving it.
- Prose contract, labels, figures and checks: `semantic/docs/design/2026-09-23-interface-language-documentation-plan.md` §4–§7.
- Evidence: the audit (`semantic/docs/research/interface-language-documentation-audit.md`) and the survey's §9 criteria D1–D8.

## Done when

- The three pages follow §9.1's section order, or the draft records why a
  section moved.
- Every obligation named on `explanation/unsaid.md` maps to a rule identifier,
  even where the page shows no AIL. Every domain term in the root brief has a
  defining location.
- The existing README's status and scope statements survive with their
  meaning intact.
- Pages that do not exist yet (the concept pages, tutorial, reference and
  review guide) are named as plain text, not linked, under the staging rule in the plan's §3.
  Each page's next route points to an existing page.
- Figure slots G1 and G4 are recorded under `## Handed forward` in the node
  brief for `art`.
- `task docs:check` passes.

## Notes

The synthetic C header on `explanation/unsaid.md` must be labelled synthetic. It makes no claim about a real library. Keep the landing page short enough to reach the domain page within one screen.

This is the node's last draft session, so its last act is `leaf-add` of the `copy-edit` leaf, unless a live later sibling already holds one.
