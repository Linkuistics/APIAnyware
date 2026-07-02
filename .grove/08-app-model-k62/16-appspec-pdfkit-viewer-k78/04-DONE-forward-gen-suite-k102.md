# forward-gen-suite-k102

**Kind:** work

## Goal

Forward-gen the pdfkit-viewer `#lang app-spec` scenario suite + `run-values.rkt` (+ the
**PDF fixture**) from the k95 spec + k96 contracts, via the AppSpec forward-gen workflow
(`~/Development/AppSpec/capabilities/forward-gen/workflow.md`) — the gallery k93 stage.
Suite homes at `apps/macos/pdfkit-viewer/scenarios/`.

## Context

- **Template:** the ui-controls-gallery suite (`apps/macos/ui-controls-gallery/scenarios/`
  + `run-values.rkt`) — the k93 worked exemplar (hard vs `recording:` cluster split,
  `;; spec:` per-assertion tracing, coverage-or-gap rule
  `AppSpec/capabilities/forward-gen/validation.md` L1b, two-run consensus for a suite
  gating four impls, presentation-settled `wait-for-log` probe before coordinate clicks).
- **Inputs:** `apps/macos/pdfkit-viewer/docs/{spec,logging-contract,observable-state}.md`.
  The observable-state assertion→path map is the suite's skeleton — every §13 line
  verb-backed or a documented gap.
- **All four impls are instrumented + built** (k98–k101): the suite can assume the
  contract events (`[lifecycle] startup`, bare launch line beginning `PDFKit Viewer`,
  `[document] opened file="…" pages=N` / `page-changed page=n pages=N`, `shutdown
  reason=menu`) and the descriptors at
  `targets/<t>/app-implementations/macos/pdfkit-viewer/pdfkit-viewer-impl.rkt`.
- **App-specific: the PDF fixture.** No impl ships a document (k95) — provision an
  **N ≥ 3-page** fixture, lazy + assertable, homed with the scenarios (never in the
  AppSpec toolkit). The k101-era learnings recipe: generate with CoreGraphics
  (`beginPDFPage`/`CTLineDraw`), each page a distinct colour + big "PAGE n". The `opened`
  event exact-matches the fixture's **basename** (panel canonicalization makes the full
  path unstable).
- **Panel driving is out-of-process** (k95): the NSOpenPanel is not in the app's AX tree
  — drive by keyboard: Cmd-Shift-G → full fixture path → Return ×2.
- **Contract rules the scenarios must respect:** consumers never **count** `page-changed`
  events nor assume ordering vs `opened` (assigning a document may itself fire the
  notification; match the specific driven-to line, e.g. `page=2 pages=3`); silent no-ops
  (cancel / nil URL / failed init) emit nothing — assert the persisting empty state via
  OCR/AX, never a negative log read; the nav-enabled-flag read is **runner-side only**
  (the SDK transform + `expect-ax` drop `enabled`) — the label + `[document]` events
  proxy the four flag assertions until `expect-ax #:enabled?` lands in AppSpec.

## Done when

The suite + `run-values.rkt` + the fixture are authored and validated per the
forward-gen workflow's checks (scenario↔spec correlation review; coverage-or-gap map
complete); committed. Running the suite live is the Tier-2 live-run leaf's bar (grow it
on retire).

## Notes

Window geometry differs per impl (720×540 content in racket/chez/gerbil/sbcl but layouts
may diverge in toolbar placement) — apply the k77 per-impl geometry practice: measure
from `agent snapshot --mode layout`, two-launch determinism diff before binding values,
per-impl `run-values-<impl>.rkt` only where layouts diverge.
