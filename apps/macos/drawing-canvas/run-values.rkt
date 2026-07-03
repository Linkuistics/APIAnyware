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
;; ── PROVISIONAL (forward-gen-suite-k138, 2026-07-03) ──
;; NOT yet live-measured. Values are the k120 spec-derived projection over
;; the live-measured geometry of the SAME window shape: the app's window is
;; 640x480-content, centred, traffic-light-identical to scenekit-viewer's,
;; whose live-run-k112 measurements on the 1920x1080 VM anchor everything
;; here — window frame (640,145) 640x512 on the 26px-metrics impls (content
;; top-left fb (640,177)), the shared NSColorPanel at its default frame
;; with the k112-measured pane coordinates carried over verbatim. The
;; live-run stage MUST re-measure per impl from `agent snapshot --mode
;; layout` (two-launch determinism diff first), split per-impl siblings
;; only where layouts diverge (measure the share-set, never assume it —
;; racket's compact 22px metrics WILL diverge: scenekit measured its window
;; at (640,146) 640x508 and its panel RGB fields ~9px higher at
;; (207,724/771/818)), and re-tune slider-track-max-* until the driven
;; `width-changed` value IS the asserted maximum 20 (the coordinate is the
;; free variable, the asserted value the rule — the k94 end-click practice).
;;
;; NSColorPanel provisioning (the k112 rule): seed each impl's panel to the
;; RGB Sliders KIND at provisioning (fresh per-app defaults open Grayscale —
;; the scenarios' 'Blue' gate would time out); remembered per-app, survives
;; relaunch; re-seed after any VM re-clone. All four impls' panels open at
;; the default frame (0,605) 250x397 (bottom-left).
;;
;; No fixtures, no work/ directory, no between-scenario cleanup: all app
;; state is in-process and dies with the relaunch (observable-state.md).

(run-values
  ;; scenarios/04,08,12,13,14,15 — the Clear button centre (content frame
  ;; (552,448,76,28) right-anchored → fb, launch width)
  (clear-button-x 1230)
  (clear-button-y 195)
  ;; scenarios/09,10,11 — the Color… button centre (content frame
  ;; (12,448,96,28) → fb)
  (color-button-x 700)
  (color-button-y 195)
  ;; scenarios/07,12 — the width slider track's effective RIGHT end, knob
  ;; half-width in (k94): slider frame (120,450,200,24) → fb track x
  ;; 760..960; the click must drive the slider to its MAXIMUM (20)
  (slider-track-max-x 944)
  (slider-track-max-y 195)
  ;; scenarios/05,07,08,10,11,14,15 — a canvas point well inside the drawing
  ;; surface (canvas fb region x 640..1280, y 213..657; respect the ~10px
  ;; resize-border band)
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
  ;; scenarios/10,11 — a title-bar point clear of the traffic lights: the
  ;; re-key click after the colour panel has taken key (no canvas
  ;; mouse-down, no control side-effect — observable-state driver guidance;
  ;; title bar fb y 145..177)
  (window-titlebar-x 980)
  (window-titlebar-y 161)
  ;; scenarios/10,11 — the shared NSColorPanel (k112-measured, carried over:
  ;; default frame shared by all four impls; pane interior is per-impl —
  ;; racket's fields sit ~9px higher, split at live-run):
  ;; the panel toolbar's sliders mode tab (AXButton 'Color Sliders')
  (panel-sliders-tab-x 81)
  (panel-sliders-tab-y 646)
  ;; the RGB sliders pane's three value fields (right-aligned, typed into
  ;; after a ctrl-a/ctrl-k clear — never OCR-read, k112)
  (panel-red-field-x 207)
  (panel-red-field-y 733)
  (panel-green-field-x 207)
  (panel-green-field-y 780)
  (panel-blue-field-x 207)
  (panel-blue-field-y 827)
  ;; scenario/11 — the colour panel's own close widget
  (panel-close-x 13)
  (panel-close-y 618)
  ;; scenario/17 — the app window's close control (leftmost traffic-light;
  ;; scenekit-measured same-shape anchor)
  (close-button-x 656)
  (close-button-y 161))
