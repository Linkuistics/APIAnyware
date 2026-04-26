#lang racket/base
;; tests/test-integration-keyboard-capture.rkt — Integration test for the
;; CGEvent keyboard tap.
;;
;; Boots a minimal NSApplication, installs the keyboard tap, and runs the
;; Cocoa run loop briefly to verify the tap actually activates. The test
;; arms two GCD timers from `applicationDidFinishLaunching:`:
;;
;;   • a safety-net at 5 s that always fires `(exit 1)` so any failure
;;     in the delegate body still terminates the process loudly;
;;   • a normal-path timer at 0.5 s that fires `(exit 0)` once the
;;     `start-keyboard-capture!` precondition has held long enough for
;;     the tap to be observably installed.
;;
;; The historical version of this file dropped the user into an interactive
;; "Stop with: Ctrl+C" loop, which hung any automated test runner. The
;; auto-termination pattern below preserves the original coverage (delegate
;; reentry + tap install) without the manual-input dependency. CGEvent taps
;; only fire on physical hardware input (memory: "CGEvents only capture
;; physical keyboard input"), so this test cannot assert that key events
;; are actually captured — only that the tap installs and the delegate
;; survives the C→Racket reentry boundary.

(require "../bindings/runtime/objc-base.rkt"
         "../bindings/runtime/delegate.rkt"
         "../bindings/generated/oo/appkit/nsapplication.rkt"
         "../ffi/cgevent.rkt"
         "../ffi/main-thread.rkt"
         "../ffi/permissions.rkt")

(file-stream-buffer-mode (current-output-port) 'line)

(define NSApplicationActivationPolicyAccessory 1)
(define app (nsapplication-shared-application))
(void (nsapplication-set-activation-policy! app NSApplicationActivationPolicyAccessory))

(define (no-op-key-handler keycode modifiers key-down?)
  'pass-through)

(define delegate
  (make-delegate
   "applicationDidFinishLaunching:"
   (lambda (notification)
     ;; Arm the safety net first so any subsequent failure still terminates.
     (call-on-main-thread-after
      5.0
      (lambda ()
        (eprintf "test-integration-keyboard-capture: SAFETY EXIT (5s elapsed)\n")
        (exit 1)))
     (with-handlers ([exn:fail?
                      (lambda (e)
                        (eprintf "applicationDidFinishLaunching: delegate error: ~a\n"
                                 (exn-message e)))])
       (unless (accessibility-trusted?)
         (eprintf "test-integration-keyboard-capture: accessibility permission required — grant racket access in System Settings → Privacy & Security → Accessibility\n")
         (exit 1))
       (unless (start-keyboard-capture! no-op-key-handler)
         (eprintf "test-integration-keyboard-capture: start-keyboard-capture! returned #f — CGEvent tap install failed\n")
         (exit 1))
       (call-on-main-thread-after
        0.5
        (lambda ()
          (stop-keyboard-capture!)
          (displayln "test-integration-keyboard-capture: tap installed and survived 0.5s — ok")
          (exit 0)))))))

(void (nsapplication-set-delegate! app delegate))
(nsapplication-run app)
