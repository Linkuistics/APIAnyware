# 060-verify-restructure

**Kind:** work

## Goal

Verify the restructure is complete and self-consistent: no dangling links, no
stale paths, no orphaned files.

## Context

Per PRD `docs/prd/2026-06-14-docs-restructure-main-and-per-language.md`. Final
leaf — runs after 020–050. Docs-only change, so **no VM verification needed**.

## Done when

- Grep across all `.md` (and source/README/CLAUDE) finds **no** references to
  retired paths: `knowledge/`, `analysis/docs/`, `generation/docs/`.
- No dangling relative markdown links (every `[..](path)` resolves).
- `docs/README.md` map matches the actual `docs/` tree; each per-target
  `README.md` points at slots that exist.
- `knowledge/` is gone; `analysis/docs/` and `generation/docs/` gone if emptied.
- All ADRs still central in `docs/adr/` with unchanged numbering.
- The two judgment-call files from leaf 030 (blockbridge, counter) are resolved.

## Notes

If verification surfaces a missed reference or a structural gap, fix it here (or
add a follow-up leaf if it's substantial). This leaf's completion makes the
grove ready to **Finish**.
