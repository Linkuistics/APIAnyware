#lang racket/base
;; Generated binding for NSArray (Foundation)
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
(define (mirror? v) (objc-instance-of? v "Mirror"))
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsfastenumerationiterator? v) (objc-instance-of? v "NSFastEnumerationIterator"))
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
  [nsarray-make-iterator (c-> nsarray? (or/c nsfastenumerationiterator? objc-nil?))]
  [nsarray-mutable-copy-with-zone (c-> nsarray? (or/c cpointer? #f) any/c)]
  [nsarray-object-at-index (c-> nsarray? exact-nonnegative-integer? any/c)]
  [nsarray-supports-secure-coding (c-> boolean?)]
  )

;; --- Class reference ---
(import-class NSArray)

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _bool)))
(define _msg-1  ; (_fun _pointer _pointer -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _uint64)))
(define _msg-2  ; (_fun _pointer _pointer _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _id)))
(define _msg-3  ; (_fun _pointer _pointer _pointer _pointer _uint64 -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _pointer _uint64 -> _uint64)))
(define _msg-4  ; (_fun _pointer _pointer _pointer _uint64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _uint64 -> _id)))
(define _msg-5  ; (_fun _pointer _pointer _uint64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _id)))

;; --- Constructors ---
(define (make-nsarray-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSArray alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nsarray-init-with-objects-count objects cnt)
  (wrap-objc-object
   (_msg-4 (tell NSArray alloc)
       (sel_registerName "initWithObjects:count:")
       objects
       cnt)
   #:retained #t))


;; --- Properties ---
(define (nsarray-count self)
  (tell #:type _uint64 (coerce-arg self) count))
(define (nsarray-custom-mirror self)
  (wrap-objc-object
   (tell (coerce-arg self) customMirror)))
(define (nsarray-description self)
  (wrap-objc-object
   (tell (coerce-arg self) description)))
(define (nsarray-first-object self)
  (wrap-objc-object
   (tell (coerce-arg self) firstObject)))
(define (nsarray-last-object self)
  (wrap-objc-object
   (tell (coerce-arg self) lastObject)))
(define (nsarray-sorted-array-hint self)
  (wrap-objc-object
   (tell (coerce-arg self) sortedArrayHint)))
(define (nsarray-underestimated-count self)
  (tell #:type _int64 (coerce-arg self) underestimatedCount))

;; --- Instance methods ---
(define (nsarray-copy-with-zone self zone)
  (wrap-objc-object
   (_msg-2 (coerce-arg self) (sel_registerName "copyWithZone:") zone)
   #:retained #t))
(define (nsarray-count-by-enumerating-with-state-objects-count self state buffer len)
  (_msg-3 (coerce-arg self) (sel_registerName "countByEnumeratingWithState:objects:count:") state buffer len))
(define (nsarray-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nsarray-make-iterator self)
  (wrap-objc-object
   (tell (coerce-arg self) makeIterator)))
(define (nsarray-mutable-copy-with-zone self zone)
  (wrap-objc-object
   (_msg-2 (coerce-arg self) (sel_registerName "mutableCopyWithZone:") zone)
   #:retained #t))
(define (nsarray-object-at-index self index)
  (wrap-objc-object
   (_msg-5 (coerce-arg self) (sel_registerName "objectAtIndex:") index)
   ))

;; --- Class methods ---
(define (nsarray-supports-secure-coding)
  (_msg-0 NSArray (sel_registerName "supportsSecureCoding")))
