#lang racket/base
;; Generated binding for NSImage (AppKit)
;; Do not edit — regenerate from enriched IR

(require ffi/unsafe
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../runtime/objc-base.rkt"
         "../../runtime/coerce.rkt"
         "../../runtime/block.rkt"
         "../../runtime/type-mapping.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/AppKit.framework/AppKit"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nscolor? v) (objc-instance-of? v "NSColor"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsimage? v) (objc-instance-of? v "NSImage"))
(define (nsimagerep? v) (objc-instance-of? v "NSImageRep"))
(define (nsimagesymbolconfiguration? v) (objc-instance-of? v "NSImageSymbolConfiguration"))
(define (nslocale? v) (objc-instance-of? v "NSLocale"))
(define (nsprogress? v) (objc-instance-of? v "NSProgress"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (nsurl? v) (objc-instance-of? v "NSURL"))
(define (opaquetypearchetype? v) (objc-instance-of? v "OpaqueTypeArchetype"))
(provide NSImage)
(provide/contract
  [make-nsimage-init-with-cg-image-size (c-> (or/c cpointer? #f) any/c any/c)]
  [make-nsimage-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsimage-init-with-contents-of-file (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsimage-init-with-contents-of-url (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsimage-init-with-data (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsimage-init-with-data-ignoring-orientation (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsimage-init-with-pasteboard (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsimage-init-with-pasteboard-property-list-of-type (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [make-nsimage-init-with-size (c-> any/c any/c)]
  [nsimage-tiff-representation (c-> nsimage? (or/c nsdata? objc-nil?))]
  [nsimage-accessibility-description (c-> nsimage? (or/c nsstring? objc-nil?))]
  [nsimage-set-accessibility-description! (c-> nsimage? (or/c string? objc-object? #f) void?)]
  [nsimage-alignment-rect (c-> nsimage? any/c)]
  [nsimage-set-alignment-rect! (c-> nsimage? any/c void?)]
  [nsimage-background-color (c-> nsimage? (or/c nscolor? objc-nil?))]
  [nsimage-set-background-color! (c-> nsimage? (or/c string? objc-object? #f) void?)]
  [nsimage-cache-mode (c-> nsimage? exact-nonnegative-integer?)]
  [nsimage-set-cache-mode! (c-> nsimage? exact-nonnegative-integer? void?)]
  [nsimage-cap-insets (c-> nsimage? any/c)]
  [nsimage-set-cap-insets! (c-> nsimage? any/c void?)]
  [nsimage-delegate (c-> nsimage? any/c)]
  [nsimage-set-delegate! (c-> nsimage? (or/c string? objc-object? #f) void?)]
  [nsimage-image-types (c-> any/c)]
  [nsimage-image-unfiltered-types (c-> any/c)]
  [nsimage-locale (c-> nsimage? (or/c nslocale? objc-nil?))]
  [nsimage-matches-on-multiple-resolution (c-> nsimage? boolean?)]
  [nsimage-set-matches-on-multiple-resolution! (c-> nsimage? boolean? void?)]
  [nsimage-matches-only-on-best-fitting-axis (c-> nsimage? boolean?)]
  [nsimage-set-matches-only-on-best-fitting-axis! (c-> nsimage? boolean? void?)]
  [nsimage-prefers-color-match (c-> nsimage? boolean?)]
  [nsimage-set-prefers-color-match! (c-> nsimage? boolean? void?)]
  [nsimage-representations (c-> nsimage? any/c)]
  [nsimage-resizing-mode (c-> nsimage? exact-integer?)]
  [nsimage-set-resizing-mode! (c-> nsimage? exact-integer? void?)]
  [nsimage-size (c-> nsimage? any/c)]
  [nsimage-set-size! (c-> nsimage? any/c void?)]
  [nsimage-symbol-configuration (c-> nsimage? (or/c nsimagesymbolconfiguration? objc-nil?))]
  [nsimage-template (c-> nsimage? boolean?)]
  [nsimage-set-template! (c-> nsimage? boolean? void?)]
  [nsimage-transfer-representation (c-> (or/c opaquetypearchetype? objc-nil?))]
  [nsimage-uses-eps-on-resolution-mismatch (c-> nsimage? boolean?)]
  [nsimage-set-uses-eps-on-resolution-mismatch! (c-> nsimage? boolean? void?)]
  [nsimage-valid (c-> nsimage? boolean?)]
  [nsimage-cg-image-for-proposed-rect-context-hints (c-> nsimage? (or/c cpointer? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f))]
  [nsimage-tiff-representation-using-compression-factor (c-> nsimage? exact-nonnegative-integer? real? (or/c nsdata? objc-nil?))]
  [nsimage-add-representation! (c-> nsimage? (or/c string? objc-object? #f) void?)]
  [nsimage-add-representations! (c-> nsimage? (or/c string? objc-object? #f) void?)]
  [nsimage-best-representation-for-rect-context-hints (c-> nsimage? any/c (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c nsimagerep? objc-nil?))]
  [nsimage-copy-with-zone (c-> nsimage? (or/c cpointer? #f) any/c)]
  [nsimage-draw-at-point-from-rect-operation-fraction (c-> nsimage? any/c any/c exact-nonnegative-integer? real? void?)]
  [nsimage-draw-in-rect (c-> nsimage? any/c void?)]
  [nsimage-draw-in-rect-from-rect-operation-fraction (c-> nsimage? any/c any/c exact-nonnegative-integer? real? void?)]
  [nsimage-draw-in-rect-from-rect-operation-fraction-respect-flipped-hints (c-> nsimage? any/c any/c exact-nonnegative-integer? real? boolean? (or/c string? objc-object? #f) void?)]
  [nsimage-draw-representation-in-rect (c-> nsimage? (or/c string? objc-object? #f) any/c boolean?)]
  [nsimage-encode-with-coder (c-> nsimage? (or/c string? objc-object? #f) void?)]
  [nsimage-hit-test-rect-with-image-destination-rect-context-hints-flipped (c-> nsimage? any/c any/c (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean? boolean?)]
  [nsimage-image-with-locale (c-> nsimage? (or/c string? objc-object? #f) (or/c nsimage? objc-nil?))]
  [nsimage-image-with-symbol-configuration (c-> nsimage? (or/c string? objc-object? #f) (or/c nsimage? objc-nil?))]
  [nsimage-imported-content-types (c-> nsimage? (or/c nsarray? objc-nil?))]
  [nsimage-init-by-referencing-file (c-> nsimage? (or/c string? objc-object? #f) any/c)]
  [nsimage-init-by-referencing-url (c-> nsimage? (or/c string? objc-object? #f) any/c)]
  [nsimage-is-template (c-> nsimage? boolean?)]
  [nsimage-is-valid (c-> nsimage? boolean?)]
  [nsimage-item-provider-visibility-for-representation-with-type-identifier (c-> nsimage? (or/c string? objc-object? #f) exact-integer?)]
  [nsimage-layer-contents-for-contents-scale (c-> nsimage? real? any/c)]
  [nsimage-load-data-with-type-identifier-for-item-provider-completion-handler (c-> nsimage? (or/c string? objc-object? #f) (or/c procedure? #f) (or/c nsprogress? objc-nil?))]
  [nsimage-name (c-> nsimage? (or/c nsstring? objc-nil?))]
  [nsimage-pasteboard-property-list-for-type (c-> nsimage? (or/c string? objc-object? #f) any/c)]
  [nsimage-recache (c-> nsimage? void?)]
  [nsimage-recommended-layer-contents-scale (c-> nsimage? real? real?)]
  [nsimage-remove-representation! (c-> nsimage? (or/c string? objc-object? #f) void?)]
  [nsimage-set-name! (c-> nsimage? (or/c string? objc-object? #f) boolean?)]
  [nsimage-writable-type-identifiers-for-item-provider (c-> nsimage? any/c)]
  [nsimage-writable-types-for-pasteboard (c-> nsimage? (or/c string? objc-object? #f) any/c)]
  [nsimage-writing-options-for-type-pasteboard (c-> nsimage? (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nsimage-can-init-with-pasteboard (c-> (or/c string? objc-object? #f) boolean?)]
  [nsimage-image-named (c-> (or/c string? objc-object? #f) (or/c nsimage? objc-nil?))]
  [nsimage-image-with-size-flipped-drawing-handler (c-> any/c boolean? (or/c procedure? #f) any/c)]
  [nsimage-image-with-symbol-name-bundle-variable-value (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) real? any/c)]
  [nsimage-image-with-symbol-name-variable-value (c-> (or/c string? objc-object? #f) real? any/c)]
  [nsimage-image-with-system-symbol-name-accessibility-description (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nsimage-image-with-system-symbol-name-variable-value-accessibility-description (c-> (or/c string? objc-object? #f) real? (or/c string? objc-object? #f) any/c)]
  [nsimage-object-with-item-provider-data-type-identifier-error (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) any/c)]
  [nsimage-readable-type-identifiers-for-item-provider (c-> any/c)]
  [nsimage-readable-types-for-pasteboard (c-> (or/c string? objc-object? #f) any/c)]
  [nsimage-reading-options-for-type-pasteboard (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nsimage-supports-secure-coding (c-> boolean?)]
  )

;; --- Class reference ---
(import-class NSImage)

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer -> _NSEdgeInsets)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _NSEdgeInsets)))
(define _msg-1  ; (_fun _pointer _pointer -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _NSRect)))
(define _msg-2  ; (_fun _pointer _pointer -> _NSSize)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _NSSize)))
(define _msg-3  ; (_fun _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _bool)))
(define _msg-4  ; (_fun _pointer _pointer -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _int64)))
(define _msg-5  ; (_fun _pointer _pointer -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _uint64)))
(define _msg-6  ; (_fun _pointer _pointer _NSEdgeInsets -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSEdgeInsets -> _void)))
(define _msg-7  ; (_fun _pointer _pointer _NSPoint _NSRect _uint64 _double -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint _NSRect _uint64 _double -> _void)))
(define _msg-8  ; (_fun _pointer _pointer _NSRect -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _void)))
(define _msg-9  ; (_fun _pointer _pointer _NSRect _NSRect _id _id _bool -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _NSRect _id _id _bool -> _bool)))
(define _msg-10  ; (_fun _pointer _pointer _NSRect _NSRect _uint64 _double -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _NSRect _uint64 _double -> _void)))
(define _msg-11  ; (_fun _pointer _pointer _NSRect _NSRect _uint64 _double _bool _id -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _NSRect _uint64 _double _bool _id -> _void)))
(define _msg-12  ; (_fun _pointer _pointer _NSRect _id _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id _id -> _id)))
(define _msg-13  ; (_fun _pointer _pointer _NSSize -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize -> _id)))
(define _msg-14  ; (_fun _pointer _pointer _NSSize -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize -> _void)))
(define _msg-15  ; (_fun _pointer _pointer _NSSize _bool _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize _bool _pointer -> _id)))
(define _msg-16  ; (_fun _pointer _pointer _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _bool -> _void)))
(define _msg-17  ; (_fun _pointer _pointer _double -> _double)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double -> _double)))
(define _msg-18  ; (_fun _pointer _pointer _double -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double -> _id)))
(define _msg-19  ; (_fun _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _bool)))
(define _msg-20  ; (_fun _pointer _pointer _id -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _int64)))
(define _msg-21  ; (_fun _pointer _pointer _id _NSRect -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _NSRect -> _bool)))
(define _msg-22  ; (_fun _pointer _pointer _id _double -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _double -> _id)))
(define _msg-23  ; (_fun _pointer _pointer _id _double _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _double _id -> _id)))
(define _msg-24  ; (_fun _pointer _pointer _id _id -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id -> _uint64)))
(define _msg-25  ; (_fun _pointer _pointer _id _id _double -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _double -> _id)))
(define _msg-26  ; (_fun _pointer _pointer _id _id _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _pointer -> _id)))
(define _msg-27  ; (_fun _pointer _pointer _id _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer -> _id)))
(define _msg-28  ; (_fun _pointer _pointer _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _void)))
(define _msg-29  ; (_fun _pointer _pointer _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _id)))
(define _msg-30  ; (_fun _pointer _pointer _pointer _NSSize -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _NSSize -> _id)))
(define _msg-31  ; (_fun _pointer _pointer _pointer _id _id -> _pointer)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id _id -> _pointer)))
(define _msg-32  ; (_fun _pointer _pointer _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _void)))
(define _msg-33  ; (_fun _pointer _pointer _uint64 _float -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 _float -> _id)))

;; --- Constructors ---
(define (make-nsimage-init-with-cg-image-size cg-image size)
  (wrap-objc-object
   (_msg-30 (tell NSImage alloc)
       (sel_registerName "initWithCGImage:size:")
       cg-image
       size)
   #:retained #t))

(define (make-nsimage-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSImage alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nsimage-init-with-contents-of-file file-name)
  (wrap-objc-object
   (tell (tell NSImage alloc)
         initWithContentsOfFile: (coerce-arg file-name))
   #:retained #t))

(define (make-nsimage-init-with-contents-of-url url)
  (wrap-objc-object
   (tell (tell NSImage alloc)
         initWithContentsOfURL: (coerce-arg url))
   #:retained #t))

(define (make-nsimage-init-with-data data)
  (wrap-objc-object
   (tell (tell NSImage alloc)
         initWithData: (coerce-arg data))
   #:retained #t))

(define (make-nsimage-init-with-data-ignoring-orientation data)
  (wrap-objc-object
   (tell (tell NSImage alloc)
         initWithDataIgnoringOrientation: (coerce-arg data))
   #:retained #t))

(define (make-nsimage-init-with-pasteboard pasteboard)
  (wrap-objc-object
   (tell (tell NSImage alloc)
         initWithPasteboard: (coerce-arg pasteboard))
   #:retained #t))

(define (make-nsimage-init-with-pasteboard-property-list-of-type property-list type)
  (wrap-objc-object
   (tell (tell NSImage alloc)
         initWithPasteboardPropertyList: (coerce-arg property-list) ofType: (coerce-arg type))
   #:retained #t))

(define (make-nsimage-init-with-size size)
  (wrap-objc-object
   (_msg-13 (tell NSImage alloc)
       (sel_registerName "initWithSize:")
       size)
   #:retained #t))


;; --- Properties ---
(define (nsimage-tiff-representation self)
  (wrap-objc-object
   (tell (coerce-arg self) TIFFRepresentation)))
(define (nsimage-accessibility-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDescription)))
(define (nsimage-set-accessibility-description! self value)
  (tell #:type _void (coerce-arg self) setAccessibilityDescription: (coerce-arg value)))
(define (nsimage-alignment-rect self)
  (tell #:type _NSRect (coerce-arg self) alignmentRect))
(define (nsimage-set-alignment-rect! self value)
  (_msg-8 (coerce-arg self) (sel_registerName "setAlignmentRect:") value))
(define (nsimage-background-color self)
  (wrap-objc-object
   (tell (coerce-arg self) backgroundColor)))
(define (nsimage-set-background-color! self value)
  (tell #:type _void (coerce-arg self) setBackgroundColor: (coerce-arg value)))
(define (nsimage-cache-mode self)
  (tell #:type _uint64 (coerce-arg self) cacheMode))
(define (nsimage-set-cache-mode! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setCacheMode:") value))
(define (nsimage-cap-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) capInsets))
(define (nsimage-set-cap-insets! self value)
  (_msg-6 (coerce-arg self) (sel_registerName "setCapInsets:") value))
(define (nsimage-delegate self)
  (wrap-objc-object
   (tell (coerce-arg self) delegate)))
(define (nsimage-set-delegate! self value)
  (tell #:type _void (coerce-arg self) setDelegate: (coerce-arg value)))
(define (nsimage-image-types)
  (wrap-objc-object
   (tell NSImage imageTypes)))
(define (nsimage-image-unfiltered-types)
  (wrap-objc-object
   (tell NSImage imageUnfilteredTypes)))
(define (nsimage-locale self)
  (wrap-objc-object
   (tell (coerce-arg self) locale)))
(define (nsimage-matches-on-multiple-resolution self)
  (tell #:type _bool (coerce-arg self) matchesOnMultipleResolution))
(define (nsimage-set-matches-on-multiple-resolution! self value)
  (_msg-16 (coerce-arg self) (sel_registerName "setMatchesOnMultipleResolution:") value))
(define (nsimage-matches-only-on-best-fitting-axis self)
  (tell #:type _bool (coerce-arg self) matchesOnlyOnBestFittingAxis))
(define (nsimage-set-matches-only-on-best-fitting-axis! self value)
  (_msg-16 (coerce-arg self) (sel_registerName "setMatchesOnlyOnBestFittingAxis:") value))
(define (nsimage-prefers-color-match self)
  (tell #:type _bool (coerce-arg self) prefersColorMatch))
(define (nsimage-set-prefers-color-match! self value)
  (_msg-16 (coerce-arg self) (sel_registerName "setPrefersColorMatch:") value))
(define (nsimage-representations self)
  (wrap-objc-object
   (tell (coerce-arg self) representations)))
(define (nsimage-resizing-mode self)
  (tell #:type _int64 (coerce-arg self) resizingMode))
(define (nsimage-set-resizing-mode! self value)
  (_msg-28 (coerce-arg self) (sel_registerName "setResizingMode:") value))
(define (nsimage-size self)
  (tell #:type _NSSize (coerce-arg self) size))
(define (nsimage-set-size! self value)
  (_msg-14 (coerce-arg self) (sel_registerName "setSize:") value))
(define (nsimage-symbol-configuration self)
  (wrap-objc-object
   (tell (coerce-arg self) symbolConfiguration)))
(define (nsimage-template self)
  (tell #:type _bool (coerce-arg self) template))
(define (nsimage-set-template! self value)
  (_msg-16 (coerce-arg self) (sel_registerName "setTemplate:") value))
(define (nsimage-transfer-representation)
  (wrap-objc-object
   (tell NSImage transferRepresentation)))
(define (nsimage-uses-eps-on-resolution-mismatch self)
  (tell #:type _bool (coerce-arg self) usesEPSOnResolutionMismatch))
(define (nsimage-set-uses-eps-on-resolution-mismatch! self value)
  (_msg-16 (coerce-arg self) (sel_registerName "setUsesEPSOnResolutionMismatch:") value))
(define (nsimage-valid self)
  (tell #:type _bool (coerce-arg self) valid))

;; --- Instance methods ---
(define (nsimage-cg-image-for-proposed-rect-context-hints self proposed-dest-rect reference-context hints)
  (_msg-31 (coerce-arg self) (sel_registerName "CGImageForProposedRect:context:hints:") proposed-dest-rect (coerce-arg reference-context) (coerce-arg hints)))
(define (nsimage-tiff-representation-using-compression-factor self comp factor)
  (wrap-objc-object
   (_msg-33 (coerce-arg self) (sel_registerName "TIFFRepresentationUsingCompression:factor:") comp factor)
   ))
(define (nsimage-add-representation! self image-rep)
  (tell #:type _void (coerce-arg self) addRepresentation: (coerce-arg image-rep)))
(define (nsimage-add-representations! self image-reps)
  (tell #:type _void (coerce-arg self) addRepresentations: (coerce-arg image-reps)))
(define (nsimage-best-representation-for-rect-context-hints self rect reference-context hints)
  (wrap-objc-object
   (_msg-12 (coerce-arg self) (sel_registerName "bestRepresentationForRect:context:hints:") rect (coerce-arg reference-context) (coerce-arg hints))
   ))
(define (nsimage-copy-with-zone self zone)
  (wrap-objc-object
   (_msg-29 (coerce-arg self) (sel_registerName "copyWithZone:") zone)
   #:retained #t))
(define (nsimage-draw-at-point-from-rect-operation-fraction self point from-rect op delta)
  (_msg-7 (coerce-arg self) (sel_registerName "drawAtPoint:fromRect:operation:fraction:") point from-rect op delta))
(define (nsimage-draw-in-rect self rect)
  (_msg-8 (coerce-arg self) (sel_registerName "drawInRect:") rect))
(define (nsimage-draw-in-rect-from-rect-operation-fraction self rect from-rect op delta)
  (_msg-10 (coerce-arg self) (sel_registerName "drawInRect:fromRect:operation:fraction:") rect from-rect op delta))
(define (nsimage-draw-in-rect-from-rect-operation-fraction-respect-flipped-hints self dst-space-portion-rect src-space-portion-rect op requested-alpha respect-context-is-flipped hints)
  (_msg-11 (coerce-arg self) (sel_registerName "drawInRect:fromRect:operation:fraction:respectFlipped:hints:") dst-space-portion-rect src-space-portion-rect op requested-alpha respect-context-is-flipped (coerce-arg hints)))
(define (nsimage-draw-representation-in-rect self image-rep rect)
  (_msg-21 (coerce-arg self) (sel_registerName "drawRepresentation:inRect:") (coerce-arg image-rep) rect))
(define (nsimage-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nsimage-hit-test-rect-with-image-destination-rect-context-hints-flipped self test-rect-dest-space image-rect-dest-space context hints flipped)
  (_msg-9 (coerce-arg self) (sel_registerName "hitTestRect:withImageDestinationRect:context:hints:flipped:") test-rect-dest-space image-rect-dest-space (coerce-arg context) (coerce-arg hints) flipped))
(define (nsimage-image-with-locale self locale)
  (wrap-objc-object
   (tell (coerce-arg self) imageWithLocale: (coerce-arg locale))))
(define (nsimage-image-with-symbol-configuration self configuration)
  (wrap-objc-object
   (tell (coerce-arg self) imageWithSymbolConfiguration: (coerce-arg configuration))))
(define (nsimage-imported-content-types self)
  (wrap-objc-object
   (tell (coerce-arg self) importedContentTypes)))
(define (nsimage-init-by-referencing-file self file-name)
  (wrap-objc-object
   (tell (coerce-arg self) initByReferencingFile: (coerce-arg file-name))
   #:retained #t))
(define (nsimage-init-by-referencing-url self url)
  (wrap-objc-object
   (tell (coerce-arg self) initByReferencingURL: (coerce-arg url))
   #:retained #t))
(define (nsimage-is-template self)
  (_msg-3 (coerce-arg self) (sel_registerName "isTemplate")))
(define (nsimage-is-valid self)
  (_msg-3 (coerce-arg self) (sel_registerName "isValid")))
(define (nsimage-item-provider-visibility-for-representation-with-type-identifier self type-identifier)
  (_msg-20 (coerce-arg self) (sel_registerName "itemProviderVisibilityForRepresentationWithTypeIdentifier:") (coerce-arg type-identifier)))
(define (nsimage-layer-contents-for-contents-scale self layer-contents-scale)
  (wrap-objc-object
   (_msg-18 (coerce-arg self) (sel_registerName "layerContentsForContentsScale:") layer-contents-scale)
   ))
;; block param 1: async-copied (runtime-managed)
(define (nsimage-load-data-with-type-identifier-for-item-provider-completion-handler self type-identifier completion-handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block completion-handler (list _id _id) _void))
  (wrap-objc-object
   (_msg-27 (coerce-arg self) (sel_registerName "loadDataWithTypeIdentifier:forItemProviderCompletionHandler:") (coerce-arg type-identifier) _blk1)
   ))
(define (nsimage-name self)
  (wrap-objc-object
   (tell (coerce-arg self) name)))
(define (nsimage-pasteboard-property-list-for-type self type)
  (wrap-objc-object
   (tell (coerce-arg self) pasteboardPropertyListForType: (coerce-arg type))))
(define (nsimage-recache self)
  (tell #:type _void (coerce-arg self) recache))
(define (nsimage-recommended-layer-contents-scale self preferred-contents-scale)
  (_msg-17 (coerce-arg self) (sel_registerName "recommendedLayerContentsScale:") preferred-contents-scale))
(define (nsimage-remove-representation! self image-rep)
  (tell #:type _void (coerce-arg self) removeRepresentation: (coerce-arg image-rep)))
(define (nsimage-set-name! self string)
  (_msg-19 (coerce-arg self) (sel_registerName "setName:") (coerce-arg string)))
(define (nsimage-writable-type-identifiers-for-item-provider self)
  (wrap-objc-object
   (tell (coerce-arg self) writableTypeIdentifiersForItemProvider)))
(define (nsimage-writable-types-for-pasteboard self pasteboard)
  (wrap-objc-object
   (tell (coerce-arg self) writableTypesForPasteboard: (coerce-arg pasteboard))))
(define (nsimage-writing-options-for-type-pasteboard self type pasteboard)
  (_msg-24 (coerce-arg self) (sel_registerName "writingOptionsForType:pasteboard:") (coerce-arg type) (coerce-arg pasteboard)))

;; --- Class methods ---
(define (nsimage-can-init-with-pasteboard pasteboard)
  (_msg-19 NSImage (sel_registerName "canInitWithPasteboard:") (coerce-arg pasteboard)))
(define (nsimage-image-named name)
  (wrap-objc-object
   (tell NSImage imageNamed: (coerce-arg name))))
;; block param 2: stored (retained across calls)
(define (nsimage-image-with-size-flipped-drawing-handler size drawing-handler-should-be-called-with-flipped-context drawing-handler)
  (define-values (_blk2 _blk2-id)
    (make-objc-block drawing-handler (list _NSRect) _bool))
  (wrap-objc-object
   (_msg-15 NSImage (sel_registerName "imageWithSize:flipped:drawingHandler:") size drawing-handler-should-be-called-with-flipped-context _blk2)
   ))
(define (nsimage-image-with-symbol-name-bundle-variable-value name bundle value)
  (wrap-objc-object
   (_msg-25 NSImage (sel_registerName "imageWithSymbolName:bundle:variableValue:") (coerce-arg name) (coerce-arg bundle) value)
   ))
(define (nsimage-image-with-symbol-name-variable-value name value)
  (wrap-objc-object
   (_msg-22 NSImage (sel_registerName "imageWithSymbolName:variableValue:") (coerce-arg name) value)
   ))
(define (nsimage-image-with-system-symbol-name-accessibility-description name description)
  (wrap-objc-object
   (tell NSImage imageWithSystemSymbolName: (coerce-arg name) accessibilityDescription: (coerce-arg description))))
(define (nsimage-image-with-system-symbol-name-variable-value-accessibility-description name value description)
  (wrap-objc-object
   (_msg-23 NSImage (sel_registerName "imageWithSystemSymbolName:variableValue:accessibilityDescription:") (coerce-arg name) value (coerce-arg description))
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsimage-object-with-item-provider-data-type-identifier-error data type-identifier out-error)
  (wrap-objc-object
   (_msg-26 NSImage (sel_registerName "objectWithItemProviderData:typeIdentifier:error:") (coerce-arg data) (coerce-arg type-identifier) out-error)
   ))
(define (nsimage-readable-type-identifiers-for-item-provider)
  (wrap-objc-object
   (tell NSImage readableTypeIdentifiersForItemProvider)))
(define (nsimage-readable-types-for-pasteboard pasteboard)
  (wrap-objc-object
   (tell NSImage readableTypesForPasteboard: (coerce-arg pasteboard))))
(define (nsimage-reading-options-for-type-pasteboard type pasteboard)
  (_msg-24 NSImage (sel_registerName "readingOptionsForType:pasteboard:") (coerce-arg type) (coerce-arg pasteboard)))
(define (nsimage-supports-secure-coding)
  (_msg-3 NSImage (sel_registerName "supportsSecureCoding")))
