#lang app-spec
;; forward-generated from SceneKit Viewer §13 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: colour button opens the shared colour panel"
  #:description "When the user clicks the colour button, then the shared system colour panel appears — its platform-supplied 'Colors' chrome becomes OCR-readable, and (provisionally) the panel appears as an additional AXWindow of the app, the shared NSColorPanel being in-process (observable-state; snapshot scope — key vs. all windows — to confirm). Provisional (§13 marks the line to confirm in-VM: the chrome text is platform-supplied, observed 'Colors' in one impl's VM notes): a PASS confirms the panel-presence probe both suites downstream rely on; a FAILURE is a spec-quality / chrome-text finding, not a suite bug. State-mutating (opens the panel): its own launch."

  ;; run: color-button-x/y — the colour button's click coordinates (framebuffer px), bound at run time from
  ;; the per-app run-values config via current-run-values (ADR-0011). Internal defines so they resolve at
  ;; run time, not at load (validation L1a).
  (define color-button-x (run-value 'color-button-x))
  (define color-button-y (run-value 'color-button-y))

  ;; spec: §13 — Launch diagnostic is emitted. (presentation-settled probe for the coordinate click)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"SceneKit Viewer")

  ;; spec: §13 — Colour button present. (Re-asserted as the render-settled probe: the button is the click
  ;; target, so its title must be drawn before its coordinates are clicked.)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Colo")

  ;; spec: (to confirm in-VM) — Colour panel opens. (activate the colour button — §7.3: obtain the shared
  ;; panel, (re)wire it continuous, makeKeyAndOrderFront. Window is key at launch, first click delivers.)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at color-button-x color-button-y)

  ;; spec: (to confirm in-VM) — Colour panel opens. ('Colors' is the panel's platform-supplied chrome and
  ;; appears nowhere in the app's own UI, so its readability witnesses the panel; polling absorbs the
  ;; panel-present latency.)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Colors")

  ;; spec: (to confirm in-VM) — Colour panel opens. (the AX half, provisional: the in-process panel expected
  ;; as an additional AXWindow of the app, platform-titled 'Colors' — observable-state role table row
  ;; 'expected — to confirm in-VM, incl. snapshot scope once the panel is key'.)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "Colors"))
