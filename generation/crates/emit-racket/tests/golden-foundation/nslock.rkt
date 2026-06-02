#lang racket/base
;; Generated binding for NSLock (Foundation)
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

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_v (-> ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_b (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))

;; --- Constructors ---
(define (make-nslock)
  (wrap-objc-object
   (tell (tell NSLock alloc) init)
   #:retained #t))


;; --- Properties ---
(define (nslock-name self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "name"))))))
(define (nslock-set-name! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setName:")) (id->ffi2-ptr (coerce-arg value))))

;; --- Instance methods ---
(define (nslock-lock self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lock"))))
(define (nslock-lock-before-date self limit)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lockBeforeDate:")) (id->ffi2-ptr (coerce-arg limit))))
(define (nslock-try-lock self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tryLock"))))
(define (nslock-unlock self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "unlock"))))
