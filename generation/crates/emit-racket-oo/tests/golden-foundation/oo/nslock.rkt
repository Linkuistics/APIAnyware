#lang racket/base
;; Generated binding for NSLock (Foundation)
;; Do not edit — regenerate from enriched IR

(require ffi/unsafe
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../../runtime/objc-base.rkt"
         "../../../runtime/coerce.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/Foundation.framework/Foundation"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
(define (nslock? v) (objc-instance-of? v "NSLock"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(provide NSLock)
(provide/contract
  [make-nslock (c-> any/c)]
  [nslock-name (c-> nslock? (or/c nsstring? objc-nil?))]
  [nslock-set-name! (c-> nslock? (or/c string? objc-object? #f) void?)]
  [nslock-lock (c-> nslock? void?)]
  [nslock-lock-before-date (c-> nslock? (or/c string? objc-object? #f) boolean?)]
  [nslock-try-lock (c-> nslock? boolean?)]
  [nslock-unlock (c-> nslock? void?)]
  )

;; --- Class reference ---
(import-class NSLock)

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _bool)))
(define _msg-1  ; (_fun _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _bool)))

;; --- Constructors ---
(define (make-nslock)
  (wrap-objc-object
   (tell (tell NSLock alloc) init)
   #:retained #t))


;; --- Properties ---
(define (nslock-name self)
  (wrap-objc-object
   (tell (coerce-arg self) name)))
(define (nslock-set-name! self value)
  (tell #:type _void (coerce-arg self) setName: (coerce-arg value)))

;; --- Instance methods ---
(define (nslock-lock self)
  (tell #:type _void (coerce-arg self) lock))
(define (nslock-lock-before-date self limit)
  (_msg-1 (coerce-arg self) (sel_registerName "lockBeforeDate:") (coerce-arg limit)))
(define (nslock-try-lock self)
  (_msg-0 (coerce-arg self) (sel_registerName "tryLock")))
(define (nslock-unlock self)
  (tell #:type _void (coerce-arg self) unlock))
