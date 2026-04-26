#lang racket/base
;; test-state-machine.rkt — Tests for core/state-machine.rkt

(require rackunit
         "../core/state-machine.rkt")

;; ─── Tree Registry ──────────────────────────────────────────────

(clear-trees!)

(register-tree! 'global
  (list (cons 'kind 'command) (cons 'key "a") (cons 'label "App A") (cons 'action (lambda () 'launch-a)))
  (list (cons 'kind 'group) (cons 'key "w") (cons 'label "Windows")
        (cons 'children
              (list
                (list (cons 'kind 'command) (cons 'key "h") (cons 'label "Left Half") (cons 'action (lambda () 'left-half)))
                (list (cons 'kind 'command) (cons 'key "l") (cons 'label "Right Half") (cons 'action (lambda () 'right-half))))))
  (list (cons 'kind 'selector) (cons 'key "s") (cons 'label "Search")))

(check-not-false (lookup-tree 'global) "global tree should exist")
(check-false (lookup-tree 'nonexistent) "nonexistent tree should return #f")

;; ─── Node Predicates ────────────────────────────────────────────

(define tree (lookup-tree 'global))
(check-true (group? tree) "root should be a group")

(define children (node-children tree))
(check-equal? (length children) 3)

(define cmd-a (car children))
(check-true (command? cmd-a))
(check-equal? (node-key cmd-a) "a")
(check-equal? (node-label cmd-a) "App A")

(define group-w (cadr children))
(check-true (group? group-w))
(check-equal? (node-key group-w) "w")
(check-equal? (node-label group-w) "Windows")

(define sel-s (caddr children))
(check-true (selector? sel-s))
(check-equal? (node-key sel-s) "s")

;; ─── find-child ─────────────────────────────────────────────────

(check-equal? (find-child tree "a") cmd-a)
(check-equal? (find-child tree "w") group-w)
(check-equal? (find-child tree "s") sel-s)
(check-false (find-child tree "z") "unknown key returns #f")

;; ─── Modal Navigation ──────────────────────────────────────────

;; Track side effects
(define executed-action #f)
(define opened-chooser #f)
(define overlay-shown #f)
(define overlay-hidden #f)

;; Install test overlay hooks
(set-overlay-hooks!
 #:show (lambda (root path) (set! overlay-shown (list root path)))
 #:update (lambda (root path) (set! overlay-shown (list root path)))
 #:hide (lambda () (set! overlay-hidden #t))
 #:open-chooser (lambda (node) (set! opened-chooser node))
 #:open? (lambda () #f))

;; Test: enter and immediate exit
(set-overlay-delay! 0)  ;; no delay for testing
(modal-enter tree 64)   ;; F17 as leader
(check-true modal-active?)
(check-equal? modal-current-path '())

(modal-exit)
(check-false modal-active?)
(check-true overlay-hidden)

;; Test: enter → press command key → action executed
(set! executed-action #f)
(set! overlay-hidden #f)

;; Build a tree with a trackable action
(clear-trees!)
(register-tree! 'global
  (list (cons 'kind 'command) (cons 'key "a") (cons 'label "Test")
        (cons 'action (lambda () (set! executed-action 'ran)))))

(define test-tree (lookup-tree 'global))
(modal-enter test-tree 64)
(check-true modal-active?)

(modal-handle-key "a")
(check-false modal-active? "modal should exit after command")
(check-equal? executed-action 'ran "action should have executed")

;; Test: enter → navigate group → step back
(clear-trees!)
(register-tree! 'global
  (list (cons 'kind 'group) (cons 'key "w") (cons 'label "Win")
        (cons 'children
              (list
                (list (cons 'kind 'command) (cons 'key "h") (cons 'label "Half")
                      (cons 'action (lambda () (set! executed-action 'half))))))))

(define test-tree-2 (lookup-tree 'global))
(set! overlay-hidden #f)
(modal-enter test-tree-2 64)

(modal-handle-key "w")
(check-true modal-active? "still active in group")
(check-equal? modal-current-path '("w"))

;; Step back
(modal-step-back)
(check-true modal-active? "still active after step-back to root")
(check-equal? modal-current-path '())

;; Step back from root exits
(modal-step-back)
(check-false modal-active? "step-back from root exits modal")

;; Test: navigate group → execute nested command
(modal-enter test-tree-2 64)
(modal-handle-key "w")
(set! executed-action #f)
(modal-handle-key "h")
(check-false modal-active?)
(check-equal? executed-action 'half)

;; Test: unknown key exits modal
(modal-enter test-tree-2 64)
(modal-handle-key "z")
(check-false modal-active? "unknown key should exit modal")

;; Test: selector opens chooser
(clear-trees!)
(set! opened-chooser #f)
(register-tree! 'global
  (list (cons 'kind 'selector) (cons 'key "s") (cons 'label "Search")))

(define test-tree-3 (lookup-tree 'global))
(modal-enter test-tree-3 64)
(modal-handle-key "s")
(check-false modal-active?)
(check-not-false opened-chooser "chooser should have opened")

(displayln "test-state-machine: all checks passed")
