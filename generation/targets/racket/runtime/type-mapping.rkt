#lang racket/base
;; type-mapping.rkt — Conversions between Racket and ObjC Foundation types
;;
;; Provides:
;;   string->nsstring / nsstring->string  — Racket string ↔ NSString
;;   list->nsarray / nsarray->list        — Racket list ↔ NSArray
;;   hash->nsdictionary / nsdictionary->hash — Racket hash ↔ NSDictionary
;;   make-nsrect, make-nspoint, make-nssize — struct constructors

(require ffi/unsafe
         ;; `_id` tagging only — `tell`/`import-class`/`sel_registerName` and the
         ;; in-Racket CFString/objc_msgSend marshalling were retired in leaf
         ;; 050/030; the per-element work now lives in libAPIAnywareRacket
         ;; (CollectionMarshal.swift / StringConversion.swift).
         ffi/unsafe/objc
         "objc-base.rkt"
         "swift-helpers.rkt")

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

;; arm64 integer types
(define _NSUInteger _uint64)
(define _NSInteger _int64)

;; --- NSString conversions (Depth-2, leaf 050/030) ---
;;
;; The per-value marshalling now lives in libAPIAnywareRacket
;; (StringConversion.swift); these are thin shims over the native helpers, not
;; in-Racket CFString / `tell …UTF8String`.

;; Convert a Racket string to an NSString (raw `_id` pointer, retained +1).
(define (string->nsstring str)
  (cast (swift:string-to-nsstring str) _pointer _id))

;; Convert an NSString (raw pointer) to a Racket string. The native helper
;; returns a +0/borrowed `char*` (`-utf8String`); ffi `_string` copies it into a
;; Racket string immediately (see StringConversion.swift ownership note).
(define (nsstring->string nsstr)
  (if (not nsstr)
      ""
      (or (swift:nsstring-to-string nsstr) "")))

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

;; --- NSArray conversions (batched native — leaf 050/030) ---

;; Convert a Racket list of ObjC values to an NSArray in one native call
;; (`aw_racket_list_to_nsarray`), replacing the per-element `tell addObject:`
;; loop. Accepts objc-objects or raw cpointers; returns an objc-object wrapper
;; around a +1-retained NSMutableArray so callers can pass it straight into
;; class-wrapper param contracts (which reject raw cpointers since 2026-04-16).
(define (list->nsarray lst)
  (let ([items (map unwrap-objc-object lst)])
    (wrap-objc-object (swift:list->nsarray items (length items))
                      #:retained #t)))

;; Convert an NSArray to a Racket list of raw ObjC `_id` pointers in one native
;; call (`aw_racket_nsarray_get_all`), replacing the per-index `objectAtIndex:`
;; loop. Accepts either a raw cpointer or an objc-object wrapper. The returned
;; element pointers are unretained — valid because `nsarr` is held across the call.
(define (nsarray->list nsarr)
  (let* ([raw (unwrap-objc-object nsarr)]
         [count (swift:nsarray-count raw)])
    (if (zero? count)
        '()
        (map (lambda (p) (cast p _pointer _id))
             (swift:nsarray-get-all raw count)))))

;; --- NSDictionary conversions (batched native — leaf 050/030) ---

;; Convert a Racket hash (string keys → ObjC values) to an NSDictionary in one
;; native call (`aw_racket_hash_to_nsdictionary`), replacing the per-entry
;; NSString creation + `setObject:forKey:` loop. Returns an objc-object wrapper
;; around a +1-retained NSMutableDictionary; see list->nsarray for the rationale.
(define (hash->nsdictionary ht)
  (define-values (keys vals)
    (for/lists (keys vals) ([(k v) (in-hash ht)])
      (values k (unwrap-objc-object v))))
  (wrap-objc-object (swift:hash->nsdictionary keys vals (length keys))
                    #:retained #t))

;; Convert an NSDictionary to a Racket hash (string keys → ObjC `_id` pointers)
;; in one native call (`aw_racket_nsdictionary_get_all`), replacing the `allKeys`
;; + per-key `objectForKey:` + NSString→string loop. Accepts a raw cpointer or an
;; objc-object wrapper. Key `char*`s are +0/borrowed; ffi `_string` copies them.
(define (nsdictionary->hash nsdict)
  (let* ([raw (unwrap-objc-object nsdict)]
         [count (swift:nsdictionary-count raw)]
         [ht (make-hash)])
    (when (> count 0)
      (define-values (keys vals) (swift:nsdictionary-get-all raw count))
      (for ([k (in-list keys)] [v (in-list vals)])
        (hash-set! ht k (cast v _pointer _id))))
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
