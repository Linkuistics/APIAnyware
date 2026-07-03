#lang app-spec
;; forward-generated from Drawing Canvas §14 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "Clear empties the canvas"
  #:description "When the user draws two strokes and activates Clear, then the whole stroke set is removed in one action — the cleared event reports count=2, the exact cardinality of the set just emptied (§8.3: Clear empties the collection totally; the count channel is the blankness assertion's model half) — the app keeps running, and the window still carries its exact launch title (§13 — no window retitling — survives draw-and-clear mutations; AX exactness is what makes 'unchanged' expressible). The visual return to blank is pixel-level — the screenshot artifact is that record (documented gap). The second dot's committed line is byte-identical to the first and events are never counted (logging contract), so the count=2 IS the aggregate two-strokes witness. State-mutating: its own launch, carrying only its own-effect reads."

  ;; run: bundle-id — bound at run time from the impl descriptor (ADR-0011).
  ;; run: canvas-point-x/y, canvas-point-2-x/y — two visibly distinct canvas points (k94 margins);
  ;; clear-button-x/y — the Clear button. Framebuffer px, from the per-app run-values config (ADR-0011).
  ;; Internal defines so they resolve at run time, not at load (L1a).
  (define bundle-id (run-value 'bundle-id))
  (define canvas-point-x (run-value 'canvas-point-x))
  (define canvas-point-y (run-value 'canvas-point-y))
  (define canvas-point-2-x (run-value 'canvas-point-2-x))
  (define canvas-point-2-y (run-value 'canvas-point-2-y))
  (define clear-button-x (run-value 'clear-button-x))
  (define clear-button-y (run-value 'clear-button-y))

  ;; spec: §14 — Launch diagnostic is emitted. (presentation-settled probe for the coordinate clicks)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Drawing Canvas")

  ;; spec: §14 — Toolbar controls present. (render-settled probe before the first coordinate click)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Clear")

  ;; spec: §14 — Clear empties the canvas. (setup: stroke one)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at canvas-point-x canvas-point-y)

  ;; spec: §14 — Clear empties the canvas. (stroke one's delivery gate)
  ;; harness: runner/harness-logs.rkt — regexp; \\b guards the integers.
  (wait-for-log #px"\\[canvas\\] stroke-committed r=0 g=0 b=0 width=2 points=1\\b")

  ;; spec: §14 — Clear empties the canvas. (setup: stroke two — its committed line is byte-identical to
  ;; stroke one's, so it has no individual log gate; AppKit's main-thread serialisation orders it before
  ;; the Clear below, and the count=2 is its witness. gv-click's pre-move keeps the consecutive clicks
  ;; from fusing into a double-click.)
  (click-at canvas-point-2-x canvas-point-2-y)

  ;; spec: §14 — Clear empties the canvas. (the removal)
  (click-at clear-button-x clear-button-y)

  ;; spec: §14 — Clear empties the canvas. (count=2: exactly the two driven strokes were removed and the
  ;; set is now empty; visual blankness rides the screenshot artifact)
  ;; harness: runner/harness-logs.rkt — regexp; \\b keeps count=2 exact.
  (wait-for-log #px"\\[canvas\\] cleared count=2\\b")

  ;; spec: §14 — Clear empties the canvas. ('the app keeps running')
  ;; harness: runner/harness-observations.rkt — #:running? defaults to #t.
  (expect-running-app bundle-id)

  ;; spec: §13 not-included — No window retitling. (still exactly the launch title after draw-and-clear;
  ;; the exact equal? AXTitle match is what makes 'unchanged' expressible — a presence-only OCR read
  ;; could not detect a retitle)
  ;; harness: runner/harness-observations.rkt — expect-ax #:title is an exact equal? match.
  (expect-ax #:role 'AXWindow #:title "Drawing Canvas"))
