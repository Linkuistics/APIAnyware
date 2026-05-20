#lang racket/base
;; Generated binding for TKManager (TestKit)
;; Do not edit — regenerate from enriched IR

(require ffi/unsafe
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../../runtime/objc-base.rkt"
         "../../../runtime/coerce.rkt")

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

;; --- Constructors ---
(define (make-tkmanager)
  (wrap-objc-object
   (tell (tell TKManager alloc) init)
   #:retained #t))


;; --- Instance methods ---
(define (tkmanager-dealloc self)
  (tell #:type _void (coerce-arg self) dealloc))
(define (tkmanager-description self)
  (wrap-objc-object
   (tell (coerce-arg self) description)))
