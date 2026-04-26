#lang racket/base
;; cgevent.rkt — CGEvent tap FFI for keyboard capture
;;
;; Installs a system-wide CGEvent tap that intercepts keyboard events.
;; The handler callback receives (keycode modifiers key-down?) and
;; returns 'suppress or 'pass-through.
;;
;; Requires Accessibility permissions (see ffi/permissions.rkt).

(require (only-in "../bindings/runtime/cgevent-helpers.rkt"
                  make-cgevent-tap
                  cgevent-tap-enable!)
         (only-in "../bindings/generated/oo/corefoundation/functions.rkt"
                  CFRunLoopGetMain
                  CFRunLoopRemoveSource
                  CFRelease)
         (only-in "../bindings/generated/oo/corefoundation/constants.rkt"
                  kCFRunLoopCommonModes))

(provide start-keyboard-capture!
         stop-keyboard-capture!
         keyboard-capturing?)

;; --- Module state ---

(define current-event-tap #f)
(define current-run-loop-source #f)

;; --- Public API ---

;; Start capturing keyboard events.
;; handler: (lambda (keycode modifiers key-down?) -> 'suppress | 'pass-through)
;; Returns #t on success, #f on failure (usually means no accessibility permission).
(define (start-keyboard-capture! handler)
  (when current-event-tap
    (stop-keyboard-capture!))

  (define-values (tap source)
    (make-cgevent-tap handler
                      #:on-disabled
                      (lambda (type tap)
                        (displayln "keyboard-capture: tap re-enabled after system disable")
                        (cgevent-tap-enable! tap #t))))

  (cond
    [(not tap)
     (displayln "keyboard-capture: CGEventTapCreate failed (accessibility not granted?)")
     #f]
    [else
     (set! current-event-tap tap)
     (set! current-run-loop-source source)
     (displayln "keyboard-capture: event tap active")
     #t]))

;; Stop capturing keyboard events and clean up.
(define (stop-keyboard-capture!)
  (when current-event-tap
    (cgevent-tap-enable! current-event-tap #f))
  (when (and current-run-loop-source current-event-tap)
    (CFRunLoopRemoveSource (CFRunLoopGetMain) current-run-loop-source kCFRunLoopCommonModes))
  (when current-run-loop-source
    (CFRelease current-run-loop-source))
  (when current-event-tap
    (CFRelease current-event-tap))
  (set! current-event-tap #f)
  (set! current-run-loop-source #f)
  (displayln "keyboard-capture: stopped"))

;; Check if capture is currently active.
(define (keyboard-capturing?)
  (and current-event-tap #t))
