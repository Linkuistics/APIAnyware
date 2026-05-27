#lang racket/base
;; Generated binding for TKHelper (TestKit)
;; Do not edit — regenerate from enriched IR

(require ffi/unsafe
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

;; --- Constructors ---
(define (make-tkhelper)
  (wrap-objc-object
   (tell (tell TKHelper alloc) init)
   #:retained #t))


;; --- Instance methods ---
(define (tkhelper-dealloc self)
  (tell #:type _void (coerce-arg self) dealloc))
(define (tkhelper-description self)
  (wrap-objc-object
   (tell (coerce-arg self) description)))
