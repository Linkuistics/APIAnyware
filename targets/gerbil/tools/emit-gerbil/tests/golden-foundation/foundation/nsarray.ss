;;; Generated binding for NSArray (Foundation) — do not edit
(import :std/foreign
        (rename-in :std/generic (defgeneric g:defgeneric) (defmethod g:defmethod))
        :gerbil-bindings/generics
        :gerbil-bindings/runtime/objc)
(export
  NSArray
  NSArray?
  count
  custom-mirror
  description
  encode-with-coder
  first-object
  last-object
  make-nsarray-init-with-coder
  nsarray-count
  nsarray-custom-mirror
  nsarray-description
  nsarray-encode-with-coder
  nsarray-first-object
  nsarray-last-object
  nsarray-make-iterator
  nsarray-object-at-index
  nsarray-sorted-array-hint
  nsarray-supports-secure-coding
  nsarray-underestimated-count
  object-at-index
  sorted-array-hint
  underestimated-count
  )

;; --- Class graph (ADR-0020) ---
(defclass (NSArray NSObject) () transparent: #t)
(register-objc-class! (lambda (p) (make-NSArray ptr: p)) NSArray::t "NSArray" "NSObject")

(begin-ffi (objc_getClass sel_registerName
            %msg-p->p
            %msg-p->v
            %msg-u64->p
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
  (define-c-lambda %msg-u64->p ((pointer void) (pointer void) unsigned-int64) (pointer void)
    "___return( ((id (*)(id, SEL, uint64_t))objc_msgSend)(___arg1, (SEL)___arg2, ___arg3) );")
  (define-c-lambda %msg-v->b ((pointer void) (pointer void)) bool
    "___return( ((BOOL (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->i64 ((pointer void) (pointer void)) int64
    "___return( ((int64_t (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->p ((pointer void) (pointer void)) (pointer void)
    "___return( ((id (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  (define-c-lambda %msg-v->u64 ((pointer void) (pointer void)) unsigned-int64
    "___return( ((uint64_t (*)(id, SEL))objc_msgSend)(___arg1, (SEL)___arg2) );")
  )

(define %sel-nsarray-init-with-coder (sel_registerName "initWithCoder:"))
(define %sel-nsarray-object-at-index (sel_registerName "objectAtIndex:"))
(define %sel-nsarray-encode-with-coder (sel_registerName "encodeWithCoder:"))
(define %sel-nsarray-supports-secure-coding (sel_registerName "supportsSecureCoding"))
(define %sel-nsarray-count (sel_registerName "count"))
(define %sel-nsarray-description (sel_registerName "description"))
(define %sel-nsarray-first-object (sel_registerName "firstObject"))
(define %sel-nsarray-last-object (sel_registerName "lastObject"))
(define %sel-nsarray-sorted-array-hint (sel_registerName "sortedArrayHint"))
(define %sel-nsarray-underestimated-count (sel_registerName "underestimatedCount"))
(define %sel-nsarray-custom-mirror (sel_registerName "customMirror"))

;; --- Dispatch surfaces (ADR-0020): inlinable proc core; generics are
;;     declared once in :gerbil-bindings/generics and extended below ---
(declare (inline))

;; --- Constructors ---
(define (make-nsarray-init-with-coder coder)
  (wrap (%msg-p->p (%msg-v->p (objc_getClass "NSArray") (sel_registerName "alloc")) %sel-nsarray-init-with-coder (->ptr coder)) #t))

;; --- Properties ---
(define (nsarray-count self)
  (%msg-v->u64 (NSObject-ptr self) %sel-nsarray-count))
(defmethod {count NSArray} (lambda (self) (nsarray-count self)))
(g:defmethod (count (o NSArray)) (nsarray-count o))

(define (nsarray-description self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsarray-description)))
(defmethod {description NSArray} (lambda (self) (nsarray-description self)))
(g:defmethod (description (o NSArray)) (nsarray-description o))

(define (nsarray-first-object self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsarray-first-object)))
(defmethod {first-object NSArray} (lambda (self) (nsarray-first-object self)))
(g:defmethod (first-object (o NSArray)) (nsarray-first-object o))

(define (nsarray-last-object self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsarray-last-object)))
(defmethod {last-object NSArray} (lambda (self) (nsarray-last-object self)))
(g:defmethod (last-object (o NSArray)) (nsarray-last-object o))

(define (nsarray-sorted-array-hint self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsarray-sorted-array-hint)))
(defmethod {sorted-array-hint NSArray} (lambda (self) (nsarray-sorted-array-hint self)))
(g:defmethod (sorted-array-hint (o NSArray)) (nsarray-sorted-array-hint o))

(define (nsarray-underestimated-count self)
  (%msg-v->i64 (NSObject-ptr self) %sel-nsarray-underestimated-count))
(defmethod {underestimated-count NSArray} (lambda (self) (nsarray-underestimated-count self)))
(g:defmethod (underestimated-count (o NSArray)) (nsarray-underestimated-count o))

(define (nsarray-custom-mirror self)
  (wrap (%msg-v->p (NSObject-ptr self) %sel-nsarray-custom-mirror)))
(defmethod {custom-mirror NSArray} (lambda (self) (nsarray-custom-mirror self)))
(g:defmethod (custom-mirror (o NSArray)) (nsarray-custom-mirror o))

;; --- Instance methods ---
(define (nsarray-object-at-index self index)
  (wrap (%msg-u64->p (NSObject-ptr self) %sel-nsarray-object-at-index index)))
(defmethod {object-at-index NSArray} (lambda (self index) (nsarray-object-at-index self index)))

(define (nsarray-encode-with-coder self coder)
  (%msg-p->v (NSObject-ptr self) %sel-nsarray-encode-with-coder (->ptr coder)))
(defmethod {encode-with-coder NSArray} (lambda (self coder) (nsarray-encode-with-coder self coder)))

;; --- Class methods ---
(define (nsarray-supports-secure-coding)
  (%msg-v->b (objc_getClass "NSArray") %sel-nsarray-supports-secure-coding))

;; --- Swift-native methods (receiver-handle trampolines, ADR-0030) ---
;; Trampolined through libAPIAnywareGerbil (aw_gerbil_swift_* entries),
;; not the framework dylib (ADR-0029); receiver coerced via (->ptr self).
(begin-ffi (
            %swift-nsarray-make-iterator
            )
  (c-declare "extern void * aw_gerbil_swift_m_Foundation_NSArray_makeIterator(void *);")

  (define-c-lambda %swift-nsarray-make-iterator ((pointer void)) (pointer void) "aw_gerbil_swift_m_Foundation_NSArray_makeIterator")
  )

(define nsarray-make-iterator
  (lambda (self)
    (wrap (%swift-nsarray-make-iterator (->ptr self)) #t)))

