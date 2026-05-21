#lang racket/base
;; Generated binding for NSColor (AppKit)
;; Do not edit — regenerate from enriched IR

(require ffi/unsafe
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../../runtime/objc-base.rkt"
         "../../../runtime/coerce.rkt"
         "../../../runtime/block.rkt"
         "../../../runtime/type-mapping.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/AppKit.framework/AppKit"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nscolor? v) (objc-instance-of? v "NSColor"))
(define (nscolorspace? v) (objc-instance-of? v "NSColorSpace"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsimage? v) (objc-instance-of? v "NSImage"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (nsurl? v) (objc-instance-of? v "NSURL"))
(define (opaquetypearchetype? v) (objc-instance-of? v "OpaqueTypeArchetype"))
(provide NSColor)
(provide/contract
  [make-nscolor-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nscolor-init-with-pasteboard-property-list-of-type (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nscolor-cg-color (c-> nscolor? (or/c cpointer? #f))]
  [nscolor-alpha-component (c-> nscolor? real?)]
  [nscolor-alternate-selected-control-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-alternate-selected-control-text-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-alternating-content-background-colors (c-> any/c)]
  [nscolor-black-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-black-component (c-> nscolor? real?)]
  [nscolor-blue-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-blue-component (c-> nscolor? real?)]
  [nscolor-brightness-component (c-> nscolor? real?)]
  [nscolor-brown-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-catalog-name-component (c-> nscolor? (or/c nsstring? objc-nil?))]
  [nscolor-clear-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-color-name-component (c-> nscolor? (or/c nsstring? objc-nil?))]
  [nscolor-color-space (c-> nscolor? (or/c nscolorspace? objc-nil?))]
  [nscolor-color-space-name (c-> nscolor? (or/c nsstring? objc-nil?))]
  [nscolor-control-accent-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-control-alternating-row-background-colors (c-> any/c)]
  [nscolor-control-background-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-control-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-control-dark-shadow-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-control-highlight-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-control-light-highlight-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-control-shadow-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-control-text-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-current-control-tint (c-> exact-nonnegative-integer?)]
  [nscolor-cyan-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-cyan-component (c-> nscolor? real?)]
  [nscolor-dark-gray-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-disabled-control-text-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-find-highlight-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-gray-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-green-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-green-component (c-> nscolor? real?)]
  [nscolor-grid-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-header-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-header-text-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-highlight-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-hue-component (c-> nscolor? real?)]
  [nscolor-ignores-alpha (c-> boolean?)]
  [nscolor-set-ignores-alpha! (c-> boolean? void?)]
  [nscolor-keyboard-focus-indicator-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-knob-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-label-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-light-gray-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-linear-exposure (c-> nscolor? real?)]
  [nscolor-link-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-localized-catalog-name-component (c-> nscolor? (or/c nsstring? objc-nil?))]
  [nscolor-localized-color-name-component (c-> nscolor? (or/c nsstring? objc-nil?))]
  [nscolor-magenta-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-magenta-component (c-> nscolor? real?)]
  [nscolor-number-of-components (c-> nscolor? exact-integer?)]
  [nscolor-orange-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-pattern-image (c-> nscolor? (or/c nsimage? objc-nil?))]
  [nscolor-placeholder-text-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-purple-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-quaternary-label-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-quaternary-system-fill-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-quinary-label-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-quinary-system-fill-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-red-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-red-component (c-> nscolor? real?)]
  [nscolor-saturation-component (c-> nscolor? real?)]
  [nscolor-scroll-bar-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-scrubber-textured-background-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-secondary-label-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-secondary-selected-control-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-secondary-system-fill-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-selected-content-background-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-selected-control-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-selected-control-text-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-selected-knob-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-selected-menu-item-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-selected-menu-item-text-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-selected-text-background-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-selected-text-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-separator-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-shadow-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-standard-dynamic-range-color (c-> nscolor? (or/c nscolor? objc-nil?))]
  [nscolor-system-blue-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-system-brown-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-system-cyan-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-system-fill-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-system-gray-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-system-green-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-system-indigo-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-system-mint-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-system-orange-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-system-pink-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-system-purple-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-system-red-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-system-teal-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-system-yellow-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-tertiary-label-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-tertiary-system-fill-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-text-background-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-text-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-text-insertion-point-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-transfer-representation (c-> (or/c opaquetypearchetype? objc-nil?))]
  [nscolor-type (c-> nscolor? exact-integer?)]
  [nscolor-under-page-background-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-unemphasized-selected-content-background-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-unemphasized-selected-text-background-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-unemphasized-selected-text-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-white-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-white-component (c-> nscolor? real?)]
  [nscolor-window-background-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-window-frame-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-window-frame-text-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-yellow-color (c-> (or/c nscolor? objc-nil?))]
  [nscolor-yellow-component (c-> nscolor? real?)]
  [nscolor-accessibility-name (c-> nscolor? (or/c nsstring? objc-nil?))]
  [nscolor-blended-color-with-fraction-of-color (c-> nscolor? real? (or/c string? objc-object? #f) (or/c nscolor? objc-nil?))]
  [nscolor-color-by-applying-content-headroom (c-> nscolor? real? (or/c nscolor? objc-nil?))]
  [nscolor-color-using-color-space (c-> nscolor? (or/c string? objc-object? #f) (or/c nscolor? objc-nil?))]
  [nscolor-color-using-type (c-> nscolor? exact-integer? (or/c nscolor? objc-nil?))]
  [nscolor-color-with-alpha-component (c-> nscolor? real? (or/c nscolor? objc-nil?))]
  [nscolor-color-with-system-effect (c-> nscolor? exact-integer? (or/c nscolor? objc-nil?))]
  [nscolor-copy-with-zone (c-> nscolor? (or/c cpointer? #f) any/c)]
  [nscolor-draw-swatch-in-rect (c-> nscolor? any/c void?)]
  [nscolor-encode-with-coder (c-> nscolor? (or/c string? objc-object? #f) void?)]
  [nscolor-get-components (c-> nscolor? (or/c cpointer? #f) void?)]
  [nscolor-get-cyan-magenta-yellow-black-alpha (c-> nscolor? (or/c cpointer? #f) (or/c cpointer? #f) (or/c cpointer? #f) (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nscolor-get-hue-saturation-brightness-alpha (c-> nscolor? (or/c cpointer? #f) (or/c cpointer? #f) (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nscolor-get-red-green-blue-alpha (c-> nscolor? (or/c cpointer? #f) (or/c cpointer? #f) (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nscolor-get-white-alpha (c-> nscolor? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nscolor-highlight-with-level (c-> nscolor? real? (or/c nscolor? objc-nil?))]
  [nscolor-imported-content-types (c-> nscolor? (or/c nsarray? objc-nil?))]
  [nscolor-pasteboard-property-list-for-type (c-> nscolor? (or/c string? objc-object? #f) any/c)]
  [nscolor-set! (c-> nscolor? void?)]
  [nscolor-set-fill! (c-> nscolor? void?)]
  [nscolor-set-stroke! (c-> nscolor? void?)]
  [nscolor-shadow-with-level (c-> nscolor? real? (or/c nscolor? objc-nil?))]
  [nscolor-writable-types-for-pasteboard (c-> nscolor? (or/c string? objc-object? #f) any/c)]
  [nscolor-write-to-pasteboard (c-> nscolor? (or/c string? objc-object? #f) void?)]
  [nscolor-writing-options-for-type-pasteboard (c-> nscolor? (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nscolor-color-for-control-tint (c-> exact-nonnegative-integer? (or/c nscolor? objc-nil?))]
  [nscolor-color-from-pasteboard (c-> (or/c string? objc-object? #f) (or/c nscolor? objc-nil?))]
  [nscolor-color-named (c-> (or/c string? objc-object? #f) (or/c nscolor? objc-nil?))]
  [nscolor-color-named-bundle (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c nscolor? objc-nil?))]
  [nscolor-color-with-cg-color (c-> (or/c cpointer? #f) (or/c nscolor? objc-nil?))]
  [nscolor-color-with-calibrated-hue-saturation-brightness-alpha (c-> real? real? real? real? (or/c nscolor? objc-nil?))]
  [nscolor-color-with-calibrated-red-green-blue-alpha (c-> real? real? real? real? (or/c nscolor? objc-nil?))]
  [nscolor-color-with-calibrated-white-alpha (c-> real? real? (or/c nscolor? objc-nil?))]
  [nscolor-color-with-catalog-name-color-name (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c nscolor? objc-nil?))]
  [nscolor-color-with-color-space-components-count (c-> (or/c string? objc-object? #f) (or/c cpointer? #f) exact-integer? (or/c nscolor? objc-nil?))]
  [nscolor-color-with-color-space-hue-saturation-brightness-alpha (c-> (or/c string? objc-object? #f) real? real? real? real? (or/c nscolor? objc-nil?))]
  [nscolor-color-with-device-cyan-magenta-yellow-black-alpha (c-> real? real? real? real? real? (or/c nscolor? objc-nil?))]
  [nscolor-color-with-device-hue-saturation-brightness-alpha (c-> real? real? real? real? (or/c nscolor? objc-nil?))]
  [nscolor-color-with-device-red-green-blue-alpha (c-> real? real? real? real? (or/c nscolor? objc-nil?))]
  [nscolor-color-with-device-white-alpha (c-> real? real? (or/c nscolor? objc-nil?))]
  [nscolor-color-with-display-p3-red-green-blue-alpha (c-> real? real? real? real? (or/c nscolor? objc-nil?))]
  [nscolor-color-with-generic-gamma22-white-alpha (c-> real? real? (or/c nscolor? objc-nil?))]
  [nscolor-color-with-hue-saturation-brightness-alpha (c-> real? real? real? real? (or/c nscolor? objc-nil?))]
  [nscolor-color-with-name-dynamic-provider (c-> (or/c string? objc-object? #f) (or/c procedure? #f) (or/c nscolor? objc-nil?))]
  [nscolor-color-with-pattern-image (c-> (or/c string? objc-object? #f) (or/c nscolor? objc-nil?))]
  [nscolor-color-with-red-green-blue-alpha (c-> real? real? real? real? (or/c nscolor? objc-nil?))]
  [nscolor-color-with-red-green-blue-alpha-exposure (c-> real? real? real? real? real? (or/c nscolor? objc-nil?))]
  [nscolor-color-with-red-green-blue-alpha-linear-exposure (c-> real? real? real? real? real? (or/c nscolor? objc-nil?))]
  [nscolor-color-with-srgb-red-green-blue-alpha (c-> real? real? real? real? (or/c nscolor? objc-nil?))]
  [nscolor-color-with-white-alpha (c-> real? real? (or/c nscolor? objc-nil?))]
  [nscolor-readable-types-for-pasteboard (c-> (or/c string? objc-object? #f) any/c)]
  [nscolor-reading-options-for-type-pasteboard (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nscolor-supports-secure-coding (c-> boolean?)]
  )

;; --- Class reference ---
(import-class NSColor)

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _bool)))
(define _msg-1  ; (_fun _pointer _pointer -> _double)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _double)))
(define _msg-2  ; (_fun _pointer _pointer -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _int64)))
(define _msg-3  ; (_fun _pointer _pointer -> _pointer)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _pointer)))
(define _msg-4  ; (_fun _pointer _pointer -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _uint64)))
(define _msg-5  ; (_fun _pointer _pointer _NSRect -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _void)))
(define _msg-6  ; (_fun _pointer _pointer _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _bool -> _void)))
(define _msg-7  ; (_fun _pointer _pointer _double -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double -> _id)))
(define _msg-8  ; (_fun _pointer _pointer _double _double -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double _double -> _id)))
(define _msg-9  ; (_fun _pointer _pointer _double _double _double _double -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double _double _double _double -> _id)))
(define _msg-10  ; (_fun _pointer _pointer _double _double _double _double _double -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double _double _double _double _double -> _id)))
(define _msg-11  ; (_fun _pointer _pointer _double _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double _id -> _id)))
(define _msg-12  ; (_fun _pointer _pointer _id _double _double _double _double -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _double _double _double _double -> _id)))
(define _msg-13  ; (_fun _pointer _pointer _id _id -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id -> _uint64)))
(define _msg-14  ; (_fun _pointer _pointer _id _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer -> _id)))
(define _msg-15  ; (_fun _pointer _pointer _id _pointer _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer _int64 -> _id)))
(define _msg-16  ; (_fun _pointer _pointer _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _id)))
(define _msg-17  ; (_fun _pointer _pointer _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _id)))
(define _msg-18  ; (_fun _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _void)))
(define _msg-19  ; (_fun _pointer _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _pointer -> _void)))
(define _msg-20  ; (_fun _pointer _pointer _pointer _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _pointer _pointer _pointer -> _void)))
(define _msg-21  ; (_fun _pointer _pointer _pointer _pointer _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _pointer _pointer _pointer _pointer -> _void)))
(define _msg-22  ; (_fun _pointer _pointer _uint64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _id)))

;; --- Constructors ---
(define (make-nscolor-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSColor alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nscolor-init-with-pasteboard-property-list-of-type property-list type)
  (wrap-objc-object
   (tell (tell NSColor alloc)
         initWithPasteboardPropertyList: (coerce-arg property-list) ofType: (coerce-arg type))
   #:retained #t))


;; --- Properties ---
(define (nscolor-cg-color self)
  (tell #:type _pointer (coerce-arg self) CGColor))
(define (nscolor-alpha-component self)
  (tell #:type _double (coerce-arg self) alphaComponent))
(define (nscolor-alternate-selected-control-color)
  (wrap-objc-object
   (tell NSColor alternateSelectedControlColor)))
(define (nscolor-alternate-selected-control-text-color)
  (wrap-objc-object
   (tell NSColor alternateSelectedControlTextColor)))
(define (nscolor-alternating-content-background-colors)
  (wrap-objc-object
   (tell NSColor alternatingContentBackgroundColors)))
(define (nscolor-black-color)
  (wrap-objc-object
   (tell NSColor blackColor)))
(define (nscolor-black-component self)
  (tell #:type _double (coerce-arg self) blackComponent))
(define (nscolor-blue-color)
  (wrap-objc-object
   (tell NSColor blueColor)))
(define (nscolor-blue-component self)
  (tell #:type _double (coerce-arg self) blueComponent))
(define (nscolor-brightness-component self)
  (tell #:type _double (coerce-arg self) brightnessComponent))
(define (nscolor-brown-color)
  (wrap-objc-object
   (tell NSColor brownColor)))
(define (nscolor-catalog-name-component self)
  (wrap-objc-object
   (tell (coerce-arg self) catalogNameComponent)))
(define (nscolor-clear-color)
  (wrap-objc-object
   (tell NSColor clearColor)))
(define (nscolor-color-name-component self)
  (wrap-objc-object
   (tell (coerce-arg self) colorNameComponent)))
(define (nscolor-color-space self)
  (wrap-objc-object
   (tell (coerce-arg self) colorSpace)))
(define (nscolor-color-space-name self)
  (wrap-objc-object
   (tell (coerce-arg self) colorSpaceName)))
(define (nscolor-control-accent-color)
  (wrap-objc-object
   (tell NSColor controlAccentColor)))
(define (nscolor-control-alternating-row-background-colors)
  (wrap-objc-object
   (tell NSColor controlAlternatingRowBackgroundColors)))
(define (nscolor-control-background-color)
  (wrap-objc-object
   (tell NSColor controlBackgroundColor)))
(define (nscolor-control-color)
  (wrap-objc-object
   (tell NSColor controlColor)))
(define (nscolor-control-dark-shadow-color)
  (wrap-objc-object
   (tell NSColor controlDarkShadowColor)))
(define (nscolor-control-highlight-color)
  (wrap-objc-object
   (tell NSColor controlHighlightColor)))
(define (nscolor-control-light-highlight-color)
  (wrap-objc-object
   (tell NSColor controlLightHighlightColor)))
(define (nscolor-control-shadow-color)
  (wrap-objc-object
   (tell NSColor controlShadowColor)))
(define (nscolor-control-text-color)
  (wrap-objc-object
   (tell NSColor controlTextColor)))
(define (nscolor-current-control-tint)
  (tell #:type _uint64 NSColor currentControlTint))
(define (nscolor-cyan-color)
  (wrap-objc-object
   (tell NSColor cyanColor)))
(define (nscolor-cyan-component self)
  (tell #:type _double (coerce-arg self) cyanComponent))
(define (nscolor-dark-gray-color)
  (wrap-objc-object
   (tell NSColor darkGrayColor)))
(define (nscolor-disabled-control-text-color)
  (wrap-objc-object
   (tell NSColor disabledControlTextColor)))
(define (nscolor-find-highlight-color)
  (wrap-objc-object
   (tell NSColor findHighlightColor)))
(define (nscolor-gray-color)
  (wrap-objc-object
   (tell NSColor grayColor)))
(define (nscolor-green-color)
  (wrap-objc-object
   (tell NSColor greenColor)))
(define (nscolor-green-component self)
  (tell #:type _double (coerce-arg self) greenComponent))
(define (nscolor-grid-color)
  (wrap-objc-object
   (tell NSColor gridColor)))
(define (nscolor-header-color)
  (wrap-objc-object
   (tell NSColor headerColor)))
(define (nscolor-header-text-color)
  (wrap-objc-object
   (tell NSColor headerTextColor)))
(define (nscolor-highlight-color)
  (wrap-objc-object
   (tell NSColor highlightColor)))
(define (nscolor-hue-component self)
  (tell #:type _double (coerce-arg self) hueComponent))
(define (nscolor-ignores-alpha)
  (tell #:type _bool NSColor ignoresAlpha))
(define (nscolor-set-ignores-alpha! value)
  (_msg-6 NSColor (sel_registerName "setIgnoresAlpha:") value))
(define (nscolor-keyboard-focus-indicator-color)
  (wrap-objc-object
   (tell NSColor keyboardFocusIndicatorColor)))
(define (nscolor-knob-color)
  (wrap-objc-object
   (tell NSColor knobColor)))
(define (nscolor-label-color)
  (wrap-objc-object
   (tell NSColor labelColor)))
(define (nscolor-light-gray-color)
  (wrap-objc-object
   (tell NSColor lightGrayColor)))
(define (nscolor-linear-exposure self)
  (tell #:type _double (coerce-arg self) linearExposure))
(define (nscolor-link-color)
  (wrap-objc-object
   (tell NSColor linkColor)))
(define (nscolor-localized-catalog-name-component self)
  (wrap-objc-object
   (tell (coerce-arg self) localizedCatalogNameComponent)))
(define (nscolor-localized-color-name-component self)
  (wrap-objc-object
   (tell (coerce-arg self) localizedColorNameComponent)))
(define (nscolor-magenta-color)
  (wrap-objc-object
   (tell NSColor magentaColor)))
(define (nscolor-magenta-component self)
  (tell #:type _double (coerce-arg self) magentaComponent))
(define (nscolor-number-of-components self)
  (tell #:type _int64 (coerce-arg self) numberOfComponents))
(define (nscolor-orange-color)
  (wrap-objc-object
   (tell NSColor orangeColor)))
(define (nscolor-pattern-image self)
  (wrap-objc-object
   (tell (coerce-arg self) patternImage)))
(define (nscolor-placeholder-text-color)
  (wrap-objc-object
   (tell NSColor placeholderTextColor)))
(define (nscolor-purple-color)
  (wrap-objc-object
   (tell NSColor purpleColor)))
(define (nscolor-quaternary-label-color)
  (wrap-objc-object
   (tell NSColor quaternaryLabelColor)))
(define (nscolor-quaternary-system-fill-color)
  (wrap-objc-object
   (tell NSColor quaternarySystemFillColor)))
(define (nscolor-quinary-label-color)
  (wrap-objc-object
   (tell NSColor quinaryLabelColor)))
(define (nscolor-quinary-system-fill-color)
  (wrap-objc-object
   (tell NSColor quinarySystemFillColor)))
(define (nscolor-red-color)
  (wrap-objc-object
   (tell NSColor redColor)))
(define (nscolor-red-component self)
  (tell #:type _double (coerce-arg self) redComponent))
(define (nscolor-saturation-component self)
  (tell #:type _double (coerce-arg self) saturationComponent))
(define (nscolor-scroll-bar-color)
  (wrap-objc-object
   (tell NSColor scrollBarColor)))
(define (nscolor-scrubber-textured-background-color)
  (wrap-objc-object
   (tell NSColor scrubberTexturedBackgroundColor)))
(define (nscolor-secondary-label-color)
  (wrap-objc-object
   (tell NSColor secondaryLabelColor)))
(define (nscolor-secondary-selected-control-color)
  (wrap-objc-object
   (tell NSColor secondarySelectedControlColor)))
(define (nscolor-secondary-system-fill-color)
  (wrap-objc-object
   (tell NSColor secondarySystemFillColor)))
(define (nscolor-selected-content-background-color)
  (wrap-objc-object
   (tell NSColor selectedContentBackgroundColor)))
(define (nscolor-selected-control-color)
  (wrap-objc-object
   (tell NSColor selectedControlColor)))
(define (nscolor-selected-control-text-color)
  (wrap-objc-object
   (tell NSColor selectedControlTextColor)))
(define (nscolor-selected-knob-color)
  (wrap-objc-object
   (tell NSColor selectedKnobColor)))
(define (nscolor-selected-menu-item-color)
  (wrap-objc-object
   (tell NSColor selectedMenuItemColor)))
(define (nscolor-selected-menu-item-text-color)
  (wrap-objc-object
   (tell NSColor selectedMenuItemTextColor)))
(define (nscolor-selected-text-background-color)
  (wrap-objc-object
   (tell NSColor selectedTextBackgroundColor)))
(define (nscolor-selected-text-color)
  (wrap-objc-object
   (tell NSColor selectedTextColor)))
(define (nscolor-separator-color)
  (wrap-objc-object
   (tell NSColor separatorColor)))
(define (nscolor-shadow-color)
  (wrap-objc-object
   (tell NSColor shadowColor)))
(define (nscolor-standard-dynamic-range-color self)
  (wrap-objc-object
   (tell (coerce-arg self) standardDynamicRangeColor)))
(define (nscolor-system-blue-color)
  (wrap-objc-object
   (tell NSColor systemBlueColor)))
(define (nscolor-system-brown-color)
  (wrap-objc-object
   (tell NSColor systemBrownColor)))
(define (nscolor-system-cyan-color)
  (wrap-objc-object
   (tell NSColor systemCyanColor)))
(define (nscolor-system-fill-color)
  (wrap-objc-object
   (tell NSColor systemFillColor)))
(define (nscolor-system-gray-color)
  (wrap-objc-object
   (tell NSColor systemGrayColor)))
(define (nscolor-system-green-color)
  (wrap-objc-object
   (tell NSColor systemGreenColor)))
(define (nscolor-system-indigo-color)
  (wrap-objc-object
   (tell NSColor systemIndigoColor)))
(define (nscolor-system-mint-color)
  (wrap-objc-object
   (tell NSColor systemMintColor)))
(define (nscolor-system-orange-color)
  (wrap-objc-object
   (tell NSColor systemOrangeColor)))
(define (nscolor-system-pink-color)
  (wrap-objc-object
   (tell NSColor systemPinkColor)))
(define (nscolor-system-purple-color)
  (wrap-objc-object
   (tell NSColor systemPurpleColor)))
(define (nscolor-system-red-color)
  (wrap-objc-object
   (tell NSColor systemRedColor)))
(define (nscolor-system-teal-color)
  (wrap-objc-object
   (tell NSColor systemTealColor)))
(define (nscolor-system-yellow-color)
  (wrap-objc-object
   (tell NSColor systemYellowColor)))
(define (nscolor-tertiary-label-color)
  (wrap-objc-object
   (tell NSColor tertiaryLabelColor)))
(define (nscolor-tertiary-system-fill-color)
  (wrap-objc-object
   (tell NSColor tertiarySystemFillColor)))
(define (nscolor-text-background-color)
  (wrap-objc-object
   (tell NSColor textBackgroundColor)))
(define (nscolor-text-color)
  (wrap-objc-object
   (tell NSColor textColor)))
(define (nscolor-text-insertion-point-color)
  (wrap-objc-object
   (tell NSColor textInsertionPointColor)))
(define (nscolor-transfer-representation)
  (wrap-objc-object
   (tell NSColor transferRepresentation)))
(define (nscolor-type self)
  (tell #:type _int64 (coerce-arg self) type))
(define (nscolor-under-page-background-color)
  (wrap-objc-object
   (tell NSColor underPageBackgroundColor)))
(define (nscolor-unemphasized-selected-content-background-color)
  (wrap-objc-object
   (tell NSColor unemphasizedSelectedContentBackgroundColor)))
(define (nscolor-unemphasized-selected-text-background-color)
  (wrap-objc-object
   (tell NSColor unemphasizedSelectedTextBackgroundColor)))
(define (nscolor-unemphasized-selected-text-color)
  (wrap-objc-object
   (tell NSColor unemphasizedSelectedTextColor)))
(define (nscolor-white-color)
  (wrap-objc-object
   (tell NSColor whiteColor)))
(define (nscolor-white-component self)
  (tell #:type _double (coerce-arg self) whiteComponent))
(define (nscolor-window-background-color)
  (wrap-objc-object
   (tell NSColor windowBackgroundColor)))
(define (nscolor-window-frame-color)
  (wrap-objc-object
   (tell NSColor windowFrameColor)))
(define (nscolor-window-frame-text-color)
  (wrap-objc-object
   (tell NSColor windowFrameTextColor)))
(define (nscolor-yellow-color)
  (wrap-objc-object
   (tell NSColor yellowColor)))
(define (nscolor-yellow-component self)
  (tell #:type _double (coerce-arg self) yellowComponent))

;; --- Instance methods ---
(define (nscolor-accessibility-name self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityName)))
(define (nscolor-blended-color-with-fraction-of-color self fraction color)
  (wrap-objc-object
   (_msg-11 (coerce-arg self) (sel_registerName "blendedColorWithFraction:ofColor:") fraction (coerce-arg color))
   ))
(define (nscolor-color-by-applying-content-headroom self content-headroom)
  (wrap-objc-object
   (_msg-7 (coerce-arg self) (sel_registerName "colorByApplyingContentHeadroom:") content-headroom)
   ))
(define (nscolor-color-using-color-space self space)
  (wrap-objc-object
   (tell (coerce-arg self) colorUsingColorSpace: (coerce-arg space))))
(define (nscolor-color-using-type self type)
  (wrap-objc-object
   (_msg-16 (coerce-arg self) (sel_registerName "colorUsingType:") type)
   ))
(define (nscolor-color-with-alpha-component self alpha)
  (wrap-objc-object
   (_msg-7 (coerce-arg self) (sel_registerName "colorWithAlphaComponent:") alpha)
   ))
(define (nscolor-color-with-system-effect self system-effect)
  (wrap-objc-object
   (_msg-16 (coerce-arg self) (sel_registerName "colorWithSystemEffect:") system-effect)
   ))
(define (nscolor-copy-with-zone self zone)
  (wrap-objc-object
   (_msg-17 (coerce-arg self) (sel_registerName "copyWithZone:") zone)
   #:retained #t))
(define (nscolor-draw-swatch-in-rect self rect)
  (_msg-5 (coerce-arg self) (sel_registerName "drawSwatchInRect:") rect))
(define (nscolor-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nscolor-get-components self components)
  (_msg-18 (coerce-arg self) (sel_registerName "getComponents:") components))
(define (nscolor-get-cyan-magenta-yellow-black-alpha self cyan magenta yellow black alpha)
  (_msg-21 (coerce-arg self) (sel_registerName "getCyan:magenta:yellow:black:alpha:") cyan magenta yellow black alpha))
(define (nscolor-get-hue-saturation-brightness-alpha self hue saturation brightness alpha)
  (_msg-20 (coerce-arg self) (sel_registerName "getHue:saturation:brightness:alpha:") hue saturation brightness alpha))
(define (nscolor-get-red-green-blue-alpha self red green blue alpha)
  (_msg-20 (coerce-arg self) (sel_registerName "getRed:green:blue:alpha:") red green blue alpha))
(define (nscolor-get-white-alpha self white alpha)
  (_msg-19 (coerce-arg self) (sel_registerName "getWhite:alpha:") white alpha))
(define (nscolor-highlight-with-level self val)
  (wrap-objc-object
   (_msg-7 (coerce-arg self) (sel_registerName "highlightWithLevel:") val)
   ))
(define (nscolor-imported-content-types self)
  (wrap-objc-object
   (tell (coerce-arg self) importedContentTypes)))
(define (nscolor-pasteboard-property-list-for-type self type)
  (wrap-objc-object
   (tell (coerce-arg self) pasteboardPropertyListForType: (coerce-arg type))))
(define (nscolor-set! self)
  (tell #:type _void (coerce-arg self) set))
(define (nscolor-set-fill! self)
  (tell #:type _void (coerce-arg self) setFill))
(define (nscolor-set-stroke! self)
  (tell #:type _void (coerce-arg self) setStroke))
(define (nscolor-shadow-with-level self val)
  (wrap-objc-object
   (_msg-7 (coerce-arg self) (sel_registerName "shadowWithLevel:") val)
   ))
(define (nscolor-writable-types-for-pasteboard self pasteboard)
  (wrap-objc-object
   (tell (coerce-arg self) writableTypesForPasteboard: (coerce-arg pasteboard))))
(define (nscolor-write-to-pasteboard self paste-board)
  (tell #:type _void (coerce-arg self) writeToPasteboard: (coerce-arg paste-board)))
(define (nscolor-writing-options-for-type-pasteboard self type pasteboard)
  (_msg-13 (coerce-arg self) (sel_registerName "writingOptionsForType:pasteboard:") (coerce-arg type) (coerce-arg pasteboard)))

;; --- Class methods ---
(define (nscolor-color-for-control-tint control-tint)
  (wrap-objc-object
   (_msg-22 NSColor (sel_registerName "colorForControlTint:") control-tint)
   ))
(define (nscolor-color-from-pasteboard paste-board)
  (wrap-objc-object
   (tell NSColor colorFromPasteboard: (coerce-arg paste-board))))
(define (nscolor-color-named name)
  (wrap-objc-object
   (tell NSColor colorNamed: (coerce-arg name))))
(define (nscolor-color-named-bundle name bundle)
  (wrap-objc-object
   (tell NSColor colorNamed: (coerce-arg name) bundle: (coerce-arg bundle))))
(define (nscolor-color-with-cg-color cg-color)
  (wrap-objc-object
   (_msg-17 NSColor (sel_registerName "colorWithCGColor:") cg-color)
   ))
(define (nscolor-color-with-calibrated-hue-saturation-brightness-alpha hue saturation brightness alpha)
  (wrap-objc-object
   (_msg-9 NSColor (sel_registerName "colorWithCalibratedHue:saturation:brightness:alpha:") hue saturation brightness alpha)
   ))
(define (nscolor-color-with-calibrated-red-green-blue-alpha red green blue alpha)
  (wrap-objc-object
   (_msg-9 NSColor (sel_registerName "colorWithCalibratedRed:green:blue:alpha:") red green blue alpha)
   ))
(define (nscolor-color-with-calibrated-white-alpha white alpha)
  (wrap-objc-object
   (_msg-8 NSColor (sel_registerName "colorWithCalibratedWhite:alpha:") white alpha)
   ))
(define (nscolor-color-with-catalog-name-color-name list-name color-name)
  (wrap-objc-object
   (tell NSColor colorWithCatalogName: (coerce-arg list-name) colorName: (coerce-arg color-name))))
(define (nscolor-color-with-color-space-components-count space components number-of-components)
  (wrap-objc-object
   (_msg-15 NSColor (sel_registerName "colorWithColorSpace:components:count:") (coerce-arg space) components number-of-components)
   ))
(define (nscolor-color-with-color-space-hue-saturation-brightness-alpha space hue saturation brightness alpha)
  (wrap-objc-object
   (_msg-12 NSColor (sel_registerName "colorWithColorSpace:hue:saturation:brightness:alpha:") (coerce-arg space) hue saturation brightness alpha)
   ))
(define (nscolor-color-with-device-cyan-magenta-yellow-black-alpha cyan magenta yellow black alpha)
  (wrap-objc-object
   (_msg-10 NSColor (sel_registerName "colorWithDeviceCyan:magenta:yellow:black:alpha:") cyan magenta yellow black alpha)
   ))
(define (nscolor-color-with-device-hue-saturation-brightness-alpha hue saturation brightness alpha)
  (wrap-objc-object
   (_msg-9 NSColor (sel_registerName "colorWithDeviceHue:saturation:brightness:alpha:") hue saturation brightness alpha)
   ))
(define (nscolor-color-with-device-red-green-blue-alpha red green blue alpha)
  (wrap-objc-object
   (_msg-9 NSColor (sel_registerName "colorWithDeviceRed:green:blue:alpha:") red green blue alpha)
   ))
(define (nscolor-color-with-device-white-alpha white alpha)
  (wrap-objc-object
   (_msg-8 NSColor (sel_registerName "colorWithDeviceWhite:alpha:") white alpha)
   ))
(define (nscolor-color-with-display-p3-red-green-blue-alpha red green blue alpha)
  (wrap-objc-object
   (_msg-9 NSColor (sel_registerName "colorWithDisplayP3Red:green:blue:alpha:") red green blue alpha)
   ))
(define (nscolor-color-with-generic-gamma22-white-alpha white alpha)
  (wrap-objc-object
   (_msg-8 NSColor (sel_registerName "colorWithGenericGamma22White:alpha:") white alpha)
   ))
(define (nscolor-color-with-hue-saturation-brightness-alpha hue saturation brightness alpha)
  (wrap-objc-object
   (_msg-9 NSColor (sel_registerName "colorWithHue:saturation:brightness:alpha:") hue saturation brightness alpha)
   ))
(define (nscolor-color-with-name-dynamic-provider color-name dynamic-provider)
  (define-values (_blk1 _blk1-id)
    (make-objc-block dynamic-provider (list _id) _id))
  (wrap-objc-object
   (_msg-14 NSColor (sel_registerName "colorWithName:dynamicProvider:") (coerce-arg color-name) _blk1)
   ))
(define (nscolor-color-with-pattern-image image)
  (wrap-objc-object
   (tell NSColor colorWithPatternImage: (coerce-arg image))))
(define (nscolor-color-with-red-green-blue-alpha red green blue alpha)
  (wrap-objc-object
   (_msg-9 NSColor (sel_registerName "colorWithRed:green:blue:alpha:") red green blue alpha)
   ))
(define (nscolor-color-with-red-green-blue-alpha-exposure red green blue alpha exposure)
  (wrap-objc-object
   (_msg-10 NSColor (sel_registerName "colorWithRed:green:blue:alpha:exposure:") red green blue alpha exposure)
   ))
(define (nscolor-color-with-red-green-blue-alpha-linear-exposure red green blue alpha linear-exposure)
  (wrap-objc-object
   (_msg-10 NSColor (sel_registerName "colorWithRed:green:blue:alpha:linearExposure:") red green blue alpha linear-exposure)
   ))
(define (nscolor-color-with-srgb-red-green-blue-alpha red green blue alpha)
  (wrap-objc-object
   (_msg-9 NSColor (sel_registerName "colorWithSRGBRed:green:blue:alpha:") red green blue alpha)
   ))
(define (nscolor-color-with-white-alpha white alpha)
  (wrap-objc-object
   (_msg-8 NSColor (sel_registerName "colorWithWhite:alpha:") white alpha)
   ))
(define (nscolor-readable-types-for-pasteboard pasteboard)
  (wrap-objc-object
   (tell NSColor readableTypesForPasteboard: (coerce-arg pasteboard))))
(define (nscolor-reading-options-for-type-pasteboard type pasteboard)
  (_msg-13 NSColor (sel_registerName "readingOptionsForType:pasteboard:") (coerce-arg type) (coerce-arg pasteboard)))
(define (nscolor-supports-secure-coding)
  (_msg-0 NSColor (sel_registerName "supportsSecureCoding")))
