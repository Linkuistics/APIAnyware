#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "Cancel keeps everything"
  #:description
  "When New is activated with unsaved edits and the §8.1 alert is dismissed with Cancel, then the command is abandoned with no state change (§8.5.2): the editor text is intact — its heading still rendered in the preview — and the title still carries the '— edited —' form. The confirmation itself discards nothing (§8.1); the cancel path is contract-silent, so the state channels are its observables. One guarded flow in its own launch."

  ;; run: editor-click-x/y, new-button-x/y — click coordinates (framebuffer px);
  ;; alert-cancel-x/y — the alert's Cancel button centre (the run-values' weakest
  ;; projection — re-measure from the open alert at live-run). Bound at run time from the
  ;; per-app run-values config (ADR-0011).
  (define editor-x (run-value 'editor-click-x))
  (define editor-y (run-value 'editor-click-y))
  (define new-x (run-value 'new-button-x))
  (define new-y (run-value 'new-button-y))
  (define cancel-x (run-value 'alert-cancel-x))
  (define cancel-y (run-value 'alert-cancel-y))

  ;; spec: §15 — Boundary — Cancel keeps everything. (presentation-settled probe)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")
  (wait-for-ocr "Undo")

  ;; spec: §15 — Boundary — Cancel keeps everything. (make the document dirty)
  (click-at editor-x editor-y)
  (wait 0.5)
  (type "# Hello")
  ;; spec: §15 — Boundary — Cancel keeps everything. (settle after type before the button
  ;; click — the k121 race)
  (wait-for-log #px"\\[preview\\] rendered placeholder=false chars=7\\b" #:timeout 10.0)

  ;; spec: §15 — Boundary — Cancel keeps everything. (activate New — the guard fires)
  (click-at new-x new-y)
  ;; spec: §15 — Boundary — Cancel keeps everything. (the New alert is up — its
  ;; trigger-specific message)
  (wait-for-ocr "start a new note" #:timeout 10.0)

  ;; spec: §15 — Boundary — Cancel keeps everything. (choose Cancel — clicked at
  ;; AX-reported coordinates per the driver guidance; Return would fire Discard, the
  ;; default)
  (click-at cancel-x cancel-y)
  (wait 1.0)

  ;; spec: §15 — Boundary — Cancel keeps everything. (the text is intact — the heading is
  ;; still rendered on the live screen)
  (expect-ocr "Hello")
  ;; spec: §15 — Boundary — Cancel keeps everything. (the title still contains 'edited' —
  ;; exact §6.1 dirty form, real U+2014 em dashes)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "Untitled — edited — Note Editor"))
