#lang app-spec
;; forward-generated from Drawing Canvas §14 on 2026-07-03, then human-validated by git review (ADR-0050, ADR-0052).

(scenario "recording: width applies to subsequent strokes only"
  #:description "When the user draws a stroke, moves the slider to its maximum, and draws again, then the second stroke freezes the new width at ITS OWN mouse-down while the first stroke's committed tuple — already on record with width=2 — never changes: the capture-at-mouse-down freeze (§2/§7.1) proven from the log alone. The slider drive lands as width-changed width=20 — a click at the track's effective right end drives the maximum, 20, deterministically (range 1-20, §5.1/§8.2), which also witnesses the range's upper bound via the platform clamp. Provisional (§14 marks the line to confirm in-VM; continuous slider delivery is itself to-confirm — the driven-to line is matched, never a count or a stream shape): a PASS confirms the freeze's model half; the rendered thickness of both strokes is pixel-level — the screenshot artifact is that record (documented gap). A FAILURE is a driver / spec-quality finding, not a suite bug. State-mutating (draws and drives the slider): its own launch."

  ;; run: canvas-point-x/y, canvas-point-2-x/y — two visibly distinct canvas points (below the toolbar
  ;; band, >=10px from borders — k94); slider-track-max-x/y — the slider track's EFFECTIVE right end
  ;; (knob half-width in — k94; a track click jumps the knob to the clicked point, default NSSlider).
  ;; Framebuffer px, bound at run time from the per-app run-values config via current-run-values
  ;; (ADR-0011); internal defines so they resolve at run time, not at load (L1a).
  (define canvas-point-x (run-value 'canvas-point-x))
  (define canvas-point-y (run-value 'canvas-point-y))
  (define canvas-point-2-x (run-value 'canvas-point-2-x))
  (define canvas-point-2-y (run-value 'canvas-point-2-y))
  (define slider-track-max-x (run-value 'slider-track-max-x))
  (define slider-track-max-y (run-value 'slider-track-max-y))

  ;; spec: §14 — Launch diagnostic is emitted. (presentation-settled probe for the coordinate clicks)
  ;; harness: runner/harness-logs.rkt — wait-for-log takes a regexp.
  (wait-for-log #rx"Drawing Canvas")

  ;; spec: §14 — Toolbar controls present. (render-settled probe before the first coordinate click)
  ;; harness: runner/harness-observations.rkt — wait-for-ocr polls a literal substring.
  (wait-for-ocr "Clear")

  ;; spec: (to confirm in-VM) — Width applies to subsequent strokes only. (baseline: a stroke at the
  ;; launch width, BEFORE the slider moves)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at canvas-point-x canvas-point-y)

  ;; spec: (to confirm in-VM) — Width applies to subsequent strokes only. (the baseline tuple on record:
  ;; width=2 frozen at its own mouse-down — freeze-proof half 1; also the delivery gate for the click)
  ;; harness: runner/harness-logs.rkt — regexp; \\b keeps width=2 and points=1 exact.
  (wait-for-log #px"\\[canvas\\] stroke-committed r=0 g=0 b=0 width=2 points=1\\b")

  ;; spec: (to confirm in-VM) — Width applies to subsequent strokes only. (move the slider up: the track
  ;; click jumps the knob to the effective right end)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y).
  (click-at slider-track-max-x slider-track-max-y)

  ;; spec: (to confirm in-VM) — Width applies to subsequent strokes only. (the stored width is now 20)
  ;; spec: §14 — Slider initial state. (the range half's upper bound: the platform clamps the track-end
  ;; drive to the configured maximum 20 — the only expressible range read; the min end stays a gap)
  ;; harness: runner/harness-logs.rkt — regexp; intermediate width-changed lines may precede it
  ;; (continuous wiring, §5.1) — the driven-to line is matched, never a count; \\b guards the integer.
  (wait-for-log #px"\\[canvas\\] width-changed width=20\\b")

  ;; spec: (to confirm in-VM) — Width applies to subsequent strokes only. (a NEW stroke after the change)
  ;; harness: runner/harness-inputs.rkt — click-at takes positional (x y); gv-click's pre-move keeps the
  ;; two deliberate consecutive clicks from fusing into a double-click.
  (click-at canvas-point-2-x canvas-point-2-y)

  ;; spec: (to confirm in-VM) — Width applies to subsequent strokes only. (freeze-proof half 2: the new
  ;; stroke carries width=20 frozen at ITS mouse-down; the earlier width=2 committed line already on
  ;; record is the proof no existing stroke's tuple changed — the §7.2 structural guarantee; the pixels
  ;; of both strokes ride the screenshot artifact)
  ;; harness: runner/harness-logs.rkt — regexp; fixed key order per the logging contract.
  (wait-for-log #px"\\[canvas\\] stroke-committed r=0 g=0 b=0 width=20 points=1\\b"))
