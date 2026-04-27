#lang racket/base
;; Generated binding for NSError (Foundation)
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
(define (nsstring? v) (objc-instance-of? v "NSString"))
(provide NSError)
(provide/contract
  [make-nserror-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nserror-init-with-domain-code-user-info (c-> (or/c string? objc-object? #f) exact-integer? (or/c string? objc-object? #f) any/c)]
  [nserror-code (c-> objc-object? exact-integer?)]
  [nserror-domain (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nserror-help-anchor (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nserror-localized-description (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nserror-localized-failure-reason (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nserror-localized-recovery-options (c-> objc-object? any/c)]
  [nserror-localized-recovery-suggestion (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nserror-recovery-attempter (c-> objc-object? any/c)]
  [nserror-underlying-errors (c-> objc-object? any/c)]
  [nserror-user-info (c-> objc-object? any/c)]
  [nserror-copy-with-zone (c-> objc-object? (or/c cpointer? #f) any/c)]
  [nserror-encode-with-coder (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nserror-error-with-domain-code-user-info (c-> (or/c string? objc-object? #f) exact-integer? (or/c string? objc-object? #f) any/c)]
  [nserror-set-user-info-value-provider-for-domain-provider! (c-> (or/c string? objc-object? #f) (or/c procedure? #f) void?)]
  [nserror-supports-secure-coding (c-> boolean?)]
  [nserror-user-info-value-provider-for-domain (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f))]
  )

;; --- Class reference ---
(import-class NSError)

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _bool)))
(define _msg-1  ; (_fun _pointer _pointer -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _int64)))
(define _msg-2  ; (_fun _pointer _pointer _id _id _id -> _pointer)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _id -> _pointer)))
(define _msg-3  ; (_fun _pointer _pointer _id _int64 _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _int64 _id -> _id)))
(define _msg-4  ; (_fun _pointer _pointer _id _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer -> _void)))
(define _msg-5  ; (_fun _pointer _pointer _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _id)))

;; --- Constructors ---
(define (make-nserror-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSError alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nserror-init-with-domain-code-user-info domain code dict)
  (wrap-objc-object
   (_msg-3 (tell NSError alloc)
       (sel_registerName "initWithDomain:code:userInfo:")
       (coerce-arg domain)
       code
       (coerce-arg dict))
   #:retained #t))


;; --- Properties ---
(define (nserror-code self)
  (tell #:type _int64 (coerce-arg self) code))
(define (nserror-domain self)
  (wrap-objc-object
   (tell (coerce-arg self) domain)))
(define (nserror-help-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) helpAnchor)))
(define (nserror-localized-description self)
  (wrap-objc-object
   (tell (coerce-arg self) localizedDescription)))
(define (nserror-localized-failure-reason self)
  (wrap-objc-object
   (tell (coerce-arg self) localizedFailureReason)))
(define (nserror-localized-recovery-options self)
  (wrap-objc-object
   (tell (coerce-arg self) localizedRecoveryOptions)))
(define (nserror-localized-recovery-suggestion self)
  (wrap-objc-object
   (tell (coerce-arg self) localizedRecoverySuggestion)))
(define (nserror-recovery-attempter self)
  (wrap-objc-object
   (tell (coerce-arg self) recoveryAttempter)))
(define (nserror-underlying-errors self)
  (wrap-objc-object
   (tell (coerce-arg self) underlyingErrors)))
(define (nserror-user-info self)
  (wrap-objc-object
   (tell (coerce-arg self) userInfo)))

;; --- Instance methods ---
(define (nserror-copy-with-zone self zone)
  (wrap-objc-object
   (_msg-5 (coerce-arg self) (sel_registerName "copyWithZone:") zone)
   #:retained #t))
(define (nserror-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))

;; --- Class methods ---
(define (nserror-error-with-domain-code-user-info domain code dict)
  (wrap-objc-object
   (_msg-3 NSError (sel_registerName "errorWithDomain:code:userInfo:") (coerce-arg domain) code (coerce-arg dict))
   ))
(define (nserror-set-user-info-value-provider-for-domain-provider! error-domain provider)
  (define-values (_blk1 _blk1-id)
    (make-objc-block provider (list _id _id) _id))
  (_msg-4 NSError (sel_registerName "setUserInfoValueProviderForDomain:provider:") (coerce-arg error-domain) _blk1))
(define (nserror-supports-secure-coding)
  (_msg-0 NSError (sel_registerName "supportsSecureCoding")))
(define (nserror-user-info-value-provider-for-domain err user-info-key error-domain)
  (_msg-2 NSError (sel_registerName "userInfoValueProviderForDomain:") (coerce-arg err) (coerce-arg user-info-key) (coerce-arg error-domain)))
