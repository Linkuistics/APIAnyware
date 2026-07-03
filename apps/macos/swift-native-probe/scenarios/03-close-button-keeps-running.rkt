#lang app-spec
;; forward-generated from Swift-Native Probe §10 on 2026-07-04, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: close-button keeps the process running"
  #:description "When the window's close control is activated, the window hides; per §3.9 (termination is Quit-driven, not close-driven — no application delegate, no terminate-after-last-window-closed opt-in, and the gui-app app-kind does not require it) the process is expected to KEEP RUNNING. Provisional (§10 marks this to-confirm in-VM; the hello-window precedent confirmed it holds for all four targets): a PASS confirms the expectation and signals reverse-gen may drop the (to confirm in-VM) marker; a FAILURE is a spec-quality finding for human review, not a suite bug (the runner captures the failure artifacts). Per the logging contract, closing the window is expected to emit NOTHING; a shutdown line observed at live-run would be the spec-quality finding, recorded from the run artifacts, never asserted here. State-mutating: its own launch."

  ;; run: bundle-id — from the impl descriptor (ADR-0011); close-button-x / close-button-y — the app
  ;; window's close-control coordinates (framebuffer px), from the per-app run-values config. Internal
  ;; defines so they resolve at run time, not at load (validation L1a).
  (define bundle-id (run-value 'bundle-id))
  (define close-button-x (run-value 'close-button-x))
  (define close-button-y (run-value 'close-button-y))

  ;; spec: §10 — Readiness / launch diagnostic. (presentation-settled probe for the coordinate click)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP; the literal '.' is escaped.
  (wait-for-log #rx"Swift-Native Probe opened\\.")
  ;; spec: §10 — Window title is correct. (render-settled probe — the window is present before we click its close control)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr matches a literal substring.
  (wait-for-ocr "Swift-Native API Coverage")

  ;; spec: (to confirm in-VM) — Close-button keeps the process running. (activate the close control — the window is key at launch, so the first click delivers)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at close-button-x close-button-y)

  ;; spec: (to confirm in-VM) — Close-button keeps the process running. (expected: the gui-app keeps running — §3.9 / ns-application-terminate; the window hides, the process stays. The window-hide is asynchronous, so settle before the check — a run-capability tweak, not a §10 assertion.)
  ;; harness: runner/harness-state.rkt — (wait seconds).
  (wait 2)
  ;; harness: runner/harness-observations.rkt — expect-running-app asserts presence (#:running? defaults to #t).
  (expect-running-app bundle-id))
