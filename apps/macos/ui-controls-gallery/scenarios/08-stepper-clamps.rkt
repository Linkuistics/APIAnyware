#lang app-spec
;; forward-generated from UI Controls Gallery §13 on 2026-07-02, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: stepper clamps to its 0-10 range"
  #:description "When the user clicks the stepper's increment arrow twelve times, then repeated increments stop at 10 (the driven-to top value observed via [controls] stepper-changed is exactly 10); when the user then clicks the decrement arrow twelve times, repeated decrements stop at 0. Twelve clicks exceed the whole 0-10 span, so the clamped ends are reached regardless of the impl-varying initial preset (a §6 hole). Provisional (to confirm in-VM — the range/increment are configured, the clamping is platform runtime behaviour): a PASS confirms; a FAILURE is a spec-quality finding, not a suite bug. State-mutating: its own launch."

  ;; run: stepper-increment-x/y and stepper-decrement-x/y — click coordinates of the stepper's up and down
  ;; arrows (framebuffer px), bound at run time from the per-app run-values config via current-run-values
  ;; (ADR-0011). Window size and layout are impl-varying (§4/§5), so the run stage may bind these per impl.
  ;; Internal defines inside the scenario thunk so they resolve at run time, not at load.
  (define stepper-increment-x (run-value 'stepper-increment-x))
  (define stepper-increment-y (run-value 'stepper-increment-y))
  (define stepper-decrement-x (run-value 'stepper-decrement-x))
  (define stepper-decrement-y (run-value 'stepper-decrement-y))

  ;; spec: §13 — Launch diagnostic is emitted. (Re-asserted as the presentation-settled probe for the clicks below.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Controls Gallery")

  ;; spec: (to confirm in-VM) — Boundary — stepper clamps. (repeated increments; loops are first-class racket
  ;; in app-spec — scenarios are code, not data, app-spec/main.rkt)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (for ([_ (in-range 12)])
    (click-at stepper-increment-x stepper-increment-y))

  ;; spec: (to confirm in-VM) — Boundary — stepper clamps.
  ;; harness: runner/harness-logs.rkt — the driven-to top value is exactly 10 (integer-formatted); the wait
  ;; matches the value, not an event count. \b keeps value=10 from ever matching inside a longer integer.
  (wait-for-log #px"\\[controls\\] stepper-changed value=10\\b")

  ;; spec: (to confirm in-VM) — Boundary — stepper clamps. (repeated decrements)
  (for ([_ (in-range 12)])
    (click-at stepper-decrement-x stepper-decrement-y))

  ;; spec: (to confirm in-VM) — Boundary — stepper clamps.
  ;; harness: runner/harness-logs.rkt — \b keeps the bare 0 from matching inside the buffered value=10 lines.
  (wait-for-log #px"\\[controls\\] stepper-changed value=0\\b"))
