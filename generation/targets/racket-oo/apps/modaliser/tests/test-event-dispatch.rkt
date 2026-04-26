#lang racket/base
;; test-event-dispatch.rkt — Tests for core/event-dispatch.rkt
;;
;; Tests the event dispatch logic: leader key entry, modal key routing,
;; escape/delete handling, and Cmd passthrough.
;;
;; Note: requiring event-dispatch.rkt loads the CGEvent FFI, which
;; requires macOS. These tests verify the dispatch logic, not the tap.

(require rackunit
         "../core/keymap.rkt"
         "../core/state-machine.rkt"
         "../core/event-dispatch.rkt"
         "../lib/dsl.rkt")

;; ─── Setup ──────────────────────────────────────────────────────

;; Disable overlay delay for deterministic tests
(set-overlay-delay! 0)

;; Track overlay operations
(define overlay-visible #f)
(set-overlay-hooks!
 #:show (lambda (r p) (set! overlay-visible #t))
 #:update (lambda (r p) (void))
 #:hide (lambda () (set! overlay-visible #f))
 #:open-chooser (lambda (n) (void))
 #:open? (lambda () overlay-visible))

;; ─── Build test tree ────────────────────────────────────────────

(clear-trees!)
(define action-result #f)

(define-tree 'global
  (key "a" "App A" (lambda () (set! action-result 'app-a)))
  (group "w" "Windows"
    (key "h" "Left Half" (lambda () (set! action-result 'left-half)))
    (key "l" "Right Half" (lambda () (set! action-result 'right-half))))
  (selector "s" "Search"))

;; ─── Register leader key ───────────────────────────────────────

(define LEADER KEY-F17)
(register-hotkey! LEADER (lambda ()
                           (if modal-active?
                               (modal-exit)
                               (let ([tree (lookup-tree "global")])
                                 (when tree (modal-enter tree LEADER))))))

;; ─── Test: hotkey triggers modal entry ─────────────────────────

(check-false modal-active? "modal should be inactive initially")

;; Enter modal directly (simulates what the leader handler does)
(let ([tree (lookup-tree "global")])
  (when tree (modal-enter tree LEADER)))

(check-true modal-active? "modal should be active after leader handler")
(modal-exit)

;; ─── Test: modal-key-handler routing ────────────────────────────

;; Enter modal
(modal-enter (lookup-tree "global") LEADER)
(check-true modal-active?)

;; Escape exits
(void (modal-key-handler KEY-ESCAPE 0))  ;; no modifiers
(check-false modal-active? "escape should exit modal")

;; Re-enter and test delete (step back from root = exit)
(modal-enter (lookup-tree "global") LEADER)
(void (modal-key-handler KEY-DELETE 0))
(check-false modal-active? "delete from root should exit modal")

;; ─── Test: Cmd+key passes through ──────────────────────────────

(modal-enter (lookup-tree "global") LEADER)
(define cmd-result (modal-key-handler 0 MOD-CMD))  ;; Cmd+A (keycode 0 = 'a')
(check-false cmd-result "Cmd+key should return #f (pass through)")
(check-true modal-active? "modal should still be active after Cmd+key")
(modal-exit)

;; ─── Test: regular key executes command ─────────────────────────

(set! action-result #f)
(modal-enter (lookup-tree "global") LEADER)

;; Press "a" (keycode 0, no modifiers)
(void (modal-key-handler 0 0))
(check-false modal-active? "modal should exit after command")
(check-equal? action-result 'app-a "action should have executed")

;; ─── Test: group navigation ────────────────────────────────────

(set! action-result #f)
(modal-enter (lookup-tree "global") LEADER)

;; Press "w" (keycode 13) — enter Windows group
(void (modal-key-handler 13 0))  ;; keycode 13 = "w"
(check-true modal-active? "modal still active in group")
(check-equal? modal-current-path '("w"))

;; Press "h" (keycode 4) — Left Half
(void (modal-key-handler 4 0))  ;; keycode 4 = "h"
(check-false modal-active?)
(check-equal? action-result 'left-half)

;; ─── Test: group → step back → exit ─────────────────────────────

(modal-enter (lookup-tree "global") LEADER)
(void (modal-key-handler 13 0))  ;; "w" → enter group
(check-equal? modal-current-path '("w"))

(void (modal-key-handler KEY-DELETE 0))  ;; step back
(check-true modal-active?)
(check-equal? modal-current-path '())

(void (modal-key-handler KEY-DELETE 0))  ;; step back from root → exit
(check-false modal-active?)

;; ─── Test: unknown key exits modal ──────────────────────────────

(modal-enter (lookup-tree "global") LEADER)
(void (modal-key-handler 6 0))  ;; keycode 6 = "z" — not in our tree
(check-false modal-active? "unknown key should exit modal")

;; ─── Test: leader key while modal exits ─────────────────────────

(modal-enter (lookup-tree "global") LEADER)
(void (modal-key-handler LEADER 0))
(check-false modal-active? "leader key should toggle modal off")

;; ─── Test: shift produces uppercase ─────────────────────────────

(clear-trees!)
(set! action-result #f)
(define-tree 'global
  (key "A" "Shift-A Action" (lambda () (set! action-result 'shift-a))))

(modal-enter (lookup-tree "global") LEADER)
(void (modal-key-handler 0 MOD-SHIFT))  ;; Shift+A → "A"
(check-false modal-active?)
(check-equal? action-result 'shift-a "shift should produce uppercase key")

(displayln "test-event-dispatch: all checks passed")
