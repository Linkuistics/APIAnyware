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
;; ── ALL VALUES BELOW ARE PROVISIONAL ZEROS — MEASURE BEFORE RUNNING ──
;; Unlike hello-window (fixed 400×200 window, shared geometry across impls),
;; the gallery's window size, section map, and control layout are
;; IMPL-VARYING (spec §4/§5) — there is no shared formula to pre-compute.
;; The Tier-2 live-run leaf MUST measure each control's centre per impl via
;; `agent snapshot --mode layout` (the hello-window k73 recipe: AX position +
;; size → centre, in framebuffer px — `testanyware input click` takes
;; framebuffer pixels) and bind real values before driving scenarios
;; 04–09/11. Running with the zeros below would click the screen origin (the
;; menu-bar corner) and is meaningless.
;;
;; Because layouts differ per impl, ONE per-app table may not fit all four
;; impls. `--run-values` binds per runner invocation, so the live-run stage
;; may keep per-impl copies (e.g. run-values-<impl>.rkt beside this file,
;; passed explicitly) — geometry-derivation-from-AX at run time stays
;; deferred (ADR-0011). This file is the key roster + the racket/chez/gerbil
;; measurement home; scenarios 01/02/03/10 need no coordinates and run as-is.

(run-values
  ;; scenarios/04 — the 'Option B' radio button centre
  (radio-option-b-x 0)
  (radio-option-b-y 0)
  ;; scenarios/05 — the checkbox centre
  (checkbox-x 0)
  (checkbox-y 0)
  ;; scenarios/06 — the text field centre
  (text-field-x 0)
  (text-field-y 0)
  ;; scenarios/07 — at/just past the slider track's two ends
  (slider-track-max-x 0)
  (slider-track-max-y 0)
  (slider-track-min-x 0)
  (slider-track-min-y 0)
  ;; scenarios/08 — the stepper's up (increment) and down (decrement) arrows
  (stepper-increment-x 0)
  (stepper-increment-y 0)
  (stepper-decrement-x 0)
  (stepper-decrement-y 0)
  ;; scenarios/09 — the 'Click Me' push button centre
  (push-button-x 0)
  (push-button-y 0)
  ;; scenarios/11 — the window close control (leftmost traffic-light) centre
  (close-button-x 0)
  (close-button-y 0))
