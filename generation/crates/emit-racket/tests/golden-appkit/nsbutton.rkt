#lang racket/base
;; Generated binding for NSButton (AppKit)
;; Do not edit — regenerate from enriched IR

(require "../../runtime/ffi2-dispatch.rkt"
         (except-in ffi/unsafe ->)
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../runtime/objc-base.rkt"
         "../../runtime/coerce.rkt"
         "../../runtime/type-mapping.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/AppKit.framework/AppKit"))
(define _objc-lib (ffi-lib "libobjc"))

;; Threading: this class has main-thread-only methods.

;; --- Class predicates ---
(define (calayer? v) (objc-instance-of? v "CALayer"))
(define (cifilter? v) (objc-instance-of? v "CIFilter"))
(define (nsappearance? v) (objc-instance-of? v "NSAppearance"))
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsattributedstring? v) (objc-instance-of? v "NSAttributedString"))
(define (nsbitmapimagerep? v) (objc-instance-of? v "NSBitmapImageRep"))
(define (nsbutton? v) (objc-instance-of? v "NSButton"))
(define (nscandidatelisttouchbaritem? v) (objc-instance-of? v "NSCandidateListTouchBarItem"))
(define (nscolor? v) (objc-instance-of? v "NSColor"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsfont? v) (objc-instance-of? v "NSFont"))
(define (nsimage? v) (objc-instance-of? v "NSImage"))
(define (nsimagesymbolconfiguration? v) (objc-instance-of? v "NSImageSymbolConfiguration"))
(define (nslayoutdimension? v) (objc-instance-of? v "NSLayoutDimension"))
(define (nslayoutguide? v) (objc-instance-of? v "NSLayoutGuide"))
(define (nslayoutxaxisanchor? v) (objc-instance-of? v "NSLayoutXAxisAnchor"))
(define (nslayoutyaxisanchor? v) (objc-instance-of? v "NSLayoutYAxisAnchor"))
(define (nsmenu? v) (objc-instance-of? v "NSMenu"))
(define (nsmenuitem? v) (objc-instance-of? v "NSMenuItem"))
(define (nspressureconfiguration? v) (objc-instance-of? v "NSPressureConfiguration"))
(define (nsresponder? v) (objc-instance-of? v "NSResponder"))
(define (nsscrollview? v) (objc-instance-of? v "NSScrollView"))
(define (nsshadow? v) (objc-instance-of? v "NSShadow"))
(define (nssound? v) (objc-instance-of? v "NSSound"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (nstextinputcontext? v) (objc-instance-of? v "NSTextInputContext"))
(define (nstouchbar? v) (objc-instance-of? v "NSTouchBar"))
(define (nsurl? v) (objc-instance-of? v "NSURL"))
(define (nsundomanager? v) (objc-instance-of? v "NSUndoManager"))
(define (nsuseractivity? v) (objc-instance-of? v "NSUserActivity"))
(define (nsuserinterfacecompressionoptions? v) (objc-instance-of? v "NSUserInterfaceCompressionOptions"))
(define (nsview? v) (objc-instance-of? v "NSView"))
(define (nswindow? v) (objc-instance-of? v "NSWindow"))
(define (nswritingtoolscoordinator? v) (objc-instance-of? v "NSWritingToolsCoordinator"))
(provide NSButton)
(provide/contract
  [make-nsbutton-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsbutton-init-with-frame (c-> any/c any/c)]
  [nsbutton-accepts-first-responder (c-> nsbutton? boolean?)]
  [nsbutton-accepts-touch-events (c-> nsbutton? boolean?)]
  [nsbutton-set-accepts-touch-events! (c-> nsbutton? boolean? void?)]
  [nsbutton-action (c-> nsbutton? cpointer?)]
  [nsbutton-set-action! (c-> nsbutton? string? void?)]
  [nsbutton-active-compression-options (c-> nsbutton? (or/c nsuserinterfacecompressionoptions? objc-nil?))]
  [nsbutton-additional-safe-area-insets (c-> nsbutton? any/c)]
  [nsbutton-set-additional-safe-area-insets! (c-> nsbutton? any/c void?)]
  [nsbutton-alignment (c-> nsbutton? exact-integer?)]
  [nsbutton-set-alignment! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-alignment-rect-insets (c-> nsbutton? any/c)]
  [nsbutton-allowed-touch-types (c-> nsbutton? exact-nonnegative-integer?)]
  [nsbutton-set-allowed-touch-types! (c-> nsbutton? exact-nonnegative-integer? void?)]
  [nsbutton-allows-expansion-tool-tips (c-> nsbutton? boolean?)]
  [nsbutton-set-allows-expansion-tool-tips! (c-> nsbutton? boolean? void?)]
  [nsbutton-allows-mixed-state (c-> nsbutton? boolean?)]
  [nsbutton-set-allows-mixed-state! (c-> nsbutton? boolean? void?)]
  [nsbutton-allows-vibrancy (c-> nsbutton? boolean?)]
  [nsbutton-alpha-value (c-> nsbutton? real?)]
  [nsbutton-set-alpha-value! (c-> nsbutton? real? void?)]
  [nsbutton-alternate-image (c-> nsbutton? (or/c nsimage? objc-nil?))]
  [nsbutton-set-alternate-image! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-alternate-title (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-set-alternate-title! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-attributed-alternate-title (c-> nsbutton? (or/c nsattributedstring? objc-nil?))]
  [nsbutton-set-attributed-alternate-title! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-attributed-string-value (c-> nsbutton? (or/c nsattributedstring? objc-nil?))]
  [nsbutton-set-attributed-string-value! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-attributed-title (c-> nsbutton? (or/c nsattributedstring? objc-nil?))]
  [nsbutton-set-attributed-title! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-autoresizes-subviews (c-> nsbutton? boolean?)]
  [nsbutton-set-autoresizes-subviews! (c-> nsbutton? boolean? void?)]
  [nsbutton-autoresizing-mask (c-> nsbutton? exact-nonnegative-integer?)]
  [nsbutton-set-autoresizing-mask! (c-> nsbutton? exact-nonnegative-integer? void?)]
  [nsbutton-background-filters (c-> nsbutton? any/c)]
  [nsbutton-set-background-filters! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-base-writing-direction (c-> nsbutton? exact-integer?)]
  [nsbutton-set-base-writing-direction! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-baseline-offset-from-bottom (c-> nsbutton? real?)]
  [nsbutton-bezel-color (c-> nsbutton? (or/c nscolor? objc-nil?))]
  [nsbutton-set-bezel-color! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-bezel-style (c-> nsbutton? exact-nonnegative-integer?)]
  [nsbutton-set-bezel-style! (c-> nsbutton? exact-nonnegative-integer? void?)]
  [nsbutton-border-shape (c-> nsbutton? exact-integer?)]
  [nsbutton-set-border-shape! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-bordered (c-> nsbutton? boolean?)]
  [nsbutton-set-bordered! (c-> nsbutton? boolean? void?)]
  [nsbutton-bottom-anchor (c-> nsbutton? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsbutton-bounds (c-> nsbutton? any/c)]
  [nsbutton-set-bounds! (c-> nsbutton? any/c void?)]
  [nsbutton-bounds-rotation (c-> nsbutton? real?)]
  [nsbutton-set-bounds-rotation! (c-> nsbutton? real? void?)]
  [nsbutton-can-become-key-view (c-> nsbutton? boolean?)]
  [nsbutton-can-draw (c-> nsbutton? boolean?)]
  [nsbutton-can-draw-concurrently (c-> nsbutton? boolean?)]
  [nsbutton-set-can-draw-concurrently! (c-> nsbutton? boolean? void?)]
  [nsbutton-can-draw-subviews-into-layer (c-> nsbutton? boolean?)]
  [nsbutton-set-can-draw-subviews-into-layer! (c-> nsbutton? boolean? void?)]
  [nsbutton-candidate-list-touch-bar-item (c-> nsbutton? (or/c nscandidatelisttouchbaritem? objc-nil?))]
  [nsbutton-cell (c-> nsbutton? any/c)]
  [nsbutton-set-cell! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-cell-class (c-> cpointer?)]
  [nsbutton-set-cell-class! (c-> cpointer? void?)]
  [nsbutton-center-x-anchor (c-> nsbutton? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsbutton-center-y-anchor (c-> nsbutton? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsbutton-clips-to-bounds (c-> nsbutton? boolean?)]
  [nsbutton-set-clips-to-bounds! (c-> nsbutton? boolean? void?)]
  [nsbutton-compatible-with-responsive-scrolling (c-> boolean?)]
  [nsbutton-compositing-filter (c-> nsbutton? (or/c cifilter? objc-nil?))]
  [nsbutton-set-compositing-filter! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-constraints (c-> nsbutton? any/c)]
  [nsbutton-content-filters (c-> nsbutton? any/c)]
  [nsbutton-set-content-filters! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-content-tint-color (c-> nsbutton? (or/c nscolor? objc-nil?))]
  [nsbutton-set-content-tint-color! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-continuous (c-> nsbutton? boolean?)]
  [nsbutton-set-continuous! (c-> nsbutton? boolean? void?)]
  [nsbutton-control-size (c-> nsbutton? exact-nonnegative-integer?)]
  [nsbutton-set-control-size! (c-> nsbutton? exact-nonnegative-integer? void?)]
  [nsbutton-default-focus-ring-type (c-> exact-nonnegative-integer?)]
  [nsbutton-default-menu (c-> (or/c nsmenu? objc-nil?))]
  [nsbutton-double-value (c-> nsbutton? real?)]
  [nsbutton-set-double-value! (c-> nsbutton? real? void?)]
  [nsbutton-drawing-find-indicator (c-> nsbutton? boolean?)]
  [nsbutton-enabled (c-> nsbutton? boolean?)]
  [nsbutton-set-enabled! (c-> nsbutton? boolean? void?)]
  [nsbutton-enclosing-menu-item (c-> nsbutton? (or/c nsmenuitem? objc-nil?))]
  [nsbutton-enclosing-scroll-view (c-> nsbutton? (or/c nsscrollview? objc-nil?))]
  [nsbutton-first-baseline-anchor (c-> nsbutton? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsbutton-first-baseline-offset-from-top (c-> nsbutton? real?)]
  [nsbutton-fitting-size (c-> nsbutton? any/c)]
  [nsbutton-flipped (c-> nsbutton? boolean?)]
  [nsbutton-float-value (c-> nsbutton? real?)]
  [nsbutton-set-float-value! (c-> nsbutton? real? void?)]
  [nsbutton-focus-ring-mask-bounds (c-> nsbutton? any/c)]
  [nsbutton-focus-ring-type (c-> nsbutton? exact-nonnegative-integer?)]
  [nsbutton-set-focus-ring-type! (c-> nsbutton? exact-nonnegative-integer? void?)]
  [nsbutton-focus-view (c-> (or/c nsview? objc-nil?))]
  [nsbutton-font (c-> nsbutton? (or/c nsfont? objc-nil?))]
  [nsbutton-set-font! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-formatter (c-> nsbutton? any/c)]
  [nsbutton-set-formatter! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-frame (c-> nsbutton? any/c)]
  [nsbutton-set-frame! (c-> nsbutton? any/c void?)]
  [nsbutton-frame-center-rotation (c-> nsbutton? real?)]
  [nsbutton-set-frame-center-rotation! (c-> nsbutton? real? void?)]
  [nsbutton-frame-rotation (c-> nsbutton? real?)]
  [nsbutton-set-frame-rotation! (c-> nsbutton? real? void?)]
  [nsbutton-gesture-recognizers (c-> nsbutton? any/c)]
  [nsbutton-set-gesture-recognizers! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-has-ambiguous-layout (c-> nsbutton? boolean?)]
  [nsbutton-has-destructive-action (c-> nsbutton? boolean?)]
  [nsbutton-set-has-destructive-action! (c-> nsbutton? boolean? void?)]
  [nsbutton-height-adjust-limit (c-> nsbutton? real?)]
  [nsbutton-height-anchor (c-> nsbutton? (or/c nslayoutdimension? objc-nil?))]
  [nsbutton-hidden (c-> nsbutton? boolean?)]
  [nsbutton-set-hidden! (c-> nsbutton? boolean? void?)]
  [nsbutton-hidden-or-has-hidden-ancestor (c-> nsbutton? boolean?)]
  [nsbutton-highlighted (c-> nsbutton? boolean?)]
  [nsbutton-set-highlighted! (c-> nsbutton? boolean? void?)]
  [nsbutton-horizontal-content-size-constraint-active (c-> nsbutton? boolean?)]
  [nsbutton-set-horizontal-content-size-constraint-active! (c-> nsbutton? boolean? void?)]
  [nsbutton-ignores-multi-click (c-> nsbutton? boolean?)]
  [nsbutton-set-ignores-multi-click! (c-> nsbutton? boolean? void?)]
  [nsbutton-image (c-> nsbutton? (or/c nsimage? objc-nil?))]
  [nsbutton-set-image! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-image-hugs-title (c-> nsbutton? boolean?)]
  [nsbutton-set-image-hugs-title! (c-> nsbutton? boolean? void?)]
  [nsbutton-image-position (c-> nsbutton? exact-nonnegative-integer?)]
  [nsbutton-set-image-position! (c-> nsbutton? exact-nonnegative-integer? void?)]
  [nsbutton-image-scaling (c-> nsbutton? exact-nonnegative-integer?)]
  [nsbutton-set-image-scaling! (c-> nsbutton? exact-nonnegative-integer? void?)]
  [nsbutton-in-full-screen-mode (c-> nsbutton? boolean?)]
  [nsbutton-in-live-resize (c-> nsbutton? boolean?)]
  [nsbutton-input-context (c-> nsbutton? (or/c nstextinputcontext? objc-nil?))]
  [nsbutton-int-value (c-> nsbutton? exact-integer?)]
  [nsbutton-set-int-value! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-integer-value (c-> nsbutton? exact-integer?)]
  [nsbutton-set-integer-value! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-intrinsic-content-size (c-> nsbutton? any/c)]
  [nsbutton-key-equivalent (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-set-key-equivalent! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-key-equivalent-modifier-mask (c-> nsbutton? exact-nonnegative-integer?)]
  [nsbutton-set-key-equivalent-modifier-mask! (c-> nsbutton? exact-nonnegative-integer? void?)]
  [nsbutton-last-baseline-anchor (c-> nsbutton? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsbutton-last-baseline-offset-from-bottom (c-> nsbutton? real?)]
  [nsbutton-layer (c-> nsbutton? (or/c calayer? objc-nil?))]
  [nsbutton-set-layer! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-layer-contents-placement (c-> nsbutton? exact-integer?)]
  [nsbutton-set-layer-contents-placement! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-layer-contents-redraw-policy (c-> nsbutton? exact-integer?)]
  [nsbutton-set-layer-contents-redraw-policy! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-layer-uses-core-image-filters (c-> nsbutton? boolean?)]
  [nsbutton-set-layer-uses-core-image-filters! (c-> nsbutton? boolean? void?)]
  [nsbutton-layout-guides (c-> nsbutton? any/c)]
  [nsbutton-layout-margins-guide (c-> nsbutton? (or/c nslayoutguide? objc-nil?))]
  [nsbutton-leading-anchor (c-> nsbutton? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsbutton-left-anchor (c-> nsbutton? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsbutton-line-break-mode (c-> nsbutton? exact-nonnegative-integer?)]
  [nsbutton-set-line-break-mode! (c-> nsbutton? exact-nonnegative-integer? void?)]
  [nsbutton-max-accelerator-level (c-> nsbutton? exact-integer?)]
  [nsbutton-set-max-accelerator-level! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-menu (c-> nsbutton? (or/c nsmenu? objc-nil?))]
  [nsbutton-set-menu! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-mouse-down-can-move-window (c-> nsbutton? boolean?)]
  [nsbutton-needs-display (c-> nsbutton? boolean?)]
  [nsbutton-set-needs-display! (c-> nsbutton? boolean? void?)]
  [nsbutton-needs-layout (c-> nsbutton? boolean?)]
  [nsbutton-set-needs-layout! (c-> nsbutton? boolean? void?)]
  [nsbutton-needs-panel-to-become-key (c-> nsbutton? boolean?)]
  [nsbutton-needs-update-constraints (c-> nsbutton? boolean?)]
  [nsbutton-set-needs-update-constraints! (c-> nsbutton? boolean? void?)]
  [nsbutton-next-key-view (c-> nsbutton? (or/c nsview? objc-nil?))]
  [nsbutton-set-next-key-view! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-next-responder (c-> nsbutton? (or/c nsresponder? objc-nil?))]
  [nsbutton-set-next-responder! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-next-valid-key-view (c-> nsbutton? (or/c nsview? objc-nil?))]
  [nsbutton-object-value (c-> nsbutton? any/c)]
  [nsbutton-set-object-value! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-opaque (c-> nsbutton? boolean?)]
  [nsbutton-opaque-ancestor (c-> nsbutton? (or/c nsview? objc-nil?))]
  [nsbutton-page-footer (c-> nsbutton? (or/c nsattributedstring? objc-nil?))]
  [nsbutton-page-header (c-> nsbutton? (or/c nsattributedstring? objc-nil?))]
  [nsbutton-posts-bounds-changed-notifications (c-> nsbutton? boolean?)]
  [nsbutton-set-posts-bounds-changed-notifications! (c-> nsbutton? boolean? void?)]
  [nsbutton-posts-frame-changed-notifications (c-> nsbutton? boolean?)]
  [nsbutton-set-posts-frame-changed-notifications! (c-> nsbutton? boolean? void?)]
  [nsbutton-prefers-compact-control-size-metrics (c-> nsbutton? boolean?)]
  [nsbutton-set-prefers-compact-control-size-metrics! (c-> nsbutton? boolean? void?)]
  [nsbutton-prepared-content-rect (c-> nsbutton? any/c)]
  [nsbutton-set-prepared-content-rect! (c-> nsbutton? any/c void?)]
  [nsbutton-preserves-content-during-live-resize (c-> nsbutton? boolean?)]
  [nsbutton-pressure-configuration (c-> nsbutton? (or/c nspressureconfiguration? objc-nil?))]
  [nsbutton-set-pressure-configuration! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-previous-key-view (c-> nsbutton? (or/c nsview? objc-nil?))]
  [nsbutton-previous-valid-key-view (c-> nsbutton? (or/c nsview? objc-nil?))]
  [nsbutton-print-job-title (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-rect-preserved-during-live-resize (c-> nsbutton? any/c)]
  [nsbutton-refuses-first-responder (c-> nsbutton? boolean?)]
  [nsbutton-set-refuses-first-responder! (c-> nsbutton? boolean? void?)]
  [nsbutton-registered-dragged-types (c-> nsbutton? any/c)]
  [nsbutton-requires-constraint-based-layout (c-> boolean?)]
  [nsbutton-restorable-state-key-paths (c-> any/c)]
  [nsbutton-right-anchor (c-> nsbutton? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsbutton-rotated-from-base (c-> nsbutton? boolean?)]
  [nsbutton-rotated-or-scaled-from-base (c-> nsbutton? boolean?)]
  [nsbutton-safe-area-insets (c-> nsbutton? any/c)]
  [nsbutton-safe-area-layout-guide (c-> nsbutton? (or/c nslayoutguide? objc-nil?))]
  [nsbutton-safe-area-rect (c-> nsbutton? any/c)]
  [nsbutton-shadow (c-> nsbutton? (or/c nsshadow? objc-nil?))]
  [nsbutton-set-shadow! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-shows-border-only-while-mouse-inside (c-> nsbutton? boolean?)]
  [nsbutton-set-shows-border-only-while-mouse-inside! (c-> nsbutton? boolean? void?)]
  [nsbutton-sound (c-> nsbutton? (or/c nssound? objc-nil?))]
  [nsbutton-set-sound! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-spring-loaded (c-> nsbutton? boolean?)]
  [nsbutton-set-spring-loaded! (c-> nsbutton? boolean? void?)]
  [nsbutton-state (c-> nsbutton? exact-integer?)]
  [nsbutton-set-state! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-string-value (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-set-string-value! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-subviews (c-> nsbutton? any/c)]
  [nsbutton-set-subviews! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-superview (c-> nsbutton? (or/c nsview? objc-nil?))]
  [nsbutton-symbol-configuration (c-> nsbutton? (or/c nsimagesymbolconfiguration? objc-nil?))]
  [nsbutton-set-symbol-configuration! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-tag (c-> nsbutton? exact-integer?)]
  [nsbutton-set-tag! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-target (c-> nsbutton? any/c)]
  [nsbutton-set-target! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-tint-prominence (c-> nsbutton? exact-integer?)]
  [nsbutton-set-tint-prominence! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-title (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-set-title! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-tool-tip (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-set-tool-tip! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-top-anchor (c-> nsbutton? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsbutton-touch-bar (c-> nsbutton? (or/c nstouchbar? objc-nil?))]
  [nsbutton-set-touch-bar! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-tracking-areas (c-> nsbutton? any/c)]
  [nsbutton-trailing-anchor (c-> nsbutton? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsbutton-translates-autoresizing-mask-into-constraints (c-> nsbutton? boolean?)]
  [nsbutton-set-translates-autoresizing-mask-into-constraints! (c-> nsbutton? boolean? void?)]
  [nsbutton-transparent (c-> nsbutton? boolean?)]
  [nsbutton-set-transparent! (c-> nsbutton? boolean? void?)]
  [nsbutton-undo-manager (c-> nsbutton? (or/c nsundomanager? objc-nil?))]
  [nsbutton-user-activity (c-> nsbutton? (or/c nsuseractivity? objc-nil?))]
  [nsbutton-set-user-activity! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-user-interface-layout-direction (c-> nsbutton? exact-integer?)]
  [nsbutton-set-user-interface-layout-direction! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-uses-single-line-mode (c-> nsbutton? boolean?)]
  [nsbutton-set-uses-single-line-mode! (c-> nsbutton? boolean? void?)]
  [nsbutton-vertical-content-size-constraint-active (c-> nsbutton? boolean?)]
  [nsbutton-set-vertical-content-size-constraint-active! (c-> nsbutton? boolean? void?)]
  [nsbutton-visible-rect (c-> nsbutton? any/c)]
  [nsbutton-wants-best-resolution-open-gl-surface (c-> nsbutton? boolean?)]
  [nsbutton-set-wants-best-resolution-open-gl-surface! (c-> nsbutton? boolean? void?)]
  [nsbutton-wants-default-clipping (c-> nsbutton? boolean?)]
  [nsbutton-wants-extended-dynamic-range-open-gl-surface (c-> nsbutton? boolean?)]
  [nsbutton-set-wants-extended-dynamic-range-open-gl-surface! (c-> nsbutton? boolean? void?)]
  [nsbutton-wants-layer (c-> nsbutton? boolean?)]
  [nsbutton-set-wants-layer! (c-> nsbutton? boolean? void?)]
  [nsbutton-wants-resting-touches (c-> nsbutton? boolean?)]
  [nsbutton-set-wants-resting-touches! (c-> nsbutton? boolean? void?)]
  [nsbutton-wants-update-layer (c-> nsbutton? boolean?)]
  [nsbutton-width-adjust-limit (c-> nsbutton? real?)]
  [nsbutton-width-anchor (c-> nsbutton? (or/c nslayoutdimension? objc-nil?))]
  [nsbutton-window (c-> nsbutton? (or/c nswindow? objc-nil?))]
  [nsbutton-writing-tools-coordinator (c-> nsbutton? (or/c nswritingtoolscoordinator? objc-nil?))]
  [nsbutton-set-writing-tools-coordinator! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-accepts-first-mouse (c-> nsbutton? (or/c string? objc-object? #f) boolean?)]
  [nsbutton-accessibility-activation-point (c-> nsbutton? any/c)]
  [nsbutton-accessibility-allowed-values (c-> nsbutton? any/c)]
  [nsbutton-accessibility-application-focused-ui-element (c-> nsbutton? any/c)]
  [nsbutton-accessibility-attributed-string-for-range (c-> nsbutton? any/c (or/c nsattributedstring? objc-nil?))]
  [nsbutton-accessibility-attributed-user-input-labels (c-> nsbutton? any/c)]
  [nsbutton-accessibility-cancel-button (c-> nsbutton? any/c)]
  [nsbutton-accessibility-cell-for-column-row (c-> nsbutton? exact-integer? exact-integer? any/c)]
  [nsbutton-accessibility-children (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-children-in-navigation-order (c-> nsbutton? any/c)]
  [nsbutton-accessibility-clear-button (c-> nsbutton? any/c)]
  [nsbutton-accessibility-close-button (c-> nsbutton? any/c)]
  [nsbutton-accessibility-column-count (c-> nsbutton? exact-integer?)]
  [nsbutton-accessibility-column-header-ui-elements (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-column-index-range (c-> nsbutton? any/c)]
  [nsbutton-accessibility-column-titles (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-columns (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-contents (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-critical-value (c-> nsbutton? any/c)]
  [nsbutton-accessibility-custom-actions (c-> nsbutton? any/c)]
  [nsbutton-accessibility-custom-rotors (c-> nsbutton? any/c)]
  [nsbutton-accessibility-decrement-button (c-> nsbutton? any/c)]
  [nsbutton-accessibility-default-button (c-> nsbutton? any/c)]
  [nsbutton-accessibility-disclosed-by-row (c-> nsbutton? any/c)]
  [nsbutton-accessibility-disclosed-rows (c-> nsbutton? any/c)]
  [nsbutton-accessibility-disclosure-level (c-> nsbutton? exact-integer?)]
  [nsbutton-accessibility-document (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-accessibility-extras-menu-bar (c-> nsbutton? any/c)]
  [nsbutton-accessibility-filename (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-accessibility-focused-window (c-> nsbutton? any/c)]
  [nsbutton-accessibility-frame (c-> nsbutton? any/c)]
  [nsbutton-accessibility-frame-for-range (c-> nsbutton? any/c any/c)]
  [nsbutton-accessibility-full-screen-button (c-> nsbutton? any/c)]
  [nsbutton-accessibility-grow-area (c-> nsbutton? any/c)]
  [nsbutton-accessibility-handles (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-header (c-> nsbutton? any/c)]
  [nsbutton-accessibility-help (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-accessibility-horizontal-scroll-bar (c-> nsbutton? any/c)]
  [nsbutton-accessibility-horizontal-unit-description (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-accessibility-horizontal-units (c-> nsbutton? exact-integer?)]
  [nsbutton-accessibility-identifier (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-accessibility-increment-button (c-> nsbutton? any/c)]
  [nsbutton-accessibility-index (c-> nsbutton? exact-integer?)]
  [nsbutton-accessibility-insertion-point-line-number (c-> nsbutton? exact-integer?)]
  [nsbutton-accessibility-label (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-accessibility-label-ui-elements (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-label-value (c-> nsbutton? real?)]
  [nsbutton-accessibility-layout-point-for-screen-point (c-> nsbutton? any/c any/c)]
  [nsbutton-accessibility-layout-size-for-screen-size (c-> nsbutton? any/c any/c)]
  [nsbutton-accessibility-line-for-index (c-> nsbutton? exact-integer? exact-integer?)]
  [nsbutton-accessibility-linked-ui-elements (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-main-window (c-> nsbutton? any/c)]
  [nsbutton-accessibility-marker-group-ui-element (c-> nsbutton? any/c)]
  [nsbutton-accessibility-marker-type-description (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-accessibility-marker-ui-elements (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-marker-values (c-> nsbutton? any/c)]
  [nsbutton-accessibility-max-value (c-> nsbutton? any/c)]
  [nsbutton-accessibility-menu-bar (c-> nsbutton? any/c)]
  [nsbutton-accessibility-min-value (c-> nsbutton? any/c)]
  [nsbutton-accessibility-minimize-button (c-> nsbutton? any/c)]
  [nsbutton-accessibility-next-contents (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-number-of-characters (c-> nsbutton? exact-integer?)]
  [nsbutton-accessibility-orientation (c-> nsbutton? exact-integer?)]
  [nsbutton-accessibility-overflow-button (c-> nsbutton? any/c)]
  [nsbutton-accessibility-parent (c-> nsbutton? any/c)]
  [nsbutton-accessibility-perform-cancel (c-> nsbutton? boolean?)]
  [nsbutton-accessibility-perform-confirm (c-> nsbutton? boolean?)]
  [nsbutton-accessibility-perform-decrement (c-> nsbutton? boolean?)]
  [nsbutton-accessibility-perform-delete (c-> nsbutton? boolean?)]
  [nsbutton-accessibility-perform-increment (c-> nsbutton? boolean?)]
  [nsbutton-accessibility-perform-pick (c-> nsbutton? boolean?)]
  [nsbutton-accessibility-perform-press (c-> nsbutton? boolean?)]
  [nsbutton-accessibility-perform-raise (c-> nsbutton? boolean?)]
  [nsbutton-accessibility-perform-show-alternate-ui (c-> nsbutton? boolean?)]
  [nsbutton-accessibility-perform-show-default-ui (c-> nsbutton? boolean?)]
  [nsbutton-accessibility-perform-show-menu (c-> nsbutton? boolean?)]
  [nsbutton-accessibility-placeholder-value (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-accessibility-previous-contents (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-proxy (c-> nsbutton? any/c)]
  [nsbutton-accessibility-rtf-for-range (c-> nsbutton? any/c (or/c nsdata? objc-nil?))]
  [nsbutton-accessibility-range-for-index (c-> nsbutton? exact-integer? any/c)]
  [nsbutton-accessibility-range-for-line (c-> nsbutton? exact-integer? any/c)]
  [nsbutton-accessibility-range-for-position (c-> nsbutton? any/c any/c)]
  [nsbutton-accessibility-role (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-accessibility-role-description (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-accessibility-row-count (c-> nsbutton? exact-integer?)]
  [nsbutton-accessibility-row-header-ui-elements (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-row-index-range (c-> nsbutton? any/c)]
  [nsbutton-accessibility-rows (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-ruler-marker-type (c-> nsbutton? exact-integer?)]
  [nsbutton-accessibility-screen-point-for-layout-point (c-> nsbutton? any/c any/c)]
  [nsbutton-accessibility-screen-size-for-layout-size (c-> nsbutton? any/c any/c)]
  [nsbutton-accessibility-search-button (c-> nsbutton? any/c)]
  [nsbutton-accessibility-search-menu (c-> nsbutton? any/c)]
  [nsbutton-accessibility-selected-cells (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-selected-children (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-selected-columns (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-selected-rows (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-selected-text (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-accessibility-selected-text-range (c-> nsbutton? any/c)]
  [nsbutton-accessibility-selected-text-ranges (c-> nsbutton? any/c)]
  [nsbutton-accessibility-serves-as-title-for-ui-elements (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-shared-character-range (c-> nsbutton? any/c)]
  [nsbutton-accessibility-shared-focus-elements (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-shared-text-ui-elements (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-shown-menu (c-> nsbutton? any/c)]
  [nsbutton-accessibility-sort-direction (c-> nsbutton? exact-integer?)]
  [nsbutton-accessibility-splitters (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-string-for-range (c-> nsbutton? any/c (or/c nsstring? objc-nil?))]
  [nsbutton-accessibility-style-range-for-index (c-> nsbutton? exact-integer? any/c)]
  [nsbutton-accessibility-subrole (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-accessibility-tabs (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-title (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-accessibility-title-ui-element (c-> nsbutton? any/c)]
  [nsbutton-accessibility-toolbar-button (c-> nsbutton? any/c)]
  [nsbutton-accessibility-top-level-ui-element (c-> nsbutton? any/c)]
  [nsbutton-accessibility-url (c-> nsbutton? (or/c nsurl? objc-nil?))]
  [nsbutton-accessibility-unit-description (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-accessibility-units (c-> nsbutton? exact-integer?)]
  [nsbutton-accessibility-user-input-labels (c-> nsbutton? any/c)]
  [nsbutton-accessibility-value (c-> nsbutton? any/c)]
  [nsbutton-accessibility-value-description (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-accessibility-vertical-scroll-bar (c-> nsbutton? any/c)]
  [nsbutton-accessibility-vertical-unit-description (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-accessibility-vertical-units (c-> nsbutton? exact-integer?)]
  [nsbutton-accessibility-visible-cells (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-visible-character-range (c-> nsbutton? any/c)]
  [nsbutton-accessibility-visible-children (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-visible-columns (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-visible-rows (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-warning-value (c-> nsbutton? any/c)]
  [nsbutton-accessibility-window (c-> nsbutton? any/c)]
  [nsbutton-accessibility-windows (c-> nsbutton? (or/c nsarray? objc-nil?))]
  [nsbutton-accessibility-zoom-button (c-> nsbutton? any/c)]
  [nsbutton-add-subview! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-add-subview-positioned-relative-to! (c-> nsbutton? (or/c string? objc-object? #f) exact-integer? (or/c string? objc-object? #f) void?)]
  [nsbutton-add-tool-tip-rect-owner-user-data! (c-> nsbutton? any/c (or/c string? objc-object? #f) (or/c cpointer? #f) exact-integer?)]
  [nsbutton-adjust-scroll (c-> nsbutton? any/c any/c)]
  [nsbutton-ancestor-shared-with-view (c-> nsbutton? (or/c string? objc-object? #f) (or/c nsview? objc-nil?))]
  [nsbutton-animation-for-key (c-> nsbutton? (or/c string? objc-object? #f) any/c)]
  [nsbutton-animations (c-> nsbutton? any/c)]
  [nsbutton-animator (c-> nsbutton? any/c)]
  [nsbutton-appearance (c-> nsbutton? (or/c nsappearance? objc-nil?))]
  [nsbutton-autoscroll (c-> nsbutton? (or/c string? objc-object? #f) boolean?)]
  [nsbutton-backing-aligned-rect-options (c-> nsbutton? any/c exact-nonnegative-integer? any/c)]
  [nsbutton-become-first-responder (c-> nsbutton? boolean?)]
  [nsbutton-begin-gesture-with-event! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-bitmap-image-rep-for-caching-display-in-rect (c-> nsbutton? any/c (or/c nsbitmapimagerep? objc-nil?))]
  [nsbutton-cache-display-in-rect-to-bitmap-image-rep (c-> nsbutton? any/c (or/c string? objc-object? #f) void?)]
  [nsbutton-cancel-operation (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-capitalize-word (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-center-scan-rect! (c-> nsbutton? any/c any/c)]
  [nsbutton-center-selection-in-visible-area! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-change-case-of-letter (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-change-mode-with-event (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-complete (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-compress-with-prioritized-compression-options (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-conclude-drag-operation (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-context-menu-key-down (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-convert-point-from-view (c-> nsbutton? any/c (or/c string? objc-object? #f) any/c)]
  [nsbutton-convert-point-to-view (c-> nsbutton? any/c (or/c string? objc-object? #f) any/c)]
  [nsbutton-convert-point-from-backing (c-> nsbutton? any/c any/c)]
  [nsbutton-convert-point-from-layer (c-> nsbutton? any/c any/c)]
  [nsbutton-convert-point-to-backing (c-> nsbutton? any/c any/c)]
  [nsbutton-convert-point-to-layer (c-> nsbutton? any/c any/c)]
  [nsbutton-convert-rect-from-view (c-> nsbutton? any/c (or/c string? objc-object? #f) any/c)]
  [nsbutton-convert-rect-to-view (c-> nsbutton? any/c (or/c string? objc-object? #f) any/c)]
  [nsbutton-convert-rect-from-backing (c-> nsbutton? any/c any/c)]
  [nsbutton-convert-rect-from-layer (c-> nsbutton? any/c any/c)]
  [nsbutton-convert-rect-to-backing (c-> nsbutton? any/c any/c)]
  [nsbutton-convert-rect-to-layer (c-> nsbutton? any/c any/c)]
  [nsbutton-convert-size-from-view (c-> nsbutton? any/c (or/c string? objc-object? #f) any/c)]
  [nsbutton-convert-size-to-view (c-> nsbutton? any/c (or/c string? objc-object? #f) any/c)]
  [nsbutton-convert-size-from-backing (c-> nsbutton? any/c any/c)]
  [nsbutton-convert-size-from-layer (c-> nsbutton? any/c any/c)]
  [nsbutton-convert-size-to-backing (c-> nsbutton? any/c any/c)]
  [nsbutton-convert-size-to-layer (c-> nsbutton? any/c any/c)]
  [nsbutton-cursor-update (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-delete-backward (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-delete-backward-by-decomposing-previous-character (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-delete-forward (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-delete-to-beginning-of-line (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-delete-to-beginning-of-paragraph (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-delete-to-end-of-line (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-delete-to-end-of-paragraph (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-delete-to-mark (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-delete-word-backward (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-delete-word-forward (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-did-add-subview (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-did-close-menu-with-event (c-> nsbutton? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsbutton-display! (c-> nsbutton? void?)]
  [nsbutton-display-if-needed! (c-> nsbutton? void?)]
  [nsbutton-display-if-needed-ignoring-opacity! (c-> nsbutton? void?)]
  [nsbutton-display-if-needed-in-rect! (c-> nsbutton? any/c void?)]
  [nsbutton-display-if-needed-in-rect-ignoring-opacity! (c-> nsbutton? any/c void?)]
  [nsbutton-display-rect! (c-> nsbutton? any/c void?)]
  [nsbutton-display-rect-ignoring-opacity! (c-> nsbutton? any/c void?)]
  [nsbutton-display-rect-ignoring-opacity-in-context! (c-> nsbutton? any/c (or/c string? objc-object? #f) void?)]
  [nsbutton-do-command-by-selector (c-> nsbutton? string? void?)]
  [nsbutton-dragging-ended (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-dragging-entered (c-> nsbutton? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nsbutton-dragging-exited (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-dragging-updated (c-> nsbutton? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nsbutton-draw-rect (c-> nsbutton? any/c void?)]
  [nsbutton-draw-with-expansion-frame-in-view (c-> nsbutton? any/c (or/c string? objc-object? #f) void?)]
  [nsbutton-effective-appearance (c-> nsbutton? (or/c nsappearance? objc-nil?))]
  [nsbutton-encode-with-coder (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-end-gesture-with-event! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-expansion-frame-with-frame (c-> nsbutton? any/c any/c)]
  [nsbutton-flags-changed (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-flush-buffered-key-events (c-> nsbutton? void?)]
  [nsbutton-get-periodic-delay-interval (c-> nsbutton? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nsbutton-get-rects-being-drawn-count (c-> nsbutton? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nsbutton-get-rects-exposed-during-live-resize-count (c-> nsbutton? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nsbutton-help-requested (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-highlight (c-> nsbutton? boolean? void?)]
  [nsbutton-hit-test (c-> nsbutton? any/c (or/c nsview? objc-nil?))]
  [nsbutton-identifier (c-> nsbutton? (or/c nsstring? objc-nil?))]
  [nsbutton-indent (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-insert-backtab! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-insert-container-break! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-insert-double-quote-ignoring-substitution! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-insert-line-break! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-insert-newline! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-insert-newline-ignoring-field-editor! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-insert-paragraph-separator! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-insert-single-quote-ignoring-substitution! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-insert-tab! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-insert-tab-ignoring-field-editor! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-insert-text! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-interpret-key-events (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-is-accessibility-alternate-ui-visible (c-> nsbutton? boolean?)]
  [nsbutton-is-accessibility-disclosed (c-> nsbutton? boolean?)]
  [nsbutton-is-accessibility-edited (c-> nsbutton? boolean?)]
  [nsbutton-is-accessibility-element (c-> nsbutton? boolean?)]
  [nsbutton-is-accessibility-enabled (c-> nsbutton? boolean?)]
  [nsbutton-is-accessibility-expanded (c-> nsbutton? boolean?)]
  [nsbutton-is-accessibility-focused (c-> nsbutton? boolean?)]
  [nsbutton-is-accessibility-frontmost (c-> nsbutton? boolean?)]
  [nsbutton-is-accessibility-hidden (c-> nsbutton? boolean?)]
  [nsbutton-is-accessibility-main (c-> nsbutton? boolean?)]
  [nsbutton-is-accessibility-minimized (c-> nsbutton? boolean?)]
  [nsbutton-is-accessibility-modal (c-> nsbutton? boolean?)]
  [nsbutton-is-accessibility-ordered-by-row (c-> nsbutton? boolean?)]
  [nsbutton-is-accessibility-protected-content (c-> nsbutton? boolean?)]
  [nsbutton-is-accessibility-required (c-> nsbutton? boolean?)]
  [nsbutton-is-accessibility-selected (c-> nsbutton? boolean?)]
  [nsbutton-is-accessibility-selector-allowed (c-> nsbutton? string? boolean?)]
  [nsbutton-is-bordered (c-> nsbutton? boolean?)]
  [nsbutton-is-continuous (c-> nsbutton? boolean?)]
  [nsbutton-is-descendant-of (c-> nsbutton? (or/c string? objc-object? #f) boolean?)]
  [nsbutton-is-enabled (c-> nsbutton? boolean?)]
  [nsbutton-is-flipped (c-> nsbutton? boolean?)]
  [nsbutton-is-hidden (c-> nsbutton? boolean?)]
  [nsbutton-is-hidden-or-has-hidden-ancestor (c-> nsbutton? boolean?)]
  [nsbutton-is-highlighted (c-> nsbutton? boolean?)]
  [nsbutton-is-opaque (c-> nsbutton? boolean?)]
  [nsbutton-is-rotated-from-base (c-> nsbutton? boolean?)]
  [nsbutton-is-rotated-or-scaled-from-base (c-> nsbutton? boolean?)]
  [nsbutton-is-spring-loaded (c-> nsbutton? boolean?)]
  [nsbutton-is-transparent (c-> nsbutton? boolean?)]
  [nsbutton-key-down (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-key-up (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-layout (c-> nsbutton? void?)]
  [nsbutton-layout-subtree-if-needed (c-> nsbutton? void?)]
  [nsbutton-lowercase-word (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-magnify-with-event (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-make-backing-layer (c-> nsbutton? (or/c calayer? objc-nil?))]
  [nsbutton-make-base-writing-direction-left-to-right (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-make-base-writing-direction-natural (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-make-base-writing-direction-right-to-left (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-make-text-writing-direction-left-to-right (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-make-text-writing-direction-natural (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-make-text-writing-direction-right-to-left (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-menu-for-event (c-> nsbutton? (or/c string? objc-object? #f) (or/c nsmenu? objc-nil?))]
  [nsbutton-minimum-size-with-prioritized-compression-options (c-> nsbutton? (or/c string? objc-object? #f) any/c)]
  [nsbutton-mouse-in-rect (c-> nsbutton? any/c any/c boolean?)]
  [nsbutton-mouse-cancelled (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-mouse-down (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-mouse-dragged (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-mouse-entered (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-mouse-exited (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-mouse-moved (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-mouse-up (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-backward! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-backward-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-down! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-down-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-forward! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-forward-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-left! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-left-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-paragraph-backward-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-paragraph-forward-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-right! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-right-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-to-beginning-of-document! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-to-beginning-of-document-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-to-beginning-of-line! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-to-beginning-of-line-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-to-beginning-of-paragraph! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-to-beginning-of-paragraph-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-to-end-of-document! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-to-end-of-document-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-to-end-of-line! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-to-end-of-line-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-to-end-of-paragraph! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-to-end-of-paragraph-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-to-left-end-of-line! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-to-left-end-of-line-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-to-right-end-of-line! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-to-right-end-of-line-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-up! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-up-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-word-backward! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-word-backward-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-word-forward! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-word-forward-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-word-left! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-word-left-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-word-right! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-move-word-right-and-modify-selection! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-needs-to-draw-rect (c-> nsbutton? any/c boolean?)]
  [nsbutton-no-responder-for (c-> nsbutton? string? void?)]
  [nsbutton-other-mouse-down (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-other-mouse-dragged (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-other-mouse-up (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-page-down (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-page-down-and-modify-selection (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-page-up (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-page-up-and-modify-selection (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-perform-click! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-perform-drag-operation! (c-> nsbutton? (or/c string? objc-object? #f) boolean?)]
  [nsbutton-perform-key-equivalent! (c-> nsbutton? (or/c string? objc-object? #f) boolean?)]
  [nsbutton-prepare-content-in-rect (c-> nsbutton? any/c void?)]
  [nsbutton-prepare-for-drag-operation (c-> nsbutton? (or/c string? objc-object? #f) boolean?)]
  [nsbutton-prepare-for-reuse (c-> nsbutton? void?)]
  [nsbutton-pressure-change-with-event (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-quick-look-preview-items (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-quick-look-with-event (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-rect-for-smart-magnification-at-point-in-rect (c-> nsbutton? any/c any/c any/c)]
  [nsbutton-remove-all-tool-tips! (c-> nsbutton? void?)]
  [nsbutton-remove-from-superview! (c-> nsbutton? void?)]
  [nsbutton-remove-from-superview-without-needing-display! (c-> nsbutton? void?)]
  [nsbutton-remove-tool-tip! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-replace-subview-with! (c-> nsbutton? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsbutton-resign-first-responder (c-> nsbutton? boolean?)]
  [nsbutton-resize-subviews-with-old-size (c-> nsbutton? any/c void?)]
  [nsbutton-resize-with-old-superview-size (c-> nsbutton? any/c void?)]
  [nsbutton-restore-user-activity-state (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-right-mouse-down (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-right-mouse-dragged (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-right-mouse-up (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-rotate-by-angle (c-> nsbutton? real? void?)]
  [nsbutton-rotate-with-event (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-scale-unit-square-to-size (c-> nsbutton? any/c void?)]
  [nsbutton-scroll-line-down (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-scroll-line-up (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-scroll-page-down (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-scroll-page-up (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-scroll-point (c-> nsbutton? any/c void?)]
  [nsbutton-scroll-rect-to-visible (c-> nsbutton? any/c boolean?)]
  [nsbutton-scroll-to-beginning-of-document (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-scroll-to-end-of-document (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-scroll-wheel (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-select-all (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-select-line (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-select-paragraph (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-select-to-mark (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-select-word (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-send-action-to (c-> nsbutton? string? (or/c string? objc-object? #f) boolean?)]
  [nsbutton-send-action-on (c-> nsbutton? exact-nonnegative-integer? exact-integer?)]
  [nsbutton-set-accessibility-activation-point! (c-> nsbutton? any/c void?)]
  [nsbutton-set-accessibility-allowed-values! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-alternate-ui-visible! (c-> nsbutton? boolean? void?)]
  [nsbutton-set-accessibility-application-focused-ui-element! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-attributed-user-input-labels! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-cancel-button! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-children! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-children-in-navigation-order! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-clear-button! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-close-button! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-column-count! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-set-accessibility-column-header-ui-elements! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-column-index-range! (c-> nsbutton? any/c void?)]
  [nsbutton-set-accessibility-column-titles! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-columns! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-contents! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-critical-value! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-custom-actions! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-custom-rotors! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-decrement-button! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-default-button! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-disclosed! (c-> nsbutton? boolean? void?)]
  [nsbutton-set-accessibility-disclosed-by-row! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-disclosed-rows! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-disclosure-level! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-set-accessibility-document! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-edited! (c-> nsbutton? boolean? void?)]
  [nsbutton-set-accessibility-element! (c-> nsbutton? boolean? void?)]
  [nsbutton-set-accessibility-enabled! (c-> nsbutton? boolean? void?)]
  [nsbutton-set-accessibility-expanded! (c-> nsbutton? boolean? void?)]
  [nsbutton-set-accessibility-extras-menu-bar! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-filename! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-focused! (c-> nsbutton? boolean? void?)]
  [nsbutton-set-accessibility-focused-window! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-frame! (c-> nsbutton? any/c void?)]
  [nsbutton-set-accessibility-frontmost! (c-> nsbutton? boolean? void?)]
  [nsbutton-set-accessibility-full-screen-button! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-grow-area! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-handles! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-header! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-help! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-hidden! (c-> nsbutton? boolean? void?)]
  [nsbutton-set-accessibility-horizontal-scroll-bar! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-horizontal-unit-description! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-horizontal-units! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-set-accessibility-identifier! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-increment-button! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-index! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-set-accessibility-insertion-point-line-number! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-set-accessibility-label! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-label-ui-elements! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-label-value! (c-> nsbutton? real? void?)]
  [nsbutton-set-accessibility-linked-ui-elements! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-main! (c-> nsbutton? boolean? void?)]
  [nsbutton-set-accessibility-main-window! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-marker-group-ui-element! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-marker-type-description! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-marker-ui-elements! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-marker-values! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-max-value! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-menu-bar! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-min-value! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-minimize-button! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-minimized! (c-> nsbutton? boolean? void?)]
  [nsbutton-set-accessibility-modal! (c-> nsbutton? boolean? void?)]
  [nsbutton-set-accessibility-next-contents! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-number-of-characters! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-set-accessibility-ordered-by-row! (c-> nsbutton? boolean? void?)]
  [nsbutton-set-accessibility-orientation! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-set-accessibility-overflow-button! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-parent! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-placeholder-value! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-previous-contents! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-protected-content! (c-> nsbutton? boolean? void?)]
  [nsbutton-set-accessibility-proxy! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-required! (c-> nsbutton? boolean? void?)]
  [nsbutton-set-accessibility-role! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-role-description! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-row-count! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-set-accessibility-row-header-ui-elements! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-row-index-range! (c-> nsbutton? any/c void?)]
  [nsbutton-set-accessibility-rows! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-ruler-marker-type! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-set-accessibility-search-button! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-search-menu! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-selected! (c-> nsbutton? boolean? void?)]
  [nsbutton-set-accessibility-selected-cells! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-selected-children! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-selected-columns! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-selected-rows! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-selected-text! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-selected-text-range! (c-> nsbutton? any/c void?)]
  [nsbutton-set-accessibility-selected-text-ranges! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-serves-as-title-for-ui-elements! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-shared-character-range! (c-> nsbutton? any/c void?)]
  [nsbutton-set-accessibility-shared-focus-elements! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-shared-text-ui-elements! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-shown-menu! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-sort-direction! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-set-accessibility-splitters! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-subrole! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-tabs! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-title! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-title-ui-element! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-toolbar-button! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-top-level-ui-element! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-url! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-unit-description! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-units! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-set-accessibility-user-input-labels! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-value! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-value-description! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-vertical-scroll-bar! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-vertical-unit-description! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-vertical-units! (c-> nsbutton? exact-integer? void?)]
  [nsbutton-set-accessibility-visible-cells! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-visible-character-range! (c-> nsbutton? any/c void?)]
  [nsbutton-set-accessibility-visible-children! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-visible-columns! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-visible-rows! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-warning-value! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-window! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-windows! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-accessibility-zoom-button! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-animations! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-appearance! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-bounds-origin! (c-> nsbutton? any/c void?)]
  [nsbutton-set-bounds-size! (c-> nsbutton? any/c void?)]
  [nsbutton-set-button-type! (c-> nsbutton? exact-nonnegative-integer? void?)]
  [nsbutton-set-frame-origin! (c-> nsbutton? any/c void?)]
  [nsbutton-set-frame-size! (c-> nsbutton? any/c void?)]
  [nsbutton-set-identifier! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-mark! (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-set-needs-display-in-rect! (c-> nsbutton? any/c void?)]
  [nsbutton-set-next-state! (c-> nsbutton? void?)]
  [nsbutton-set-periodic-delay-interval! (c-> nsbutton? real? real? void?)]
  [nsbutton-should-be-treated-as-ink-event (c-> nsbutton? (or/c string? objc-object? #f) boolean?)]
  [nsbutton-should-delay-window-ordering-for-event (c-> nsbutton? (or/c string? objc-object? #f) boolean?)]
  [nsbutton-show-context-help (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-show-context-menu-for-selection (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-size-that-fits (c-> nsbutton? any/c any/c)]
  [nsbutton-size-to-fit (c-> nsbutton? void?)]
  [nsbutton-smart-magnify-with-event (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-sort-subviews-using-function-context (c-> nsbutton? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nsbutton-supplemental-target-for-action-sender (c-> nsbutton? string? (or/c string? objc-object? #f) any/c)]
  [nsbutton-swap-with-mark (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-swipe-with-event (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-tablet-point (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-tablet-proximity (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-take-double-value-from (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-take-float-value-from (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-take-int-value-from (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-take-integer-value-from (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-take-object-value-from (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-take-string-value-from (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-touches-began-with-event (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-touches-cancelled-with-event (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-touches-ended-with-event (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-touches-moved-with-event (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-translate-origin-to-point (c-> nsbutton? any/c void?)]
  [nsbutton-translate-rects-needing-display-in-rect-by (c-> nsbutton? any/c any/c void?)]
  [nsbutton-transpose (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-transpose-words (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-try-to-perform-with (c-> nsbutton? string? (or/c string? objc-object? #f) boolean?)]
  [nsbutton-update-dragging-items-for-drag (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-update-layer (c-> nsbutton? void?)]
  [nsbutton-uppercase-word (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-valid-requestor-for-send-type-return-type (c-> nsbutton? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nsbutton-validate-user-interface-item (c-> nsbutton? (or/c string? objc-object? #f) boolean?)]
  [nsbutton-view-did-change-backing-properties (c-> nsbutton? void?)]
  [nsbutton-view-did-change-effective-appearance (c-> nsbutton? void?)]
  [nsbutton-view-did-end-live-resize (c-> nsbutton? void?)]
  [nsbutton-view-did-hide (c-> nsbutton? void?)]
  [nsbutton-view-did-move-to-superview (c-> nsbutton? void?)]
  [nsbutton-view-did-move-to-window (c-> nsbutton? void?)]
  [nsbutton-view-did-unhide (c-> nsbutton? void?)]
  [nsbutton-view-will-draw (c-> nsbutton? void?)]
  [nsbutton-view-will-move-to-superview (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-view-will-move-to-window (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-view-will-start-live-resize (c-> nsbutton? void?)]
  [nsbutton-view-with-tag (c-> nsbutton? exact-integer? any/c)]
  [nsbutton-wants-forwarded-scroll-events-for-axis (c-> nsbutton? exact-integer? boolean?)]
  [nsbutton-wants-periodic-dragging-updates (c-> nsbutton? boolean?)]
  [nsbutton-wants-scroll-events-for-swipe-tracking-on-axis (c-> nsbutton? exact-integer? boolean?)]
  [nsbutton-will-open-menu-with-event (c-> nsbutton? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsbutton-will-remove-subview (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-yank (c-> nsbutton? (or/c string? objc-object? #f) void?)]
  [nsbutton-button-with-image-target-action (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) string? any/c)]
  [nsbutton-button-with-title-image-target-action (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) string? any/c)]
  [nsbutton-button-with-title-target-action (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) string? any/c)]
  [nsbutton-checkbox-with-title-target-action (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) string? any/c)]
  [nsbutton-default-animation-for-key (c-> (or/c string? objc-object? #f) any/c)]
  [nsbutton-is-compatible-with-responsive-scrolling (c-> boolean?)]
  [nsbutton-radio-button-with-title-target-action (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) string? any/c)]
  )

;; --- Class reference ---
(import-class NSButton)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_i (-> ptr_t ptr_t int32_t))
(define-aw-msg aw_racket_msg_0_q (-> ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_0_Q (-> ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_0_f (-> ptr_t ptr_t float_t))
(define-aw-msg aw_racket_msg_0_d (-> ptr_t ptr_t double_t))
(define-aw-msg aw_racket_msg_0_R (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_0_O (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_0_Z (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_0_G (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_0_E (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_0_v (-> ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_b (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_P_Q (-> ptr_t ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_P_Z (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_b (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PPPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PqP_v (-> ptr_t ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_b_v (-> ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_i_v (-> ptr_t ptr_t int32_t void_t))
(define-aw-msg aw_racket_msg_q_P (-> ptr_t ptr_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_q_b (-> ptr_t ptr_t int64_t bool_t))
(define-aw-msg aw_racket_msg_q_q (-> ptr_t ptr_t int64_t int64_t))
(define-aw-msg aw_racket_msg_q_G (-> ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_q_v (-> ptr_t ptr_t int64_t void_t))
(define-aw-msg aw_racket_msg_qq_P (-> ptr_t ptr_t int64_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_Q_q (-> ptr_t ptr_t uint64_t int64_t))
(define-aw-msg aw_racket_msg_Q_v (-> ptr_t ptr_t uint64_t void_t))
(define-aw-msg aw_racket_msg_f_v (-> ptr_t ptr_t float_t void_t))
(define-aw-msg aw_racket_msg_ff_v (-> ptr_t ptr_t float_t float_t void_t))
(define-aw-msg aw_racket_msg_d_v (-> ptr_t ptr_t double_t void_t))
(define-aw-msg aw_racket_msg_R_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_R_b (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_R_R (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_R_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RP_R (-> ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RPP_q (-> ptr_t ptr_t ptr_t ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_RQ_R (-> ptr_t ptr_t ptr_t uint64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RZ_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_O_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_O_O (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_O_G (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_O_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_OP_O (-> ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_OR_b (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_OR_R (-> ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_Z_Z (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_Z_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_ZP_Z (-> ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_G_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_G_R (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_G_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_E_v (-> ptr_t ptr_t ptr_t void_t))

;; --- Constructors ---
(define (make-nsbutton-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSButton alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nsbutton-init-with-frame frame-rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (tell NSButton alloc)) (id->ffi2-ptr (sel_registerName "initWithFrame:")) (id->ffi2-ptr frame-rect)))
   #:retained #t))


;; --- Properties ---
(define (nsbutton-accepts-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsFirstResponder"))))
(define (nsbutton-accepts-touch-events self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsTouchEvents"))))
(define (nsbutton-set-accepts-touch-events! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAcceptsTouchEvents:")) value))
(define (nsbutton-action self)
  (ptr_t->cpointer (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "action")))))
(define (nsbutton-set-action! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAction:")) (id->ffi2-ptr (sel_registerName value))))
(define (nsbutton-active-compression-options self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "activeCompressionOptions"))))))
(define (nsbutton-additional-safe-area-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "additionalSafeAreaInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nsbutton-set-additional-safe-area-insets! self value)
  (aw_racket_msg_E_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAdditionalSafeAreaInsets:")) (id->ffi2-ptr value)))
(define (nsbutton-alignment self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignment"))))
(define (nsbutton-set-alignment! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlignment:")) value))
(define (nsbutton-alignment-rect-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignmentRectInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nsbutton-allowed-touch-types self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowedTouchTypes"))))
(define (nsbutton-set-allowed-touch-types! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowedTouchTypes:")) value))
(define (nsbutton-allows-expansion-tool-tips self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsExpansionToolTips"))))
(define (nsbutton-set-allows-expansion-tool-tips! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsExpansionToolTips:")) value))
(define (nsbutton-allows-mixed-state self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsMixedState"))))
(define (nsbutton-set-allows-mixed-state! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsMixedState:")) value))
(define (nsbutton-allows-vibrancy self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsVibrancy"))))
(define (nsbutton-alpha-value self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alphaValue"))))
(define (nsbutton-set-alpha-value! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlphaValue:")) value))
(define (nsbutton-alternate-image self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alternateImage"))))))
(define (nsbutton-set-alternate-image! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlternateImage:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-alternate-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alternateTitle"))))))
(define (nsbutton-set-alternate-title! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlternateTitle:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-attributed-alternate-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "attributedAlternateTitle"))))))
(define (nsbutton-set-attributed-alternate-title! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAttributedAlternateTitle:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-attributed-string-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "attributedStringValue"))))))
(define (nsbutton-set-attributed-string-value! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAttributedStringValue:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-attributed-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "attributedTitle"))))))
(define (nsbutton-set-attributed-title! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAttributedTitle:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-autoresizes-subviews self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoresizesSubviews"))))
(define (nsbutton-set-autoresizes-subviews! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutoresizesSubviews:")) value))
(define (nsbutton-autoresizing-mask self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoresizingMask"))))
(define (nsbutton-set-autoresizing-mask! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutoresizingMask:")) value))
(define (nsbutton-background-filters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backgroundFilters"))))))
(define (nsbutton-set-background-filters! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBackgroundFilters:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-base-writing-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "baseWritingDirection"))))
(define (nsbutton-set-base-writing-direction! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBaseWritingDirection:")) value))
(define (nsbutton-baseline-offset-from-bottom self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "baselineOffsetFromBottom"))))
(define (nsbutton-bezel-color self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bezelColor"))))))
(define (nsbutton-set-bezel-color! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBezelColor:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-bezel-style self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bezelStyle"))))
(define (nsbutton-set-bezel-style! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBezelStyle:")) value))
(define (nsbutton-border-shape self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "borderShape"))))
(define (nsbutton-set-border-shape! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBorderShape:")) value))
(define (nsbutton-bordered self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bordered"))))
(define (nsbutton-set-bordered! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBordered:")) value))
(define (nsbutton-bottom-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bottomAnchor"))))))
(define (nsbutton-bounds self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bounds")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-set-bounds! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBounds:")) (id->ffi2-ptr value)))
(define (nsbutton-bounds-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "boundsRotation"))))
(define (nsbutton-set-bounds-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsRotation:")) value))
(define (nsbutton-can-become-key-view self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canBecomeKeyView"))))
(define (nsbutton-can-draw self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDraw"))))
(define (nsbutton-can-draw-concurrently self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDrawConcurrently"))))
(define (nsbutton-set-can-draw-concurrently! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCanDrawConcurrently:")) value))
(define (nsbutton-can-draw-subviews-into-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDrawSubviewsIntoLayer"))))
(define (nsbutton-set-can-draw-subviews-into-layer! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCanDrawSubviewsIntoLayer:")) value))
(define (nsbutton-candidate-list-touch-bar-item self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "candidateListTouchBarItem"))))))
(define (nsbutton-cell self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cell"))))))
(define (nsbutton-set-cell! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCell:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-cell-class)
  (ptr_t->cpointer (aw_racket_msg_0_P (id->ffi2-ptr NSButton) (id->ffi2-ptr (sel_registerName "cellClass")))))
(define (nsbutton-set-cell-class! value)
  (aw_racket_msg_P_v (id->ffi2-ptr NSButton) (id->ffi2-ptr (sel_registerName "setCellClass:")) (id->ffi2-ptr value)))
(define (nsbutton-center-x-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerXAnchor"))))))
(define (nsbutton-center-y-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerYAnchor"))))))
(define (nsbutton-clips-to-bounds self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "clipsToBounds"))))
(define (nsbutton-set-clips-to-bounds! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setClipsToBounds:")) value))
(define (nsbutton-compatible-with-responsive-scrolling)
  (aw_racket_msg_0_b (id->ffi2-ptr NSButton) (id->ffi2-ptr (sel_registerName "compatibleWithResponsiveScrolling"))))
(define (nsbutton-compositing-filter self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "compositingFilter"))))))
(define (nsbutton-set-compositing-filter! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCompositingFilter:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-constraints self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "constraints"))))))
(define (nsbutton-content-filters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentFilters"))))))
(define (nsbutton-set-content-filters! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentFilters:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-content-tint-color self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentTintColor"))))))
(define (nsbutton-set-content-tint-color! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentTintColor:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-continuous self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "continuous"))))
(define (nsbutton-set-continuous! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContinuous:")) value))
(define (nsbutton-control-size self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "controlSize"))))
(define (nsbutton-set-control-size! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setControlSize:")) value))
(define (nsbutton-default-focus-ring-type)
  (aw_racket_msg_0_Q (id->ffi2-ptr NSButton) (id->ffi2-ptr (sel_registerName "defaultFocusRingType"))))
(define (nsbutton-default-menu)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSButton) (id->ffi2-ptr (sel_registerName "defaultMenu"))))))
(define (nsbutton-double-value self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "doubleValue"))))
(define (nsbutton-set-double-value! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDoubleValue:")) value))
(define (nsbutton-drawing-find-indicator self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawingFindIndicator"))))
(define (nsbutton-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enabled"))))
(define (nsbutton-set-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setEnabled:")) value))
(define (nsbutton-enclosing-menu-item self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enclosingMenuItem"))))))
(define (nsbutton-enclosing-scroll-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enclosingScrollView"))))))
(define (nsbutton-first-baseline-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstBaselineAnchor"))))))
(define (nsbutton-first-baseline-offset-from-top self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstBaselineOffsetFromTop"))))
(define (nsbutton-fitting-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fittingSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsbutton-flipped self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flipped"))))
(define (nsbutton-float-value self)
  (aw_racket_msg_0_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "floatValue"))))
(define (nsbutton-set-float-value! self value)
  (aw_racket_msg_f_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFloatValue:")) value))
(define (nsbutton-focus-ring-mask-bounds self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "focusRingMaskBounds")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-focus-ring-type self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "focusRingType"))))
(define (nsbutton-set-focus-ring-type! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFocusRingType:")) value))
(define (nsbutton-focus-view)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSButton) (id->ffi2-ptr (sel_registerName "focusView"))))))
(define (nsbutton-font self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "font"))))))
(define (nsbutton-set-font! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFont:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-formatter self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "formatter"))))))
(define (nsbutton-set-formatter! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFormatter:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-set-frame! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrame:")) (id->ffi2-ptr value)))
(define (nsbutton-frame-center-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameCenterRotation"))))
(define (nsbutton-set-frame-center-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameCenterRotation:")) value))
(define (nsbutton-frame-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameRotation"))))
(define (nsbutton-set-frame-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameRotation:")) value))
(define (nsbutton-gesture-recognizers self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "gestureRecognizers"))))))
(define (nsbutton-set-gesture-recognizers! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setGestureRecognizers:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-has-ambiguous-layout self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasAmbiguousLayout"))))
(define (nsbutton-has-destructive-action self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasDestructiveAction"))))
(define (nsbutton-set-has-destructive-action! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHasDestructiveAction:")) value))
(define (nsbutton-height-adjust-limit self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "heightAdjustLimit"))))
(define (nsbutton-height-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "heightAnchor"))))))
(define (nsbutton-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hidden"))))
(define (nsbutton-set-hidden! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHidden:")) value))
(define (nsbutton-hidden-or-has-hidden-ancestor self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hiddenOrHasHiddenAncestor"))))
(define (nsbutton-highlighted self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "highlighted"))))
(define (nsbutton-set-highlighted! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHighlighted:")) value))
(define (nsbutton-horizontal-content-size-constraint-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "horizontalContentSizeConstraintActive"))))
(define (nsbutton-set-horizontal-content-size-constraint-active! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHorizontalContentSizeConstraintActive:")) value))
(define (nsbutton-ignores-multi-click self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "ignoresMultiClick"))))
(define (nsbutton-set-ignores-multi-click! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIgnoresMultiClick:")) value))
(define (nsbutton-image self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "image"))))))
(define (nsbutton-set-image! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setImage:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-image-hugs-title self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "imageHugsTitle"))))
(define (nsbutton-set-image-hugs-title! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setImageHugsTitle:")) value))
(define (nsbutton-image-position self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "imagePosition"))))
(define (nsbutton-set-image-position! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setImagePosition:")) value))
(define (nsbutton-image-scaling self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "imageScaling"))))
(define (nsbutton-set-image-scaling! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setImageScaling:")) value))
(define (nsbutton-in-full-screen-mode self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inFullScreenMode"))))
(define (nsbutton-in-live-resize self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inLiveResize"))))
(define (nsbutton-input-context self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inputContext"))))))
(define (nsbutton-int-value self)
  (aw_racket_msg_0_i (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "intValue"))))
(define (nsbutton-set-int-value! self value)
  (aw_racket_msg_i_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIntValue:")) value))
(define (nsbutton-integer-value self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "integerValue"))))
(define (nsbutton-set-integer-value! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIntegerValue:")) value))
(define (nsbutton-intrinsic-content-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "intrinsicContentSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsbutton-key-equivalent self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyEquivalent"))))))
(define (nsbutton-set-key-equivalent! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setKeyEquivalent:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-key-equivalent-modifier-mask self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyEquivalentModifierMask"))))
(define (nsbutton-set-key-equivalent-modifier-mask! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setKeyEquivalentModifierMask:")) value))
(define (nsbutton-last-baseline-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastBaselineAnchor"))))))
(define (nsbutton-last-baseline-offset-from-bottom self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastBaselineOffsetFromBottom"))))
(define (nsbutton-layer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layer"))))))
(define (nsbutton-set-layer! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayer:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-layer-contents-placement self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerContentsPlacement"))))
(define (nsbutton-set-layer-contents-placement! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerContentsPlacement:")) value))
(define (nsbutton-layer-contents-redraw-policy self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerContentsRedrawPolicy"))))
(define (nsbutton-set-layer-contents-redraw-policy! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerContentsRedrawPolicy:")) value))
(define (nsbutton-layer-uses-core-image-filters self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerUsesCoreImageFilters"))))
(define (nsbutton-set-layer-uses-core-image-filters! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerUsesCoreImageFilters:")) value))
(define (nsbutton-layout-guides self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutGuides"))))))
(define (nsbutton-layout-margins-guide self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutMarginsGuide"))))))
(define (nsbutton-leading-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "leadingAnchor"))))))
(define (nsbutton-left-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "leftAnchor"))))))
(define (nsbutton-line-break-mode self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lineBreakMode"))))
(define (nsbutton-set-line-break-mode! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLineBreakMode:")) value))
(define (nsbutton-max-accelerator-level self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "maxAcceleratorLevel"))))
(define (nsbutton-set-max-accelerator-level! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMaxAcceleratorLevel:")) value))
(define (nsbutton-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menu"))))))
(define (nsbutton-set-menu! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMenu:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-mouse-down-can-move-window self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDownCanMoveWindow"))))
(define (nsbutton-needs-display self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsDisplay"))))
(define (nsbutton-set-needs-display! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsDisplay:")) value))
(define (nsbutton-needs-layout self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsLayout"))))
(define (nsbutton-set-needs-layout! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsLayout:")) value))
(define (nsbutton-needs-panel-to-become-key self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsPanelToBecomeKey"))))
(define (nsbutton-needs-update-constraints self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsUpdateConstraints"))))
(define (nsbutton-set-needs-update-constraints! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsUpdateConstraints:")) value))
(define (nsbutton-next-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextKeyView"))))))
(define (nsbutton-set-next-key-view! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextKeyView:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-next-responder self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextResponder"))))))
(define (nsbutton-set-next-responder! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextResponder:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-next-valid-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextValidKeyView"))))))
(define (nsbutton-object-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "objectValue"))))))
(define (nsbutton-set-object-value! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setObjectValue:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-opaque self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "opaque"))))
(define (nsbutton-opaque-ancestor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "opaqueAncestor"))))))
(define (nsbutton-page-footer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageFooter"))))))
(define (nsbutton-page-header self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageHeader"))))))
(define (nsbutton-posts-bounds-changed-notifications self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "postsBoundsChangedNotifications"))))
(define (nsbutton-set-posts-bounds-changed-notifications! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPostsBoundsChangedNotifications:")) value))
(define (nsbutton-posts-frame-changed-notifications self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "postsFrameChangedNotifications"))))
(define (nsbutton-set-posts-frame-changed-notifications! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPostsFrameChangedNotifications:")) value))
(define (nsbutton-prefers-compact-control-size-metrics self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prefersCompactControlSizeMetrics"))))
(define (nsbutton-set-prefers-compact-control-size-metrics! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPrefersCompactControlSizeMetrics:")) value))
(define (nsbutton-prepared-content-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preparedContentRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-set-prepared-content-rect! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPreparedContentRect:")) (id->ffi2-ptr value)))
(define (nsbutton-preserves-content-during-live-resize self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preservesContentDuringLiveResize"))))
(define (nsbutton-pressure-configuration self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pressureConfiguration"))))))
(define (nsbutton-set-pressure-configuration! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPressureConfiguration:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-previous-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "previousKeyView"))))))
(define (nsbutton-previous-valid-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "previousValidKeyView"))))))
(define (nsbutton-print-job-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "printJobTitle"))))))
(define (nsbutton-rect-preserved-during-live-resize self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectPreservedDuringLiveResize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-refuses-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "refusesFirstResponder"))))
(define (nsbutton-set-refuses-first-responder! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setRefusesFirstResponder:")) value))
(define (nsbutton-registered-dragged-types self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "registeredDraggedTypes"))))))
(define (nsbutton-requires-constraint-based-layout)
  (aw_racket_msg_0_b (id->ffi2-ptr NSButton) (id->ffi2-ptr (sel_registerName "requiresConstraintBasedLayout"))))
(define (nsbutton-restorable-state-key-paths)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSButton) (id->ffi2-ptr (sel_registerName "restorableStateKeyPaths"))))))
(define (nsbutton-right-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightAnchor"))))))
(define (nsbutton-rotated-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotatedFromBase"))))
(define (nsbutton-rotated-or-scaled-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotatedOrScaledFromBase"))))
(define (nsbutton-safe-area-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nsbutton-safe-area-layout-guide self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaLayoutGuide"))))))
(define (nsbutton-safe-area-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-shadow self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shadow"))))))
(define (nsbutton-set-shadow! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShadow:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-shows-border-only-while-mouse-inside self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showsBorderOnlyWhileMouseInside"))))
(define (nsbutton-set-shows-border-only-while-mouse-inside! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShowsBorderOnlyWhileMouseInside:")) value))
(define (nsbutton-sound self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sound"))))))
(define (nsbutton-set-sound! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSound:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-spring-loaded self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "springLoaded"))))
(define (nsbutton-set-spring-loaded! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSpringLoaded:")) value))
(define (nsbutton-state self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "state"))))
(define (nsbutton-set-state! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setState:")) value))
(define (nsbutton-string-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringValue"))))))
(define (nsbutton-set-string-value! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setStringValue:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-subviews self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "subviews"))))))
(define (nsbutton-set-subviews! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSubviews:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-superview self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "superview"))))))
(define (nsbutton-symbol-configuration self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "symbolConfiguration"))))))
(define (nsbutton-set-symbol-configuration! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSymbolConfiguration:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-tag self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tag"))))
(define (nsbutton-set-tag! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTag:")) value))
(define (nsbutton-target self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "target"))))))
(define (nsbutton-set-target! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTarget:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-tint-prominence self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tintProminence"))))
(define (nsbutton-set-tint-prominence! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTintProminence:")) value))
(define (nsbutton-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "title"))))))
(define (nsbutton-set-title! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTitle:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-tool-tip self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "toolTip"))))))
(define (nsbutton-set-tool-tip! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setToolTip:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-top-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "topAnchor"))))))
(define (nsbutton-touch-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchBar"))))))
(define (nsbutton-set-touch-bar! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTouchBar:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-tracking-areas self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "trackingAreas"))))))
(define (nsbutton-trailing-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "trailingAnchor"))))))
(define (nsbutton-translates-autoresizing-mask-into-constraints self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translatesAutoresizingMaskIntoConstraints"))))
(define (nsbutton-set-translates-autoresizing-mask-into-constraints! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTranslatesAutoresizingMaskIntoConstraints:")) value))
(define (nsbutton-transparent self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transparent"))))
(define (nsbutton-set-transparent! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTransparent:")) value))
(define (nsbutton-undo-manager self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "undoManager"))))))
(define (nsbutton-user-activity self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userActivity"))))))
(define (nsbutton-set-user-activity! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserActivity:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsbutton-user-interface-layout-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userInterfaceLayoutDirection"))))
(define (nsbutton-set-user-interface-layout-direction! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserInterfaceLayoutDirection:")) value))
(define (nsbutton-uses-single-line-mode self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "usesSingleLineMode"))))
(define (nsbutton-set-uses-single-line-mode! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUsesSingleLineMode:")) value))
(define (nsbutton-vertical-content-size-constraint-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "verticalContentSizeConstraintActive"))))
(define (nsbutton-set-vertical-content-size-constraint-active! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setVerticalContentSizeConstraintActive:")) value))
(define (nsbutton-visible-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "visibleRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-wants-best-resolution-open-gl-surface self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsBestResolutionOpenGLSurface"))))
(define (nsbutton-set-wants-best-resolution-open-gl-surface! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsBestResolutionOpenGLSurface:")) value))
(define (nsbutton-wants-default-clipping self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsDefaultClipping"))))
(define (nsbutton-wants-extended-dynamic-range-open-gl-surface self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsExtendedDynamicRangeOpenGLSurface"))))
(define (nsbutton-set-wants-extended-dynamic-range-open-gl-surface! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsExtendedDynamicRangeOpenGLSurface:")) value))
(define (nsbutton-wants-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsLayer"))))
(define (nsbutton-set-wants-layer! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsLayer:")) value))
(define (nsbutton-wants-resting-touches self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsRestingTouches"))))
(define (nsbutton-set-wants-resting-touches! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsRestingTouches:")) value))
(define (nsbutton-wants-update-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsUpdateLayer"))))
(define (nsbutton-width-adjust-limit self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "widthAdjustLimit"))))
(define (nsbutton-width-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "widthAnchor"))))))
(define (nsbutton-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "window"))))))
(define (nsbutton-writing-tools-coordinator self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writingToolsCoordinator"))))))
(define (nsbutton-set-writing-tools-coordinator! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWritingToolsCoordinator:")) (id->ffi2-ptr (coerce-arg value))))

;; --- Instance methods ---
(define (nsbutton-accepts-first-mouse self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsFirstMouse:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-accessibility-activation-point self)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_0_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityActivationPoint")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsbutton-accessibility-allowed-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAllowedValues"))))
   ))
(define (nsbutton-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityApplicationFocusedUIElement"))))
   ))
(define (nsbutton-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nsbutton-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedUserInputLabels"))))
   ))
(define (nsbutton-accessibility-cancel-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCancelButton"))))
   ))
(define (nsbutton-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_qq_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCellForColumn:row:")) column row))
   ))
(define (nsbutton-accessibility-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildren"))))
   ))
(define (nsbutton-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildrenInNavigationOrder"))))
   ))
(define (nsbutton-accessibility-clear-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityClearButton"))))
   ))
(define (nsbutton-accessibility-close-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCloseButton"))))
   ))
(define (nsbutton-accessibility-column-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnCount"))))
(define (nsbutton-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnHeaderUIElements"))))
   ))
(define (nsbutton-accessibility-column-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsbutton-accessibility-column-titles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnTitles"))))
   ))
(define (nsbutton-accessibility-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumns"))))
   ))
(define (nsbutton-accessibility-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityContents"))))
   ))
(define (nsbutton-accessibility-critical-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCriticalValue"))))
   ))
(define (nsbutton-accessibility-custom-actions self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomActions"))))
   ))
(define (nsbutton-accessibility-custom-rotors self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomRotors"))))
   ))
(define (nsbutton-accessibility-decrement-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDecrementButton"))))
   ))
(define (nsbutton-accessibility-default-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDefaultButton"))))
   ))
(define (nsbutton-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedByRow"))))
   ))
(define (nsbutton-accessibility-disclosed-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedRows"))))
   ))
(define (nsbutton-accessibility-disclosure-level self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosureLevel"))))
(define (nsbutton-accessibility-document self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDocument"))))
   ))
(define (nsbutton-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityExtrasMenuBar"))))
   ))
(define (nsbutton-accessibility-filename self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFilename"))))
   ))
(define (nsbutton-accessibility-focused-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFocusedWindow"))))
   ))
(define (nsbutton-accessibility-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-accessibility-frame-for-range self range)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_G_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrameForRange:")) (id->ffi2-ptr range) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-accessibility-full-screen-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFullScreenButton"))))
   ))
(define (nsbutton-accessibility-grow-area self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityGrowArea"))))
   ))
(define (nsbutton-accessibility-handles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHandles"))))
   ))
(define (nsbutton-accessibility-header self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHeader"))))
   ))
(define (nsbutton-accessibility-help self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHelp"))))
   ))
(define (nsbutton-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalScrollBar"))))
   ))
(define (nsbutton-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnitDescription"))))
   ))
(define (nsbutton-accessibility-horizontal-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnits"))))
(define (nsbutton-accessibility-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIdentifier"))))
   ))
(define (nsbutton-accessibility-increment-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIncrementButton"))))
   ))
(define (nsbutton-accessibility-index self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIndex"))))
(define (nsbutton-accessibility-insertion-point-line-number self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityInsertionPointLineNumber"))))
(define (nsbutton-accessibility-label self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabel"))))
   ))
(define (nsbutton-accessibility-label-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelUIElements"))))
   ))
(define (nsbutton-accessibility-label-value self)
  (aw_racket_msg_0_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelValue"))))
(define (nsbutton-accessibility-layout-point-for-screen-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutPointForScreenPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsbutton-accessibility-layout-size-for-screen-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutSizeForScreenSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsbutton-accessibility-line-for-index self index)
  (aw_racket_msg_q_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLineForIndex:")) index))
(define (nsbutton-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLinkedUIElements"))))
   ))
(define (nsbutton-accessibility-main-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMainWindow"))))
   ))
(define (nsbutton-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerGroupUIElement"))))
   ))
(define (nsbutton-accessibility-marker-type-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerTypeDescription"))))
   ))
(define (nsbutton-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerUIElements"))))
   ))
(define (nsbutton-accessibility-marker-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerValues"))))
   ))
(define (nsbutton-accessibility-max-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMaxValue"))))
   ))
(define (nsbutton-accessibility-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMenuBar"))))
   ))
(define (nsbutton-accessibility-min-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinValue"))))
   ))
(define (nsbutton-accessibility-minimize-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinimizeButton"))))
   ))
(define (nsbutton-accessibility-next-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNextContents"))))
   ))
(define (nsbutton-accessibility-number-of-characters self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNumberOfCharacters"))))
(define (nsbutton-accessibility-orientation self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOrientation"))))
(define (nsbutton-accessibility-overflow-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOverflowButton"))))
   ))
(define (nsbutton-accessibility-parent self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityParent"))))
   ))
(define (nsbutton-accessibility-perform-cancel self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformCancel"))))
(define (nsbutton-accessibility-perform-confirm self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformConfirm"))))
(define (nsbutton-accessibility-perform-decrement self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDecrement"))))
(define (nsbutton-accessibility-perform-delete self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDelete"))))
(define (nsbutton-accessibility-perform-increment self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformIncrement"))))
(define (nsbutton-accessibility-perform-pick self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPick"))))
(define (nsbutton-accessibility-perform-press self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPress"))))
(define (nsbutton-accessibility-perform-raise self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformRaise"))))
(define (nsbutton-accessibility-perform-show-alternate-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowAlternateUI"))))
(define (nsbutton-accessibility-perform-show-default-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowDefaultUI"))))
(define (nsbutton-accessibility-perform-show-menu self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowMenu"))))
(define (nsbutton-accessibility-placeholder-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPlaceholderValue"))))
   ))
(define (nsbutton-accessibility-previous-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPreviousContents"))))
   ))
(define (nsbutton-accessibility-proxy self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityProxy"))))
   ))
(define (nsbutton-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRTFForRange:")) (id->ffi2-ptr range)))
   ))
(define (nsbutton-accessibility-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsbutton-accessibility-range-for-line self line)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForLine:")) line (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsbutton-accessibility-range-for-position self point)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_O_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForPosition:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsbutton-accessibility-role self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRole"))))
   ))
(define (nsbutton-accessibility-role-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRoleDescription"))))
   ))
(define (nsbutton-accessibility-row-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowCount"))))
(define (nsbutton-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowHeaderUIElements"))))
   ))
(define (nsbutton-accessibility-row-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsbutton-accessibility-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRows"))))
   ))
(define (nsbutton-accessibility-ruler-marker-type self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRulerMarkerType"))))
(define (nsbutton-accessibility-screen-point-for-layout-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenPointForLayoutPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsbutton-accessibility-screen-size-for-layout-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenSizeForLayoutSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsbutton-accessibility-search-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchButton"))))
   ))
(define (nsbutton-accessibility-search-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchMenu"))))
   ))
(define (nsbutton-accessibility-selected-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedCells"))))
   ))
(define (nsbutton-accessibility-selected-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedChildren"))))
   ))
(define (nsbutton-accessibility-selected-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedColumns"))))
   ))
(define (nsbutton-accessibility-selected-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedRows"))))
   ))
(define (nsbutton-accessibility-selected-text self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedText"))))
   ))
(define (nsbutton-accessibility-selected-text-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsbutton-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRanges"))))
   ))
(define (nsbutton-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityServesAsTitleForUIElements"))))
   ))
(define (nsbutton-accessibility-shared-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsbutton-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedFocusElements"))))
   ))
(define (nsbutton-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedTextUIElements"))))
   ))
(define (nsbutton-accessibility-shown-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityShownMenu"))))
   ))
(define (nsbutton-accessibility-sort-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySortDirection"))))
(define (nsbutton-accessibility-splitters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySplitters"))))
   ))
(define (nsbutton-accessibility-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nsbutton-accessibility-style-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStyleRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsbutton-accessibility-subrole self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySubrole"))))
   ))
(define (nsbutton-accessibility-tabs self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTabs"))))
   ))
(define (nsbutton-accessibility-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitle"))))
   ))
(define (nsbutton-accessibility-title-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitleUIElement"))))
   ))
(define (nsbutton-accessibility-toolbar-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityToolbarButton"))))
   ))
(define (nsbutton-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTopLevelUIElement"))))
   ))
(define (nsbutton-accessibility-url self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityURL"))))
   ))
(define (nsbutton-accessibility-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnitDescription"))))
   ))
(define (nsbutton-accessibility-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnits"))))
(define (nsbutton-accessibility-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUserInputLabels"))))
   ))
(define (nsbutton-accessibility-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValue"))))
   ))
(define (nsbutton-accessibility-value-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValueDescription"))))
   ))
(define (nsbutton-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalScrollBar"))))
   ))
(define (nsbutton-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnitDescription"))))
   ))
(define (nsbutton-accessibility-vertical-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnits"))))
(define (nsbutton-accessibility-visible-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCells"))))
   ))
(define (nsbutton-accessibility-visible-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsbutton-accessibility-visible-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleChildren"))))
   ))
(define (nsbutton-accessibility-visible-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleColumns"))))
   ))
(define (nsbutton-accessibility-visible-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleRows"))))
   ))
(define (nsbutton-accessibility-warning-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWarningValue"))))
   ))
(define (nsbutton-accessibility-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindow"))))
   ))
(define (nsbutton-accessibility-windows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindows"))))
   ))
(define (nsbutton-accessibility-zoom-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityZoomButton"))))
   ))
(define (nsbutton-add-subview! self view)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addSubview:")) (id->ffi2-ptr (coerce-arg view))))
(define (nsbutton-add-subview-positioned-relative-to! self view place other-view)
  (aw_racket_msg_PqP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addSubview:positioned:relativeTo:")) (id->ffi2-ptr (coerce-arg view)) place (id->ffi2-ptr (coerce-arg other-view))))
(define (nsbutton-add-tool-tip-rect-owner-user-data! self rect owner data)
  (aw_racket_msg_RPP_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addToolTipRect:owner:userData:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg owner)) (id->ffi2-ptr data)))
(define (nsbutton-adjust-scroll self new-visible)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "adjustScroll:")) (id->ffi2-ptr new-visible) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-ancestor-shared-with-view self view)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "ancestorSharedWithView:")) (id->ffi2-ptr (coerce-arg view))))
   ))
(define (nsbutton-animation-for-key self key)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animationForKey:")) (id->ffi2-ptr (coerce-arg key))))
   ))
(define (nsbutton-animations self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animations"))))
   ))
(define (nsbutton-animator self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animator"))))
   ))
(define (nsbutton-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "appearance"))))
   ))
(define (nsbutton-autoscroll self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoscroll:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-backing-aligned-rect-options self rect options)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RQ_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backingAlignedRect:options:")) (id->ffi2-ptr rect) options (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-become-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "becomeFirstResponder"))))
(define (nsbutton-begin-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-bitmap-image-rep-for-caching-display-in-rect self rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bitmapImageRepForCachingDisplayInRect:")) (id->ffi2-ptr rect)))
   ))
(define (nsbutton-cache-display-in-rect-to-bitmap-image-rep self rect bitmap-image-rep)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cacheDisplayInRect:toBitmapImageRep:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg bitmap-image-rep))))
(define (nsbutton-cancel-operation self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cancelOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-capitalize-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "capitalizeWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-center-scan-rect! self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerScanRect:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-center-selection-in-visible-area! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerSelectionInVisibleArea:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-change-case-of-letter self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeCaseOfLetter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-change-mode-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeModeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-complete self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "complete:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-compress-with-prioritized-compression-options self prioritized-options)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "compressWithPrioritizedCompressionOptions:")) (id->ffi2-ptr (coerce-arg prioritized-options))))
(define (nsbutton-conclude-drag-operation self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "concludeDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-context-menu-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contextMenuKeyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-convert-point-from-view self point view)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_OP_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPoint:fromView:")) (id->ffi2-ptr point) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsbutton-convert-point-to-view self point view)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_OP_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPoint:toView:")) (id->ffi2-ptr point) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsbutton-convert-point-from-backing self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointFromBacking:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsbutton-convert-point-from-layer self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointFromLayer:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsbutton-convert-point-to-backing self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointToBacking:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsbutton-convert-point-to-layer self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointToLayer:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsbutton-convert-rect-from-view self rect view)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RP_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRect:fromView:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-convert-rect-to-view self rect view)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RP_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRect:toView:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-convert-rect-from-backing self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectFromBacking:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-convert-rect-from-layer self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectFromLayer:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-convert-rect-to-backing self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectToBacking:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-convert-rect-to-layer self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectToLayer:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-convert-size-from-view self size view)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_ZP_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSize:fromView:")) (id->ffi2-ptr size) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsbutton-convert-size-to-view self size view)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_ZP_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSize:toView:")) (id->ffi2-ptr size) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsbutton-convert-size-from-backing self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeFromBacking:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsbutton-convert-size-from-layer self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeFromLayer:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsbutton-convert-size-to-backing self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeToBacking:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsbutton-convert-size-to-layer self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeToLayer:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsbutton-cursor-update self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cursorUpdate:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-delete-backward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-delete-backward-by-decomposing-previous-character self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteBackwardByDecomposingPreviousCharacter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-delete-forward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-delete-to-beginning-of-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToBeginningOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-delete-to-beginning-of-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToBeginningOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-delete-to-end-of-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-delete-to-end-of-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToEndOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-delete-to-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-delete-word-backward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteWordBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-delete-word-forward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteWordForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-did-add-subview self subview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "didAddSubview:")) (id->ffi2-ptr (coerce-arg subview))))
(define (nsbutton-did-close-menu-with-event self menu event)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "didCloseMenu:withEvent:")) (id->ffi2-ptr (coerce-arg menu)) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-display! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "display"))))
(define (nsbutton-display-if-needed! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeeded"))))
(define (nsbutton-display-if-needed-ignoring-opacity! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededIgnoringOpacity"))))
(define (nsbutton-display-if-needed-in-rect! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededInRect:")) (id->ffi2-ptr rect)))
(define (nsbutton-display-if-needed-in-rect-ignoring-opacity! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededInRectIgnoringOpacity:")) (id->ffi2-ptr rect)))
(define (nsbutton-display-rect! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRect:")) (id->ffi2-ptr rect)))
(define (nsbutton-display-rect-ignoring-opacity! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRectIgnoringOpacity:")) (id->ffi2-ptr rect)))
(define (nsbutton-display-rect-ignoring-opacity-in-context! self rect context)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRectIgnoringOpacity:inContext:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg context))))
(define (nsbutton-do-command-by-selector self selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "doCommandBySelector:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nsbutton-dragging-ended self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingEnded:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-dragging-entered self sender)
  (aw_racket_msg_P_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingEntered:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-dragging-exited self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingExited:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-dragging-updated self sender)
  (aw_racket_msg_P_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingUpdated:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-draw-rect self dirty-rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawRect:")) (id->ffi2-ptr dirty-rect)))
(define (nsbutton-draw-with-expansion-frame-in-view self content-frame view)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawWithExpansionFrame:inView:")) (id->ffi2-ptr content-frame) (id->ffi2-ptr (coerce-arg view))))
(define (nsbutton-effective-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "effectiveAppearance"))))
   ))
(define (nsbutton-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nsbutton-end-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-expansion-frame-with-frame self content-frame)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "expansionFrameWithFrame:")) (id->ffi2-ptr content-frame) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-flags-changed self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flagsChanged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-flush-buffered-key-events self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flushBufferedKeyEvents"))))
(define (nsbutton-get-periodic-delay-interval self delay interval)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getPeriodicDelay:interval:")) (id->ffi2-ptr delay) (id->ffi2-ptr interval)))
(define (nsbutton-get-rects-being-drawn-count self rects count)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getRectsBeingDrawn:count:")) (id->ffi2-ptr rects) (id->ffi2-ptr count)))
(define (nsbutton-get-rects-exposed-during-live-resize-count self exposed-rects count)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getRectsExposedDuringLiveResize:count:")) (id->ffi2-ptr exposed-rects) (id->ffi2-ptr count)))
(define (nsbutton-help-requested self event-ptr)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "helpRequested:")) (id->ffi2-ptr (coerce-arg event-ptr))))
(define (nsbutton-highlight self flag)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "highlight:")) flag))
(define (nsbutton-hit-test self point)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_O_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hitTest:")) (id->ffi2-ptr point)))
   ))
(define (nsbutton-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "identifier"))))
   ))
(define (nsbutton-indent self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indent:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-insert-backtab! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertBacktab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-insert-container-break! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertContainerBreak:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-insert-double-quote-ignoring-substitution! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertDoubleQuoteIgnoringSubstitution:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-insert-line-break! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertLineBreak:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-insert-newline! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertNewline:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-insert-newline-ignoring-field-editor! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertNewlineIgnoringFieldEditor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-insert-paragraph-separator! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertParagraphSeparator:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-insert-single-quote-ignoring-substitution! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertSingleQuoteIgnoringSubstitution:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-insert-tab! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-insert-tab-ignoring-field-editor! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTabIgnoringFieldEditor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-insert-text! self insert-string)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertText:")) (id->ffi2-ptr (coerce-arg insert-string))))
(define (nsbutton-interpret-key-events self event-array)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "interpretKeyEvents:")) (id->ffi2-ptr (coerce-arg event-array))))
(define (nsbutton-is-accessibility-alternate-ui-visible self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityAlternateUIVisible"))))
(define (nsbutton-is-accessibility-disclosed self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityDisclosed"))))
(define (nsbutton-is-accessibility-edited self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEdited"))))
(define (nsbutton-is-accessibility-element self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityElement"))))
(define (nsbutton-is-accessibility-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEnabled"))))
(define (nsbutton-is-accessibility-expanded self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityExpanded"))))
(define (nsbutton-is-accessibility-focused self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFocused"))))
(define (nsbutton-is-accessibility-frontmost self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFrontmost"))))
(define (nsbutton-is-accessibility-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityHidden"))))
(define (nsbutton-is-accessibility-main self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMain"))))
(define (nsbutton-is-accessibility-minimized self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMinimized"))))
(define (nsbutton-is-accessibility-modal self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityModal"))))
(define (nsbutton-is-accessibility-ordered-by-row self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityOrderedByRow"))))
(define (nsbutton-is-accessibility-protected-content self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityProtectedContent"))))
(define (nsbutton-is-accessibility-required self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityRequired"))))
(define (nsbutton-is-accessibility-selected self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelected"))))
(define (nsbutton-is-accessibility-selector-allowed self selector)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelectorAllowed:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nsbutton-is-bordered self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isBordered"))))
(define (nsbutton-is-continuous self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isContinuous"))))
(define (nsbutton-is-descendant-of self view)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isDescendantOf:")) (id->ffi2-ptr (coerce-arg view))))
(define (nsbutton-is-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isEnabled"))))
(define (nsbutton-is-flipped self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isFlipped"))))
(define (nsbutton-is-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHidden"))))
(define (nsbutton-is-hidden-or-has-hidden-ancestor self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHiddenOrHasHiddenAncestor"))))
(define (nsbutton-is-highlighted self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHighlighted"))))
(define (nsbutton-is-opaque self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isOpaque"))))
(define (nsbutton-is-rotated-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRotatedFromBase"))))
(define (nsbutton-is-rotated-or-scaled-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRotatedOrScaledFromBase"))))
(define (nsbutton-is-spring-loaded self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isSpringLoaded"))))
(define (nsbutton-is-transparent self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isTransparent"))))
(define (nsbutton-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-key-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-layout self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layout"))))
(define (nsbutton-layout-subtree-if-needed self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutSubtreeIfNeeded"))))
(define (nsbutton-lowercase-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lowercaseWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "magnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-make-backing-layer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBackingLayer"))))
   ))
(define (nsbutton-make-base-writing-direction-left-to-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionLeftToRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-make-base-writing-direction-natural self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionNatural:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-make-base-writing-direction-right-to-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionRightToLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-make-text-writing-direction-left-to-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionLeftToRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-make-text-writing-direction-natural self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionNatural:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-make-text-writing-direction-right-to-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionRightToLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-menu-for-event self event)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menuForEvent:")) (id->ffi2-ptr (coerce-arg event))))
   ))
(define (nsbutton-minimum-size-with-prioritized-compression-options self prioritized-options)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_P_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "minimumSizeWithPrioritizedCompressionOptions:")) (id->ffi2-ptr (coerce-arg prioritized-options)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsbutton-mouse-in-rect self point rect)
  (aw_racket_msg_OR_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouse:inRect:")) (id->ffi2-ptr point) (id->ffi2-ptr rect)))
(define (nsbutton-mouse-cancelled self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseCancelled:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-mouse-entered self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseEntered:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-mouse-exited self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseExited:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-mouse-moved self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseMoved:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-move-backward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-down! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-down-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveDownAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-forward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-left! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-left-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveLeftAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-paragraph-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveParagraphBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-paragraph-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveParagraphForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-right! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-right-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRightAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-to-beginning-of-document! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-to-beginning-of-document-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfDocumentAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-to-beginning-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-to-beginning-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-to-beginning-of-paragraph! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfParagraphAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-to-end-of-document! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-to-end-of-document-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfDocumentAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-to-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-to-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-to-end-of-paragraph! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-to-end-of-paragraph-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfParagraphAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-to-left-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToLeftEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-to-left-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToLeftEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-to-right-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToRightEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-to-right-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToRightEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-up! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-up-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveUpAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-word-backward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-word-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-word-forward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-word-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-word-left! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-word-left-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordLeftAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-word-right! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-move-word-right-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordRightAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-needs-to-draw-rect self rect)
  (aw_racket_msg_R_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsToDrawRect:")) (id->ffi2-ptr rect)))
(define (nsbutton-no-responder-for self event-selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "noResponderFor:")) (id->ffi2-ptr (sel_registerName event-selector))))
(define (nsbutton-other-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-other-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-other-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-page-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-page-down-and-modify-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageDownAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-page-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-page-up-and-modify-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageUpAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-perform-click! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performClick:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-perform-drag-operation! self sender)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-perform-key-equivalent! self key)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performKeyEquivalent:")) (id->ffi2-ptr (coerce-arg key))))
(define (nsbutton-prepare-content-in-rect self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareContentInRect:")) (id->ffi2-ptr rect)))
(define (nsbutton-prepare-for-drag-operation self sender)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareForDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-prepare-for-reuse self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareForReuse"))))
(define (nsbutton-pressure-change-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pressureChangeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-quick-look-preview-items self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookPreviewItems:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-quick-look-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-rect-for-smart-magnification-at-point-in-rect self location visible-rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_OR_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectForSmartMagnificationAtPoint:inRect:")) (id->ffi2-ptr location) (id->ffi2-ptr visible-rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsbutton-remove-all-tool-tips! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeAllToolTips"))))
(define (nsbutton-remove-from-superview! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeFromSuperview"))))
(define (nsbutton-remove-from-superview-without-needing-display! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeFromSuperviewWithoutNeedingDisplay"))))
(define (nsbutton-remove-tool-tip! self tag)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeToolTip:")) tag))
(define (nsbutton-replace-subview-with! self old-view new-view)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "replaceSubview:with:")) (id->ffi2-ptr (coerce-arg old-view)) (id->ffi2-ptr (coerce-arg new-view))))
(define (nsbutton-resign-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resignFirstResponder"))))
(define (nsbutton-resize-subviews-with-old-size self old-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resizeSubviewsWithOldSize:")) (id->ffi2-ptr old-size)))
(define (nsbutton-resize-with-old-superview-size self old-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resizeWithOldSuperviewSize:")) (id->ffi2-ptr old-size)))
(define (nsbutton-restore-user-activity-state self user-activity)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "restoreUserActivityState:")) (id->ffi2-ptr (coerce-arg user-activity))))
(define (nsbutton-right-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-right-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-right-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-rotate-by-angle self angle)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotateByAngle:")) angle))
(define (nsbutton-rotate-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotateWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-scale-unit-square-to-size self new-unit-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scaleUnitSquareToSize:")) (id->ffi2-ptr new-unit-size)))
(define (nsbutton-scroll-line-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollLineDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-scroll-line-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollLineUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-scroll-page-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPageDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-scroll-page-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPageUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-scroll-point self point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPoint:")) (id->ffi2-ptr point)))
(define (nsbutton-scroll-rect-to-visible self rect)
  (aw_racket_msg_R_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollRectToVisible:")) (id->ffi2-ptr rect)))
(define (nsbutton-scroll-to-beginning-of-document self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollToBeginningOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-scroll-to-end-of-document self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollToEndOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-scroll-wheel self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollWheel:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-select-all self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectAll:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-select-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-select-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-select-to-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectToMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-select-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-send-action-to self action target)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sendAction:to:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg target))))
(define (nsbutton-send-action-on self mask)
  (aw_racket_msg_Q_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sendActionOn:")) mask))
(define (nsbutton-set-accessibility-activation-point! self accessibility-activation-point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityActivationPoint:")) (id->ffi2-ptr accessibility-activation-point)))
(define (nsbutton-set-accessibility-allowed-values! self accessibility-allowed-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAllowedValues:")) (id->ffi2-ptr (coerce-arg accessibility-allowed-values))))
(define (nsbutton-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAlternateUIVisible:")) accessibility-alternate-ui-visible))
(define (nsbutton-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityApplicationFocusedUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-application-focused-ui-element))))
(define (nsbutton-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAttributedUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-attributed-user-input-labels))))
(define (nsbutton-set-accessibility-cancel-button! self accessibility-cancel-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCancelButton:")) (id->ffi2-ptr (coerce-arg accessibility-cancel-button))))
(define (nsbutton-set-accessibility-children! self accessibility-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildren:")) (id->ffi2-ptr (coerce-arg accessibility-children))))
(define (nsbutton-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildrenInNavigationOrder:")) (id->ffi2-ptr (coerce-arg accessibility-children-in-navigation-order))))
(define (nsbutton-set-accessibility-clear-button! self accessibility-clear-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityClearButton:")) (id->ffi2-ptr (coerce-arg accessibility-clear-button))))
(define (nsbutton-set-accessibility-close-button! self accessibility-close-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCloseButton:")) (id->ffi2-ptr (coerce-arg accessibility-close-button))))
(define (nsbutton-set-accessibility-column-count! self accessibility-column-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnCount:")) accessibility-column-count))
(define (nsbutton-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-column-header-ui-elements))))
(define (nsbutton-set-accessibility-column-index-range! self accessibility-column-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnIndexRange:")) (id->ffi2-ptr accessibility-column-index-range)))
(define (nsbutton-set-accessibility-column-titles! self accessibility-column-titles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnTitles:")) (id->ffi2-ptr (coerce-arg accessibility-column-titles))))
(define (nsbutton-set-accessibility-columns! self accessibility-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumns:")) (id->ffi2-ptr (coerce-arg accessibility-columns))))
(define (nsbutton-set-accessibility-contents! self accessibility-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityContents:")) (id->ffi2-ptr (coerce-arg accessibility-contents))))
(define (nsbutton-set-accessibility-critical-value! self accessibility-critical-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCriticalValue:")) (id->ffi2-ptr (coerce-arg accessibility-critical-value))))
(define (nsbutton-set-accessibility-custom-actions! self accessibility-custom-actions)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomActions:")) (id->ffi2-ptr (coerce-arg accessibility-custom-actions))))
(define (nsbutton-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomRotors:")) (id->ffi2-ptr (coerce-arg accessibility-custom-rotors))))
(define (nsbutton-set-accessibility-decrement-button! self accessibility-decrement-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDecrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-decrement-button))))
(define (nsbutton-set-accessibility-default-button! self accessibility-default-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDefaultButton:")) (id->ffi2-ptr (coerce-arg accessibility-default-button))))
(define (nsbutton-set-accessibility-disclosed! self accessibility-disclosed)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosed:")) accessibility-disclosed))
(define (nsbutton-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedByRow:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-by-row))))
(define (nsbutton-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedRows:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-rows))))
(define (nsbutton-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosureLevel:")) accessibility-disclosure-level))
(define (nsbutton-set-accessibility-document! self accessibility-document)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDocument:")) (id->ffi2-ptr (coerce-arg accessibility-document))))
(define (nsbutton-set-accessibility-edited! self accessibility-edited)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEdited:")) accessibility-edited))
(define (nsbutton-set-accessibility-element! self accessibility-element)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityElement:")) accessibility-element))
(define (nsbutton-set-accessibility-enabled! self accessibility-enabled)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEnabled:")) accessibility-enabled))
(define (nsbutton-set-accessibility-expanded! self accessibility-expanded)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExpanded:")) accessibility-expanded))
(define (nsbutton-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExtrasMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-extras-menu-bar))))
(define (nsbutton-set-accessibility-filename! self accessibility-filename)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFilename:")) (id->ffi2-ptr (coerce-arg accessibility-filename))))
(define (nsbutton-set-accessibility-focused! self accessibility-focused)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocused:")) accessibility-focused))
(define (nsbutton-set-accessibility-focused-window! self accessibility-focused-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocusedWindow:")) (id->ffi2-ptr (coerce-arg accessibility-focused-window))))
(define (nsbutton-set-accessibility-frame! self accessibility-frame)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrame:")) (id->ffi2-ptr accessibility-frame)))
(define (nsbutton-set-accessibility-frontmost! self accessibility-frontmost)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrontmost:")) accessibility-frontmost))
(define (nsbutton-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFullScreenButton:")) (id->ffi2-ptr (coerce-arg accessibility-full-screen-button))))
(define (nsbutton-set-accessibility-grow-area! self accessibility-grow-area)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityGrowArea:")) (id->ffi2-ptr (coerce-arg accessibility-grow-area))))
(define (nsbutton-set-accessibility-handles! self accessibility-handles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHandles:")) (id->ffi2-ptr (coerce-arg accessibility-handles))))
(define (nsbutton-set-accessibility-header! self accessibility-header)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHeader:")) (id->ffi2-ptr (coerce-arg accessibility-header))))
(define (nsbutton-set-accessibility-help! self accessibility-help)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHelp:")) (id->ffi2-ptr (coerce-arg accessibility-help))))
(define (nsbutton-set-accessibility-hidden! self accessibility-hidden)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHidden:")) accessibility-hidden))
(define (nsbutton-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-scroll-bar))))
(define (nsbutton-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-unit-description))))
(define (nsbutton-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnits:")) accessibility-horizontal-units))
(define (nsbutton-set-accessibility-identifier! self accessibility-identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIdentifier:")) (id->ffi2-ptr (coerce-arg accessibility-identifier))))
(define (nsbutton-set-accessibility-increment-button! self accessibility-increment-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIncrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-increment-button))))
(define (nsbutton-set-accessibility-index! self accessibility-index)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIndex:")) accessibility-index))
(define (nsbutton-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityInsertionPointLineNumber:")) accessibility-insertion-point-line-number))
(define (nsbutton-set-accessibility-label! self accessibility-label)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabel:")) (id->ffi2-ptr (coerce-arg accessibility-label))))
(define (nsbutton-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-label-ui-elements))))
(define (nsbutton-set-accessibility-label-value! self accessibility-label-value)
  (aw_racket_msg_f_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelValue:")) accessibility-label-value))
(define (nsbutton-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLinkedUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-linked-ui-elements))))
(define (nsbutton-set-accessibility-main! self accessibility-main)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMain:")) accessibility-main))
(define (nsbutton-set-accessibility-main-window! self accessibility-main-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMainWindow:")) (id->ffi2-ptr (coerce-arg accessibility-main-window))))
(define (nsbutton-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerGroupUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-marker-group-ui-element))))
(define (nsbutton-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerTypeDescription:")) (id->ffi2-ptr (coerce-arg accessibility-marker-type-description))))
(define (nsbutton-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-marker-ui-elements))))
(define (nsbutton-set-accessibility-marker-values! self accessibility-marker-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerValues:")) (id->ffi2-ptr (coerce-arg accessibility-marker-values))))
(define (nsbutton-set-accessibility-max-value! self accessibility-max-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMaxValue:")) (id->ffi2-ptr (coerce-arg accessibility-max-value))))
(define (nsbutton-set-accessibility-menu-bar! self accessibility-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-menu-bar))))
(define (nsbutton-set-accessibility-min-value! self accessibility-min-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinValue:")) (id->ffi2-ptr (coerce-arg accessibility-min-value))))
(define (nsbutton-set-accessibility-minimize-button! self accessibility-minimize-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimizeButton:")) (id->ffi2-ptr (coerce-arg accessibility-minimize-button))))
(define (nsbutton-set-accessibility-minimized! self accessibility-minimized)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimized:")) accessibility-minimized))
(define (nsbutton-set-accessibility-modal! self accessibility-modal)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityModal:")) accessibility-modal))
(define (nsbutton-set-accessibility-next-contents! self accessibility-next-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNextContents:")) (id->ffi2-ptr (coerce-arg accessibility-next-contents))))
(define (nsbutton-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNumberOfCharacters:")) accessibility-number-of-characters))
(define (nsbutton-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrderedByRow:")) accessibility-ordered-by-row))
(define (nsbutton-set-accessibility-orientation! self accessibility-orientation)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrientation:")) accessibility-orientation))
(define (nsbutton-set-accessibility-overflow-button! self accessibility-overflow-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOverflowButton:")) (id->ffi2-ptr (coerce-arg accessibility-overflow-button))))
(define (nsbutton-set-accessibility-parent! self accessibility-parent)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityParent:")) (id->ffi2-ptr (coerce-arg accessibility-parent))))
(define (nsbutton-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPlaceholderValue:")) (id->ffi2-ptr (coerce-arg accessibility-placeholder-value))))
(define (nsbutton-set-accessibility-previous-contents! self accessibility-previous-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPreviousContents:")) (id->ffi2-ptr (coerce-arg accessibility-previous-contents))))
(define (nsbutton-set-accessibility-protected-content! self accessibility-protected-content)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProtectedContent:")) accessibility-protected-content))
(define (nsbutton-set-accessibility-proxy! self accessibility-proxy)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProxy:")) (id->ffi2-ptr (coerce-arg accessibility-proxy))))
(define (nsbutton-set-accessibility-required! self accessibility-required)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRequired:")) accessibility-required))
(define (nsbutton-set-accessibility-role! self accessibility-role)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRole:")) (id->ffi2-ptr (coerce-arg accessibility-role))))
(define (nsbutton-set-accessibility-role-description! self accessibility-role-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRoleDescription:")) (id->ffi2-ptr (coerce-arg accessibility-role-description))))
(define (nsbutton-set-accessibility-row-count! self accessibility-row-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowCount:")) accessibility-row-count))
(define (nsbutton-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-row-header-ui-elements))))
(define (nsbutton-set-accessibility-row-index-range! self accessibility-row-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowIndexRange:")) (id->ffi2-ptr accessibility-row-index-range)))
(define (nsbutton-set-accessibility-rows! self accessibility-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRows:")) (id->ffi2-ptr (coerce-arg accessibility-rows))))
(define (nsbutton-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRulerMarkerType:")) accessibility-ruler-marker-type))
(define (nsbutton-set-accessibility-search-button! self accessibility-search-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchButton:")) (id->ffi2-ptr (coerce-arg accessibility-search-button))))
(define (nsbutton-set-accessibility-search-menu! self accessibility-search-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchMenu:")) (id->ffi2-ptr (coerce-arg accessibility-search-menu))))
(define (nsbutton-set-accessibility-selected! self accessibility-selected)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelected:")) accessibility-selected))
(define (nsbutton-set-accessibility-selected-cells! self accessibility-selected-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedCells:")) (id->ffi2-ptr (coerce-arg accessibility-selected-cells))))
(define (nsbutton-set-accessibility-selected-children! self accessibility-selected-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedChildren:")) (id->ffi2-ptr (coerce-arg accessibility-selected-children))))
(define (nsbutton-set-accessibility-selected-columns! self accessibility-selected-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedColumns:")) (id->ffi2-ptr (coerce-arg accessibility-selected-columns))))
(define (nsbutton-set-accessibility-selected-rows! self accessibility-selected-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedRows:")) (id->ffi2-ptr (coerce-arg accessibility-selected-rows))))
(define (nsbutton-set-accessibility-selected-text! self accessibility-selected-text)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedText:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text))))
(define (nsbutton-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRange:")) (id->ffi2-ptr accessibility-selected-text-range)))
(define (nsbutton-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRanges:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text-ranges))))
(define (nsbutton-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityServesAsTitleForUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-serves-as-title-for-ui-elements))))
(define (nsbutton-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedCharacterRange:")) (id->ffi2-ptr accessibility-shared-character-range)))
(define (nsbutton-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedFocusElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-focus-elements))))
(define (nsbutton-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedTextUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-text-ui-elements))))
(define (nsbutton-set-accessibility-shown-menu! self accessibility-shown-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityShownMenu:")) (id->ffi2-ptr (coerce-arg accessibility-shown-menu))))
(define (nsbutton-set-accessibility-sort-direction! self accessibility-sort-direction)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySortDirection:")) accessibility-sort-direction))
(define (nsbutton-set-accessibility-splitters! self accessibility-splitters)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySplitters:")) (id->ffi2-ptr (coerce-arg accessibility-splitters))))
(define (nsbutton-set-accessibility-subrole! self accessibility-subrole)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySubrole:")) (id->ffi2-ptr (coerce-arg accessibility-subrole))))
(define (nsbutton-set-accessibility-tabs! self accessibility-tabs)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTabs:")) (id->ffi2-ptr (coerce-arg accessibility-tabs))))
(define (nsbutton-set-accessibility-title! self accessibility-title)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitle:")) (id->ffi2-ptr (coerce-arg accessibility-title))))
(define (nsbutton-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitleUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-title-ui-element))))
(define (nsbutton-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityToolbarButton:")) (id->ffi2-ptr (coerce-arg accessibility-toolbar-button))))
(define (nsbutton-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTopLevelUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-top-level-ui-element))))
(define (nsbutton-set-accessibility-url! self accessibility-url)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityURL:")) (id->ffi2-ptr (coerce-arg accessibility-url))))
(define (nsbutton-set-accessibility-unit-description! self accessibility-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-unit-description))))
(define (nsbutton-set-accessibility-units! self accessibility-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnits:")) accessibility-units))
(define (nsbutton-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-user-input-labels))))
(define (nsbutton-set-accessibility-value! self accessibility-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValue:")) (id->ffi2-ptr (coerce-arg accessibility-value))))
(define (nsbutton-set-accessibility-value-description! self accessibility-value-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValueDescription:")) (id->ffi2-ptr (coerce-arg accessibility-value-description))))
(define (nsbutton-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-scroll-bar))))
(define (nsbutton-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-unit-description))))
(define (nsbutton-set-accessibility-vertical-units! self accessibility-vertical-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnits:")) accessibility-vertical-units))
(define (nsbutton-set-accessibility-visible-cells! self accessibility-visible-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCells:")) (id->ffi2-ptr (coerce-arg accessibility-visible-cells))))
(define (nsbutton-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCharacterRange:")) (id->ffi2-ptr accessibility-visible-character-range)))
(define (nsbutton-set-accessibility-visible-children! self accessibility-visible-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleChildren:")) (id->ffi2-ptr (coerce-arg accessibility-visible-children))))
(define (nsbutton-set-accessibility-visible-columns! self accessibility-visible-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleColumns:")) (id->ffi2-ptr (coerce-arg accessibility-visible-columns))))
(define (nsbutton-set-accessibility-visible-rows! self accessibility-visible-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleRows:")) (id->ffi2-ptr (coerce-arg accessibility-visible-rows))))
(define (nsbutton-set-accessibility-warning-value! self accessibility-warning-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWarningValue:")) (id->ffi2-ptr (coerce-arg accessibility-warning-value))))
(define (nsbutton-set-accessibility-window! self accessibility-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindow:")) (id->ffi2-ptr (coerce-arg accessibility-window))))
(define (nsbutton-set-accessibility-windows! self accessibility-windows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindows:")) (id->ffi2-ptr (coerce-arg accessibility-windows))))
(define (nsbutton-set-accessibility-zoom-button! self accessibility-zoom-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityZoomButton:")) (id->ffi2-ptr (coerce-arg accessibility-zoom-button))))
(define (nsbutton-set-animations! self animations)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAnimations:")) (id->ffi2-ptr (coerce-arg animations))))
(define (nsbutton-set-appearance! self appearance)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAppearance:")) (id->ffi2-ptr (coerce-arg appearance))))
(define (nsbutton-set-bounds-origin! self new-origin)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsOrigin:")) (id->ffi2-ptr new-origin)))
(define (nsbutton-set-bounds-size! self new-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsSize:")) (id->ffi2-ptr new-size)))
(define (nsbutton-set-button-type! self type)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setButtonType:")) type))
(define (nsbutton-set-frame-origin! self new-origin)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameOrigin:")) (id->ffi2-ptr new-origin)))
(define (nsbutton-set-frame-size! self new-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameSize:")) (id->ffi2-ptr new-size)))
(define (nsbutton-set-identifier! self identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIdentifier:")) (id->ffi2-ptr (coerce-arg identifier))))
(define (nsbutton-set-mark! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-set-needs-display-in-rect! self invalid-rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsDisplayInRect:")) (id->ffi2-ptr invalid-rect)))
(define (nsbutton-set-next-state! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextState"))))
(define (nsbutton-set-periodic-delay-interval! self delay interval)
  (aw_racket_msg_ff_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPeriodicDelay:interval:")) delay interval))
(define (nsbutton-should-be-treated-as-ink-event self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldBeTreatedAsInkEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-should-delay-window-ordering-for-event self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldDelayWindowOrderingForEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-show-context-help self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextHelp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-show-context-menu-for-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextMenuForSelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-size-that-fits self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sizeThatFits:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsbutton-size-to-fit self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sizeToFit"))))
(define (nsbutton-smart-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "smartMagnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-sort-subviews-using-function-context self compare context)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sortSubviewsUsingFunction:context:")) (id->ffi2-ptr compare) (id->ffi2-ptr context)))
(define (nsbutton-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "supplementalTargetForAction:sender:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg sender))))
   ))
(define (nsbutton-swap-with-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swapWithMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-swipe-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swipeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-tablet-point self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletPoint:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-tablet-proximity self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletProximity:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-take-double-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeDoubleValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-take-float-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeFloatValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-take-int-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeIntValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-take-integer-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeIntegerValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-take-object-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeObjectValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-take-string-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeStringValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-touches-began-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesBeganWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-touches-cancelled-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesCancelledWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-touches-ended-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesEndedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-touches-moved-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesMovedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-translate-origin-to-point self translation)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translateOriginToPoint:")) (id->ffi2-ptr translation)))
(define (nsbutton-translate-rects-needing-display-in-rect-by self clip-rect delta)
  (aw_racket_msg_RZ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translateRectsNeedingDisplayInRect:by:")) (id->ffi2-ptr clip-rect) (id->ffi2-ptr delta)))
(define (nsbutton-transpose self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transpose:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-transpose-words self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transposeWords:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-try-to-perform-with self action object)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tryToPerform:with:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg object))))
(define (nsbutton-update-dragging-items-for-drag self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateDraggingItemsForDrag:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-update-layer self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateLayer"))))
(define (nsbutton-uppercase-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "uppercaseWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsbutton-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validRequestorForSendType:returnType:")) (id->ffi2-ptr (coerce-arg send-type)) (id->ffi2-ptr (coerce-arg return-type))))
   ))
(define (nsbutton-validate-user-interface-item self item)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validateUserInterfaceItem:")) (id->ffi2-ptr (coerce-arg item))))
(define (nsbutton-view-did-change-backing-properties self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidChangeBackingProperties"))))
(define (nsbutton-view-did-change-effective-appearance self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidChangeEffectiveAppearance"))))
(define (nsbutton-view-did-end-live-resize self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidEndLiveResize"))))
(define (nsbutton-view-did-hide self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidHide"))))
(define (nsbutton-view-did-move-to-superview self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidMoveToSuperview"))))
(define (nsbutton-view-did-move-to-window self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidMoveToWindow"))))
(define (nsbutton-view-did-unhide self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidUnhide"))))
(define (nsbutton-view-will-draw self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillDraw"))))
(define (nsbutton-view-will-move-to-superview self new-superview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillMoveToSuperview:")) (id->ffi2-ptr (coerce-arg new-superview))))
(define (nsbutton-view-will-move-to-window self new-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillMoveToWindow:")) (id->ffi2-ptr (coerce-arg new-window))))
(define (nsbutton-view-will-start-live-resize self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillStartLiveResize"))))
(define (nsbutton-view-with-tag self tag)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWithTag:")) tag))
   ))
(define (nsbutton-wants-forwarded-scroll-events-for-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsForwardedScrollEventsForAxis:")) axis))
(define (nsbutton-wants-periodic-dragging-updates self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsPeriodicDraggingUpdates"))))
(define (nsbutton-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:")) axis))
(define (nsbutton-will-open-menu-with-event self menu event)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "willOpenMenu:withEvent:")) (id->ffi2-ptr (coerce-arg menu)) (id->ffi2-ptr (coerce-arg event))))
(define (nsbutton-will-remove-subview self subview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "willRemoveSubview:")) (id->ffi2-ptr (coerce-arg subview))))
(define (nsbutton-yank self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "yank:")) (id->ffi2-ptr (coerce-arg sender))))

;; --- Class methods ---
(define (nsbutton-button-with-image-target-action image target action)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPP_P (id->ffi2-ptr NSButton) (id->ffi2-ptr (sel_registerName "buttonWithImage:target:action:")) (id->ffi2-ptr (coerce-arg image)) (id->ffi2-ptr (coerce-arg target)) (id->ffi2-ptr (sel_registerName action))))
   ))
(define (nsbutton-button-with-title-image-target-action title image target action)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPPP_P (id->ffi2-ptr NSButton) (id->ffi2-ptr (sel_registerName "buttonWithTitle:image:target:action:")) (id->ffi2-ptr (coerce-arg title)) (id->ffi2-ptr (coerce-arg image)) (id->ffi2-ptr (coerce-arg target)) (id->ffi2-ptr (sel_registerName action))))
   ))
(define (nsbutton-button-with-title-target-action title target action)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPP_P (id->ffi2-ptr NSButton) (id->ffi2-ptr (sel_registerName "buttonWithTitle:target:action:")) (id->ffi2-ptr (coerce-arg title)) (id->ffi2-ptr (coerce-arg target)) (id->ffi2-ptr (sel_registerName action))))
   ))
(define (nsbutton-checkbox-with-title-target-action title target action)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPP_P (id->ffi2-ptr NSButton) (id->ffi2-ptr (sel_registerName "checkboxWithTitle:target:action:")) (id->ffi2-ptr (coerce-arg title)) (id->ffi2-ptr (coerce-arg target)) (id->ffi2-ptr (sel_registerName action))))
   ))
(define (nsbutton-default-animation-for-key key)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSButton) (id->ffi2-ptr (sel_registerName "defaultAnimationForKey:")) (id->ffi2-ptr (coerce-arg key))))
   ))
(define (nsbutton-is-compatible-with-responsive-scrolling)
  (aw_racket_msg_0_b (id->ffi2-ptr NSButton) (id->ffi2-ptr (sel_registerName "isCompatibleWithResponsiveScrolling"))))
(define (nsbutton-radio-button-with-title-target-action title target action)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPP_P (id->ffi2-ptr NSButton) (id->ffi2-ptr (sel_registerName "radioButtonWithTitle:target:action:")) (id->ffi2-ptr (coerce-arg title)) (id->ffi2-ptr (coerce-arg target)) (id->ffi2-ptr (sel_registerName action))))
   ))
