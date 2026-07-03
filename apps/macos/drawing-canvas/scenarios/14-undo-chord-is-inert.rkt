#lang app-spec
;; forward-generated from Drawing Canvas §14 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "undo chord is inert — Clear-all is the only removal"
  #:description "When the user draws a stroke and then sends Command-Z, then the stroke set is untouched: the app has no undo/redo (§13 — strokes are unrecoverable and Clear-all is the only removal), so a follow-up Clear reports count=1 — the drawn stroke SURVIVED the chord (had an undo existed and removed it, the count would be 0: the discriminating positive form via the cardinality channel) — and the app keeps running (the unhandled chord caused no crash; §13 — no keyboard interaction beyond menu key equivalents; no Edit menu is mandated, §9 mandates only ⌘Q). State-mutating (draws, sends input): its own launch."

  ;; run: bundle-id — from the impl descriptor (ADR-0011); canvas-point-x/y — a canvas point (k94
  ;; margins); clear-button-x/y — the Clear button. Framebuffer px, from the per-app run-values config
  ;; (ADR-0011). Internal defines so they resolve at run time, not at load (L1a).
  (define bundle-id (run-value 'bundle-id))
  (define canvas-point-x (run-value 'canvas-point-x))
  (define canvas-point-y (run-value 'canvas-point-y))
  (define clear-button-x (run-value 'clear-button-x))
  (define clear-button-y (run-value 'clear-button-y))

  ;; spec: §14 — Launch diagnostic is emitted. (presentation-settled probe for the coordinate clicks)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Drawing Canvas")

  ;; spec: §14 — Toolbar controls present. (render-settled probe before the first coordinate click)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Clear")

  ;; spec: §13 not-included — No persistence, no undo/redo, no save/export. (setup: put exactly one stroke
  ;; in the set — the thing the undo chord must NOT remove)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at canvas-point-x canvas-point-y)

  ;; spec: §13 not-included — No persistence, no undo/redo, no save/export. (the stroke-on-record gate:
  ;; the click delivered and the stroke committed)
  ;; harness: runner/harness-logs.rkt — regexp; \\b guards the integers.
  (wait-for-log #px"\\[canvas\\] stroke-committed r=0 g=0 b=0 width=2 points=1\\b")

  ;; spec: §13 not-included — No persistence, no undo/redo, no save/export. (the undo attempt — no Edit
  ;; menu is mandated and no undo manager exists; expected inert)
  ;; harness: runner/harness-inputs.rkt — chord takes (list-of-modifier-symbols key), not a flat "cmd z".
  (chord '(cmd) 'z)

  ;; harness: runner/harness-state.rkt — (wait seconds): give any (nonexistent) undo a beat to act before
  ;; the cardinality read, so a failure would be a real removal, not a race.
  (wait 1)

  ;; spec: §13 not-included — No persistence, no undo/redo, no save/export. (read the cardinality)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at clear-button-x clear-button-y)

  ;; spec: §13 not-included — No persistence, no undo/redo, no save/export. (count=1: the stroke survived
  ;; the chord — undo removed nothing; Clear-all remains the only removal)
  ;; harness: runner/harness-logs.rkt — regexp; \\b keeps count=1 from matching a longer integer.
  (wait-for-log #px"\\[canvas\\] cleared count=1\\b")

  ;; spec: §13 not-included — No keyboard interaction. (the unhandled chord caused no crash)
  ;; harness: runner/harness-observations.rkt — #:running? defaults to #t.
  (expect-running-app bundle-id))
