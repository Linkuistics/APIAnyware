#lang racket/base
;; web-search.rkt — Google Suggest integration for the chooser
;;
;; Provides a dynamic search handler that queries Google's suggestion API
;; and an on-select handler that opens the selected search result in the
;; default browser.
;;
;; Used in config.scm as:
;;   (selector "g" "Google Search"
;;     'prompt "Search Google…"
;;     'dynamic-search web-search-handler
;;     'on-select web-search-on-select)

(require racket/string
         racket/port
         net/uri-codec
         json
         "../services/http.rkt"
         "util.rkt")

(provide web-search-handler
         web-search-on-select)

;; Minimum query length before issuing HTTP request.
;; Shorter queries only show the pinned "Search Google for '...'" item.
(define MIN-QUERY-LENGTH 3)

;; Google Suggest API (Firefox client returns JSON)
(define SUGGEST-URL "https://suggestqueries.google.com/complete/search?client=firefox&q=")

;; Build Google search URL for a query string.
(define (google-search-url query)
  (string-append "https://www.google.com/search?q="
                 (uri-encode query)))

;; Build the pinned "Search Google for '...'" item (always first result).
(define (make-pinned-item query)
  (list (cons 'text (string-append "Search Google for '" query "'"))
        (cons 'search-url (google-search-url query))))

;; Build a suggestion item from a suggestion string.
(define (make-suggestion-item suggestion)
  (list (cons 'text suggestion)
        (cons 'search-url (google-search-url suggestion))))

;; Parse Google Suggest JSON response.
;; Format: ["query", ["suggestion1", "suggestion2", ...]]
;; Returns list of suggestion strings, or '() on parse error.
(define (parse-suggestions response-body)
  (with-handlers ([exn:fail? (lambda (_) '())])
    (define parsed (with-input-from-string response-body read-json))
    (cond
      [(and (list? parsed)
            (>= (length parsed) 2)
            (list? (cadr parsed)))
       (filter string? (cadr parsed))]
      [else '()])))

;; ─── Dynamic search handler ───────────────────────────────────

;; Stale-query guard: each call to web-search-handler increments the
;; generation counter. The async HTTP callback only fires if its generation
;; still matches the current one (i.e., no newer query has been issued).
(define current-search-query (box ""))

;; (web-search-handler query callback) → void
;; Called by the chooser for each keystroke.
;; callback: (callback items) where items is a list of alists with 'text key.
(define (web-search-handler query callback)
  (set-box! current-search-query query)
  (cond
    [(string=? query "")
     (callback '())]
    [(< (string-length query) MIN-QUERY-LENGTH)
     ;; Too short for API call — just show pinned item
     (callback (list (make-pinned-item query)))]
    [else
     ;; Show pinned item immediately, then fetch suggestions
     (callback (list (make-pinned-item query)))
     (define my-query query)
     (define url (string-append SUGGEST-URL (uri-encode query)))
     (http-get url
               (lambda (body)
                 ;; Drop result if a newer query has been issued
                 (when (equal? (unbox current-search-query) my-query)
                   (cond
                     [(not body) (void)]
                     [else
                      (define suggestions (parse-suggestions body))
                      (define items
                        (cons (make-pinned-item my-query)
                              (map make-suggestion-item suggestions)))
                      (callback items)]))))]))

;; ─── On-select handler ────────────────────────────────────────

;; (web-search-on-select choice) → void
;; Opens the selected search result URL in the default browser.
(define (web-search-on-select choice)
  (define url (alist-ref choice 'search-url))
  (when url
    (open-url url)))
