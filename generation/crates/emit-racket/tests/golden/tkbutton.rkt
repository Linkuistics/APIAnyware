#lang racket/base
;; Generated binding for TKButton (TestKit)
;; Do not edit — regenerate from enriched IR

(require "../../runtime/ffi2-dispatch.rkt"
         (except-in ffi/unsafe ->)
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../runtime/objc-base.rkt"
         "../../runtime/coerce.rkt"
         "../../runtime/block.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/TestKit.framework/TestKit"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
(define (nsrect? v) (objc-instance-of? v "NSRect"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (tkbutton? v) (objc-instance-of? v "TKButton"))
(provide TKButton)
(provide/contract
  [make-tkbutton (c-> any/c)]
  [tkbutton-title (c-> tkbutton? (or/c nsstring? objc-nil?))]
  [tkbutton-set-title! (c-> tkbutton? (or/c string? objc-object? #f) void?)]
  [tkbutton-hidden (c-> tkbutton? boolean?)]
  [tkbutton-set-hidden! (c-> tkbutton? boolean? void?)]
  [tkbutton-tag (c-> tkbutton? exact-integer?)]
  [tkbutton-set-tag! (c-> tkbutton? exact-integer? void?)]
  [tkbutton-frame (c-> tkbutton? (or/c nsrect? objc-nil?))]
  [tkbutton-dealloc (c-> tkbutton? void?)]
  [tkbutton-description (c-> tkbutton? (or/c nsstring? objc-nil?))]
  [tkbutton-set-needs-display! (c-> tkbutton? void?)]
  [tkbutton-animate-with-duration-animations (c-> tkbutton? real? (or/c procedure? #f) void?)]
  )

;; --- Class reference ---
(import-class TKButton)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_q (-> ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_0_v (-> ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_b_v (-> ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_q_v (-> ptr_t ptr_t int64_t void_t))
(define-aw-msg aw_racket_msg_dP_v (-> ptr_t ptr_t double_t ptr_t void_t))

;; --- Constructors ---
(define (make-tkbutton)
  (wrap-objc-object
   (tell (tell TKButton alloc) init)
   #:retained #t))


;; --- Properties ---
(define (tkbutton-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "title"))))))
(define (tkbutton-set-title! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTitle:")) (id->ffi2-ptr (coerce-arg value))))
(define (tkbutton-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hidden"))))
(define (tkbutton-set-hidden! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHidden:")) value))
(define (tkbutton-tag self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tag"))))
(define (tkbutton-set-tag! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTag:")) value))
(define (tkbutton-frame self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frame"))))))

;; --- Instance methods ---
(define (tkbutton-dealloc self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dealloc"))))
(define (tkbutton-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "description"))))
   ))
(define (tkbutton-set-needs-display! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsDisplay"))))
(define (tkbutton-animate-with-duration-animations self duration animations)
  (define-values (_blk1 _blk1-id)
    (make-objc-block animations (list ) _void))
  (aw_racket_msg_dP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animateWithDuration:animations:")) duration (id->ffi2-ptr _blk1)))
