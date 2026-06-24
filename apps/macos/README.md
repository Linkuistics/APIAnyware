# apps/macos/ — common macOS app specs

Target-independent AppSpec definitions for macOS applications (REFACTOR.md §15):
one directory per app (e.g. `gui-counter`, `menu-daemon-clipboard`) holding the
AppSpec plus `docs/`. Each spec is a behavioural exemplar (§7.8) that every
target's implementation is checked against — kept free of projection so the same
spec drives racket, chez, gerbil, sbcl, and future targets alike (§45.11).

The existing portfolio docs were co-located here in `co-locate-docs-k9`: the index
+ portfolio design at `apps/macos/docs/`, and per-app `spec.md` / `learnings.md` /
`test-strategy.md` at `apps/macos/<app>/docs/` (§10).

TODO (workstream 7 — apps): finalize the structure — promote each `spec.md` to a
first-class AppSpec, split spec vs. implementation-notes, and reconcile the
co-located per-app docs with the per-target implementations under
`targets/<t>/app-implementations/`.
