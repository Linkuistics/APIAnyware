#lang racket/base
;; Generated binding for NSColor (AppKit)
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
(define (nscolor? v) (objc-instance-of? v "NSColor"))
(define (nscolorspace? v) (objc-instance-of? v "NSColorSpace"))
(define (nsimage? v) (objc-instance-of? v "NSImage"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
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

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_q (-> ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_0_Q (-> ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_0_d (-> ptr_t ptr_t double_t))
(define-aw-msg aw_racket_msg_0_v (-> ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_Q (-> ptr_t ptr_t ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_PP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPPP_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPPPP_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPq_P (-> ptr_t ptr_t ptr_t ptr_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_Pdddd_P (-> ptr_t ptr_t ptr_t double_t double_t double_t double_t ptr_t))
(define-aw-msg aw_racket_msg_b_v (-> ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_q_P (-> ptr_t ptr_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_Q_P (-> ptr_t ptr_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_d_P (-> ptr_t ptr_t double_t ptr_t))
(define-aw-msg aw_racket_msg_dP_P (-> ptr_t ptr_t double_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_dd_P (-> ptr_t ptr_t double_t double_t ptr_t))
(define-aw-msg aw_racket_msg_dddd_P (-> ptr_t ptr_t double_t double_t double_t double_t ptr_t))
(define-aw-msg aw_racket_msg_ddddd_P (-> ptr_t ptr_t double_t double_t double_t double_t double_t ptr_t))
(define-aw-msg aw_racket_msg_R_v (-> ptr_t ptr_t ptr_t void_t))

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
  (ptr_t->cpointer (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "CGColor")))))
(define (nscolor-alpha-component self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alphaComponent"))))
(define (nscolor-alternate-selected-control-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "alternateSelectedControlColor"))))))
(define (nscolor-alternate-selected-control-text-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "alternateSelectedControlTextColor"))))))
(define (nscolor-alternating-content-background-colors)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "alternatingContentBackgroundColors"))))))
(define (nscolor-black-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "blackColor"))))))
(define (nscolor-black-component self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "blackComponent"))))
(define (nscolor-blue-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "blueColor"))))))
(define (nscolor-blue-component self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "blueComponent"))))
(define (nscolor-brightness-component self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "brightnessComponent"))))
(define (nscolor-brown-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "brownColor"))))))
(define (nscolor-catalog-name-component self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "catalogNameComponent"))))))
(define (nscolor-clear-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "clearColor"))))))
(define (nscolor-color-name-component self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "colorNameComponent"))))))
(define (nscolor-color-space self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "colorSpace"))))))
(define (nscolor-color-space-name self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "colorSpaceName"))))))
(define (nscolor-control-accent-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "controlAccentColor"))))))
(define (nscolor-control-alternating-row-background-colors)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "controlAlternatingRowBackgroundColors"))))))
(define (nscolor-control-background-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "controlBackgroundColor"))))))
(define (nscolor-control-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "controlColor"))))))
(define (nscolor-control-dark-shadow-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "controlDarkShadowColor"))))))
(define (nscolor-control-highlight-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "controlHighlightColor"))))))
(define (nscolor-control-light-highlight-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "controlLightHighlightColor"))))))
(define (nscolor-control-shadow-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "controlShadowColor"))))))
(define (nscolor-control-text-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "controlTextColor"))))))
(define (nscolor-current-control-tint)
  (aw_racket_msg_0_Q (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "currentControlTint"))))
(define (nscolor-cyan-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "cyanColor"))))))
(define (nscolor-cyan-component self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cyanComponent"))))
(define (nscolor-dark-gray-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "darkGrayColor"))))))
(define (nscolor-disabled-control-text-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "disabledControlTextColor"))))))
(define (nscolor-find-highlight-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "findHighlightColor"))))))
(define (nscolor-gray-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "grayColor"))))))
(define (nscolor-green-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "greenColor"))))))
(define (nscolor-green-component self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "greenComponent"))))
(define (nscolor-grid-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "gridColor"))))))
(define (nscolor-header-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "headerColor"))))))
(define (nscolor-header-text-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "headerTextColor"))))))
(define (nscolor-highlight-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "highlightColor"))))))
(define (nscolor-hue-component self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hueComponent"))))
(define (nscolor-ignores-alpha)
  (aw_racket_msg_0_b (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "ignoresAlpha"))))
(define (nscolor-set-ignores-alpha! value)
  (aw_racket_msg_b_v (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "setIgnoresAlpha:")) value))
(define (nscolor-keyboard-focus-indicator-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "keyboardFocusIndicatorColor"))))))
(define (nscolor-knob-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "knobColor"))))))
(define (nscolor-label-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "labelColor"))))))
(define (nscolor-light-gray-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "lightGrayColor"))))))
(define (nscolor-linear-exposure self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "linearExposure"))))
(define (nscolor-link-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "linkColor"))))))
(define (nscolor-localized-catalog-name-component self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "localizedCatalogNameComponent"))))))
(define (nscolor-localized-color-name-component self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "localizedColorNameComponent"))))))
(define (nscolor-magenta-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "magentaColor"))))))
(define (nscolor-magenta-component self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "magentaComponent"))))
(define (nscolor-number-of-components self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "numberOfComponents"))))
(define (nscolor-orange-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "orangeColor"))))))
(define (nscolor-pattern-image self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "patternImage"))))))
(define (nscolor-placeholder-text-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "placeholderTextColor"))))))
(define (nscolor-purple-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "purpleColor"))))))
(define (nscolor-quaternary-label-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "quaternaryLabelColor"))))))
(define (nscolor-quaternary-system-fill-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "quaternarySystemFillColor"))))))
(define (nscolor-quinary-label-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "quinaryLabelColor"))))))
(define (nscolor-quinary-system-fill-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "quinarySystemFillColor"))))))
(define (nscolor-red-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "redColor"))))))
(define (nscolor-red-component self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "redComponent"))))
(define (nscolor-saturation-component self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "saturationComponent"))))
(define (nscolor-scroll-bar-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "scrollBarColor"))))))
(define (nscolor-scrubber-textured-background-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "scrubberTexturedBackgroundColor"))))))
(define (nscolor-secondary-label-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "secondaryLabelColor"))))))
(define (nscolor-secondary-selected-control-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "secondarySelectedControlColor"))))))
(define (nscolor-secondary-system-fill-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "secondarySystemFillColor"))))))
(define (nscolor-selected-content-background-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "selectedContentBackgroundColor"))))))
(define (nscolor-selected-control-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "selectedControlColor"))))))
(define (nscolor-selected-control-text-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "selectedControlTextColor"))))))
(define (nscolor-selected-knob-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "selectedKnobColor"))))))
(define (nscolor-selected-menu-item-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "selectedMenuItemColor"))))))
(define (nscolor-selected-menu-item-text-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "selectedMenuItemTextColor"))))))
(define (nscolor-selected-text-background-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "selectedTextBackgroundColor"))))))
(define (nscolor-selected-text-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "selectedTextColor"))))))
(define (nscolor-separator-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "separatorColor"))))))
(define (nscolor-shadow-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "shadowColor"))))))
(define (nscolor-standard-dynamic-range-color self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "standardDynamicRangeColor"))))))
(define (nscolor-system-blue-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "systemBlueColor"))))))
(define (nscolor-system-brown-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "systemBrownColor"))))))
(define (nscolor-system-cyan-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "systemCyanColor"))))))
(define (nscolor-system-fill-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "systemFillColor"))))))
(define (nscolor-system-gray-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "systemGrayColor"))))))
(define (nscolor-system-green-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "systemGreenColor"))))))
(define (nscolor-system-indigo-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "systemIndigoColor"))))))
(define (nscolor-system-mint-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "systemMintColor"))))))
(define (nscolor-system-orange-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "systemOrangeColor"))))))
(define (nscolor-system-pink-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "systemPinkColor"))))))
(define (nscolor-system-purple-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "systemPurpleColor"))))))
(define (nscolor-system-red-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "systemRedColor"))))))
(define (nscolor-system-teal-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "systemTealColor"))))))
(define (nscolor-system-yellow-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "systemYellowColor"))))))
(define (nscolor-tertiary-label-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "tertiaryLabelColor"))))))
(define (nscolor-tertiary-system-fill-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "tertiarySystemFillColor"))))))
(define (nscolor-text-background-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "textBackgroundColor"))))))
(define (nscolor-text-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "textColor"))))))
(define (nscolor-text-insertion-point-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "textInsertionPointColor"))))))
(define (nscolor-transfer-representation)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "transferRepresentation"))))))
(define (nscolor-type self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "type"))))
(define (nscolor-under-page-background-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "underPageBackgroundColor"))))))
(define (nscolor-unemphasized-selected-content-background-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "unemphasizedSelectedContentBackgroundColor"))))))
(define (nscolor-unemphasized-selected-text-background-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "unemphasizedSelectedTextBackgroundColor"))))))
(define (nscolor-unemphasized-selected-text-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "unemphasizedSelectedTextColor"))))))
(define (nscolor-white-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "whiteColor"))))))
(define (nscolor-white-component self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "whiteComponent"))))
(define (nscolor-window-background-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "windowBackgroundColor"))))))
(define (nscolor-window-frame-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "windowFrameColor"))))))
(define (nscolor-window-frame-text-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "windowFrameTextColor"))))))
(define (nscolor-yellow-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "yellowColor"))))))
(define (nscolor-yellow-component self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "yellowComponent"))))

;; --- Instance methods ---
(define (nscolor-accessibility-name self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityName"))))
   ))
(define (nscolor-blended-color-with-fraction-of-color self fraction color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "blendedColorWithFraction:ofColor:")) fraction (id->ffi2-ptr (coerce-arg color))))
   ))
(define (nscolor-color-by-applying-content-headroom self content-headroom)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_d_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "colorByApplyingContentHeadroom:")) content-headroom))
   ))
(define (nscolor-color-using-color-space self space)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "colorUsingColorSpace:")) (id->ffi2-ptr (coerce-arg space))))
   ))
(define (nscolor-color-using-type self type)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "colorUsingType:")) type))
   ))
(define (nscolor-color-with-alpha-component self alpha)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_d_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "colorWithAlphaComponent:")) alpha))
   ))
(define (nscolor-color-with-system-effect self system-effect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "colorWithSystemEffect:")) system-effect))
   ))
(define (nscolor-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "copyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))
(define (nscolor-draw-swatch-in-rect self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawSwatchInRect:")) (id->ffi2-ptr rect)))
(define (nscolor-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nscolor-get-components self components)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getComponents:")) (id->ffi2-ptr components)))
(define (nscolor-get-cyan-magenta-yellow-black-alpha self cyan magenta yellow black alpha)
  (aw_racket_msg_PPPPP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getCyan:magenta:yellow:black:alpha:")) (id->ffi2-ptr cyan) (id->ffi2-ptr magenta) (id->ffi2-ptr yellow) (id->ffi2-ptr black) (id->ffi2-ptr alpha)))
(define (nscolor-get-hue-saturation-brightness-alpha self hue saturation brightness alpha)
  (aw_racket_msg_PPPP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getHue:saturation:brightness:alpha:")) (id->ffi2-ptr hue) (id->ffi2-ptr saturation) (id->ffi2-ptr brightness) (id->ffi2-ptr alpha)))
(define (nscolor-get-red-green-blue-alpha self red green blue alpha)
  (aw_racket_msg_PPPP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getRed:green:blue:alpha:")) (id->ffi2-ptr red) (id->ffi2-ptr green) (id->ffi2-ptr blue) (id->ffi2-ptr alpha)))
(define (nscolor-get-white-alpha self white alpha)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getWhite:alpha:")) (id->ffi2-ptr white) (id->ffi2-ptr alpha)))
(define (nscolor-highlight-with-level self val)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_d_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "highlightWithLevel:")) val))
   ))
(define (nscolor-pasteboard-property-list-for-type self type)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pasteboardPropertyListForType:")) (id->ffi2-ptr (coerce-arg type))))
   ))
(define (nscolor-set! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "set"))))
(define (nscolor-set-fill! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFill"))))
(define (nscolor-set-stroke! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setStroke"))))
(define (nscolor-shadow-with-level self val)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_d_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shadowWithLevel:")) val))
   ))
(define (nscolor-writable-types-for-pasteboard self pasteboard)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writableTypesForPasteboard:")) (id->ffi2-ptr (coerce-arg pasteboard))))
   ))
(define (nscolor-write-to-pasteboard self paste-board)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writeToPasteboard:")) (id->ffi2-ptr (coerce-arg paste-board))))
(define (nscolor-writing-options-for-type-pasteboard self type pasteboard)
  (aw_racket_msg_PP_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writingOptionsForType:pasteboard:")) (id->ffi2-ptr (coerce-arg type)) (id->ffi2-ptr (coerce-arg pasteboard))))

;; --- Class methods ---
(define (nscolor-color-for-control-tint control-tint)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Q_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorForControlTint:")) control-tint))
   ))
(define (nscolor-color-from-pasteboard paste-board)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorFromPasteboard:")) (id->ffi2-ptr (coerce-arg paste-board))))
   ))
(define (nscolor-color-named name)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorNamed:")) (id->ffi2-ptr (coerce-arg name))))
   ))
(define (nscolor-color-named-bundle name bundle)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorNamed:bundle:")) (id->ffi2-ptr (coerce-arg name)) (id->ffi2-ptr (coerce-arg bundle))))
   ))
(define (nscolor-color-with-cg-color cg-color)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithCGColor:")) (id->ffi2-ptr cg-color)))
   ))
(define (nscolor-color-with-calibrated-hue-saturation-brightness-alpha hue saturation brightness alpha)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dddd_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithCalibratedHue:saturation:brightness:alpha:")) hue saturation brightness alpha))
   ))
(define (nscolor-color-with-calibrated-red-green-blue-alpha red green blue alpha)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dddd_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithCalibratedRed:green:blue:alpha:")) red green blue alpha))
   ))
(define (nscolor-color-with-calibrated-white-alpha white alpha)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dd_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithCalibratedWhite:alpha:")) white alpha))
   ))
(define (nscolor-color-with-catalog-name-color-name list-name color-name)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithCatalogName:colorName:")) (id->ffi2-ptr (coerce-arg list-name)) (id->ffi2-ptr (coerce-arg color-name))))
   ))
(define (nscolor-color-with-color-space-components-count space components number-of-components)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPq_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithColorSpace:components:count:")) (id->ffi2-ptr (coerce-arg space)) (id->ffi2-ptr components) number-of-components))
   ))
(define (nscolor-color-with-color-space-hue-saturation-brightness-alpha space hue saturation brightness alpha)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Pdddd_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithColorSpace:hue:saturation:brightness:alpha:")) (id->ffi2-ptr (coerce-arg space)) hue saturation brightness alpha))
   ))
(define (nscolor-color-with-device-cyan-magenta-yellow-black-alpha cyan magenta yellow black alpha)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_ddddd_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithDeviceCyan:magenta:yellow:black:alpha:")) cyan magenta yellow black alpha))
   ))
(define (nscolor-color-with-device-hue-saturation-brightness-alpha hue saturation brightness alpha)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dddd_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithDeviceHue:saturation:brightness:alpha:")) hue saturation brightness alpha))
   ))
(define (nscolor-color-with-device-red-green-blue-alpha red green blue alpha)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dddd_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithDeviceRed:green:blue:alpha:")) red green blue alpha))
   ))
(define (nscolor-color-with-device-white-alpha white alpha)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dd_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithDeviceWhite:alpha:")) white alpha))
   ))
(define (nscolor-color-with-display-p3-red-green-blue-alpha red green blue alpha)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dddd_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithDisplayP3Red:green:blue:alpha:")) red green blue alpha))
   ))
(define (nscolor-color-with-generic-gamma22-white-alpha white alpha)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dd_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithGenericGamma22White:alpha:")) white alpha))
   ))
(define (nscolor-color-with-hue-saturation-brightness-alpha hue saturation brightness alpha)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dddd_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithHue:saturation:brightness:alpha:")) hue saturation brightness alpha))
   ))
;; block param 1: async-copied (runtime-managed)
(define (nscolor-color-with-name-dynamic-provider color-name dynamic-provider)
  (define-values (_blk1 _blk1-id)
    (make-objc-block dynamic-provider (list _id) _id))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithName:dynamicProvider:")) (id->ffi2-ptr (coerce-arg color-name)) (id->ffi2-ptr _blk1)))
   ))
(define (nscolor-color-with-pattern-image image)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithPatternImage:")) (id->ffi2-ptr (coerce-arg image))))
   ))
(define (nscolor-color-with-red-green-blue-alpha red green blue alpha)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dddd_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithRed:green:blue:alpha:")) red green blue alpha))
   ))
(define (nscolor-color-with-red-green-blue-alpha-exposure red green blue alpha exposure)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_ddddd_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithRed:green:blue:alpha:exposure:")) red green blue alpha exposure))
   ))
(define (nscolor-color-with-red-green-blue-alpha-linear-exposure red green blue alpha linear-exposure)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_ddddd_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithRed:green:blue:alpha:linearExposure:")) red green blue alpha linear-exposure))
   ))
(define (nscolor-color-with-srgb-red-green-blue-alpha red green blue alpha)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dddd_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithSRGBRed:green:blue:alpha:")) red green blue alpha))
   ))
(define (nscolor-color-with-white-alpha white alpha)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_dd_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "colorWithWhite:alpha:")) white alpha))
   ))
(define (nscolor-readable-types-for-pasteboard pasteboard)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "readableTypesForPasteboard:")) (id->ffi2-ptr (coerce-arg pasteboard))))
   ))
(define (nscolor-reading-options-for-type-pasteboard type pasteboard)
  (aw_racket_msg_PP_Q (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "readingOptionsForType:pasteboard:")) (id->ffi2-ptr (coerce-arg type)) (id->ffi2-ptr (coerce-arg pasteboard))))
(define (nscolor-supports-secure-coding)
  (aw_racket_msg_0_b (id->ffi2-ptr NSColor) (id->ffi2-ptr (sel_registerName "supportsSecureCoding"))))
