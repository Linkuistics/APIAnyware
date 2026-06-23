#lang racket/base
;; Generated binding for NSUserDefaults (Foundation)
;; Do not edit — regenerate from enriched IR

(require "../../runtime/ffi2-dispatch.rkt"
         (except-in ffi/unsafe ->)
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../runtime/objc-base.rkt"
         "../../runtime/coerce.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/Foundation.framework/Foundation"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (nsurl? v) (objc-instance-of? v "NSURL"))
(define (nsuserdefaults? v) (objc-instance-of? v "NSUserDefaults"))
(provide NSUserDefaults)
(provide/contract
  [make-nsuserdefaults-init-with-suite-name (c-> (or/c string? objc-object? #f) any/c)]
  [nsuserdefaults-standard-user-defaults (c-> (or/c nsuserdefaults? objc-nil?))]
  [nsuserdefaults-volatile-domain-names (c-> nsuserdefaults? any/c)]
  [nsuserdefaults-url-for-key (c-> nsuserdefaults? (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsuserdefaults-add-suite-named! (c-> nsuserdefaults? (or/c string? objc-object? #f) void?)]
  [nsuserdefaults-array-for-key (c-> nsuserdefaults? (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsuserdefaults-bool-for-key (c-> nsuserdefaults? (or/c string? objc-object? #f) boolean?)]
  [nsuserdefaults-data-for-key (c-> nsuserdefaults? (or/c string? objc-object? #f) (or/c nsdata? objc-nil?))]
  [nsuserdefaults-dictionary-for-key (c-> nsuserdefaults? (or/c string? objc-object? #f) any/c)]
  [nsuserdefaults-dictionary-representation (c-> nsuserdefaults? any/c)]
  [nsuserdefaults-double-for-key (c-> nsuserdefaults? (or/c string? objc-object? #f) real?)]
  [nsuserdefaults-float-for-key (c-> nsuserdefaults? (or/c string? objc-object? #f) real?)]
  [nsuserdefaults-integer-for-key (c-> nsuserdefaults? (or/c string? objc-object? #f) exact-integer?)]
  [nsuserdefaults-object-for-key (c-> nsuserdefaults? (or/c string? objc-object? #f) any/c)]
  [nsuserdefaults-object-is-forced-for-key (c-> nsuserdefaults? (or/c string? objc-object? #f) boolean?)]
  [nsuserdefaults-object-is-forced-for-key-in-domain (c-> nsuserdefaults? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nsuserdefaults-persistent-domain-for-name (c-> nsuserdefaults? (or/c string? objc-object? #f) any/c)]
  [nsuserdefaults-register-defaults (c-> nsuserdefaults? (or/c string? objc-object? #f) void?)]
  [nsuserdefaults-remove-object-for-key! (c-> nsuserdefaults? (or/c string? objc-object? #f) void?)]
  [nsuserdefaults-remove-persistent-domain-for-name! (c-> nsuserdefaults? (or/c string? objc-object? #f) void?)]
  [nsuserdefaults-remove-suite-named! (c-> nsuserdefaults? (or/c string? objc-object? #f) void?)]
  [nsuserdefaults-remove-volatile-domain-for-name! (c-> nsuserdefaults? (or/c string? objc-object? #f) void?)]
  [nsuserdefaults-set-bool-for-key! (c-> nsuserdefaults? boolean? (or/c string? objc-object? #f) void?)]
  [nsuserdefaults-set-double-for-key! (c-> nsuserdefaults? real? (or/c string? objc-object? #f) void?)]
  [nsuserdefaults-set-float-for-key! (c-> nsuserdefaults? real? (or/c string? objc-object? #f) void?)]
  [nsuserdefaults-set-integer-for-key! (c-> nsuserdefaults? exact-integer? (or/c string? objc-object? #f) void?)]
  [nsuserdefaults-set-object-for-key! (c-> nsuserdefaults? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsuserdefaults-set-persistent-domain-for-name! (c-> nsuserdefaults? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsuserdefaults-set-url-for-key! (c-> nsuserdefaults? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsuserdefaults-set-volatile-domain-for-name! (c-> nsuserdefaults? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsuserdefaults-string-array-for-key (c-> nsuserdefaults? (or/c string? objc-object? #f) any/c)]
  [nsuserdefaults-string-for-key (c-> nsuserdefaults? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsuserdefaults-synchronize (c-> nsuserdefaults? boolean?)]
  [nsuserdefaults-volatile-domain-for-name (c-> nsuserdefaults? (or/c string? objc-object? #f) any/c)]
  [nsuserdefaults-reset-standard-user-defaults! (c-> void?)]
  )

;; --- Class reference ---
(import-class NSUserDefaults)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_v (-> ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_b (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_P_q (-> ptr_t ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_P_f (-> ptr_t ptr_t ptr_t float_t))
(define-aw-msg aw_racket_msg_P_d (-> ptr_t ptr_t ptr_t double_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_b (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_bP_v (-> ptr_t ptr_t bool_t ptr_t void_t))
(define-aw-msg aw_racket_msg_qP_v (-> ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_fP_v (-> ptr_t ptr_t float_t ptr_t void_t))
(define-aw-msg aw_racket_msg_dP_v (-> ptr_t ptr_t double_t ptr_t void_t))

;; --- Constructors ---
(define (make-nsuserdefaults-init-with-suite-name suitename)
  (wrap-objc-object
   (tell (tell NSUserDefaults alloc)
         initWithSuiteName: (coerce-arg suitename))
   #:retained #t))


;; --- Properties ---
(define (nsuserdefaults-standard-user-defaults)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSUserDefaults) (id->ffi2-ptr (sel_registerName "standardUserDefaults"))))))
(define (nsuserdefaults-volatile-domain-names self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "volatileDomainNames"))))))

;; --- Instance methods ---
(define (nsuserdefaults-url-for-key self default-name)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "URLForKey:")) (id->ffi2-ptr (coerce-arg default-name))))
   ))
(define (nsuserdefaults-add-suite-named! self suite-name)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addSuiteNamed:")) (id->ffi2-ptr (coerce-arg suite-name))))
(define (nsuserdefaults-array-for-key self default-name)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "arrayForKey:")) (id->ffi2-ptr (coerce-arg default-name))))
   ))
(define (nsuserdefaults-bool-for-key self default-name)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "boolForKey:")) (id->ffi2-ptr (coerce-arg default-name))))
(define (nsuserdefaults-data-for-key self default-name)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dataForKey:")) (id->ffi2-ptr (coerce-arg default-name))))
   ))
(define (nsuserdefaults-dictionary-for-key self default-name)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dictionaryForKey:")) (id->ffi2-ptr (coerce-arg default-name))))
   ))
(define (nsuserdefaults-dictionary-representation self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dictionaryRepresentation"))))
   ))
(define (nsuserdefaults-double-for-key self default-name)
  (aw_racket_msg_P_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "doubleForKey:")) (id->ffi2-ptr (coerce-arg default-name))))
(define (nsuserdefaults-float-for-key self default-name)
  (aw_racket_msg_P_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "floatForKey:")) (id->ffi2-ptr (coerce-arg default-name))))
(define (nsuserdefaults-integer-for-key self default-name)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "integerForKey:")) (id->ffi2-ptr (coerce-arg default-name))))
(define (nsuserdefaults-object-for-key self default-name)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "objectForKey:")) (id->ffi2-ptr (coerce-arg default-name))))
   ))
(define (nsuserdefaults-object-is-forced-for-key self key)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "objectIsForcedForKey:")) (id->ffi2-ptr (coerce-arg key))))
(define (nsuserdefaults-object-is-forced-for-key-in-domain self key domain)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "objectIsForcedForKey:inDomain:")) (id->ffi2-ptr (coerce-arg key)) (id->ffi2-ptr (coerce-arg domain))))
(define (nsuserdefaults-persistent-domain-for-name self domain-name)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "persistentDomainForName:")) (id->ffi2-ptr (coerce-arg domain-name))))
   ))
(define (nsuserdefaults-register-defaults self registration-dictionary)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "registerDefaults:")) (id->ffi2-ptr (coerce-arg registration-dictionary))))
(define (nsuserdefaults-remove-object-for-key! self default-name)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeObjectForKey:")) (id->ffi2-ptr (coerce-arg default-name))))
(define (nsuserdefaults-remove-persistent-domain-for-name! self domain-name)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removePersistentDomainForName:")) (id->ffi2-ptr (coerce-arg domain-name))))
(define (nsuserdefaults-remove-suite-named! self suite-name)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeSuiteNamed:")) (id->ffi2-ptr (coerce-arg suite-name))))
(define (nsuserdefaults-remove-volatile-domain-for-name! self domain-name)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeVolatileDomainForName:")) (id->ffi2-ptr (coerce-arg domain-name))))
(define (nsuserdefaults-set-bool-for-key! self value default-name)
  (aw_racket_msg_bP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBool:forKey:")) value (id->ffi2-ptr (coerce-arg default-name))))
(define (nsuserdefaults-set-double-for-key! self value default-name)
  (aw_racket_msg_dP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDouble:forKey:")) value (id->ffi2-ptr (coerce-arg default-name))))
(define (nsuserdefaults-set-float-for-key! self value default-name)
  (aw_racket_msg_fP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFloat:forKey:")) value (id->ffi2-ptr (coerce-arg default-name))))
(define (nsuserdefaults-set-integer-for-key! self value default-name)
  (aw_racket_msg_qP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setInteger:forKey:")) value (id->ffi2-ptr (coerce-arg default-name))))
(define (nsuserdefaults-set-object-for-key! self value default-name)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setObject:forKey:")) (id->ffi2-ptr (coerce-arg value)) (id->ffi2-ptr (coerce-arg default-name))))
(define (nsuserdefaults-set-persistent-domain-for-name! self domain domain-name)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPersistentDomain:forName:")) (id->ffi2-ptr (coerce-arg domain)) (id->ffi2-ptr (coerce-arg domain-name))))
(define (nsuserdefaults-set-url-for-key! self url default-name)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setURL:forKey:")) (id->ffi2-ptr (coerce-arg url)) (id->ffi2-ptr (coerce-arg default-name))))
(define (nsuserdefaults-set-volatile-domain-for-name! self domain domain-name)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setVolatileDomain:forName:")) (id->ffi2-ptr (coerce-arg domain)) (id->ffi2-ptr (coerce-arg domain-name))))
(define (nsuserdefaults-string-array-for-key self default-name)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringArrayForKey:")) (id->ffi2-ptr (coerce-arg default-name))))
   ))
(define (nsuserdefaults-string-for-key self default-name)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringForKey:")) (id->ffi2-ptr (coerce-arg default-name))))
   ))
(define (nsuserdefaults-synchronize self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "synchronize"))))
(define (nsuserdefaults-volatile-domain-for-name self domain-name)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "volatileDomainForName:")) (id->ffi2-ptr (coerce-arg domain-name))))
   ))

;; --- Class methods ---
(define (nsuserdefaults-reset-standard-user-defaults!)
  (aw_racket_msg_0_v (id->ffi2-ptr NSUserDefaults) (id->ffi2-ptr (sel_registerName "resetStandardUserDefaults"))))
