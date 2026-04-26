#lang racket/base
;; test-integration-modal.rkt — Integration test for the full modal flow
;;
;; Tests the complete chain: DSL tree construction → event dispatch →
;; modal state machine → command execution. Also verifies that
;; start-keyboard-dispatch! successfully starts the CGEvent tap.
;;
;; Run:  racket tests/test-integration-modal.rkt
;; This test creates a minimal NSApplication (no run loop) to verify
;; the keyboard dispatch can start, then tests the full modal flow
;; programmatically.

(require rackunit
         "../bindings/runtime/objc-base.rkt"
         "../bindings/runtime/coerce.rkt"
         "../bindings/generated/oo/appkit/nsapplication.rkt"
         "../core/keymap.rkt"
         "../core/state-machine.rkt"
         "../core/event-dispatch.rkt"
         "../lib/dsl.rkt"
         "../ffi/permissions.rkt")

(file-stream-buffer-mode (current-output-port) 'line)

;; ─── Setup NSApplication (needed for CGEvent tap) ───────────────

(define NSApplicationActivationPolicyAccessory 1)
(define app (nsapplication-shared-application))
(void (nsapplication-set-activation-policy! app NSApplicationActivationPolicyAccessory))

;; ─── Verify keyboard dispatch starts ────────────────────────────

(unless (accessibility-trusted?)
  (eprintf "test-integration-modal: accessibility permission required — grant racket access in System Settings → Privacy & Security → Accessibility\n")
  (exit 1))

(unless (start-keyboard-dispatch!)
  (eprintf "test-integration-modal: start-keyboard-dispatch! returned #f — CGEvent tap install failed\n")
  (exit 1))

;; ─── Build a test config via DSL ────────────────────────────────

(clear-trees!)
(set-overlay-delay! 0)

(define action-log '())
(define (log-action! name)
  (set! action-log (append action-log (list name))))

;; Install stub overlay hooks
(set-overlay-hooks!
 #:show (lambda (r p) (log-action! 'overlay-show))
 #:update (lambda (r p) (log-action! 'overlay-update))
 #:hide (lambda () (log-action! 'overlay-hide))
 #:open-chooser (lambda (n) (log-action! 'chooser-open))
 #:open? (lambda () #f))

;; Build a realistic tree
(define-tree 'global
  (key "a" "Terminal" (lambda () (log-action! 'launch-terminal)))
  (group "w" "Windows"
    (key "h" "Left Half" (lambda () (log-action! 'left-half)))
    (key "l" "Right Half" (lambda () (log-action! 'right-half)))
    (key "f" "Fullscreen" (lambda () (log-action! 'fullscreen))))
  (group "b" "Browser"
    (key "s" "Safari" (lambda () (log-action! 'launch-safari)))
    (key "f" "Firefox" (lambda () (log-action! 'launch-firefox))))
  (selector "s" "Search"))

(displayln "Tree built with 2 groups, 1 selector, 6 commands")

;; ─── Test 1: Direct command ─────────────────────────────────────

(set! action-log '())
(modal-enter (lookup-tree "global") KEY-F17)
(check-true modal-active?)
(void (modal-key-handler (char->keycode "a") 0))
(check-false modal-active?)
;; modal-exit hides overlay BEFORE the action runs
(check-equal? action-log '(overlay-show overlay-hide launch-terminal)
              "should show overlay, hide overlay, execute")

;; ─── Test 2: Group → nested command ─────────────────────────────

(set! action-log '())
(modal-enter (lookup-tree "global") KEY-F17)
(void (modal-key-handler (char->keycode "w") 0))  ;; enter Windows group
(check-true modal-active?)
(void (modal-key-handler (char->keycode "l") 0))  ;; Right Half
(check-false modal-active?)
(check-equal? action-log '(overlay-show overlay-show overlay-hide right-half)
              "should show overlay, navigate group (show again), hide, execute")

;; ─── Test 3: Group → step back → different key ──────────────────

(set! action-log '())
(modal-enter (lookup-tree "global") KEY-F17)
(void (modal-key-handler (char->keycode "w") 0))  ;; enter Windows
(check-equal? modal-current-path '("w"))
(void (modal-key-handler KEY-DELETE 0))            ;; step back
(check-equal? modal-current-path '())
(void (modal-key-handler (char->keycode "b") 0))  ;; enter Browser
(check-equal? modal-current-path '("b"))
(void (modal-key-handler (char->keycode "s") 0))  ;; Safari
(check-false modal-active?)
(check-not-false (member 'launch-safari action-log)
            "should have launched Safari")

;; ─── Test 4: Escape exits from any depth ────────────────────────

(set! action-log '())
(modal-enter (lookup-tree "global") KEY-F17)
(void (modal-key-handler (char->keycode "w") 0))
(void (modal-key-handler KEY-ESCAPE 0))
(check-false modal-active?)
(check-not-false (member 'overlay-hide action-log))

;; ─── Test 5: Selector opens chooser ─────────────────────────────

(set! action-log '())
(modal-enter (lookup-tree "global") KEY-F17)
(void (modal-key-handler (char->keycode "s") 0))
(check-false modal-active?)
(check-not-false (member 'chooser-open action-log)
            "selector should open chooser")

;; ─── Test 6: Cmd passthrough doesn't exit modal ─────────────────

(modal-enter (lookup-tree "global") KEY-F17)
(define result (modal-key-handler (char->keycode "c") MOD-CMD))
(check-false result "Cmd+C should pass through")
(check-true modal-active? "modal should remain active after Cmd+key")
(modal-exit)

;; ─── Cleanup ────────────────────────────────────────────────────

(stop-keyboard-dispatch!)
(displayln "test-integration-modal: all checks passed")
