#lang racket/base
;; Generated binding for NSNotificationCenter (Foundation)
;; Do not edit — regenerate from enriched IR

(require ffi/unsafe
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../../runtime/objc-base.rkt"
         "../../../runtime/coerce.rkt"
         "../../../runtime/block.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/Foundation.framework/Foundation"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
(define (nsnotificationcenter? v) (objc-instance-of? v "NSNotificationCenter"))
(provide NSNotificationCenter)
(provide/contract
  [make-nsnotificationcenter (c-> any/c)]
  [nsnotificationcenter-default-center (c-> (or/c nsnotificationcenter? objc-nil?))]
  [nsnotificationcenter-add-observer-selector-name-object! (c-> nsnotificationcenter? (or/c string? objc-object? #f) string? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsnotificationcenter-add-observer-for-name-object-queue-using-block! (c-> nsnotificationcenter? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c procedure? #f) any/c)]
  [nsnotificationcenter-post-notification (c-> nsnotificationcenter? (or/c string? objc-object? #f) void?)]
  [nsnotificationcenter-post-notification-name-object (c-> nsnotificationcenter? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsnotificationcenter-post-notification-name-object-user-info (c-> nsnotificationcenter? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsnotificationcenter-remove-observer! (c-> nsnotificationcenter? (or/c string? objc-object? #f) void?)]
  [nsnotificationcenter-remove-observer-name-object! (c-> nsnotificationcenter? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  )

;; --- Class reference ---
(import-class NSNotificationCenter)

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer _id _id _id _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _id _pointer -> _id)))
(define _msg-1  ; (_fun _pointer _pointer _id _pointer _id _id -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer _id _id -> _void)))

;; --- Constructors ---
(define (make-nsnotificationcenter)
  (wrap-objc-object
   (tell (tell NSNotificationCenter alloc) init)
   #:retained #t))


;; --- Properties ---
(define (nsnotificationcenter-default-center)
  (wrap-objc-object
   (tell NSNotificationCenter defaultCenter)))

;; --- Instance methods ---
;; param 0: weak reference
(define (nsnotificationcenter-add-observer-selector-name-object! self observer a-selector a-name an-object)
  (_msg-1 (coerce-arg self) (sel_registerName "addObserver:selector:name:object:") (coerce-arg observer) (sel_registerName a-selector) (coerce-arg a-name) (coerce-arg an-object)))
;; block param 3: stored (retained across calls)
(define (nsnotificationcenter-add-observer-for-name-object-queue-using-block! self name obj queue block)
  (define-values (_blk3 _blk3-id)
    (make-objc-block block (list _id) _void))
  (wrap-objc-object
   (_msg-0 (coerce-arg self) (sel_registerName "addObserverForName:object:queue:usingBlock:") (coerce-arg name) (coerce-arg obj) (coerce-arg queue) _blk3)
   ))
(define (nsnotificationcenter-post-notification self notification)
  (tell #:type _void (coerce-arg self) postNotification: (coerce-arg notification)))
(define (nsnotificationcenter-post-notification-name-object self a-name an-object)
  (tell #:type _void (coerce-arg self) postNotificationName: (coerce-arg a-name) object: (coerce-arg an-object)))
(define (nsnotificationcenter-post-notification-name-object-user-info self a-name an-object a-user-info)
  (tell #:type _void (coerce-arg self) postNotificationName: (coerce-arg a-name) object: (coerce-arg an-object) userInfo: (coerce-arg a-user-info)))
(define (nsnotificationcenter-remove-observer! self observer)
  (tell #:type _void (coerce-arg self) removeObserver: (coerce-arg observer)))
(define (nsnotificationcenter-remove-observer-name-object! self observer a-name an-object)
  (tell #:type _void (coerce-arg self) removeObserver: (coerce-arg observer) name: (coerce-arg a-name) object: (coerce-arg an-object)))
