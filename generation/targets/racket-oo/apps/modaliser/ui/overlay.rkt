#lang racket/base
;; ui/overlay.rkt — Which-key overlay using WebView
;;
;; Manages a non-activating floating panel that shows available
;; keybindings at the current position in the command tree.
;;
;; Pure API (testable):
;;   (render-overlay-html node path) -> full HTML document string
;;   (render-overlay-body node path) -> raw-html of overlay body
;;   (render-breadcrumb root-label path) -> raw-html of breadcrumb header
;;   (render-entry child) -> raw-html of a single entry
;;
;; Side-effecting API:
;;   (show-overlay node path)   — create panel if needed, render and display
;;   (update-overlay node path) — push incremental update via JS
;;   (hide-overlay)             — close panel
;;   (overlay-open?)            — is the overlay currently shown?
;;   (set-overlay-css! css)     — store custom CSS for theming

(require racket/file
         racket/runtime-path
         "../core/state-machine.rkt"
         "../ui/dom.rkt"
         "../ui/panel-manager.rkt")


(provide ;; Pure rendering
         render-overlay-html
         render-overlay-body
         render-breadcrumb
         render-entry

         ;; Side-effecting lifecycle
         show-overlay
         update-overlay
         hide-overlay
         overlay-open?

         ;; CSS theming
         set-overlay-css!)

;; ─── Resource Paths ───────────────────────────────────────────
;; Use runtime-path so resources are found both from source and
;; when compiled/packaged.

(define-runtime-path base-css-path "base.css")
(define-runtime-path overlay-js-path "overlay.js")

;; ─── CSS/JS Loading ──────────────────────────────────────────

(define overlay-base-css (file->string base-css-path))
(define overlay-js (file->string overlay-js-path))

;; ─── Overlay State ────────────────────────────────────────────

(define overlay-webview-id "modaliser-overlay")
(define overlay-is-open? #f)
(define overlay-custom-css "")

(define (overlay-open?) overlay-is-open?)

;; ─── CSS Theming ──────────────────────────────────────────────

(define (set-overlay-css! css)
  (set! overlay-custom-css css))

;; ─── Panel Configuration ─────────────────────────────────────

(define overlay-panel-width 340)
(define overlay-panel-height 400)

;; ─── Rendering (Pure Functions) ───────────────────────────────

;; Build the breadcrumb header from a navigation path.
;; path: list of key strings, e.g. '("w" "m")
;; root-label: label of the root tree node
(define (render-breadcrumb root-label path)
  (if (null? path)
      (header '((class . "overlay-header"))
        (span '((class . "breadcrumb")) root-label))
      (let* ([segments (cons root-label path)]
             [sep (html->string (span '((class . "breadcrumb-sep")) ">"))])
        (header '((class . "overlay-header"))
          (make-raw-html
           (let loop ([segs segments] [result ""])
             (if (null? segs)
                 result
                 (loop (cdr segs)
                       (string-append result
                         (if (string=? result "") "" sep)
                         (html-escape (car segs)))))))))))

;; Render an entry for a single child node.
(define (render-entry child)
  (let* ([k (node-key child)]
         [label (node-label child)]
         [is-group (group? child)]
         [display-key (if (equal? k " ") "\u2423" k)]
         [display-label (if is-group
                            (string-append label " \u2026")
                            label)]
         [label-class (if is-group "entry-label group-label" "entry-label")])
    (li '((class . "overlay-entry"))
      (span '((class . "entry-key")) display-key)
      (span '((class . "entry-arrow")) "\u2192")
      (span (list (cons 'class label-class)) display-label))))

;; Sort children alphabetically by key.
(define (sort-children children)
  (define (insert item sorted)
    (cond
      [(null? sorted) (list item)]
      [(string<? (node-key item) (node-key (car sorted)))
       (cons item sorted)]
      [else (cons (car sorted) (insert item (cdr sorted)))]))
  (let loop ([rest children] [sorted '()])
    (if (null? rest)
        sorted
        (loop (cdr rest) (insert (car rest) sorted)))))

;; Navigate from root following a list of key strings.
(define (navigate-to-path root path)
  (if (null? path)
      root
      (let ([child (find-child root (car path))])
        (if child
            (navigate-to-path child (cdr path))
            root))))

;; Render the full overlay body: header + entry list
(define (render-overlay-body node path)
  (let* ([root-label (node-label node)]
         [current (if (null? path)
                      node
                      (navigate-to-path node path))]
         [children (if current (node-children current) '())]
         [sorted (sort-children children)])
    (div '((class . "overlay"))
      (render-breadcrumb root-label path)
      (apply ul (cons '((class . "overlay-entries"))
                      (map render-entry sorted))))))

;; (render-overlay-html node path) -> full HTML document string
;; Pure function. node is the root tree node, path is the navigation path.
(define (render-overlay-html node path)
  (let ([css (if (string=? overlay-custom-css "")
                 overlay-base-css
                 (string-append overlay-base-css "\n" overlay-custom-css))])
    (html-document
     (make-raw-html
      (string-append
       (html->string (style-element '() css))
       (html->string (script-element '() overlay-js))))
     (render-overlay-body node path))))

;; ─── JS Data Push ─────────────────────────────────────────────
;; Build JSON and push to JS updateOverlay(). Faster than full
;; HTML replacement for group navigation.

(define (js-escape-overlay str)
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

(define (push-overlay-update node path)
  (let* ([root-label (node-label node)]
         [current (if (null? path)
                      node
                      (navigate-to-path node path))]
         [children (if current (node-children current) '())]
         [sorted (sort-children children)]
         ;; Build path JSON array
         [path-json (string-append "["
                      (let loop ([segs path] [result ""])
                        (if (null? segs)
                            result
                            (loop (cdr segs)
                                  (string-append result
                                    (if (string=? result "") "" ",")
                                    "\"" (js-escape-overlay (car segs)) "\""))))
                      "]")]
         ;; Build entries JSON array
         [entries-json (string-append "["
                         (let loop ([items sorted] [result ""])
                           (if (null? items)
                               result
                               (let* ([item (car items)]
                                      [k (node-key item)]
                                      [lbl (node-label item)]
                                      [is-grp (group? item)])
                                 (loop (cdr items)
                                       (string-append result
                                         (if (string=? result "") "" ",")
                                         "{\"key\":\"" (js-escape-overlay k)
                                         "\",\"label\":\"" (js-escape-overlay lbl)
                                         "\",\"isGroup\":" (if is-grp "true" "false")
                                         "}")))))
                         "]")])
    (panel-eval-js! overlay-webview-id
      (string-append "updateOverlay({\"label\":\""
        (js-escape-overlay root-label) "\",\"path\":" path-json
        ",\"entries\":" entries-json "})"))))

;; ─── Overlay Lifecycle (Side-Effecting) ───────────────────────

(define (show-overlay node path)
  (unless overlay-is-open?
    (create-panel! overlay-webview-id
      #:width overlay-panel-width
      #:height overlay-panel-height
      #:activating #f
      #:floating #t
      #:transparent #t)
    (set! overlay-is-open? #t))
  (panel-set-html! overlay-webview-id
    (render-overlay-html node path)))

(define (update-overlay node path)
  (when overlay-is-open?
    (push-overlay-update node path)))

(define (hide-overlay)
  (when overlay-is-open?
    (close-panel! overlay-webview-id)
    (set! overlay-is-open? #f)))
