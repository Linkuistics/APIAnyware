#lang app-spec
;; forward-generated from UI Controls Gallery §13 on 2026-07-02, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: slider clamps to its 0-100 range"
  #:description "When the user drives the slider to and past each end of its track, then the value clamps to the configured range — the driven-to values observed via [controls] slider-changed are exactly 100 at the max end and 0 at the min end (integer-formatted per the logging contract). A continuous slider may emit many slider-changed lines per interaction, so the driven-to value is matched, never a count. Provisional (to confirm in-VM — the ranges are configured, the clamping is platform runtime behaviour): a PASS confirms; a FAILURE is a spec-quality finding, not a suite bug. State-mutating: its own launch."

  ;; run: slider-track-max-x/y and slider-track-min-x/y — click coordinates at (and just past) the slider
  ;; track's two ends (framebuffer px), bound at run time from the per-app run-values config via
  ;; current-run-values (ADR-0011). Window size and layout are impl-varying (§4/§5), so the run stage may bind
  ;; these per impl. Internal defines inside the scenario thunk so they resolve at run time, not at load.
  (define slider-track-max-x (run-value 'slider-track-max-x))
  (define slider-track-max-y (run-value 'slider-track-max-y))
  (define slider-track-min-x (run-value 'slider-track-min-x))
  (define slider-track-min-y (run-value 'slider-track-min-y))

  ;; spec: §13 — Launch diagnostic is emitted. (Re-asserted as the presentation-settled probe for the clicks below.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Controls Gallery")

  ;; spec: (to confirm in-VM) — Boundary — slider clamps. (drive to/past the max end)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y); a track click jumps the knob to the
  ;; clicked point (default NSSlider behaviour).
  (click-at slider-track-max-x slider-track-max-y)

  ;; spec: (to confirm in-VM) — Boundary — slider clamps.
  ;; harness: runner/harness-logs.rkt — regexp; the clamped max is exactly 100 (integer-formatted values,
  ;; logging contract). Intermediate slider-changed lines may precede it; the wait matches the driven-to value.
  (wait-for-log #px"\\[controls\\] slider-changed value=100")

  ;; spec: (to confirm in-VM) — Boundary — slider clamps. (drive to/past the min end)
  (click-at slider-track-min-x slider-track-min-y)

  ;; spec: (to confirm in-VM) — Boundary — slider clamps.
  ;; harness: runner/harness-logs.rkt — \b keeps the bare 0 from matching inside a longer integer (e.g. the
  ;; buffered value=100 from the max end); the clamped min is exactly 0.
  (wait-for-log #px"\\[controls\\] slider-changed value=0\\b"))
