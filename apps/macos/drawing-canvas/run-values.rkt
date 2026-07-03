#lang app-spec/run-values

;; Per-app run-values config for Drawing Canvas (ADR-0011, the per-app
;; run-value source schema). Carries the *app-level* values the scenarios
;; read: window/toolbar/canvas/panel click coordinates; the per-*impl*
;; value (bundle-id) lives in each `#lang app-spec/impl` descriptor
;; (../../../targets/<t>/app-implementations/macos/drawing-canvas/
;; drawing-canvas-impl.rkt); the runner merges the two into the single
;; `current-run-values` table that `(run-value 'key)` reads
;; (runner/main.rkt; the descriptor wins on any key clash).
;;
;; This config holds *app data* and lives downstream in APIAnyware, never
;; in the AppSpec toolkit (ADR-0052). It is consumed by `runner/main.rkt
;; --run-values <this file>` and is deliberately NOT placed under
;; scenarios/ — the runner discovers every .rkt there as a scenario
;; (runner/dispatch.rkt).
;;
;; ── LIVE-MEASURED (live-run-k139, 2026-07-03) ──
;; This file serves the THREE 26px-metrics impls — chez + gerbil + sbcl,
;; pixel-identical on the app window (window (640,145) 640x512; the
;; pdfkit/mini-browser/note-editor share-set — racket alone diverges onto
;; run-values-racket.rkt, its compact 22px window (640,146) 640x508).
;; Two-launch determinism diff green on all three (no ambiguous-layout
;; defect). Toolbar-control and canvas coordinates land identically on all
;; three. The shared NSColorPanel is subtler: chez/gerbil remember frame
;; (0,605), sbcl (0,610), so sbcl's RGB fields sit ~5px lower (739/786/833
;; vs 734/781/828) — but the 5px offset is absorbed by the 24px-tall fields,
;; so the chez/gerbil values below land INSIDE sbcl's fields too (verified),
;; and sbcl shares this file (measured, not assumed). racket's fields sit
;; ~5px higher again (729/776/823) — its sibling carries those.
;;
;; NSColorPanel provisioning (the k112 rule): each impl's panel was seeded
;; to the RGB Sliders KIND at provisioning and clean-quit (Cmd-Q) so the
;; kind persists across the runner's per-scenario `open -n` relaunches —
;; verified persisting on racket. Fresh per-app defaults open the sliders
;; pane in Grayscale; re-seed after any VM re-clone. Note (k139 finding):
;; the panel's 'Blue' slider label OCRs as "Rluc" (conf 0.50, the k103
;; small-text class) — the 09/10/11 `wait-for-ocr "Blue"` gate cannot pass;
;; adjudicated in run-results.md, the key behaviour proven by manual drive.

(run-values
  ;; scenarios/04,08,12,13,14,15 — the Clear button centre (measured live)
  (clear-button-x 1230)
  (clear-button-y 195)
  ;; scenarios/09,10,11 — the Color… button centre (measured live)
  (color-button-x 700)
  (color-button-y 195)
  ;; scenarios/07,12 — the width slider track's effective RIGHT end, knob
  ;; half-width in (k94): slider frame (759,182,202,26) → track x 759..961;
  ;; x=948 (= 961 − knob-half) drives the slider to its MAXIMUM (20) —
  ;; live-tuned until `width-changed width=20` fired (chez).
  (slider-track-max-x 948)
  (slider-track-max-y 195)
  ;; scenarios/05,07,08,10,11,14,15 — a canvas point well inside the drawing
  ;; surface (canvas fb region x 640..1280, y 213..657; ~10px resize band)
  (canvas-point-x 960)
  (canvas-point-y 430)
  ;; scenarios/07,08,10 — a second, visibly distinct canvas point
  (canvas-point-2-x 1080)
  (canvas-point-2-y 520)
  ;; scenarios/06 — a held-button drag path across the canvas (drag-from-to
  ;; endpoints, both well inside the canvas)
  (canvas-drag-from-x 740)
  (canvas-drag-from-y 300)
  ;; scenarios/06,12 — the drag end point (also 12's control-drag release,
  ;; inside the canvas, below the toolbar band)
  (canvas-drag-to-x 1140)
  (canvas-drag-to-y 400)
  ;; scenarios/10,11 — a title-bar point clear of the traffic lights AND the
  ;; window title (title text spans fb x 722..830 on the 26px impls); the
  ;; re-key click after the colour panel has taken key (no canvas mouse-down,
  ;; no control side-effect); title bar fb y 145..177.
  (window-titlebar-x 980)
  (window-titlebar-y 161)
  ;; scenarios/10,11 — the shared NSColorPanel (chez/gerbil at frame (0,605)):
  ;; the panel toolbar's Color Sliders tab (measured live)
  (panel-sliders-tab-x 81)
  (panel-sliders-tab-y 646)
  ;; the RGB sliders pane's three value fields (right-aligned, typed into
  ;; after a ctrl-a/ctrl-k clear — never OCR-read, k112). chez/gerbil actuals;
  ;; land inside sbcl's (739/786/833) fields too.
  (panel-red-field-x 207)
  (panel-red-field-y 734)
  (panel-green-field-x 207)
  (panel-green-field-y 781)
  (panel-blue-field-x 207)
  (panel-blue-field-y 828)
  ;; scenario/11 — the colour panel's own close widget (tiny 9x5; chez/gerbil
  ;; panel origin (0,605))
  (panel-close-x 14)
  (panel-close-y 619)
  ;; scenario/17 — the app window's close control (leftmost traffic-light;
  ;; measured live)
  (close-button-x 656)
  (close-button-y 161))
