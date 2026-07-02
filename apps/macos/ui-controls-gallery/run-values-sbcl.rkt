#lang app-spec/run-values

;; Per-impl run-values for the SBCL build of UI Controls Gallery — measured
;; live (live-run-k94) against the 1920x1080 testanyware-golden-macos-tahoe
;; framebuffer from `agent snapshot --mode layout` (AX position+size → element
;; centre, framebuffer px). The sbcl gallery is a static two-column 820x532
;; window titled "AppKit Controls - SBCL" centered at (550, 140) — a layout
;; genuinely different from the racket/chez/gerbil single-column stack, which
;; is why this impl carries its own file (../run-values.rkt is the
;; racket/chez/gerbil home; `--run-values` binds per runner invocation).
;;
;; Geometry is deterministic per launch ([NSWindow center] on the fixed-size
;; framebuffer); re-measure if the framebuffer, window size, or layout change.

(run-values
  ;; scenarios/04 — the 'Option B' radio button centre (AX 799,308 98x22)
  (radio-option-b-x 848)
  (radio-option-b-y 319)
  ;; scenarios/05 — the checkbox centre (AX 699,271 172x24)
  (checkbox-x 785)
  (checkbox-y 283)
  ;; scenarios/06 — the text field centre (AX 1109,307 212x26)
  (text-field-x 1215)
  (text-field-y 320)
  ;; scenarios/07 — just inside the 0-100 slider track's two ends (AX 699,457 212x26)
  (slider-track-max-x 905)
  (slider-track-max-y 470)
  (slider-track-min-x 703)
  (slider-track-min-y 470)
  ;; scenarios/08 — the stepper's up/down arrow centres (AX 699,495 22x30; top=increment)
  (stepper-increment-x 710)
  (stepper-increment-y 502)
  (stepper-decrement-x 710)
  (stepper-decrement-y 518)
  ;; scenarios/09 — the 'Click Me' push button centre (AX 699,227 132x32)
  (push-button-x 765)
  (push-button-y 243)
  ;; scenarios/11 — the window close control centre (AX 558,148 16x16)
  (close-button-x 566)
  (close-button-y 156))
