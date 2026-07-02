#lang app-spec/run-values

;; Per-app run-values config for SceneKit Viewer (ADR-0011, the per-app
;; run-value source schema). Carries the *app-level* values the scenarios
;; read: toolbar/window/panel click coordinates (scenarios/03–08, 10); the
;; per-*impl* value (bundle-id) lives in each `#lang app-spec/impl`
;; descriptor (../../../targets/<t>/app-implementations/macos/
;; scenekit-viewer/scenekit-viewer-impl.rkt); the runner merges the two into
;; the single `current-run-values` table that `(run-value 'key)` reads
;; (runner/main.rkt; the descriptor wins on any key clash).
;;
;; This config holds *app data* and lives downstream in APIAnyware, never in
;; the AppSpec toolkit (ADR-0052). It is consumed by `runner/main.rkt
;; --run-values <this file>` and is deliberately NOT placed under scenarios/ —
;; the runner discovers every .rkt there as a `#lang app-spec` scenario, so a
;; config file there would be mis-loaded (runner/dispatch.rkt).
;;
;; ── MEASURED LIVE (live-run-k112, 2026-07-03) ── from `agent snapshot`
;; (AX position+size → element centre, framebuffer px) on the 1920x1080
;; testanyware-golden-macos-tahoe VM, after a two-launch determinism diff per
;; impl (byte-identical). This default is shared by CHEZ + GERBIL
;; (pixel-identical layouts, 26px toolbar controls); SBCL diverges (toolbar
;; strip 4px lower + wider 'Colour…' button → run-values-sbcl.rkt) and
;; RACKET diverges (tighter 22px control metrics AND a ~9px-higher colour-
;; panel pane — its compact metrics propagate into the shared NSColorPanel's
;; picker layout, which also omits the Opacity row → run-values-racket.rkt).
;;
;; PANEL state is system-remembered per-app: all four impls' panels open at
;; the default frame (0,605) 250x397 (bottom-left), and the live-run
;; provisioning pass seeded each impl's sliders pane to the RGB Sliders KIND
;; (fresh defaults open Grayscale — the 07/08 'Blue' gate would time out;
;; the pre-agreed seed-VM-defaults remedy) and verified it persists across a
;; clean quit+relaunch. Re-seed after any VM re-clone.
;;
;; No fixtures: the app ships no document (spec §13).

(run-values
  ;; scenarios/03,04,07,08 — the geometry picker (NSPopUpButton; measured
  ;; pos (651,184) size 101x26)
  (picker-x 702)
  (picker-y 197)
  ;; scenarios/04,07,08 — the 'Sphere' row in the OPEN picker menu, measured
  ;; from the open menu with 'Cube' current (a pop-up re-aligns its menu to
  ;; the current selection — §13 driver guidance; every menu-opening
  ;; scenario departs from the fresh-launch Cube selection, so one
  ;; measurement serves all three). OCR text box (661,215) 48x17.
  (sphere-item-x 685)
  (sphere-item-y 224)
  ;; scenarios/05,06,07,08 — the colour button centre ('Color…', measured
  ;; pos (758,184) size 69x26)
  (color-button-x 792)
  (color-button-y 197)
  ;; scenario/06 — the panel toolbar's colour-wheel mode tab (AXButton
  ;; 'Color Wheel' (15,629) 44x33; panel toolbar identical on all impls)
  (panel-wheel-tab-x 37)
  (panel-wheel-tab-y 646)
  ;; scenario/06 — a point inside the colour wheel, off-centre so the picked
  ;; colour is saturated and differs from the prior colour (wheel region
  ;; ≈ x 45–215, y 675–845, centre ≈ (130,760); provisioning-verified: a
  ;; SINGLE click here fired [scene] color-changed on sbcl AND racket —
  ;; the no-drag-verb to-confirm answered affirmatively)
  (wheel-point-x 170)
  (wheel-point-y 715)
  ;; scenarios/07,08 — the panel toolbar's sliders mode tab (AXButton
  ;; 'Color Sliders' (59,629) 44x33)
  (panel-sliders-tab-x 81)
  (panel-sliders-tab-y 646)
  ;; scenarios/07,08 — the RGB sliders pane's three value fields (AXTextField
  ;; (181,721/768/815) 52x24 each, right-aligned; bound from the panel's AX
  ;; snapshot in RGB-sliders mode)
  (panel-red-field-x 207)
  (panel-red-field-y 733)
  (panel-green-field-x 207)
  (panel-green-field-y 780)
  (panel-blue-field-x 207)
  (panel-blue-field-y 827)
  ;; scenario/08 — the colour panel's own close widget (AXButton (7,612)
  ;; 12x12)
  (panel-close-x 13)
  (panel-close-y 618)
  ;; scenario/10 — the app window's close control (leftmost traffic-light)
  ;; centre (AXButton (648,153) 16x16; window frame (640,145) 640x512)
  (close-button-x 656)
  (close-button-y 161))
