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
;; ── PROVISIONAL (forward-gen-suite-k111, 2026-07-03) — NOT yet measured ──
;; App-window coordinates are estimates from the spec's fixed geometry
;; (§4/§5: 640x480 content, centred, titled; toolbar strip at content
;; (12, 440, 616, 32); [NSWindow center]'s above-true-centre vertical bias
;; ≈ 0.25·(screenH − windowH), as measured on hello-window and pdfkit)
;; projected onto the 1920x1080 testanyware-golden-macos-tahoe framebuffer,
;; with control widths estimated from intrinsic stack sizing: window frame
;; ≈ origin (640, 143), 640x508 (28px title bar + 480 content); toolbar
;; strip centre-line ≈ fb y 195. The COLOUR-PANEL coordinates are
;; placeholders only — the shared NSColorPanel's position is
;; system-remembered and genuinely unmeasurable pre-run (a nominal panel
;; frame of (1250, 150) 445x550 is assumed). The live-run stage MUST
;; re-measure EVERY coordinate from `agent snapshot --mode layout` (AX
;; centre, framebuffer px) with a two-launch determinism diff before binding
;; values — the k77/k94 per-impl geometry practice — keeping sibling
;; per-impl run-values-<impl>.rkt files only where impl layouts genuinely
;; diverge (pdfkit: chez+gerbil+sbcl shared one table, racket diverged;
;; the gallery's share-set differed — measure, never assume).
;;
;; No fixtures: the app ships no document (spec §13).

(run-values
  ;; scenarios/03,04,07,08 — the geometry picker (NSPopUpButton, first
  ;; arranged subview; est. width ~100 from the four item titles)
  (picker-x 702)
  (picker-y 195)
  ;; scenarios/04,07,08 — the 'Sphere' row in the OPEN picker menu, measured
  ;; from the open menu's AX snapshot with 'Cube' current (a pop-up
  ;; re-aligns its menu to the current selection — §13 driver guidance;
  ;; every menu-opening scenario departs from the fresh-launch Cube
  ;; selection, so one measurement serves all three). Est.: one ~22px menu
  ;; row below the picker centre-line.
  (sphere-item-x 702)
  (sphere-item-y 217)
  ;; scenarios/05,06,07,08 — the colour button centre (second arranged
  ;; subview: x from 652+~100+8 spacing; est. width ~75 for 'Color…')
  (color-button-x 798)
  (color-button-y 195)
  ;; scenario/06 — the panel toolbar's colour-wheel mode tab (PLACEHOLDER —
  ;; panel-relative; first toolbar icon of the assumed panel frame)
  (panel-wheel-tab-x 1286)
  (panel-wheel-tab-y 195)
  ;; scenario/06 — a point inside the colour wheel, off-centre so the picked
  ;; colour is saturated and differs from the prior colour (PLACEHOLDER)
  (wheel-point-x 1520)
  (wheel-point-y 380)
  ;; scenarios/07,08 — the panel toolbar's sliders mode tab (PLACEHOLDER —
  ;; second toolbar icon)
  (panel-sliders-tab-x 1322)
  (panel-sliders-tab-y 195)
  ;; scenarios/07,08 — the RGB sliders pane's three value fields
  ;; (PLACEHOLDER — right-aligned fields; bind from the panel's AX snapshot
  ;; while in RGB-sliders mode)
  (panel-red-field-x 1650)
  (panel-red-field-y 300)
  (panel-green-field-x 1650)
  (panel-green-field-y 340)
  (panel-blue-field-x 1650)
  (panel-blue-field-y 380)
  ;; scenario/08 — the colour panel's own close widget (PLACEHOLDER —
  ;; panel frame origin + traffic-light offset)
  (panel-close-x 1270)
  (panel-close-y 165)
  ;; scenario/10 — the app window's close control (leftmost traffic-light)
  ;; centre (window-frame origin + (16, 16), the hello-window/pdfkit-
  ;; measured offset)
  (close-button-x 656)
  (close-button-y 159))
