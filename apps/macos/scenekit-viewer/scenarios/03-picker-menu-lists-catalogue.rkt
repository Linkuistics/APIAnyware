#lang app-spec
;; forward-generated from SceneKit Viewer §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: picker menu lists the geometry catalogue"
  #:description "When the user clicks the geometry picker, then its menu opens listing the four catalogue titles — Cube, Sphere, Torus, Cylinder (§5.1/§6) — with the three non-selected titles becoming OCR-readable (the selected 'Cube' is not discriminating: it already reads on the closed picker). Provisional (§13 marks the line to confirm in-VM; the open-menu AXMenuItem role/title shape is uncertain in the role table): a PASS confirms the catalogue listing and firms the open-menu AX row — which the run stage also depends on, since item CLICK positions are read from the open menu's AX snapshot (§13 driver guidance); a FAILURE is a spec-quality / menu-driving finding, not a suite bug. State-mutating (opens the menu): its own launch."

  ;; run: picker-x/y — the geometry picker's click coordinates (framebuffer px), bound at run time from the
  ;; per-app run-values config via current-run-values (ADR-0011). Internal defines inside the scenario thunk
  ;; so they resolve at run time, not at load (validation L1a).
  (define picker-x (run-value 'picker-x))
  (define picker-y (run-value 'picker-y))

  ;; spec: §13 — Launch diagnostic is emitted. (Re-asserted as the presentation-settled probe for the
  ;; coordinate click below.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"SceneKit Viewer")

  ;; spec: §13 — Colour button present. (Re-asserted as the render-settled probe: the toolbar strip must be
  ;; drawn before its coordinates are clicked. 'Colo' is the strip's FIRM text — the picker's own 'Cube'
  ;; display is itself to-confirm (02's subject), so probing on it here would couple this scenario's
  ;; verdict to 02's finding.)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Colo")

  ;; spec: (to confirm in-VM) — Picker menu lists the catalogue. (open the picker's menu. The window is key
  ;; at launch, so the first click delivers — the first-click-only-re-activates rule applies only after the
  ;; colour panel has taken key, §13 driver guidance.)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at picker-x picker-y)

  ;; spec: (to confirm in-VM) — Picker menu lists the catalogue. (the §13-named probe: any non-selected
  ;; title witnesses the OPEN menu; polling absorbs the menu-open latency.)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Torus")

  ;; spec: (to confirm in-VM) — Picker menu lists the catalogue. (the remaining non-selected titles — with
  ;; 'Torus' above, all of Sphere/Torus/Cylinder are witnessed in the open menu.)
  ;; harness: runner/harness-observations.rkt — expect-ocr is a single-shot literal substring match; the
  ;; menu is open and static once 'Torus' has read.
  (expect-ocr "Sphere")
  ;; spec: (to confirm in-VM) — Picker menu lists the catalogue. (as above)
  (expect-ocr "Cylinder")

  ;; spec: (to confirm in-VM) — Picker menu lists the catalogue. (the open-menu AX-snapshot half: the role
  ;; table marks the AXMenuItem role/title shape uncertain — this provisional read firms it, and with it
  ;; the run stage's item-position reads.)
  ;; harness: runner/harness-observations.rkt — expect-ax matches #:role (+ optional exact #:title only).
  (expect-ax #:role 'AXMenuItem #:title "Torus"))
