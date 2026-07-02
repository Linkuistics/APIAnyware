#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: quit with unsaved edits neither asks nor saves"
  #:description
  "When Command-Q is sent with unsaved edits, then per §3.10 the terminate path is expected to run unguarded — the §8.1 confirmation covers New and Open ONLY: shutdown reason=menu is logged and the process exits. recording: §3.10/§8.5.10 flag this (to confirm in-VM, explicitly flagged for human confirmation) — anchored on §3's termination model (no application delegate consults the dirty flag) and the gui-app app-kind. The no-alert half is witnessed by the terminate completing: a wrongly-raised modal alert would swallow the chord's effect and no shutdown event could fire — the wait would time out (a direct post-chord AX read would race the exiting process, so the event is the discriminating channel). The 'edits are not on disk anywhere' half is a documented gap: an unbounded absence with no keyable path — no path was ever presented to the impl in this flow, so any expect-file #:absent? would pass by construction. A PASS confirms §3.10 and reverse-gen may drop the marker; a FAILURE (an alert, a survival) is a spec-quality finding, not a suite bug — the runner captures artifacts for review."

  ;; run: bundle-id — bound at run time from the impl descriptor (ADR-0011);
  ;; editor-click-x/y — from the per-app run-values config.
  (define bundle-id (run-value 'bundle-id))
  (define editor-x (run-value 'editor-click-x))
  (define editor-y (run-value 'editor-click-y))

  ;; spec: (to confirm in-VM) — Boundary — quit with unsaved edits neither asks nor saves.
  ;; (presentation-settled probe)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")
  (wait-for-ocr "Undo")

  ;; spec: (to confirm in-VM) — Boundary — quit with unsaved edits neither asks nor saves.
  ;; (make the document dirty)
  (click-at editor-x editor-y)
  (wait 0.5)
  (type "# Hello")
  ;; spec: (to confirm in-VM) — Boundary — quit with unsaved edits neither asks nor saves.
  ;; (settle after type before the chord — the k121 race)
  (wait-for-log #px"\\[preview\\] rendered placeholder=false chars=7\\b" #:timeout 10.0)

  ;; spec: (to confirm in-VM) — Boundary — quit with unsaved edits neither asks nor saves.
  ;; (Command-Q on the dirty document — steady state, no modal open)
  ;; harness: runner/harness-inputs.rkt — chord takes a LIST of modifier symbols then a key.
  (chord '(cmd) 'q)
  ;; spec: (to confirm in-VM) — Boundary — quit with unsaved edits neither asks nor saves.
  ;; (the unguarded terminate completes — §3.10; an alert would block this event, making
  ;; the timeout the no-alert catch)
  (wait-for-log #px"\\[lifecycle\\] shutdown reason=menu" #:timeout 10.0)
  (wait 1.0)
  ;; spec: (to confirm in-VM) — Boundary — quit with unsaved edits neither asks nor saves.
  ;; (the process is gone)
  ;; harness: runner/harness-observations.rkt — #:running? #f asserts the app is not
  ;; running.
  (expect-running-app bundle-id #:running? #f))
