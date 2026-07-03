#lang app-spec/run-values

;; Per-app run-values SIBLING for the racket build of Drawing Canvas
;; (ADR-0011). The runner reads this via `--run-values` for the racket impl
;; ONLY; chez/gerbil/sbcl share run-values.rkt (the 26px-metrics window).
;; Same schema, same keys — only the coordinates differ.
;;
;; ── LIVE-MEASURED (live-run-k139, 2026-07-03) ──
;; racket's compact 22px control metrics give it its OWN window shape —
;; window (640,146) 640x508 (vs the 26px impls' (640,145) 640x512) — the
;; standing pdfkit/mini-browser/note-editor split (racket alone). Two-launch
;; determinism diff green. The toolbar controls sit ~4px higher (centre-line
;; fb y ~191 vs 195); the traffic-light close is at (654,160). The shared
;; NSColorPanel (frame (0,610) here) renders its RGB picker-pane fields ~5px
;; higher again than the 26px impls (729/776/823 vs 734/781/828) — racket's
;; compact metrics reach inside the panel (the scenekit k112 effect), so the
;; panel fields are carried here too. Canvas coordinates are identical to the
;; shared file (the canvas region x 640..1280 is the same on both shapes).
;;
;; NSColorPanel provisioning (k112): racket's panel seeded to RGB Sliders and
;; clean-quit at provisioning; the kind persists across `open -n` relaunches
;; (verified). The 'Blue' label OCRs as "Rluc" (k103 class) — 09/10/11's
;; `wait-for-ocr "Blue"` gate cannot pass; see run-results.md.

(run-values
  ;; scenarios/04,08,12,13,14,15 — the Clear button centre (measured live)
  (clear-button-x 1230)
  (clear-button-y 191)
  ;; scenarios/09,10,11 — the Color… button centre (measured live)
  (color-button-x 700)
  (color-button-y 191)
  ;; scenarios/07,12 — the width slider track's effective RIGHT end, knob
  ;; half-width in (k94): slider frame (761,181,198,18) → track x 761..959;
  ;; x=947 (= 959 − knob-half) drives the maximum (20).
  (slider-track-max-x 947)
  (slider-track-max-y 190)
  ;; scenarios/05,07,08,10,11,14,15 — a canvas point well inside the drawing
  ;; surface (canvas fb region x 640..1280, y 210..654; ~10px resize band)
  (canvas-point-x 960)
  (canvas-point-y 430)
  ;; scenarios/07,08,10 — a second, visibly distinct canvas point
  (canvas-point-2-x 1080)
  (canvas-point-2-y 520)
  ;; scenarios/06 — a held-button drag path across the canvas
  (canvas-drag-from-x 740)
  (canvas-drag-from-y 300)
  ;; scenarios/06,12 — the drag end point
  (canvas-drag-to-x 1140)
  (canvas-drag-to-y 400)
  ;; scenarios/10,11 — a title-bar point clear of the traffic lights AND the
  ;; window title (racket's title text spans fb x 906..1014; use the empty
  ;; stretch between the zoom button (~700) and the title); the re-key click.
  (window-titlebar-x 800)
  (window-titlebar-y 160)
  ;; scenarios/10,11 — the shared NSColorPanel (frame (0,610) for racket):
  ;; the panel toolbar's Color Sliders tab (measured live)
  (panel-sliders-tab-x 81)
  (panel-sliders-tab-y 650)
  ;; the RGB sliders pane's three value fields (racket actuals — ~5px higher
  ;; than the 26px impls, the compact-metrics picker-pane compression)
  (panel-red-field-x 207)
  (panel-red-field-y 729)
  (panel-green-field-x 207)
  (panel-green-field-y 776)
  (panel-blue-field-x 207)
  (panel-blue-field-y 823)
  ;; scenario/11 — the colour panel's own close widget (racket panel origin
  ;; (0,610))
  (panel-close-x 14)
  (panel-close-y 624)
  ;; scenario/17 — the app window's close control (leftmost traffic-light)
  (close-button-x 654)
  (close-button-y 160))
