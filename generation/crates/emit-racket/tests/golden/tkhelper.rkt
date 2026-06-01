#lang racket/base
;; Generated binding for TKHelper (TestKit)
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
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (tkhelper? v) (objc-instance-of? v "TKHelper"))
(provide TKHelper)
(provide/contract
  [make-tkhelper (c-> any/c)]
  [tkhelper-dealloc (c-> tkhelper? void?)]
  [tkhelper-description (c-> tkhelper? (or/c nsstring? objc-nil?))]
  )

;; --- Class reference ---
(import-class TKHelper)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_v (-> ptr_t ptr_t void_t))

;; --- Constructors ---
(define (make-tkhelper)
  (wrap-objc-object
   (tell (tell TKHelper alloc) init)
   #:retained #t))


;; --- Instance methods ---
(define (tkhelper-dealloc self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dealloc"))))
(define (tkhelper-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "description"))))
   ))
