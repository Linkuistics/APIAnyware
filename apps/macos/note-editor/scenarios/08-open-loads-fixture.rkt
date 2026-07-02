#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "Open loads a file through the keyboard-driven panel"
  #:description
  "When Open… is activated on a clean document (no alert — §8.5.1 passes it straight through) and the 123-character fixture is chosen keyboard-first (Cmd-Shift-G → absolute path → Return ×2 — the open panel's file cells are not in the AX tree, the k103 rule), then [document] opened fires with the fixture's basename, the preview re-renders exactly the fixture's 123 characters (the open-fidelity witness that needs no editor OCR), its '# FIXTURE NOTE' h1 becomes OCR-readable, the title takes the file's name, and the status begins 'Opened '. One open flow in its own launch."

  ;; run: open-button-x/y — click coordinates (framebuffer px); fixture-path — the in-VM
  ;; absolute path the run stage uploads fixtures/fixture-note.md to (byte-exact: the
  ;; chars=123 bind below is its length). Bound at run time from the per-app run-values
  ;; config (ADR-0011).
  (define open-x (run-value 'open-button-x))
  (define open-y (run-value 'open-button-y))
  (define fixture-path (run-value 'fixture-path))

  ;; spec: §15 — Open loads a file. (presentation-settled probe before the coordinate click)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")
  (wait-for-ocr "Undo")

  ;; spec: §15 — Open loads a file. (activate Open… — clean document, so §8.5.1 skips the
  ;; alert and the panel runs directly; a wrongly-raised alert would strand the keyboard
  ;; drive below)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at open-x open-y)
  ;; spec: §15 — Open loads a file. (the panel is up — 'Cancel' is its discriminating
  ;; affordance, appearing nowhere in the app's own chrome; the pdfkit 05 probe)
  (wait-for-ocr "Cancel" #:timeout 10.0)

  ;; spec: §15 — Open loads a file. (Cmd-Shift-G opens Go-to-Folder — the k103 fixture rule)
  ;; harness: runner/harness-inputs.rkt — chord takes a LIST of modifier symbols then a key.
  (chord '(cmd shift) 'g)
  (wait 1.0)
  ;; spec: §15 — Open loads a file. (the FULL fixture path — the file exists, so Go-to
  ;; selects it; the panel canonicalizes /tmp to /private/tmp, hence the basename-only
  ;; event match below)
  (type fixture-path)
  ;; spec: §15 — Open loads a file. (Return confirms Go-to-Folder, selecting the fixture)
  (press 'return)
  (wait 1.0)
  ;; spec: §15 — Open loads a file. (Return fires the panel's default Open button)
  (press 'return)

  ;; spec: §15 — Open loads a file. (the reliable open-completed cue after the keyboard
  ;; drive — post-state, dirty=false; basename-only, the pdfkit basename rule)
  (wait-for-log #px"\\[document\\] opened path=\"[^\"]*/fixture-note\\.md\" dirty=false"
                #:timeout 15.0)
  ;; spec: §15 — Open loads a file. (the preview re-rendered exactly the fixture's content —
  ;; chars=123 is fixture truth, not an impl value; \\b guards the digit boundary)
  (wait-for-log #px"\\[preview\\] rendered placeholder=false chars=123\\b" #:timeout 10.0)

  ;; spec: §15 — Open loads a file. (settle for the repaint, then the fixture's designed
  ;; OCR marker — h1-rendered large; case-sensitive, so the marker cannot be satisfied by
  ;; body text)
  (wait 0.5)
  (wait-for-ocr "FIXTURE NOTE" #:timeout 10.0)

  ;; spec: §15 — Open loads a file. (title takes the file's name, clean form — exact,
  ;; real U+2014 em dashes)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "fixture-note.md — Note Editor")

  ;; spec: §15 — Open loads a file. (the status begins 'Opened ' — the <path> tail is
  ;; panel-canonicalized, so the stable prefix rides OCR; capital-O 'Opened' is
  ;; case-distinct from the toolbar's 'Open…'; 11-pt small text — adjudicate a garble
  ;; against the opened event above)
  (wait-for-ocr "Opened" #:timeout 10.0))
