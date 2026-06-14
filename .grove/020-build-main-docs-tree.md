# 020-build-main-docs-tree

**Kind:** work

## Goal

Consolidate the cross-cutting (main) documentation into a single top-level
`docs/` tree and dissolve `knowledge/`.

## Context

Per PRD `docs/prd/2026-06-14-docs-restructure-main-and-per-language.md` (read it
first — it has the full move-map). This leaf does the **main-tier** moves only;
per-language co-location is leaf 030.

Target main tree:

```
docs/  README.md  adr/  pipeline/  specs/  research/  apps/  testing/  guides/  prd/
```

## Done when

- `docs/pipeline/` holds `knowledge/pipeline/*`, `analysis/docs/*`, and
  `generation/docs/emitter-contract.md`.
- `docs/apps/` = former `knowledge/apps/`; `docs/testing/` = former
  `knowledge/testanyware/`.
- `docs/guides/` holds `adding-a-language-target.md` + `codesigning-identity.md`.
- `docs/README.md` exists as the main map (fold in `knowledge/README.md`'s axis
  guide, rewritten for the new layout), and `knowledge/` is gone.
- `analysis/docs/` and `generation/docs/` removed if left empty.
- All moves via `git mv` (preserve history). Leave per-target ADRs/specs/research
  in place — they move in 030. Do **not** fix external cross-references yet
  (that is leaf 040) beyond what's needed for `docs/README.md` to be accurate.

## Notes

`README.md` + `CONTEXT.md` stay at repo root. `analysis/scripts/*.md` and
`docs/superpowers/` are untouched.
