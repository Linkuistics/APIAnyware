;;; Generated binding for TKManager (TestKit) — do not edit
(import :std/foreign
        (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod))
        :gerbil-bindings/generics
        :gerbil-bindings/testkit/tkobject
        :gerbil-bindings/runtime/objc)
(export
  TKManager
  TKManager?
  load-resource-error
  make-tkmanager
  resource-named
  tkmanager-load-resource-error
  tkmanager-resource-named
  tkmanager-shared-manager
  )

;; --- Class graph (ADR-0020) ---
(defclass (TKManager TKObject) () transparent: #t)
(register-objc-class! (lambda (p) (make-TKManager ptr: p)) TKManager::t "TKManager" "TKObject")

(begin-ffi (objc_getClass sel_registerName
            %msg-p->p
            %msg-p-pp->b-e
            %msg-v->p
            )
  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")
  (c-declare "#include <stdint.h>")

  (define-c-lambda objc_getClass (char-string) (pointer void) "objc_getClass")
  (define-c-lambda sel_registerName (char-string) (pointer void) "sel_registerName")
  (define-c-lambda %msg-p->p ((pointer void) (pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-p-pp->b-e ((pointer void) (pointer void) (pointer void) (pointer (pointer void))) bool
    "___return( ((BOOL (*)(id, SEL, id, NSError**))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3, (NSError**)___arg4) );")
  (define-c-lambda %msg-v->p ((pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  )

(define %sel-tkmanager-load-resource-error (sel_registerName "loadResource:error:"))
(define %sel-tkmanager-resource-named (sel_registerName "resourceNamed:"))
(define %sel-tkmanager-shared-manager (sel_registerName "sharedManager"))

;; --- Dispatch surfaces (ADR-0020): inlinable proc core; generics are
;;     declared once in :gerbil-bindings/generics and extended below ---
(declare (inline))

;; --- Constructors ---
(define (make-tkmanager)
  (wrap
    (%msg-v->p (%msg-v->p (objc_getClass "TKManager") (sel_registerName "alloc"))
          (sel_registerName "init"))
    #t))

;; --- Instance methods ---
(define (tkmanager-load-resource-error self name)
  (call-with-nserror-out
    (lambda (%err-cell)
      (%msg-p-pp->b-e (NSObject-ptr self) %sel-tkmanager-load-resource-error (->ptr name) %err-cell))))
(defmethod {load-resource-error TKManager} (lambda (self name) (tkmanager-load-resource-error self name)))

(define (tkmanager-resource-named self name)
  (wrap (%msg-p->p (NSObject-ptr self) %sel-tkmanager-resource-named (->ptr name))))
(defmethod {resource-named TKManager} (lambda (self name) (tkmanager-resource-named self name)))

;; --- Class methods ---
(define (tkmanager-shared-manager)
  (wrap (%msg-v->p (objc_getClass "TKManager") %sel-tkmanager-shared-manager)))

