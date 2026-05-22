#lang racket/base
;; Generated binding for NSString (Foundation)
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
(define (dynamicself? v) (objc-instance-of? v "DynamicSelf"))
(define (nsprogress? v) (objc-instance-of? v "NSProgress"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (_playgroundquicklook? v) (objc-instance-of? v "_PlaygroundQuickLook"))
(provide NSString)
(provide/contract
  [make-nsstring-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [nsstring-utf8-string (c-> nsstring? (or/c string? #f))]
  [nsstring-absolute-path (c-> nsstring? boolean?)]
  [nsstring-available-string-encodings (c-> (or/c cpointer? #f))]
  [nsstring-bool-value (c-> nsstring? boolean?)]
  [nsstring-capitalized-string (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-custom-playground-quick-look (c-> nsstring? (or/c _playgroundquicklook? objc-nil?))]
  [nsstring-decomposed-string-with-canonical-mapping (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-decomposed-string-with-compatibility-mapping (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-default-c-string-encoding (c-> exact-nonnegative-integer?)]
  [nsstring-description (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-double-value (c-> nsstring? real?)]
  [nsstring-fastest-encoding (c-> nsstring? exact-nonnegative-integer?)]
  [nsstring-file-system-representation (c-> nsstring? (or/c string? #f))]
  [nsstring-float-value (c-> nsstring? real?)]
  [nsstring-hash (c-> nsstring? exact-nonnegative-integer?)]
  [nsstring-int-value (c-> nsstring? exact-integer?)]
  [nsstring-integer-value (c-> nsstring? exact-integer?)]
  [nsstring-last-path-component (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-length (c-> nsstring? exact-nonnegative-integer?)]
  [nsstring-localized-capitalized-string (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-localized-lowercase-string (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-localized-uppercase-string (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-long-long-value (c-> nsstring? exact-integer?)]
  [nsstring-lowercase-string (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-path-components (c-> nsstring? any/c)]
  [nsstring-path-extension (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-precomposed-string-with-canonical-mapping (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-precomposed-string-with-compatibility-mapping (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-smallest-encoding (c-> nsstring? exact-nonnegative-integer?)]
  [nsstring-string-by-abbreviating-with-tilde-in-path (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-string-by-deleting-last-path-component (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-string-by-deleting-path-extension (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-string-by-expanding-tilde-in-path (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-string-by-removing-percent-encoding (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-string-by-resolving-symlinks-in-path (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-string-by-standardizing-path (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-uppercase-string (c-> nsstring? (or/c nsstring? objc-nil?))]
  [nsstring-character-at-index (c-> nsstring? exact-nonnegative-integer? exact-nonnegative-integer?)]
  [nsstring-copy-with-zone (c-> nsstring? (or/c cpointer? #f) any/c)]
  [nsstring-encode-with-coder (c-> nsstring? (or/c string? objc-object? #f) void?)]
  [nsstring-item-provider-visibility-for-representation-with-type-identifier (c-> nsstring? (or/c string? objc-object? #f) exact-integer?)]
  [nsstring-load-data-with-type-identifier-for-item-provider-completion-handler (c-> nsstring? (or/c string? objc-object? #f) (or/c procedure? #f) (or/c nsprogress? objc-nil?))]
  [nsstring-mutable-copy-with-zone (c-> nsstring? (or/c cpointer? #f) any/c)]
  [nsstring-writable-type-identifiers-for-item-provider (c-> nsstring? any/c)]
  [nsstring-object-with-item-provider-data-type-identifier-error (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) any/c)]
  [nsstring-readable-type-identifiers-for-item-provider (c-> any/c)]
  [nsstring-supports-secure-coding (c-> boolean?)]
  )

;; --- Class reference ---
(import-class NSString)

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _bool)))
(define _msg-1  ; (_fun _pointer _pointer -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _uint64)))
(define _msg-2  ; (_fun _pointer _pointer _id -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _int64)))
(define _msg-3  ; (_fun _pointer _pointer _id _id _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _pointer -> _id)))
(define _msg-4  ; (_fun _pointer _pointer _id _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer -> _id)))
(define _msg-5  ; (_fun _pointer _pointer _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _id)))
(define _msg-6  ; (_fun _pointer _pointer _uint64 -> _uint16)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _uint16)))

;; --- Constructors ---
(define (make-nsstring-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSString alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))


;; --- Properties ---
(define (nsstring-utf8-string self)
  (tell #:type _string (coerce-arg self) UTF8String))
(define (nsstring-absolute-path self)
  (tell #:type _bool (coerce-arg self) absolutePath))
(define (nsstring-available-string-encodings)
  (tell #:type _pointer NSString availableStringEncodings))
(define (nsstring-bool-value self)
  (tell #:type _bool (coerce-arg self) boolValue))
(define (nsstring-capitalized-string self)
  (wrap-objc-object
   (tell (coerce-arg self) capitalizedString)))
(define (nsstring-custom-playground-quick-look self)
  (wrap-objc-object
   (tell (coerce-arg self) customPlaygroundQuickLook)))
(define (nsstring-decomposed-string-with-canonical-mapping self)
  (wrap-objc-object
   (tell (coerce-arg self) decomposedStringWithCanonicalMapping)))
(define (nsstring-decomposed-string-with-compatibility-mapping self)
  (wrap-objc-object
   (tell (coerce-arg self) decomposedStringWithCompatibilityMapping)))
(define (nsstring-default-c-string-encoding)
  (tell #:type _uint64 NSString defaultCStringEncoding))
(define (nsstring-description self)
  (wrap-objc-object
   (tell (coerce-arg self) description)))
(define (nsstring-double-value self)
  (tell #:type _double (coerce-arg self) doubleValue))
(define (nsstring-fastest-encoding self)
  (tell #:type _uint64 (coerce-arg self) fastestEncoding))
(define (nsstring-file-system-representation self)
  (tell #:type _string (coerce-arg self) fileSystemRepresentation))
(define (nsstring-float-value self)
  (tell #:type _float (coerce-arg self) floatValue))
(define (nsstring-hash self)
  (tell #:type _uint64 (coerce-arg self) hash))
(define (nsstring-int-value self)
  (tell #:type _int32 (coerce-arg self) intValue))
(define (nsstring-integer-value self)
  (tell #:type _int64 (coerce-arg self) integerValue))
(define (nsstring-last-path-component self)
  (wrap-objc-object
   (tell (coerce-arg self) lastPathComponent)))
(define (nsstring-length self)
  (tell #:type _uint64 (coerce-arg self) length))
(define (nsstring-localized-capitalized-string self)
  (wrap-objc-object
   (tell (coerce-arg self) localizedCapitalizedString)))
(define (nsstring-localized-lowercase-string self)
  (wrap-objc-object
   (tell (coerce-arg self) localizedLowercaseString)))
(define (nsstring-localized-uppercase-string self)
  (wrap-objc-object
   (tell (coerce-arg self) localizedUppercaseString)))
(define (nsstring-long-long-value self)
  (tell #:type _int64 (coerce-arg self) longLongValue))
(define (nsstring-lowercase-string self)
  (wrap-objc-object
   (tell (coerce-arg self) lowercaseString)))
(define (nsstring-path-components self)
  (wrap-objc-object
   (tell (coerce-arg self) pathComponents)))
(define (nsstring-path-extension self)
  (wrap-objc-object
   (tell (coerce-arg self) pathExtension)))
(define (nsstring-precomposed-string-with-canonical-mapping self)
  (wrap-objc-object
   (tell (coerce-arg self) precomposedStringWithCanonicalMapping)))
(define (nsstring-precomposed-string-with-compatibility-mapping self)
  (wrap-objc-object
   (tell (coerce-arg self) precomposedStringWithCompatibilityMapping)))
(define (nsstring-smallest-encoding self)
  (tell #:type _uint64 (coerce-arg self) smallestEncoding))
(define (nsstring-string-by-abbreviating-with-tilde-in-path self)
  (wrap-objc-object
   (tell (coerce-arg self) stringByAbbreviatingWithTildeInPath)))
(define (nsstring-string-by-deleting-last-path-component self)
  (wrap-objc-object
   (tell (coerce-arg self) stringByDeletingLastPathComponent)))
(define (nsstring-string-by-deleting-path-extension self)
  (wrap-objc-object
   (tell (coerce-arg self) stringByDeletingPathExtension)))
(define (nsstring-string-by-expanding-tilde-in-path self)
  (wrap-objc-object
   (tell (coerce-arg self) stringByExpandingTildeInPath)))
(define (nsstring-string-by-removing-percent-encoding self)
  (wrap-objc-object
   (tell (coerce-arg self) stringByRemovingPercentEncoding)))
(define (nsstring-string-by-resolving-symlinks-in-path self)
  (wrap-objc-object
   (tell (coerce-arg self) stringByResolvingSymlinksInPath)))
(define (nsstring-string-by-standardizing-path self)
  (wrap-objc-object
   (tell (coerce-arg self) stringByStandardizingPath)))
(define (nsstring-uppercase-string self)
  (wrap-objc-object
   (tell (coerce-arg self) uppercaseString)))

;; --- Instance methods ---
(define (nsstring-character-at-index self index)
  (_msg-6 (coerce-arg self) (sel_registerName "characterAtIndex:") index))
(define (nsstring-copy-with-zone self zone)
  (wrap-objc-object
   (_msg-5 (coerce-arg self) (sel_registerName "copyWithZone:") zone)
   #:retained #t))
(define (nsstring-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nsstring-item-provider-visibility-for-representation-with-type-identifier self type-identifier)
  (_msg-2 (coerce-arg self) (sel_registerName "itemProviderVisibilityForRepresentationWithTypeIdentifier:") (coerce-arg type-identifier)))
;; block param 1: async-copied (runtime-managed)
(define (nsstring-load-data-with-type-identifier-for-item-provider-completion-handler self type-identifier completion-handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block completion-handler (list _id _id) _void))
  (wrap-objc-object
   (_msg-4 (coerce-arg self) (sel_registerName "loadDataWithTypeIdentifier:forItemProviderCompletionHandler:") (coerce-arg type-identifier) _blk1)
   ))
(define (nsstring-mutable-copy-with-zone self zone)
  (wrap-objc-object
   (_msg-5 (coerce-arg self) (sel_registerName "mutableCopyWithZone:") zone)
   #:retained #t))
(define (nsstring-writable-type-identifiers-for-item-provider self)
  (wrap-objc-object
   (tell (coerce-arg self) writableTypeIdentifiersForItemProvider)))

;; --- Class methods ---
;; NSError out-param: result-or-error wrapper candidate
(define (nsstring-object-with-item-provider-data-type-identifier-error data type-identifier out-error)
  (wrap-objc-object
   (_msg-3 NSString (sel_registerName "objectWithItemProviderData:typeIdentifier:error:") (coerce-arg data) (coerce-arg type-identifier) out-error)
   ))
(define (nsstring-readable-type-identifiers-for-item-provider)
  (wrap-objc-object
   (tell NSString readableTypeIdentifiersForItemProvider)))
(define (nsstring-supports-secure-coding)
  (_msg-0 NSString (sel_registerName "supportsSecureCoding")))
