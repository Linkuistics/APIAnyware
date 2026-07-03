#lang app-spec
;; forward-generated from Drawing Canvas §14 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: a drag begun on a toolbar control draws nothing"
  #:description "When the user presses on a toolbar control (the width slider) and drags across the canvas with the button held, then no stroke appears: the slider's mouse-down starts a control tracking loop that captures the pointer, so the canvas never receives mouseDown:/mouseDragged: — and a drag with no preceding canvas mouse-down appends nothing (§7.2 boundary). The press landing on the control is witnessed positively by a width-changed line (shape-only — the drag's release x makes the final value driver-dependent, and a width change is harmless in this scenario's own launch); the no-stroke outcome is then asserted through the cardinality channel: a follow-up Clear reports count=0 (absence is never asserted directly — the cleared count turns it positive, logging contract). The slider was chosen over Clear (a release outside a push button never fires; a positive delivery witness is stronger) and over Color… (which would open the key-stealing panel). Provisional (§14 marks the boundary to confirm in-VM): a PASS confirms the tracking-loop capture; a FAILURE is a driver-choreography / spec-quality finding, not a suite bug. The canvas staying visually unchanged is pixel-level — the screenshot artifact is that record. State-mutating: its own launch."

  ;; run: slider-track-max-x/y — the press point ON the slider (the track's effective right end — k94);
  ;; canvas-drag-to-x/y — the release point inside the canvas region, below the toolbar band;
  ;; clear-button-x/y — the Clear button. All framebuffer px, bound at run time from the per-app
  ;; run-values config via current-run-values (ADR-0011); internal defines so they resolve at run time,
  ;; not at load (L1a).
  (define slider-track-max-x (run-value 'slider-track-max-x))
  (define slider-track-max-y (run-value 'slider-track-max-y))
  (define canvas-drag-to-x (run-value 'canvas-drag-to-x))
  (define canvas-drag-to-y (run-value 'canvas-drag-to-y))
  (define clear-button-x (run-value 'clear-button-x))
  (define clear-button-y (run-value 'clear-button-y))

  ;; spec: §14 — Launch diagnostic is emitted. (presentation-settled probe for the coordinate gesture)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Drawing Canvas")

  ;; spec: §14 — Toolbar controls present. (render-settled probe before the first coordinate gesture)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Clear")

  ;; spec: (to confirm in-VM) — Boundary — a drag begun on a toolbar control draws nothing. (press on the
  ;; slider, drag down across the canvas, release inside it — held-button throughout)
  ;; harness: runner/harness-inputs.rkt — drag-from-to takes positional (from-x from-y to-x to-y).
  (drag-from-to slider-track-max-x slider-track-max-y canvas-drag-to-x canvas-drag-to-y)

  ;; spec: (to confirm in-VM) — Boundary — a drag begun on a toolbar control draws nothing. (the delivery
  ;; witness: the press landed on the CONTROL — without this, the count=0 below could pass vacuously on an
  ;; undelivered gesture; shape-only match, the final tracked value is driver-dependent)
  ;; harness: runner/harness-logs.rkt — regexp; \\d+ matches the bare integer.
  (wait-for-log #px"\\[canvas\\] width-changed width=\\d+")

  ;; spec: (to confirm in-VM) — Boundary — a drag begun on a toolbar control draws nothing. (turn the
  ;; absence positive: Clear reports the stroke-set cardinality)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at clear-button-x clear-button-y)

  ;; spec: (to confirm in-VM) — Boundary — a drag begun on a toolbar control draws nothing. (count=0: no
  ;; stroke was ever born — the §7.2 boundary held)
  ;; harness: runner/harness-logs.rkt — regexp; \\b keeps count=0 exact.
  (wait-for-log #px"\\[canvas\\] cleared count=0\\b"))
