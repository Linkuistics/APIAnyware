#lang app-spec/run-values

;; Per-impl run-values for the RACKET build of UI Controls Gallery — measured
;; live (live-run-k94) against the 1920x1080 testanyware-golden-macos-tahoe
;; framebuffer from `agent snapshot --mode layout` (AX position+size → element
;; centre, framebuffer px). Same single-column stack as chez/gerbil
;; (../run-values.rkt, the shared default) but racket's generated-binding
;; control metrics are tighter (22px control heights vs 26), so rows sit at
;; different offsets in the same 500x920-content window at (710, 36) — hence
;; the per-impl copy (`--run-values` binds per invocation).
;;
;; Geometry verified DETERMINISTIC across launches (two-launch AX diff,
;; byte-identical) after the k94 radio-container fix — the pre-fix plain-
;; NSView container had no intrinsic size and shifted every row below it
;; nondeterministically per launch. Re-measure if the framebuffer, window
;; size, or layout change.

(run-values
  ;; scenarios/04 — the 'Option B' radio button centre (AX 912,288 76x17)
  (radio-option-b-x 950)
  (radio-option-b-y 296)
  ;; scenarios/05 — the checkbox centre (AX 895,257 111x17)
  (checkbox-x 950)
  (checkbox-y 265)
  ;; scenarios/06 — the text field centre (AX 709,116 482x22)
  (text-field-x 950)
  (text-field-y 127)
  ;; scenarios/07 — just inside the slider track's two ends (AX 709,352 482x22).
  ;; The min end sits at the track's effective start (frame edge + the ~12px
  ;; knob half-width inset), NOT the frame edge: the window's left border is
  ;; 1px away there and its ~5px resize-handle band swallows edge clicks (a
  ;; click at frame-edge x=713 never reached the slider); x=720 still maps
  ;; below the knob inset, clamping to 0.
  (slider-track-max-x 1187)
  (slider-track-max-y 363)
  (slider-track-min-x 720)
  (slider-track-min-y 363)
  ;; scenarios/08 — the stepper's up/down arrow centres (AX 943,776 15x22; top=increment)
  (stepper-increment-x 950)
  (stepper-increment-y 781)
  (stepper-decrement-x 950)
  (stepper-decrement-y 792)
  ;; scenarios/09 — the 'Click Me' push button centre (AX 915,221 71x22)
  (push-button-x 950)
  (push-button-y 232)
  ;; scenarios/11 — the window close control (leftmost traffic-light) centre (AX 718,43 12x14)
  (close-button-x 724)
  (close-button-y 50))
