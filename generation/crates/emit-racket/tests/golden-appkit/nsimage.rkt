#lang racket/base
;; Generated binding for NSImage (AppKit)
;; Do not edit — regenerate from enriched IR

(require "../../runtime/ffi2-dispatch.rkt"
         (except-in ffi/unsafe ->)
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
  [nsimage-object-with-item-provider-data-type-identifier-error (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (values any/c (or/c objc-object? #f)))]
  [nsimage-readable-type-identifiers-for-item-provider (c-> any/c)]
  [nsimage-readable-types-for-pasteboard (c-> (or/c string? objc-object? #f) any/c)]
  [nsimage-reading-options-for-type-pasteboard (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nsimage-supports-secure-coding (c-> boolean?)]
  )

;; --- Class reference ---
(import-class NSImage)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_q (-> ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_0_Q (-> ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_0_R (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_0_Z (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_0_E (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_0_v (-> ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_b (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_P_q (-> ptr_t ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_P_e (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_Q (-> ptr_t ptr_t ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_PPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PPd_P (-> ptr_t ptr_t ptr_t ptr_t double_t ptr_t))
(define-aw-msg aw_racket_msg_Pd_P (-> ptr_t ptr_t ptr_t double_t ptr_t))
(define-aw-msg aw_racket_msg_PdP_P (-> ptr_t ptr_t ptr_t double_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PR_b (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PZ_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_b_v (-> ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_q_v (-> ptr_t ptr_t int64_t void_t))
(define-aw-msg aw_racket_msg_Q_v (-> ptr_t ptr_t uint64_t void_t))
(define-aw-msg aw_racket_msg_Qf_P (-> ptr_t ptr_t uint64_t float_t ptr_t))
(define-aw-msg aw_racket_msg_d_P (-> ptr_t ptr_t double_t ptr_t))
(define-aw-msg aw_racket_msg_d_d (-> ptr_t ptr_t double_t double_t))
(define-aw-msg aw_racket_msg_R_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_RRPPb_b (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t bool_t bool_t))
(define-aw-msg aw_racket_msg_RRQd_v (-> ptr_t ptr_t ptr_t ptr_t uint64_t double_t void_t))
(define-aw-msg aw_racket_msg_RRQdbP_v (-> ptr_t ptr_t ptr_t ptr_t uint64_t double_t bool_t ptr_t void_t))
(define-aw-msg aw_racket_msg_ORQd_v (-> ptr_t ptr_t ptr_t ptr_t uint64_t double_t void_t))
(define-aw-msg aw_racket_msg_Z_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_Z_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_ZbP_P (-> ptr_t ptr_t ptr_t bool_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_E_v (-> ptr_t ptr_t ptr_t void_t))

;; --- Constructors ---
(define (make-nsimage-init-with-cg-image-size cg-image size)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PZ_P (id->ffi2-ptr (tell NSImage alloc)) (id->ffi2-ptr (sel_registerName "initWithCGImage:size:")) (id->ffi2-ptr cg-image) (id->ffi2-ptr size)))
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
   (ffi2-ptr->id (aw_racket_msg_Z_P (id->ffi2-ptr (tell NSImage alloc)) (id->ffi2-ptr (sel_registerName "initWithSize:")) (id->ffi2-ptr size)))
   #:retained #t))


;; --- Properties ---
(define (nsimage-tiff-representation self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "TIFFRepresentation"))))))
(define (nsimage-accessibility-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDescription"))))))
(define (nsimage-set-accessibility-description! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDescription:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsimage-alignment-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignmentRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsimage-set-alignment-rect! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlignmentRect:")) (id->ffi2-ptr value)))
(define (nsimage-background-color self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backgroundColor"))))))
(define (nsimage-set-background-color! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBackgroundColor:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsimage-cache-mode self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cacheMode"))))
(define (nsimage-set-cache-mode! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCacheMode:")) value))
(define (nsimage-cap-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "capInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nsimage-set-cap-insets! self value)
  (aw_racket_msg_E_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCapInsets:")) (id->ffi2-ptr value)))
(define (nsimage-delegate self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "delegate"))))))
(define (nsimage-set-delegate! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDelegate:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsimage-image-types)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSImage) (id->ffi2-ptr (sel_registerName "imageTypes"))))))
(define (nsimage-image-unfiltered-types)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSImage) (id->ffi2-ptr (sel_registerName "imageUnfilteredTypes"))))))
(define (nsimage-locale self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "locale"))))))
(define (nsimage-matches-on-multiple-resolution self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "matchesOnMultipleResolution"))))
(define (nsimage-set-matches-on-multiple-resolution! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMatchesOnMultipleResolution:")) value))
(define (nsimage-matches-only-on-best-fitting-axis self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "matchesOnlyOnBestFittingAxis"))))
(define (nsimage-set-matches-only-on-best-fitting-axis! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMatchesOnlyOnBestFittingAxis:")) value))
(define (nsimage-prefers-color-match self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prefersColorMatch"))))
(define (nsimage-set-prefers-color-match! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPrefersColorMatch:")) value))
(define (nsimage-representations self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "representations"))))))
(define (nsimage-resizing-mode self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resizingMode"))))
(define (nsimage-set-resizing-mode! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setResizingMode:")) value))
(define (nsimage-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "size")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsimage-set-size! self value)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSize:")) (id->ffi2-ptr value)))
(define (nsimage-symbol-configuration self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "symbolConfiguration"))))))
(define (nsimage-template self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "template"))))
(define (nsimage-set-template! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTemplate:")) value))
(define (nsimage-transfer-representation)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSImage) (id->ffi2-ptr (sel_registerName "transferRepresentation"))))))
(define (nsimage-uses-eps-on-resolution-mismatch self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "usesEPSOnResolutionMismatch"))))
(define (nsimage-set-uses-eps-on-resolution-mismatch! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUsesEPSOnResolutionMismatch:")) value))
(define (nsimage-valid self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "valid"))))

;; --- Instance methods ---
(define (nsimage-cg-image-for-proposed-rect-context-hints self proposed-dest-rect reference-context hints)
  (ptr_t->cpointer (aw_racket_msg_PPP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "CGImageForProposedRect:context:hints:")) (id->ffi2-ptr proposed-dest-rect) (id->ffi2-ptr (coerce-arg reference-context)) (id->ffi2-ptr (coerce-arg hints)))))
(define (nsimage-tiff-representation-using-compression-factor self comp factor)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Qf_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "TIFFRepresentationUsingCompression:factor:")) comp factor))
   ))
(define (nsimage-add-representation! self image-rep)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addRepresentation:")) (id->ffi2-ptr (coerce-arg image-rep))))
(define (nsimage-add-representations! self image-reps)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addRepresentations:")) (id->ffi2-ptr (coerce-arg image-reps))))
(define (nsimage-best-representation-for-rect-context-hints self rect reference-context hints)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_RPP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bestRepresentationForRect:context:hints:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg reference-context)) (id->ffi2-ptr (coerce-arg hints))))
   ))
(define (nsimage-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "copyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))
(define (nsimage-draw-at-point-from-rect-operation-fraction self point from-rect op delta)
  (aw_racket_msg_ORQd_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawAtPoint:fromRect:operation:fraction:")) (id->ffi2-ptr point) (id->ffi2-ptr from-rect) op delta))
(define (nsimage-draw-in-rect self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawInRect:")) (id->ffi2-ptr rect)))
(define (nsimage-draw-in-rect-from-rect-operation-fraction self rect from-rect op delta)
  (aw_racket_msg_RRQd_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawInRect:fromRect:operation:fraction:")) (id->ffi2-ptr rect) (id->ffi2-ptr from-rect) op delta))
(define (nsimage-draw-in-rect-from-rect-operation-fraction-respect-flipped-hints self dst-space-portion-rect src-space-portion-rect op requested-alpha respect-context-is-flipped hints)
  (aw_racket_msg_RRQdbP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawInRect:fromRect:operation:fraction:respectFlipped:hints:")) (id->ffi2-ptr dst-space-portion-rect) (id->ffi2-ptr src-space-portion-rect) op requested-alpha respect-context-is-flipped (id->ffi2-ptr (coerce-arg hints))))
(define (nsimage-draw-representation-in-rect self image-rep rect)
  (aw_racket_msg_PR_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawRepresentation:inRect:")) (id->ffi2-ptr (coerce-arg image-rep)) (id->ffi2-ptr rect)))
(define (nsimage-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nsimage-hit-test-rect-with-image-destination-rect-context-hints-flipped self test-rect-dest-space image-rect-dest-space context hints flipped)
  (aw_racket_msg_RRPPb_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hitTestRect:withImageDestinationRect:context:hints:flipped:")) (id->ffi2-ptr test-rect-dest-space) (id->ffi2-ptr image-rect-dest-space) (id->ffi2-ptr (coerce-arg context)) (id->ffi2-ptr (coerce-arg hints)) flipped))
(define (nsimage-image-with-locale self locale)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "imageWithLocale:")) (id->ffi2-ptr (coerce-arg locale))))
   ))
(define (nsimage-image-with-symbol-configuration self configuration)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "imageWithSymbolConfiguration:")) (id->ffi2-ptr (coerce-arg configuration))))
   ))
(define (nsimage-imported-content-types self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "importedContentTypes"))))
   ))
(define (nsimage-init-by-referencing-file self file-name)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "initByReferencingFile:")) (id->ffi2-ptr (coerce-arg file-name))))
   #:retained #t))
(define (nsimage-init-by-referencing-url self url)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "initByReferencingURL:")) (id->ffi2-ptr (coerce-arg url))))
   #:retained #t))
(define (nsimage-is-template self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isTemplate"))))
(define (nsimage-is-valid self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isValid"))))
(define (nsimage-item-provider-visibility-for-representation-with-type-identifier self type-identifier)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "itemProviderVisibilityForRepresentationWithTypeIdentifier:")) (id->ffi2-ptr (coerce-arg type-identifier))))
(define (nsimage-layer-contents-for-contents-scale self layer-contents-scale)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_d_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerContentsForContentsScale:")) layer-contents-scale))
   ))
;; block param 1: async-copied (runtime-managed)
(define (nsimage-load-data-with-type-identifier-for-item-provider-completion-handler self type-identifier completion-handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block completion-handler (list _id _id) _void))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "loadDataWithTypeIdentifier:forItemProviderCompletionHandler:")) (id->ffi2-ptr (coerce-arg type-identifier)) (id->ffi2-ptr _blk1)))
   ))
(define (nsimage-name self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "name"))))
   ))
(define (nsimage-pasteboard-property-list-for-type self type)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pasteboardPropertyListForType:")) (id->ffi2-ptr (coerce-arg type))))
   ))
(define (nsimage-recache self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "recache"))))
(define (nsimage-recommended-layer-contents-scale self preferred-contents-scale)
  (aw_racket_msg_d_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "recommendedLayerContentsScale:")) preferred-contents-scale))
(define (nsimage-remove-representation! self image-rep)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeRepresentation:")) (id->ffi2-ptr (coerce-arg image-rep))))
(define (nsimage-set-name! self string)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setName:")) (id->ffi2-ptr (coerce-arg string))))
(define (nsimage-writable-type-identifiers-for-item-provider self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writableTypeIdentifiersForItemProvider"))))
   ))
(define (nsimage-writable-types-for-pasteboard self pasteboard)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writableTypesForPasteboard:")) (id->ffi2-ptr (coerce-arg pasteboard))))
   ))
(define (nsimage-writing-options-for-type-pasteboard self type pasteboard)
  (aw_racket_msg_PP_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writingOptionsForType:pasteboard:")) (id->ffi2-ptr (coerce-arg type)) (id->ffi2-ptr (coerce-arg pasteboard))))

;; --- Class methods ---
(define (nsimage-can-init-with-pasteboard pasteboard)
  (aw_racket_msg_P_b (id->ffi2-ptr NSImage) (id->ffi2-ptr (sel_registerName "canInitWithPasteboard:")) (id->ffi2-ptr (coerce-arg pasteboard))))
(define (nsimage-image-named name)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSImage) (id->ffi2-ptr (sel_registerName "imageNamed:")) (id->ffi2-ptr (coerce-arg name))))
   ))
;; block param 2: stored (retained across calls)
(define (nsimage-image-with-size-flipped-drawing-handler size drawing-handler-should-be-called-with-flipped-context drawing-handler)
  (define-values (_blk2 _blk2-id)
    (make-objc-block drawing-handler (list _NSRect) _bool))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_ZbP_P (id->ffi2-ptr NSImage) (id->ffi2-ptr (sel_registerName "imageWithSize:flipped:drawingHandler:")) (id->ffi2-ptr size) drawing-handler-should-be-called-with-flipped-context (id->ffi2-ptr _blk2)))
   ))
(define (nsimage-image-with-symbol-name-bundle-variable-value name bundle value)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPd_P (id->ffi2-ptr NSImage) (id->ffi2-ptr (sel_registerName "imageWithSymbolName:bundle:variableValue:")) (id->ffi2-ptr (coerce-arg name)) (id->ffi2-ptr (coerce-arg bundle)) value))
   ))
(define (nsimage-image-with-symbol-name-variable-value name value)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Pd_P (id->ffi2-ptr NSImage) (id->ffi2-ptr (sel_registerName "imageWithSymbolName:variableValue:")) (id->ffi2-ptr (coerce-arg name)) value))
   ))
(define (nsimage-image-with-system-symbol-name-accessibility-description name description)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr NSImage) (id->ffi2-ptr (sel_registerName "imageWithSystemSymbolName:accessibilityDescription:")) (id->ffi2-ptr (coerce-arg name)) (id->ffi2-ptr (coerce-arg description))))
   ))
(define (nsimage-image-with-system-symbol-name-variable-value-accessibility-description name value description)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PdP_P (id->ffi2-ptr NSImage) (id->ffi2-ptr (sel_registerName "imageWithSystemSymbolName:variableValue:accessibilityDescription:")) (id->ffi2-ptr (coerce-arg name)) value (id->ffi2-ptr (coerce-arg description))))
   ))
;; NSError out-param: result-or-error wrapper candidate
(define (nsimage-object-with-item-provider-data-type-identifier-error data type-identifier)
  (let ([errbuf (malloc _pointer)])
    (let ([result (aw_racket_msg_PP_P_e (id->ffi2-ptr NSImage) (id->ffi2-ptr (sel_registerName "objectWithItemProviderData:typeIdentifier:error:")) (id->ffi2-ptr (coerce-arg data)) (id->ffi2-ptr (coerce-arg type-identifier)) (cpointer->ptr_t errbuf))]
          [err (ptr-ref errbuf _pointer)])
      (values (wrap-objc-object (ffi2-ptr->id result)) (if (ptr-equal? err #f) #f (wrap-objc-object err #:retained #t))))))
(define (nsimage-readable-type-identifiers-for-item-provider)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSImage) (id->ffi2-ptr (sel_registerName "readableTypeIdentifiersForItemProvider"))))
   ))
(define (nsimage-readable-types-for-pasteboard pasteboard)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSImage) (id->ffi2-ptr (sel_registerName "readableTypesForPasteboard:")) (id->ffi2-ptr (coerce-arg pasteboard))))
   ))
(define (nsimage-reading-options-for-type-pasteboard type pasteboard)
  (aw_racket_msg_PP_Q (id->ffi2-ptr NSImage) (id->ffi2-ptr (sel_registerName "readingOptionsForType:pasteboard:")) (id->ffi2-ptr (coerce-arg type)) (id->ffi2-ptr (coerce-arg pasteboard))))
(define (nsimage-supports-secure-coding)
  (aw_racket_msg_0_b (id->ffi2-ptr NSImage) (id->ffi2-ptr (sel_registerName "supportsSecureCoding"))))
