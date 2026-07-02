#lang app-spec
;; forward-generated from UI Controls Gallery §13 on 2026-07-02, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "no app-level handling: clicking the push button emits no controls event"
  #:description "When the user clicks the 'Click Me' push button, then no [controls] event appears in the events log within the bounded window — the §12 exclusion ('no app-specific handling' for the push button; the controls act only as themselves) realized against the logging contract's closed event set (exactly the four instrumented controls emit events, no others). Because the whole accumulated buffer is searched, this also witnesses that no [controls] event is emitted at construction time. State-mutating (a click trigger): its own launch."

  ;; run: push-button-x / push-button-y — the 'Click Me' push button's click coordinates (framebuffer px),
  ;; bound at run time from the per-app run-values config via current-run-values (ADR-0011). Window size and
  ;; layout are impl-varying (§4/§5), so the run stage may bind these per impl. Internal defines so they
  ;; resolve at run time, not at load.
  (define push-button-x (run-value 'push-button-x))
  (define push-button-y (run-value 'push-button-y))

  ;; spec: §13 — Launch diagnostic is emitted. (Re-asserted as the presentation-settled probe for the click below.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Controls Gallery")

  ;; spec: §12 (not included) — No app-specific handling for push-button clicks.
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at push-button-x push-button-y)

  ;; spec: §12 (not included) — No app-specific handling for push-button clicks.
  ;; harness: runner/harness-logs.rkt — expect-not-log asserts absence only within #:within seconds (not
  ;; eternal absence); 2.0s is set deliberately to absorb event-propagation latency after the click.
  (expect-not-log #px"\\[controls\\]" #:within 2.0))
