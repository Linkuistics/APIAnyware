#lang app-spec/run-values

;; Per-app run-values config for UI Controls Gallery (ADR-0011, the per-app
;; run-value source schema). Carries the *app-level* coordinate values the
;; interaction scenarios (scenarios/04–09, 11) click; the per-*impl* value
;; (bundle-id) lives in each `#lang app-spec/impl` descriptor
;; (../../../targets/<t>/app-implementations/macos/ui-controls-gallery/
;; ui-controls-gallery-impl.rkt); the runner merges the two into the single
;; `current-run-values` table that `(run-value 'key)` reads (runner/main.rkt;
;; the descriptor wins on any key clash).
;;
;; This config holds *app data* and lives downstream in APIAnyware, never in
;; the AppSpec toolkit (ADR-0052). It is consumed by `runner/main.rkt
;; --run-values <this file>` and is deliberately NOT placed under scenarios/ —
;; the runner discovers every .rkt there as a `#lang app-spec` scenario, so a
;; config file there would be mis-loaded (runner/dispatch.rkt).
;;
;; ── MEASURED LIVE (live-run-k94, 2026-07-02) — the CHEZ + GERBIL table ──
;; Values are element centres in framebuffer px on the 1920x1080
;; testanyware-golden-macos-tahoe framebuffer, read from `agent snapshot
;; --mode layout` (AX position+size → centre) against the post-launch
;; 500x920-content window at (710, 35) — the k94 launch-presentation fix
;; (window content sized past the 900px stack document so the whole roster
;; is visible; a 600px viewport launched bottom-scrolled).
;;
;; chez and gerbil realize PIXEL-IDENTICAL layouts (same generated-binding
;; control metrics), so they share this default table. The other two impls
;; diverge and carry sibling per-impl files, passed explicitly per runner
;; invocation (`--run-values` binds per invocation; the descriptor wins only
;; on `bundle-id`): run-values-racket.rkt (same stack, tighter control
;; metrics → rows sit higher), run-values-sbcl.rkt (a genuinely different
;; static two-column 820x532 layout). Geometry verified DETERMINISTIC across
;; launches (two-launch AX diff, byte-identical) after the k94
;; radio-container fix — the pre-fix plain-NSView container had no intrinsic
;; size and shifted every row below it nondeterministically per launch.
;; Re-measure if the framebuffer, window size, or layout change.

(run-values
  ;; scenarios/04 — the 'Option B' radio button centre (AX 911,304 77x18)
  (radio-option-b-x 949)
  (radio-option-b-y 313)
  ;; scenarios/05 — the checkbox centre (AX 893,272 115x18)
  (checkbox-x 950)
  (checkbox-y 281)
  ;; scenarios/06 — the text field centre (AX 709,119 482x26)
  (text-field-x 950)
  (text-field-y 132)
  ;; scenarios/07 — just inside the slider track's two ends (AX 709,369 482x18).
  ;; The min end sits at the track's effective start (frame edge + the ~10px
  ;; knob half-width inset), NOT the frame edge: the window's left border is
  ;; 1px away there and its ~5px resize-handle band swallows edge clicks (the
  ;; k94 racket finding); x=719 still maps below the knob inset, clamping to 0.
  (slider-track-max-x 1187)
  (slider-track-max-y 378)
  (slider-track-min-x 719)
  (slider-track-min-y 378)
  ;; scenarios/08 — the stepper's up/down arrow centres (AX 939,797 22x28; top=increment)
  (stepper-increment-x 950)
  (stepper-increment-y 804)
  (stepper-decrement-x 950)
  (stepper-decrement-y 818)
  ;; scenarios/09 — the 'Click Me' push button centre (AX 911,232 78x26)
  (push-button-x 950)
  (push-button-y 245)
  ;; scenarios/11 — the window close control (leftmost traffic-light) centre (AX 718,43 16x16)
  (close-button-x 726)
  (close-button-y 51))
