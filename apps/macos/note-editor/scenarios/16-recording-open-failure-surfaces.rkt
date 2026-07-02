#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: read failure surfaces on the status line"
  #:description
  "When the mode-000 locked fixture is chosen through the open panel (Cmd-Shift-G — the run stage uploads fixtures/locked.md and chmods it 000 in-guest), then the §8.5.6 read-failure path is expected: [document] open-failed fires with the attempted path and the unchanged dirty flag, the status begins 'Open failed', and the editor keeps its (empty) text — title unchanged, placeholder still rendered. recording: §15 marks this line (to confirm in-VM) and calls it hard to drive through the panel — anchored on §8.5.6 (the failure path is code-witnessed in every impl) and on the §8 abstract-read rule. A PASS confirms the panel will select an unreadable file and the drive is viable; a FAILURE is a drivability/spec-quality finding (e.g. the panel refusing or pre-validating the selection), not an impl defect or suite bug — the runner captures artifacts for review."

  ;; run: open-button-x/y — click coordinates (framebuffer px); locked-fixture-path — the
  ;; in-VM mode-000 fixture the run stage prepares. Bound at run time from the per-app
  ;; run-values config (ADR-0011).
  (define open-x (run-value 'open-button-x))
  (define open-y (run-value 'open-button-y))
  (define locked-path (run-value 'locked-fixture-path))

  ;; spec: (to confirm in-VM) — Boundary — read failure surfaces on the status line.
  ;; (presentation-settled probe)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")
  (wait-for-ocr "Undo")

  ;; spec: (to confirm in-VM) — Boundary — read failure surfaces on the status line.
  ;; (clean document — §8.5.1 skips the alert; the panel runs directly)
  (click-at open-x open-y)
  (wait-for-ocr "Cancel" #:timeout 10.0)
  ;; spec: (to confirm in-VM) — Boundary — read failure surfaces on the status line.
  ;; (the k103 keyboard drive to the unreadable file)
  ;; harness: runner/harness-inputs.rkt — chord takes a LIST of modifier symbols then a key.
  (chord '(cmd shift) 'g)
  (wait 1.0)
  (type locked-path)
  (press 'return)
  (wait 1.0)
  (press 'return)

  ;; spec: (to confirm in-VM) — Boundary — read failure surfaces on the status line. (the
  ;; normalized failure channel — the event carries the ATTEMPTED path and the unchanged
  ;; dirty flag; basename-only, the pdfkit basename rule)
  (wait-for-log #px"\\[document\\] open-failed path=\"[^\"]*/locked\\.md\" dirty=false"
                #:timeout 15.0)
  ;; spec: (to confirm in-VM) — Boundary — read failure surfaces on the status line. (the
  ;; stable visible prefix — asserted colon-free: OCR drops punctuation deterministically
  ;; on some impls, the k121 finding; the <detail> tail is impl-realized and never bound)
  (wait-for-ocr "Open failed" #:timeout 10.0)
  ;; spec: (to confirm in-VM) — Boundary — read failure surfaces on the status line. (the
  ;; editor keeps its text: model untouched by rule — title still the exact launch form)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "Untitled — Note Editor")
  ;; spec: (to confirm in-VM) — Boundary — read failure surfaces on the status line. (no
  ;; render was triggered — the placeholder is still on the live screen)
  (expect-ocr "Start typing Markdown"))
