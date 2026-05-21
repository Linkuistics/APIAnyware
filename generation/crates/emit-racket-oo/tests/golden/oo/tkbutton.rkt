#lang racket/base
;; Generated binding for TKButton (TestKit)
;; Do not edit — regenerate from enriched IR

(require ffi/unsafe
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../../runtime/objc-base.rkt"
         "../../../runtime/coerce.rkt"
         "../../../runtime/block.rkt")

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

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _bool -> _void)))
(define _msg-1  ; (_fun _pointer _pointer _double _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double _pointer -> _void)))
(define _msg-2  ; (_fun _pointer _pointer _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _void)))

;; --- Constructors ---
(define (make-tkbutton)
  (wrap-objc-object
   (tell (tell TKButton alloc) init)
   #:retained #t))


;; --- Properties ---
(define (tkbutton-title self)
  (wrap-objc-object
   (tell (coerce-arg self) title)))
(define (tkbutton-set-title! self value)
  (tell #:type _void (coerce-arg self) setTitle: (coerce-arg value)))
(define (tkbutton-hidden self)
  (tell #:type _bool (coerce-arg self) hidden))
(define (tkbutton-set-hidden! self value)
  (_msg-0 (coerce-arg self) (sel_registerName "setHidden:") value))
(define (tkbutton-tag self)
  (tell #:type _int64 (coerce-arg self) tag))
(define (tkbutton-set-tag! self value)
  (_msg-2 (coerce-arg self) (sel_registerName "setTag:") value))
(define (tkbutton-frame self)
  (wrap-objc-object
   (tell (coerce-arg self) frame)))

;; --- Instance methods ---
(define (tkbutton-dealloc self)
  (tell #:type _void (coerce-arg self) dealloc))
(define (tkbutton-description self)
  (wrap-objc-object
   (tell (coerce-arg self) description)))
(define (tkbutton-set-needs-display! self)
  (tell #:type _void (coerce-arg self) setNeedsDisplay))
(define (tkbutton-animate-with-duration-animations self duration animations)
  (define-values (_blk1 _blk1-id)
    (make-objc-block animations (list ) _void))
  (_msg-1 (coerce-arg self) (sel_registerName "animateWithDuration:animations:") duration _blk1))
