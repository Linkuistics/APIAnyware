#lang racket/base
;; tests/test-chooser-render.rkt — Tests for chooser rendering (pure functions)
;;
;; Tests HTML generation for the chooser panel without needing a running
;; app or WKWebView. Verifies highlight-matches, render-chooser-row,
;; render-action-panel, and the full render-chooser-html.

(require rackunit
         racket/string
         "../ui/dom.rkt"
         "../ui/chooser.rkt"
         "../lib/fuzzy-match.rkt")

;; ─── Test Data ──────────────────────────────────────────────

(define test-items
  (list
   (list (cons 'text "Safari")
         (cons 'path "/Applications/Safari.app")
         (cons 'kind "file"))
   (list (cons 'text "Terminal")
         (cons 'path "/Applications/Utilities/Terminal.app")
         (cons 'kind "file"))
   (list (cons 'text "Development")
         (cons 'path "/Users/antony/Development")
         (cons 'kind "directory"))
   (list (cons 'text "Signal")
         (cons 'path "/Applications/Signal.app")
         (cons 'kind "file"))))

;; Build visible items from fuzzy filter results
(define test-texts (map (lambda (item) (cdr (assoc 'text item))) test-items))

;; ─── highlight-matches ──────────────────────────────────────

(test-case "highlight-matches: no indices, no spans"
  (define html (html->string (highlight-matches "hello" '())))
  (check-equal? html "hello"))

(test-case "highlight-matches: all indices"
  (define html (html->string (highlight-matches "abc" '(0 1 2))))
  (check-true (string-contains? html "<span class=\"match\">a</span>"))
  (check-true (string-contains? html "<span class=\"match\">b</span>"))
  (check-true (string-contains? html "<span class=\"match\">c</span>")))

(test-case "highlight-matches: partial indices"
  (define html (html->string (highlight-matches "hello" '(0 2 4))))
  ;; 'h', 'l' (first), 'o' should be wrapped
  (check-true (string-contains? html "<span class=\"match\">h</span>"))
  (check-true (string-contains? html "<span class=\"match\">l</span>"))
  (check-true (string-contains? html "<span class=\"match\">o</span>"))
  ;; 'e' and second 'l' should NOT be wrapped
  (check-false (string-contains? html "<span class=\"match\">e</span>")))

(test-case "highlight-matches: HTML escapes special characters"
  (define html (html->string (highlight-matches "<b>&" '(0))))
  (check-true (string-contains? html "&lt;"))
  (check-true (string-contains? html "&amp;"))
  ;; The '<' at index 0 should be matched and wrapped
  (check-true (string-contains? html "<span class=\"match\">&lt;</span>")))

(test-case "highlight-matches: empty string"
  (define html (html->string (highlight-matches "" '())))
  (check-equal? html ""))

;; ─── build-visible-items ────────────────────────────────────

(test-case "build-visible-items: maps fuzzy-filter results correctly"
  (define fuzzy-results '((0 50 (0 1)) (2 30 (0 1 2))))
  (define texts '("Safari" "Terminal" "Development" "Signal"))
  (define visible (build-visible-items fuzzy-results texts))
  (check-equal? (length visible) 2)
  ;; First item: index 0, text "Safari", indices (0 1)
  (check-equal? (car (car visible)) 0)
  (check-equal? (cadr (car visible)) "Safari")
  (check-equal? (caddr (car visible)) '(0 1))
  ;; Second item: index 2, text "Development", indices (0 1 2)
  (check-equal? (car (cadr visible)) 2)
  (check-equal? (cadr (cadr visible)) "Development"))

;; ─── render-chooser-row ─────────────────────────────────────

(test-case "render-chooser-row: file item with path shows two-line layout"
  (define item (list 0 "/Applications/Safari.app" '(14 15)))
  (define source (list-ref test-items 0))
  (define html (html->string (render-chooser-row item source 0 0)))
  ;; Selected row
  (check-true (string-contains? html "chooser-row selected"))
  ;; Has content wrapper and subtext
  (check-true (string-contains? html "chooser-row-content"))
  (check-true (string-contains? html "chooser-row-subtext"))
  ;; Display text (Safari) shown without highlights for files
  (check-true (string-contains? html "Safari"))
  ;; Path subtext shows with match highlights
  (check-true (string-contains? html "chooser-row-subtext")))

(test-case "render-chooser-row: directory item highlights display text"
  (define item (list 2 "Development" '(0 1 2)))
  (define source (list-ref test-items 2))
  (define html (html->string (render-chooser-row item source 0 0)))
  ;; Directory gets special class
  (check-true (string-contains? html "chooser-dir"))
  ;; Display text has match spans
  (check-true (string-contains? html "<span class=\"match\">")))

(test-case "render-chooser-row: unselected row"
  (define item (list 1 "Terminal" '()))
  (define source (list-ref test-items 1))
  (define html (html->string (render-chooser-row item source 1 0)))
  ;; Row 1 is not selected (selected = 0)
  (check-true (string-contains? html "class=\"chooser-row\""))
  (check-false (string-contains? html "chooser-row selected")))

(test-case "render-chooser-row: item without path shows single-line"
  (define simple-item (list (cons 'text "Quick Note")))
  (define item (list 0 "Quick Note" '(0 5)))
  (define html (html->string (render-chooser-row item simple-item 0 0)))
  ;; No subtext div
  (check-false (string-contains? html "chooser-row-subtext"))
  ;; Match highlights in search text
  (check-true (string-contains? html "<span class=\"match\">")))

;; ─── render-action-panel ────────────────────────────────────

(define test-actions
  (list
   (list (cons 'name "Open")
         (cons 'description "Launch or focus")
         (cons 'key 'primary)
         (cons 'run (lambda (c) (void))))
   (list (cons 'name "Show in Finder")
         (cons 'description "Reveal in Finder")
         (cons 'key 'secondary)
         (cons 'run (lambda (c) (void))))
   (list (cons 'name "Copy Path")
         (cons 'description "Copy full path")
         (cons 'run (lambda (c) (void))))))

(test-case "render-action-panel: shows all actions"
  (define html (html->string (render-action-panel test-actions 0)))
  (check-true (string-contains? html "chooser-actions"))
  (check-true (string-contains? html "Actions"))
  (check-true (string-contains? html "Open"))
  (check-true (string-contains? html "Show in Finder"))
  (check-true (string-contains? html "Copy Path")))

(test-case "render-action-panel: first action is selected"
  (define html (html->string (render-action-panel test-actions 0)))
  ;; First action should have selected class
  (check-true (string-contains? html "chooser-action-item selected")))

(test-case "render-action-panel: primary action shows return symbol"
  (define html (html->string (render-action-panel test-actions 0)))
  ;; ↵ (U+21B5) for primary
  (check-true (string-contains? html "\u21b5")))

(test-case "render-action-panel: secondary action shows cmd+return symbol"
  (define html (html->string (render-action-panel test-actions 0)))
  ;; ⌘↵ (U+2318 U+21B5) for secondary
  (check-true (string-contains? html "\u2318\u21b5")))

(test-case "render-action-panel: descriptions shown"
  (define html (html->string (render-action-panel test-actions 0)))
  (check-true (string-contains? html "Launch or focus"))
  (check-true (string-contains? html "Reveal in Finder")))

;; ─── render-chooser-html ────────────────────────────────────

(test-case "render-chooser-html: full document structure"
  (define visible '((0 "Safari" ()) (1 "Terminal" ())))
  (define html (render-chooser-html "Find app…" visible "" 0 #f '() 0
                                    #:items test-items))
  ;; Full HTML document
  (check-true (string-contains? html "<!DOCTYPE html>"))
  (check-true (string-contains? html "<html>"))
  (check-true (string-contains? html "</html>"))
  ;; Contains CSS
  (check-true (string-contains? html "<style>"))
  ;; Contains JS (chooser.js)
  (check-true (string-contains? html "<script>"))
  (check-true (string-contains? html "updateResults"))
  ;; Contains chooser structure
  (check-true (string-contains? html "chooser-search"))
  (check-true (string-contains? html "chooser-results"))
  (check-true (string-contains? html "chooser-footer"))
  ;; Prompt text
  (check-true (string-contains? html "Find app")))

(test-case "render-chooser-html: shows item count in footer"
  (define visible '((0 "a" ()) (1 "b" ()) (2 "c" ())))
  (define html (render-chooser-html "Test" visible "" 0 #f '() 0
                                    #:items test-items))
  (check-true (string-contains? html "3 items")))

(test-case "render-chooser-html: singular item count"
  (define visible '((0 "a" ())))
  (define html (render-chooser-html "Test" visible "" 0 #f '() 0
                                    #:items test-items))
  (check-true (string-contains? html "1 item"))
  ;; Make sure it's "1 item" not "1 items"
  (check-false (string-contains? html "1 items")))

(test-case "render-chooser-html: no action panel when not visible"
  (define html (render-chooser-html "Test" '() "" 0 #f test-actions 0
                                    #:items '()))
  ;; The text "Actions" only appears in the action panel title div, not in CSS.
  ;; When hidden, only the CSS rules reference "chooser-actions" classes.
  (check-false (string-contains? html ">Actions<")))

(test-case "render-chooser-html: action panel shown when visible"
  (define html (render-chooser-html "Test" '() "" 0 #t test-actions 0
                                    #:items '()))
  (check-true (string-contains? html "chooser-actions"))
  (check-true (string-contains? html "Open")))

(test-case "render-chooser-html: search input has correct attributes"
  (define html (render-chooser-html "Test" '() "saf" 0 #f '() 0
                                    #:items '()))
  (check-true (string-contains? html "chooser-input"))
  (check-true (string-contains? html "autocomplete=\"off\"")))

;; ─── alist-ref ──────────────────────────────────────────────

(test-case "alist-ref: finds existing key"
  (define a '((name . "hello") (age . 42)))
  (check-equal? (alist-ref a 'name) "hello")
  (check-equal? (alist-ref a 'age) 42))

(test-case "alist-ref: returns default for missing key"
  (define a '((name . "hello")))
  (check-false (alist-ref a 'missing))
  (check-equal? (alist-ref a 'missing "default") "default"))

;; ─── Integration: fuzzy-match → visible-items → render ──────

(test-case "end-to-end: fuzzy match to rendered HTML"
  ;; Simulate the full pipeline: items → fuzzy-filter → visible → render
  (define items
    (list (list (cons 'text "Safari"))
          (list (cons 'text "Terminal"))
          (list (cons 'text "Signal"))))
  (define texts (map (lambda (i) (cdr (assoc 'text i))) items))
  (define results (fuzzy-filter "sa" texts))
  (define visible (build-visible-items results texts))
  (define html (render-chooser-html "Find app…" visible "sa" 0 #f '() 0
                                    #:items items))
  ;; Safari text appears (split by match spans: S + a + fari)
  (check-true (string-contains? html "fari"))
  ;; Should have match highlight spans
  (check-true (string-contains? html "<span class=\"match\">")))

(displayln "test-chooser-render: all tests passed")
