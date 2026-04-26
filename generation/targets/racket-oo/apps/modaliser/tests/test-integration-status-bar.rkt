#lang racket/base
;; tests/test-integration-status-bar.rkt — Integration test for status bar
;; menu construction.
;;
;; Why this exists: tests/test-lifecycle.rkt only checks
;; `(procedure? setup-status-bar!)`. Three contract violations inside the
;; menu construction code (passing `sel_registerName` cpointers where strings
;; were required, raw `_id` from `tell ... separatorItem` where `objc-object?`
;; was required) shipped past "26/26 tests pass" and only surfaced on the first
;; VM install. This test boots a real NSApplication, calls `setup-status-bar!`
;; from `applicationDidFinishLaunching:`, and inspects the resulting menu —
;; forcing every contract-checked binding call on the construction path to
;; actually execute.
;;
;; Follows the auto-terminating Cocoa-loop pattern (memory:
;; "Auto-terminating Cocoa-loop test pattern"): arms a 5 s safety-net exit
;; before any assertion, runs assertions inside the existing delegate
;; with-handlers boundary, then schedules a normal-path `(exit 0)`.
;;
;; CGEvent tap is not installed (the keyboard-capture test covers that).
;; Status bar setup does not require accessibility permission, so this test
;; runs without TCC prompts.

(require "../bindings/runtime/objc-base.rkt"
         "../bindings/runtime/delegate.rkt"
         "../bindings/runtime/type-mapping.rkt"
         "../bindings/generated/oo/appkit/nsapplication.rkt"
         "../bindings/generated/oo/appkit/nsmenu.rkt"
         "../bindings/generated/oo/appkit/nsmenuitem.rkt"
         "../bindings/generated/oo/appkit/nsstatusitem.rkt"
         "../ffi/main-thread.rkt"
         "../services/lifecycle.rkt"
         (submod "../services/lifecycle.rkt" test-hooks))

(file-stream-buffer-mode (current-output-port) 'line)

(define NSApplicationActivationPolicyAccessory 1)
(define app (nsapplication-shared-application))
(void (nsapplication-set-activation-policy! app NSApplicationActivationPolicyAccessory))

(define expected-items
  ;; (index . (separator? . title)) — items 1 and 3 are separators
  '((0 #f "Settings…")
    (1 #t #f)
    (2 #f "Relaunch")
    (3 #t #f)
    (4 #f "Quit Modaliser")))

(define (fail! fmt . args)
  (apply eprintf fmt args)
  (exit 1))

(define (check-menu-structure!)
  (unless current-status-item
    (fail! "test-integration-status-bar: current-status-item is #f after setup\n"))
  (define menu (nsstatusitem-menu current-status-item))
  (unless menu
    (fail! "test-integration-status-bar: status item menu is #f\n"))
  (define count (nsmenu-number-of-items menu))
  (unless (= count 5)
    (fail! "test-integration-status-bar: expected 5 menu items, got ~a\n" count))
  (for ([row (in-list expected-items)])
    (define index (car row))
    (define expect-separator? (cadr row))
    (define expect-title (caddr row))
    (define item (nsmenu-item-at-index menu index))
    (define is-sep? (nsmenuitem-is-separator-item item))
    (cond
      [expect-separator?
       (unless is-sep?
         (fail! "test-integration-status-bar: item ~a expected separator, got non-separator\n"
                index))]
      [else
       (when is-sep?
         (fail! "test-integration-status-bar: item ~a expected non-separator, got separator\n"
                index))
       (define title (->string (nsmenuitem-title item)))
       (unless (equal? title expect-title)
         (fail! "test-integration-status-bar: item ~a title mismatch — expected ~s, got ~s\n"
                index expect-title title))
       (define target (nsmenuitem-target item))
       (unless target
         (fail! "test-integration-status-bar: item ~a target is #f — delegate not wired\n"
                index))])))

(define delegate
  (make-delegate
   "applicationDidFinishLaunching:"
   (lambda (notification)
     ;; Safety net first — any failure below still terminates loudly.
     (call-on-main-thread-after
      5.0
      (lambda ()
        (eprintf "test-integration-status-bar: SAFETY EXIT (5s elapsed)\n")
        (exit 1)))
     (with-handlers ([exn:fail?
                      (lambda (e)
                        (eprintf "test-integration-status-bar: setup-status-bar! raised: ~a\n"
                                 (exn-message e))
                        (exit 1))])
       (setup-status-bar!)
       (check-menu-structure!)
       (call-on-main-thread-after
        0.1
        (lambda ()
          (displayln "test-integration-status-bar: status bar built and menu verified — ok")
          (exit 0)))))))

(void (nsapplication-set-delegate! app delegate))
(nsapplication-run app)
