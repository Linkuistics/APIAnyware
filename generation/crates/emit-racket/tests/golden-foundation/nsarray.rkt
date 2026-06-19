#lang racket/base
;; Generated binding for NSArray (Foundation)
;; Do not edit — regenerate from enriched IR

(require "../../runtime/ffi2-dispatch.rkt"
         (except-in ffi/unsafe ->)
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../runtime/objc-base.rkt"
         "../../runtime/coerce.rkt"
         "../../runtime/swift-trampoline.rkt"
         (only-in ffi/unsafe [-> aw->]))

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/Foundation.framework/Foundation"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
(define (mirror? v) (objc-instance-of? v "Mirror"))
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(provide NSArray)
(provide/contract
  [make-nsarray-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsarray-init-with-objects-count (c-> (or/c cpointer? #f) exact-nonnegative-integer? any/c)]
  [nsarray-count (c-> nsarray? exact-nonnegative-integer?)]
  [nsarray-custom-mirror (c-> nsarray? (or/c mirror? objc-nil?))]
  [nsarray-description (c-> nsarray? (or/c nsstring? objc-nil?))]
  [nsarray-first-object (c-> nsarray? any/c)]
  [nsarray-last-object (c-> nsarray? any/c)]
  [nsarray-sorted-array-hint (c-> nsarray? (or/c nsdata? objc-nil?))]
  [nsarray-underestimated-count (c-> nsarray? exact-integer?)]
  [nsarray-copy-with-zone (c-> nsarray? (or/c cpointer? #f) any/c)]
  [nsarray-count-by-enumerating-with-state-objects-count (c-> nsarray? (or/c cpointer? #f) (or/c cpointer? #f) exact-nonnegative-integer? exact-nonnegative-integer?)]
  [nsarray-encode-with-coder (c-> nsarray? (or/c string? objc-object? #f) void?)]
  [nsarray-mutable-copy-with-zone (c-> nsarray? (or/c cpointer? #f) any/c)]
  [nsarray-object-at-index (c-> nsarray? exact-nonnegative-integer? any/c)]
  [nsarray-supports-secure-coding (c-> boolean?)]
  )

(provide
  nsarray-make-iterator
  )

;; --- Class reference ---
(import-class NSArray)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_q (-> ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_0_Q (-> ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPQ_Q (-> ptr_t ptr_t ptr_t ptr_t uint64_t uint64_t))
(define-aw-msg aw_racket_msg_PQ_P (-> ptr_t ptr_t ptr_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_Q_P (-> ptr_t ptr_t uint64_t ptr_t))

;; --- Constructors ---
(define (make-nsarray-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSArray alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nsarray-init-with-objects-count objects cnt)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQ_P (id->ffi2-ptr (tell NSArray alloc)) (id->ffi2-ptr (sel_registerName "initWithObjects:count:")) (id->ffi2-ptr objects) cnt))
   #:retained #t))


;; --- Properties ---
(define (nsarray-count self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "count"))))
(define (nsarray-custom-mirror self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "customMirror"))))))
(define (nsarray-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "description"))))))
(define (nsarray-first-object self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstObject"))))))
(define (nsarray-last-object self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastObject"))))))
(define (nsarray-sorted-array-hint self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sortedArrayHint"))))))
(define (nsarray-underestimated-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "underestimatedCount"))))

;; --- Instance methods ---
(define (nsarray-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "copyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))
(define (nsarray-count-by-enumerating-with-state-objects-count self state buffer len)
  (aw_racket_msg_PPQ_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "countByEnumeratingWithState:objects:count:")) (id->ffi2-ptr state) (id->ffi2-ptr buffer) len))
(define (nsarray-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nsarray-mutable-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mutableCopyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))
(define (nsarray-object-at-index self index)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "objectAtIndex:")) index))
   ))

;; --- Class methods ---
(define (nsarray-supports-secure-coding)
  (aw_racket_msg_0_b (id->ffi2-ptr NSArray) (id->ffi2-ptr (sel_registerName "supportsSecureCoding"))))

;; --- Swift-native methods (receiver-handle trampolines, ADR-0030) ---
(define nsarray-make-iterator
  (let ([raw (get-ffi-obj 'aw_racket_swift_m_Foundation_NSArray_makeIterator _aw-lib (_fun _pointer aw-> _pointer))])
    (lambda (self)
      (raw (coerce-arg self)))))
