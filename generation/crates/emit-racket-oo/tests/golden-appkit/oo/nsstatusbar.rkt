#lang racket/base
;; Generated binding for NSStatusBar (AppKit)
;; Do not edit — regenerate from enriched IR

(require ffi/unsafe
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../../runtime/objc-base.rkt"
         "../../../runtime/coerce.rkt")

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

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _bool)))
(define _msg-1  ; (_fun _pointer _pointer -> _double)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _double)))
(define _msg-2  ; (_fun _pointer _pointer _double -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double -> _id)))

;; --- Constructors ---
(define (make-nsstatusbar)
  (wrap-objc-object
   (tell (tell NSStatusBar alloc) init)
   #:retained #t))


;; --- Properties ---
(define (nsstatusbar-system-status-bar)
  (wrap-objc-object
   (tell NSStatusBar systemStatusBar)))
(define (nsstatusbar-thickness self)
  (tell #:type _double (coerce-arg self) thickness))
(define (nsstatusbar-vertical self)
  (tell #:type _bool (coerce-arg self) vertical))

;; --- Instance methods ---
(define (nsstatusbar-is-vertical self)
  (_msg-0 (coerce-arg self) (sel_registerName "isVertical")))
(define (nsstatusbar-remove-status-item! self item)
  (tell #:type _void (coerce-arg self) removeStatusItem: (coerce-arg item)))
(define (nsstatusbar-status-item-with-length self length)
  (wrap-objc-object
   (_msg-2 (coerce-arg self) (sel_registerName "statusItemWithLength:") length)
   ))
