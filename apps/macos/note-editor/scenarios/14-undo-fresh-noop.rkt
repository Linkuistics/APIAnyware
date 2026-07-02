#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "Undo on a fresh document is a no-op"
  #:description
  "When Undo is activated at launch, before any edit, then nothing changes and the app keeps running: canUndo is false so the §9 rule does nothing — the title keeps its exact launch form and the process survives (§8.5.8). The no-op is contract-silent; event silence is never asserted — the unchanged state channels are the observables. One boundary flow in its own launch."

  ;; run: bundle-id — bound at run time from the impl descriptor (ADR-0011);
  ;; undo-button-x/y — click coordinates (framebuffer px) from the per-app run-values
  ;; config.
  (define bundle-id (run-value 'bundle-id))
  (define undo-x (run-value 'undo-button-x))
  (define undo-y (run-value 'undo-button-y))

  ;; spec: §15 — Boundary — Undo on a fresh document is a no-op. (presentation-settled
  ;; probe)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")
  (wait-for-ocr "Undo")

  ;; spec: §15 — Boundary — Undo on a fresh document is a no-op. (activate Undo with an
  ;; empty undo stack)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at undo-x undo-y)
  ;; spec: §15 — Boundary — Undo on a fresh document is a no-op. (settle — give a wrongly
  ;; mutating impl time to show it)
  (wait 1.0)

  ;; spec: §15 — Boundary — Undo on a fresh document is a no-op. (the title is unchanged —
  ;; exact launch form, real U+2014 em dashes)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "Untitled — Note Editor")
  ;; spec: §15 — Boundary — Undo on a fresh document is a no-op. (the app keeps running)
  (expect-running-app bundle-id))
