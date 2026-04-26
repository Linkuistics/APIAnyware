#lang racket/base
;; ui/chooser.rkt — Search/select UI using WebView
;;
;; An activating panel with a search input, filtered result list,
;; and optional action panel. Used by selector nodes in the command tree.
;;
;; Pure API (testable):
;;   (render-chooser-html prompt visible-items query selected-index
;;     actions-visible? actions action-index) → full HTML document string
;;   (highlight-matches text indices) → raw-html with match spans
;;   (render-chooser-row item source-item row-index selected) → raw-html
;;   (render-action-panel actions action-index) → raw-html
;;
;; Side-effecting API:
;;   (open-chooser selector-node)  — open chooser with source data
;;   (close-chooser)               — close chooser and clean up
;;   (chooser-open?)               — is the chooser currently shown?

(require racket/file
         racket/runtime-path
         racket/string
         "../ui/dom.rkt"
         "../ui/panel-manager.rkt"
         "../lib/events.rkt"
         "../lib/fuzzy-match.rkt"
         "../lib/mru-store.rkt"
         "../ffi/main-thread.rkt")

(provide ;; Pure rendering
         render-chooser-html
         render-chooser-row
         render-action-panel
         highlight-matches
         build-visible-items

         ;; Side-effecting lifecycle
         open-chooser
         close-chooser
         chooser-open?

         ;; For overlay.rkt to share CSS with chooser
         set-chooser-css!

         ;; Hook for file indexing (set by services layer)
         set-index-files-fn!

         ;; For testing — expose alist-ref
         alist-ref)

;; ─── Resource Paths ─────────────────────────────────────────

(define-runtime-path base-css-path "base.css")
(define-runtime-path chooser-js-path "chooser.js")

;; ─── CSS/JS Loading ─────────────────────────────────────────

(define chooser-base-css (file->string base-css-path))
(define chooser-js (file->string chooser-js-path))

;; ─── Chooser State ──────────────────────────────────────────

(define chooser-webview-id "modaliser-chooser")
(define chooser-is-open? #f)
(define chooser-items '())             ; raw items from source (list of alists)
(define chooser-item-texts '())        ; search texts extracted from items
(define chooser-filtered '())          ; filtered results: ((index search-text (matched-indices...)) ...)
(define chooser-selected-index 0)      ; index into chooser-filtered
(define chooser-query "")
(define chooser-actions-visible? #f)
(define chooser-selector-node #f)      ; the selector alist
(define chooser-action-index 0)        ; index into actions list when panel visible
(define chooser-dynamic-search #f)     ; dynamic-search callback or #f
(define chooser-custom-css "")         ; custom CSS from overlay theming
(define chooser-search-generation 0)   ; generation counter for async search

(define (chooser-open?) chooser-is-open?)

(define (set-chooser-css! css)
  (set! chooser-custom-css css))

;; ─── File Indexing Hook ─────────────────────────────────────
;; Set by the services layer to provide file enumeration for
;; selectors with 'file-roots property. Signature: (list-of-paths) → items.
(define index-files-fn #f)

(define (set-index-files-fn! fn)
  (set! index-files-fn fn))

;; ─── Panel Configuration ────────────────────────────────────

(define chooser-panel-width 500)
(define chooser-panel-height 420)
(define chooser-max-visible-rows 50)

;; ─── Alist Helpers ──────────────────────────────────────────

;; (alist-ref alist key [default]) → value or default
(define (alist-ref alist key [default #f])
  (define pair (assoc key alist))
  (if pair (cdr pair) default))

;; ─── Item Text Extraction ───────────────────────────────────

;; Extract search text from a source item (alist).
;; Directories match against name; files against full path.
(define (item-search-text item)
  (define kind (alist-ref item 'kind))
  (define path (alist-ref item 'path))
  (define text (alist-ref item 'text))
  (cond
    [(and kind (equal? kind "directory") text) text]
    [path path]
    [text text]
    [else ""]))

;; Extract display text from a source item.
(define (item-display-text item)
  (alist-ref item 'text ""))

;; Extract search texts from all items.
(define (extract-item-texts items)
  (map item-search-text items))

;; Build visible items list from fuzzy-filter results.
;; fuzzy-results: ((original-index score (matched-indices...)) ...)
;; item-texts: list of search text strings
(define (build-visible-items fuzzy-results item-texts-list)
  (map (lambda (result)
         (define orig-index (car result))
         (define indices (caddr result))
         (define text (list-ref item-texts-list orig-index))
         (list orig-index text indices))
       fuzzy-results))

;; ─── Highlight Matches ──────────────────────────────────────

;; (highlight-matches text indices) → raw-html
;; Wraps characters at given indices in <span class="match">.
(define (highlight-matches text indices)
  (define chars (string->list text))
  (make-raw-html
   (let loop ([i 0] [rest chars] [result ""])
     (if (null? rest)
         result
         (let* ([c (car rest)]
                [escaped (html-escape (string c))]
                [is-match (and (member i indices) #t)])
           (loop (add1 i) (cdr rest)
                 (string-append result
                   (if is-match
                       (string-append "<span class=\"match\">" escaped "</span>")
                       escaped))))))))

;; ─── Rendering (Pure Functions) ─────────────────────────────

;; Render a single result row.
;; item: (index search-text (matched-indices...))
;; source-item: the original alist from chooser-items
;; row-index: position in visible list
;; selected: currently selected row-index
(define (render-chooser-row item source-item row-index selected)
  (define search-text (cadr item))
  (define indices (caddr item))
  (define display-text (item-display-text source-item))
  (define sub-text (alist-ref source-item 'path #f))
  (define kind (alist-ref source-item 'kind #f))
  (define is-dir (and kind (equal? kind "directory")))
  (define is-selected (= row-index selected))
  (define row-class (if is-selected "chooser-row selected" "chooser-row"))

  (if sub-text
      ;; Two-line row: display text + path subtext
      (li (list (cons 'class row-class))
        (div '((class . "chooser-row-content"))
          (span (list (cons 'class (if is-dir
                                       "chooser-row-text chooser-dir"
                                       "chooser-row-text")))
            (if is-dir
                (highlight-matches display-text indices)
                display-text))
          (div '((class . "chooser-row-subtext"))
            (if is-dir
                sub-text
                (highlight-matches search-text indices)))))
      ;; Single-line row: just search text with highlights
      (li (list (cons 'class row-class))
        (span '((class . "chooser-row-text"))
          (highlight-matches search-text indices)))))

;; Render the action panel.
;; actions: list of action alists
;; action-index: currently selected action
(define (render-action-panel actions action-index)
  (div '((class . "chooser-actions"))
    (div '((class . "chooser-actions-title")) "Actions")
    (apply ul (cons '((class . "chooser-action-list"))
                    (let loop ([acts actions] [i 0] [result '()])
                      (if (null? acts)
                          (reverse result)
                          (let* ([act (car acts)]
                                 [name (alist-ref act 'name "")]
                                 [desc (alist-ref act 'description "")]
                                 [act-key (alist-ref act 'key #f)]
                                 [key-label (cond
                                              [(eq? act-key 'primary) "\u21b5"]
                                              [(eq? act-key 'secondary) "\u2318\u21b5"]
                                              [else ""])]
                                 [is-selected (= i action-index)]
                                 [item-class (if is-selected
                                                 "chooser-action-item selected"
                                                 "chooser-action-item")])
                            (loop (cdr acts) (add1 i)
                                  (cons
                                   (li (list (cons 'class item-class))
                                     (span '((class . "chooser-action-key")) key-label)
                                     (span '((class . "chooser-action-label")) name)
                                     (span '((class . "chooser-action-desc")) desc))
                                   result)))))))))

;; (render-chooser-html prompt visible-items query selected-index
;;   actions-visible? actions action-index) → HTML document string
(define (render-chooser-html prompt visible-items query selected-index
                             actions-visible? actions action-index
                             #:items [items '()])
  (define css (if (string=? chooser-custom-css "")
                  chooser-base-css
                  (string-append chooser-base-css "\n" chooser-custom-css)))
  (define item-count (length visible-items))
  (define footer-text (string-append (number->string item-count)
                        (if (= item-count 1) " item" " items")))
  (define body
    (div '((class . "chooser"))
      ;; Search input area
      (div '((class . "chooser-search"))
        (div '((class . "chooser-prompt")) prompt)
        (input-element (list (cons 'type "text")
                             (cons 'class "chooser-input")
                             (cons 'id "chooser-input")
                             (cons 'value query)
                             (cons 'autocomplete "off")
                             (cons 'autofocus "true"))))
      ;; Result list (capped)
      (apply ul (cons '((class . "chooser-results"))
                      (let loop ([vis visible-items] [i 0] [rows '()])
                        (if (or (null? vis) (>= i chooser-max-visible-rows))
                            (reverse rows)
                            (let* ([item (car vis)]
                                   [orig-index (car item)]
                                   [source-item (if (< orig-index (length items))
                                                    (list-ref items orig-index)
                                                    '())])
                              (loop (cdr vis) (add1 i)
                                    (cons (render-chooser-row item source-item i selected-index)
                                          rows)))))))
      ;; Footer
      (div '((class . "chooser-footer")) footer-text)
      ;; Action panel (conditional)
      (if actions-visible?
          (render-action-panel actions action-index)
          (make-raw-html ""))))

  (html-document
   (make-raw-html
    (string-append
     (html->string (style-element '() css))
     (html->string (script-element '() chooser-js))))
   body))

;; ─── JSON Escaping ──────────────────────────────────────────

(define (json-escape str)
  (let loop ([chars (string->list str)] [result '()])
    (if (null? chars)
        (list->string (reverse result))
        (let ([c (car chars)])
          (loop (cdr chars)
                (cond
                  [(char=? c #\\) (append '(#\\ #\\) result)]
                  [(char=? c #\") (append '(#\" #\\) result)]
                  [(char=? c #\newline) (append '(#\n #\\) result)]
                  [(char=? c #\return) (append '(#\r #\\) result)]
                  [(char=? c #\tab) (append '(#\t #\\) result)]
                  [else (cons c result)]))))))

;; JS string escaping (for innerHTML updates)
(define (js-escape str)
  (let loop ([chars (string->list str)] [result '()])
    (if (null? chars)
        (list->string (reverse result))
        (let ([c (car chars)])
          (loop (cdr chars)
                (cond
                  [(char=? c #\\) (append '(#\\ #\\) result)]
                  [(char=? c #\') (append '(#\' #\\) result)]
                  [(char=? c #\newline) (append '(#\n #\\) result)]
                  [(char=? c #\return) (append '(#\r #\\) result)]
                  [else (cons c result)]))))))

;; ─── Search ─────────────────────────────────────────────────
;; Synchronous fuzzy matching with generation counter.
;; Runs on the main thread (fast enough for ~670 items).
;; Racket green threads cannot run while nsapplication-run blocks
;; the scheduler, so async (thread ...) is not viable.

(define (chooser-search! query)
  (set! chooser-search-generation (add1 chooser-search-generation))
  (define gen chooser-search-generation)
  (define items chooser-items)
  (define texts chooser-item-texts)

  (define results (fuzzy-filter query texts))

  (when (= gen chooser-search-generation)
    (define visible (build-visible-items results texts))

    (define json
      (string-append "["
        (let loop ([rest results] [first? #t] [acc ""])
          (if (null? rest)
              acc
              (let* ([r (car rest)]
                     [idx (car r)]
                     [indices (caddr r)]
                     [item (list-ref items idx)]
                     [display-text (json-escape (item-display-text item))]
                     [search-text (json-escape (item-search-text item))]
                     [path (json-escape (alist-ref item 'path ""))]
                     [kind (json-escape (alist-ref item 'kind ""))]
                     [indices-str (string-join
                                   (map number->string indices) ",")]
                     [sep (if first? "" ",")])
                (loop (cdr rest) #f
                      (string-append acc sep
                        "{\"d\":\"" display-text "\""
                        ",\"s\":\"" search-text "\""
                        ",\"p\":\"" path "\""
                        ",\"k\":\"" kind "\""
                        ",\"i\":[" indices-str "]"
                        ",\"x\":" (number->string idx) "}")))))
        "]"))

    (define count (length results))
    (define js-call
      (string-append
       "if(window.updateResults)updateResults("
       json "," (number->string count) ");"))

    (log-event 'chooser 'push 'query query 'results count)
    (set! chooser-filtered visible)
    (panel-eval-js! chooser-webview-id js-call)))

;; ─── Dynamic Chooser Support ────────────────────────────────

;; Push dynamic results to the chooser WebView.
;; Items: list of alists with at minimum a 'text key.
(define (chooser-push-results items)
  ;; Called from the main thread (message handler → dynamic-search path).
  ;; http-get also invokes its callback synchronously on the caller's thread
  ;; now, so the wrapping call-on-main-thread is a no-op fast path but kept
  ;; for robustness if a future caller dispatches from a GCD queue.
  (call-on-main-thread
    (lambda ()
      (when chooser-is-open?
        (set! chooser-items items)
        (set! chooser-selected-index 0)
        ;; Update chooser-filtered for action panel rendering
        (set! chooser-filtered
          (let loop ([rest items] [i 0] [acc '()])
            (if (null? rest)
                (reverse acc)
                (loop (cdr rest) (add1 i)
                      (cons (list i (alist-ref (car rest) 'text "") '()) acc)))))
        (define count (length items))
        (define json
          (string-append "["
            (let loop ([rest items] [i 0] [acc ""])
              (if (null? rest)
                  acc
                  (let* ([item (car rest)]
                         [text (json-escape (alist-ref item 'text ""))]
                         [path (json-escape (alist-ref item 'path ""))]
                         [kind (json-escape (alist-ref item 'kind ""))]
                         [sep (if (= i 0) "" ",")])
                    (loop (cdr rest) (add1 i)
                          (string-append acc sep
                            "{\"d\":\"" text "\""
                            ",\"s\":\"" text "\""
                            ",\"p\":\"" path "\""
                            ",\"k\":\"" kind "\""
                            ",\"i\":[],\"x\":" (number->string i) "}")))))
            "]"))
        (define js-call
          (string-append
           "if(window.updateResults)updateResults("
           json "," (number->string count) ");"))
        (panel-eval-js! chooser-webview-id js-call)))))

;; ─── Chooser Lifecycle ──────────────────────────────────────

;; Load page skeleton — search input + empty results + JS.
;; JS DOMContentLoaded sends "ready" which triggers async search.
(define (chooser-load-skeleton)
  (when chooser-is-open?
    (define prompt (alist-ref chooser-selector-node 'prompt "Select..."))
    (define css (if (string=? chooser-custom-css "")
                    chooser-base-css
                    (string-append chooser-base-css "\n" chooser-custom-css)))
    (define html
      (html-document
       (make-raw-html
        (string-append
         (html->string (style-element '() css))
         (html->string (script-element '() chooser-js))))
       (div '((class . "chooser"))
         (div '((class . "chooser-search"))
           (div '((class . "chooser-prompt")) prompt)
           (input-element (list (cons 'type "text")
                                (cons 'class "chooser-input")
                                (cons 'id "chooser-input")
                                (cons 'value "")
                                (cons 'autocomplete "off")
                                (cons 'autofocus "true"))))
         (ul '((class . "chooser-results")))
         (div '((class . "chooser-footer")) ""))))
    (panel-set-html! chooser-webview-id html)))

;; Full HTML replacement — used for action panel toggle.
(define (chooser-update-html)
  (when chooser-is-open?
    (define prompt (alist-ref chooser-selector-node 'prompt "Select..."))
    (define actions (alist-ref chooser-selector-node 'actions '()))
    (panel-set-html! chooser-webview-id
      (render-chooser-html prompt chooser-filtered chooser-query
                           chooser-selected-index chooser-actions-visible?
                           actions chooser-action-index
                           #:items chooser-items))))

;; (open-chooser selector-node) — open the chooser for a selector.
(define (open-chooser selector-node)
  (define source-fn (alist-ref selector-node 'source #f))
  (define file-roots (alist-ref selector-node 'file-roots #f))
  (define dynamic-search-fn (alist-ref selector-node 'dynamic-search #f))
  (define prompt (alist-ref selector-node 'prompt "Select..."))
  (define actions (alist-ref selector-node 'actions '()))
  (define remember-key (alist-ref selector-node 'remember #f))
  ;; Config passes id-field as a string (e.g., "bundleId") but item alists
  ;; use symbol keys (e.g., 'bundleId). Convert for alist lookup.
  (define id-field-raw (alist-ref selector-node 'id-field #f))
  (define id-field (and id-field-raw
                        (if (string? id-field-raw)
                            (string->symbol id-field-raw)
                            id-field-raw)))
  (define raw-items
    (cond
      [dynamic-search-fn '()]       ; dynamic: no static items
      [source-fn (source-fn)]
      [file-roots                    ; file indexing via index-files hook
       (if index-files-fn
           (index-files-fn file-roots)
           (begin
             (displayln "warning: file-roots selector used but index-files hook not set")
             '()))]
      [else '()]))
  ;; Reorder by MRU if selector has 'remember + 'id-field
  (define items
    (if (and remember-key id-field (not dynamic-search-fn))
        (mru-reorder-items raw-items remember-key id-field)
        raw-items))
  (define texts (extract-item-texts items))
  (define initial-visible
    (if dynamic-search-fn
        '()
        (build-visible-items (fuzzy-filter "" texts) texts)))

  (log-event 'chooser 'open 'selector prompt)

  ;; Set chooser state
  (set! chooser-is-open? #t)
  (set! chooser-items items)
  (set! chooser-item-texts texts)
  (set! chooser-filtered initial-visible)
  (set! chooser-selected-index 0)
  (set! chooser-query "")
  (set! chooser-actions-visible? #f)
  (set! chooser-selector-node selector-node)
  (set! chooser-action-index 0)
  (set! chooser-dynamic-search dynamic-search-fn)
  (set! chooser-search-generation 0)

  ;; Create activating WebView panel
  (create-panel! chooser-webview-id
    #:width chooser-panel-width
    #:height chooser-panel-height
    #:activating #t
    #:floating #t
    #:transparent #t)

  ;; Register message handler
  (panel-set-message-handler! chooser-webview-id
    (lambda (body) (chooser-message-handler body)))

  ;; Load page skeleton (triggers "ready" → async search)
  (chooser-load-skeleton))

;; (close-chooser [reason]) — close the chooser and reset state.
;; reason: 'select | 'cancel | 'secondary-action (default 'cancel).
(define (close-chooser [reason 'cancel])
  (when chooser-is-open?
    (log-event 'chooser 'close 'reason reason)
    (set! chooser-search-generation (add1 chooser-search-generation))
    (close-panel! chooser-webview-id)
    (set! chooser-is-open? #f)
    (set! chooser-items '())
    (set! chooser-item-texts '())
    (set! chooser-filtered '())
    (set! chooser-selected-index 0)
    (set! chooser-query "")
    (set! chooser-actions-visible? #f)
    (set! chooser-selector-node #f)
    (set! chooser-action-index 0)
    (set! chooser-dynamic-search #f)))

;; ─── Message Handler ────────────────────────────────────────

;; Handle messages from the chooser JavaScript.
;; body: ObjC NSDictionary — extract fields via panel-manager helpers.
;; For testability, also accept a Racket alist.
(define (chooser-message-handler body)
  (define msg-type
    (cond
      [(pair? body) (alist-ref body 'type "")]    ; Racket alist (testing)
      [else (dict-get-string body "type")]))       ; ObjC dict (production)

  (cond
    [(equal? msg-type "ready")
     (if chooser-dynamic-search
         (chooser-dynamic-search "" chooser-push-results)
         (chooser-search! ""))]
    [(equal? msg-type "search")
     (define query
       (cond
         [(pair? body) (alist-ref body 'query "")]
         [else (dict-get-string body "query")]))
     (chooser-handle-search query)]
    [(equal? msg-type "select")
     (define idx
       (cond
         [(pair? body) (alist-ref body 'originalIndex #f)]
         [else (dict-get-number body "originalIndex")]))
     (chooser-handle-select idx)]
    [(equal? msg-type "secondary-action")
     (define idx
       (cond
         [(pair? body) (alist-ref body 'originalIndex #f)]
         [else (dict-get-number body "originalIndex")]))
     (chooser-handle-secondary-action idx)]
    [(equal? msg-type "cancel")
     (close-chooser)]
    [(equal? msg-type "toggle-actions")
     (chooser-handle-toggle-actions)]))

;; ObjC dict helpers — directly use panel-manager's exported functions.
;; panel-manager.rkt is already imported at the top; no dynamic-require needed.
(define dict-get-string objc-dict-get)
(define dict-get-number objc-dict-get-number)

;; ─── Message Handlers ───────────────────────────────────────

(define (chooser-handle-search query)
  (set! chooser-query query)
  (set! chooser-selected-index 0)
  (if chooser-dynamic-search
      (chooser-dynamic-search query chooser-push-results)
      (chooser-search! query)))

(define (chooser-handle-select raw-index)
  (define orig-index
    (and raw-index
         (nonneg-number? raw-index)
         (inexact->exact (truncate raw-index))))
  (when (and orig-index (>= orig-index 0) (< orig-index (length chooser-items)))
    (define item (list-ref chooser-items orig-index))
    (define on-select (alist-ref chooser-selector-node 'on-select #f))
    (define actions (alist-ref chooser-selector-node 'actions '()))
    (define primary-action (find-action-by-key actions 'primary))
    (define was-actions-visible? chooser-actions-visible?)
    ;; Record MRU before close-chooser clears selector-node
    (chooser-record-mru! item)
    (close-chooser 'select)
    (cond
      [(and was-actions-visible? primary-action)
       (define run-fn (alist-ref primary-action 'run #f))
       (when run-fn (run-fn item))]
      [on-select (on-select item)])))

(define (chooser-handle-toggle-actions)
  (set! chooser-actions-visible? (not chooser-actions-visible?))
  (set! chooser-action-index 0)
  (chooser-update-html))

(define (chooser-handle-secondary-action raw-index)
  (define orig-index
    (and raw-index
         (nonneg-number? raw-index)
         (inexact->exact (truncate raw-index))))
  (when (and orig-index (>= orig-index 0) (< orig-index (length chooser-items)))
    (define item (list-ref chooser-items orig-index))
    (define actions (alist-ref chooser-selector-node 'actions '()))
    (define secondary (find-action-by-key actions 'secondary))
    (when secondary
      (define run-fn (alist-ref secondary 'run #f))
      ;; Record MRU before close-chooser clears selector-node
      (chooser-record-mru! item)
      (close-chooser 'secondary-action)
      (when run-fn (run-fn item)))))

;; ─── MRU Recording ──────────────────────────────────────────

;; Record an item selection in the MRU store, if the current selector
;; has 'remember and 'id-field properties.
(define (chooser-record-mru! item)
  (when chooser-selector-node
    (define remember-key (alist-ref chooser-selector-node 'remember #f))
    (define id-field-raw (alist-ref chooser-selector-node 'id-field #f))
    (define id-field (and id-field-raw
                          (if (string? id-field-raw)
                              (string->symbol id-field-raw)
                              id-field-raw)))
    (when (and remember-key id-field)
      (define id-pair (assoc id-field item))
      (when id-pair
        (mru-record! remember-key (cdr id-pair))))))

;; ─── Action Helpers ─────────────────────────────────────────

(define (find-action-by-key actions key-val)
  (let loop ([acts actions])
    (if (null? acts)
        #f
        (let ([act (car acts)])
          (if (eq? (alist-ref act 'key #f) key-val)
              act
              (loop (cdr acts)))))))

;; ─── Numeric Validation ─────────────────────────────────────

;; Check if a value is a non-negative number usable as an index.
;; Accepts both exact integers and inexact numbers (JS sends doubles).
;; Callers use (inexact->exact (truncate v)) to get the integer index.
(define (nonneg-number? v)
  (and (number? v) (>= v 0)))
