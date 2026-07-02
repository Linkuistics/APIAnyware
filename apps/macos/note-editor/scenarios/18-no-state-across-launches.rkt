#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "no state across launches"
  #:description
  "When the app is killed and relaunched after a successful save, then it starts fresh at 'Untitled — Note Editor' with an empty editor and the placeholder preview — no autosave, no reopened document, no MRU (§14: the only persistence is an explicit Save). The post-restart reads ride the live channels only (AX title, OCR): the fresh launch's log lines are byte-identical to the first launch's already in the accumulated buffer, so no post-restart log pattern is discriminating (the accumulated-buffer rule). One lifecycle flow in its own launch; requires a fresh work/ (run-values prep)."

  ;; run: bundle-id — bound at run time from the impl descriptor (ADR-0011);
  ;; editor-click-x/y, save-button-x/y, work-dir — from the per-app run-values config.
  (define bundle-id (run-value 'bundle-id))
  (define editor-x (run-value 'editor-click-x))
  (define editor-y (run-value 'editor-click-y))
  (define save-x (run-value 'save-button-x))
  (define save-y (run-value 'save-button-y))
  (define work-dir (run-value 'work-dir))

  ;; ── setup: give the pre-restart instance real state — edits AND a saved path ──
  ;; spec: §15 — No state across launches. (presentation-settled probe)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")
  (wait-for-ocr "Undo")
  (click-at editor-x editor-y)
  (wait 0.5)
  (type "# Hello")
  (wait-for-log #px"\\[preview\\] rendered placeholder=false chars=7\\b" #:timeout 10.0)
  (click-at save-x save-y)
  (wait-for-ocr "untitled" #:timeout 10.0)
  ;; harness: runner/harness-inputs.rkt — chord takes a LIST of modifier symbols then a key.
  (chord '(cmd shift) 'g)
  (wait 1.0)
  (type work-dir)
  (press 'return)
  (wait 1.0)
  (press 'return)
  (wait-for-log #px"\\[document\\] saved path=\"[^\"]*/untitled\\.md\" dirty=false"
                #:timeout 15.0)
  ;; spec: §15 — No state across launches. (the saved state is in place — title shows the
  ;; file's name before the restart)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "untitled.md — Note Editor")

  ;; spec: §15 — No state across launches. (kill and relaunch — restart-impl! is the
  ;; driver's quit → relaunch → wait-ready sequence)
  ;; harness: runner/harness-state.rkt — (restart-impl!).
  (restart-impl!)
  ;; spec: §15 — No state across launches. (settle the fresh presentation)
  (wait 1.0)

  ;; spec: §15 — No state across launches. (the fresh instance is up)
  (expect-running-app bundle-id)
  ;; spec: §15 — No state across launches. (starts at Untitled — exact launch form, NOT
  ;; the saved file's name; real U+2014 em dashes)
  (expect-ax #:role 'AXWindow #:title "Untitled — Note Editor")
  ;; spec: §15 — No state across launches. (empty editor → the placeholder preview is on
  ;; the live screen — the pre-restart screen showed the rendered heading instead)
  (wait-for-ocr "Start typing Markdown" #:timeout 10.0))
