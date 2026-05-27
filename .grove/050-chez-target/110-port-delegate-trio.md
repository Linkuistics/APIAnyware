# 110-port-delegate-trio

**Kind:** work

## Goal
Port the three delegate-only sample apps to chez in a single session:
`ui-controls-gallery`, `scenekit-viewer`, `pdfkit-viewer`. They
exercise the same runtime piece (sync delegate) at increasing reach.

## Context
- Design spec §7 (feature ladder, rungs 2-4).
- Each app's racket source:
  - `generation/targets/racket/apps/ui-controls-gallery/`
  - `generation/targets/racket/apps/scenekit-viewer/`
  - `generation/targets/racket/apps/pdfkit-viewer/`
- `runtime/dispatch.sls`'s `make-delegate` (leaf 040).
- [[feedback-use-testanyware]], [[feedback-sample-apps-perfect]].

## Done when
- All three `.sls` sources exist and idiomatic-chez (no leftover
  `tell` macros, no `_cprocedure`, `(values result error)` for fallible
  calls).
- All three bundle, launch, behave identically to their racket
  counterparts, pass TestAnyware.
- Activity Monitor: no growth.

## Notes
- If a runtime bug surfaces during one app, fix and re-verify all three
  before retiring.
- If the leaf takes more than one session, split it (`110-port-ui-controls-gallery.md`,
  `120-port-scenekit-viewer.md`, …) and renumber the downstream leaves.
  This is grove-legal — see constraint 5 ("grove guides, it does not
  gate").
