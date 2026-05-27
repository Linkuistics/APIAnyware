#lang racket/base
;; coerce.rkt — Auto-coercion of Racket values to ObjC _id pointers
;;
;; Provides coerce-arg for smart parameter passing in generated wrappers.
;; Re-exports all public symbols from objc-base.rkt and type-mapping.rkt
;; so generated files can require just this module.

(require ffi/unsafe
         ffi/unsafe/objc
         "objc-base.rkt"
         "type-mapping.rkt")

;; Re-export all public symbols from objc-base.rkt
(provide (all-from-out "objc-base.rkt"))

;; Re-export all public symbols from type-mapping.rkt
(provide (all-from-out "type-mapping.rkt"))

;; Coerce a Racket value to an _id-tagged ObjC pointer.
;;
;; Accepted inputs:
;;   string?       → string->nsstring, cast to _id
;;   objc-object?  → unwrap pointer (already _id-tagged)
;;   cpointer?     → cast to _id
;;   #f            → #f (nil)
;;
;; Only strings are auto-coerced. Lists and hashes are NOT — that would be
;; too implicit for a thin wrapper layer.
(provide coerce-arg)

(define (coerce-arg v)
  (cond
    [(not v) #f]
    [(string? v) (string->nsstring v)]
    [(objc-object? v) (cast (objc-object-ptr v) _pointer _id)]
    [(cpointer? v) (cast v _pointer _id)]
    [else (error 'coerce-arg "expected string, objc-object, cpointer, or #f, got ~a" v)]))
