#lang racket/base
;; Generated binding for TKObject (TestKit)
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
(define (tkobject? v) (objc-instance-of? v "TKObject"))
(provide TKObject)
(provide/contract
  [make-tkobject (c-> any/c)]
  [tkobject-dealloc (c-> tkobject? void?)]
  [tkobject-description (c-> tkobject? (or/c nsstring? objc-nil?))]
  )

;; --- Class reference ---
(import-class TKObject)

;; --- Constructors ---
(define (make-tkobject)
  (wrap-objc-object
   (tell (tell TKObject alloc) init)
   #:retained #t))


;; --- Instance methods ---
(define (tkobject-dealloc self)
  (tell #:type _void (coerce-arg self) dealloc))
(define (tkobject-description self)
  (wrap-objc-object
   (tell (coerce-arg self) description)))
