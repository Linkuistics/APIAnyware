#lang racket/base
;; Generated binding for NSStatusBar (AppKit)
;; Do not edit — regenerate from enriched IR

(require "../../runtime/ffi2-dispatch.rkt"
         (except-in ffi/unsafe ->)
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../runtime/objc-base.rkt"
         "../../runtime/coerce.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/AppKit.framework/AppKit"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
(define (nsstatusbar? v) (objc-instance-of? v "NSStatusBar"))
(define (nsstatusitem? v) (objc-instance-of? v "NSStatusItem"))
(provide NSStatusBar)
(provide/contract
  [make-nsstatusbar (c-> any/c)]
  [nsstatusbar-system-status-bar (c-> (or/c nsstatusbar? objc-nil?))]
  [nsstatusbar-thickness (c-> nsstatusbar? real?)]
  [nsstatusbar-vertical (c-> nsstatusbar? boolean?)]
  [nsstatusbar-is-vertical (c-> nsstatusbar? boolean?)]
  [nsstatusbar-remove-status-item! (c-> nsstatusbar? (or/c string? objc-object? #f) void?)]
  [nsstatusbar-status-item-with-length (c-> nsstatusbar? real? (or/c nsstatusitem? objc-nil?))]
  )

;; --- Class reference ---
(import-class NSStatusBar)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_d (-> ptr_t ptr_t double_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_d_P (-> ptr_t ptr_t double_t ptr_t))

;; --- Constructors ---
(define (make-nsstatusbar)
  (wrap-objc-object
   (tell (tell NSStatusBar alloc) init)
   #:retained #t))


;; --- Properties ---
(define (nsstatusbar-system-status-bar)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSStatusBar) (id->ffi2-ptr (sel_registerName "systemStatusBar"))))))
(define (nsstatusbar-thickness self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "thickness"))))
(define (nsstatusbar-vertical self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "vertical"))))

;; --- Instance methods ---
(define (nsstatusbar-is-vertical self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isVertical"))))
(define (nsstatusbar-remove-status-item! self item)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeStatusItem:")) (id->ffi2-ptr (coerce-arg item))))
(define (nsstatusbar-status-item-with-length self length)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_d_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "statusItemWithLength:")) length))
   ))
