#lang app-spec/run-values

;; Per-impl run-values sibling for the RACKET build of SceneKit Viewer — the
;; k77/k94 per-impl geometry practice: a sibling exists only where an impl's
;; layout genuinely diverges from the shared default (run-values.rkt, which
;; chez + gerbil share). racket's generated-binding control metrics are
;; tighter (22px-high toolbar controls vs the others' 26px — the same
;; divergence the gallery and pdfkit measured), shifting every app-window
;; centre — AND, new with this app, the compact metrics propagate into the
;; shared NSColorPanel's PICKER PANE: racket's sliders pane sits ~9px higher
;; (fields (181,712/759/806) vs (181,721/768/815)) and its wheel pane omits
;; the Opacity row entirely (a larger wheel). Panel frame, toolbar tabs, and
;; close widget are unchanged (window chrome, not pane content).
;;
;; MEASURED LIVE (live-run-k112, 2026-07-03) from `agent snapshot` (AX
;; position+size → element centre, framebuffer px) on the 1920x1080
;; testanyware-golden-macos-tahoe VM, after a two-launch determinism diff
;; (byte-identical). See run-values.rkt for the schema / consumption /
;; panel-seeding notes (runner/main.rkt --run-values <this file>).

(run-values
  ;; the geometry picker (measured pos (651,181) size 85x22)
  (picker-x 694)
  (picker-y 192)
  ;; the 'Sphere' row in the OPEN picker menu (OCR text box (659,209) 45x14 —
  ;; racket's menu rows are compact too)
  (sphere-item-x 682)
  (sphere-item-y 216)
  ;; the colour button centre ('Color…', measured pos (742,181) size 62x22)
  (color-button-x 773)
  (color-button-y 192)
  ;; colour panel (frame (0,605) 250x397 shared; toolbar tabs shared; RGB
  ;; kind seeded)
  (panel-wheel-tab-x 37)
  (panel-wheel-tab-y 646)
  ;; wheel pane: racket's wheel is taller (no Opacity row; region ≈ y
  ;; 660–880); this point provisioning-verified — a SINGLE click fired
  ;; [scene] color-changed r=255 g=235 b=73
  (wheel-point-x 170)
  (wheel-point-y 715)
  (panel-sliders-tab-x 81)
  (panel-sliders-tab-y 646)
  ;; the RGB sliders pane's three value fields — racket's compact pane
  ;; (AXTextField (181,712/759/806) 52x24)
  (panel-red-field-x 207)
  (panel-red-field-y 724)
  (panel-green-field-x 207)
  (panel-green-field-y 771)
  (panel-blue-field-x 207)
  (panel-blue-field-y 818)
  (panel-close-x 14)
  (panel-close-y 618)
  ;; the app window's close control (AXButton (648,153) 12x14; window frame
  ;; (640,146) 640x508)
  (close-button-x 654)
  (close-button-y 160))
