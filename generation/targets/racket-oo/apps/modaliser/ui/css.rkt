#lang racket/base
;; ui/css.rkt — CSS generation helpers
;;
;; Pure functions for generating CSS strings from Scheme data.
;;
;; API:
;;   (css-rule selector properties-alist) -> CSS rule string
;;   (css-rules . rules) -> concatenated CSS string
;;   (inline-style properties-alist) -> "prop: val; prop: val" string

(provide css-rule
         css-rules
         inline-style)

;; ─── CSS Rule Generation ──────────────────────────────────────

;; (css-rule selector properties-alist) -> CSS rule string
;; selector: string (e.g. ".key", "body", "#overlay .entry")
;; properties: alist of (symbol . string) pairs
;;
;; Example:
;;   (css-rule ".key" '((background . "#333") (padding . "2px 6px")))
;;   -> ".key { background: #333; padding: 2px 6px; }"
(define (css-rule selector properties)
  (string-append
   selector " { "
   (css-properties properties)
   " }"))

;; Render properties alist as "prop: val; prop: val;"
(define (css-properties properties)
  (let loop ([pairs properties] [result ""])
    (if (null? pairs)
        result
        (let* ([pair (car pairs)]
               [prop (symbol->string (car pair))]
               [val (cdr pair)]
               [decl (string-append prop ": " val ";")]
               [sep (if (string=? result "") "" " ")])
          (loop (cdr pairs)
                (string-append result sep decl))))))

;; (css-rules . rules) -> concatenated CSS string
;; Each rule is a string (typically from css-rule).
;; Joins with newlines.
(define (css-rules . rules)
  (let loop ([rest rules] [result ""])
    (if (null? rest)
        result
        (loop (cdr rest)
              (string-append result
                (if (string=? result "") "" "\n")
                (car rest))))))

;; ─── Inline Styles ────────────────────────────────────────────

;; (inline-style properties-alist) -> style attribute value string
;; Returns "prop: val; prop: val;"
;;
;; Example:
;;   (inline-style '((color . "red") (font-size . "14px")))
;;   -> "color: red; font-size: 14px;"
(define (inline-style properties)
  (let loop ([pairs properties] [result ""])
    (if (null? pairs)
        result
        (let* ([pair (car pairs)]
               [prop (symbol->string (car pair))]
               [val (cdr pair)]
               [sep (if (string=? result "") "" " ")])
          (loop (cdr pairs)
                (string-append result sep prop ": " val ";"))))))
