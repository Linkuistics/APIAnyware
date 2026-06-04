;;; Generated binding for TKHelper (TestKit) — do not edit
(import :std/foreign
        (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod))
        :gerbil-bindings/testkit/tkobject
        :gerbil-bindings/runtime/objc)
(export
  TKHelper
  TKHelper?
  make-tkhelper
  tkhelper-maximum-count
  tkhelper-version-string
  )

;; --- Class graph (ADR-0020) ---
(defclass (TKHelper TKObject) () transparent: #t)
(register-objc-class! (lambda (p) (make-TKHelper ptr: p)) TKHelper::t "TKHelper" "TKObject")

(begin-ffi (objc_getClass sel_registerName
            %msg-v->i64
            %msg-v->p
            )
  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")
  (c-declare "#include <stdint.h>")

  (define-c-lambda objc_getClass (char-string) (pointer void) "objc_getClass")
  (define-c-lambda sel_registerName (char-string) (pointer void) "sel_registerName")
  (define-c-lambda %msg-v->i64 ((pointer void) (pointer void)) int64
    "___return( ((int64_t (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->p ((pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  )

(define %sel-tkhelper-version-string (sel_registerName "versionString"))
(define %sel-tkhelper-maximum-count (sel_registerName "maximumCount"))

;; --- Constructors ---
(define (make-tkhelper)
  (wrap
    (%msg-v->p (%msg-v->p (objc_getClass "TKHelper") (sel_registerName "alloc"))
          (sel_registerName "init"))
    #t))

;; --- Class methods ---
(define (tkhelper-version-string)
  (wrap (%msg-v->p (objc_getClass "TKHelper") %sel-tkhelper-version-string)))

(define (tkhelper-maximum-count)
  (%msg-v->i64 (objc_getClass "TKHelper") %sel-tkhelper-maximum-count))

