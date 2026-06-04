;;; Generated protocol binding for TKDelegate (TestKit) — do not edit
(import :gerbil-bindings/runtime/objc)
(export
  make-tkdelegate
  tkdelegate-selectors
  )

(define tkdelegate-selectors
  '(
    "managerDidFinish:"
    "managerShouldContinue:"
    "managerWillReturnResult:"
    ))

;; selector → ((param-tokens …) return-token) — delegate bridge spec
(define %method-info
  '(
    ("managerDidFinish:" (object) void)
    ("managerShouldContinue:" (object) bool)
    ("managerWillReturnResult:" (object) object)
    ))

(define (%lookup-info sel)
  (let loop ((xs %method-info))
    (cond
      ((null? xs) (error "make-tkdelegate: unknown selector for protocol" sel))
      ((string=? (car (car xs)) sel) (car xs))
      (else (loop (cdr xs))))))

(define (make-tkdelegate . selector+handler-pairs)
  (let loop ((rest selector+handler-pairs)
             (specs '()))
    (cond
      ((null? rest) (make-delegate (reverse specs)))
      ((null? (cdr rest)) (error "make-tkdelegate: odd number of arguments — expected selector handler pairs"))
      (else
       (let* ((sel  (car rest))
              (proc (cadr rest))
              (info (%lookup-info sel)))
         (loop (cddr rest)
               (cons (list sel proc (cadr info) (caddr info)) specs)))))))
