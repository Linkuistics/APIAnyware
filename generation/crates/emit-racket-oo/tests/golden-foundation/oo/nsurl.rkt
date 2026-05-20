#lang racket/base
;; Generated binding for NSURL (Foundation)
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
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsnumber? v) (objc-instance-of? v "NSNumber"))
(define (nsprogress? v) (objc-instance-of? v "NSProgress"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (nsurl? v) (objc-instance-of? v "NSURL"))
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
  [nsurl-path-components (c-> nsurl? any/c)]
  [nsurl-path-extension (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-port (c-> nsurl? (or/c nsnumber? objc-nil?))]
  [nsurl-query (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-relative-path (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-relative-string (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-resource-specifier (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-scheme (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-standardized-url (c-> nsurl? (or/c nsurl? objc-nil?))]
  [nsurl-user (c-> nsurl? (or/c nsstring? objc-nil?))]
  [nsurl-bookmark-data-with-options-including-resource-values-for-keys-relative-to-url-error (c-> nsurl? exact-nonnegative-integer? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) (or/c nsdata? objc-nil?))]
  [nsurl-copy-with-zone (c-> nsurl? (or/c cpointer? #f) any/c)]
  [nsurl-encode-with-coder (c-> nsurl? (or/c string? objc-object? #f) void?)]
  [nsurl-file-reference-url (c-> nsurl? (or/c nsurl? objc-nil?))]
  [nsurl-get-file-system-representation-max-length (c-> nsurl? (or/c cpointer? #f) exact-nonnegative-integer? boolean?)]
  [nsurl-get-resource-value-for-key-error (c-> nsurl? (or/c cpointer? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsurl-init-absolute-url-with-data-representation-relative-to-url (c-> nsurl? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nsurl-init-by-resolving-bookmark-data-options-relative-to-url-bookmark-data-is-stale-error (c-> nsurl? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c string? objc-object? #f) (or/c cpointer? #f) (or/c cpointer? #f) any/c)]
  [nsurl-init-file-url-with-file-system-representation-is-directory-relative-to-url (c-> nsurl? string? boolean? (or/c string? objc-object? #f) any/c)]
  [nsurl-init-file-url-with-path (c-> nsurl? (or/c string? objc-object? #f) any/c)]
  [nsurl-init-file-url-with-path-is-directory (c-> nsurl? (or/c string? objc-object? #f) boolean? any/c)]
  [nsurl-init-file-url-with-path-is-directory-relative-to-url (c-> nsurl? (or/c string? objc-object? #f) boolean? (or/c string? objc-object? #f) any/c)]
  [nsurl-init-file-url-with-path-relative-to-url (c-> nsurl? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nsurl-is-file-reference-url (c-> nsurl? boolean?)]
  [nsurl-is-file-url (c-> nsurl? boolean?)]
  [nsurl-item-provider-visibility-for-representation-with-type-identifier (c-> nsurl? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nsurl-load-data-with-type-identifier-for-item-provider-completion-handler (c-> nsurl? (or/c string? objc-object? #f) (or/c procedure? #f) (or/c nsprogress? objc-nil?))]
  [nsurl-remove-all-cached-resource-values! (c-> nsurl? void?)]
  [nsurl-remove-cached-resource-value-for-key! (c-> nsurl? (or/c string? objc-object? #f) void?)]
  [nsurl-resource-values-for-keys-error (c-> nsurl? (or/c string? objc-object? #f) (or/c cpointer? #f) any/c)]
  [nsurl-set-resource-value-for-key-error! (c-> nsurl? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsurl-set-resource-values-error! (c-> nsurl? (or/c string? objc-object? #f) (or/c cpointer? #f) boolean?)]
  [nsurl-set-temporary-resource-value-for-key! (c-> nsurl? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsurl-start-accessing-security-scoped-resource (c-> nsurl? boolean?)]
  [nsurl-stop-accessing-security-scoped-resource (c-> nsurl? void?)]
  [nsurl-writable-type-identifiers-for-item-provider (c-> nsurl? any/c)]
  [nsurl-url-by-resolving-alias-file-at-url-options-error (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c cpointer? #f) any/c)]
  [nsurl-url-by-resolving-bookmark-data-options-relative-to-url-bookmark-data-is-stale-error (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c string? objc-object? #f) (or/c cpointer? #f) (or/c cpointer? #f) any/c)]
  [nsurl-url-with-data-representation-relative-to-url (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsurl-url-with-string (c-> (or/c string? objc-object? #f) any/c)]
  [nsurl-url-with-string-encoding-invalid-characters (c-> (or/c string? objc-object? #f) boolean? any/c)]
  [nsurl-url-with-string-relative-to-url (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nsurl-absolute-url-with-data-representation-relative-to-url (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsurl-bookmark-data-with-contents-of-url-error (c-> (or/c string? objc-object? #f) (or/c cpointer? #f) (or/c nsdata? objc-nil?))]
  [nsurl-file-url-with-file-system-representation-is-directory-relative-to-url (c-> string? boolean? (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsurl-file-url-with-path (c-> (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsurl-file-url-with-path-is-directory (c-> (or/c string? objc-object? #f) boolean? (or/c nsurl? objc-nil?))]
  [nsurl-file-url-with-path-is-directory-relative-to-url (c-> (or/c string? objc-object? #f) boolean? (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsurl-file-url-with-path-relative-to-url (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c nsurl? objc-nil?))]
  [nsurl-object-with-item-provider-data-type-identifier-error (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) any/c)]
  [nsurl-readable-type-identifiers-for-item-provider (c-> any/c)]
  [nsurl-resource-values-for-keys-from-bookmark-data (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nsurl-supports-secure-coding (c-> boolean?)]
  [nsurl-write-bookmark-data-to-url-options-error (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c cpointer? #f) boolean?)]
  )

;; --- Class reference ---
(import-class NSURL)

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _bool)))
(define _msg-1  ; (_fun _pointer _pointer -> _string)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _string)))
(define _msg-2  ; (_fun _pointer _pointer _id -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _int64)))
(define _msg-3  ; (_fun _pointer _pointer _id _bool -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _bool -> _id)))
(define _msg-4  ; (_fun _pointer _pointer _id _bool _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _bool _id -> _id)))
(define _msg-5  ; (_fun _pointer _pointer _id _id _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _pointer -> _bool)))
(define _msg-6  ; (_fun _pointer _pointer _id _id _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _pointer -> _id)))
(define _msg-7  ; (_fun _pointer _pointer _id _id _uint64 _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _uint64 _pointer -> _bool)))
(define _msg-8  ; (_fun _pointer _pointer _id _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer -> _bool)))
(define _msg-9  ; (_fun _pointer _pointer _id _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer -> _id)))
(define _msg-10  ; (_fun _pointer _pointer _id _uint64 _id _pointer _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _uint64 _id _pointer _pointer -> _id)))
(define _msg-11  ; (_fun _pointer _pointer _id _uint64 _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _uint64 _pointer -> _id)))
(define _msg-12  ; (_fun _pointer _pointer _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _id)))
(define _msg-13  ; (_fun _pointer _pointer _pointer _id _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id _pointer -> _bool)))
(define _msg-14  ; (_fun _pointer _pointer _pointer _uint64 -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _uint64 -> _bool)))
(define _msg-15  ; (_fun _pointer _pointer _string _bool _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _string _bool _id -> _id)))
(define _msg-16  ; (_fun _pointer _pointer _uint64 _id _id _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 _id _id _pointer -> _id)))

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
   (_msg-3 (tell NSURL alloc)
       (sel_registerName "initWithString:encodingInvalidCharacters:")
       (coerce-arg url-string)
       encoding-invalid-characters)
   #:retained #t))

(define (make-nsurl-init-with-string-relative-to-url url-string base-url)
  (wrap-objc-object
   (tell (tell NSURL alloc)
         initWithString: (coerce-arg url-string) relativeToURL: (coerce-arg base-url))
   #:retained #t))


;; --- Properties ---
(define (nsurl-url-by-deleting-last-path-component self)
  (wrap-objc-object
   (tell (coerce-arg self) URLByDeletingLastPathComponent)))
(define (nsurl-url-by-deleting-path-extension self)
  (wrap-objc-object
   (tell (coerce-arg self) URLByDeletingPathExtension)))
(define (nsurl-url-by-resolving-symlinks-in-path self)
  (wrap-objc-object
   (tell (coerce-arg self) URLByResolvingSymlinksInPath)))
(define (nsurl-url-by-standardizing-path self)
  (wrap-objc-object
   (tell (coerce-arg self) URLByStandardizingPath)))
(define (nsurl-absolute-string self)
  (wrap-objc-object
   (tell (coerce-arg self) absoluteString)))
(define (nsurl-absolute-url self)
  (wrap-objc-object
   (tell (coerce-arg self) absoluteURL)))
(define (nsurl-base-url self)
  (wrap-objc-object
   (tell (coerce-arg self) baseURL)))
(define (nsurl-custom-playground-quick-look self)
  (wrap-objc-object
   (tell (coerce-arg self) customPlaygroundQuickLook)))
(define (nsurl-data-representation self)
  (wrap-objc-object
   (tell (coerce-arg self) dataRepresentation)))
(define (nsurl-file-path-url self)
  (wrap-objc-object
   (tell (coerce-arg self) filePathURL)))
(define (nsurl-file-system-representation self)
  (tell #:type _string (coerce-arg self) fileSystemRepresentation))
(define (nsurl-file-url self)
  (tell #:type _bool (coerce-arg self) fileURL))
(define (nsurl-fragment self)
  (wrap-objc-object
   (tell (coerce-arg self) fragment)))
(define (nsurl-has-directory-path self)
  (tell #:type _bool (coerce-arg self) hasDirectoryPath))
(define (nsurl-host self)
  (wrap-objc-object
   (tell (coerce-arg self) host)))
(define (nsurl-last-path-component self)
  (wrap-objc-object
   (tell (coerce-arg self) lastPathComponent)))
(define (nsurl-parameter-string self)
  (wrap-objc-object
   (tell (coerce-arg self) parameterString)))
(define (nsurl-password self)
  (wrap-objc-object
   (tell (coerce-arg self) password)))
(define (nsurl-path self)
  (wrap-objc-object
   (tell (coerce-arg self) path)))
(define (nsurl-path-components self)
  (wrap-objc-object
   (tell (coerce-arg self) pathComponents)))
(define (nsurl-path-extension self)
  (wrap-objc-object
   (tell (coerce-arg self) pathExtension)))
(define (nsurl-port self)
  (wrap-objc-object
   (tell (coerce-arg self) port)))
(define (nsurl-query self)
  (wrap-objc-object
   (tell (coerce-arg self) query)))
(define (nsurl-relative-path self)
  (wrap-objc-object
   (tell (coerce-arg self) relativePath)))
(define (nsurl-relative-string self)
  (wrap-objc-object
   (tell (coerce-arg self) relativeString)))
(define (nsurl-resource-specifier self)
  (wrap-objc-object
   (tell (coerce-arg self) resourceSpecifier)))
(define (nsurl-scheme self)
  (wrap-objc-object
   (tell (coerce-arg self) scheme)))
(define (nsurl-standardized-url self)
  (wrap-objc-object
   (tell (coerce-arg self) standardizedURL)))
(define (nsurl-user self)
  (wrap-objc-object
   (tell (coerce-arg self) user)))

;; --- Instance methods ---
(define (nsurl-bookmark-data-with-options-including-resource-values-for-keys-relative-to-url-error self options keys relative-url error)
  (wrap-objc-object
   (_msg-16 (coerce-arg self) (sel_registerName "bookmarkDataWithOptions:includingResourceValuesForKeys:relativeToURL:error:") options (coerce-arg keys) (coerce-arg relative-url) error)
   ))
(define (nsurl-copy-with-zone self zone)
  (wrap-objc-object
   (_msg-12 (coerce-arg self) (sel_registerName "copyWithZone:") zone)
   #:retained #t))
(define (nsurl-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nsurl-file-reference-url self)
  (wrap-objc-object
   (tell (coerce-arg self) fileReferenceURL)))
(define (nsurl-get-file-system-representation-max-length self buffer max-buffer-length)
  (_msg-14 (coerce-arg self) (sel_registerName "getFileSystemRepresentation:maxLength:") buffer max-buffer-length))
(define (nsurl-get-resource-value-for-key-error self value key error)
  (_msg-13 (coerce-arg self) (sel_registerName "getResourceValue:forKey:error:") value (coerce-arg key) error))
(define (nsurl-init-absolute-url-with-data-representation-relative-to-url self data base-url)
  (wrap-objc-object
   (tell (coerce-arg self) initAbsoluteURLWithDataRepresentation: (coerce-arg data) relativeToURL: (coerce-arg base-url))
   #:retained #t))
(define (nsurl-init-by-resolving-bookmark-data-options-relative-to-url-bookmark-data-is-stale-error self bookmark-data options relative-url is-stale error)
  (wrap-objc-object
   (_msg-10 (coerce-arg self) (sel_registerName "initByResolvingBookmarkData:options:relativeToURL:bookmarkDataIsStale:error:") (coerce-arg bookmark-data) options (coerce-arg relative-url) is-stale error)
   #:retained #t))
(define (nsurl-init-file-url-with-file-system-representation-is-directory-relative-to-url self path is-dir base-url)
  (wrap-objc-object
   (_msg-15 (coerce-arg self) (sel_registerName "initFileURLWithFileSystemRepresentation:isDirectory:relativeToURL:") path is-dir (coerce-arg base-url))
   #:retained #t))
(define (nsurl-init-file-url-with-path self path)
  (wrap-objc-object
   (tell (coerce-arg self) initFileURLWithPath: (coerce-arg path))
   #:retained #t))
(define (nsurl-init-file-url-with-path-is-directory self path is-dir)
  (wrap-objc-object
   (_msg-3 (coerce-arg self) (sel_registerName "initFileURLWithPath:isDirectory:") (coerce-arg path) is-dir)
   #:retained #t))
(define (nsurl-init-file-url-with-path-is-directory-relative-to-url self path is-dir base-url)
  (wrap-objc-object
   (_msg-4 (coerce-arg self) (sel_registerName "initFileURLWithPath:isDirectory:relativeToURL:") (coerce-arg path) is-dir (coerce-arg base-url))
   #:retained #t))
(define (nsurl-init-file-url-with-path-relative-to-url self path base-url)
  (wrap-objc-object
   (tell (coerce-arg self) initFileURLWithPath: (coerce-arg path) relativeToURL: (coerce-arg base-url))
   #:retained #t))
(define (nsurl-is-file-reference-url self)
  (_msg-0 (coerce-arg self) (sel_registerName "isFileReferenceURL")))
(define (nsurl-is-file-url self)
  (_msg-0 (coerce-arg self) (sel_registerName "isFileURL")))
(define (nsurl-item-provider-visibility-for-representation-with-type-identifier self type-identifier)
  (_msg-2 (coerce-arg self) (sel_registerName "itemProviderVisibilityForRepresentationWithTypeIdentifier:") (coerce-arg type-identifier)))
(define (nsurl-load-data-with-type-identifier-for-item-provider-completion-handler self type-identifier completion-handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block completion-handler (list _id _id) _void))
  (wrap-objc-object
   (_msg-9 (coerce-arg self) (sel_registerName "loadDataWithTypeIdentifier:forItemProviderCompletionHandler:") (coerce-arg type-identifier) _blk1)
   ))
(define (nsurl-remove-all-cached-resource-values! self)
  (tell #:type _void (coerce-arg self) removeAllCachedResourceValues))
(define (nsurl-remove-cached-resource-value-for-key! self key)
  (tell #:type _void (coerce-arg self) removeCachedResourceValueForKey: (coerce-arg key)))
(define (nsurl-resource-values-for-keys-error self keys error)
  (wrap-objc-object
   (_msg-9 (coerce-arg self) (sel_registerName "resourceValuesForKeys:error:") (coerce-arg keys) error)
   ))
(define (nsurl-set-resource-value-for-key-error! self value key error)
  (_msg-5 (coerce-arg self) (sel_registerName "setResourceValue:forKey:error:") (coerce-arg value) (coerce-arg key) error))
(define (nsurl-set-resource-values-error! self keyed-values error)
  (_msg-8 (coerce-arg self) (sel_registerName "setResourceValues:error:") (coerce-arg keyed-values) error))
(define (nsurl-set-temporary-resource-value-for-key! self value key)
  (tell #:type _void (coerce-arg self) setTemporaryResourceValue: (coerce-arg value) forKey: (coerce-arg key)))
(define (nsurl-start-accessing-security-scoped-resource self)
  (_msg-0 (coerce-arg self) (sel_registerName "startAccessingSecurityScopedResource")))
(define (nsurl-stop-accessing-security-scoped-resource self)
  (tell #:type _void (coerce-arg self) stopAccessingSecurityScopedResource))
(define (nsurl-writable-type-identifiers-for-item-provider self)
  (wrap-objc-object
   (tell (coerce-arg self) writableTypeIdentifiersForItemProvider)))

;; --- Class methods ---
(define (nsurl-url-by-resolving-alias-file-at-url-options-error url options error)
  (wrap-objc-object
   (_msg-11 NSURL (sel_registerName "URLByResolvingAliasFileAtURL:options:error:") (coerce-arg url) options error)
   ))
(define (nsurl-url-by-resolving-bookmark-data-options-relative-to-url-bookmark-data-is-stale-error bookmark-data options relative-url is-stale error)
  (wrap-objc-object
   (_msg-10 NSURL (sel_registerName "URLByResolvingBookmarkData:options:relativeToURL:bookmarkDataIsStale:error:") (coerce-arg bookmark-data) options (coerce-arg relative-url) is-stale error)
   ))
(define (nsurl-url-with-data-representation-relative-to-url data base-url)
  (wrap-objc-object
   (tell NSURL URLWithDataRepresentation: (coerce-arg data) relativeToURL: (coerce-arg base-url))))
(define (nsurl-url-with-string url-string)
  (wrap-objc-object
   (tell NSURL URLWithString: (coerce-arg url-string))))
(define (nsurl-url-with-string-encoding-invalid-characters url-string encoding-invalid-characters)
  (wrap-objc-object
   (_msg-3 NSURL (sel_registerName "URLWithString:encodingInvalidCharacters:") (coerce-arg url-string) encoding-invalid-characters)
   ))
(define (nsurl-url-with-string-relative-to-url url-string base-url)
  (wrap-objc-object
   (tell NSURL URLWithString: (coerce-arg url-string) relativeToURL: (coerce-arg base-url))))
(define (nsurl-absolute-url-with-data-representation-relative-to-url data base-url)
  (wrap-objc-object
   (tell NSURL absoluteURLWithDataRepresentation: (coerce-arg data) relativeToURL: (coerce-arg base-url))))
(define (nsurl-bookmark-data-with-contents-of-url-error bookmark-file-url error)
  (wrap-objc-object
   (_msg-9 NSURL (sel_registerName "bookmarkDataWithContentsOfURL:error:") (coerce-arg bookmark-file-url) error)
   ))
(define (nsurl-file-url-with-file-system-representation-is-directory-relative-to-url path is-dir base-url)
  (wrap-objc-object
   (_msg-15 NSURL (sel_registerName "fileURLWithFileSystemRepresentation:isDirectory:relativeToURL:") path is-dir (coerce-arg base-url))
   ))
(define (nsurl-file-url-with-path path)
  (wrap-objc-object
   (tell NSURL fileURLWithPath: (coerce-arg path))))
(define (nsurl-file-url-with-path-is-directory path is-dir)
  (wrap-objc-object
   (_msg-3 NSURL (sel_registerName "fileURLWithPath:isDirectory:") (coerce-arg path) is-dir)
   ))
(define (nsurl-file-url-with-path-is-directory-relative-to-url path is-dir base-url)
  (wrap-objc-object
   (_msg-4 NSURL (sel_registerName "fileURLWithPath:isDirectory:relativeToURL:") (coerce-arg path) is-dir (coerce-arg base-url))
   ))
(define (nsurl-file-url-with-path-relative-to-url path base-url)
  (wrap-objc-object
   (tell NSURL fileURLWithPath: (coerce-arg path) relativeToURL: (coerce-arg base-url))))
(define (nsurl-object-with-item-provider-data-type-identifier-error data type-identifier out-error)
  (wrap-objc-object
   (_msg-6 NSURL (sel_registerName "objectWithItemProviderData:typeIdentifier:error:") (coerce-arg data) (coerce-arg type-identifier) out-error)
   ))
(define (nsurl-readable-type-identifiers-for-item-provider)
  (wrap-objc-object
   (tell NSURL readableTypeIdentifiersForItemProvider)))
(define (nsurl-resource-values-for-keys-from-bookmark-data keys bookmark-data)
  (wrap-objc-object
   (tell NSURL resourceValuesForKeys: (coerce-arg keys) fromBookmarkData: (coerce-arg bookmark-data))))
(define (nsurl-supports-secure-coding)
  (_msg-0 NSURL (sel_registerName "supportsSecureCoding")))
(define (nsurl-write-bookmark-data-to-url-options-error bookmark-data bookmark-file-url options error)
  (_msg-7 NSURL (sel_registerName "writeBookmarkData:toURL:options:error:") (coerce-arg bookmark-data) (coerce-arg bookmark-file-url) options error))
