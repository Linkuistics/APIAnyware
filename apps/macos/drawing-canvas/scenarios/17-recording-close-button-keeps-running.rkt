#lang app-spec
;; forward-generated from Drawing Canvas §14 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: close-button keeps the process running"
  #:description "When the window's close control is activated, the window hides; per §3 (termination is Quit-driven, not close-driven: no application delegate, no terminate-after-last-window-closed opt-in — also §13's 'no close-to-quit' exclusion) the process is expected to KEEP RUNNING. Confirmed on all four impls at live-run — the seventh portfolio app to confirm the keep-running expectation, after hello-window/gallery/pdfkit/scenekit/mini-browser/note-editor (run-results.md scenario 17); the earlier provisional marker is dropped (ADR-0010 D4). A regression here would be a spec-quality finding for human review, not a suite bug — three impls' printed 'Close window or Ctrl+C to exit' guidance is prose, not behaviour (§3). Per the logging contract, closing the window is expected to emit NOTHING; a shutdown line observed at live-run would be the spec-quality finding, recorded from the run artifacts, never asserted here. State-mutating: its own launch."

  ;; run: bundle-id — from the impl descriptor (ADR-0011); close-button-x/y — the app window's close
  ;; control coordinates (framebuffer px), from the per-app run-values config. Internal defines so they
  ;; resolve at run time, not at load (validation L1a).
  (define bundle-id (run-value 'bundle-id))
  (define close-button-x (run-value 'close-button-x))
  (define close-button-y (run-value 'close-button-y))

  ;; spec: §14 — Launch diagnostic is emitted. (presentation-settled probe for the coordinate click)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Drawing Canvas")
  ;; spec: §14 — Toolbar controls present. (render-settled probe)
  (wait-for-ocr "Clear")

  ;; spec: §3 — Close-button behaviour, confirmed ×4. (activate the close control — the window is key at
  ;; launch, so the first click delivers)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at close-button-x close-button-y)

  ;; spec: §3 — Close-button behaviour, confirmed ×4. (expected: the gui-app keeps running — §3 /
  ;; ns-application-terminate; the window hides, the process stays. run-tuning note: the window-hide is
  ;; asynchronous; a settle before this check is a run-capability tweak, not a §14 assertion.)
  ;; harness: runner/harness-observations.rkt — expect-running-app asserts presence (#:running? defaults
  ;; to #t).
  (wait 2)
  (expect-running-app bundle-id))
