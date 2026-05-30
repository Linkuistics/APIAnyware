#lang racket/base
;; type-mapping.rkt — Conversions between Racket and ObjC Foundation types
;;
;; Provides:
;;   string->nsstring / nsstring->string  — Racket string ↔ NSString
;;   list->nsarray / nsarray->list        — Racket list ↔ NSArray
;;   hash->nsdictionary / nsdictionary->hash — Racket hash ↔ NSDictionary
;;   make-nsrect, make-nspoint, make-nssize — struct constructors

(require ffi/unsafe
         ffi/unsafe/objc
         "objc-base.rkt")

(provide string->nsstring
         nsstring->string
         ->string
         list->nsarray
         nsarray->list
         hash->nsdictionary
         nsdictionary->hash
         make-nspoint
         make-nssize
         make-nsrect
         _NSPoint _NSSize _NSRect _NSRange
         _NSEdgeInsets _NSDirectionalEdgeInsets
         _NSAffineTransformStruct _CGAffineTransform _CGVector
         NSPoint-x NSPoint-y
         NSSize-width NSSize-height
         NSRect-origin NSRect-size
         NSRange-location NSRange-length
         _NSUInteger _NSInteger)

;; Import Foundation classes
(import-class NSString NSMutableArray NSDictionary NSMutableDictionary)

;; CoreFoundation for string creation (toll-free bridged with NSString)
(define cf-lib
  (ffi-lib "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation"))
(define CFStringCreateWithCString
  (get-ffi-obj "CFStringCreateWithCString" cf-lib
    (_fun _pointer _string _uint32 -> _id)))
(define kCFStringEncodingUTF8 #x08000100)

;; Low-level ObjC runtime for methods with non-id parameters
(define objc-lib (ffi-lib "libobjc"))
(define msg-uint64->id
  (get-ffi-obj "objc_msgSend" objc-lib
    (_fun _pointer _pointer _uint64 -> _pointer)))
(define msg-id->id
  (get-ffi-obj "objc_msgSend" objc-lib
    (_fun _pointer _pointer _id -> _pointer)))

;; Selectors used internally
(define sel-objectAtIndex (sel_registerName "objectAtIndex:"))
(define sel-objectForKey (sel_registerName "objectForKey:"))
(define sel-count (sel_registerName "count"))

;; arm64 integer types
(define _NSUInteger _uint64)
(define _NSInteger _int64)

;; --- NSString conversions ---

;; Convert a Racket string to an NSString (returns raw ObjC pointer, retained +1).
(define (string->nsstring str)
  (CFStringCreateWithCString #f str kCFStringEncodingUTF8))

;; Convert an NSString (raw pointer) to a Racket string
(define (nsstring->string nsstr)
  (if (not nsstr)
      ""
      (tell #:type _string nsstr UTF8String)))

;; Convert an NSString value to a Racket string.
;; Accepts objc-object (from wrapper returns), raw cpointer, or #f/nil.
;; Returns "" for nil/null inputs.
(define (->string v)
  (cond
    [(not v) ""]
    [(objc-object? v) (nsstring->string (unwrap-objc-object v))]
    [(cpointer? v) (nsstring->string v)]
    [(string? v) v]
    [else (error '->string "expected objc-object, cpointer, string, or #f, got ~a" v)]))

;; --- NSArray conversions ---

;; Convert a Racket list of raw ObjC pointers to an NSArray.
;; Returns an objc-object wrapper around a +1-retained NSMutableArray so
;; callers can pass the result directly into class-wrapper param contracts
;; (which reject raw cpointers since 2026-04-16). Pass through
;; unwrap-objc-object when a raw pointer is needed for `tell` / objc_msgSend.
(define (list->nsarray lst)
  (let ([arr (tell (tell NSMutableArray alloc) init)])
    (for ([item (in-list lst)])
      (tell arr addObject: item))
    (wrap-objc-object arr #:retained #t)))

;; Convert an NSArray to a Racket list of raw ObjC pointers.
;; Accepts either a raw cpointer or an objc-object wrapper.
(define (nsarray->list nsarr)
  (let* ([raw (unwrap-objc-object nsarr)]
         [count (tell #:type _NSUInteger raw count)])
    (for/list ([i (in-range count)])
      (cast (msg-uint64->id raw sel-objectAtIndex i) _pointer _id))))

;; --- NSDictionary conversions ---

;; Convert a Racket hash (string keys → ObjC pointer values) to NSDictionary.
;; Returns an objc-object wrapper around a +1-retained NSMutableDictionary;
;; see list->nsarray for the rationale.
(define (hash->nsdictionary ht)
  (let ([dict (tell (tell NSMutableDictionary alloc) init)])
    (for ([(k v) (in-hash ht)])
      (let ([nskey (string->nsstring k)])
        (tell dict setObject: v forKey: nskey)
        (tell nskey release)))
    (wrap-objc-object dict #:retained #t)))

;; Convert an NSDictionary to a Racket hash (string keys → ObjC pointers).
;; Accepts either a raw cpointer or an objc-object wrapper.
(define (nsdictionary->hash nsdict)
  (let* ([raw (unwrap-objc-object nsdict)]
         [keys (tell raw allKeys)]
         [count (tell #:type _NSUInteger keys count)]
         [ht (make-hash)])
    (for ([i (in-range count)])
      (let* ([key (cast (msg-uint64->id keys sel-objectAtIndex i) _pointer _id)]
             [val (cast (msg-id->id raw sel-objectForKey key) _pointer _id)]
             [key-str (nsstring->string key)])
        (hash-set! ht key-str val)))
    ht))

;; --- Geometry struct types ---
;; These match the arm64 ABI layout.

;; NSPoint / CGPoint: {x: double, y: double}
(define-cstruct _NSPoint ([x _double] [y _double]))

;; NSSize / CGSize: {width: double, height: double}
(define-cstruct _NSSize ([width _double] [height _double]))

;; NSRect / CGRect: {origin: NSPoint, size: NSSize}
(define-cstruct _NSRect ([origin _NSPoint] [size _NSSize]))

;; NSRange: {location: uint64, length: uint64}
(define-cstruct _NSRange ([location _uint64] [length _uint64]))

;; NSEdgeInsets: {top: double, left: double, bottom: double, right: double}
(define-cstruct _NSEdgeInsets ([top _double] [left _double] [bottom _double] [right _double]))

;; NSDirectionalEdgeInsets: {top: double, leading: double, bottom: double, trailing: double}
(define-cstruct _NSDirectionalEdgeInsets ([top _double] [leading _double] [bottom _double] [trailing _double]))

;; NSAffineTransformStruct: {m11: double, m12: double, m21: double, m22: double, tX: double, tY: double}
(define-cstruct _NSAffineTransformStruct ([m11 _double] [m12 _double] [m21 _double] [m22 _double] [tX _double] [tY _double]))

;; CGAffineTransform: {a: double, b: double, c: double, d: double, tx: double, ty: double}
(define-cstruct _CGAffineTransform ([a _double] [b _double] [c _double] [d _double] [tx _double] [ty _double]))

;; CGVector: {dx: double, dy: double}
(define-cstruct _CGVector ([dx _double] [dy _double]))

;; Convenience constructors
(define (make-nspoint x y)
  (make-NSPoint (exact->inexact x) (exact->inexact y)))

(define (make-nssize w h)
  (make-NSSize (exact->inexact w) (exact->inexact h)))

(define (make-nsrect x y w h)
  (make-NSRect (make-NSPoint (exact->inexact x) (exact->inexact y))
               (make-NSSize (exact->inexact w) (exact->inexact h))))
