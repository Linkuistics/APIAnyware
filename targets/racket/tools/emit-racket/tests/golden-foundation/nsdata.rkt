#lang racket/base
;; Generated binding for NSData (Foundation)
;; Do not edit — regenerate from enriched IR

(require "../../runtime/ffi2-dispatch.rkt"
         (except-in ffi/unsafe ->)
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../runtime/objc-base.rkt"
         "../../runtime/coerce.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/Foundation.framework/Foundation"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(provide NSData)
(provide/contract
  [make-nsdata-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [nsdata-bytes (c-> nsdata? (or/c cpointer? #f))]
  [nsdata-description (c-> nsdata? (or/c nsstring? objc-nil?))]
  [nsdata-end-index (c-> nsdata? exact-integer?)]
  [nsdata-length (c-> nsdata? exact-nonnegative-integer?)]
  [nsdata-regions (c-> nsdata? (or/c nsarray? objc-nil?))]
  [nsdata-start-index (c-> nsdata? exact-integer?)]
  [nsdata-copy-with-zone (c-> nsdata? (or/c cpointer? #f) any/c)]
  [nsdata-encode-with-coder (c-> nsdata? (or/c string? objc-object? #f) void?)]
  [nsdata-mutable-copy-with-zone (c-> nsdata? (or/c cpointer? #f) any/c)]
  [nsdata-supports-secure-coding (c-> boolean?)]
  )

;; --- Class reference ---
(import-class NSData)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_q (-> ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_0_Q (-> ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))

;; --- Constructors ---
(define (make-nsdata-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSData alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))


;; --- Properties ---
(define (nsdata-bytes self)
  (ptr_t->cpointer (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bytes")))))
(define (nsdata-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "description"))))))
(define (nsdata-end-index self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endIndex"))))
(define (nsdata-length self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "length"))))
(define (nsdata-regions self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "regions"))))))
(define (nsdata-start-index self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "startIndex"))))

;; --- Instance methods ---
(define (nsdata-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "copyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))
(define (nsdata-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nsdata-mutable-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mutableCopyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))

;; --- Class methods ---
(define (nsdata-supports-secure-coding)
  (aw_racket_msg_0_b (id->ffi2-ptr NSData) (id->ffi2-ptr (sel_registerName "supportsSecureCoding"))))
