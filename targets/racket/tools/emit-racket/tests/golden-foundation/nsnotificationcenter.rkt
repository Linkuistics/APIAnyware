#lang racket/base
;; Generated binding for NSNotificationCenter (Foundation)
;; Do not edit — regenerate from enriched IR

(require "../../runtime/ffi2-dispatch.rkt"
         (except-in ffi/unsafe ->)
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../runtime/objc-base.rkt"
         "../../runtime/coerce.rkt"
         "../../runtime/block.rkt")

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

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPP_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PPPP_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t void_t))

;; --- Constructors ---
(define (make-nsnotificationcenter)
  (wrap-objc-object
   (tell (tell NSNotificationCenter alloc) init)
   #:retained #t))


;; --- Properties ---
(define (nsnotificationcenter-default-center)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSNotificationCenter) (id->ffi2-ptr (sel_registerName "defaultCenter"))))))

;; --- Instance methods ---
;; param 0: weak reference
(define (nsnotificationcenter-add-observer-selector-name-object! self observer a-selector a-name an-object)
  (aw_racket_msg_PPPP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addObserver:selector:name:object:")) (id->ffi2-ptr (coerce-arg observer)) (id->ffi2-ptr (sel_registerName a-selector)) (id->ffi2-ptr (coerce-arg a-name)) (id->ffi2-ptr (coerce-arg an-object))))
;; block param 3: stored (retained across calls)
(define (nsnotificationcenter-add-observer-for-name-object-queue-using-block! self name obj queue block)
  (define-values (_blk3 _blk3-id)
    (make-objc-block block (list _id) _void))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPPP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addObserverForName:object:queue:usingBlock:")) (id->ffi2-ptr (coerce-arg name)) (id->ffi2-ptr (coerce-arg obj)) (id->ffi2-ptr (coerce-arg queue)) (id->ffi2-ptr _blk3)))
   ))
(define (nsnotificationcenter-post-notification self notification)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "postNotification:")) (id->ffi2-ptr (coerce-arg notification))))
(define (nsnotificationcenter-post-notification-name-object self a-name an-object)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "postNotificationName:object:")) (id->ffi2-ptr (coerce-arg a-name)) (id->ffi2-ptr (coerce-arg an-object))))
(define (nsnotificationcenter-post-notification-name-object-user-info self a-name an-object a-user-info)
  (aw_racket_msg_PPP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "postNotificationName:object:userInfo:")) (id->ffi2-ptr (coerce-arg a-name)) (id->ffi2-ptr (coerce-arg an-object)) (id->ffi2-ptr (coerce-arg a-user-info))))
(define (nsnotificationcenter-remove-observer! self observer)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeObserver:")) (id->ffi2-ptr (coerce-arg observer))))
(define (nsnotificationcenter-remove-observer-name-object! self observer a-name an-object)
  (aw_racket_msg_PPP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeObserver:name:object:")) (id->ffi2-ptr (coerce-arg observer)) (id->ffi2-ptr (coerce-arg a-name)) (id->ffi2-ptr (coerce-arg an-object))))
