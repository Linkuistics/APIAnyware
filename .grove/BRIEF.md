# restructure-docs-to-main-and-per-language — brief

## Goal

Restructure the repo's documentation into two clear tiers: a **main**
(cross-cutting / shared) tier consolidated under a single top-level `docs/`
tree, and a **per-language** (per-target) tier co-located inside each target's
on-disk unit `generation/targets/<lang>/`. The new-target authoring process is
updated so producing the per-language docs, in this structure, is an explicit
step of adding a target.

## Done when

- `docs/` is the single main tier (`adr/ pipeline/ specs/ research/ apps/
  testing/ guides/ prd/ README.md`); `knowledge/` dissolved.
- Each target follows the canonical per-target doc layout
  (`docs/{reference,developer-guide,design/,research/}`, per-app `learnings.md`).
- ADRs remain central in `docs/adr/` with unchanged numbering (the one exception
  to co-location).
- No dangling links / stale paths; co-location ADR written; the new-target guide
  bakes in doc production.

## Decomposition

- `010-plan` — planning (this grove's grilling; produced the PRD). *(retired)*
- `020-build-main-docs-tree` — consolidate main; dissolve `knowledge/`.
- `030-colocate-per-language-docs` — move per-target docs into target units.
- `040-cross-refs-glossary-adr` — repair references; verify glossary; write ADR.
- `050-authoring-guide-includes-docs` — bake docs into new-target authoring.
- `060-verify-restructure` — grep for dangling links/paths; confirm no orphans.

## Pointers

- PRD: `docs/prd/2026-06-14-docs-restructure-main-and-per-language.md` (full move-map).
- Glossary: `CONTEXT.md` — "Main docs / main tier", "Per-language docs".
- ADRs: `0010` (native library is the binding), `0011` (targets hermetically
  isolated) — the co-location decision extends these to docs.

## Notes

Decision rationale lives in `010-plan.md`'s running log (Q1–Q10) and the PRD.
