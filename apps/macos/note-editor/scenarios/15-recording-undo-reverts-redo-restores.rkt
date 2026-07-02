#lang app-spec
;; forward-generated from Note Editor §15 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: undo reverts typing; redo restores it"
  #:description
  "When Undo is activated repeatedly after typing '# Hello', then the text system's undo is expected to revert the typing — returning the preview to the placeholder — and Redo to re-apply it, bringing 'Hello' back. recording: §15 marks the undo grouping granularity and §9 the notification-on-undo coupling (to confirm in-VM) — anchored on §5.3 allowsUndo + the §9 delegated-undo rule, the buttons drive NSTextView's own undo manager and an undone edit is expected to ride the same §6.2 change path as typing. Eight clicks per direction over-shoot any grouping (extras are §8.5.8 no-ops); the live screen (placeholder gone→back→gone) is the discriminating channel — the undo-to-empty rendered line is byte-identical to the launch's and is deliberately NOT matched. A PASS confirms the coupling and grouping reachability (reverse-gen may drop the markers, recording actuals); a FAILURE is a spec-quality finding about §9's platform coupling, not a suite bug — the runner captures artifacts for review. The dirty flag never clears on undo (§6.2 only sets it) — the title keeps '— edited —' throughout, deliberately unasserted here."

  ;; run: editor-click-x/y, undo-button-x/y, redo-button-x/y — click coordinates
  ;; (framebuffer px). Bound at run time from the per-app run-values config (ADR-0011).
  (define editor-x (run-value 'editor-click-x))
  (define editor-y (run-value 'editor-click-y))
  (define undo-x (run-value 'undo-button-x))
  (define undo-y (run-value 'undo-button-y))
  (define redo-x (run-value 'redo-button-x))
  (define redo-y (run-value 'redo-button-y))

  ;; spec: (to confirm in-VM) — Undo reverts typing. (presentation-settled probe)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Note Editor")
  (wait-for-ocr "Undo")

  ;; spec: (to confirm in-VM) — Undo reverts typing. (the typing to revert)
  (click-at editor-x editor-y)
  (wait 0.5)
  (type "# Hello")
  ;; spec: (to confirm in-VM) — Undo reverts typing. (settle after type before the button
  ;; clicks — the k121 race; the heading is rendered before undoing starts)
  (wait-for-log #px"\\[preview\\] rendered placeholder=false chars=7\\b" #:timeout 10.0)
  (wait 0.5)
  (wait-for-ocr "Hello" #:timeout 10.0)

  ;; spec: (to confirm in-VM) — Undo reverts typing. (repeatedly, per the text system's
  ;; grouping — eight clicks over-shoot any granularity; extras hit the empty stack and
  ;; no-op, §8.5.8; scenarios are code — loops are first-class, app-spec/main.rkt)
  (for ([i (in-range 8)])
    (click-at undo-x undo-y)
    (wait 0.5))
  ;; spec: (to confirm in-VM) — Undo reverts typing. (undoing all typing returns the
  ;; preview to the placeholder — the live screen is discriminating: the placeholder had
  ;; been replaced by the heading since the first keystroke)
  (wait-for-ocr "Start typing Markdown" #:timeout 10.0)

  ;; spec: (to confirm in-VM) — Redo restores. (symmetric — eight clicks, extras no-op)
  (for ([i (in-range 8)])
    (click-at redo-x redo-y)
    (wait 0.5))
  ;; spec: (to confirm in-VM) — Redo restores. (the re-applied edit renders the heading
  ;; again — live-screen discriminating: the placeholder was on screen immediately before)
  (wait-for-ocr "Hello" #:timeout 10.0))
