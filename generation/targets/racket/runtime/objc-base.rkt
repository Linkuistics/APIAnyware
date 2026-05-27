#lang racket/base
;; objc-base.rkt — Core ObjC object wrapping with GC-attached release
;;
;; When libAPIAnywareRacket.dylib is available, uses aw_common_autorelease_push/pop
;; and aw_common_retain/release. Falls back to direct libobjc calls when absent.
;;
;; Provides:
;;   wrap-objc-object   — wrap an ObjC pointer with a release finalizer
;;   borrow-objc-object — wrap an ObjC pointer WITHOUT retain/finalizer (callback args)
;;   unwrap-objc-object — extract the raw cpointer for FFI calls
;;   with-autorelease-pool — syntax for @autoreleasepool scoping
;;   objc-thread         — spawn a thread with autorelease pool
;;   with-objc-pool-guard — wrap callback to push/pop pool per invocation
;;   objc-retain         — explicit retain
;;   objc-release        — explicit release

(require ffi/unsafe
         ffi/unsafe/objc
         "swift-helpers.rkt")

(provide wrap-objc-object
         borrow-objc-object
         unwrap-objc-object
         as-id
         with-autorelease-pool
         objc-thread
         with-objc-pool-guard
         objc-retain
         objc-release
         objc-autorelease
         objc-object?
         objc-object-ptr
         objc-null?
         objc-null
         objc-nil?
         nil->false
         objc-instance-of?)

;; --- Autorelease pool (fallback when Swift helpers unavailable) ---

(define objc-lib (ffi-lib "libobjc"))
(define objc_autoreleasePoolPush-raw
  (get-ffi-obj "objc_autoreleasePoolPush" objc-lib (_fun -> _pointer)))
(define objc_autoreleasePoolPop-raw
  (get-ffi-obj "objc_autoreleasePoolPop" objc-lib (_fun _pointer -> _void)))

;; Dispatch to Swift helpers or raw ObjC runtime
(define (autorelease-push)
  (if swift-available?
      (swift:autorelease-push)
      (objc_autoreleasePoolPush-raw)))

(define (autorelease-pop pool)
  (if swift-available?
      (swift:autorelease-pop pool)
      (objc_autoreleasePoolPop-raw pool)))

;; Struct wrapping an ObjC object pointer.
;; Using a struct lets us attach a finalizer and prevent premature GC.
(struct objc-object (ptr prevent-gc)
  #:mutable
  #:transparent)

(define objc-null (objc-object #f '()))

(define (objc-null? obj)
  (or (not (objc-object-ptr obj))
      (ptr-equal? (objc-object-ptr obj) #f)))

;; Wrap a raw ObjC pointer with a release finalizer.
;;
;; #:retained determines ownership transfer:
;;   #t — caller already owns +1 (init/copy/new/mutableCopy).
;;         The finalizer's release balances this +1.
;;   #f — caller does NOT own (autoreleased, +0 return).
;;         We call retain first, then the finalizer's release balances our retain.
;;
;; If ptr is null/nil, returns objc-null (no retain, no finalizer).
(define (wrap-objc-object ptr #:retained [retained #f])
  (if (or (not ptr) (and (cpointer? ptr) (ptr-equal? ptr #f)))
      objc-null
      (let ()
        ;; For +0 (autoreleased) objects, retain immediately to prevent
        ;; the autorelease pool from deallocating the object.
        (unless retained
          (if swift-available?
              (swift:retain ptr)
              (tell ptr retain)))
        (let ([obj (objc-object ptr '())])
          (register-finalizer obj release-prevent-gc)
          obj))))

;; Wrap a raw ObjC pointer as an objc-object WITHOUT retain or finalizer.
;;
;; Use for borrowed references (e.g. delegate callback args from the Swift
;; trampoline) that are valid only for the duration of the call. The caller
;; must not store the result beyond the callback scope.
;;
;; Returns objc-null for null/nil pointers.
(define (borrow-objc-object ptr)
  (if (or (not ptr) (and (cpointer? ptr) (ptr-equal? ptr #f)))
      objc-null
      (objc-object (cast ptr _pointer _id) '())))

;; Finalizer: release the ObjC object when the wrapper is collected.
(define (release-prevent-gc obj)
  (when (objc-object-ptr obj)
    (if swift-available?
        (swift:release (objc-object-ptr obj))
        (tell (objc-object-ptr obj) release))
    (set-objc-object-ptr! obj #f)))

;; Unwrap to raw pointer for FFI calls.
(define (unwrap-objc-object obj)
  (cond
    [(objc-object? obj) (objc-object-ptr obj)]
    [(cpointer? obj) obj]
    [else (error 'unwrap-objc-object "expected objc-object or cpointer, got ~a" obj)]))

;; Ensure an ObjC reference is _id-tagged for use with `tell`.
;; Both branches must cast — a raw cpointer pulled out of an objc-object
;; struct is *not* automatically _id-tagged, and `tell` rejects it with
;; "id->C: argument is not `id` pointer".
(define (as-id obj)
  (cond
    [(not obj) #f]
    [(objc-object? obj) (cast (objc-object-ptr obj) _pointer _id)]
    [(cpointer? obj) (cast obj _pointer _id)]
    [else (error 'as-id "expected objc-object or cpointer, got ~a" obj)]))

;; Explicit retain/release for manual memory management
(define (objc-retain obj)
  (if swift-available?
      (begin (swift:retain (unwrap-objc-object obj)) obj)
      (begin (tell (unwrap-objc-object obj) retain) obj)))

(define (objc-release obj)
  (when (objc-object? obj)
    (when (objc-object-ptr obj)
      (if swift-available?
          (swift:release (objc-object-ptr obj))
          (tell (objc-object-ptr obj) release))
      (set-objc-object-ptr! obj #f))))

;; Autorelease an ObjC object and return the raw pointer.
;; Converts a +1 retained pointer to +0 autoreleased. Use for delegate
;; callbacks that must return an autoreleased object (e.g. NSString from
;; string->nsstring). Returns #f for nil inputs.
(define (objc-autorelease ptr)
  (cond
    [(not ptr) #f]
    [(objc-object? ptr)
     (tell (cast (objc-object-ptr ptr) _pointer _id) autorelease)]
    [(cpointer? ptr)
     (if (ptr-equal? ptr #f)
         #f
         (tell (cast ptr _pointer _id) autorelease))]
    [else (error 'objc-autorelease "expected objc-object, cpointer, or #f, got ~a" ptr)]))

;; Check if any ObjC reference is nil
(define (objc-nil? v)
  (cond
    [(not v) #t]
    [(objc-object? v) (objc-null? v)]
    [(cpointer? v) (ptr-equal? v #f)]
    [else #f]))

;; Convert a potentially-nil ObjC pointer to #f if nil.
(define (nil->false ptr)
  (if (or (not ptr) (and (cpointer? ptr) (ptr-equal? ptr #f)))
      #f
      ptr))

;; Syntax: (with-autorelease-pool body ...)
;; Creates an autorelease pool, evaluates body, then drains the pool.
(define-syntax-rule (with-autorelease-pool body ...)
  (let ([pool (autorelease-push)])
    (begin0
      (begin body ...)
      (autorelease-pop pool))))

;; Spawn a thread with an autorelease pool.
;; The pool is drained when body returns.
;; Returns the thread handle.
(define (objc-thread body)
  (thread
   (lambda ()
     (with-autorelease-pool
       (body)))))

;; Wrap a callback so every invocation pushes/pops an autorelease pool.
;; Use for callbacks that may be invoked on threads controlled by Cocoa
;; (e.g., notification observers, timer callbacks).
(define (with-objc-pool-guard callback)
  (lambda args
    (with-autorelease-pool
      (apply callback args))))

;; --- Class introspection ─────────────────────────────────────

;; objc_getClass returns the Class object for a given class name, or #f.
(define _objc_getClass
  (get-ffi-obj "objc_getClass" objc-lib
    (_fun _string -> _pointer)))

;; Cache class lookups — the same class name is queried from many return sites.
(define class-cache (make-hash))

(define (get-objc-class name)
  (hash-ref! class-cache name
    (lambda ()
      (define cls (_objc_getClass name))
      (if (and cls (not (ptr-equal? cls #f)))
          (cast cls _pointer _id)
          #f))))

;; (objc-instance-of? v class-name) → boolean?
;; Returns #t if v is an ObjC object that is an instance of the named class
;; or any of its subclasses (backed by isKindOfClass:).
;; Returns #f for #f, objc-null, non-objc-object values, or unknown class names.
(define (objc-instance-of? v class-name)
  (cond
    [(not v) #f]
    [(and (objc-object? v) (objc-null? v)) #f]
    [else
     (define cls (get-objc-class class-name))
     (and cls
          (let ([ptr (cond
                       [(objc-object? v) (cast (objc-object-ptr v) _pointer _id)]
                       [(cpointer? v) (cast v _pointer _id)]
                       [else #f])])
            (and ptr
                 (tell #:type _bool ptr isKindOfClass: cls))))]))
