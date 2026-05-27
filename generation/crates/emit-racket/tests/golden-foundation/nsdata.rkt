#lang racket/base
;; Generated binding for NSData (Foundation)
;; Do not edit — regenerate from enriched IR

(require ffi/unsafe
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
(define (range? v) (objc-instance-of? v "Range"))
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

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _bool)))
(define _msg-1  ; (_fun _pointer _pointer -> _pointer)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _pointer)))
(define _msg-2  ; (_fun _pointer _pointer -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _uint64)))
(define _msg-3  ; (_fun _pointer _pointer _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _id)))

;; --- Constructors ---
(define (make-nsdata-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSData alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))


;; --- Properties ---
(define (nsdata-bytes self)
  (tell #:type _pointer (coerce-arg self) bytes))
(define (nsdata-description self)
  (wrap-objc-object
   (tell (coerce-arg self) description)))
(define (nsdata-end-index self)
  (tell #:type _int64 (coerce-arg self) endIndex))
(define (nsdata-length self)
  (tell #:type _uint64 (coerce-arg self) length))
(define (nsdata-regions self)
  (wrap-objc-object
   (tell (coerce-arg self) regions)))
(define (nsdata-start-index self)
  (tell #:type _int64 (coerce-arg self) startIndex))

;; --- Instance methods ---
(define (nsdata-copy-with-zone self zone)
  (wrap-objc-object
   (_msg-3 (coerce-arg self) (sel_registerName "copyWithZone:") zone)
   #:retained #t))
(define (nsdata-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nsdata-mutable-copy-with-zone self zone)
  (wrap-objc-object
   (_msg-3 (coerce-arg self) (sel_registerName "mutableCopyWithZone:") zone)
   #:retained #t))

;; --- Class methods ---
(define (nsdata-supports-secure-coding)
  (_msg-0 NSData (sel_registerName "supportsSecureCoding")))
