#lang app-spec
;; forward-generated from Hello Window §10 on 2026-06-30, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: close-button keeps the process running"
  #:description "When the window's close control is activated, the window hides; per §3.8 and the gui-app ns-application-terminate model (no opt-in to close-to-quit) the process is expected to KEEP RUNNING. Provisional (to confirm in-VM): a PASS confirms the expectation and signals reverse-gen may drop the (to confirm in-VM) marker; a FAILURE is a spec-quality finding for human review, not a suite bug (the runner captures the failure artifacts). State-mutating: its own launch."

  ;; run: bundle-id — bound at run time from the impl descriptor / per-app run-values config (ADR-0011).
  ;; run: close-button-x / close-button-y — per-app window close-control coordinates (framebuffer px),
  ;; bound at run time from the per-app run-values config via current-run-values (ADR-0011).
  ;; Internal defines inside the scenario thunk so they resolve at run time, not at load —
  ;; keeping the suite loadable outside the runner (validation L1a).
  (define bundle-id (run-value 'bundle-id))
  (define close-button-x (run-value 'close-button-x))
  (define close-button-y (run-value 'close-button-y))

  ;; spec: (to confirm in-VM) — Close-button behaviour.
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at close-button-x close-button-y)

  ;; spec: (to confirm in-VM) — Close-button behaviour (expected: gui-app keeps running, §3.8 / ns-application-terminate).
  ;; harness: runner/harness-observations.rkt — expect-running-app asserts presence (#:running? defaults to #t); this is the §3-anchored "keeps running" expectation.
  ;; run-tuning note (for 04): the window-hide is asynchronous; 04 may insert a settle ((wait seconds)) before this check — a run-capability tweak, not a §10 assertion.
  (expect-running-app bundle-id))
