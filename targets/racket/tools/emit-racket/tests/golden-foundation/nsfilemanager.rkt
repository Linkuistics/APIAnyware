#lang racket/base
;; Generated binding for NSFileManager (Foundation)
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
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsdictionary? v) (objc-instance-of? v "NSDictionary"))
(define (nsdirectoryenumerator? v) (objc-instance-of? v "NSDirectoryEnumerator"))
(define (nsfilemanager? v) (objc-instance-of? v "NSFileManager"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (nsurl? v) (objc-instance-of? v "NSURL"))
(provide NSFileManager)
(provide/contract
  [make-nsfilemanager (c-> any/c)]
  [nsfilemanager-current-directory-path (c-> nsfilemanager? (or/c nsstring? objc-nil?))]
  [nsfilemanager-default-manager (c-> (or/c nsfilemanager? objc-nil?))]
  [nsfilemanager-delegate (c-> nsfilemanager? any/c)]
  [nsfilemanager-set-delegate! (c-> nsfilemanager? (or/c string? objc-object? #f) void?)]
  [nsfilemanager-home-directory-for-current-user (c-> nsfilemanager? (or/c nsurl? objc-nil?))]
  [nsfilemanager-temporary-directory (c-> nsfilemanager? (or/c nsurl? objc-nil?))]
  [nsfilemanager-ubiquity-identity-token (c-> nsfilemanager? any/c)]
  [nsfilemanager-url-for-directory-in-domain-appropriate-for-url-create-error (c-> nsfilemanager? exact-nonnegative-integer? exact-nonnegative-integer? (or/c string? objc-object? #f) boolean? (values (or/c nsurl? objc-nil?) (or/c objc-object? #f)))]
  [nsfilemanager-url-for-publishing-ubiquitous-item-at-url-expiration-date-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c cpointer? #f) (values (or/c nsurl? objc-nil?) (or/c objc-object? #f)))]
  [nsfilemanager-url-for-ubiquity-container-identifier (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsfilemanager-ur-ls-for-directory-in-domains (c-> nsfilemanager? exact-nonnegative-integer? exact-nonnegative-integer? (or/c nsarray? objc-nil?))]
  [nsfilemanager-attributes-of-file-system-for-path-error (c-> nsfilemanager? (or/c string? objc-object? #f) (values (or/c nsdictionary? objc-nil?) (or/c objc-object? #f)))]
  [nsfilemanager-attributes-of-item-at-path-error (c-> nsfilemanager? (or/c string? objc-object? #f) (values (or/c nsdictionary? objc-nil?) (or/c objc-object? #f)))]
  [nsfilemanager-change-current-directory-path (c-> nsfilemanager? (or/c string? objc-object? #f) boolean?)]
  [nsfilemanager-components-to-display-for-path (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsfilemanager-container-url-for-security-application-group-identifier (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsfilemanager-contents-at-path (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c nsdata? objc-nil?))]
  [nsfilemanager-contents-equal-at-path-and-path (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nsfilemanager-contents-of-directory-at-path-error (c-> nsfilemanager? (or/c string? objc-object? #f) (values (or/c nsarray? objc-nil?) (or/c objc-object? #f)))]
  [nsfilemanager-contents-of-directory-at-url-including-properties-for-keys-options-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer? (values (or/c nsarray? objc-nil?) (or/c objc-object? #f)))]
  [nsfilemanager-copy-item-at-path-to-path-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-copy-item-at-url-to-url-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-create-directory-at-path-with-intermediate-directories-attributes-error (c-> nsfilemanager? (or/c string? objc-object? #f) boolean? (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-create-directory-at-url-with-intermediate-directories-attributes-error (c-> nsfilemanager? (or/c string? objc-object? #f) boolean? (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-create-file-at-path-contents-attributes (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nsfilemanager-create-symbolic-link-at-path-with-destination-path-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-create-symbolic-link-at-url-with-destination-url-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-destination-of-symbolic-link-at-path-error (c-> nsfilemanager? (or/c string? objc-object? #f) (values (or/c nsstring? objc-nil?) (or/c objc-object? #f)))]
  [nsfilemanager-display-name-at-path! (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsfilemanager-enumerator-at-path (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c nsdirectoryenumerator? objc-nil?))]
  [nsfilemanager-enumerator-at-url-including-properties-for-keys-options-error-handler (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c procedure? #f) (or/c nsdirectoryenumerator? objc-nil?))]
  [nsfilemanager-evict-ubiquitous-item-at-url-error (c-> nsfilemanager? (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-fetch-latest-remote-version-of-item-at-url-completion-handler (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c procedure? #f) void?)]
  [nsfilemanager-file-exists-at-path (c-> nsfilemanager? (or/c string? objc-object? #f) boolean?)]
  [nsfilemanager-file-exists-at-path-is-directory (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-file-system-representation-with-path (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? #f))]
  [nsfilemanager-get-file-provider-services-for-item-at-url-completion-handler (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c procedure? #f) void?)]
  [nsfilemanager-get-relationship-of-directory-in-domain-to-item-at-url-error (c-> nsfilemanager? (or/c cpointer? #f) exact-nonnegative-integer? exact-nonnegative-integer? (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-get-relationship-of-directory-at-url-to-item-at-url-error (c-> nsfilemanager? (or/c cpointer? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-home-directory-for-user (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsfilemanager-is-deletable-file-at-path (c-> nsfilemanager? (or/c string? objc-object? #f) boolean?)]
  [nsfilemanager-is-executable-file-at-path (c-> nsfilemanager? (or/c string? objc-object? #f) boolean?)]
  [nsfilemanager-is-readable-file-at-path (c-> nsfilemanager? (or/c string? objc-object? #f) boolean?)]
  [nsfilemanager-is-ubiquitous-item-at-url (c-> nsfilemanager? (or/c string? objc-object? #f) boolean?)]
  [nsfilemanager-is-writable-file-at-path (c-> nsfilemanager? (or/c string? objc-object? #f) boolean?)]
  [nsfilemanager-link-item-at-path-to-path-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-link-item-at-url-to-url-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-mounted-volume-ur-ls-including-resource-values-for-keys-options (c-> nsfilemanager? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c nsarray? objc-nil?))]
  [nsfilemanager-move-item-at-path-to-path-error! (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-move-item-at-url-to-url-error! (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-pause-sync-for-ubiquitous-item-at-url-completion-handler (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c procedure? #f) void?)]
  [nsfilemanager-remove-item-at-path-error! (c-> nsfilemanager? (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-remove-item-at-url-error! (c-> nsfilemanager? (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-replace-item-at-url-with-item-at-url-backup-item-name-options-resulting-item-url-error! (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c cpointer? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-resume-sync-for-ubiquitous-item-at-url-with-behavior-completion-handler (c-> nsfilemanager? (or/c string? objc-object? #f) exact-integer? (or/c procedure? #f) void?)]
  [nsfilemanager-set-attributes-of-item-at-path-error! (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-set-ubiquitous-item-at-url-destination-url-error! (c-> nsfilemanager? boolean? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-start-downloading-ubiquitous-item-at-url-error (c-> nsfilemanager? (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-string-with-file-system-representation-length (c-> nsfilemanager? string? exact-nonnegative-integer? (or/c nsstring? objc-nil?))]
  [nsfilemanager-subpaths-at-path (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsfilemanager-subpaths-of-directory-at-path-error (c-> nsfilemanager? (or/c string? objc-object? #f) (values (or/c nsarray? objc-nil?) (or/c objc-object? #f)))]
  [nsfilemanager-trash-item-at-url-resulting-item-url-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c cpointer? #f) (values boolean? (or/c objc-object? #f)))]
  [nsfilemanager-unmount-volume-at-url-options-completion-handler (c-> nsfilemanager? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c procedure? #f) void?)]
  [nsfilemanager-upload-local-version-of-ubiquitous-item-at-url-with-conflict-resolution-policy-completion-handler (c-> nsfilemanager? (or/c string? objc-object? #f) exact-integer? (or/c procedure? #f) void?)]
  )

;; --- Class reference ---
(import-class NSFileManager)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_P_e (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_N (-> ptr_t ptr_t ptr_t string_t))
(define-aw-msg aw_racket_msg_P_b (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_P_b_e (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_P_e (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_b (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PP_b_e (-> ptr_t ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPP_b (-> ptr_t ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PPP_b_e (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PPPQP_b_e (-> ptr_t ptr_t ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PPQ_P_e (-> ptr_t ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PPQP_P (-> ptr_t ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PbP_b_e (-> ptr_t ptr_t ptr_t bool_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PqP_v (-> ptr_t ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PQ_P (-> ptr_t ptr_t ptr_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_PQP_v (-> ptr_t ptr_t ptr_t uint64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PQQP_b_e (-> ptr_t ptr_t ptr_t uint64_t uint64_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_NQ_P (-> ptr_t ptr_t string_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_bPP_b_e (-> ptr_t ptr_t bool_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_QQ_P (-> ptr_t ptr_t uint64_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_QQPb_P_e (-> ptr_t ptr_t uint64_t uint64_t ptr_t bool_t ptr_t ptr_t))

;; --- Constructors ---
(define (make-nsfilemanager)
  (wrap-objc-object
   (tell (tell NSFileManager alloc) init)
   #:retained #t))


;; --- Properties ---
(define (nsfilemanager-current-directory-path self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "currentDirectoryPath"))))))
(define (nsfilemanager-default-manager)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSFileManager) (id->ffi2-ptr (sel_registerName "defaultManager"))))))
(define (nsfilemanager-delegate self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "delegate"))))))
(define (nsfilemanager-set-delegate! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDelegate:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsfilemanager-home-directory-for-current-user self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "homeDirectoryForCurrentUser"))))))
(define (nsfilemanager-temporary-directory self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "temporaryDirectory"))))))
(define (nsfilemanager-ubiquity-identity-token self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "ubiquityIdentityToken"))))))

;; --- Instance methods ---
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-url-for-directory-in-domain-appropriate-for-url-create-error self directory domain url should-create)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_QQPb_P_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "URLForDirectory:inDomain:appropriateForURL:create:error:")) directory domain (id->ffi2-ptr (coerce-arg url)) should-create (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-url-for-publishing-ubiquitous-item-at-url-expiration-date-error self url out-date)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_P_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "URLForPublishingUbiquitousItemAtURL:expirationDate:error:")) (id->ffi2-ptr (coerce-arg url)) (id->ffi2-ptr out-date) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsfilemanager-url-for-ubiquity-container-identifier self container-identifier)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "URLForUbiquityContainerIdentifier:")) (id->ffi2-ptr (coerce-arg container-identifier))))
   ))
(define (nsfilemanager-ur-ls-for-directory-in-domains self directory domain-mask)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_QQ_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "URLsForDirectory:inDomains:")) directory domain-mask))
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-attributes-of-file-system-for-path-error self path)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_P_P_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "attributesOfFileSystemForPath:error:")) (id->ffi2-ptr (coerce-arg path)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-attributes-of-item-at-path-error self path)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_P_P_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "attributesOfItemAtPath:error:")) (id->ffi2-ptr (coerce-arg path)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsfilemanager-change-current-directory-path self path)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeCurrentDirectoryPath:")) (id->ffi2-ptr (coerce-arg path))))
(define (nsfilemanager-components-to-display-for-path self path)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "componentsToDisplayForPath:")) (id->ffi2-ptr (coerce-arg path))))
   ))
(define (nsfilemanager-container-url-for-security-application-group-identifier self group-identifier)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "containerURLForSecurityApplicationGroupIdentifier:")) (id->ffi2-ptr (coerce-arg group-identifier))))
   ))
(define (nsfilemanager-contents-at-path self path)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentsAtPath:")) (id->ffi2-ptr (coerce-arg path))))
   ))
(define (nsfilemanager-contents-equal-at-path-and-path self path1 path2)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentsEqualAtPath:andPath:")) (id->ffi2-ptr (coerce-arg path1)) (id->ffi2-ptr (coerce-arg path2))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-contents-of-directory-at-path-error self path)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_P_P_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentsOfDirectoryAtPath:error:")) (id->ffi2-ptr (coerce-arg path)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-contents-of-directory-at-url-including-properties-for-keys-options-error self url keys mask)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PPQ_P_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentsOfDirectoryAtURL:includingPropertiesForKeys:options:error:")) (id->ffi2-ptr (coerce-arg url)) (id->ffi2-ptr (coerce-arg keys)) mask (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-copy-item-at-path-to-path-error self src-path dst-path)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "copyItemAtPath:toPath:error:")) (id->ffi2-ptr (coerce-arg src-path)) (id->ffi2-ptr (coerce-arg dst-path)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-copy-item-at-url-to-url-error self src-url dst-url)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "copyItemAtURL:toURL:error:")) (id->ffi2-ptr (coerce-arg src-url)) (id->ffi2-ptr (coerce-arg dst-url)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-create-directory-at-path-with-intermediate-directories-attributes-error self path create-intermediates attributes)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PbP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "createDirectoryAtPath:withIntermediateDirectories:attributes:error:")) (id->ffi2-ptr (coerce-arg path)) create-intermediates (id->ffi2-ptr (coerce-arg attributes)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-create-directory-at-url-with-intermediate-directories-attributes-error self url create-intermediates attributes)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PbP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "createDirectoryAtURL:withIntermediateDirectories:attributes:error:")) (id->ffi2-ptr (coerce-arg url)) create-intermediates (id->ffi2-ptr (coerce-arg attributes)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsfilemanager-create-file-at-path-contents-attributes self path data attr)
  (aw_racket_msg_PPP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "createFileAtPath:contents:attributes:")) (id->ffi2-ptr (coerce-arg path)) (id->ffi2-ptr (coerce-arg data)) (id->ffi2-ptr (coerce-arg attr))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-create-symbolic-link-at-path-with-destination-path-error self path dest-path)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "createSymbolicLinkAtPath:withDestinationPath:error:")) (id->ffi2-ptr (coerce-arg path)) (id->ffi2-ptr (coerce-arg dest-path)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-create-symbolic-link-at-url-with-destination-url-error self url dest-url)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "createSymbolicLinkAtURL:withDestinationURL:error:")) (id->ffi2-ptr (coerce-arg url)) (id->ffi2-ptr (coerce-arg dest-url)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-destination-of-symbolic-link-at-path-error self path)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_P_P_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "destinationOfSymbolicLinkAtPath:error:")) (id->ffi2-ptr (coerce-arg path)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsfilemanager-display-name-at-path! self path)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayNameAtPath:")) (id->ffi2-ptr (coerce-arg path))))
   ))
(define (nsfilemanager-enumerator-at-path self path)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enumeratorAtPath:")) (id->ffi2-ptr (coerce-arg path))))
   ))
;; block param 3: stored (retained across calls)
(define (nsfilemanager-enumerator-at-url-including-properties-for-keys-options-error-handler self url keys mask handler)
  (define-values (_blk3 _blk3-id)
    (make-objc-block handler (list _id _id) _bool))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPQP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enumeratorAtURL:includingPropertiesForKeys:options:errorHandler:")) (id->ffi2-ptr (coerce-arg url)) (id->ffi2-ptr (coerce-arg keys)) mask (id->ffi2-ptr _blk3)))
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-evict-ubiquitous-item-at-url-error self url)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_P_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "evictUbiquitousItemAtURL:error:")) (id->ffi2-ptr (coerce-arg url)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; block param 1: async-copied (runtime-managed)
(define (nsfilemanager-fetch-latest-remote-version-of-item-at-url-completion-handler self url completion-handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block completion-handler (list _id _id) _void))
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fetchLatestRemoteVersionOfItemAtURL:completionHandler:")) (id->ffi2-ptr (coerce-arg url)) (id->ffi2-ptr _blk1)))
(define (nsfilemanager-file-exists-at-path self path)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fileExistsAtPath:")) (id->ffi2-ptr (coerce-arg path))))
(define (nsfilemanager-file-exists-at-path-is-directory self path is-directory)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fileExistsAtPath:isDirectory:")) (id->ffi2-ptr (coerce-arg path)) (id->ffi2-ptr is-directory)))
(define (nsfilemanager-file-system-representation-with-path self path)
  (aw_racket_msg_P_N (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fileSystemRepresentationWithPath:")) (id->ffi2-ptr (coerce-arg path))))
;; block param 1: async-copied (runtime-managed)
(define (nsfilemanager-get-file-provider-services-for-item-at-url-completion-handler self url completion-handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block completion-handler (list _id _id) _void))
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getFileProviderServicesForItemAtURL:completionHandler:")) (id->ffi2-ptr (coerce-arg url)) (id->ffi2-ptr _blk1)))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-get-relationship-of-directory-in-domain-to-item-at-url-error self out-relationship directory domain-mask url)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PQQP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getRelationship:ofDirectory:inDomain:toItemAtURL:error:")) (id->ffi2-ptr out-relationship) directory domain-mask (id->ffi2-ptr (coerce-arg url)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-get-relationship-of-directory-at-url-to-item-at-url-error self out-relationship directory-url other-url)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PPP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getRelationship:ofDirectoryAtURL:toItemAtURL:error:")) (id->ffi2-ptr out-relationship) (id->ffi2-ptr (coerce-arg directory-url)) (id->ffi2-ptr (coerce-arg other-url)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsfilemanager-home-directory-for-user self user-name)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "homeDirectoryForUser:")) (id->ffi2-ptr (coerce-arg user-name))))
   ))
(define (nsfilemanager-is-deletable-file-at-path self path)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isDeletableFileAtPath:")) (id->ffi2-ptr (coerce-arg path))))
(define (nsfilemanager-is-executable-file-at-path self path)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isExecutableFileAtPath:")) (id->ffi2-ptr (coerce-arg path))))
(define (nsfilemanager-is-readable-file-at-path self path)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isReadableFileAtPath:")) (id->ffi2-ptr (coerce-arg path))))
(define (nsfilemanager-is-ubiquitous-item-at-url self url)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isUbiquitousItemAtURL:")) (id->ffi2-ptr (coerce-arg url))))
(define (nsfilemanager-is-writable-file-at-path self path)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isWritableFileAtPath:")) (id->ffi2-ptr (coerce-arg path))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-link-item-at-path-to-path-error self src-path dst-path)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "linkItemAtPath:toPath:error:")) (id->ffi2-ptr (coerce-arg src-path)) (id->ffi2-ptr (coerce-arg dst-path)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-link-item-at-url-to-url-error self src-url dst-url)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "linkItemAtURL:toURL:error:")) (id->ffi2-ptr (coerce-arg src-url)) (id->ffi2-ptr (coerce-arg dst-url)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsfilemanager-mounted-volume-ur-ls-including-resource-values-for-keys-options self property-keys options)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PQ_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mountedVolumeURLsIncludingResourceValuesForKeys:options:")) (id->ffi2-ptr (coerce-arg property-keys)) options))
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-move-item-at-path-to-path-error! self src-path dst-path)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveItemAtPath:toPath:error:")) (id->ffi2-ptr (coerce-arg src-path)) (id->ffi2-ptr (coerce-arg dst-path)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-move-item-at-url-to-url-error! self src-url dst-url)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveItemAtURL:toURL:error:")) (id->ffi2-ptr (coerce-arg src-url)) (id->ffi2-ptr (coerce-arg dst-url)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; block param 1: async-copied (runtime-managed)
(define (nsfilemanager-pause-sync-for-ubiquitous-item-at-url-completion-handler self url completion-handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block completion-handler (list _id) _void))
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pauseSyncForUbiquitousItemAtURL:completionHandler:")) (id->ffi2-ptr (coerce-arg url)) (id->ffi2-ptr _blk1)))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-remove-item-at-path-error! self path)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_P_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeItemAtPath:error:")) (id->ffi2-ptr (coerce-arg path)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-remove-item-at-url-error! self url)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_P_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeItemAtURL:error:")) (id->ffi2-ptr (coerce-arg url)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-replace-item-at-url-with-item-at-url-backup-item-name-options-resulting-item-url-error! self original-item-url new-item-url backup-item-name options resulting-url)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PPPQP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "replaceItemAtURL:withItemAtURL:backupItemName:options:resultingItemURL:error:")) (id->ffi2-ptr (coerce-arg original-item-url)) (id->ffi2-ptr (coerce-arg new-item-url)) (id->ffi2-ptr (coerce-arg backup-item-name)) options (id->ffi2-ptr resulting-url) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; block param 2: async-copied (runtime-managed)
(define (nsfilemanager-resume-sync-for-ubiquitous-item-at-url-with-behavior-completion-handler self url behavior completion-handler)
  (define-values (_blk2 _blk2-id)
    (make-objc-block completion-handler (list _id) _void))
  (aw_racket_msg_PqP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resumeSyncForUbiquitousItemAtURL:withBehavior:completionHandler:")) (id->ffi2-ptr (coerce-arg url)) behavior (id->ffi2-ptr _blk2)))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-set-attributes-of-item-at-path-error! self attributes path)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAttributes:ofItemAtPath:error:")) (id->ffi2-ptr (coerce-arg attributes)) (id->ffi2-ptr (coerce-arg path)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-set-ubiquitous-item-at-url-destination-url-error! self flag url destination-url)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_bPP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUbiquitous:itemAtURL:destinationURL:error:")) flag (id->ffi2-ptr (coerce-arg url)) (id->ffi2-ptr (coerce-arg destination-url)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-start-downloading-ubiquitous-item-at-url-error self url)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_P_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "startDownloadingUbiquitousItemAtURL:error:")) (id->ffi2-ptr (coerce-arg url)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsfilemanager-string-with-file-system-representation-length self str len)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_NQ_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringWithFileSystemRepresentation:length:")) str len))
   ))
(define (nsfilemanager-subpaths-at-path self path)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "subpathsAtPath:")) (id->ffi2-ptr (coerce-arg path))))
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-subpaths-of-directory-at-path-error self path)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_P_P_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "subpathsOfDirectoryAtPath:error:")) (id->ffi2-ptr (coerce-arg path)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-trash-item-at-url-resulting-item-url-error self url out-resulting-url)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "trashItemAtURL:resultingItemURL:error:")) (id->ffi2-ptr (coerce-arg url)) (id->ffi2-ptr out-resulting-url) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; block param 2: async-copied (runtime-managed)
(define (nsfilemanager-unmount-volume-at-url-options-completion-handler self url mask completion-handler)
  (define-values (_blk2 _blk2-id)
    (make-objc-block completion-handler (list _id) _void))
  (aw_racket_msg_PQP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "unmountVolumeAtURL:options:completionHandler:")) (id->ffi2-ptr (coerce-arg url)) mask (id->ffi2-ptr _blk2)))
;; block param 2: async-copied (runtime-managed)
(define (nsfilemanager-upload-local-version-of-ubiquitous-item-at-url-with-conflict-resolution-policy-completion-handler self url conflict-resolution-policy completion-handler)
  (define-values (_blk2 _blk2-id)
    (make-objc-block completion-handler (list _id _id) _void))
  (aw_racket_msg_PqP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "uploadLocalVersionOfUbiquitousItemAtURL:withConflictResolutionPolicy:completionHandler:")) (id->ffi2-ptr (coerce-arg url)) conflict-resolution-policy (id->ffi2-ptr _blk2)))
