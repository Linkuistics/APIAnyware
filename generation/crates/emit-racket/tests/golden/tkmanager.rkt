#lang racket/base
;; Generated binding for TKManager (TestKit)
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
(define (tkmanager? v) (objc-instance-of? v "TKManager"))
(provide TKManager)
(provide/contract
  [make-tkmanager (c-> any/c)]
  [tkmanager-dealloc (c-> tkmanager? void?)]
  [tkmanager-description (c-> tkmanager? (or/c nsstring? objc-nil?))]
  )

;; --- Class reference ---
(import-class TKManager)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_v (-> ptr_t ptr_t void_t))

;; --- Constructors ---
(define (make-tkmanager)
  (wrap-objc-object
   (tell (tell TKManager alloc) init)
   #:retained #t))


;; --- Instance methods ---
(define (tkmanager-dealloc self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dealloc"))))
(define (tkmanager-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "description"))))
   ))
