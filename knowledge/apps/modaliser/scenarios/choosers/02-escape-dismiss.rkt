#lang app-spec

;; Escape dismisses the chooser, emitting [chooser] close reason=cancel.
;; ui/chooser.rkt logs `reason` as a symbol (='cancel), so events.rkt
;; emits it bare — reason=cancel, not reason="cancel".
;;
;; On macOS 26 (Tahoe) the post-close AX tree is predictable enough to
;; assert the panel is gone; earlier versions close-animate with timing
;; that's flaky under OCR/AX polling. Gated via at-least-macos? so the
;; scenario is meaningful on both, stricter on Tahoe.

(require "../helpers/common-setups.rkt"
         "../helpers/platform.rkt")

(scenario "chooser-dismisses-on-escape"
  #:description "Escape closes the Find Apps chooser (reason=cancel)"
  (open-find-apps!)
  (expect-ocr "Find app")
  (press 'Escape)
  (wait-for-log #px"\\[chooser\\] close reason=cancel" #:timeout 5.0)
  (when (at-least-macos? 26)
    (wait 0.5)
    (expect-no-ax #:role 'AXWindow #:title "Find Apps")))
