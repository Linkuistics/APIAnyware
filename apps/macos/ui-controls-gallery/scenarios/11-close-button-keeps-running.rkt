#lang app-spec
;; forward-generated from UI Controls Gallery §13 on 2026-07-02, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: close-button keeps the process running"
  #:description "When the window's close control is activated, the window hides; per §3.8 and the gui-app ns-application-terminate model (no application delegate, no opt-in to close-to-quit — also the §12 'No close-to-quit' exclusion) the process is expected to KEEP RUNNING. Provisional (to confirm in-VM): a PASS confirms the expectation and signals reverse-gen may drop the (to confirm in-VM) marker; a FAILURE is a spec-quality finding for human review, not a suite bug (the runner captures the failure artifacts; some impls' printed 'Close window ... to exit' guidance is prose, not behaviour — §3.8). State-mutating: its own launch."

  ;; run: bundle-id — bound at run time from the impl descriptor / per-app run-values config (ADR-0011).
  ;; run: close-button-x / close-button-y — the window close control's coordinates (framebuffer px), bound at
  ;; run time from the per-app run-values config via current-run-values (ADR-0011). Window size is
  ;; impl-varying (§4), so the run stage may bind these per impl.
  ;; Internal defines inside the scenario thunk so they resolve at run time, not at load (validation L1a).
  (define bundle-id (run-value 'bundle-id))
  (define close-button-x (run-value 'close-button-x))
  (define close-button-y (run-value 'close-button-y))

  ;; spec: §13 — Launch diagnostic is emitted. (Re-asserted as the presentation-settled probe for the click below.)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Controls Gallery")

  ;; spec: (to confirm in-VM) — Close-button behaviour.
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at close-button-x close-button-y)

  ;; spec: (to confirm in-VM) — Close-button behaviour (expected: gui-app keeps running, §3.8 / ns-application-terminate).
  ;; harness: runner/harness-observations.rkt — expect-running-app asserts presence (#:running? defaults to #t).
  ;; run-tuning note: the window-hide is asynchronous; the run stage may insert a settle ((wait seconds),
  ;; runner/harness-state.rkt) before this check — a run-capability tweak, not a §13 assertion.
  (expect-running-app bundle-id))
