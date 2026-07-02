#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: close button leaves the process running"
  #:description
  "When the window's close control is clicked, then per §3.10 and the gui-app app-kind (termination is Quit-driven — ns-application-terminate; no implementation opts into terminate-after-last-window-closed; §14 excludes close-to-quit) the window hides and the process is expected to keep running. recording: §3.10 flags this (to confirm in-VM) — a pass confirms the expectation and signals reverse-gen may drop the marker; a failure is a spec-quality finding (three impls' 'Close window … to exit' guidance prose would be the contradiction to investigate), not a suite bug — the runner captures artifacts for review. Fifth-app precedent: hello-window through mini-browser all confirmed keep-running."

  ;; run: bundle-id — bound at run time from the impl descriptor (ADR-0011);
  ;; close-button-x/y — the window close control's centre (framebuffer px) from the
  ;; per-app run-values config.
  (define bundle-id (run-value 'bundle-id))
  (define close-x (run-value 'close-button-x))
  (define close-y (run-value 'close-button-y))

  ;; spec: (to confirm in-VM) — Close-button behaviour. (presentation-settled probe)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")
  (wait-for-ocr "Undo")

  ;; spec: (to confirm in-VM) — Close-button behaviour. (activate the close control)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y), framebuffer px.
  (click-at close-x close-y)
  ;; spec: (to confirm in-VM) — Close-button behaviour. (settle — give a wrongly
  ;; terminating impl time to exit before the process check; closing emits nothing by
  ;; contract, and a shutdown event observed here at live-run would itself be a
  ;; spec-quality finding)
  (wait 2.0)
  ;; spec: (to confirm in-VM) — Close-button behaviour. (§3.10 / gui-app anchor: the
  ;; window hides but the process keeps running — the recorded expectation)
  (expect-running-app bundle-id))
