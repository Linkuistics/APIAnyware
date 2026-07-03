#lang app-spec
;; forward-generated from Drawing Canvas §14 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "Clear on an empty canvas is a safe no-op"
  #:description "When the user activates Clear at launch, with nothing drawn, then the action is a safe no-op: the cleared event reports count=0 — which simultaneously proves the launch stroke SET is empty (the model half of §14's 'launch canvas is blank'; the cleared event is always emitted, including on an empty canvas, and its count is the positive stroke-set-cardinality channel — logging contract) — and the app keeps running. Launch-state pixel blankness itself is pixel-level with no verb — the screenshot artifact is that record (documented gap). State-mutating (a Clear action): its own launch."

  ;; run: bundle-id — bound at run time from the impl descriptor (ADR-0011).
  ;; run: clear-button-x/y — the Clear button's click coordinates (framebuffer px), bound at run time from
  ;; the per-app run-values config via current-run-values (ADR-0011); click at AX-reported coordinates,
  ;; never screenshot pixels (§14 driver guidance). Internal defines so they resolve at run time, not at
  ;; load (validation L1a).
  (define bundle-id (run-value 'bundle-id))
  (define clear-button-x (run-value 'clear-button-x))
  (define clear-button-y (run-value 'clear-button-y))

  ;; spec: §14 — Launch diagnostic is emitted. (presentation-settled probe for the coordinate click)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Drawing Canvas")

  ;; spec: §14 — Toolbar controls present. (Re-asserted as the render-settled probe: the Clear title is
  ;; the click target, so it must be drawn before its coordinates are clicked.)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Clear")

  ;; spec: §14 — Boundary — Clear on an empty canvas is a safe no-op. (the window is key at launch, so the
  ;; first click delivers; gv-click's 100px pre-move is load-bearing for every click here — k130)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at clear-button-x clear-button-y)

  ;; spec: §14 — Boundary — Clear on an empty canvas is a safe no-op. (count=0: nothing was removed)
  ;; spec: (to confirm in-VM) — Launch canvas is blank. (the model half: cleared count=0 proves the empty
  ;; stroke set at launch — the positive cardinality channel; the pixel half rides the screenshot artifact)
  ;; harness: runner/harness-logs.rkt — regexp; \\b keeps count=0 from matching inside a longer integer.
  (wait-for-log #px"\\[canvas\\] cleared count=0\\b")

  ;; spec: §14 — Boundary — Clear on an empty canvas is a safe no-op. ('safe': the app keeps running)
  ;; harness: runner/harness-observations.rkt — #:running? defaults to #t.
  (expect-running-app bundle-id))
