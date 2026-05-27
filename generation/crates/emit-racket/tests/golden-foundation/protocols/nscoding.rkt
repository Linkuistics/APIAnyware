#lang racket/base
;; Generated protocol definition for NSCoding (Foundation)
;; Do not edit — regenerate from enriched IR
;;
;; NSCoding defines 2 methods:
;;   void-returning (1):
;;     encodeWithCoder:  (coder:NSCoder)
;;   id-returning (1):
;;     initWithCoder:  (coder:NSCoder)

(require racket/contract
         "../../../runtime/delegate.rkt")

(provide/contract
  [make-nscoding (->* () () #:rest (listof (or/c string? procedure?)) any/c)]
  [nscoding-selectors (listof string?)])

;; All selectors in this protocol
(define nscoding-selectors
  '("encodeWithCoder:"
    "initWithCoder:"))

;; Create a NSCoding delegate.
;; Pass selector string → handler procedure pairs.
;; Example:
;;   (make-nscoding
;;     "encodeWithCoder:" (lambda (coder) ...)
;;   )
(define (make-nscoding . selector+handler-pairs)
  (apply make-delegate
    #:return-types
    (hash "initWithCoder:" 'id)
    #:param-types
    (hash "encodeWithCoder:" '(object) "initWithCoder:" '(object))
    selector+handler-pairs))
