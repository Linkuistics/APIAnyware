#lang racket/base
;; Generated binding for NSString (Foundation)
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
  [nsstring-object-with-item-provider-data-type-identifier-error (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (values any/c (or/c objc-object? #f)))]
  [nsstring-readable-type-identifiers-for-item-provider (c-> any/c)]
  [nsstring-supports-secure-coding (c-> boolean?)]
  )

;; --- Class reference ---
(import-class NSString)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_N (-> ptr_t ptr_t string_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_i (-> ptr_t ptr_t int32_t))
(define-aw-msg aw_racket_msg_0_q (-> ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_0_Q (-> ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_0_f (-> ptr_t ptr_t float_t))
(define-aw-msg aw_racket_msg_0_d (-> ptr_t ptr_t double_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_q (-> ptr_t ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_P_e (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_Q_S (-> ptr_t ptr_t uint64_t uint16_t))

;; --- Constructors ---
(define (make-nsstring-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSString alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))


;; --- Properties ---
(define (nsstring-utf8-string self)
  (aw_racket_msg_0_N (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "UTF8String"))))
(define (nsstring-absolute-path self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "absolutePath"))))
(define (nsstring-available-string-encodings)
  (ptr_t->cpointer (aw_racket_msg_0_P (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "availableStringEncodings")))))
(define (nsstring-bool-value self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "boolValue"))))
(define (nsstring-capitalized-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "capitalizedString"))))))
(define (nsstring-custom-playground-quick-look self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "customPlaygroundQuickLook"))))))
(define (nsstring-decomposed-string-with-canonical-mapping self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "decomposedStringWithCanonicalMapping"))))))
(define (nsstring-decomposed-string-with-compatibility-mapping self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "decomposedStringWithCompatibilityMapping"))))))
(define (nsstring-default-c-string-encoding)
  (aw_racket_msg_0_Q (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "defaultCStringEncoding"))))
(define (nsstring-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "description"))))))
(define (nsstring-double-value self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "doubleValue"))))
(define (nsstring-fastest-encoding self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fastestEncoding"))))
(define (nsstring-file-system-representation self)
  (aw_racket_msg_0_N (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fileSystemRepresentation"))))
(define (nsstring-float-value self)
  (aw_racket_msg_0_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "floatValue"))))
(define (nsstring-hash self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hash"))))
(define (nsstring-int-value self)
  (aw_racket_msg_0_i (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "intValue"))))
(define (nsstring-integer-value self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "integerValue"))))
(define (nsstring-last-path-component self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastPathComponent"))))))
(define (nsstring-length self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "length"))))
(define (nsstring-localized-capitalized-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "localizedCapitalizedString"))))))
(define (nsstring-localized-lowercase-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "localizedLowercaseString"))))))
(define (nsstring-localized-uppercase-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "localizedUppercaseString"))))))
(define (nsstring-long-long-value self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "longLongValue"))))
(define (nsstring-lowercase-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lowercaseString"))))))
(define (nsstring-path-components self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pathComponents"))))))
(define (nsstring-path-extension self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pathExtension"))))))
(define (nsstring-precomposed-string-with-canonical-mapping self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "precomposedStringWithCanonicalMapping"))))))
(define (nsstring-precomposed-string-with-compatibility-mapping self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "precomposedStringWithCompatibilityMapping"))))))
(define (nsstring-smallest-encoding self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "smallestEncoding"))))
(define (nsstring-string-by-abbreviating-with-tilde-in-path self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByAbbreviatingWithTildeInPath"))))))
(define (nsstring-string-by-deleting-last-path-component self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByDeletingLastPathComponent"))))))
(define (nsstring-string-by-deleting-path-extension self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByDeletingPathExtension"))))))
(define (nsstring-string-by-expanding-tilde-in-path self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByExpandingTildeInPath"))))))
(define (nsstring-string-by-removing-percent-encoding self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByRemovingPercentEncoding"))))))
(define (nsstring-string-by-resolving-symlinks-in-path self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByResolvingSymlinksInPath"))))))
(define (nsstring-string-by-standardizing-path self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringByStandardizingPath"))))))
(define (nsstring-uppercase-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "uppercaseString"))))))

;; --- Instance methods ---
(define (nsstring-character-at-index self index)
  (aw_racket_msg_Q_S (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "characterAtIndex:")) index))
(define (nsstring-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "copyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))
(define (nsstring-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nsstring-item-provider-visibility-for-representation-with-type-identifier self type-identifier)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "itemProviderVisibilityForRepresentationWithTypeIdentifier:")) (id->ffi2-ptr (coerce-arg type-identifier))))
;; block param 1: async-copied (runtime-managed)
(define (nsstring-load-data-with-type-identifier-for-item-provider-completion-handler self type-identifier completion-handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block completion-handler (list _id _id) _void))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "loadDataWithTypeIdentifier:forItemProviderCompletionHandler:")) (id->ffi2-ptr (coerce-arg type-identifier)) (id->ffi2-ptr _blk1)))
   ))
(define (nsstring-mutable-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mutableCopyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))
(define (nsstring-writable-type-identifiers-for-item-provider self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writableTypeIdentifiersForItemProvider"))))
   ))

;; --- Class methods ---
;; NSError out-param: result-or-error wrapper candidate
(define (nsstring-object-with-item-provider-data-type-identifier-error data type-identifier)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_P_e (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "objectWithItemProviderData:typeIdentifier:error:")) (id->ffi2-ptr (coerce-arg data)) (id->ffi2-ptr (coerce-arg type-identifier)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsstring-readable-type-identifiers-for-item-provider)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "readableTypeIdentifiersForItemProvider"))))
   ))
(define (nsstring-supports-secure-coding)
  (aw_racket_msg_0_b (id->ffi2-ptr NSString) (id->ffi2-ptr (sel_registerName "supportsSecureCoding"))))
