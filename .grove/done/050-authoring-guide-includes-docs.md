# 050-authoring-guide-includes-docs

**Kind:** work

## Goal

Update the new-target authoring instructions so that producing the per-language
documentation, in the canonical structure, is an explicit and sequenced part of
the authoring process — not an afterthought. (PRD goal 5; user-requested.)

## Context

Per PRD `docs/prd/2026-06-14-docs-restructure-main-and-per-language.md` (goal 5
and the leaf-050 section). The guide lives at `docs/guides/adding-a-language-target.md`
after leaf 020. Today it describes the build but treats docs as implicit.

## Done when

`docs/guides/adding-a-language-target.md`:

- Has an explicit **"Document the target"** stage walking the author through
  every canonical slot: `docs/reference.md`, `docs/developer-guide.md`,
  `docs/design/` (specs raised during the build), `docs/research/` (spikes),
  per-app `apps/<app>/learnings.md`, and `README.md`.
- States the **read-vs-produce split** up front: which **main** docs the author
  reads (pipeline, app portfolio specs, emitter-contract, ADRs 0010/0011, the
  restructure PRD) vs. which **per-language** docs they produce.
- Makes "docs exist in the canonical structure" part of the target's
  **definition of done**.
- Cross-references the co-location ADR (from leaf 040).
- Optionally provides a copyable skeleton / checklist so the author fills slots
  rather than inventing layout.

## Notes

This is the onboarding payoff of the whole restructure — the per-language tier
becomes a template a new-target author fills, closing the loop with the existing
new-target guide.
