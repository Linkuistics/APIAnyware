#lang racket/base
;; Generated binding for NSError (Foundation)
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
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsdictionary? v) (objc-instance-of? v "NSDictionary"))
(define (nserror? v) (objc-instance-of? v "NSError"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(provide NSError)
(provide/contract
  [make-nserror-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nserror-init-with-domain-code-user-info (c-> (or/c string? objc-object? #f) exact-integer? (or/c string? objc-object? #f) any/c)]
  [nserror-code (c-> nserror? exact-integer?)]
  [nserror-domain (c-> nserror? (or/c nsstring? objc-nil?))]
  [nserror-help-anchor (c-> nserror? (or/c nsstring? objc-nil?))]
  [nserror-localized-description (c-> nserror? (or/c nsstring? objc-nil?))]
  [nserror-localized-failure-reason (c-> nserror? (or/c nsstring? objc-nil?))]
  [nserror-localized-recovery-options (c-> nserror? (or/c nsarray? objc-nil?))]
  [nserror-localized-recovery-suggestion (c-> nserror? (or/c nsstring? objc-nil?))]
  [nserror-recovery-attempter (c-> nserror? any/c)]
  [nserror-underlying-errors (c-> nserror? (or/c nsarray? objc-nil?))]
  [nserror-user-info (c-> nserror? (or/c nsdictionary? objc-nil?))]
  [nserror-copy-with-zone (c-> nserror? (or/c cpointer? #f) any/c)]
  [nserror-encode-with-coder (c-> nserror? (or/c string? objc-object? #f) void?)]
  [nserror-error-with-domain-code-user-info (c-> (or/c string? objc-object? #f) exact-integer? (or/c string? objc-object? #f) any/c)]
  [nserror-set-user-info-value-provider-for-domain-provider! (c-> (or/c string? objc-object? #f) (or/c procedure? #f) void?)]
  [nserror-supports-secure-coding (c-> boolean?)]
  [nserror-user-info-value-provider-for-domain (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f))]
  )

;; --- Class reference ---
(import-class NSError)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_q (-> ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PqP_P (-> ptr_t ptr_t ptr_t int64_t ptr_t ptr_t))

;; --- Constructors ---
(define (make-nserror-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSError alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nserror-init-with-domain-code-user-info domain code dict)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PqP_P (id->ffi2-ptr (tell NSError alloc)) (id->ffi2-ptr (sel_registerName "initWithDomain:code:userInfo:")) (id->ffi2-ptr (coerce-arg domain)) code (id->ffi2-ptr (coerce-arg dict))))
   #:retained #t))


;; --- Properties ---
(define (nserror-code self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "code"))))
(define (nserror-domain self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "domain"))))))
(define (nserror-help-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "helpAnchor"))))))
(define (nserror-localized-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "localizedDescription"))))))
(define (nserror-localized-failure-reason self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "localizedFailureReason"))))))
(define (nserror-localized-recovery-options self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "localizedRecoveryOptions"))))))
(define (nserror-localized-recovery-suggestion self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "localizedRecoverySuggestion"))))))
(define (nserror-recovery-attempter self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "recoveryAttempter"))))))
(define (nserror-underlying-errors self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "underlyingErrors"))))))
(define (nserror-user-info self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userInfo"))))))

;; --- Instance methods ---
(define (nserror-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "copyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))
(define (nserror-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))

;; --- Class methods ---
(define (nserror-error-with-domain-code-user-info domain code dict)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PqP_P (id->ffi2-ptr NSError) (id->ffi2-ptr (sel_registerName "errorWithDomain:code:userInfo:")) (id->ffi2-ptr (coerce-arg domain)) code (id->ffi2-ptr (coerce-arg dict))))
   ))
;; block param 1: stored (retained across calls)
(define (nserror-set-user-info-value-provider-for-domain-provider! error-domain provider)
  (define-values (_blk1 _blk1-id)
    (make-objc-block provider (list _id _id) _id))
  (aw_racket_msg_PP_v (id->ffi2-ptr NSError) (id->ffi2-ptr (sel_registerName "setUserInfoValueProviderForDomain:provider:")) (id->ffi2-ptr (coerce-arg error-domain)) (id->ffi2-ptr _blk1)))
(define (nserror-supports-secure-coding)
  (aw_racket_msg_0_b (id->ffi2-ptr NSError) (id->ffi2-ptr (sel_registerName "supportsSecureCoding"))))
(define (nserror-user-info-value-provider-for-domain err user-info-key error-domain)
  (ptr_t->cpointer (aw_racket_msg_PPP_P (id->ffi2-ptr NSError) (id->ffi2-ptr (sel_registerName "userInfoValueProviderForDomain:")) (id->ffi2-ptr (coerce-arg err)) (id->ffi2-ptr (coerce-arg user-info-key)) (id->ffi2-ptr (coerce-arg error-domain)))))
