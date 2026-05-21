#lang racket/base
;; Generated binding for TKView (TestKit)
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

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _bool -> _void)))
(define _msg-1  ; (_fun _pointer _pointer _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _void)))

;; --- Constructors ---
(define (make-tkview)
  (wrap-objc-object
   (tell (tell TKView alloc) init)
   #:retained #t))


;; --- Properties ---
(define (tkview-title self)
  (wrap-objc-object
   (tell (coerce-arg self) title)))
(define (tkview-set-title! self value)
  (tell #:type _void (coerce-arg self) setTitle: (coerce-arg value)))
(define (tkview-hidden self)
  (tell #:type _bool (coerce-arg self) hidden))
(define (tkview-set-hidden! self value)
  (_msg-0 (coerce-arg self) (sel_registerName "setHidden:") value))
(define (tkview-tag self)
  (tell #:type _int64 (coerce-arg self) tag))
(define (tkview-set-tag! self value)
  (_msg-1 (coerce-arg self) (sel_registerName "setTag:") value))
(define (tkview-frame self)
  (wrap-objc-object
   (tell (coerce-arg self) frame)))

;; --- Instance methods ---
(define (tkview-dealloc self)
  (tell #:type _void (coerce-arg self) dealloc))
(define (tkview-description self)
  (wrap-objc-object
   (tell (coerce-arg self) description)))
