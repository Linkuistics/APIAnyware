#lang app-spec
;; forward-generated from Drawing Canvas §14 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "typing draws nothing"
  #:description "When a character is typed at the steady state, then nothing happens: the app has no keyboard interaction beyond menu key equivalents and no text surface anywhere (§13), so the process keeps running and a following Clear records cleared count=0 — proving the keystroke created no stroke (the positive cardinality channel; the canvas-unchanged pixel half is the documented artifact gap). State-mutating (sends input): its own launch."

  ;; run: bundle-id — from the impl descriptor (ADR-0011); clear-button-x/y — the Clear button. From the
  ;; per-app run-values config; internal defines so they resolve at run time, not at load (L1a).
  (define bundle-id (run-value 'bundle-id))
  (define clear-button-x (run-value 'clear-button-x))
  (define clear-button-y (run-value 'clear-button-y))

  ;; spec: §14 — Launch diagnostic is emitted. (presentation-settled probe)
  ;; harness: runner/harness-logs.rkt — the log verbs take a REGEXP.
  (wait-for-log #rx"Drawing Canvas")
  ;; spec: §14 — Toolbar controls present. (render-settled probe before the coordinate click below)
  (wait-for-ocr "Clear")

  ;; spec: §14 — Boundary — typing draws nothing. (the keystroke — a bare 'x' matches no key equivalent;
  ;; §9 mandates only ⌘Q)
  ;; spec: §13 not-included — No keyboard interaction. (beyond menu key equivalents; no text surface)
  ;; harness: runner/harness-inputs.rkt — type takes a string.
  (type "x")

  ;; spec: §14 — Boundary — typing draws nothing. (settle after type before any button click — the k121
  ;; driver guidance)
  ;; harness: runner/harness-state.rkt — (wait seconds).
  (wait 1)

  ;; spec: §14 — Boundary — typing draws nothing. (the app keeps running — the unhandled keystroke caused
  ;; no crash)
  ;; harness: runner/harness-observations.rkt — #:running? defaults to #t.
  (expect-running-app bundle-id)

  ;; spec: §14 — Boundary — typing draws nothing. (turn the absence positive via the cardinality channel)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at clear-button-x clear-button-y)

  ;; spec: §14 — Boundary — typing draws nothing. (count=0: no stroke was born from the keystroke)
  ;; harness: runner/harness-logs.rkt — regexp; \\b keeps count=0 exact.
  (wait-for-log #px"\\[canvas\\] cleared count=0\\b"))
