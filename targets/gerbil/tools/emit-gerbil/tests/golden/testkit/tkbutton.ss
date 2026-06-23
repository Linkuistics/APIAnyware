;;; Generated binding for TKButton (TestKit) — do not edit
(import :std/foreign
        (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod))
        :gerbil-bindings/generics
        :gerbil-bindings/testkit/tkview
        :gerbil-bindings/runtime/objc)
(export
  TKButton
  TKButton?
  enabled
  is-highlighted
  label
  make-tkbutton
  set-enabled!
  set-label!
  set-target-action!
  tkbutton-enabled
  tkbutton-is-highlighted
  tkbutton-label
  tkbutton-set-enabled!
  tkbutton-set-label!
  tkbutton-set-target-action!
  )

;; --- Class graph (ADR-0020) ---
(defclass (TKButton TKView) () transparent: #t)
(register-objc-class! (lambda (p) (make-TKButton ptr: p)) TKButton::t "TKButton" "TKView")

(begin-ffi (objc_getClass sel_registerName
            %msg-b->v
            %msg-p->v
            %msg-p-p->v
            %msg-v->b
            %msg-v->p
            )
  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")
  (c-declare "#include <stdint.h>")

  (define-c-lambda objc_getClass (char-string) (pointer void) "objc_getClass")
  (define-c-lambda sel_registerName (char-string) (pointer void) "sel_registerName")
  (define-c-lambda %msg-b->v ((pointer void) (pointer void) bool) void
    "((void (*)(id, SEL, BOOL))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3);")
  (define-c-lambda %msg-p->v ((pointer void) (pointer void) (pointer void)) void
    "((void (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3);")
  (define-c-lambda %msg-p-p->v ((pointer void) (pointer void) (pointer void) (pointer void)) void
    "((void (*)(id, SEL, id, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, ___arg4);")
  (define-c-lambda %msg-v->b ((pointer void) (pointer void)) bool
    "___return( ((BOOL (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->p ((pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  )

(define %sel-tkbutton-set-target-action (sel_registerName "setTarget:action:"))
(define %sel-tkbutton-is-highlighted (sel_registerName "isHighlighted"))
(define %sel-tkbutton-label (sel_registerName "label"))
(define %sel-tkbutton-set-label (sel_registerName "setLabel:"))
(define %sel-tkbutton-enabled (sel_registerName "enabled"))
(define %sel-tkbutton-set-enabled (sel_registerName "setEnabled:"))

;; --- Dispatch surfaces (ADR-0020): inlinable proc core; generics are
;;     declared once in :gerbil-bindings/generics and extended below ---
(declare (inline))

;; --- Constructors ---
(define (make-tkbutton)
  (wrap
    (%msg-v->p (%msg-v->p (objc_getClass "TKButton") (sel_registerName "alloc"))
          (sel_registerName "init"))
    #t))

;; --- Properties ---
(define (tkbutton-label self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-tkbutton-label)))
(defmethod {label TKButton} (lambda (self) (tkbutton-label self)))
(g:defmethod (label (o TKButton)) (tkbutton-label o))

(define (tkbutton-set-label! self value)
  (%msg-p->v (NSObject-ptr self) %sel-tkbutton-set-label (->ptr value)))
(defmethod {set-label! TKButton} (lambda (self value) (tkbutton-set-label! self value)))

(define (tkbutton-enabled self)
  (%msg-v->b (NSObject-ptr self) %sel-tkbutton-enabled))
(defmethod {enabled TKButton} (lambda (self) (tkbutton-enabled self)))
(g:defmethod (enabled (o TKButton)) (tkbutton-enabled o))

(define (tkbutton-set-enabled! self value)
  (%msg-b->v (NSObject-ptr self) %sel-tkbutton-set-enabled value))
(defmethod {set-enabled! TKButton} (lambda (self value) (tkbutton-set-enabled! self value)))

;; --- Instance methods ---
(define (tkbutton-set-target-action! self target action)
  (%msg-p-p->v (NSObject-ptr self) %sel-tkbutton-set-target-action (->ptr target) (sel_registerName action)))
(defmethod {set-target-action! TKButton} (lambda (self target action) (tkbutton-set-target-action! self target action)))

(define (tkbutton-is-highlighted self)
  (%msg-v->b (NSObject-ptr self) %sel-tkbutton-is-highlighted))
(defmethod {is-highlighted TKButton} (lambda (self) (tkbutton-is-highlighted self)))
(g:defmethod (is-highlighted (o TKButton)) (tkbutton-is-highlighted o))

