#lang racket/base
;; Generated protocol definition for TKDelegate (TestKit)
;; Do not edit — regenerate from enriched IR
;;
;; TKDelegate defines 3 methods:
;;   void-returning (2):
;;     managerDidFinish:  (manager:TKManager)
;;     managerShouldContinue:  (manager:TKManager)
;;   id-returning (1):
;;     managerWillReturnResult:  (manager:TKManager)

(require racket/contract
         "../../../runtime/delegate.rkt")

(provide/contract
  [make-tkdelegate (->* () () #:rest (listof (or/c string? procedure?)) any/c)]
  [tkdelegate-selectors (listof string?)])

;; All selectors in this protocol
(define tkdelegate-selectors
  '("managerDidFinish:"
    "managerShouldContinue:"
    "managerWillReturnResult:"))

;; Create a TKDelegate delegate.
;; Pass selector string → handler procedure pairs.
;; Example:
;;   (make-tkdelegate
;;     "managerDidFinish:" (lambda (manager) ...)
;;   )
(define (make-tkdelegate . selector+handler-pairs)
  (apply make-delegate
    #:return-types
    (hash "managerWillReturnResult:" 'id)
    #:param-types
    (hash "managerDidFinish:" '(object) "managerShouldContinue:" '(object) "managerWillReturnResult:" '(object))
    selector+handler-pairs))
