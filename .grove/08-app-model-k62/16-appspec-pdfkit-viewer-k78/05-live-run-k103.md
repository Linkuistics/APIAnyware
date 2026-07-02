# live-run-k103

**Kind:** work

## Goal

Tier-2 live-run the pdfkit-viewer forward-gen suite (k102) against all four impls in a
macOS VM, via the AppSpec run workflow (`~/Development/AppSpec/capabilities/run/workflow.md`)
— the gallery k94 stage. Adjudicate every `recording:` scenario (a pass confirms the
`(to confirm in-VM)` expectation; a failure is a spec-quality finding), write
`apps/macos/pdfkit-viewer/docs/run-results.md`, and close the parent node's Done-when.

## Context

- **Suite:** `apps/macos/pdfkit-viewer/scenarios/` (9 scenarios: 3 hard — 01/03/08;
  6 `recording:` — 02/04/05/06/07/09) + `run-values.rkt` + `fixtures/fixture.pdf`
  (3 pages, `PAGE n` upper-third markers; regenerate via `fixtures/make-fixture.swift`).
- **Before first run — geometry.** The `run-values.rkt` coordinates are PROVISIONAL
  (spec-§4/§5 estimates on 1920×1080). Re-measure every coordinate from `agent snapshot
  --mode layout` (AX centre → framebuffer px) with a **two-launch determinism diff**
  before binding values (k77/k94 practice); add per-impl `run-values-<impl>.rkt`
  siblings only where impl layouts genuinely diverge (gallery: chez+gerbil shared,
  racket/sbcl diverged).
- **Before first run — fixture.** Upload `fixtures/fixture.pdf` to
  `/tmp/pdfkit-viewer/fixture.pdf` in the VM (the `fixture-path` run-value; same parent
  dir the impls create for events.log). The `opened` matcher exact-matches only the
  basename `fixture.pdf` (panel canonicalizes /tmp → /private/tmp).
- **Impls:** `build/PDFKitViewer-<impl>.app` per k98–k101, installed at
  `/Applications/PDFKitViewer-<impl>.app`; descriptors at
  `targets/<t>/app-implementations/macos/pdfkit-viewer/pdfkit-viewer-impl.rkt`.
  racket needs the k74/k34 runtime provisioning (host Racket v9.2 upload + ffi2-lib
  user-scope + `raco make` precompile) unless k76's self-contained bundle landed for
  this app; sbcl's libzstd is vendored since k75.
- **Runner:** full-suite-reliable since AppSpec `46fec5b` + `f2b8b76` (k77 outcomes);
  the post-failure delayed-truncate residual stands — adjudicate a red that follows a
  failure by solo re-run (run workflow §3).
- **Known judgment points to adjudicate** (from the k102 consensus reconciliation):
  scenario 07 uses `'right` (the §13-literal arrow key) — if continuous-mode arrows
  scroll sub-page instead of paging, probe `'pagedown`/`'end` as run-tuning and feed
  the finding back to the spec; scenario 02's five provisional AX rows (Open… U+2026
  AXTitle, ◀/▶ glyph titles, label value→AXTitle fold, AXScrollArea) firm or correct
  the k96 role table; the panel-drive settles (`wait 1`) in 05/06/07 are run-tunable.
  Consensus extras deliberately not in the suite, probe-able live: ◀-inert at page 1;
  `expect-no-ax` window-hidden after close.

## Done when

All four impls run the suite green in the live VM ([[vm_verify_every_app]] — CLI smoke
never satisfies the bar); `recording:` outcomes adjudicated per D4;
`docs/run-results.md` records the outcome table + per-impl findings (the k94 shape);
refined run-values committed. This closes the parent `appspec-pdfkit-viewer-k78`
Done-when — expect the parent-chain retire cascade on completion.

## Notes

Sample apps must be visually perfect — the human eye still checks the window during
live-run (graphical states have no OCR/AX read; record in run-results.md).
