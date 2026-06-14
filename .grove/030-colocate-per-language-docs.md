# 030-colocate-per-language-docs

**Kind:** work

## Goal

Co-locate all per-target documentation into each target's on-disk unit
`generation/targets/<lang>/`, following the canonical per-target layout.

## Context

Per PRD `docs/prd/2026-06-14-docs-restructure-main-and-per-language.md` (full
move-map there). For each `<lang>` in {racket, chez, gerbil}:

```
generation/targets/<lang>/
  README.md
  docs/{reference.md, developer-guide.md, design/, research/}
  apps/<app>/{README.md, learnings.md}
  test-results/<app>/report.md   (already present)
```

## Done when

- `knowledge/targets/<lang>.md` → `generation/targets/<lang>/docs/reference.md`.
- `knowledge/matrix/<app>/<lang>.md` → `generation/targets/<lang>/apps/<app>/learnings.md`
  (create `apps/<app>/` dirs as needed).
- Per-target design specs → `<lang>/docs/design/`; per-target research/spikes →
  `<lang>/docs/research/` (see PRD for the per-target spec/research assignments).
- Each target has a `README.md` (racket already does; create for chez/gerbil if
  missing — overview/index pointing at the docs/ slots).
- `knowledge/targets/` and `knowledge/matrix/` are gone.
- All moves via `git mv`. ADRs stay central (do not move).

## Notes

Two judgment calls — resolve by reading, surface to user, do not silently delete:
- `docs/specs/2026-05-21-blockbridge-test-flake.md` — BlockBridge is racket's
  native trampoline; likely racket → `racket/docs/design/`. If genuinely
  cross-cutting, leave in `docs/specs/`.
- `knowledge/matrix/counter/racket.md` — `counter` app is retired; no
  `apps/counter/` destination. Ask the user: drop, or keep as a historical note.
