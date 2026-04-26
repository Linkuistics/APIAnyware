#lang racket/base
;; tests/test-overlay-render.rkt — Tests for overlay rendering (pure functions)
;;
;; Tests the HTML generation parts of ui/overlay.rkt without needing
;; a running app or WKWebView. Uses state-machine.rkt's register-tree!/
;; node construction to build test trees.

(require rackunit
         racket/string
         "../core/state-machine.rkt"
         "../ui/dom.rkt"
         "../ui/overlay.rkt")

;; ─── Test Tree Construction ──────────────────────────────────
;; Build trees using the same alist structure as state-machine.rkt

(define (make-command key label action)
  (list (cons 'kind 'command)
        (cons 'key key)
        (cons 'label label)
        (cons 'action action)))

(define (make-group key label children)
  (list (cons 'kind 'group)
        (cons 'key key)
        (cons 'label label)
        (cons 'children children)))

;; A test tree:
;;   Global
;;   ├── w → Windows...
;;   │   ├── c → Center
;;   │   └── f → Fullscreen
;;   ├── a → Apps...
;;   │   └── t → Terminal
;;   └── q → Quit

(define test-tree
  (make-group "" "Global"
    (list
      (make-group "w" "Windows"
        (list
          (make-command "c" "Center" (lambda () 'center))
          (make-command "f" "Fullscreen" (lambda () 'fullscreen))))
      (make-group "a" "Apps"
        (list
          (make-command "t" "Terminal" (lambda () 'terminal))))
      (make-command "q" "Quit" (lambda () 'quit)))))

;; ─── render-breadcrumb ───────────────────────────────────────

(test-case "render-breadcrumb: root level (empty path)"
  (define html (html->string (render-breadcrumb "Global" '())))
  (check-true (string-contains? html "overlay-header"))
  (check-true (string-contains? html "breadcrumb"))
  (check-true (string-contains? html "Global"))
  ;; No separator at root
  (check-false (string-contains? html "breadcrumb-sep")))

(test-case "render-breadcrumb: one level deep"
  (define html (html->string (render-breadcrumb "Global" '("w"))))
  (check-true (string-contains? html "Global"))
  (check-true (string-contains? html "w"))
  (check-true (string-contains? html "breadcrumb-sep")))

(test-case "render-breadcrumb: two levels deep"
  (define html (html->string (render-breadcrumb "Root" '("a" "b"))))
  (check-true (string-contains? html "Root"))
  (check-true (string-contains? html "a"))
  (check-true (string-contains? html "b")))

;; ─── render-entry ────────────────────────────────────────────

(test-case "render-entry: command"
  (define entry (make-command "q" "Quit" (lambda () 'quit)))
  (define html (html->string (render-entry entry)))
  (check-true (string-contains? html "overlay-entry"))
  (check-true (string-contains? html "entry-key"))
  (check-true (string-contains? html "q"))
  (check-true (string-contains? html "Quit"))
  ;; Commands don't get group-label class or ellipsis
  (check-false (string-contains? html "group-label"))
  (check-false (string-contains? html "\u2026")))

(test-case "render-entry: group shows ellipsis and group-label class"
  (define entry (make-group "w" "Windows" '()))
  (define html (html->string (render-entry entry)))
  (check-true (string-contains? html "group-label"))
  (check-true (string-contains? html "\u2026"))
  (check-true (string-contains? html "Windows")))

(test-case "render-entry: space key shows open box symbol"
  (define entry (make-command " " "Space Action" (lambda () 'space)))
  (define html (html->string (render-entry entry)))
  (check-true (string-contains? html "\u2423")))

;; ─── render-overlay-body ─────────────────────────────────────

(test-case "render-overlay-body: root level shows all children"
  (define html (html->string (render-overlay-body test-tree '())))
  ;; Should contain breadcrumb with "Global"
  (check-true (string-contains? html "Global"))
  ;; Should contain all three children
  (check-true (string-contains? html "Windows"))
  (check-true (string-contains? html "Apps"))
  (check-true (string-contains? html "Quit"))
  ;; Children should be sorted alphabetically by key: a, q, w
  (define (find-pos str sub)
    (car (car (regexp-match-positions (regexp-quote sub) str))))
  (define a-pos (find-pos html "Apps"))
  (define q-pos (find-pos html "Quit"))
  (define w-pos (find-pos html "Windows"))
  (check-true (< a-pos q-pos))
  (check-true (< q-pos w-pos)))

(test-case "render-overlay-body: navigate to sub-group"
  (define html (html->string (render-overlay-body test-tree '("w"))))
  ;; Should show Windows children
  (check-true (string-contains? html "Center"))
  (check-true (string-contains? html "Fullscreen"))
  ;; Should NOT show root-level entries
  (check-false (string-contains? html "Quit")))

;; ─── render-overlay-html ─────────────────────────────────────

(test-case "render-overlay-html: full document structure"
  (define html (render-overlay-html test-tree '()))
  ;; Full HTML document
  (check-true (string-contains? html "<!DOCTYPE html>"))
  (check-true (string-contains? html "<html>"))
  (check-true (string-contains? html "</html>"))
  ;; Contains CSS
  (check-true (string-contains? html "<style>"))
  (check-true (string-contains? html "--overlay-bg"))
  ;; Contains JS
  (check-true (string-contains? html "<script>"))
  (check-true (string-contains? html "updateOverlay"))
  ;; Contains overlay content
  (check-true (string-contains? html "overlay-entries")))

(test-case "render-overlay-html: includes custom CSS"
  (set-overlay-css! ".custom { color: purple; }")
  (define html (render-overlay-html test-tree '()))
  (check-true (string-contains? html ".custom"))
  (check-true (string-contains? html "purple"))
  ;; Reset
  (set-overlay-css! ""))

;; ─── js-escape-overlay (indirectly via render) ───────────────

(test-case "render-entry: handles special characters in labels"
  (define entry (make-command "x" "Say \"hello\"" (lambda () 'x)))
  (define html (html->string (render-entry entry)))
  ;; The label should be HTML-escaped
  (check-true (string-contains? html "&quot;")))

(displayln "test-overlay-render: all tests passed")
