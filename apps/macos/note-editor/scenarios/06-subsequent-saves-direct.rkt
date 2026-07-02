#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "subsequent saves are direct — no sheet"
  #:description
  "When a document that already has a path (first-saved through the sheet as setup) is re-dirtied and Save… is activated again, then the write is a direct overwrite with no panel (§8.4 — the direct branch): with no sheet interaction whatsoever, the title cleans back to 'untitled.md — Note Editor' and the file's bytes update to the edited text. The no-sheet witness is indirect but discriminating: no Return is ever sent after the second Save… click, so had a sheet appeared the save could not complete — the title would stay '— edited —' and the content stale, failing both reads (the sheet's own AX role is a k123 provisional row, so its absence is not directly assertable yet). Requires a fresh work/ (run-values prep). One save flow in its own launch."

  ;; run: editor-click-x/y, save-button-x/y — click coordinates (framebuffer px); work-dir /
  ;; work-file — the in-VM scratch paths. Bound at run time from the per-app run-values
  ;; config (ADR-0011).
  (define editor-x (run-value 'editor-click-x))
  (define editor-y (run-value 'editor-click-y))
  (define save-x (run-value 'save-button-x))
  (define save-y (run-value 'save-button-y))
  (define work-dir (run-value 'work-dir))
  (define work-file (run-value 'work-file))

  ;; ── setup: the §8.4 sheet branch gives the document a path (asserted in 04) ──
  ;; spec: §15 — Subsequent saves are direct. (presentation-settled probe)
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
  (wait 0.5)

  ;; spec: §15 — Subsequent saves are direct. (re-dirty: re-focus the editor — after the
  ;; sheet had key the first click may only re-activate, the k112 rule; the 1s gap keeps
  ;; the two clicks below the system double-click threshold apart)
  (click-at editor-x editor-y)
  (wait 1.0)
  (click-at editor-x editor-y)
  (wait 0.5)
  ;; spec: §15 — Subsequent saves are direct. (append — the insertion point sits at the
  ;; text end after a click past it)
  (type " more")
  ;; spec: §15 — Subsequent saves are direct. (the re-dirty flip — discriminating from
  ;; the first dirty-changed, which carried path=\"\"; now the path is set)
  (wait-for-log #px"\\[document\\] dirty-changed path=\"[^\"]*/untitled\\.md\" dirty=true"
                #:timeout 10.0)
  ;; spec: §15 — Subsequent saves are direct. (title takes the dirty form again — exact)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "untitled.md — edited — Note Editor")
  ;; spec: §15 — Subsequent saves are direct. (settle after type before the button click —
  ;; the k121 race; '# Hello more' is 12 characters)
  (wait-for-log #px"\\[preview\\] rendered placeholder=false chars=12\\b" #:timeout 10.0)

  ;; spec: §15 — Subsequent saves are direct. (the second Save… — the direct branch; no
  ;; Return follows, so a wrongly-appearing sheet would strand the flow and fail the reads
  ;; below)
  (click-at save-x save-y)
  ;; spec: §15 — Subsequent saves are direct. (the direct write is synchronous main-thread
  ;; code — settle, then read; the second saved event line is byte-identical to the setup's
  ;; and is deliberately NOT matched — never count events, the logging-contract rule)
  (wait 1.5)
  ;; spec: §15 — Subsequent saves are direct. (the title cleans — the completion witness)
  (expect-ax #:role 'AXWindow #:title "untitled.md — Note Editor")
  ;; spec: §15 — Subsequent saves are direct. (the file's content updated to the edit)
  ;; harness: runner/harness-state.rkt — read-file returns BYTES via in-guest cat.
  (let ([content (bytes->string/utf-8 (read-file work-file))])
    (unless (regexp-match? #rx"# Hello more" content)
      (error 'direct-save-content
             "work file does not contain the edited text: ~v" content))))
