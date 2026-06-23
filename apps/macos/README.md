# apps/macos/ — common macOS app specs

Target-independent AppSpec definitions for macOS applications (REFACTOR.md §15):
one directory per app (e.g. `gui-counter`, `menu-daemon-clipboard`) holding the
AppSpec plus `docs/`. Each spec is a behavioural exemplar (§7.8) that every
target's implementation is checked against — kept free of projection so the same
spec drives racket, chez, gerbil, sbcl, and future targets alike (§45.11).

TODO: app specs land in workstream 7 (apps). Today's per-target sample apps are
split into a common spec (here) and per-target implementations
(`targets/<t>/app-implementations/`) during `move-target-material-k8` +
workstream 7. No content this leaf.
