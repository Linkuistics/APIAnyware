#lang racket/base
;; Generated protocol definition for TKCopying (TestKit)
;; Do not edit — regenerate from enriched IR
;;
;; TKCopying defines 1 methods:
;;   id-returning (1):
;;     copyWithZone:  (zone:pointer)

(require racket/contract
         "../../../runtime/delegate.rkt")

(provide/contract
  [make-tkcopying (->* () () #:rest (listof (or/c string? procedure?)) any/c)]
  [tkcopying-selectors (listof string?)])

;; All selectors in this protocol
(define tkcopying-selectors
  '("copyWithZone:"))

;; Create a TKCopying delegate.
;; Pass selector string → handler procedure pairs.
;; Example:
;;   (make-tkcopying
;;   )
(define (make-tkcopying . selector+handler-pairs)
  (apply make-delegate
    #:return-types
    (hash "copyWithZone:" 'id)
    selector+handler-pairs))
