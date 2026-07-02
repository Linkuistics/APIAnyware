#lang app-spec/run-values

;; Per-impl run-values sibling for the SBCL build of SceneKit Viewer — the
;; k77/k94 per-impl geometry practice: a sibling exists only where an impl's
;; layout genuinely diverges from the shared default (run-values.rkt, which
;; chez + gerbil share). sbcl's toolbar strip sits 4px LOWER (controls
;; (651,188) vs (651,184)) and its colour button is wider ('Colour…' 76px vs
;; 'Color…' 69px — the spelling divergence is by design, spec §5.1), shifting
;; the three app-window control centres. Window frame, close control, picker
;; open-menu geometry, and the whole colour-panel pane are shared with the
;; default.
;;
;; MEASURED LIVE (live-run-k112, 2026-07-03) from `agent snapshot` (AX
;; position+size → element centre, framebuffer px) on the 1920x1080
;; testanyware-golden-macos-tahoe VM, after a two-launch determinism diff
;; (byte-identical). See run-values.rkt for the schema / consumption /
;; panel-seeding notes (runner/main.rkt --run-values <this file>).

(run-values
  ;; the geometry picker (measured pos (651,188) size 101x26)
  (picker-x 702)
  (picker-y 201)
  ;; the 'Sphere' row in the OPEN picker menu (OCR text box (661,215) 47x20)
  (sphere-item-x 684)
  (sphere-item-y 225)
  ;; the colour button centre ('Colour…', measured pos (758,188) size 76x26)
  (color-button-x 796)
  (color-button-y 201)
  ;; colour panel (frame (0,605) 250x397, same as default; RGB kind seeded)
  (panel-wheel-tab-x 37)
  (panel-wheel-tab-y 646)
  (wheel-point-x 170)
  (wheel-point-y 715)
  (panel-sliders-tab-x 81)
  (panel-sliders-tab-y 646)
  (panel-red-field-x 207)
  (panel-red-field-y 733)
  (panel-green-field-x 207)
  (panel-green-field-y 780)
  (panel-blue-field-x 207)
  (panel-blue-field-y 827)
  (panel-close-x 13)
  (panel-close-y 618)
  ;; the app window's close control (AXButton (648,153) 16x16)
  (close-button-x 656)
  (close-button-y 161))
