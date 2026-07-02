#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "a file saved by the app and re-opened shows identical content"
  #:description
  "When typed content is saved through the sheet, the document is cleared with New, and the saved file is re-opened through the panel, then the content survives the disk round-trip: the saved bytes contain exactly what was typed (read-file ground truth), and after re-opening, the '# ROUND TRIP' h1 renders in the preview again and the title takes the file's name. New on the just-saved (clean) document passes §8.5.1 without an alert — its [document] new event is the cue. The re-open's rendered chars line (32) is byte-identical to the typing flow's final line and is deliberately NOT matched (accumulated-buffer rule); the opened event plus the live OCR read carry the re-open witness. One round-trip flow in its own launch; requires a fresh work/ (run-values prep)."

  ;; run: editor-click-x/y, save-button-x/y, new-button-x/y, open-button-x/y — click
  ;; coordinates (framebuffer px); work-dir / work-file — the in-VM scratch paths. Bound at
  ;; run time from the per-app run-values config (ADR-0011).
  (define editor-x (run-value 'editor-click-x))
  (define editor-y (run-value 'editor-click-y))
  (define save-x (run-value 'save-button-x))
  (define save-y (run-value 'save-button-y))
  (define new-x (run-value 'new-button-x))
  (define new-y (run-value 'new-button-y))
  (define open-x (run-value 'open-button-x))
  (define open-y (run-value 'open-button-y))
  (define work-dir (run-value 'work-dir))
  (define work-file (run-value 'work-file))

  ;; spec: §15 — Round-trip. (presentation-settled probe before the coordinate click)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")
  (wait-for-ocr "Undo")

  ;; ── type the marker content: '# ROUND TRIP\nSaved and reopened.' — 32 characters ──
  ;; spec: §15 — Round-trip. (the content whose survival the round-trip asserts)
  (click-at editor-x editor-y)
  (wait 0.5)
  (type "# ROUND TRIP")
  (press 'return)
  (type "Saved and reopened.")
  ;; spec: §15 — Round-trip. (settle after type before the button click — the k121 race)
  (wait-for-log #px"\\[preview\\] rendered placeholder=false chars=32\\b" #:timeout 10.0)

  ;; ── save through the sheet (the §8.4 sheet branch, asserted in 04) ──
  ;; spec: §15 — Round-trip. (Save… → sheet → Cmd-Shift-G → work/ → Return ×2)
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
  ;; spec: §15 — Round-trip. (the saved bytes contain exactly what was typed — the disk
  ;; half of the round-trip)
  ;; harness: runner/harness-state.rkt — read-file returns BYTES via in-guest cat.
  (let ([content (bytes->string/utf-8 (read-file work-file))])
    (unless (and (regexp-match? #rx"# ROUND TRIP" content)
                 (regexp-match? #rx"Saved and reopened\\." content))
      (error 'round-trip-content
             "saved file does not contain the typed text: ~v" content)))

  ;; ── clear with New (clean document — no alert, §8.5.1) ──
  ;; spec: §15 — Round-trip. (New proceeds directly on the clean just-saved document; its
  ;; event is the cue that the editor emptied and the preview re-rendered the placeholder)
  (click-at new-x new-y)
  (wait-for-log #px"\\[document\\] new path=\"\" dirty=false" #:timeout 10.0)
  (wait 0.5)
  ;; spec: §15 — Round-trip. (the placeholder is back on the live screen — the typed
  ;; content is gone before the re-open proves it comes back from disk)
  (wait-for-ocr "Start typing Markdown" #:timeout 10.0)

  ;; ── re-open the saved file through the panel (the k103 keyboard drive) ──
  ;; spec: §15 — Round-trip. (Open… → Cmd-Shift-G → the saved file → Return ×2)
  (click-at open-x open-y)
  (wait-for-ocr "Cancel" #:timeout 10.0)
  (chord '(cmd shift) 'g)
  (wait 1.0)
  (type work-file)
  (press 'return)
  (wait 1.0)
  (press 'return)
  ;; spec: §15 — Round-trip. (the re-open completes — post-state; basename-only match)
  (wait-for-log #px"\\[document\\] opened path=\"[^\"]*/untitled\\.md\" dirty=false"
                #:timeout 15.0)
  ;; spec: §15 — Round-trip. (settle for the repaint, then the marker h1 renders AGAIN —
  ;; the live screen showed the placeholder immediately before this, so the read is
  ;; discriminating)
  (wait 0.5)
  (wait-for-ocr "ROUND TRIP" #:timeout 10.0)
  ;; spec: §15 — Round-trip. (title takes the re-opened file's name — exact, real U+2014
  ;; em dashes)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "untitled.md — Note Editor"))
