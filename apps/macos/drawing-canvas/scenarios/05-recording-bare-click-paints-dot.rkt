#lang app-spec
;; forward-generated from Drawing Canvas §14 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: bare click on the canvas paints a dot"
  #:description "When the user clicks a canvas point without dragging, then a stroke is born carrying the frozen launch tool state — stroke-begun r=0 g=0 b=0 width=2 (initial colour black, initial width 2, both deterministic — logging contract) — and commits with exactly points=1, the deterministic dot discriminator (§7.2: the release location is never appended; a motionless click stores exactly the down point; §7.3 renders it as a filled disc via the coincident-second-point round-cap rule). Provisional (§14 marks the line to confirm in-VM): a PASS confirms canvas click delivery (stroke-begun is the k130 click-delivery witness) and the dot's model half; the dot's rendered roundness and diameter are pixel-level with no verb — the screenshot artifact is that record (this app's headline gap). A FAILURE is a driver-delivery / spec-quality finding, not a suite bug. State-mutating (draws): its own launch."

  ;; run: canvas-point-x/y — a canvas point comfortably below the 36-point toolbar band and >=10px from
  ;; the resizable window's borders (k94), framebuffer px, bound at run time from the per-app run-values
  ;; config via current-run-values (ADR-0011). Internal defines so they resolve at run time, not at load
  ;; (validation L1a).
  (define canvas-point-x (run-value 'canvas-point-x))
  (define canvas-point-y (run-value 'canvas-point-y))

  ;; spec: §14 — Launch diagnostic is emitted. (presentation-settled probe for the coordinate click)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Drawing Canvas")

  ;; spec: §14 — Toolbar controls present. (render-settled probe before the first coordinate click)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Clear")

  ;; spec: (to confirm in-VM) — Bare click paints a dot. (the trigger; gv-click's 100px pre-move is
  ;; load-bearing — the capture-then-parked-click swallow, k130)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at canvas-point-x canvas-point-y)

  ;; spec: (to confirm in-VM) — Bare click paints a dot. (the delivery witness: the gesture reached the
  ;; canvas, and the stroke froze the launch tool state at mouse-down)
  ;; spec: §14 — Slider initial state. (the firm log half: the frozen width=2 agrees with the slider's
  ;; initial value/position — §8.2; the launch tool state r=0 g=0 b=0 width=2 is deterministic and
  ;; byte-identical across impls — logging contract)
  ;; harness: runner/harness-logs.rkt — regexp; fixed key order r g b width per the logging contract, so
  ;; adjacency is reliable; \\b keeps width=2 from matching inside width=20.
  (wait-for-log #px"\\[canvas\\] stroke-begun r=0 g=0 b=0 width=2\\b")

  ;; spec: (to confirm in-VM) — Bare click paints a dot. (points=1 — the deterministic dot discriminator:
  ;; the down point plus zero drag points, the release never appended — logging contract)
  ;; harness: runner/harness-logs.rkt — regexp; \\b keeps points=1 from matching a longer count.
  (wait-for-log #px"\\[canvas\\] stroke-committed r=0 g=0 b=0 width=2 points=1\\b"))
