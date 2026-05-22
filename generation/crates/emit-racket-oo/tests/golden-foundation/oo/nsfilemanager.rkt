#lang racket/base
;; Generated binding for NSFileManager (Foundation)
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
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsdictionary? v) (objc-instance-of? v "NSDictionary"))
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
  [nsfilemanager-url-for-directory-in-domain-appropriate-for-url-create-error (c-> nsfilemanager? exact-nonnegative-integer? exact-nonnegative-integer? (or/c string? objc-object? #f) boolean? (or/c cpointer? #f) (or/c nsurl? objc-nil?))]
  [nsfilemanager-url-for-publishing-ubiquitous-item-at-url-expiration-date-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c cpointer? #f) (or/c cpointer? #f) (or/c nsurl? objc-nil?))]
  [nsfilemanager-url-for-ubiquity-container-identifier (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsfilemanager-ur-ls-for-directory-in-domains (c-> nsfilemanager? exact-nonnegative-integer? exact-nonnegative-integer? any/c)]
  [nsfilemanager-attributes-of-file-system-for-path-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c cpointer? #f) any/c)]
  [nsfilemanager-attributes-of-item-at-path-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c cpointer? #f) any/c)]
  [nsfilemanager-change-current-directory-path (c-> nsfilemanager? (or/c string? objc-object? #f) boolean?)]
  [nsfilemanager-components-to-display-for-path (c-> nsfilemanager? (or/c string? objc-object? #f) any/c)]
  [nsfilemanager-container-url-for-security-application-group-identifier (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsfilemanager-contents-at-path (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c nsdata? objc-nil?))]
  [nsfilemanager-contents-equal-at-path-and-path (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nsfilemanager-contents-of-directory-at-path-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c cpointer? #f) any/c)]
  [nsfilemanager-contents-of-directory-at-url-including-properties-for-keys-options-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c cpointer? #f) any/c)]
  [nsfilemanager-copy-item-at-path-to-path-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-copy-item-at-url-to-url-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-create-directory-at-path-with-intermediate-directories-attributes-error (c-> nsfilemanager? (or/c string? objc-object? #f) boolean? (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-create-directory-at-url-with-intermediate-directories-attributes-error (c-> nsfilemanager? (or/c string? objc-object? #f) boolean? (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-create-file-at-path-contents-attributes (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nsfilemanager-create-symbolic-link-at-path-with-destination-path-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-create-symbolic-link-at-url-with-destination-url-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-destination-of-symbolic-link-at-path-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c cpointer? #f) (or/c nsstring? objc-nil?))]
  [nsfilemanager-display-name-at-path! (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nsfilemanager-enumerator-at-path (c-> nsfilemanager? (or/c string? objc-object? #f) any/c)]
  [nsfilemanager-enumerator-at-url-including-properties-for-keys-options-error-handler (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c procedure? #f) any/c)]
  [nsfilemanager-evict-ubiquitous-item-at-url-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-fetch-latest-remote-version-of-item-at-url-completion-handler (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c procedure? #f) void?)]
  [nsfilemanager-file-exists-at-path (c-> nsfilemanager? (or/c string? objc-object? #f) boolean?)]
  [nsfilemanager-file-exists-at-path-is-directory (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-file-system-representation-with-path (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? #f))]
  [nsfilemanager-get-file-provider-services-for-item-at-url-completion-handler (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c procedure? #f) void?)]
  [nsfilemanager-get-relationship-of-directory-in-domain-to-item-at-url-error (c-> nsfilemanager? (or/c cpointer? #f) exact-nonnegative-integer? exact-nonnegative-integer? (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-get-relationship-of-directory-at-url-to-item-at-url-error (c-> nsfilemanager? (or/c cpointer? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-is-deletable-file-at-path (c-> nsfilemanager? (or/c string? objc-object? #f) boolean?)]
  [nsfilemanager-is-executable-file-at-path (c-> nsfilemanager? (or/c string? objc-object? #f) boolean?)]
  [nsfilemanager-is-readable-file-at-path (c-> nsfilemanager? (or/c string? objc-object? #f) boolean?)]
  [nsfilemanager-is-ubiquitous-item-at-url (c-> nsfilemanager? (or/c string? objc-object? #f) boolean?)]
  [nsfilemanager-is-writable-file-at-path (c-> nsfilemanager? (or/c string? objc-object? #f) boolean?)]
  [nsfilemanager-link-item-at-path-to-path-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-link-item-at-url-to-url-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-mounted-volume-ur-ls-including-resource-values-for-keys-options (c-> nsfilemanager? (or/c string? objc-object? #f) exact-nonnegative-integer? any/c)]
  [nsfilemanager-move-item-at-path-to-path-error! (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-move-item-at-url-to-url-error! (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-pause-sync-for-ubiquitous-item-at-url-completion-handler (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c procedure? #f) void?)]
  [nsfilemanager-remove-item-at-path-error! (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-remove-item-at-url-error! (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-replace-item-at-url-with-item-at-url-backup-item-name-options-resulting-item-url-error! (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c cpointer? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-resume-sync-for-ubiquitous-item-at-url-with-behavior-completion-handler (c-> nsfilemanager? (or/c string? objc-object? #f) exact-integer? (or/c procedure? #f) void?)]
  [nsfilemanager-set-attributes-of-item-at-path-error! (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-set-ubiquitous-item-at-url-destination-url-error! (c-> nsfilemanager? boolean? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-start-downloading-ubiquitous-item-at-url-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-string-with-file-system-representation-length (c-> nsfilemanager? string? exact-nonnegative-integer? (or/c nsstring? objc-nil?))]
  [nsfilemanager-subpaths-at-path (c-> nsfilemanager? (or/c string? objc-object? #f) any/c)]
  [nsfilemanager-subpaths-of-directory-at-path-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c cpointer? #f) any/c)]
  [nsfilemanager-trash-item-at-url-resulting-item-url-error (c-> nsfilemanager? (or/c string? objc-object? #f) (or/c cpointer? #f) (or/c cpointer? #f) boolean?)]
  [nsfilemanager-unmount-volume-at-url-options-completion-handler (c-> nsfilemanager? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c procedure? #f) void?)]
  [nsfilemanager-upload-local-version-of-ubiquitous-item-at-url-with-conflict-resolution-policy-completion-handler (c-> nsfilemanager? (or/c string? objc-object? #f) exact-integer? (or/c procedure? #f) void?)]
  )

;; --- Class reference ---
(import-class NSFileManager)

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer _bool _id _id _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _bool _id _id _pointer -> _bool)))
(define _msg-1  ; (_fun _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _bool)))
(define _msg-2  ; (_fun _pointer _pointer _id -> _string)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _string)))
(define _msg-3  ; (_fun _pointer _pointer _id _bool _id _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _bool _id _pointer -> _bool)))
(define _msg-4  ; (_fun _pointer _pointer _id _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id -> _bool)))
(define _msg-5  ; (_fun _pointer _pointer _id _id _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _id -> _bool)))
(define _msg-6  ; (_fun _pointer _pointer _id _id _id _uint64 _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _id _uint64 _pointer _pointer -> _bool)))
(define _msg-7  ; (_fun _pointer _pointer _id _id _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _pointer -> _bool)))
(define _msg-8  ; (_fun _pointer _pointer _id _id _uint64 _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _uint64 _pointer -> _id)))
(define _msg-9  ; (_fun _pointer _pointer _id _int64 _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _int64 _pointer -> _void)))
(define _msg-10  ; (_fun _pointer _pointer _id _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer -> _bool)))
(define _msg-11  ; (_fun _pointer _pointer _id _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer -> _id)))
(define _msg-12  ; (_fun _pointer _pointer _id _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer -> _void)))
(define _msg-13  ; (_fun _pointer _pointer _id _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer _pointer -> _bool)))
(define _msg-14  ; (_fun _pointer _pointer _id _pointer _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer _pointer -> _id)))
(define _msg-15  ; (_fun _pointer _pointer _id _uint64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _uint64 -> _id)))
(define _msg-16  ; (_fun _pointer _pointer _id _uint64 _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _uint64 _pointer -> _void)))
(define _msg-17  ; (_fun _pointer _pointer _pointer _id _id _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id _id _pointer -> _bool)))
(define _msg-18  ; (_fun _pointer _pointer _pointer _uint64 _uint64 _id _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _uint64 _uint64 _id _pointer -> _bool)))
(define _msg-19  ; (_fun _pointer _pointer _string _uint64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _string _uint64 -> _id)))
(define _msg-20  ; (_fun _pointer _pointer _uint64 _uint64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 _uint64 -> _id)))
(define _msg-21  ; (_fun _pointer _pointer _uint64 _uint64 _id _bool _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 _uint64 _id _bool _pointer -> _id)))

;; --- Constructors ---
(define (make-nsfilemanager)
  (wrap-objc-object
   (tell (tell NSFileManager alloc) init)
   #:retained #t))


;; --- Properties ---
(define (nsfilemanager-current-directory-path self)
  (wrap-objc-object
   (tell (coerce-arg self) currentDirectoryPath)))
(define (nsfilemanager-default-manager)
  (wrap-objc-object
   (tell NSFileManager defaultManager)))
(define (nsfilemanager-delegate self)
  (wrap-objc-object
   (tell (coerce-arg self) delegate)))
(define (nsfilemanager-set-delegate! self value)
  (tell #:type _void (coerce-arg self) setDelegate: (coerce-arg value)))
(define (nsfilemanager-home-directory-for-current-user self)
  (wrap-objc-object
   (tell (coerce-arg self) homeDirectoryForCurrentUser)))
(define (nsfilemanager-temporary-directory self)
  (wrap-objc-object
   (tell (coerce-arg self) temporaryDirectory)))
(define (nsfilemanager-ubiquity-identity-token self)
  (wrap-objc-object
   (tell (coerce-arg self) ubiquityIdentityToken)))

;; --- Instance methods ---
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-url-for-directory-in-domain-appropriate-for-url-create-error self directory domain url should-create error)
  (wrap-objc-object
   (_msg-21 (coerce-arg self) (sel_registerName "URLForDirectory:inDomain:appropriateForURL:create:error:") directory domain (coerce-arg url) should-create error)
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-url-for-publishing-ubiquitous-item-at-url-expiration-date-error self url out-date error)
  (wrap-objc-object
   (_msg-14 (coerce-arg self) (sel_registerName "URLForPublishingUbiquitousItemAtURL:expirationDate:error:") (coerce-arg url) out-date error)
   ))
(define (nsfilemanager-url-for-ubiquity-container-identifier self container-identifier)
  (wrap-objc-object
   (tell (coerce-arg self) URLForUbiquityContainerIdentifier: (coerce-arg container-identifier))))
(define (nsfilemanager-ur-ls-for-directory-in-domains self directory domain-mask)
  (wrap-objc-object
   (_msg-20 (coerce-arg self) (sel_registerName "URLsForDirectory:inDomains:") directory domain-mask)
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-attributes-of-file-system-for-path-error self path error)
  (wrap-objc-object
   (_msg-11 (coerce-arg self) (sel_registerName "attributesOfFileSystemForPath:error:") (coerce-arg path) error)
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-attributes-of-item-at-path-error self path error)
  (wrap-objc-object
   (_msg-11 (coerce-arg self) (sel_registerName "attributesOfItemAtPath:error:") (coerce-arg path) error)
   ))
(define (nsfilemanager-change-current-directory-path self path)
  (_msg-1 (coerce-arg self) (sel_registerName "changeCurrentDirectoryPath:") (coerce-arg path)))
(define (nsfilemanager-components-to-display-for-path self path)
  (wrap-objc-object
   (tell (coerce-arg self) componentsToDisplayForPath: (coerce-arg path))))
(define (nsfilemanager-container-url-for-security-application-group-identifier self group-identifier)
  (wrap-objc-object
   (tell (coerce-arg self) containerURLForSecurityApplicationGroupIdentifier: (coerce-arg group-identifier))))
(define (nsfilemanager-contents-at-path self path)
  (wrap-objc-object
   (tell (coerce-arg self) contentsAtPath: (coerce-arg path))))
(define (nsfilemanager-contents-equal-at-path-and-path self path1 path2)
  (_msg-4 (coerce-arg self) (sel_registerName "contentsEqualAtPath:andPath:") (coerce-arg path1) (coerce-arg path2)))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-contents-of-directory-at-path-error self path error)
  (wrap-objc-object
   (_msg-11 (coerce-arg self) (sel_registerName "contentsOfDirectoryAtPath:error:") (coerce-arg path) error)
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-contents-of-directory-at-url-including-properties-for-keys-options-error self url keys mask error)
  (wrap-objc-object
   (_msg-8 (coerce-arg self) (sel_registerName "contentsOfDirectoryAtURL:includingPropertiesForKeys:options:error:") (coerce-arg url) (coerce-arg keys) mask error)
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-copy-item-at-path-to-path-error self src-path dst-path error)
  (_msg-7 (coerce-arg self) (sel_registerName "copyItemAtPath:toPath:error:") (coerce-arg src-path) (coerce-arg dst-path) error))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-copy-item-at-url-to-url-error self src-url dst-url error)
  (_msg-7 (coerce-arg self) (sel_registerName "copyItemAtURL:toURL:error:") (coerce-arg src-url) (coerce-arg dst-url) error))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-create-directory-at-path-with-intermediate-directories-attributes-error self path create-intermediates attributes error)
  (_msg-3 (coerce-arg self) (sel_registerName "createDirectoryAtPath:withIntermediateDirectories:attributes:error:") (coerce-arg path) create-intermediates (coerce-arg attributes) error))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-create-directory-at-url-with-intermediate-directories-attributes-error self url create-intermediates attributes error)
  (_msg-3 (coerce-arg self) (sel_registerName "createDirectoryAtURL:withIntermediateDirectories:attributes:error:") (coerce-arg url) create-intermediates (coerce-arg attributes) error))
(define (nsfilemanager-create-file-at-path-contents-attributes self path data attr)
  (_msg-5 (coerce-arg self) (sel_registerName "createFileAtPath:contents:attributes:") (coerce-arg path) (coerce-arg data) (coerce-arg attr)))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-create-symbolic-link-at-path-with-destination-path-error self path dest-path error)
  (_msg-7 (coerce-arg self) (sel_registerName "createSymbolicLinkAtPath:withDestinationPath:error:") (coerce-arg path) (coerce-arg dest-path) error))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-create-symbolic-link-at-url-with-destination-url-error self url dest-url error)
  (_msg-7 (coerce-arg self) (sel_registerName "createSymbolicLinkAtURL:withDestinationURL:error:") (coerce-arg url) (coerce-arg dest-url) error))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-destination-of-symbolic-link-at-path-error self path error)
  (wrap-objc-object
   (_msg-11 (coerce-arg self) (sel_registerName "destinationOfSymbolicLinkAtPath:error:") (coerce-arg path) error)
   ))
(define (nsfilemanager-display-name-at-path! self path)
  (wrap-objc-object
   (tell (coerce-arg self) displayNameAtPath: (coerce-arg path))))
(define (nsfilemanager-enumerator-at-path self path)
  (wrap-objc-object
   (tell (coerce-arg self) enumeratorAtPath: (coerce-arg path))))
;; block param 3: stored (retained across calls)
(define (nsfilemanager-enumerator-at-url-including-properties-for-keys-options-error-handler self url keys mask handler)
  (define-values (_blk3 _blk3-id)
    (make-objc-block handler (list _id _id) _bool))
  (wrap-objc-object
   (_msg-8 (coerce-arg self) (sel_registerName "enumeratorAtURL:includingPropertiesForKeys:options:errorHandler:") (coerce-arg url) (coerce-arg keys) mask _blk3)
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-evict-ubiquitous-item-at-url-error self url error)
  (_msg-10 (coerce-arg self) (sel_registerName "evictUbiquitousItemAtURL:error:") (coerce-arg url) error))
;; block param 1: async-copied (runtime-managed)
(define (nsfilemanager-fetch-latest-remote-version-of-item-at-url-completion-handler self url completion-handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block completion-handler (list _id _id) _void))
  (_msg-12 (coerce-arg self) (sel_registerName "fetchLatestRemoteVersionOfItemAtURL:completionHandler:") (coerce-arg url) _blk1))
(define (nsfilemanager-file-exists-at-path self path)
  (_msg-1 (coerce-arg self) (sel_registerName "fileExistsAtPath:") (coerce-arg path)))
(define (nsfilemanager-file-exists-at-path-is-directory self path is-directory)
  (_msg-10 (coerce-arg self) (sel_registerName "fileExistsAtPath:isDirectory:") (coerce-arg path) is-directory))
(define (nsfilemanager-file-system-representation-with-path self path)
  (_msg-2 (coerce-arg self) (sel_registerName "fileSystemRepresentationWithPath:") (coerce-arg path)))
;; block param 1: async-copied (runtime-managed)
(define (nsfilemanager-get-file-provider-services-for-item-at-url-completion-handler self url completion-handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block completion-handler (list _id _id) _void))
  (_msg-12 (coerce-arg self) (sel_registerName "getFileProviderServicesForItemAtURL:completionHandler:") (coerce-arg url) _blk1))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-get-relationship-of-directory-in-domain-to-item-at-url-error self out-relationship directory domain-mask url error)
  (_msg-18 (coerce-arg self) (sel_registerName "getRelationship:ofDirectory:inDomain:toItemAtURL:error:") out-relationship directory domain-mask (coerce-arg url) error))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-get-relationship-of-directory-at-url-to-item-at-url-error self out-relationship directory-url other-url error)
  (_msg-17 (coerce-arg self) (sel_registerName "getRelationship:ofDirectoryAtURL:toItemAtURL:error:") out-relationship (coerce-arg directory-url) (coerce-arg other-url) error))
(define (nsfilemanager-is-deletable-file-at-path self path)
  (_msg-1 (coerce-arg self) (sel_registerName "isDeletableFileAtPath:") (coerce-arg path)))
(define (nsfilemanager-is-executable-file-at-path self path)
  (_msg-1 (coerce-arg self) (sel_registerName "isExecutableFileAtPath:") (coerce-arg path)))
(define (nsfilemanager-is-readable-file-at-path self path)
  (_msg-1 (coerce-arg self) (sel_registerName "isReadableFileAtPath:") (coerce-arg path)))
(define (nsfilemanager-is-ubiquitous-item-at-url self url)
  (_msg-1 (coerce-arg self) (sel_registerName "isUbiquitousItemAtURL:") (coerce-arg url)))
(define (nsfilemanager-is-writable-file-at-path self path)
  (_msg-1 (coerce-arg self) (sel_registerName "isWritableFileAtPath:") (coerce-arg path)))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-link-item-at-path-to-path-error self src-path dst-path error)
  (_msg-7 (coerce-arg self) (sel_registerName "linkItemAtPath:toPath:error:") (coerce-arg src-path) (coerce-arg dst-path) error))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-link-item-at-url-to-url-error self src-url dst-url error)
  (_msg-7 (coerce-arg self) (sel_registerName "linkItemAtURL:toURL:error:") (coerce-arg src-url) (coerce-arg dst-url) error))
(define (nsfilemanager-mounted-volume-ur-ls-including-resource-values-for-keys-options self property-keys options)
  (wrap-objc-object
   (_msg-15 (coerce-arg self) (sel_registerName "mountedVolumeURLsIncludingResourceValuesForKeys:options:") (coerce-arg property-keys) options)
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-move-item-at-path-to-path-error! self src-path dst-path error)
  (_msg-7 (coerce-arg self) (sel_registerName "moveItemAtPath:toPath:error:") (coerce-arg src-path) (coerce-arg dst-path) error))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-move-item-at-url-to-url-error! self src-url dst-url error)
  (_msg-7 (coerce-arg self) (sel_registerName "moveItemAtURL:toURL:error:") (coerce-arg src-url) (coerce-arg dst-url) error))
;; block param 1: async-copied (runtime-managed)
(define (nsfilemanager-pause-sync-for-ubiquitous-item-at-url-completion-handler self url completion-handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block completion-handler (list _id) _void))
  (_msg-12 (coerce-arg self) (sel_registerName "pauseSyncForUbiquitousItemAtURL:completionHandler:") (coerce-arg url) _blk1))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-remove-item-at-path-error! self path error)
  (_msg-10 (coerce-arg self) (sel_registerName "removeItemAtPath:error:") (coerce-arg path) error))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-remove-item-at-url-error! self url error)
  (_msg-10 (coerce-arg self) (sel_registerName "removeItemAtURL:error:") (coerce-arg url) error))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-replace-item-at-url-with-item-at-url-backup-item-name-options-resulting-item-url-error! self original-item-url new-item-url backup-item-name options resulting-url error)
  (_msg-6 (coerce-arg self) (sel_registerName "replaceItemAtURL:withItemAtURL:backupItemName:options:resultingItemURL:error:") (coerce-arg original-item-url) (coerce-arg new-item-url) (coerce-arg backup-item-name) options resulting-url error))
;; block param 2: async-copied (runtime-managed)
(define (nsfilemanager-resume-sync-for-ubiquitous-item-at-url-with-behavior-completion-handler self url behavior completion-handler)
  (define-values (_blk2 _blk2-id)
    (make-objc-block completion-handler (list _id) _void))
  (_msg-9 (coerce-arg self) (sel_registerName "resumeSyncForUbiquitousItemAtURL:withBehavior:completionHandler:") (coerce-arg url) behavior _blk2))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-set-attributes-of-item-at-path-error! self attributes path error)
  (_msg-7 (coerce-arg self) (sel_registerName "setAttributes:ofItemAtPath:error:") (coerce-arg attributes) (coerce-arg path) error))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-set-ubiquitous-item-at-url-destination-url-error! self flag url destination-url error)
  (_msg-0 (coerce-arg self) (sel_registerName "setUbiquitous:itemAtURL:destinationURL:error:") flag (coerce-arg url) (coerce-arg destination-url) error))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-start-downloading-ubiquitous-item-at-url-error self url error)
  (_msg-10 (coerce-arg self) (sel_registerName "startDownloadingUbiquitousItemAtURL:error:") (coerce-arg url) error))
(define (nsfilemanager-string-with-file-system-representation-length self str len)
  (wrap-objc-object
   (_msg-19 (coerce-arg self) (sel_registerName "stringWithFileSystemRepresentation:length:") str len)
   ))
(define (nsfilemanager-subpaths-at-path self path)
  (wrap-objc-object
   (tell (coerce-arg self) subpathsAtPath: (coerce-arg path))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-subpaths-of-directory-at-path-error self path error)
  (wrap-objc-object
   (_msg-11 (coerce-arg self) (sel_registerName "subpathsOfDirectoryAtPath:error:") (coerce-arg path) error)
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsfilemanager-trash-item-at-url-resulting-item-url-error self url out-resulting-url error)
  (_msg-13 (coerce-arg self) (sel_registerName "trashItemAtURL:resultingItemURL:error:") (coerce-arg url) out-resulting-url error))
;; block param 2: async-copied (runtime-managed)
(define (nsfilemanager-unmount-volume-at-url-options-completion-handler self url mask completion-handler)
  (define-values (_blk2 _blk2-id)
    (make-objc-block completion-handler (list _id) _void))
  (_msg-16 (coerce-arg self) (sel_registerName "unmountVolumeAtURL:options:completionHandler:") (coerce-arg url) mask _blk2))
;; block param 2: async-copied (runtime-managed)
(define (nsfilemanager-upload-local-version-of-ubiquitous-item-at-url-with-conflict-resolution-policy-completion-handler self url conflict-resolution-policy completion-handler)
  (define-values (_blk2 _blk2-id)
    (make-objc-block completion-handler (list _id _id) _void))
  (_msg-9 (coerce-arg self) (sel_registerName "uploadLocalVersionOfUbiquitousItemAtURL:withConflictResolutionPolicy:completionHandler:") (coerce-arg url) conflict-resolution-policy _blk2))
