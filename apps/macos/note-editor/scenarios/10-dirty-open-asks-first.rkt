#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "dirty Open asks first"
  #:description
  "When Open… is activated with unsaved edits, then the §8.1 warning alert runs first, carrying the Open-specific message 'Discard unsaved changes?' with Discard and Cancel buttons (the trigger-specific message is what distinguishes this alert from New's). The alert is then dismissed with Cancel — the §8.1 abandon path: the command is abandoned with no state change, the title keeps the '— edited —' form and the typed heading stays rendered in the preview. The alert emits nothing (a synchronous response to the runner's own click — contract), so its presence rides OCR + the k80-firmed AX shape (an extra window titled 'alert'). One guarded flow in its own launch."

  ;; run: editor-click-x/y, open-button-x/y — click coordinates (framebuffer px);
  ;; alert-cancel-x/y — the alert's Cancel button centre (the run-values' weakest
  ;; projection — re-measure from the open alert at live-run). Bound at run time from the
  ;; per-app run-values config (ADR-0011).
  (define editor-x (run-value 'editor-click-x))
  (define editor-y (run-value 'editor-click-y))
  (define open-x (run-value 'open-button-x))
  (define open-y (run-value 'open-button-y))
  (define cancel-x (run-value 'alert-cancel-x))
  (define cancel-y (run-value 'alert-cancel-y))

  ;; spec: §15 — Boundary — dirty Open asks first. (presentation-settled probe)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")
  (wait-for-ocr "Undo")

  ;; spec: §15 — Boundary — dirty Open asks first. (make the document dirty)
  (click-at editor-x editor-y)
  (wait 0.5)
  (type "# Hello")
  ;; spec: §15 — Boundary — dirty Open asks first. (settle after type before the button
  ;; click — the k121 race)
  (wait-for-log #px"\\[preview\\] rendered placeholder=false chars=7\\b" #:timeout 10.0)

  ;; spec: §15 — Boundary — dirty Open asks first. (activate Open… — the guard fires
  ;; before any panel)
  (click-at open-x open-y)
  ;; spec: §15 — Boundary — dirty Open asks first. (the Open-specific message text —
  ;; app-authored deterministic string, system-size alert chrome, good OCR odds)
  (wait-for-ocr "Discard unsaved changes" #:timeout 10.0)
  ;; spec: §15 — Boundary — dirty Open asks first. (the k80/k121-firmed alert AX shape:
  ;; an extra window titled 'alert' carrying the two §8.1 buttons)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "alert")
  ;; spec: §15 — Boundary — dirty Open asks first. (Discard, added first, is the default)
  (expect-ax #:role 'AXButton #:title "Discard")
  ;; spec: §15 — Boundary — dirty Open asks first.
  (expect-ax #:role 'AXButton #:title "Cancel")

  ;; spec: §15 — Boundary — dirty Open asks first. (dismiss with Cancel — the §8.1 abandon
  ;; path: 'any other outcome abandons the operation with no state change'; clicked at
  ;; AX-reported coordinates per the driver guidance, Escape-for-Cancel stays the
  ;; to-confirm fallback)
  (click-at cancel-x cancel-y)
  (wait 1.0)
  ;; spec: §15 — Boundary — dirty Open asks first. (no state change: the document is still
  ;; dirty — exact §6.1 dirty form)
  (expect-ax #:role 'AXWindow #:title "Untitled — edited — Note Editor")
  ;; spec: §15 — Boundary — dirty Open asks first. (the typed heading is still rendered —
  ;; the live-screen witness that the editor kept its text)
  (expect-ocr "Hello"))
