#lang racket/base
;; Generated binding for NSTimer (Foundation)
;; Do not edit — regenerate from enriched IR

(require "../../runtime/ffi2-dispatch.rkt"
         (except-in ffi/unsafe ->)
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../runtime/objc-base.rkt"
         "../../runtime/coerce.rkt"
         "../../runtime/block.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/Foundation.framework/Foundation"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
(define (nsdate? v) (objc-instance-of? v "NSDate"))
(define (nstimer? v) (objc-instance-of? v "NSTimer"))
(provide NSTimer)
(provide/contract
  [make-nstimer-init-with-fire-date-interval-repeats-block (c-> (or/c string? objc-object? #f) real? boolean? (or/c procedure? #f) any/c)]
  [make-nstimer-init-with-fire-date-interval-target-selector-user-info-repeats (c-> (or/c string? objc-object? #f) real? (or/c string? objc-object? #f) string? (or/c string? objc-object? #f) boolean? any/c)]
  [nstimer-fire-date (c-> nstimer? (or/c nsdate? objc-nil?))]
  [nstimer-set-fire-date! (c-> nstimer? (or/c string? objc-object? #f) void?)]
  [nstimer-time-interval (c-> nstimer? real?)]
  [nstimer-tolerance (c-> nstimer? real?)]
  [nstimer-set-tolerance! (c-> nstimer? real? void?)]
  [nstimer-user-info (c-> nstimer? any/c)]
  [nstimer-valid (c-> nstimer? boolean?)]
  [nstimer-fire (c-> nstimer? void?)]
  [nstimer-invalidate (c-> nstimer? void?)]
  [nstimer-is-valid (c-> nstimer? boolean?)]
  [nstimer-scheduled-timer-with-time-interval-invocation-repeats (c-> real? (or/c string? objc-object? #f) boolean? (or/c nstimer? objc-nil?))]
  [nstimer-scheduled-timer-with-time-interval-repeats-block (c-> real? boolean? (or/c procedure? #f) (or/c nstimer? objc-nil?))]
  [nstimer-scheduled-timer-with-time-interval-target-selector-user-info-repeats (c-> real? (or/c string? objc-object? #f) string? (or/c string? objc-object? #f) boolean? (or/c nstimer? objc-nil?))]
  [nstimer-timer-with-time-interval-invocation-repeats (c-> real? (or/c string? objc-object? #f) boolean? (or/c nstimer? objc-nil?))]
  [nstimer-timer-with-time-interval-repeats-block (c-> real? boolean? (or/c procedure? #f) (or/c nstimer? objc-nil?))]
  [nstimer-timer-with-time-interval-target-selector-user-info-repeats (c-> real? (or/c string? objc-object? #f) string? (or/c string? objc-object? #f) boolean? (or/c nstimer? objc-nil?))]
  )

;; --- Class reference ---
(import-class NSTimer)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_d (-> ptr_t ptr_t double_t))
(define-aw-msg aw_racket_msg_0_v (-> ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PdPPPb_P (-> ptr_t ptr_t ptr_t double_t ptr_t ptr_t ptr_t bool_t ptr_t))
(define-aw-msg aw_racket_msg_PdbP_P (-> ptr_t ptr_t ptr_t double_t bool_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_d_v (-> ptr_t ptr_t double_t void_t))
(define-aw-msg aw_racket_msg_dPPPb_P (-> ptr_t ptr_t double_t ptr_t ptr_t ptr_t bool_t ptr_t))
(define-aw-msg aw_racket_msg_dPb_P (-> ptr_t ptr_t double_t ptr_t bool_t ptr_t))
(define-aw-msg aw_racket_msg_dbP_P (-> ptr_t ptr_t double_t bool_t ptr_t ptr_t))

;; --- Constructors ---
;; block param 3: stored (retained across calls)
(define (make-nstimer-init-with-fire-date-interval-repeats-block date interval repeats block)
  (define-values (_blk3 _blk3-id)
    (make-objc-block block (list _id) _void))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PdbP_P (id->ffi2-ptr (tell NSTimer alloc)) (id->ffi2-ptr (sel_registerName "initWithFireDate:interval:repeats:block:")) (id->ffi2-ptr (coerce-arg date)) interval repeats (id->ffi2-ptr _blk3)))
   #:retained #t))

(define (make-nstimer-init-with-fire-date-interval-target-selector-user-info-repeats date ti t s ui rep)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PdPPPb_P (id->ffi2-ptr (tell NSTimer alloc)) (id->ffi2-ptr (sel_registerName "initWithFireDate:interval:target:selector:userInfo:repeats:")) (id->ffi2-ptr (coerce-arg date)) ti (id->ffi2-ptr (coerce-arg t)) (id->ffi2-ptr (sel_registerName s)) (id->ffi2-ptr (coerce-arg ui)) rep))
   #:retained #t))


;; --- Properties ---
(define (nstimer-fire-date self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fireDate"))))))
(define (nstimer-set-fire-date! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFireDate:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstimer-time-interval self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "timeInterval"))))
(define (nstimer-tolerance self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tolerance"))))
(define (nstimer-set-tolerance! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTolerance:")) value))
(define (nstimer-user-info self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userInfo"))))))
(define (nstimer-valid self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "valid"))))

;; --- Instance methods ---
(define (nstimer-fire self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fire"))))
(define (nstimer-invalidate self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "invalidate"))))
(define (nstimer-is-valid self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isValid"))))

;; --- Class methods ---
(define (nstimer-scheduled-timer-with-time-interval-invocation-repeats ti invocation yes-or-no)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dPb_P (id->ffi2-ptr NSTimer) (id->ffi2-ptr (sel_registerName "scheduledTimerWithTimeInterval:invocation:repeats:")) ti (id->ffi2-ptr (coerce-arg invocation)) yes-or-no))
   ))
;; block param 2: stored (retained across calls)
(define (nstimer-scheduled-timer-with-time-interval-repeats-block interval repeats block)
  (define-values (_blk2 _blk2-id)
    (make-objc-block block (list _id) _void))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dbP_P (id->ffi2-ptr NSTimer) (id->ffi2-ptr (sel_registerName "scheduledTimerWithTimeInterval:repeats:block:")) interval repeats (id->ffi2-ptr _blk2)))
   ))
(define (nstimer-scheduled-timer-with-time-interval-target-selector-user-info-repeats ti a-target a-selector user-info yes-or-no)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dPPPb_P (id->ffi2-ptr NSTimer) (id->ffi2-ptr (sel_registerName "scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:")) ti (id->ffi2-ptr (coerce-arg a-target)) (id->ffi2-ptr (sel_registerName a-selector)) (id->ffi2-ptr (coerce-arg user-info)) yes-or-no))
   ))
(define (nstimer-timer-with-time-interval-invocation-repeats ti invocation yes-or-no)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dPb_P (id->ffi2-ptr NSTimer) (id->ffi2-ptr (sel_registerName "timerWithTimeInterval:invocation:repeats:")) ti (id->ffi2-ptr (coerce-arg invocation)) yes-or-no))
   ))
;; block param 2: stored (retained across calls)
(define (nstimer-timer-with-time-interval-repeats-block interval repeats block)
  (define-values (_blk2 _blk2-id)
    (make-objc-block block (list _id) _void))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dbP_P (id->ffi2-ptr NSTimer) (id->ffi2-ptr (sel_registerName "timerWithTimeInterval:repeats:block:")) interval repeats (id->ffi2-ptr _blk2)))
   ))
(define (nstimer-timer-with-time-interval-target-selector-user-info-repeats ti a-target a-selector user-info yes-or-no)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dPPPb_P (id->ffi2-ptr NSTimer) (id->ffi2-ptr (sel_registerName "timerWithTimeInterval:target:selector:userInfo:repeats:")) ti (id->ffi2-ptr (coerce-arg a-target)) (id->ffi2-ptr (sel_registerName a-selector)) (id->ffi2-ptr (coerce-arg user-info)) yes-or-no))
   ))
