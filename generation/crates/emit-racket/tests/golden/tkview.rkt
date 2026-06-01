#lang racket/base
;; Generated binding for TKView (TestKit)
;; Do not edit — regenerate from enriched IR

(require "../../runtime/ffi2-dispatch.rkt"
         (except-in ffi/unsafe ->)
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../runtime/objc-base.rkt"
         "../../runtime/coerce.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/TestKit.framework/TestKit"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
(define (nsrect? v) (objc-instance-of? v "NSRect"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (tkview? v) (objc-instance-of? v "TKView"))
(provide TKView)
(provide/contract
  [make-tkview (c-> any/c)]
  [tkview-title (c-> tkview? (or/c nsstring? objc-nil?))]
  [tkview-set-title! (c-> tkview? (or/c string? objc-object? #f) void?)]
  [tkview-hidden (c-> tkview? boolean?)]
  [tkview-set-hidden! (c-> tkview? boolean? void?)]
  [tkview-tag (c-> tkview? exact-integer?)]
  [tkview-set-tag! (c-> tkview? exact-integer? void?)]
  [tkview-frame (c-> tkview? (or/c nsrect? objc-nil?))]
  [tkview-dealloc (c-> tkview? void?)]
  [tkview-description (c-> tkview? (or/c nsstring? objc-nil?))]
  )

;; --- Class reference ---
(import-class TKView)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_q (-> ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_0_v (-> ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_b_v (-> ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_q_v (-> ptr_t ptr_t int64_t void_t))

;; --- Constructors ---
(define (make-tkview)
  (wrap-objc-object
   (tell (tell TKView alloc) init)
   #:retained #t))


;; --- Properties ---
(define (tkview-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "title"))))))
(define (tkview-set-title! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTitle:")) (id->ffi2-ptr (coerce-arg value))))
(define (tkview-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hidden"))))
(define (tkview-set-hidden! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHidden:")) value))
(define (tkview-tag self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tag"))))
(define (tkview-set-tag! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTag:")) value))
(define (tkview-frame self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frame"))))))

;; --- Instance methods ---
(define (tkview-dealloc self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dealloc"))))
(define (tkview-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "description"))))
   ))
