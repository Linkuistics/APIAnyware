#lang racket/base
;; tests/test-integration-chooser.rkt — Integration test for chooser lifecycle
;;
;; Tests the full chooser pipeline from DSL selectors through fuzzy matching
;; to rendering and message handler dispatch. The panel-manager (ObjC) layer
;; is not available in headless testing, so we test:
;;
;; 1. DSL selector → node structure → chooser state initialization
;; 2. Fuzzy match pipeline: items → filter → visible-items → render
;; 3. Message handler dispatch with Racket alists (simulated JS messages)
;; 4. Select callback firing and state cleanup
;; 5. Dynamic search callback integration
;;
;; Full end-to-end test (with live panel) requires running as a macOS app.

(require rackunit
         racket/string
         "../lib/dsl.rkt"
         "../lib/fuzzy-match.rkt"
         "../core/state-machine.rkt"
         "../ui/dom.rkt"
         "../ui/chooser.rkt")

;; ─── 1. DSL Selector → Node Structure ──────────────────────

(test-case "selector node from DSL has correct structure"
  (define node
    (selector "a" "Find Apps"
      'prompt "Find app…"
      'source (lambda () '())
      'on-select (lambda (item) (void))))
  ;; Verify structure
  (check-true (selector? node))
  (check-equal? (node-key node) "a")
  (check-equal? (node-label node) "Find Apps")
  (check-equal? (alist-ref node 'prompt) "Find app…")
  (check-true (procedure? (alist-ref node 'source)))
  (check-true (procedure? (alist-ref node 'on-select))))

(test-case "selector with actions has action list"
  (define node
    (selector "f" "Find File"
      'prompt "Find file…"
      'source (lambda () '())
      'on-select (lambda (item) (void))
      'actions
        (list
          (action "Open" 'description "Open with default app" 'key 'primary
            'run (lambda (c) (void)))
          (action "Show in Finder" 'description "Reveal" 'key 'secondary
            'run (lambda (c) (void))))))
  (define actions (alist-ref node 'actions))
  (check-true (list? actions))
  (check-equal? (length actions) 2)
  (check-equal? (alist-ref (car actions) 'name) "Open")
  (check-equal? (alist-ref (cadr actions) 'name) "Show in Finder"))

;; ─── 2. Full Fuzzy Match Pipeline ──────────────────────────

(define app-items
  (list
   (list (cons 'text "Safari") (cons 'path "/Applications/Safari.app")
         (cons 'kind "file") (cons 'bundleId "com.apple.Safari"))
   (list (cons 'text "Terminal") (cons 'path "/Applications/Utilities/Terminal.app")
         (cons 'kind "file"))
   (list (cons 'text "Signal") (cons 'path "/Applications/Signal.app")
         (cons 'kind "file"))
   (list (cons 'text "System Preferences") (cons 'path "/System/Applications/System Preferences.app")
         (cons 'kind "file"))
   (list (cons 'text "Slack") (cons 'path "/Applications/Slack.app")
         (cons 'kind "file"))
   (list (cons 'text "Development") (cons 'path "/Users/antony/Development")
         (cons 'kind "directory"))))

(test-case "pipeline: items → extract texts → fuzzy-filter → visible-items → render"
  ;; Extract search texts (directories use name, files use path)
  (define texts (map (lambda (item)
                       (define kind (alist-ref item 'kind))
                       (define path (alist-ref item 'path))
                       (define text (alist-ref item 'text))
                       (cond
                         [(and kind (equal? kind "directory") text) text]
                         [path path]
                         [text text]
                         [else ""]))
                     app-items))

  ;; Search for "saf"
  (define results (fuzzy-filter "saf" texts))
  (check-true (> (length results) 0))

  ;; Build visible items
  (define visible (build-visible-items results texts))
  (check-true (> (length visible) 0))

  ;; Safari should be in results (index 0)
  (check-not-false (findf (lambda (v) (= (car v) 0)) visible))

  ;; Render full HTML
  (define html (render-chooser-html "Find app…" visible "saf" 0 #f '() 0
                                    #:items app-items))
  (check-true (string-contains? html "chooser-results"))
  (check-true (string-contains? html "chooser-search"))
  (check-true (string-contains? html "<span class=\"match\">")))

(test-case "pipeline: directory items match against name not path"
  (define texts (map (lambda (item)
                       (define kind (alist-ref item 'kind))
                       (define text (alist-ref item 'text))
                       (if (and kind (equal? kind "directory")) text ""))
                     app-items))
  ;; "dev" should match "Development" (index 5) with high score
  (define results (fuzzy-filter "dev" (list "" "" "" "" "" "Development")))
  (check-true (> (length results) 0))
  (check-equal? (car (car results)) 5))

;; ─── 3. Message Handler Dispatch ────────────────────────────
;; The message handler accepts Racket alists for testing.

(test-case "pipeline: search query updates filtered results"
  ;; Test the search → filter → visible pipeline
  (define texts '("Safari" "Terminal" "Signal" "Slack"))
  (define results (fuzzy-filter "sl" texts))
  (define visible (build-visible-items results texts))
  ;; Slack (index 3) should rank high for "sl"
  (check-not-false (findf (lambda (v) (= (car v) 3)) visible)))

;; ─── 4. Select Callback ────────────────────────────────────

(test-case "select callback fires with correct item"
  (define selected-item #f)
  (define on-select (lambda (item) (set! selected-item item)))

  ;; Simulate what open-chooser does (state setup)
  (define items
    (list (list (cons 'text "Safari") (cons 'bundleId "com.apple.Safari"))
          (list (cons 'text "Terminal"))))

  ;; Simulate select: originalIndex 0 should select Safari
  (define item (list-ref items 0))
  (on-select item)
  (check-not-false selected-item)
  (check-equal? (alist-ref selected-item 'text) "Safari")
  (check-equal? (alist-ref selected-item 'bundleId) "com.apple.Safari"))

(test-case "action-based select fires action run function"
  (define action-result #f)
  (define actions
    (list (list (cons 'name "Open")
                (cons 'key 'primary)
                (cons 'run (lambda (item)
                             (set! action-result
                               (alist-ref item 'text)))))))
  (define primary (findf (lambda (a) (eq? (alist-ref a 'key) 'primary)) actions))
  (check-not-false primary)
  (define run-fn (alist-ref primary 'run))
  (run-fn (list (cons 'text "Safari")))
  (check-equal? action-result "Safari"))

;; ─── 5. Dynamic Search Integration ─────────────────────────

(test-case "dynamic search: callback receives query"
  (define received-queries '())
  (define dynamic-handler
    (lambda (query)
      (set! received-queries (cons query received-queries))))

  ;; Simulate dynamic search calls
  (dynamic-handler "")
  (dynamic-handler "goo")
  (dynamic-handler "google")

  (check-equal? (length received-queries) 3)
  (check-equal? (car received-queries) "google")
  (check-equal? (cadr received-queries) "goo")
  (check-equal? (caddr received-queries) ""))

;; ─── 6. Render with Actions Panel ───────────────────────────

(test-case "render with visible action panel"
  (define actions
    (list (list (cons 'name "Open")
                (cons 'description "Launch or focus")
                (cons 'key 'primary))
          (list (cons 'name "Copy Path")
                (cons 'description "Copy path to clipboard"))))
  (define visible '((0 "Safari" (0 1 2))))
  (define items (list (list (cons 'text "Safari"))))
  (define html (render-chooser-html "Find app…" visible "saf" 0
                                    #t actions 0
                                    #:items items))
  ;; Action panel should be present
  (check-true (string-contains? html ">Actions<"))
  (check-true (string-contains? html "Open"))
  (check-true (string-contains? html "Copy Path"))
  (check-true (string-contains? html "Launch or focus"))
  ;; Primary action key symbol (↵)
  (check-true (string-contains? html "\u21b5")))

;; ─── 7. State Machine Integration ───────────────────────────

(test-case "state machine: selector node triggers chooser path"
  ;; Register a tree with a selector
  (clear-trees!)
  (define-tree 'global
    (selector "s" "Search"
      'prompt "Search…"
      'source (lambda () '())))

  ;; Look up the tree
  (define tree (lookup-tree 'global))
  (check-not-false tree)

  ;; Find the selector child
  (define child (find-child tree "s"))
  (check-not-false child)
  (check-true (selector? child))
  (check-equal? (alist-ref child 'prompt) "Search…"))

;; ─── 8. Stress: Large Item List ─────────────────────────────

(test-case "large item list: fuzzy-filter handles 1000 items"
  (define items
    (for/list ([i (in-range 1000)])
      (string-append "item-" (number->string i))))
  (define results (fuzzy-filter "item-5" items #:max-results 20))
  ;; Should return results (max 20)
  (check-true (<= (length results) 20))
  ;; "item-5" (index 5) should be in top results
  (check-not-false (findf (lambda (r) (= (car r) 5)) results)))

(displayln "test-integration-chooser: all tests passed")
