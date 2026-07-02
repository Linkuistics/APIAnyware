#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: write failure surfaces on the status line"
  #:description
  "When the save sheet is driven to the SIP-protected /System directory (Cmd-Shift-G) and Save is fired, then the §8.5.7 write-failure path is expected: [document] save-failed fires with the attempted path and dirty=true, the status begins 'Save failed', and the dirty title persists. recording: §15 marks this line (to confirm in-VM) and calls it hard to drive through the system panel — anchored on §8.5.7 (code-witnessed in every impl) and the §8 abstract-write rule. A PASS confirms the sheet lets an unwritable target through to the app's write; a FAILURE is a drivability/spec-quality finding (the panel may pre-validate writability and never return OK — a known platform possibility), not an impl defect or suite bug — the runner captures artifacts for review."

  ;; run: editor-click-x/y, save-button-x/y — click coordinates (framebuffer px);
  ;; unwritable-dir — the SIP-protected target. Bound at run time from the per-app
  ;; run-values config (ADR-0011).
  (define editor-x (run-value 'editor-click-x))
  (define editor-y (run-value 'editor-click-y))
  (define save-x (run-value 'save-button-x))
  (define save-y (run-value 'save-button-y))
  (define unwritable-dir (run-value 'unwritable-dir))

  ;; spec: (to confirm in-VM) — Boundary — write failure surfaces on the status line.
  ;; (presentation-settled probe)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")
  (wait-for-ocr "Undo")

  ;; spec: (to confirm in-VM) — Boundary — write failure surfaces on the status line.
  ;; (a dirty Untitled document reaches the sheet branch)
  (click-at editor-x editor-y)
  (wait 0.5)
  (type "# Hello")
  ;; spec: (to confirm in-VM) — Boundary — write failure surfaces on the status line.
  ;; (settle after type before the button click — the k121 race)
  (wait-for-log #px"\\[preview\\] rendered placeholder=false chars=7\\b" #:timeout 10.0)
  (click-at save-x save-y)
  (wait-for-ocr "untitled" #:timeout 10.0)

  ;; spec: (to confirm in-VM) — Boundary — write failure surfaces on the status line.
  ;; (drive the sheet to the unwritable directory; the prefilled untitled.md supplies the
  ;; attempted filename)
  ;; harness: runner/harness-inputs.rkt — chord takes a LIST of modifier symbols then a key.
  (chord '(cmd shift) 'g)
  (wait 1.0)
  (type unwritable-dir)
  (press 'return)
  (wait 1.0)
  ;; spec: (to confirm in-VM) — Boundary — write failure surfaces on the status line.
  ;; (Return fires the sheet's default Save on the /System target)
  (press 'return)

  ;; spec: (to confirm in-VM) — Boundary — write failure surfaces on the status line. (the
  ;; normalized failure channel — attempted path + the unchanged dirty=true flag;
  ;; basename-only match)
  (wait-for-log #px"\\[document\\] save-failed path=\"[^\"]*/untitled\\.md\" dirty=true"
                #:timeout 15.0)
  ;; spec: (to confirm in-VM) — Boundary — write failure surfaces on the status line. (the
  ;; stable visible prefix — colon-free per the k121 OCR-punctuation finding; the <detail>
  ;; tail is impl-realized and never bound)
  (wait-for-ocr "Save failed" #:timeout 10.0)
  ;; spec: (to confirm in-VM) — Boundary — write failure surfaces on the status line. (the
  ;; dirty title persists — exact §6.1 dirty form)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "Untitled — edited — Note Editor"))
