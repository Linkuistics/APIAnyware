#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "dirty New asks first; Discard clears everything"
  #:description
  "When New is activated with unsaved edits, then the §8.1 warning alert runs with the New-specific message 'Discard unsaved changes and start a new note?'; when Return fires its default Discard button (first-added, hence default — the §15 driver guidance), then the §8.2 rule runs whole: the editor empties, the preview returns to the placeholder, the status reads 'New document', and the title returns to 'Untitled — Note Editor' with the dirty flag cleared — witnessed post-state by [document] new path=\"\" dirty=false. One guarded flow in its own launch."

  ;; run: editor-click-x/y, new-button-x/y — click coordinates (framebuffer px). Bound at
  ;; run time from the per-app run-values config (ADR-0011).
  (define editor-x (run-value 'editor-click-x))
  (define editor-y (run-value 'editor-click-y))
  (define new-x (run-value 'new-button-x))
  (define new-y (run-value 'new-button-y))

  ;; spec: §15 — Dirty New asks first. (presentation-settled probe)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")
  (wait-for-ocr "Undo")

  ;; spec: §15 — Dirty New asks first. (make the document dirty)
  (click-at editor-x editor-y)
  (wait 0.5)
  (type "# Hello")
  ;; spec: §15 — Dirty New asks first. (settle after type before the button click — the
  ;; k121 race)
  (wait-for-log #px"\\[preview\\] rendered placeholder=false chars=7\\b" #:timeout 10.0)

  ;; spec: §15 — Dirty New asks first. (activate New — the guard fires)
  (click-at new-x new-y)
  ;; spec: §15 — Dirty New asks first. (the New-specific message text — the trigger-specific
  ;; tail distinguishes it from the Open alert; app-authored deterministic string)
  (wait-for-ocr "start a new note" #:timeout 10.0)

  ;; spec: §15 — Discard clears everything. (Return fires the default Discard — press
  ;; Return for an alert's default button, never click; §15 driver guidance)
  ;; harness: runner/harness-inputs.rkt — press takes a key symbol.
  (press 'return)

  ;; spec: §15 — Discard clears everything. (the §8.2 rule ran whole — post-state event;
  ;; path clears to empty, dirty to false; the mid-rule placeholder re-render precedes this
  ;; event by contract, so no separate rendered match is needed — the launch buffer already
  ;; holds a byte-identical placeholder line, the accumulated-buffer rule)
  (wait-for-log #px"\\[document\\] new path=\"\" dirty=false" #:timeout 10.0)
  ;; spec: §15 — Discard clears everything. (status — exact via the value→AXTitle fold,
  ;; the firm 11-pt channel)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXStaticText #:title "New document")
  ;; spec: §15 — Discard clears everything. (settle for the repaint, then the placeholder
  ;; is back on the live screen — the preview returned to empty)
  (wait 0.5)
  (wait-for-ocr "Start typing Markdown" #:timeout 10.0)
  ;; spec: §15 — Discard clears everything. (the title returns to the clean launch form —
  ;; exact, real U+2014 em dashes)
  (expect-ax #:role 'AXWindow #:title "Untitled — Note Editor"))
