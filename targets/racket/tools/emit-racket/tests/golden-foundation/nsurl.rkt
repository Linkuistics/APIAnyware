#lang racket/base
;; Generated binding for NSURL (Foundation)
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
(define (nsnumber? v) (objc-instance-of? v "NSNumber"))
(define (nsprogress? v) (objc-instance-of? v "NSProgress"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (nsurl? v) (objc-instance-of? v "NSURL"))
(define (nsurlhandle? v) (objc-instance-of? v "NSURLHandle"))
(define (_playgroundquicklook? v) (objc-instance-of? v "_PlaygroundQuickLook"))
(provide NSURL)
(provide/contract
  [make-nsurl-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsurl-init-with-data-representation-relative-to-url (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [make-nsurl-init-with-string (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsurl-init-with-string-encoding-invalid-characters (c-> (or/c string? objc-object? #f) boolean? any/c)]
  [make-nsurl-init-with-string-relative-to-url (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nsurl-url-by-deleting-last-path-component (c-> nsurl? (or/c nsurl? objc-nil?))]
  [nsurl-url-by-deleting-path-extension (c-> nsurl? (or/c nsurl? objc-nil?))]
  [nsurl-url-by-resolving-symlinks-in-path (c-> nsurl? (or/c nsurl? objc-nil?))]
  [nsurl-url-by-standardizing-path (c-> nsurl? (or/c nsurl? objc-nil?))]
  [nsurl-absolute-string (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-absolute-url (c-> nsurl? (or/c nsurl? objc-nil?))]
  [nsurl-base-url (c-> nsurl? (or/c nsurl? objc-nil?))]
  [nsurl-custom-playground-quick-look (c-> nsurl? (or/c _playgroundquicklook? objc-nil?))]
  [nsurl-data-representation (c-> nsurl? (or/c nsdata? objc-nil?))]
  [nsurl-file-path-url (c-> nsurl? (or/c nsurl? objc-nil?))]
  [nsurl-file-system-representation (c-> nsurl? (or/c string? #f))]
  [nsurl-file-url (c-> nsurl? boolean?)]
  [nsurl-fragment (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-has-directory-path (c-> nsurl? boolean?)]
  [nsurl-host (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-last-path-component (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-parameter-string (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-password (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-path (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-path-components (c-> nsurl? (or/c nsarray? objc-nil?))]
  [nsurl-path-extension (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-port (c-> nsurl? (or/c nsnumber? objc-nil?))]
  [nsurl-query (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-relative-path (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-relative-string (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-resource-specifier (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-scheme (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-standardized-url (c-> nsurl? (or/c nsurl? objc-nil?))]
  [nsurl-user (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-url-by-appending-path-component (c-> nsurl? (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsurl-url-by-appending-path-component-is-directory (c-> nsurl? (or/c string? objc-object? #f) boolean? (or/c nsurl? objc-nil?))]
  [nsurl-url-by-appending-path-extension (c-> nsurl? (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsurl-bookmark-data-with-options-including-resource-values-for-keys-relative-to-url-error (c-> nsurl? exact-nonnegative-integer? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (values (or/c nsdata? objc-nil?) (or/c objc-object? #f)))]
  [nsurl-check-promised-item-is-reachable-and-return-error (c-> nsurl? (values boolean? (or/c objc-object? #f)))]
  [nsurl-check-resource-is-reachable-and-return-error (c-> nsurl? (values boolean? (or/c objc-object? #f)))]
  [nsurl-copy-with-zone (c-> nsurl? (or/c cpointer? #f) any/c)]
  [nsurl-encode-with-coder (c-> nsurl? (or/c string? objc-object? #f) void?)]
  [nsurl-file-reference-url (c-> nsurl? (or/c nsurl? objc-nil?))]
  [nsurl-get-file-system-representation-max-length (c-> nsurl? (or/c cpointer? #f) exact-nonnegative-integer? boolean?)]
  [nsurl-get-promised-item-resource-value-for-key-error (c-> nsurl? (or/c cpointer? #f) (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsurl-get-resource-value-for-key-error (c-> nsurl? (or/c cpointer? #f) (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsurl-init-absolute-url-with-data-representation-relative-to-url (c-> nsurl? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nsurl-init-by-resolving-bookmark-data-options-relative-to-url-bookmark-data-is-stale-error (c-> nsurl? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c string? objc-object? #f) (or/c cpointer? #f) (values any/c (or/c objc-object? #f)))]
  [nsurl-init-file-url-with-file-system-representation-is-directory-relative-to-url (c-> nsurl? string? boolean? (or/c string? objc-object? #f) any/c)]
  [nsurl-init-file-url-with-path (c-> nsurl? (or/c string? objc-object? #f) any/c)]
  [nsurl-init-file-url-with-path-is-directory (c-> nsurl? (or/c string? objc-object? #f) boolean? any/c)]
  [nsurl-init-file-url-with-path-is-directory-relative-to-url (c-> nsurl? (or/c string? objc-object? #f) boolean? (or/c string? objc-object? #f) any/c)]
  [nsurl-init-file-url-with-path-relative-to-url (c-> nsurl? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nsurl-is-file-reference-url (c-> nsurl? boolean?)]
  [nsurl-is-file-url (c-> nsurl? boolean?)]
  [nsurl-item-provider-visibility-for-representation-with-type-identifier (c-> nsurl? (or/c string? objc-object? #f) exact-integer?)]
  [nsurl-load-data-with-type-identifier-for-item-provider-completion-handler (c-> nsurl? (or/c string? objc-object? #f) (or/c procedure? #f) (or/c nsprogress? objc-nil?))]
  [nsurl-promised-item-resource-values-for-keys-error (c-> nsurl? (or/c string? objc-object? #f) (values (or/c nsdictionary? objc-nil?) (or/c objc-object? #f)))]
  [nsurl-remove-all-cached-resource-values! (c-> nsurl? void?)]
  [nsurl-remove-cached-resource-value-for-key! (c-> nsurl? (or/c string? objc-object? #f) void?)]
  [nsurl-resource-values-for-keys-error (c-> nsurl? (or/c string? objc-object? #f) (values (or/c nsdictionary? objc-nil?) (or/c objc-object? #f)))]
  [nsurl-set-resource-value-for-key-error! (c-> nsurl? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsurl-set-resource-values-error! (c-> nsurl? (or/c string? objc-object? #f) (values boolean? (or/c objc-object? #f)))]
  [nsurl-set-temporary-resource-value-for-key! (c-> nsurl? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsurl-start-accessing-security-scoped-resource (c-> nsurl? boolean?)]
  [nsurl-stop-accessing-security-scoped-resource (c-> nsurl? void?)]
  [nsurl-writable-type-identifiers-for-item-provider (c-> nsurl? (or/c nsarray? objc-nil?))]
  [nsurl-url-by-resolving-alias-file-at-url-options-error (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? (values any/c (or/c objc-object? #f)))]
  [nsurl-url-by-resolving-bookmark-data-options-relative-to-url-bookmark-data-is-stale-error (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c string? objc-object? #f) (or/c cpointer? #f) (values any/c (or/c objc-object? #f)))]
  [nsurl-url-with-data-representation-relative-to-url (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsurl-url-with-string (c-> (or/c string? objc-object? #f) any/c)]
  [nsurl-url-with-string-encoding-invalid-characters (c-> (or/c string? objc-object? #f) boolean? any/c)]
  [nsurl-url-with-string-relative-to-url (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nsurl-absolute-url-with-data-representation-relative-to-url (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsurl-bookmark-data-with-contents-of-url-error (c-> (or/c string? objc-object? #f) (values (or/c nsdata? objc-nil?) (or/c objc-object? #f)))]
  [nsurl-file-url-with-file-system-representation-is-directory-relative-to-url (c-> string? boolean? (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsurl-file-url-with-path (c-> (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsurl-file-url-with-path-is-directory (c-> (or/c string? objc-object? #f) boolean? (or/c nsurl? objc-nil?))]
  [nsurl-file-url-with-path-is-directory-relative-to-url (c-> (or/c string? objc-object? #f) boolean? (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsurl-file-url-with-path-relative-to-url (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsurl-file-url-with-path-components (c-> (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsurl-object-with-item-provider-data-type-identifier-error (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (values any/c (or/c objc-object? #f)))]
  [nsurl-readable-type-identifiers-for-item-provider (c-> (or/c nsarray? objc-nil?))]
  [nsurl-resource-values-for-keys-from-bookmark-data (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c nsdictionary? objc-nil?))]
  [nsurl-supports-secure-coding (c-> boolean?)]
  [nsurl-write-bookmark-data-to-url-options-error (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer? (values boolean? (or/c objc-object? #f)))]
  )

;; --- Class reference ---
(import-class NSURL)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_N (-> ptr_t ptr_t string_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_b_e (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_v (-> ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_P_e (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_b_e (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_P_q (-> ptr_t ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_P_e (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_b_e (-> ptr_t ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPQ_b_e (-> ptr_t ptr_t ptr_t ptr_t uint64_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_Pb_P (-> ptr_t ptr_t ptr_t bool_t ptr_t))
(define-aw-msg aw_racket_msg_PbP_P (-> ptr_t ptr_t ptr_t bool_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PQ_P_e (-> ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PQ_b (-> ptr_t ptr_t ptr_t uint64_t bool_t))
(define-aw-msg aw_racket_msg_PQPP_P_e (-> ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_NbP_P (-> ptr_t ptr_t string_t bool_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_QPP_P_e (-> ptr_t ptr_t uint64_t ptr_t ptr_t ptr_t ptr_t))

;; --- Constructors ---
(define (make-nsurl-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSURL alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nsurl-init-with-data-representation-relative-to-url data base-url)
  (wrap-objc-object
   (tell (tell NSURL alloc)
         initWithDataRepresentation: (coerce-arg data) relativeToURL: (coerce-arg base-url))
   #:retained #t))

(define (make-nsurl-init-with-string url-string)
  (wrap-objc-object
   (tell (tell NSURL alloc)
         initWithString: (coerce-arg url-string))
   #:retained #t))

(define (make-nsurl-init-with-string-encoding-invalid-characters url-string encoding-invalid-characters)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Pb_P (id->ffi2-ptr (tell NSURL alloc)) (id->ffi2-ptr (sel_registerName "initWithString:encodingInvalidCharacters:")) (id->ffi2-ptr (coerce-arg url-string)) encoding-invalid-characters))
   #:retained #t))

(define (make-nsurl-init-with-string-relative-to-url url-string base-url)
  (wrap-objc-object
   (tell (tell NSURL alloc)
         initWithString: (coerce-arg url-string) relativeToURL: (coerce-arg base-url))
   #:retained #t))


;; --- Properties ---
(define (nsurl-url-by-deleting-last-path-component self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "URLByDeletingLastPathComponent"))))))
(define (nsurl-url-by-deleting-path-extension self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "URLByDeletingPathExtension"))))))
(define (nsurl-url-by-resolving-symlinks-in-path self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "URLByResolvingSymlinksInPath"))))))
(define (nsurl-url-by-standardizing-path self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "URLByStandardizingPath"))))))
(define (nsurl-absolute-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "absoluteString"))))))
(define (nsurl-absolute-url self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "absoluteURL"))))))
(define (nsurl-base-url self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "baseURL"))))))
(define (nsurl-custom-playground-quick-look self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "customPlaygroundQuickLook"))))))
(define (nsurl-data-representation self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dataRepresentation"))))))
(define (nsurl-file-path-url self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "filePathURL"))))))
(define (nsurl-file-system-representation self)
  (aw_racket_msg_0_N (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fileSystemRepresentation"))))
(define (nsurl-file-url self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fileURL"))))
(define (nsurl-fragment self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fragment"))))))
(define (nsurl-has-directory-path self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasDirectoryPath"))))
(define (nsurl-host self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "host"))))))
(define (nsurl-last-path-component self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastPathComponent"))))))
(define (nsurl-parameter-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "parameterString"))))))
(define (nsurl-password self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "password"))))))
(define (nsurl-path self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "path"))))))
(define (nsurl-path-components self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pathComponents"))))))
(define (nsurl-path-extension self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pathExtension"))))))
(define (nsurl-port self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "port"))))))
(define (nsurl-query self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "query"))))))
(define (nsurl-relative-path self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "relativePath"))))))
(define (nsurl-relative-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "relativeString"))))))
(define (nsurl-resource-specifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resourceSpecifier"))))))
(define (nsurl-scheme self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scheme"))))))
(define (nsurl-standardized-url self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "standardizedURL"))))))
(define (nsurl-user self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "user"))))))

;; --- Instance methods ---
(define (nsurl-url-by-appending-path-component self path-component)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "URLByAppendingPathComponent:")) (id->ffi2-ptr (coerce-arg path-component))))
   ))
(define (nsurl-url-by-appending-path-component-is-directory self path-component is-directory)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Pb_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "URLByAppendingPathComponent:isDirectory:")) (id->ffi2-ptr (coerce-arg path-component)) is-directory))
   ))
(define (nsurl-url-by-appending-path-extension self path-extension)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "URLByAppendingPathExtension:")) (id->ffi2-ptr (coerce-arg path-extension))))
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsurl-bookmark-data-with-options-including-resource-values-for-keys-relative-to-url-error self options keys relative-url)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_QPP_P_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bookmarkDataWithOptions:includingResourceValuesForKeys:relativeToURL:error:")) options (id->ffi2-ptr (coerce-arg keys)) (id->ffi2-ptr (coerce-arg relative-url)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsurl-check-promised-item-is-reachable-and-return-error self)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_0_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "checkPromisedItemIsReachableAndReturnError:")) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsurl-check-resource-is-reachable-and-return-error self)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_0_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "checkResourceIsReachableAndReturnError:")) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsurl-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "copyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))
(define (nsurl-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nsurl-file-reference-url self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fileReferenceURL"))))
   ))
(define (nsurl-get-file-system-representation-max-length self buffer max-buffer-length)
  (aw_racket_msg_PQ_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getFileSystemRepresentation:maxLength:")) (id->ffi2-ptr buffer) max-buffer-length))
;; NSError out-param: result-or-error wrapper candidate
(define (nsurl-get-promised-item-resource-value-for-key-error self value key)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getPromisedItemResourceValue:forKey:error:")) (id->ffi2-ptr value) (id->ffi2-ptr (coerce-arg key)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsurl-get-resource-value-for-key-error self value key)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getResourceValue:forKey:error:")) (id->ffi2-ptr value) (id->ffi2-ptr (coerce-arg key)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsurl-init-absolute-url-with-data-representation-relative-to-url self data base-url)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "initAbsoluteURLWithDataRepresentation:relativeToURL:")) (id->ffi2-ptr (coerce-arg data)) (id->ffi2-ptr (coerce-arg base-url))))
   #:retained #t))
;; NSError out-param: result-or-error wrapper candidate
(define (nsurl-init-by-resolving-bookmark-data-options-relative-to-url-bookmark-data-is-stale-error self bookmark-data options relative-url is-stale)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PQPP_P_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "initByResolvingBookmarkData:options:relativeToURL:bookmarkDataIsStale:error:")) (id->ffi2-ptr (coerce-arg bookmark-data)) options (id->ffi2-ptr (coerce-arg relative-url)) (id->ffi2-ptr is-stale) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result) #:retained #t) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsurl-init-file-url-with-file-system-representation-is-directory-relative-to-url self path is-dir base-url)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_NbP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "initFileURLWithFileSystemRepresentation:isDirectory:relativeToURL:")) path is-dir (id->ffi2-ptr (coerce-arg base-url))))
   #:retained #t))
(define (nsurl-init-file-url-with-path self path)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "initFileURLWithPath:")) (id->ffi2-ptr (coerce-arg path))))
   #:retained #t))
(define (nsurl-init-file-url-with-path-is-directory self path is-dir)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Pb_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "initFileURLWithPath:isDirectory:")) (id->ffi2-ptr (coerce-arg path)) is-dir))
   #:retained #t))
(define (nsurl-init-file-url-with-path-is-directory-relative-to-url self path is-dir base-url)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PbP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "initFileURLWithPath:isDirectory:relativeToURL:")) (id->ffi2-ptr (coerce-arg path)) is-dir (id->ffi2-ptr (coerce-arg base-url))))
   #:retained #t))
(define (nsurl-init-file-url-with-path-relative-to-url self path base-url)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "initFileURLWithPath:relativeToURL:")) (id->ffi2-ptr (coerce-arg path)) (id->ffi2-ptr (coerce-arg base-url))))
   #:retained #t))
(define (nsurl-is-file-reference-url self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isFileReferenceURL"))))
(define (nsurl-is-file-url self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isFileURL"))))
(define (nsurl-item-provider-visibility-for-representation-with-type-identifier self type-identifier)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "itemProviderVisibilityForRepresentationWithTypeIdentifier:")) (id->ffi2-ptr (coerce-arg type-identifier))))
;; block param 1: async-copied (runtime-managed)
(define (nsurl-load-data-with-type-identifier-for-item-provider-completion-handler self type-identifier completion-handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block completion-handler (list _id _id) _void))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "loadDataWithTypeIdentifier:forItemProviderCompletionHandler:")) (id->ffi2-ptr (coerce-arg type-identifier)) (id->ffi2-ptr _blk1)))
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsurl-promised-item-resource-values-for-keys-error self keys)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_P_P_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "promisedItemResourceValuesForKeys:error:")) (id->ffi2-ptr (coerce-arg keys)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsurl-remove-all-cached-resource-values! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeAllCachedResourceValues"))))
(define (nsurl-remove-cached-resource-value-for-key! self key)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeCachedResourceValueForKey:")) (id->ffi2-ptr (coerce-arg key))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsurl-resource-values-for-keys-error self keys)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_P_P_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resourceValuesForKeys:error:")) (id->ffi2-ptr (coerce-arg keys)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsurl-set-resource-value-for-key-error! self value key)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setResourceValue:forKey:error:")) (id->ffi2-ptr (coerce-arg value)) (id->ffi2-ptr (coerce-arg key)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsurl-set-resource-values-error! self keyed-values)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_P_b_e (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setResourceValues:error:")) (id->ffi2-ptr (coerce-arg keyed-values)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsurl-set-temporary-resource-value-for-key! self value key)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTemporaryResourceValue:forKey:")) (id->ffi2-ptr (coerce-arg value)) (id->ffi2-ptr (coerce-arg key))))
(define (nsurl-start-accessing-security-scoped-resource self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "startAccessingSecurityScopedResource"))))
(define (nsurl-stop-accessing-security-scoped-resource self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stopAccessingSecurityScopedResource"))))
(define (nsurl-writable-type-identifiers-for-item-provider self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writableTypeIdentifiersForItemProvider"))))
   ))

;; --- Class methods ---
;; NSError out-param: result-or-error wrapper candidate
(define (nsurl-url-by-resolving-alias-file-at-url-options-error url options)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PQ_P_e (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "URLByResolvingAliasFileAtURL:options:error:")) (id->ffi2-ptr (coerce-arg url)) options (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsurl-url-by-resolving-bookmark-data-options-relative-to-url-bookmark-data-is-stale-error bookmark-data options relative-url is-stale)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PQPP_P_e (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "URLByResolvingBookmarkData:options:relativeToURL:bookmarkDataIsStale:error:")) (id->ffi2-ptr (coerce-arg bookmark-data)) options (id->ffi2-ptr (coerce-arg relative-url)) (id->ffi2-ptr is-stale) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsurl-url-with-data-representation-relative-to-url data base-url)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "URLWithDataRepresentation:relativeToURL:")) (id->ffi2-ptr (coerce-arg data)) (id->ffi2-ptr (coerce-arg base-url))))
   ))
(define (nsurl-url-with-string url-string)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "URLWithString:")) (id->ffi2-ptr (coerce-arg url-string))))
   ))
(define (nsurl-url-with-string-encoding-invalid-characters url-string encoding-invalid-characters)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Pb_P (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "URLWithString:encodingInvalidCharacters:")) (id->ffi2-ptr (coerce-arg url-string)) encoding-invalid-characters))
   ))
(define (nsurl-url-with-string-relative-to-url url-string base-url)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "URLWithString:relativeToURL:")) (id->ffi2-ptr (coerce-arg url-string)) (id->ffi2-ptr (coerce-arg base-url))))
   ))
(define (nsurl-absolute-url-with-data-representation-relative-to-url data base-url)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "absoluteURLWithDataRepresentation:relativeToURL:")) (id->ffi2-ptr (coerce-arg data)) (id->ffi2-ptr (coerce-arg base-url))))
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsurl-bookmark-data-with-contents-of-url-error bookmark-file-url)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_P_P_e (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "bookmarkDataWithContentsOfURL:error:")) (id->ffi2-ptr (coerce-arg bookmark-file-url)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsurl-file-url-with-file-system-representation-is-directory-relative-to-url path is-dir base-url)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_NbP_P (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "fileURLWithFileSystemRepresentation:isDirectory:relativeToURL:")) path is-dir (id->ffi2-ptr (coerce-arg base-url))))
   ))
(define (nsurl-file-url-with-path path)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "fileURLWithPath:")) (id->ffi2-ptr (coerce-arg path))))
   ))
(define (nsurl-file-url-with-path-is-directory path is-dir)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Pb_P (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "fileURLWithPath:isDirectory:")) (id->ffi2-ptr (coerce-arg path)) is-dir))
   ))
(define (nsurl-file-url-with-path-is-directory-relative-to-url path is-dir base-url)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PbP_P (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "fileURLWithPath:isDirectory:relativeToURL:")) (id->ffi2-ptr (coerce-arg path)) is-dir (id->ffi2-ptr (coerce-arg base-url))))
   ))
(define (nsurl-file-url-with-path-relative-to-url path base-url)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "fileURLWithPath:relativeToURL:")) (id->ffi2-ptr (coerce-arg path)) (id->ffi2-ptr (coerce-arg base-url))))
   ))
(define (nsurl-file-url-with-path-components components)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "fileURLWithPathComponents:")) (id->ffi2-ptr (coerce-arg components))))
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsurl-object-with-item-provider-data-type-identifier-error data type-identifier)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_P_e (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "objectWithItemProviderData:typeIdentifier:error:")) (id->ffi2-ptr (coerce-arg data)) (id->ffi2-ptr (coerce-arg type-identifier)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsurl-readable-type-identifiers-for-item-provider)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "readableTypeIdentifiersForItemProvider"))))
   ))
(define (nsurl-resource-values-for-keys-from-bookmark-data keys bookmark-data)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "resourceValuesForKeys:fromBookmarkData:")) (id->ffi2-ptr (coerce-arg keys)) (id->ffi2-ptr (coerce-arg bookmark-data))))
   ))
(define (nsurl-supports-secure-coding)
  (aw_racket_msg_0_b (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "supportsSecureCoding"))))
;; NSError out-param: result-or-error wrapper candidate
(define (nsurl-write-bookmark-data-to-url-options-error bookmark-data bookmark-file-url options)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PPQ_b_e (id->ffi2-ptr NSURL) (id->ffi2-ptr (sel_registerName "writeBookmarkData:toURL:options:error:")) (id->ffi2-ptr (coerce-arg bookmark-data)) (id->ffi2-ptr (coerce-arg bookmark-file-url)) options (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values result (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
