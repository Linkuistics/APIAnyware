;;; Generated binding for NSData (Foundation) — do not edit
(import :std/foreign
        (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod))
        :gerbil-bindings/generics
        :gerbil-bindings/runtime/objc)
(export
  NSData
  NSData?
  bytes
  description
  encode-with-coder
  end-index
  length
  make-nsdata
  make-nsdata-init-with-coder
  nsdata-bytes
  nsdata-description
  nsdata-encode-with-coder
  nsdata-end-index
  nsdata-length
  nsdata-regions
  nsdata-start-index
  nsdata-supports-secure-coding
  regions
  start-index
  )

;; --- Class graph (ADR-0020) ---
(defclass (NSData NSObject) () transparent: #t)
(register-objc-class! (lambda (p) (make-NSData ptr: p)) NSData::t "NSData" "NSObject")

(begin-ffi (objc_getClass sel_registerName
            %msg-p->p
            %msg-p->v
            %msg-v->b
            %msg-v->i64
            %msg-v->p
            %msg-v->u64
            )
  (c-declare "#include <objc/runtime.h>")
  (c-declare "#include <objc/message.h>")
  (c-declare "#include <stdint.h>")

  (define-c-lambda objc_getClass (char-string) (pointer void) "objc_getClass")
  (define-c-lambda sel_registerName (char-string) (pointer void) "sel_registerName")
  (define-c-lambda %msg-p->p ((pointer void) (pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-p->v ((pointer void) (pointer void) (pointer void)) void
    "((void (*)(id, SEL, id))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3);")
  (define-c-lambda %msg-v->b ((pointer void) (pointer void)) bool
    "___return( ((BOOL (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->i64 ((pointer void) (pointer void)) int64
    "___return( ((int64_t (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->p ((pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->u64 ((pointer void) (pointer void)) unsigned-int64
    "___return( ((uint64_t (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  )

(define %sel-nsdata-init-with-coder (sel_registerName "initWithCoder:"))
(define %sel-nsdata-encode-with-coder (sel_registerName "encodeWithCoder:"))
(define %sel-nsdata-supports-secure-coding (sel_registerName "supportsSecureCoding"))
(define %sel-nsdata-length (sel_registerName "length"))
(define %sel-nsdata-bytes (sel_registerName "bytes"))
(define %sel-nsdata-description (sel_registerName "description"))
(define %sel-nsdata-start-index (sel_registerName "startIndex"))
(define %sel-nsdata-end-index (sel_registerName "endIndex"))
(define %sel-nsdata-regions (sel_registerName "regions"))

;; --- Dispatch surfaces (ADR-0020): inlinable proc core; generics are
;;     declared once in :gerbil-bindings/generics and extended below ---
(declare (inline))

;; --- Constructors ---
(define (make-nsdata)
  (wrap
    (%msg-v->p (%msg-v->p (objc_getClass "NSData") (sel_registerName "alloc"))
          (sel_registerName "init"))
    #t))

(define (make-nsdata-init-with-coder coder)
  (wrap (%msg-p->p (%msg-v->p (objc_getClass "NSData") (sel_registerName "alloc")) %sel-nsdata-init-with-coder (->ptr coder)) #t))

;; --- Properties ---
(define (nsdata-length self)
  (%msg-v->u64 (NSObject-ptr self) %sel-nsdata-length))
(defmethod {length NSData} (lambda (self) (nsdata-length self)))
(g:defmethod (length (o NSData)) (nsdata-length o))

(define (nsdata-bytes self)
  (%msg-v->p (NSObject-ptr self) %sel-nsdata-bytes))
(defmethod {bytes NSData} (lambda (self) (nsdata-bytes self)))
(g:defmethod (bytes (o NSData)) (nsdata-bytes o))

(define (nsdata-description self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsdata-description)))
(defmethod {description NSData} (lambda (self) (nsdata-description self)))
(g:defmethod (description (o NSData)) (nsdata-description o))

(define (nsdata-start-index self)
  (%msg-v->i64 (NSObject-ptr self) %sel-nsdata-start-index))
(defmethod {start-index NSData} (lambda (self) (nsdata-start-index self)))
(g:defmethod (start-index (o NSData)) (nsdata-start-index o))

(define (nsdata-end-index self)
  (%msg-v->i64 (NSObject-ptr self) %sel-nsdata-end-index))
(defmethod {end-index NSData} (lambda (self) (nsdata-end-index self)))
(g:defmethod (end-index (o NSData)) (nsdata-end-index o))

(define (nsdata-regions self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsdata-regions)))
(defmethod {regions NSData} (lambda (self) (nsdata-regions self)))
(g:defmethod (regions (o NSData)) (nsdata-regions o))

;; --- Instance methods ---
(define (nsdata-encode-with-coder self coder)
  (%msg-p->v (NSObject-ptr self) %sel-nsdata-encode-with-coder (->ptr coder)))
(defmethod {encode-with-coder NSData} (lambda (self coder) (nsdata-encode-with-coder self coder)))

;; --- Class methods ---
(define (nsdata-supports-secure-coding)
  (%msg-v->b (objc_getClass "NSData") %sel-nsdata-supports-secure-coding))

