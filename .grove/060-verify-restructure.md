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
  retired paths (`knowledge/`, `analysis/docs/`, `generation/docs/`) in any
  **live** doc or code — see the allowlist note below; matches outside the
  allowlist are real misses to fix.
- No dangling relative markdown links (every `[..](path)` resolves).
- `docs/README.md` map matches the actual `docs/` tree; each per-target
  `README.md` points at slots that exist.
- `knowledge/` is gone; `analysis/docs/` and `generation/docs/` gone if emptied.
- All ADRs still central in `docs/adr/` with unchanged numbering.
- The two judgment-call files from leaf 030 (blockbridge, counter) are resolved.

## Allowlist — retired-path strings intentionally retained (from leaf 040)

Leaf 040 applied a **live-pointer vs. historical-record** policy (per the PRD
non-goal "no content rewriting"): navigational pointers a reader follows to find
current info were repointed; retired-path strings inside dated historical
artifacts and the glossary were deliberately left as a record of past state. The
verification grep should find retired paths **only** in these files — any match
elsewhere (a per-target `reference.md`/`developer-guide.md`/`README.md`, an ADR's
live back-pointer, root `README.md`, code comments, live `docs/pipeline/` prose)
is a real miss:

- `CONTEXT.md` — glossary, *defines* `knowledge/` as retired (correct as-is).
- `docs/adr/0024-per-language-docs-co-locate-adrs-stay-central.md` — the ADR
  *describes* the dissolution.
- `docs/prd/2026-06-14-docs-restructure-main-and-per-language.md` — the move-map
  record itself.
- `docs/specs/{2026-03-26-macos-workspace-design, 2026-04-16-sample-app-portfolio-design,
  2026-05-20-core-pipeline-hardening-design, 2026-05-22-grove-skill-design}.md`
  — dated cross-cutting design specs (historical narrative).
- `docs/superpowers/plans/{2026-05-20-core-pipeline-hardening,
  2026-05-22-racket-oo-completion}.md` — off-limits per PRD non-goal.
- `generation/targets/chez/docs/design/2026-05-27-chez-target-design.md`,
  `generation/targets/gerbil/docs/design/2026-06-03-gerbil-target-design.md`,
  `generation/targets/racket/docs/design/2026-05-22-racket-oo-completion-design.md`
  — per-target dated design specs.
- `generation/targets/gerbil/docs/research/2026-06-03-gerbil-ffi-dispatch-spike/FINDINGS.md`
  — research findings (historical).
- `generation/targets/chez/test-results/{bundle-version-coupling, mini-browser,
  pdfkit-viewer}/report.md` — point-in-time test reports.
- `.grove/**` — ephemeral grove tree (deleted at Finish).

If you disagree with leaving any of these and want literal zero matches, that's a
content-edit decision to raise with the user, not a silent rewrite of history.

## Notes

If verification surfaces a missed reference or a structural gap, fix it here (or
add a follow-up leaf if it's substantial). This leaf's completion makes the
grove ready to **Finish**.
