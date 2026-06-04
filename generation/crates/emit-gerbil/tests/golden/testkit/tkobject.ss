;;; Generated binding for TKObject (TestKit) — do not edit
(import :std/foreign
        (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod))
        :gerbil-bindings/generics
        :gerbil-bindings/runtime/objc)
(export
  TKObject
  TKObject?
  dealloc
  description
  make-tkobject
  tkobject-dealloc
  tkobject-description
  )

;; --- Class graph (ADR-0020) ---
(defclass (TKObject NSObject) () transparent: #t)
(register-objc-class! (lambda (p) (make-TKObject ptr: p)) TKObject::t "TKObject" "")

(begin-ffi (objc_getClass sel_registerName
            %msg-v->p
            %msg-v->v
            )
  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")
  (c-declare "#include <stdint.h>")

  (define-c-lambda objc_getClass (char-string) (pointer void) "objc_getClass")
  (define-c-lambda sel_registerName (char-string) (pointer void) "sel_registerName")
  (define-c-lambda %msg-v->p ((pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->v ((pointer void) (pointer void)) void
    "((void (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2);")
  )

(define %sel-tkobject-dealloc (sel_registerName "dealloc"))
(define %sel-tkobject-description (sel_registerName "description"))

;; --- Dispatch surfaces (ADR-0020): inlinable proc core; generics are
;;     declared once in :gerbil-bindings/generics and extended below ---
(declare (inline))

;; --- Constructors ---
(define (make-tkobject)
  (wrap
    (%msg-v->p (%msg-v->p (objc_getClass "TKObject") (sel_registerName "alloc"))
          (sel_registerName "init"))
    #t))

;; --- Instance methods ---
(define (tkobject-dealloc self)
  (%msg-v->v (NSObject-ptr self) %sel-tkobject-dealloc))
(defmethod {dealloc TKObject} (lambda (self) (tkobject-dealloc self)))
(g:defmethod (dealloc (o TKObject)) (tkobject-dealloc o))

(define (tkobject-description self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-tkobject-description)))
(defmethod {description TKObject} (lambda (self) (tkobject-description self)))
(g:defmethod (description (o TKObject)) (tkobject-description o))

