#lang racket/base
;; test-dsl.rkt — Tests for lib/dsl.rkt

(require rackunit
         "../lib/dsl.rkt"
         "../core/state-machine.rkt")

;; ─── key ────────────────────────────────────────────────────────

(define cmd (key "a" "Launch App" (lambda () 'launched)))
(check-true (command? cmd))
(check-equal? (node-key cmd) "a")
(check-equal? (node-label cmd) "Launch App")
(check-equal? ((node-action cmd)) 'launched)

;; ─── group ──────────────────────────────────────────────────────

(define grp (group "w" "Windows"
              (key "h" "Left" (lambda () 'left))
              (key "l" "Right" (lambda () 'right))))
(check-true (group? grp))
(check-equal? (node-key grp) "w")
(check-equal? (node-label grp) "Windows")
(check-equal? (length (node-children grp)) 2)

(define left-cmd (find-child grp "h"))
(check-not-false left-cmd)
(check-true (command? left-cmd))
(check-equal? (node-label left-cmd) "Left")

;; ─── selector ───────────────────────────────────────────────────

(define sel (selector "s" "Search" 'items '("a" "b" "c") 'on-select displayln))
(check-true (selector? sel))
(check-equal? (node-key sel) "s")
(check-equal? (node-label sel) "Search")
;; Check custom properties
(check-equal? (cdr (assoc 'items sel)) '("a" "b" "c"))
(check-equal? (cdr (assoc 'on-select sel)) displayln)

;; ─── action ─────────────────────────────────────────────────────

(define act (action "Copy" 'icon "doc.on.doc" 'handler (lambda () 'copied)))
(check-equal? (cdr (assoc 'name act)) "Copy")
(check-equal? (cdr (assoc 'icon act)) "doc.on.doc")

;; ─── define-tree ────────────────────────────────────────────────

(clear-trees!)

(define-tree 'global
  (key "a" "Terminal" (lambda () 'term))
  (group "w" "Windows"
    (key "h" "Left" (lambda () 'left))
    (key "l" "Right" (lambda () 'right)))
  (selector "s" "Search"))

(define tree (lookup-tree 'global))
(check-not-false tree "define-tree should register the tree")
(check-true (group? tree))
(check-equal? (node-label tree) "Global")

(define tree-children (node-children tree))
(check-equal? (length tree-children) 3)

;; Navigate the tree built by DSL
(define term-cmd (find-child tree "a"))
(check-true (command? term-cmd))
(check-equal? ((node-action term-cmd)) 'term)

(define win-grp (find-child tree "w"))
(check-true (group? win-grp))
(define left (find-child win-grp "h"))
(check-true (command? left))
(check-equal? ((node-action left)) 'left)

(define search-sel (find-child tree "s"))
(check-true (selector? search-sel))

;; ─── Multiple trees ─────────────────────────────────────────────

(define-tree "com.apple.Safari"
  (key "r" "Reload" (lambda () 'reload)))

(check-not-false (lookup-tree "com.apple.Safari"))
(check-not-false (lookup-tree 'global) "global tree should still exist")

;; ─── Full modal cycle with DSL-built tree ───────────────────────

(set-overlay-delay! 0)
(set-overlay-hooks!
 #:show (lambda (r p) (void))
 #:update (lambda (r p) (void))
 #:hide (lambda () (void))
 #:open-chooser (lambda (n) (void))
 #:open? (lambda () #f))

(define action-result #f)
(clear-trees!)
(define-tree 'global
  (group "w" "Windows"
    (key "h" "Left Half" (lambda () (set! action-result 'left-half)))))

(modal-enter (lookup-tree 'global) 64)
(check-true modal-active?)
(modal-handle-key "w")
(check-true modal-active?)
(check-equal? modal-current-path '("w"))
(modal-handle-key "h")
(check-false modal-active?)
(check-equal? action-result 'left-half)

(displayln "test-dsl: all checks passed")
