#lang app-spec
;; forward-generated from Drawing Canvas §14 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: Color… opens the shared colour panel"
  #:description "When the user activates the Color… button, then the shared system colour panel appears as a window of the app (§8.1: sharedColorPanel, rewired continuous, makeKeyAndOrderFront) — its platform-supplied 'Colors' chrome becomes OCR-readable and the panel is expected as an AXWindow titled 'Colors'. Provisional (§14 marks the line to confirm in-VM — the panel chrome is platform-supplied; k112 firmed presence-as-a-window on all four impls): a PASS confirms the panel-presence gate the recolour scenarios (10, 11) rely on; a FAILURE is a chrome-text / snapshot-scope finding, not a suite bug. Only the panel's own 'Colors' AXWindow is asserted — the app window's coexistence in the same snapshot is a snapshot-scope to-confirm (scenekit precedent: whether the snapshot captures the key window only), left as a reported gap. No app code runs on mere opening (§8.1 boundary) — no [canvas] event is expected and none is asserted (silent no-ops emit nothing, logging contract). State-mutating (opens the panel): its own launch."

  ;; run: color-button-x/y — the Color… button's click coordinates (framebuffer px), bound at run time
  ;; from the per-app run-values config via current-run-values (ADR-0011). Internal defines so they
  ;; resolve at run time, not at load (L1a).
  (define color-button-x (run-value 'color-button-x))
  (define color-button-y (run-value 'color-button-y))

  ;; spec: §14 — Launch diagnostic is emitted. (presentation-settled probe for the coordinate click)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Drawing Canvas")

  ;; spec: §14 — Toolbar controls present. (Re-asserted as the render-settled probe: the Color… button is
  ;; the click target — the ellipsis-free 'Color' substring per the standing driver guidance.)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Color")

  ;; spec: (to confirm in-VM) — Colour panel opens. (the window is key at launch, so the first click
  ;; delivers; gv-click's pre-move is load-bearing — k130)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at color-button-x color-button-y)

  ;; spec: (to confirm in-VM) — Colour panel opens. ('Colors' is the panel's platform-supplied chrome and
  ;; appears nowhere in the app's own UI — the button reads 'Color…', which does not contain 'Colors' —
  ;; so its readability witnesses the panel; polling absorbs the panel-present latency)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Colors")

  ;; spec: (to confirm in-VM) — Colour panel opens. (the AX half: the in-process shared panel expected as
  ;; an AXWindow, platform-titled 'Colors' — observable-state role table: firm presence, k112)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "Colors"))
