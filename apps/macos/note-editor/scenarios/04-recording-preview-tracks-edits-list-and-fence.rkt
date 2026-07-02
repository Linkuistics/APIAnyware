#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: the preview tracks continuous edits; list items and fences render"
  #:description
  "While the user keeps typing — a heading, a paragraph, a '*'-marked list item, and a fenced code block — the preview re-renders on every change without any other action: the final [preview] rendered chars=59 hand-off is logged (the firm behavioural half, asserted inside this recording) and the appended list-item, fence, and paragraph text become OCR-readable. recording: §15 marks the tracks-edits and list-and-fence OCR reads (to confirm in-VM) — body-size preview text is exactly the k103 class that garbled on all four impls in mini-browser — anchored on §6.2 step 2 (always re-render) and §7.2 rules 2/4/6. A PASS confirms the reads and reverse-gen may drop the markers; a FAILURE with the chars=59 event present is a run-mechanism finding, not an impl defect — the runner captures artifacts for review. The list marker is typed as '*' (spec §7.2 accepts -, *, or +): the driver CLI cannot receive leading-dash text (the SDK passes type's text as a bare argv with no -- terminator — a reported run-capability gap), and the '- alpha item'/'- beta item' dash form is exercised by the 08 fixture instead. One editing flow in its own launch."

  ;; run: editor-click-x/y — a point inside the editor pane (framebuffer px); bound at run
  ;; time from the per-app run-values config (ADR-0011).
  (define editor-x (run-value 'editor-click-x))
  (define editor-y (run-value 'editor-click-y))

  ;; spec: §15 — Launch diagnostic is emitted. (presentation-settled probe before the click)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")
  ;; spec: §15 — Toolbar is present. (render-settled probe)
  (wait-for-ocr "Undo")

  ;; spec: (to confirm in-VM) — The preview tracks continuous edits. (focus the editor)
  (click-at editor-x editor-y)
  (wait 0.5)
  ;; spec: (to confirm in-VM) — The preview tracks continuous edits. (the heading line; Return in the
  ;; focused text view inserts a newline — no default button exists in the window to
  ;; swallow it)
  (type "# Hello")
  (press 'return)
  ;; spec: (to confirm in-VM) — The preview tracks continuous edits. (a paragraph line appended)
  (type "A plain paragraph.")
  (press 'return)
  ;; spec: (to confirm in-VM) — List and fence rendering. (the '*' §7.2 list marker — see #:description)
  (type "* first item")
  (press 'return)
  ;; spec: (to confirm in-VM) — List and fence rendering. (fence open)
  (type "```")
  (press 'return)
  ;; spec: (to confirm in-VM) — List and fence rendering. (the fenced line — emitted verbatim, §7.2 rule 1)
  (type "fenced code")
  (press 'return)
  ;; spec: (to confirm in-VM) — List and fence rendering. (fence close)
  (type "```")

  ;; spec: (to confirm in-VM) — The preview tracks continuous edits. (the final hand-off: the full typed
  ;; content is 59 characters — 7+18+12+3+11+3 across six lines + 5 newlines; matching the
  ;; final chars line is the settle-after-type probe, never a count)
  (wait-for-log #px"\\[preview\\] rendered placeholder=false chars=59\\b" #:timeout 15.0)
  ;; spec: (to confirm in-VM) — The preview tracks continuous edits. (settle for the repaint)
  (wait 0.5)
  ;; spec: (to confirm in-VM) — List and fence rendering. (the list item's text in the rendered preview —
  ;; body-size, adjudicate-by-artifact if garbled; case-sensitive substring)
  (wait-for-ocr "first item" #:timeout 10.0)
  ;; spec: (to confirm in-VM) — List and fence rendering. (the fenced block's text — monospace on the
  ;; light-gray block, §7 template; body-size, adjudicate-by-artifact)
  (wait-for-ocr "fenced code" #:timeout 10.0)
  ;; spec: (to confirm in-VM) — The preview tracks continuous edits. (the appended paragraph — dual
  ;; witness with the chars=59 hand-off above; body-size, adjudicate-by-artifact)
  (wait-for-ocr "plain paragraph" #:timeout 10.0))
