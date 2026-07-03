#lang app-spec
;; forward-generated from Drawing Canvas §14 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: held-button drag paints a stroke"
  #:description "When the user drags across the canvas with the button held, then a stroke is born at the down point frozen with the launch tool state (stroke-begun r=0 g=0 b=0 width=2) and commits carrying the down point plus the delivered drag points — points is matched SHAPE-ONLY (points=\\d+): the drag count depends on event-delivery cadence and is never bound exactly (logging contract). Provisional (§14 marks the line to confirm in-VM; this is the portfolio's first use of drag-from-to — the §14 preamble's 'no mouse-drag verb' predates the verb and is stale): a PASS confirms held-button drag delivery through the driver; the stroke's rendered connectedness/smoothness and its LIVE rendering mid-drag are pixel-level with no verb and no mid-gesture capture choreography — the post-gesture screenshot artifact is the record (documented gaps). A points=1 commit at live-run means the drag degenerated to a dot — a driver finding this recording surfaces, not an assertion. A FAILURE is a driver / spec-quality finding, not a suite bug. State-mutating (draws): its own launch."

  ;; run: canvas-drag-from-x/y, canvas-drag-to-x/y — the drag's endpoints, both inside the canvas region
  ;; (below the toolbar band, >=10px from window borders — k94), far enough apart to make drag delivery
  ;; unambiguous. Framebuffer px, bound at run time from the per-app run-values config via
  ;; current-run-values (ADR-0011); internal defines so they resolve at run time, not at load (L1a).
  (define canvas-drag-from-x (run-value 'canvas-drag-from-x))
  (define canvas-drag-from-y (run-value 'canvas-drag-from-y))
  (define canvas-drag-to-x (run-value 'canvas-drag-to-x))
  (define canvas-drag-to-y (run-value 'canvas-drag-to-y))

  ;; spec: §14 — Launch diagnostic is emitted. (presentation-settled probe for the coordinate gesture)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Drawing Canvas")

  ;; spec: §14 — Toolbar controls present. (render-settled probe before the first coordinate gesture)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Clear")

  ;; spec: (to confirm in-VM) — Drag paints a live stroke. (the trigger: a HELD-BUTTON drag — the SDK's
  ;; drag primitive holds the button mask for the whole motion; a bare pointer move between down and up
  ;; releases the button and yields only a down-point dot — §14 driver guidance)
  ;; harness: runner/harness-inputs.rkt — drag-from-to takes positional (from-x from-y to-x to-y).
  (drag-from-to canvas-drag-from-x canvas-drag-from-y canvas-drag-to-x canvas-drag-to-y)

  ;; spec: (to confirm in-VM) — Drag paints a live stroke. (the delivery witness: the down reached the
  ;; canvas and froze the launch tool state)
  ;; harness: runner/harness-logs.rkt — regexp; \\b keeps width=2 from matching inside width=20.
  (wait-for-log #px"\\[canvas\\] stroke-begun r=0 g=0 b=0 width=2\\b")

  ;; spec: (to confirm in-VM) — Drag paints a live stroke. (commit with the frozen tuple; points matched
  ;; shape-only — never bind an exact drag point-count, logging contract)
  ;; harness: runner/harness-logs.rkt — regexp; \\d+ matches the bare integer count.
  (wait-for-log #px"\\[canvas\\] stroke-committed r=0 g=0 b=0 width=2 points=\\d+"))
