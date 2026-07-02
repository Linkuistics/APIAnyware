#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "cancelling the save sheet changes nothing"
  #:description
  "When the save sheet is raised on a dirty Untitled document and dismissed with Escape, then no file is written and the document stays dirty: the window title keeps the '— edited —' form and work/untitled.md does not exist (§8.5.4 — the sheet-cancel boundary; the cancel path is contract-silent, and event absence is never asserted). Escape-cancels-the-panel is the pdfkit 04 firmed precedent for the open panel, presumed for the sheet. The #:absent? read relies on the fresh work/ the run stage prepares per scenario (run-values prep). One boundary flow in its own launch."

  ;; run: editor-click-x/y, save-button-x/y — click coordinates (framebuffer px);
  ;; work-file — the path that must NOT appear. Bound at run time from the per-app
  ;; run-values config (ADR-0011).
  (define editor-x (run-value 'editor-click-x))
  (define editor-y (run-value 'editor-click-y))
  (define save-x (run-value 'save-button-x))
  (define save-y (run-value 'save-button-y))
  (define work-file (run-value 'work-file))

  ;; spec: §15 — Boundary — cancelling the sheet changes nothing. (presentation-settled
  ;; probe before the coordinate click)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")
  (wait-for-ocr "Undo")

  ;; spec: §15 — Boundary — cancelling the sheet changes nothing. (make the document dirty)
  (click-at editor-x editor-y)
  (wait 0.5)
  (type "# Hello")
  ;; spec: §15 — Boundary — cancelling the sheet changes nothing. (settle after type before
  ;; the button click — the k121 race)
  (wait-for-log #px"\\[preview\\] rendered placeholder=false chars=7\\b" #:timeout 10.0)

  ;; spec: §15 — Boundary — cancelling the sheet changes nothing. (raise the sheet)
  (click-at save-x save-y)
  ;; spec: §15 — Boundary — cancelling the sheet changes nothing. (the sheet is up — the
  ;; prefilled name field; lowercase, case-distinct from the title bar's 'Untitled')
  (wait-for-ocr "untitled" #:timeout 10.0)

  ;; spec: §15 — Boundary — cancelling the sheet changes nothing. (Escape dismisses the
  ;; sheet — the §15 realization; pdfkit 04 firmed Escape on the open panel)
  ;; harness: runner/harness-inputs.rkt — press takes a key symbol.
  (press 'escape)
  ;; spec: §15 — Boundary — cancelling the sheet changes nothing. (settle the dismissal)
  (wait 1.0)

  ;; spec: §15 — Boundary — cancelling the sheet changes nothing. (the document stays
  ;; dirty — exact §6.1 dirty form, real U+2014 em dashes)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "Untitled — edited — Note Editor")
  ;; spec: §15 — Boundary — cancelling the sheet changes nothing. (no file was written —
  ;; grounded on the run stage's fresh work/ per scenario)
  ;; harness: runner/harness-observations.rkt — expect-file #:absent? inverts the sense.
  (expect-file work-file #:absent? #t))
