#lang racket/base
;; Generated binding for NSButton (AppKit)
;; Do not edit — regenerate from enriched IR

(require ffi/unsafe
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../../runtime/objc-base.rkt"
         "../../../runtime/coerce.rkt"
         "../../../runtime/type-mapping.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/AppKit.framework/AppKit"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
(define (calayer? v) (objc-instance-of? v "CALayer"))
(define (cgrect? v) (objc-instance-of? v "CGRect"))
(define (cifilter? v) (objc-instance-of? v "CIFilter"))
(define (nsappearance? v) (objc-instance-of? v "NSAppearance"))
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsattributedstring? v) (objc-instance-of? v "NSAttributedString"))
(define (nsbitmapimagerep? v) (objc-instance-of? v "NSBitmapImageRep"))
(define (nsbutton? v) (objc-instance-of? v "NSButton"))
(define (nscandidatelisttouchbaritem? v) (objc-instance-of? v "NSCandidateListTouchBarItem"))
(define (nscolor? v) (objc-instance-of? v "NSColor"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsedgeinsets? v) (objc-instance-of? v "NSEdgeInsets"))
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

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer -> _NSPoint)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _NSPoint)))
(define _msg-1  ; (_fun _pointer _pointer -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _NSRange)))
(define _msg-2  ; (_fun _pointer _pointer -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _NSRect)))
(define _msg-3  ; (_fun _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _bool)))
(define _msg-4  ; (_fun _pointer _pointer -> _double)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _double)))
(define _msg-5  ; (_fun _pointer _pointer -> _float)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _float)))
(define _msg-6  ; (_fun _pointer _pointer -> _int32)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _int32)))
(define _msg-7  ; (_fun _pointer _pointer -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _int64)))
(define _msg-8  ; (_fun _pointer _pointer -> _pointer)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _pointer)))
(define _msg-9  ; (_fun _pointer _pointer -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _uint64)))
(define _msg-10  ; (_fun _pointer _pointer _NSEdgeInsets -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSEdgeInsets -> _void)))
(define _msg-11  ; (_fun _pointer _pointer _NSPoint -> _NSPoint)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _NSPoint)))
(define _msg-12  ; (_fun _pointer _pointer _NSPoint -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _NSRange)))
(define _msg-13  ; (_fun _pointer _pointer _NSPoint -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _id)))
(define _msg-14  ; (_fun _pointer _pointer _NSPoint -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _void)))
(define _msg-15  ; (_fun _pointer _pointer _NSPoint _NSRect -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint _NSRect -> _NSRect)))
(define _msg-16  ; (_fun _pointer _pointer _NSPoint _NSRect -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint _NSRect -> _bool)))
(define _msg-17  ; (_fun _pointer _pointer _NSPoint _id -> _NSPoint)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint _id -> _NSPoint)))
(define _msg-18  ; (_fun _pointer _pointer _NSRange -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _NSRect)))
(define _msg-19  ; (_fun _pointer _pointer _NSRange -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _id)))
(define _msg-20  ; (_fun _pointer _pointer _NSRange -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _void)))
(define _msg-21  ; (_fun _pointer _pointer _NSRect -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _NSRect)))
(define _msg-22  ; (_fun _pointer _pointer _NSRect -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _bool)))
(define _msg-23  ; (_fun _pointer _pointer _NSRect -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _id)))
(define _msg-24  ; (_fun _pointer _pointer _NSRect -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _void)))
(define _msg-25  ; (_fun _pointer _pointer _NSRect _NSSize -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _NSSize -> _void)))
(define _msg-26  ; (_fun _pointer _pointer _NSRect _id -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id -> _NSRect)))
(define _msg-27  ; (_fun _pointer _pointer _NSRect _id -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id -> _void)))
(define _msg-28  ; (_fun _pointer _pointer _NSRect _id _pointer -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id _pointer -> _int64)))
(define _msg-29  ; (_fun _pointer _pointer _NSRect _uint64 -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _uint64 -> _NSRect)))
(define _msg-30  ; (_fun _pointer _pointer _NSSize -> _NSSize)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize -> _NSSize)))
(define _msg-31  ; (_fun _pointer _pointer _NSSize -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize -> _void)))
(define _msg-32  ; (_fun _pointer _pointer _NSSize _id -> _NSSize)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize _id -> _NSSize)))
(define _msg-33  ; (_fun _pointer _pointer _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _bool -> _void)))
(define _msg-34  ; (_fun _pointer _pointer _double -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double -> _void)))
(define _msg-35  ; (_fun _pointer _pointer _float -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _float -> _void)))
(define _msg-36  ; (_fun _pointer _pointer _float _float -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _float _float -> _void)))
(define _msg-37  ; (_fun _pointer _pointer _id -> _NSSize)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _NSSize)))
(define _msg-38  ; (_fun _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _bool)))
(define _msg-39  ; (_fun _pointer _pointer _id -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _uint64)))
(define _msg-40  ; (_fun _pointer _pointer _id _id _id _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _id _pointer -> _id)))
(define _msg-41  ; (_fun _pointer _pointer _id _id _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _pointer -> _id)))
(define _msg-42  ; (_fun _pointer _pointer _id _int64 _id -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _int64 _id -> _void)))
(define _msg-43  ; (_fun _pointer _pointer _int32 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int32 -> _void)))
(define _msg-44  ; (_fun _pointer _pointer _int64 -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _NSRange)))
(define _msg-45  ; (_fun _pointer _pointer _int64 -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _bool)))
(define _msg-46  ; (_fun _pointer _pointer _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _id)))
(define _msg-47  ; (_fun _pointer _pointer _int64 -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _int64)))
(define _msg-48  ; (_fun _pointer _pointer _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _void)))
(define _msg-49  ; (_fun _pointer _pointer _int64 _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _int64 -> _id)))
(define _msg-50  ; (_fun _pointer _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _bool)))
(define _msg-51  ; (_fun _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _void)))
(define _msg-52  ; (_fun _pointer _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _bool)))
(define _msg-53  ; (_fun _pointer _pointer _pointer _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _id)))
(define _msg-54  ; (_fun _pointer _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _pointer -> _void)))
(define _msg-55  ; (_fun _pointer _pointer _uint64 -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _int64)))
(define _msg-56  ; (_fun _pointer _pointer _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _void)))

;; --- Constructors ---
(define (make-nsbutton-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSButton alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nsbutton-init-with-frame frame-rect)
  (wrap-objc-object
   (_msg-23 (tell NSButton alloc)
       (sel_registerName "initWithFrame:")
       frame-rect)
   #:retained #t))


;; --- Properties ---
(define (nsbutton-accepts-first-responder self)
  (tell #:type _bool (coerce-arg self) acceptsFirstResponder))
(define (nsbutton-accepts-touch-events self)
  (tell #:type _bool (coerce-arg self) acceptsTouchEvents))
(define (nsbutton-set-accepts-touch-events! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setAcceptsTouchEvents:") value))
(define (nsbutton-action self)
  (tell #:type _pointer (coerce-arg self) action))
(define (nsbutton-set-action! self value)
  (_msg-51 (coerce-arg self) (sel_registerName "setAction:") (sel_registerName value)))
(define (nsbutton-active-compression-options self)
  (wrap-objc-object
   (tell (coerce-arg self) activeCompressionOptions)))
(define (nsbutton-additional-safe-area-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) additionalSafeAreaInsets))
(define (nsbutton-set-additional-safe-area-insets! self value)
  (_msg-10 (coerce-arg self) (sel_registerName "setAdditionalSafeAreaInsets:") value))
(define (nsbutton-alignment self)
  (tell #:type _int64 (coerce-arg self) alignment))
(define (nsbutton-set-alignment! self value)
  (_msg-48 (coerce-arg self) (sel_registerName "setAlignment:") value))
(define (nsbutton-alignment-rect-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) alignmentRectInsets))
(define (nsbutton-allowed-touch-types self)
  (tell #:type _uint64 (coerce-arg self) allowedTouchTypes))
(define (nsbutton-set-allowed-touch-types! self value)
  (_msg-56 (coerce-arg self) (sel_registerName "setAllowedTouchTypes:") value))
(define (nsbutton-allows-expansion-tool-tips self)
  (tell #:type _bool (coerce-arg self) allowsExpansionToolTips))
(define (nsbutton-set-allows-expansion-tool-tips! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setAllowsExpansionToolTips:") value))
(define (nsbutton-allows-mixed-state self)
  (tell #:type _bool (coerce-arg self) allowsMixedState))
(define (nsbutton-set-allows-mixed-state! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setAllowsMixedState:") value))
(define (nsbutton-allows-vibrancy self)
  (tell #:type _bool (coerce-arg self) allowsVibrancy))
(define (nsbutton-alpha-value self)
  (tell #:type _double (coerce-arg self) alphaValue))
(define (nsbutton-set-alpha-value! self value)
  (_msg-34 (coerce-arg self) (sel_registerName "setAlphaValue:") value))
(define (nsbutton-alternate-image self)
  (wrap-objc-object
   (tell (coerce-arg self) alternateImage)))
(define (nsbutton-set-alternate-image! self value)
  (tell #:type _void (coerce-arg self) setAlternateImage: (coerce-arg value)))
(define (nsbutton-alternate-title self)
  (wrap-objc-object
   (tell (coerce-arg self) alternateTitle)))
(define (nsbutton-set-alternate-title! self value)
  (tell #:type _void (coerce-arg self) setAlternateTitle: (coerce-arg value)))
(define (nsbutton-attributed-alternate-title self)
  (wrap-objc-object
   (tell (coerce-arg self) attributedAlternateTitle)))
(define (nsbutton-set-attributed-alternate-title! self value)
  (tell #:type _void (coerce-arg self) setAttributedAlternateTitle: (coerce-arg value)))
(define (nsbutton-attributed-string-value self)
  (wrap-objc-object
   (tell (coerce-arg self) attributedStringValue)))
(define (nsbutton-set-attributed-string-value! self value)
  (tell #:type _void (coerce-arg self) setAttributedStringValue: (coerce-arg value)))
(define (nsbutton-attributed-title self)
  (wrap-objc-object
   (tell (coerce-arg self) attributedTitle)))
(define (nsbutton-set-attributed-title! self value)
  (tell #:type _void (coerce-arg self) setAttributedTitle: (coerce-arg value)))
(define (nsbutton-autoresizes-subviews self)
  (tell #:type _bool (coerce-arg self) autoresizesSubviews))
(define (nsbutton-set-autoresizes-subviews! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setAutoresizesSubviews:") value))
(define (nsbutton-autoresizing-mask self)
  (tell #:type _uint64 (coerce-arg self) autoresizingMask))
(define (nsbutton-set-autoresizing-mask! self value)
  (_msg-56 (coerce-arg self) (sel_registerName "setAutoresizingMask:") value))
(define (nsbutton-background-filters self)
  (wrap-objc-object
   (tell (coerce-arg self) backgroundFilters)))
(define (nsbutton-set-background-filters! self value)
  (tell #:type _void (coerce-arg self) setBackgroundFilters: (coerce-arg value)))
(define (nsbutton-base-writing-direction self)
  (tell #:type _int64 (coerce-arg self) baseWritingDirection))
(define (nsbutton-set-base-writing-direction! self value)
  (_msg-48 (coerce-arg self) (sel_registerName "setBaseWritingDirection:") value))
(define (nsbutton-baseline-offset-from-bottom self)
  (tell #:type _double (coerce-arg self) baselineOffsetFromBottom))
(define (nsbutton-bezel-color self)
  (wrap-objc-object
   (tell (coerce-arg self) bezelColor)))
(define (nsbutton-set-bezel-color! self value)
  (tell #:type _void (coerce-arg self) setBezelColor: (coerce-arg value)))
(define (nsbutton-bezel-style self)
  (tell #:type _uint64 (coerce-arg self) bezelStyle))
(define (nsbutton-set-bezel-style! self value)
  (_msg-56 (coerce-arg self) (sel_registerName "setBezelStyle:") value))
(define (nsbutton-border-shape self)
  (tell #:type _int64 (coerce-arg self) borderShape))
(define (nsbutton-set-border-shape! self value)
  (_msg-48 (coerce-arg self) (sel_registerName "setBorderShape:") value))
(define (nsbutton-bordered self)
  (tell #:type _bool (coerce-arg self) bordered))
(define (nsbutton-set-bordered! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setBordered:") value))
(define (nsbutton-bottom-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) bottomAnchor)))
(define (nsbutton-bounds self)
  (tell #:type _NSRect (coerce-arg self) bounds))
(define (nsbutton-set-bounds! self value)
  (_msg-24 (coerce-arg self) (sel_registerName "setBounds:") value))
(define (nsbutton-bounds-rotation self)
  (tell #:type _double (coerce-arg self) boundsRotation))
(define (nsbutton-set-bounds-rotation! self value)
  (_msg-34 (coerce-arg self) (sel_registerName "setBoundsRotation:") value))
(define (nsbutton-can-become-key-view self)
  (tell #:type _bool (coerce-arg self) canBecomeKeyView))
(define (nsbutton-can-draw self)
  (tell #:type _bool (coerce-arg self) canDraw))
(define (nsbutton-can-draw-concurrently self)
  (tell #:type _bool (coerce-arg self) canDrawConcurrently))
(define (nsbutton-set-can-draw-concurrently! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setCanDrawConcurrently:") value))
(define (nsbutton-can-draw-subviews-into-layer self)
  (tell #:type _bool (coerce-arg self) canDrawSubviewsIntoLayer))
(define (nsbutton-set-can-draw-subviews-into-layer! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setCanDrawSubviewsIntoLayer:") value))
(define (nsbutton-candidate-list-touch-bar-item self)
  (wrap-objc-object
   (tell (coerce-arg self) candidateListTouchBarItem)))
(define (nsbutton-cell self)
  (wrap-objc-object
   (tell (coerce-arg self) cell)))
(define (nsbutton-set-cell! self value)
  (tell #:type _void (coerce-arg self) setCell: (coerce-arg value)))
(define (nsbutton-cell-class)
  (tell #:type _pointer NSButton cellClass))
(define (nsbutton-set-cell-class! value)
  (_msg-51 NSButton (sel_registerName "setCellClass:") value))
(define (nsbutton-center-x-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) centerXAnchor)))
(define (nsbutton-center-y-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) centerYAnchor)))
(define (nsbutton-clips-to-bounds self)
  (tell #:type _bool (coerce-arg self) clipsToBounds))
(define (nsbutton-set-clips-to-bounds! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setClipsToBounds:") value))
(define (nsbutton-compatible-with-responsive-scrolling)
  (tell #:type _bool NSButton compatibleWithResponsiveScrolling))
(define (nsbutton-compositing-filter self)
  (wrap-objc-object
   (tell (coerce-arg self) compositingFilter)))
(define (nsbutton-set-compositing-filter! self value)
  (tell #:type _void (coerce-arg self) setCompositingFilter: (coerce-arg value)))
(define (nsbutton-constraints self)
  (wrap-objc-object
   (tell (coerce-arg self) constraints)))
(define (nsbutton-content-filters self)
  (wrap-objc-object
   (tell (coerce-arg self) contentFilters)))
(define (nsbutton-set-content-filters! self value)
  (tell #:type _void (coerce-arg self) setContentFilters: (coerce-arg value)))
(define (nsbutton-content-tint-color self)
  (wrap-objc-object
   (tell (coerce-arg self) contentTintColor)))
(define (nsbutton-set-content-tint-color! self value)
  (tell #:type _void (coerce-arg self) setContentTintColor: (coerce-arg value)))
(define (nsbutton-continuous self)
  (tell #:type _bool (coerce-arg self) continuous))
(define (nsbutton-set-continuous! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setContinuous:") value))
(define (nsbutton-control-size self)
  (tell #:type _uint64 (coerce-arg self) controlSize))
(define (nsbutton-set-control-size! self value)
  (_msg-56 (coerce-arg self) (sel_registerName "setControlSize:") value))
(define (nsbutton-default-focus-ring-type)
  (tell #:type _uint64 NSButton defaultFocusRingType))
(define (nsbutton-default-menu)
  (wrap-objc-object
   (tell NSButton defaultMenu)))
(define (nsbutton-double-value self)
  (tell #:type _double (coerce-arg self) doubleValue))
(define (nsbutton-set-double-value! self value)
  (_msg-34 (coerce-arg self) (sel_registerName "setDoubleValue:") value))
(define (nsbutton-drawing-find-indicator self)
  (tell #:type _bool (coerce-arg self) drawingFindIndicator))
(define (nsbutton-enabled self)
  (tell #:type _bool (coerce-arg self) enabled))
(define (nsbutton-set-enabled! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setEnabled:") value))
(define (nsbutton-enclosing-menu-item self)
  (wrap-objc-object
   (tell (coerce-arg self) enclosingMenuItem)))
(define (nsbutton-enclosing-scroll-view self)
  (wrap-objc-object
   (tell (coerce-arg self) enclosingScrollView)))
(define (nsbutton-first-baseline-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) firstBaselineAnchor)))
(define (nsbutton-first-baseline-offset-from-top self)
  (tell #:type _double (coerce-arg self) firstBaselineOffsetFromTop))
(define (nsbutton-fitting-size self)
  (tell #:type _NSSize (coerce-arg self) fittingSize))
(define (nsbutton-flipped self)
  (tell #:type _bool (coerce-arg self) flipped))
(define (nsbutton-float-value self)
  (tell #:type _float (coerce-arg self) floatValue))
(define (nsbutton-set-float-value! self value)
  (_msg-35 (coerce-arg self) (sel_registerName "setFloatValue:") value))
(define (nsbutton-focus-ring-mask-bounds self)
  (tell #:type _NSRect (coerce-arg self) focusRingMaskBounds))
(define (nsbutton-focus-ring-type self)
  (tell #:type _uint64 (coerce-arg self) focusRingType))
(define (nsbutton-set-focus-ring-type! self value)
  (_msg-56 (coerce-arg self) (sel_registerName "setFocusRingType:") value))
(define (nsbutton-focus-view)
  (wrap-objc-object
   (tell NSButton focusView)))
(define (nsbutton-font self)
  (wrap-objc-object
   (tell (coerce-arg self) font)))
(define (nsbutton-set-font! self value)
  (tell #:type _void (coerce-arg self) setFont: (coerce-arg value)))
(define (nsbutton-formatter self)
  (wrap-objc-object
   (tell (coerce-arg self) formatter)))
(define (nsbutton-set-formatter! self value)
  (tell #:type _void (coerce-arg self) setFormatter: (coerce-arg value)))
(define (nsbutton-frame self)
  (tell #:type _NSRect (coerce-arg self) frame))
(define (nsbutton-set-frame! self value)
  (_msg-24 (coerce-arg self) (sel_registerName "setFrame:") value))
(define (nsbutton-frame-center-rotation self)
  (tell #:type _double (coerce-arg self) frameCenterRotation))
(define (nsbutton-set-frame-center-rotation! self value)
  (_msg-34 (coerce-arg self) (sel_registerName "setFrameCenterRotation:") value))
(define (nsbutton-frame-rotation self)
  (tell #:type _double (coerce-arg self) frameRotation))
(define (nsbutton-set-frame-rotation! self value)
  (_msg-34 (coerce-arg self) (sel_registerName "setFrameRotation:") value))
(define (nsbutton-gesture-recognizers self)
  (wrap-objc-object
   (tell (coerce-arg self) gestureRecognizers)))
(define (nsbutton-set-gesture-recognizers! self value)
  (tell #:type _void (coerce-arg self) setGestureRecognizers: (coerce-arg value)))
(define (nsbutton-has-ambiguous-layout self)
  (tell #:type _bool (coerce-arg self) hasAmbiguousLayout))
(define (nsbutton-has-destructive-action self)
  (tell #:type _bool (coerce-arg self) hasDestructiveAction))
(define (nsbutton-set-has-destructive-action! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setHasDestructiveAction:") value))
(define (nsbutton-height-adjust-limit self)
  (tell #:type _double (coerce-arg self) heightAdjustLimit))
(define (nsbutton-height-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) heightAnchor)))
(define (nsbutton-hidden self)
  (tell #:type _bool (coerce-arg self) hidden))
(define (nsbutton-set-hidden! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setHidden:") value))
(define (nsbutton-hidden-or-has-hidden-ancestor self)
  (tell #:type _bool (coerce-arg self) hiddenOrHasHiddenAncestor))
(define (nsbutton-highlighted self)
  (tell #:type _bool (coerce-arg self) highlighted))
(define (nsbutton-set-highlighted! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setHighlighted:") value))
(define (nsbutton-horizontal-content-size-constraint-active self)
  (tell #:type _bool (coerce-arg self) horizontalContentSizeConstraintActive))
(define (nsbutton-set-horizontal-content-size-constraint-active! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setHorizontalContentSizeConstraintActive:") value))
(define (nsbutton-ignores-multi-click self)
  (tell #:type _bool (coerce-arg self) ignoresMultiClick))
(define (nsbutton-set-ignores-multi-click! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setIgnoresMultiClick:") value))
(define (nsbutton-image self)
  (wrap-objc-object
   (tell (coerce-arg self) image)))
(define (nsbutton-set-image! self value)
  (tell #:type _void (coerce-arg self) setImage: (coerce-arg value)))
(define (nsbutton-image-hugs-title self)
  (tell #:type _bool (coerce-arg self) imageHugsTitle))
(define (nsbutton-set-image-hugs-title! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setImageHugsTitle:") value))
(define (nsbutton-image-position self)
  (tell #:type _uint64 (coerce-arg self) imagePosition))
(define (nsbutton-set-image-position! self value)
  (_msg-56 (coerce-arg self) (sel_registerName "setImagePosition:") value))
(define (nsbutton-image-scaling self)
  (tell #:type _uint64 (coerce-arg self) imageScaling))
(define (nsbutton-set-image-scaling! self value)
  (_msg-56 (coerce-arg self) (sel_registerName "setImageScaling:") value))
(define (nsbutton-in-full-screen-mode self)
  (tell #:type _bool (coerce-arg self) inFullScreenMode))
(define (nsbutton-in-live-resize self)
  (tell #:type _bool (coerce-arg self) inLiveResize))
(define (nsbutton-input-context self)
  (wrap-objc-object
   (tell (coerce-arg self) inputContext)))
(define (nsbutton-int-value self)
  (tell #:type _int32 (coerce-arg self) intValue))
(define (nsbutton-set-int-value! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setIntValue:") value))
(define (nsbutton-integer-value self)
  (tell #:type _int64 (coerce-arg self) integerValue))
(define (nsbutton-set-integer-value! self value)
  (_msg-48 (coerce-arg self) (sel_registerName "setIntegerValue:") value))
(define (nsbutton-intrinsic-content-size self)
  (tell #:type _NSSize (coerce-arg self) intrinsicContentSize))
(define (nsbutton-key-equivalent self)
  (wrap-objc-object
   (tell (coerce-arg self) keyEquivalent)))
(define (nsbutton-set-key-equivalent! self value)
  (tell #:type _void (coerce-arg self) setKeyEquivalent: (coerce-arg value)))
(define (nsbutton-key-equivalent-modifier-mask self)
  (tell #:type _uint64 (coerce-arg self) keyEquivalentModifierMask))
(define (nsbutton-set-key-equivalent-modifier-mask! self value)
  (_msg-56 (coerce-arg self) (sel_registerName "setKeyEquivalentModifierMask:") value))
(define (nsbutton-last-baseline-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) lastBaselineAnchor)))
(define (nsbutton-last-baseline-offset-from-bottom self)
  (tell #:type _double (coerce-arg self) lastBaselineOffsetFromBottom))
(define (nsbutton-layer self)
  (wrap-objc-object
   (tell (coerce-arg self) layer)))
(define (nsbutton-set-layer! self value)
  (tell #:type _void (coerce-arg self) setLayer: (coerce-arg value)))
(define (nsbutton-layer-contents-placement self)
  (tell #:type _int64 (coerce-arg self) layerContentsPlacement))
(define (nsbutton-set-layer-contents-placement! self value)
  (_msg-48 (coerce-arg self) (sel_registerName "setLayerContentsPlacement:") value))
(define (nsbutton-layer-contents-redraw-policy self)
  (tell #:type _int64 (coerce-arg self) layerContentsRedrawPolicy))
(define (nsbutton-set-layer-contents-redraw-policy! self value)
  (_msg-48 (coerce-arg self) (sel_registerName "setLayerContentsRedrawPolicy:") value))
(define (nsbutton-layer-uses-core-image-filters self)
  (tell #:type _bool (coerce-arg self) layerUsesCoreImageFilters))
(define (nsbutton-set-layer-uses-core-image-filters! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setLayerUsesCoreImageFilters:") value))
(define (nsbutton-layout-guides self)
  (wrap-objc-object
   (tell (coerce-arg self) layoutGuides)))
(define (nsbutton-layout-margins-guide self)
  (wrap-objc-object
   (tell (coerce-arg self) layoutMarginsGuide)))
(define (nsbutton-leading-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) leadingAnchor)))
(define (nsbutton-left-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) leftAnchor)))
(define (nsbutton-line-break-mode self)
  (tell #:type _uint64 (coerce-arg self) lineBreakMode))
(define (nsbutton-set-line-break-mode! self value)
  (_msg-56 (coerce-arg self) (sel_registerName "setLineBreakMode:") value))
(define (nsbutton-max-accelerator-level self)
  (tell #:type _int64 (coerce-arg self) maxAcceleratorLevel))
(define (nsbutton-set-max-accelerator-level! self value)
  (_msg-48 (coerce-arg self) (sel_registerName "setMaxAcceleratorLevel:") value))
(define (nsbutton-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) menu)))
(define (nsbutton-set-menu! self value)
  (tell #:type _void (coerce-arg self) setMenu: (coerce-arg value)))
(define (nsbutton-mouse-down-can-move-window self)
  (tell #:type _bool (coerce-arg self) mouseDownCanMoveWindow))
(define (nsbutton-needs-display self)
  (tell #:type _bool (coerce-arg self) needsDisplay))
(define (nsbutton-set-needs-display! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setNeedsDisplay:") value))
(define (nsbutton-needs-layout self)
  (tell #:type _bool (coerce-arg self) needsLayout))
(define (nsbutton-set-needs-layout! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setNeedsLayout:") value))
(define (nsbutton-needs-panel-to-become-key self)
  (tell #:type _bool (coerce-arg self) needsPanelToBecomeKey))
(define (nsbutton-needs-update-constraints self)
  (tell #:type _bool (coerce-arg self) needsUpdateConstraints))
(define (nsbutton-set-needs-update-constraints! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setNeedsUpdateConstraints:") value))
(define (nsbutton-next-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) nextKeyView)))
(define (nsbutton-set-next-key-view! self value)
  (tell #:type _void (coerce-arg self) setNextKeyView: (coerce-arg value)))
(define (nsbutton-next-responder self)
  (wrap-objc-object
   (tell (coerce-arg self) nextResponder)))
(define (nsbutton-set-next-responder! self value)
  (tell #:type _void (coerce-arg self) setNextResponder: (coerce-arg value)))
(define (nsbutton-next-valid-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) nextValidKeyView)))
(define (nsbutton-object-value self)
  (wrap-objc-object
   (tell (coerce-arg self) objectValue)))
(define (nsbutton-set-object-value! self value)
  (tell #:type _void (coerce-arg self) setObjectValue: (coerce-arg value)))
(define (nsbutton-opaque self)
  (tell #:type _bool (coerce-arg self) opaque))
(define (nsbutton-opaque-ancestor self)
  (wrap-objc-object
   (tell (coerce-arg self) opaqueAncestor)))
(define (nsbutton-page-footer self)
  (wrap-objc-object
   (tell (coerce-arg self) pageFooter)))
(define (nsbutton-page-header self)
  (wrap-objc-object
   (tell (coerce-arg self) pageHeader)))
(define (nsbutton-posts-bounds-changed-notifications self)
  (tell #:type _bool (coerce-arg self) postsBoundsChangedNotifications))
(define (nsbutton-set-posts-bounds-changed-notifications! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setPostsBoundsChangedNotifications:") value))
(define (nsbutton-posts-frame-changed-notifications self)
  (tell #:type _bool (coerce-arg self) postsFrameChangedNotifications))
(define (nsbutton-set-posts-frame-changed-notifications! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setPostsFrameChangedNotifications:") value))
(define (nsbutton-prefers-compact-control-size-metrics self)
  (tell #:type _bool (coerce-arg self) prefersCompactControlSizeMetrics))
(define (nsbutton-set-prefers-compact-control-size-metrics! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setPrefersCompactControlSizeMetrics:") value))
(define (nsbutton-prepared-content-rect self)
  (tell #:type _NSRect (coerce-arg self) preparedContentRect))
(define (nsbutton-set-prepared-content-rect! self value)
  (_msg-24 (coerce-arg self) (sel_registerName "setPreparedContentRect:") value))
(define (nsbutton-preserves-content-during-live-resize self)
  (tell #:type _bool (coerce-arg self) preservesContentDuringLiveResize))
(define (nsbutton-pressure-configuration self)
  (wrap-objc-object
   (tell (coerce-arg self) pressureConfiguration)))
(define (nsbutton-set-pressure-configuration! self value)
  (tell #:type _void (coerce-arg self) setPressureConfiguration: (coerce-arg value)))
(define (nsbutton-previous-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) previousKeyView)))
(define (nsbutton-previous-valid-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) previousValidKeyView)))
(define (nsbutton-print-job-title self)
  (wrap-objc-object
   (tell (coerce-arg self) printJobTitle)))
(define (nsbutton-rect-preserved-during-live-resize self)
  (tell #:type _NSRect (coerce-arg self) rectPreservedDuringLiveResize))
(define (nsbutton-refuses-first-responder self)
  (tell #:type _bool (coerce-arg self) refusesFirstResponder))
(define (nsbutton-set-refuses-first-responder! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setRefusesFirstResponder:") value))
(define (nsbutton-registered-dragged-types self)
  (wrap-objc-object
   (tell (coerce-arg self) registeredDraggedTypes)))
(define (nsbutton-requires-constraint-based-layout)
  (tell #:type _bool NSButton requiresConstraintBasedLayout))
(define (nsbutton-restorable-state-key-paths)
  (wrap-objc-object
   (tell NSButton restorableStateKeyPaths)))
(define (nsbutton-right-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) rightAnchor)))
(define (nsbutton-rotated-from-base self)
  (tell #:type _bool (coerce-arg self) rotatedFromBase))
(define (nsbutton-rotated-or-scaled-from-base self)
  (tell #:type _bool (coerce-arg self) rotatedOrScaledFromBase))
(define (nsbutton-safe-area-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) safeAreaInsets))
(define (nsbutton-safe-area-layout-guide self)
  (wrap-objc-object
   (tell (coerce-arg self) safeAreaLayoutGuide)))
(define (nsbutton-safe-area-rect self)
  (tell #:type _NSRect (coerce-arg self) safeAreaRect))
(define (nsbutton-shadow self)
  (wrap-objc-object
   (tell (coerce-arg self) shadow)))
(define (nsbutton-set-shadow! self value)
  (tell #:type _void (coerce-arg self) setShadow: (coerce-arg value)))
(define (nsbutton-shows-border-only-while-mouse-inside self)
  (tell #:type _bool (coerce-arg self) showsBorderOnlyWhileMouseInside))
(define (nsbutton-set-shows-border-only-while-mouse-inside! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setShowsBorderOnlyWhileMouseInside:") value))
(define (nsbutton-sound self)
  (wrap-objc-object
   (tell (coerce-arg self) sound)))
(define (nsbutton-set-sound! self value)
  (tell #:type _void (coerce-arg self) setSound: (coerce-arg value)))
(define (nsbutton-spring-loaded self)
  (tell #:type _bool (coerce-arg self) springLoaded))
(define (nsbutton-set-spring-loaded! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setSpringLoaded:") value))
(define (nsbutton-state self)
  (tell #:type _int64 (coerce-arg self) state))
(define (nsbutton-set-state! self value)
  (_msg-48 (coerce-arg self) (sel_registerName "setState:") value))
(define (nsbutton-string-value self)
  (wrap-objc-object
   (tell (coerce-arg self) stringValue)))
(define (nsbutton-set-string-value! self value)
  (tell #:type _void (coerce-arg self) setStringValue: (coerce-arg value)))
(define (nsbutton-subviews self)
  (wrap-objc-object
   (tell (coerce-arg self) subviews)))
(define (nsbutton-set-subviews! self value)
  (tell #:type _void (coerce-arg self) setSubviews: (coerce-arg value)))
(define (nsbutton-superview self)
  (wrap-objc-object
   (tell (coerce-arg self) superview)))
(define (nsbutton-symbol-configuration self)
  (wrap-objc-object
   (tell (coerce-arg self) symbolConfiguration)))
(define (nsbutton-set-symbol-configuration! self value)
  (tell #:type _void (coerce-arg self) setSymbolConfiguration: (coerce-arg value)))
(define (nsbutton-tag self)
  (tell #:type _int64 (coerce-arg self) tag))
(define (nsbutton-set-tag! self value)
  (_msg-48 (coerce-arg self) (sel_registerName "setTag:") value))
(define (nsbutton-target self)
  (wrap-objc-object
   (tell (coerce-arg self) target)))
(define (nsbutton-set-target! self value)
  (tell #:type _void (coerce-arg self) setTarget: (coerce-arg value)))
(define (nsbutton-tint-prominence self)
  (tell #:type _int64 (coerce-arg self) tintProminence))
(define (nsbutton-set-tint-prominence! self value)
  (_msg-48 (coerce-arg self) (sel_registerName "setTintProminence:") value))
(define (nsbutton-title self)
  (wrap-objc-object
   (tell (coerce-arg self) title)))
(define (nsbutton-set-title! self value)
  (tell #:type _void (coerce-arg self) setTitle: (coerce-arg value)))
(define (nsbutton-tool-tip self)
  (wrap-objc-object
   (tell (coerce-arg self) toolTip)))
(define (nsbutton-set-tool-tip! self value)
  (tell #:type _void (coerce-arg self) setToolTip: (coerce-arg value)))
(define (nsbutton-top-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) topAnchor)))
(define (nsbutton-touch-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) touchBar)))
(define (nsbutton-set-touch-bar! self value)
  (tell #:type _void (coerce-arg self) setTouchBar: (coerce-arg value)))
(define (nsbutton-tracking-areas self)
  (wrap-objc-object
   (tell (coerce-arg self) trackingAreas)))
(define (nsbutton-trailing-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) trailingAnchor)))
(define (nsbutton-translates-autoresizing-mask-into-constraints self)
  (tell #:type _bool (coerce-arg self) translatesAutoresizingMaskIntoConstraints))
(define (nsbutton-set-translates-autoresizing-mask-into-constraints! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setTranslatesAutoresizingMaskIntoConstraints:") value))
(define (nsbutton-transparent self)
  (tell #:type _bool (coerce-arg self) transparent))
(define (nsbutton-set-transparent! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setTransparent:") value))
(define (nsbutton-undo-manager self)
  (wrap-objc-object
   (tell (coerce-arg self) undoManager)))
(define (nsbutton-user-activity self)
  (wrap-objc-object
   (tell (coerce-arg self) userActivity)))
(define (nsbutton-set-user-activity! self value)
  (tell #:type _void (coerce-arg self) setUserActivity: (coerce-arg value)))
(define (nsbutton-user-interface-layout-direction self)
  (tell #:type _int64 (coerce-arg self) userInterfaceLayoutDirection))
(define (nsbutton-set-user-interface-layout-direction! self value)
  (_msg-48 (coerce-arg self) (sel_registerName "setUserInterfaceLayoutDirection:") value))
(define (nsbutton-uses-single-line-mode self)
  (tell #:type _bool (coerce-arg self) usesSingleLineMode))
(define (nsbutton-set-uses-single-line-mode! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setUsesSingleLineMode:") value))
(define (nsbutton-vertical-content-size-constraint-active self)
  (tell #:type _bool (coerce-arg self) verticalContentSizeConstraintActive))
(define (nsbutton-set-vertical-content-size-constraint-active! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setVerticalContentSizeConstraintActive:") value))
(define (nsbutton-visible-rect self)
  (tell #:type _NSRect (coerce-arg self) visibleRect))
(define (nsbutton-wants-best-resolution-open-gl-surface self)
  (tell #:type _bool (coerce-arg self) wantsBestResolutionOpenGLSurface))
(define (nsbutton-set-wants-best-resolution-open-gl-surface! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setWantsBestResolutionOpenGLSurface:") value))
(define (nsbutton-wants-default-clipping self)
  (tell #:type _bool (coerce-arg self) wantsDefaultClipping))
(define (nsbutton-wants-extended-dynamic-range-open-gl-surface self)
  (tell #:type _bool (coerce-arg self) wantsExtendedDynamicRangeOpenGLSurface))
(define (nsbutton-set-wants-extended-dynamic-range-open-gl-surface! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setWantsExtendedDynamicRangeOpenGLSurface:") value))
(define (nsbutton-wants-layer self)
  (tell #:type _bool (coerce-arg self) wantsLayer))
(define (nsbutton-set-wants-layer! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setWantsLayer:") value))
(define (nsbutton-wants-resting-touches self)
  (tell #:type _bool (coerce-arg self) wantsRestingTouches))
(define (nsbutton-set-wants-resting-touches! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setWantsRestingTouches:") value))
(define (nsbutton-wants-update-layer self)
  (tell #:type _bool (coerce-arg self) wantsUpdateLayer))
(define (nsbutton-width-adjust-limit self)
  (tell #:type _double (coerce-arg self) widthAdjustLimit))
(define (nsbutton-width-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) widthAnchor)))
(define (nsbutton-window self)
  (wrap-objc-object
   (tell (coerce-arg self) window)))
(define (nsbutton-writing-tools-coordinator self)
  (wrap-objc-object
   (tell (coerce-arg self) writingToolsCoordinator)))
(define (nsbutton-set-writing-tools-coordinator! self value)
  (tell #:type _void (coerce-arg self) setWritingToolsCoordinator: (coerce-arg value)))

;; --- Instance methods ---
(define (nsbutton-accepts-first-mouse self event)
  (_msg-38 (coerce-arg self) (sel_registerName "acceptsFirstMouse:") (coerce-arg event)))
(define (nsbutton-accessibility-activation-point self)
  (_msg-0 (coerce-arg self) (sel_registerName "accessibilityActivationPoint")))
(define (nsbutton-accessibility-allowed-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAllowedValues)))
(define (nsbutton-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityApplicationFocusedUIElement)))
(define (nsbutton-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (_msg-19 (coerce-arg self) (sel_registerName "accessibilityAttributedStringForRange:") range)
   ))
(define (nsbutton-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAttributedUserInputLabels)))
(define (nsbutton-accessibility-cancel-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCancelButton)))
(define (nsbutton-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (_msg-49 (coerce-arg self) (sel_registerName "accessibilityCellForColumn:row:") column row)
   ))
(define (nsbutton-accessibility-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildren)))
(define (nsbutton-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildrenInNavigationOrder)))
(define (nsbutton-accessibility-clear-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityClearButton)))
(define (nsbutton-accessibility-close-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCloseButton)))
(define (nsbutton-accessibility-column-count self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityColumnCount")))
(define (nsbutton-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnHeaderUIElements)))
(define (nsbutton-accessibility-column-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityColumnIndexRange")))
(define (nsbutton-accessibility-column-titles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnTitles)))
(define (nsbutton-accessibility-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumns)))
(define (nsbutton-accessibility-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityContents)))
(define (nsbutton-accessibility-critical-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCriticalValue)))
(define (nsbutton-accessibility-custom-actions self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomActions)))
(define (nsbutton-accessibility-custom-rotors self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomRotors)))
(define (nsbutton-accessibility-decrement-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDecrementButton)))
(define (nsbutton-accessibility-default-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDefaultButton)))
(define (nsbutton-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedByRow)))
(define (nsbutton-accessibility-disclosed-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedRows)))
(define (nsbutton-accessibility-disclosure-level self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityDisclosureLevel")))
(define (nsbutton-accessibility-document self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDocument)))
(define (nsbutton-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityExtrasMenuBar)))
(define (nsbutton-accessibility-filename self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFilename)))
(define (nsbutton-accessibility-focused-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFocusedWindow)))
(define (nsbutton-accessibility-frame self)
  (_msg-2 (coerce-arg self) (sel_registerName "accessibilityFrame")))
(define (nsbutton-accessibility-frame-for-range self range)
  (_msg-18 (coerce-arg self) (sel_registerName "accessibilityFrameForRange:") range))
(define (nsbutton-accessibility-full-screen-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFullScreenButton)))
(define (nsbutton-accessibility-grow-area self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityGrowArea)))
(define (nsbutton-accessibility-handles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHandles)))
(define (nsbutton-accessibility-header self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHeader)))
(define (nsbutton-accessibility-help self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHelp)))
(define (nsbutton-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalScrollBar)))
(define (nsbutton-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalUnitDescription)))
(define (nsbutton-accessibility-horizontal-units self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityHorizontalUnits")))
(define (nsbutton-accessibility-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIdentifier)))
(define (nsbutton-accessibility-increment-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIncrementButton)))
(define (nsbutton-accessibility-index self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityIndex")))
(define (nsbutton-accessibility-insertion-point-line-number self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityInsertionPointLineNumber")))
(define (nsbutton-accessibility-label self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabel)))
(define (nsbutton-accessibility-label-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabelUIElements)))
(define (nsbutton-accessibility-label-value self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityLabelValue")))
(define (nsbutton-accessibility-layout-point-for-screen-point self point)
  (_msg-11 (coerce-arg self) (sel_registerName "accessibilityLayoutPointForScreenPoint:") point))
(define (nsbutton-accessibility-layout-size-for-screen-size self size)
  (_msg-30 (coerce-arg self) (sel_registerName "accessibilityLayoutSizeForScreenSize:") size))
(define (nsbutton-accessibility-line-for-index self index)
  (_msg-47 (coerce-arg self) (sel_registerName "accessibilityLineForIndex:") index))
(define (nsbutton-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLinkedUIElements)))
(define (nsbutton-accessibility-main-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMainWindow)))
(define (nsbutton-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerGroupUIElement)))
(define (nsbutton-accessibility-marker-type-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerTypeDescription)))
(define (nsbutton-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerUIElements)))
(define (nsbutton-accessibility-marker-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerValues)))
(define (nsbutton-accessibility-max-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMaxValue)))
(define (nsbutton-accessibility-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMenuBar)))
(define (nsbutton-accessibility-min-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinValue)))
(define (nsbutton-accessibility-minimize-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinimizeButton)))
(define (nsbutton-accessibility-next-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityNextContents)))
(define (nsbutton-accessibility-number-of-characters self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityNumberOfCharacters")))
(define (nsbutton-accessibility-orientation self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityOrientation")))
(define (nsbutton-accessibility-overflow-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityOverflowButton)))
(define (nsbutton-accessibility-parent self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityParent)))
(define (nsbutton-accessibility-perform-cancel self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformCancel")))
(define (nsbutton-accessibility-perform-confirm self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformConfirm")))
(define (nsbutton-accessibility-perform-decrement self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformDecrement")))
(define (nsbutton-accessibility-perform-delete self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformDelete")))
(define (nsbutton-accessibility-perform-increment self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformIncrement")))
(define (nsbutton-accessibility-perform-pick self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformPick")))
(define (nsbutton-accessibility-perform-press self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformPress")))
(define (nsbutton-accessibility-perform-raise self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformRaise")))
(define (nsbutton-accessibility-perform-show-alternate-ui self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowAlternateUI")))
(define (nsbutton-accessibility-perform-show-default-ui self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowDefaultUI")))
(define (nsbutton-accessibility-perform-show-menu self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowMenu")))
(define (nsbutton-accessibility-placeholder-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPlaceholderValue)))
(define (nsbutton-accessibility-previous-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPreviousContents)))
(define (nsbutton-accessibility-proxy self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityProxy)))
(define (nsbutton-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (_msg-19 (coerce-arg self) (sel_registerName "accessibilityRTFForRange:") range)
   ))
(define (nsbutton-accessibility-range-for-index self index)
  (_msg-44 (coerce-arg self) (sel_registerName "accessibilityRangeForIndex:") index))
(define (nsbutton-accessibility-range-for-line self line)
  (_msg-44 (coerce-arg self) (sel_registerName "accessibilityRangeForLine:") line))
(define (nsbutton-accessibility-range-for-position self point)
  (_msg-12 (coerce-arg self) (sel_registerName "accessibilityRangeForPosition:") point))
(define (nsbutton-accessibility-role self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRole)))
(define (nsbutton-accessibility-role-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRoleDescription)))
(define (nsbutton-accessibility-row-count self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityRowCount")))
(define (nsbutton-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRowHeaderUIElements)))
(define (nsbutton-accessibility-row-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityRowIndexRange")))
(define (nsbutton-accessibility-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRows)))
(define (nsbutton-accessibility-ruler-marker-type self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityRulerMarkerType")))
(define (nsbutton-accessibility-screen-point-for-layout-point self point)
  (_msg-11 (coerce-arg self) (sel_registerName "accessibilityScreenPointForLayoutPoint:") point))
(define (nsbutton-accessibility-screen-size-for-layout-size self size)
  (_msg-30 (coerce-arg self) (sel_registerName "accessibilityScreenSizeForLayoutSize:") size))
(define (nsbutton-accessibility-search-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchButton)))
(define (nsbutton-accessibility-search-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchMenu)))
(define (nsbutton-accessibility-selected-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedCells)))
(define (nsbutton-accessibility-selected-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedChildren)))
(define (nsbutton-accessibility-selected-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedColumns)))
(define (nsbutton-accessibility-selected-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedRows)))
(define (nsbutton-accessibility-selected-text self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedText)))
(define (nsbutton-accessibility-selected-text-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySelectedTextRange")))
(define (nsbutton-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedTextRanges)))
(define (nsbutton-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityServesAsTitleForUIElements)))
(define (nsbutton-accessibility-shared-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySharedCharacterRange")))
(define (nsbutton-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedFocusElements)))
(define (nsbutton-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedTextUIElements)))
(define (nsbutton-accessibility-shown-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityShownMenu)))
(define (nsbutton-accessibility-sort-direction self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilitySortDirection")))
(define (nsbutton-accessibility-splitters self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySplitters)))
(define (nsbutton-accessibility-string-for-range self range)
  (wrap-objc-object
   (_msg-19 (coerce-arg self) (sel_registerName "accessibilityStringForRange:") range)
   ))
(define (nsbutton-accessibility-style-range-for-index self index)
  (_msg-44 (coerce-arg self) (sel_registerName "accessibilityStyleRangeForIndex:") index))
(define (nsbutton-accessibility-subrole self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySubrole)))
(define (nsbutton-accessibility-tabs self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTabs)))
(define (nsbutton-accessibility-title self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitle)))
(define (nsbutton-accessibility-title-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitleUIElement)))
(define (nsbutton-accessibility-toolbar-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityToolbarButton)))
(define (nsbutton-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTopLevelUIElement)))
(define (nsbutton-accessibility-url self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityURL)))
(define (nsbutton-accessibility-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUnitDescription)))
(define (nsbutton-accessibility-units self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityUnits")))
(define (nsbutton-accessibility-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUserInputLabels)))
(define (nsbutton-accessibility-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValue)))
(define (nsbutton-accessibility-value-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValueDescription)))
(define (nsbutton-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalScrollBar)))
(define (nsbutton-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalUnitDescription)))
(define (nsbutton-accessibility-vertical-units self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityVerticalUnits")))
(define (nsbutton-accessibility-visible-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleCells)))
(define (nsbutton-accessibility-visible-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityVisibleCharacterRange")))
(define (nsbutton-accessibility-visible-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleChildren)))
(define (nsbutton-accessibility-visible-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleColumns)))
(define (nsbutton-accessibility-visible-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleRows)))
(define (nsbutton-accessibility-warning-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWarningValue)))
(define (nsbutton-accessibility-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindow)))
(define (nsbutton-accessibility-windows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindows)))
(define (nsbutton-accessibility-zoom-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityZoomButton)))
(define (nsbutton-add-subview! self view)
  (tell #:type _void (coerce-arg self) addSubview: (coerce-arg view)))
(define (nsbutton-add-subview-positioned-relative-to! self view place other-view)
  (_msg-42 (coerce-arg self) (sel_registerName "addSubview:positioned:relativeTo:") (coerce-arg view) place (coerce-arg other-view)))
(define (nsbutton-add-tool-tip-rect-owner-user-data! self rect owner data)
  (_msg-28 (coerce-arg self) (sel_registerName "addToolTipRect:owner:userData:") rect (coerce-arg owner) data))
(define (nsbutton-adjust-scroll self new-visible)
  (_msg-21 (coerce-arg self) (sel_registerName "adjustScroll:") new-visible))
(define (nsbutton-ancestor-shared-with-view self view)
  (wrap-objc-object
   (tell (coerce-arg self) ancestorSharedWithView: (coerce-arg view))))
(define (nsbutton-animation-for-key self key)
  (wrap-objc-object
   (tell (coerce-arg self) animationForKey: (coerce-arg key))))
(define (nsbutton-animations self)
  (wrap-objc-object
   (tell (coerce-arg self) animations)))
(define (nsbutton-animator self)
  (wrap-objc-object
   (tell (coerce-arg self) animator)))
(define (nsbutton-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) appearance)))
(define (nsbutton-autoscroll self event)
  (_msg-38 (coerce-arg self) (sel_registerName "autoscroll:") (coerce-arg event)))
(define (nsbutton-backing-aligned-rect-options self rect options)
  (_msg-29 (coerce-arg self) (sel_registerName "backingAlignedRect:options:") rect options))
(define (nsbutton-become-first-responder self)
  (_msg-3 (coerce-arg self) (sel_registerName "becomeFirstResponder")))
(define (nsbutton-begin-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) beginGestureWithEvent: (coerce-arg event)))
(define (nsbutton-bitmap-image-rep-for-caching-display-in-rect self rect)
  (wrap-objc-object
   (_msg-23 (coerce-arg self) (sel_registerName "bitmapImageRepForCachingDisplayInRect:") rect)
   ))
(define (nsbutton-cache-display-in-rect-to-bitmap-image-rep self rect bitmap-image-rep)
  (_msg-27 (coerce-arg self) (sel_registerName "cacheDisplayInRect:toBitmapImageRep:") rect (coerce-arg bitmap-image-rep)))
(define (nsbutton-cancel-operation self sender)
  (tell #:type _void (coerce-arg self) cancelOperation: (coerce-arg sender)))
(define (nsbutton-capitalize-word self sender)
  (tell #:type _void (coerce-arg self) capitalizeWord: (coerce-arg sender)))
(define (nsbutton-center-scan-rect! self rect)
  (_msg-21 (coerce-arg self) (sel_registerName "centerScanRect:") rect))
(define (nsbutton-center-selection-in-visible-area! self sender)
  (tell #:type _void (coerce-arg self) centerSelectionInVisibleArea: (coerce-arg sender)))
(define (nsbutton-change-case-of-letter self sender)
  (tell #:type _void (coerce-arg self) changeCaseOfLetter: (coerce-arg sender)))
(define (nsbutton-change-mode-with-event self event)
  (tell #:type _void (coerce-arg self) changeModeWithEvent: (coerce-arg event)))
(define (nsbutton-complete self sender)
  (tell #:type _void (coerce-arg self) complete: (coerce-arg sender)))
(define (nsbutton-compress-with-prioritized-compression-options self prioritized-options)
  (tell #:type _void (coerce-arg self) compressWithPrioritizedCompressionOptions: (coerce-arg prioritized-options)))
(define (nsbutton-conclude-drag-operation self sender)
  (tell #:type _void (coerce-arg self) concludeDragOperation: (coerce-arg sender)))
(define (nsbutton-context-menu-key-down self event)
  (tell #:type _void (coerce-arg self) contextMenuKeyDown: (coerce-arg event)))
(define (nsbutton-convert-point-from-view self point view)
  (_msg-17 (coerce-arg self) (sel_registerName "convertPoint:fromView:") point (coerce-arg view)))
(define (nsbutton-convert-point-to-view self point view)
  (_msg-17 (coerce-arg self) (sel_registerName "convertPoint:toView:") point (coerce-arg view)))
(define (nsbutton-convert-point-from-backing self point)
  (_msg-11 (coerce-arg self) (sel_registerName "convertPointFromBacking:") point))
(define (nsbutton-convert-point-from-layer self point)
  (_msg-11 (coerce-arg self) (sel_registerName "convertPointFromLayer:") point))
(define (nsbutton-convert-point-to-backing self point)
  (_msg-11 (coerce-arg self) (sel_registerName "convertPointToBacking:") point))
(define (nsbutton-convert-point-to-layer self point)
  (_msg-11 (coerce-arg self) (sel_registerName "convertPointToLayer:") point))
(define (nsbutton-convert-rect-from-view self rect view)
  (_msg-26 (coerce-arg self) (sel_registerName "convertRect:fromView:") rect (coerce-arg view)))
(define (nsbutton-convert-rect-to-view self rect view)
  (_msg-26 (coerce-arg self) (sel_registerName "convertRect:toView:") rect (coerce-arg view)))
(define (nsbutton-convert-rect-from-backing self rect)
  (_msg-21 (coerce-arg self) (sel_registerName "convertRectFromBacking:") rect))
(define (nsbutton-convert-rect-from-layer self rect)
  (_msg-21 (coerce-arg self) (sel_registerName "convertRectFromLayer:") rect))
(define (nsbutton-convert-rect-to-backing self rect)
  (_msg-21 (coerce-arg self) (sel_registerName "convertRectToBacking:") rect))
(define (nsbutton-convert-rect-to-layer self rect)
  (_msg-21 (coerce-arg self) (sel_registerName "convertRectToLayer:") rect))
(define (nsbutton-convert-size-from-view self size view)
  (_msg-32 (coerce-arg self) (sel_registerName "convertSize:fromView:") size (coerce-arg view)))
(define (nsbutton-convert-size-to-view self size view)
  (_msg-32 (coerce-arg self) (sel_registerName "convertSize:toView:") size (coerce-arg view)))
(define (nsbutton-convert-size-from-backing self size)
  (_msg-30 (coerce-arg self) (sel_registerName "convertSizeFromBacking:") size))
(define (nsbutton-convert-size-from-layer self size)
  (_msg-30 (coerce-arg self) (sel_registerName "convertSizeFromLayer:") size))
(define (nsbutton-convert-size-to-backing self size)
  (_msg-30 (coerce-arg self) (sel_registerName "convertSizeToBacking:") size))
(define (nsbutton-convert-size-to-layer self size)
  (_msg-30 (coerce-arg self) (sel_registerName "convertSizeToLayer:") size))
(define (nsbutton-cursor-update self event)
  (tell #:type _void (coerce-arg self) cursorUpdate: (coerce-arg event)))
(define (nsbutton-delete-backward self sender)
  (tell #:type _void (coerce-arg self) deleteBackward: (coerce-arg sender)))
(define (nsbutton-delete-backward-by-decomposing-previous-character self sender)
  (tell #:type _void (coerce-arg self) deleteBackwardByDecomposingPreviousCharacter: (coerce-arg sender)))
(define (nsbutton-delete-forward self sender)
  (tell #:type _void (coerce-arg self) deleteForward: (coerce-arg sender)))
(define (nsbutton-delete-to-beginning-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfLine: (coerce-arg sender)))
(define (nsbutton-delete-to-beginning-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfParagraph: (coerce-arg sender)))
(define (nsbutton-delete-to-end-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfLine: (coerce-arg sender)))
(define (nsbutton-delete-to-end-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfParagraph: (coerce-arg sender)))
(define (nsbutton-delete-to-mark self sender)
  (tell #:type _void (coerce-arg self) deleteToMark: (coerce-arg sender)))
(define (nsbutton-delete-word-backward self sender)
  (tell #:type _void (coerce-arg self) deleteWordBackward: (coerce-arg sender)))
(define (nsbutton-delete-word-forward self sender)
  (tell #:type _void (coerce-arg self) deleteWordForward: (coerce-arg sender)))
(define (nsbutton-did-add-subview self subview)
  (tell #:type _void (coerce-arg self) didAddSubview: (coerce-arg subview)))
(define (nsbutton-did-close-menu-with-event self menu event)
  (tell #:type _void (coerce-arg self) didCloseMenu: (coerce-arg menu) withEvent: (coerce-arg event)))
(define (nsbutton-display! self)
  (tell #:type _void (coerce-arg self) display))
(define (nsbutton-display-if-needed! self)
  (tell #:type _void (coerce-arg self) displayIfNeeded))
(define (nsbutton-display-if-needed-ignoring-opacity! self)
  (tell #:type _void (coerce-arg self) displayIfNeededIgnoringOpacity))
(define (nsbutton-display-if-needed-in-rect! self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "displayIfNeededInRect:") rect))
(define (nsbutton-display-if-needed-in-rect-ignoring-opacity! self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "displayIfNeededInRectIgnoringOpacity:") rect))
(define (nsbutton-display-rect! self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "displayRect:") rect))
(define (nsbutton-display-rect-ignoring-opacity! self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "displayRectIgnoringOpacity:") rect))
(define (nsbutton-display-rect-ignoring-opacity-in-context! self rect context)
  (_msg-27 (coerce-arg self) (sel_registerName "displayRectIgnoringOpacity:inContext:") rect (coerce-arg context)))
(define (nsbutton-do-command-by-selector self selector)
  (_msg-51 (coerce-arg self) (sel_registerName "doCommandBySelector:") (sel_registerName selector)))
(define (nsbutton-dragging-ended self sender)
  (tell #:type _void (coerce-arg self) draggingEnded: (coerce-arg sender)))
(define (nsbutton-dragging-entered self sender)
  (_msg-39 (coerce-arg self) (sel_registerName "draggingEntered:") (coerce-arg sender)))
(define (nsbutton-dragging-exited self sender)
  (tell #:type _void (coerce-arg self) draggingExited: (coerce-arg sender)))
(define (nsbutton-dragging-updated self sender)
  (_msg-39 (coerce-arg self) (sel_registerName "draggingUpdated:") (coerce-arg sender)))
(define (nsbutton-draw-rect self dirty-rect)
  (_msg-24 (coerce-arg self) (sel_registerName "drawRect:") dirty-rect))
(define (nsbutton-draw-with-expansion-frame-in-view self content-frame view)
  (_msg-27 (coerce-arg self) (sel_registerName "drawWithExpansionFrame:inView:") content-frame (coerce-arg view)))
(define (nsbutton-effective-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) effectiveAppearance)))
(define (nsbutton-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nsbutton-end-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) endGestureWithEvent: (coerce-arg event)))
(define (nsbutton-expansion-frame-with-frame self content-frame)
  (_msg-21 (coerce-arg self) (sel_registerName "expansionFrameWithFrame:") content-frame))
(define (nsbutton-flags-changed self event)
  (tell #:type _void (coerce-arg self) flagsChanged: (coerce-arg event)))
(define (nsbutton-flush-buffered-key-events self)
  (tell #:type _void (coerce-arg self) flushBufferedKeyEvents))
(define (nsbutton-get-periodic-delay-interval self delay interval)
  (_msg-54 (coerce-arg self) (sel_registerName "getPeriodicDelay:interval:") delay interval))
(define (nsbutton-get-rects-being-drawn-count self rects count)
  (_msg-54 (coerce-arg self) (sel_registerName "getRectsBeingDrawn:count:") rects count))
(define (nsbutton-get-rects-exposed-during-live-resize-count self exposed-rects count)
  (_msg-54 (coerce-arg self) (sel_registerName "getRectsExposedDuringLiveResize:count:") exposed-rects count))
(define (nsbutton-help-requested self event-ptr)
  (tell #:type _void (coerce-arg self) helpRequested: (coerce-arg event-ptr)))
(define (nsbutton-highlight self flag)
  (_msg-33 (coerce-arg self) (sel_registerName "highlight:") flag))
(define (nsbutton-hit-test self point)
  (wrap-objc-object
   (_msg-13 (coerce-arg self) (sel_registerName "hitTest:") point)
   ))
(define (nsbutton-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) identifier)))
(define (nsbutton-indent self sender)
  (tell #:type _void (coerce-arg self) indent: (coerce-arg sender)))
(define (nsbutton-insert-backtab! self sender)
  (tell #:type _void (coerce-arg self) insertBacktab: (coerce-arg sender)))
(define (nsbutton-insert-container-break! self sender)
  (tell #:type _void (coerce-arg self) insertContainerBreak: (coerce-arg sender)))
(define (nsbutton-insert-double-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertDoubleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nsbutton-insert-line-break! self sender)
  (tell #:type _void (coerce-arg self) insertLineBreak: (coerce-arg sender)))
(define (nsbutton-insert-newline! self sender)
  (tell #:type _void (coerce-arg self) insertNewline: (coerce-arg sender)))
(define (nsbutton-insert-newline-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertNewlineIgnoringFieldEditor: (coerce-arg sender)))
(define (nsbutton-insert-paragraph-separator! self sender)
  (tell #:type _void (coerce-arg self) insertParagraphSeparator: (coerce-arg sender)))
(define (nsbutton-insert-single-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertSingleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nsbutton-insert-tab! self sender)
  (tell #:type _void (coerce-arg self) insertTab: (coerce-arg sender)))
(define (nsbutton-insert-tab-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertTabIgnoringFieldEditor: (coerce-arg sender)))
(define (nsbutton-insert-text! self insert-string)
  (tell #:type _void (coerce-arg self) insertText: (coerce-arg insert-string)))
(define (nsbutton-interpret-key-events self event-array)
  (tell #:type _void (coerce-arg self) interpretKeyEvents: (coerce-arg event-array)))
(define (nsbutton-is-accessibility-alternate-ui-visible self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityAlternateUIVisible")))
(define (nsbutton-is-accessibility-disclosed self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityDisclosed")))
(define (nsbutton-is-accessibility-edited self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityEdited")))
(define (nsbutton-is-accessibility-element self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityElement")))
(define (nsbutton-is-accessibility-enabled self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityEnabled")))
(define (nsbutton-is-accessibility-expanded self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityExpanded")))
(define (nsbutton-is-accessibility-focused self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityFocused")))
(define (nsbutton-is-accessibility-frontmost self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityFrontmost")))
(define (nsbutton-is-accessibility-hidden self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityHidden")))
(define (nsbutton-is-accessibility-main self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityMain")))
(define (nsbutton-is-accessibility-minimized self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityMinimized")))
(define (nsbutton-is-accessibility-modal self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityModal")))
(define (nsbutton-is-accessibility-ordered-by-row self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityOrderedByRow")))
(define (nsbutton-is-accessibility-protected-content self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityProtectedContent")))
(define (nsbutton-is-accessibility-required self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityRequired")))
(define (nsbutton-is-accessibility-selected self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilitySelected")))
(define (nsbutton-is-accessibility-selector-allowed self selector)
  (_msg-50 (coerce-arg self) (sel_registerName "isAccessibilitySelectorAllowed:") (sel_registerName selector)))
(define (nsbutton-is-bordered self)
  (_msg-3 (coerce-arg self) (sel_registerName "isBordered")))
(define (nsbutton-is-continuous self)
  (_msg-3 (coerce-arg self) (sel_registerName "isContinuous")))
(define (nsbutton-is-descendant-of self view)
  (_msg-38 (coerce-arg self) (sel_registerName "isDescendantOf:") (coerce-arg view)))
(define (nsbutton-is-enabled self)
  (_msg-3 (coerce-arg self) (sel_registerName "isEnabled")))
(define (nsbutton-is-flipped self)
  (_msg-3 (coerce-arg self) (sel_registerName "isFlipped")))
(define (nsbutton-is-hidden self)
  (_msg-3 (coerce-arg self) (sel_registerName "isHidden")))
(define (nsbutton-is-hidden-or-has-hidden-ancestor self)
  (_msg-3 (coerce-arg self) (sel_registerName "isHiddenOrHasHiddenAncestor")))
(define (nsbutton-is-highlighted self)
  (_msg-3 (coerce-arg self) (sel_registerName "isHighlighted")))
(define (nsbutton-is-opaque self)
  (_msg-3 (coerce-arg self) (sel_registerName "isOpaque")))
(define (nsbutton-is-rotated-from-base self)
  (_msg-3 (coerce-arg self) (sel_registerName "isRotatedFromBase")))
(define (nsbutton-is-rotated-or-scaled-from-base self)
  (_msg-3 (coerce-arg self) (sel_registerName "isRotatedOrScaledFromBase")))
(define (nsbutton-is-spring-loaded self)
  (_msg-3 (coerce-arg self) (sel_registerName "isSpringLoaded")))
(define (nsbutton-is-transparent self)
  (_msg-3 (coerce-arg self) (sel_registerName "isTransparent")))
(define (nsbutton-key-down self event)
  (tell #:type _void (coerce-arg self) keyDown: (coerce-arg event)))
(define (nsbutton-key-up self event)
  (tell #:type _void (coerce-arg self) keyUp: (coerce-arg event)))
(define (nsbutton-layout self)
  (tell #:type _void (coerce-arg self) layout))
(define (nsbutton-layout-subtree-if-needed self)
  (tell #:type _void (coerce-arg self) layoutSubtreeIfNeeded))
(define (nsbutton-lowercase-word self sender)
  (tell #:type _void (coerce-arg self) lowercaseWord: (coerce-arg sender)))
(define (nsbutton-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) magnifyWithEvent: (coerce-arg event)))
(define (nsbutton-make-backing-layer self)
  (wrap-objc-object
   (tell (coerce-arg self) makeBackingLayer)))
(define (nsbutton-make-base-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nsbutton-make-base-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionNatural: (coerce-arg sender)))
(define (nsbutton-make-base-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nsbutton-make-text-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nsbutton-make-text-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionNatural: (coerce-arg sender)))
(define (nsbutton-make-text-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nsbutton-menu-for-event self event)
  (wrap-objc-object
   (tell (coerce-arg self) menuForEvent: (coerce-arg event))))
(define (nsbutton-minimum-size-with-prioritized-compression-options self prioritized-options)
  (_msg-37 (coerce-arg self) (sel_registerName "minimumSizeWithPrioritizedCompressionOptions:") (coerce-arg prioritized-options)))
(define (nsbutton-mouse-in-rect self point rect)
  (_msg-16 (coerce-arg self) (sel_registerName "mouse:inRect:") point rect))
(define (nsbutton-mouse-cancelled self event)
  (tell #:type _void (coerce-arg self) mouseCancelled: (coerce-arg event)))
(define (nsbutton-mouse-down self event)
  (tell #:type _void (coerce-arg self) mouseDown: (coerce-arg event)))
(define (nsbutton-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) mouseDragged: (coerce-arg event)))
(define (nsbutton-mouse-entered self event)
  (tell #:type _void (coerce-arg self) mouseEntered: (coerce-arg event)))
(define (nsbutton-mouse-exited self event)
  (tell #:type _void (coerce-arg self) mouseExited: (coerce-arg event)))
(define (nsbutton-mouse-moved self event)
  (tell #:type _void (coerce-arg self) mouseMoved: (coerce-arg event)))
(define (nsbutton-mouse-up self event)
  (tell #:type _void (coerce-arg self) mouseUp: (coerce-arg event)))
(define (nsbutton-move-backward! self sender)
  (tell #:type _void (coerce-arg self) moveBackward: (coerce-arg sender)))
(define (nsbutton-move-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveBackwardAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-down! self sender)
  (tell #:type _void (coerce-arg self) moveDown: (coerce-arg sender)))
(define (nsbutton-move-down-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveDownAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-forward! self sender)
  (tell #:type _void (coerce-arg self) moveForward: (coerce-arg sender)))
(define (nsbutton-move-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveForwardAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-left! self sender)
  (tell #:type _void (coerce-arg self) moveLeft: (coerce-arg sender)))
(define (nsbutton-move-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveLeftAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-paragraph-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphBackwardAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-paragraph-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphForwardAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-right! self sender)
  (tell #:type _void (coerce-arg self) moveRight: (coerce-arg sender)))
(define (nsbutton-move-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveRightAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-to-beginning-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocument: (coerce-arg sender)))
(define (nsbutton-move-to-beginning-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-to-beginning-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLine: (coerce-arg sender)))
(define (nsbutton-move-to-beginning-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLineAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-to-beginning-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraph: (coerce-arg sender)))
(define (nsbutton-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-to-end-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocument: (coerce-arg sender)))
(define (nsbutton-move-to-end-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-to-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLine: (coerce-arg sender)))
(define (nsbutton-move-to-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-to-end-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraph: (coerce-arg sender)))
(define (nsbutton-move-to-end-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-to-left-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLine: (coerce-arg sender)))
(define (nsbutton-move-to-left-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-to-right-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLine: (coerce-arg sender)))
(define (nsbutton-move-to-right-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-up! self sender)
  (tell #:type _void (coerce-arg self) moveUp: (coerce-arg sender)))
(define (nsbutton-move-up-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveUpAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-word-backward! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackward: (coerce-arg sender)))
(define (nsbutton-move-word-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackwardAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-word-forward! self sender)
  (tell #:type _void (coerce-arg self) moveWordForward: (coerce-arg sender)))
(define (nsbutton-move-word-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordForwardAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-word-left! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeft: (coerce-arg sender)))
(define (nsbutton-move-word-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeftAndModifySelection: (coerce-arg sender)))
(define (nsbutton-move-word-right! self sender)
  (tell #:type _void (coerce-arg self) moveWordRight: (coerce-arg sender)))
(define (nsbutton-move-word-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordRightAndModifySelection: (coerce-arg sender)))
(define (nsbutton-needs-to-draw-rect self rect)
  (_msg-22 (coerce-arg self) (sel_registerName "needsToDrawRect:") rect))
(define (nsbutton-no-responder-for self event-selector)
  (_msg-51 (coerce-arg self) (sel_registerName "noResponderFor:") (sel_registerName event-selector)))
(define (nsbutton-other-mouse-down self event)
  (tell #:type _void (coerce-arg self) otherMouseDown: (coerce-arg event)))
(define (nsbutton-other-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) otherMouseDragged: (coerce-arg event)))
(define (nsbutton-other-mouse-up self event)
  (tell #:type _void (coerce-arg self) otherMouseUp: (coerce-arg event)))
(define (nsbutton-page-down self sender)
  (tell #:type _void (coerce-arg self) pageDown: (coerce-arg sender)))
(define (nsbutton-page-down-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageDownAndModifySelection: (coerce-arg sender)))
(define (nsbutton-page-up self sender)
  (tell #:type _void (coerce-arg self) pageUp: (coerce-arg sender)))
(define (nsbutton-page-up-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageUpAndModifySelection: (coerce-arg sender)))
(define (nsbutton-perform-click! self sender)
  (tell #:type _void (coerce-arg self) performClick: (coerce-arg sender)))
(define (nsbutton-perform-drag-operation! self sender)
  (_msg-38 (coerce-arg self) (sel_registerName "performDragOperation:") (coerce-arg sender)))
(define (nsbutton-perform-key-equivalent! self key)
  (_msg-38 (coerce-arg self) (sel_registerName "performKeyEquivalent:") (coerce-arg key)))
(define (nsbutton-prepare-content-in-rect self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "prepareContentInRect:") rect))
(define (nsbutton-prepare-for-drag-operation self sender)
  (_msg-38 (coerce-arg self) (sel_registerName "prepareForDragOperation:") (coerce-arg sender)))
(define (nsbutton-prepare-for-reuse self)
  (tell #:type _void (coerce-arg self) prepareForReuse))
(define (nsbutton-pressure-change-with-event self event)
  (tell #:type _void (coerce-arg self) pressureChangeWithEvent: (coerce-arg event)))
(define (nsbutton-quick-look-preview-items self sender)
  (tell #:type _void (coerce-arg self) quickLookPreviewItems: (coerce-arg sender)))
(define (nsbutton-quick-look-with-event self event)
  (tell #:type _void (coerce-arg self) quickLookWithEvent: (coerce-arg event)))
(define (nsbutton-rect-for-smart-magnification-at-point-in-rect self location visible-rect)
  (_msg-15 (coerce-arg self) (sel_registerName "rectForSmartMagnificationAtPoint:inRect:") location visible-rect))
(define (nsbutton-remove-all-tool-tips! self)
  (tell #:type _void (coerce-arg self) removeAllToolTips))
(define (nsbutton-remove-from-superview! self)
  (tell #:type _void (coerce-arg self) removeFromSuperview))
(define (nsbutton-remove-from-superview-without-needing-display! self)
  (tell #:type _void (coerce-arg self) removeFromSuperviewWithoutNeedingDisplay))
(define (nsbutton-remove-tool-tip! self tag)
  (_msg-48 (coerce-arg self) (sel_registerName "removeToolTip:") tag))
(define (nsbutton-replace-subview-with! self old-view new-view)
  (tell #:type _void (coerce-arg self) replaceSubview: (coerce-arg old-view) with: (coerce-arg new-view)))
(define (nsbutton-resign-first-responder self)
  (_msg-3 (coerce-arg self) (sel_registerName "resignFirstResponder")))
(define (nsbutton-resize-subviews-with-old-size self old-size)
  (_msg-31 (coerce-arg self) (sel_registerName "resizeSubviewsWithOldSize:") old-size))
(define (nsbutton-resize-with-old-superview-size self old-size)
  (_msg-31 (coerce-arg self) (sel_registerName "resizeWithOldSuperviewSize:") old-size))
(define (nsbutton-restore-user-activity-state self user-activity)
  (tell #:type _void (coerce-arg self) restoreUserActivityState: (coerce-arg user-activity)))
(define (nsbutton-right-mouse-down self event)
  (tell #:type _void (coerce-arg self) rightMouseDown: (coerce-arg event)))
(define (nsbutton-right-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) rightMouseDragged: (coerce-arg event)))
(define (nsbutton-right-mouse-up self event)
  (tell #:type _void (coerce-arg self) rightMouseUp: (coerce-arg event)))
(define (nsbutton-rotate-by-angle self angle)
  (_msg-34 (coerce-arg self) (sel_registerName "rotateByAngle:") angle))
(define (nsbutton-rotate-with-event self event)
  (tell #:type _void (coerce-arg self) rotateWithEvent: (coerce-arg event)))
(define (nsbutton-scale-unit-square-to-size self new-unit-size)
  (_msg-31 (coerce-arg self) (sel_registerName "scaleUnitSquareToSize:") new-unit-size))
(define (nsbutton-scroll-line-down self sender)
  (tell #:type _void (coerce-arg self) scrollLineDown: (coerce-arg sender)))
(define (nsbutton-scroll-line-up self sender)
  (tell #:type _void (coerce-arg self) scrollLineUp: (coerce-arg sender)))
(define (nsbutton-scroll-page-down self sender)
  (tell #:type _void (coerce-arg self) scrollPageDown: (coerce-arg sender)))
(define (nsbutton-scroll-page-up self sender)
  (tell #:type _void (coerce-arg self) scrollPageUp: (coerce-arg sender)))
(define (nsbutton-scroll-point self point)
  (_msg-14 (coerce-arg self) (sel_registerName "scrollPoint:") point))
(define (nsbutton-scroll-rect-to-visible self rect)
  (_msg-22 (coerce-arg self) (sel_registerName "scrollRectToVisible:") rect))
(define (nsbutton-scroll-to-beginning-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToBeginningOfDocument: (coerce-arg sender)))
(define (nsbutton-scroll-to-end-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToEndOfDocument: (coerce-arg sender)))
(define (nsbutton-scroll-wheel self event)
  (tell #:type _void (coerce-arg self) scrollWheel: (coerce-arg event)))
(define (nsbutton-select-all self sender)
  (tell #:type _void (coerce-arg self) selectAll: (coerce-arg sender)))
(define (nsbutton-select-line self sender)
  (tell #:type _void (coerce-arg self) selectLine: (coerce-arg sender)))
(define (nsbutton-select-paragraph self sender)
  (tell #:type _void (coerce-arg self) selectParagraph: (coerce-arg sender)))
(define (nsbutton-select-to-mark self sender)
  (tell #:type _void (coerce-arg self) selectToMark: (coerce-arg sender)))
(define (nsbutton-select-word self sender)
  (tell #:type _void (coerce-arg self) selectWord: (coerce-arg sender)))
(define (nsbutton-send-action-to self action target)
  (_msg-52 (coerce-arg self) (sel_registerName "sendAction:to:") (sel_registerName action) (coerce-arg target)))
(define (nsbutton-send-action-on self mask)
  (_msg-55 (coerce-arg self) (sel_registerName "sendActionOn:") mask))
(define (nsbutton-set-accessibility-activation-point! self accessibility-activation-point)
  (_msg-14 (coerce-arg self) (sel_registerName "setAccessibilityActivationPoint:") accessibility-activation-point))
(define (nsbutton-set-accessibility-allowed-values! self accessibility-allowed-values)
  (tell #:type _void (coerce-arg self) setAccessibilityAllowedValues: (coerce-arg accessibility-allowed-values)))
(define (nsbutton-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityAlternateUIVisible:") accessibility-alternate-ui-visible))
(define (nsbutton-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityApplicationFocusedUIElement: (coerce-arg accessibility-application-focused-ui-element)))
(define (nsbutton-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityAttributedUserInputLabels: (coerce-arg accessibility-attributed-user-input-labels)))
(define (nsbutton-set-accessibility-cancel-button! self accessibility-cancel-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCancelButton: (coerce-arg accessibility-cancel-button)))
(define (nsbutton-set-accessibility-children! self accessibility-children)
  (tell #:type _void (coerce-arg self) setAccessibilityChildren: (coerce-arg accessibility-children)))
(define (nsbutton-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (tell #:type _void (coerce-arg self) setAccessibilityChildrenInNavigationOrder: (coerce-arg accessibility-children-in-navigation-order)))
(define (nsbutton-set-accessibility-clear-button! self accessibility-clear-button)
  (tell #:type _void (coerce-arg self) setAccessibilityClearButton: (coerce-arg accessibility-clear-button)))
(define (nsbutton-set-accessibility-close-button! self accessibility-close-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCloseButton: (coerce-arg accessibility-close-button)))
(define (nsbutton-set-accessibility-column-count! self accessibility-column-count)
  (_msg-48 (coerce-arg self) (sel_registerName "setAccessibilityColumnCount:") accessibility-column-count))
(define (nsbutton-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnHeaderUIElements: (coerce-arg accessibility-column-header-ui-elements)))
(define (nsbutton-set-accessibility-column-index-range! self accessibility-column-index-range)
  (_msg-20 (coerce-arg self) (sel_registerName "setAccessibilityColumnIndexRange:") accessibility-column-index-range))
(define (nsbutton-set-accessibility-column-titles! self accessibility-column-titles)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnTitles: (coerce-arg accessibility-column-titles)))
(define (nsbutton-set-accessibility-columns! self accessibility-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityColumns: (coerce-arg accessibility-columns)))
(define (nsbutton-set-accessibility-contents! self accessibility-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityContents: (coerce-arg accessibility-contents)))
(define (nsbutton-set-accessibility-critical-value! self accessibility-critical-value)
  (tell #:type _void (coerce-arg self) setAccessibilityCriticalValue: (coerce-arg accessibility-critical-value)))
(define (nsbutton-set-accessibility-custom-actions! self accessibility-custom-actions)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomActions: (coerce-arg accessibility-custom-actions)))
(define (nsbutton-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomRotors: (coerce-arg accessibility-custom-rotors)))
(define (nsbutton-set-accessibility-decrement-button! self accessibility-decrement-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDecrementButton: (coerce-arg accessibility-decrement-button)))
(define (nsbutton-set-accessibility-default-button! self accessibility-default-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDefaultButton: (coerce-arg accessibility-default-button)))
(define (nsbutton-set-accessibility-disclosed! self accessibility-disclosed)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityDisclosed:") accessibility-disclosed))
(define (nsbutton-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedByRow: (coerce-arg accessibility-disclosed-by-row)))
(define (nsbutton-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedRows: (coerce-arg accessibility-disclosed-rows)))
(define (nsbutton-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (_msg-48 (coerce-arg self) (sel_registerName "setAccessibilityDisclosureLevel:") accessibility-disclosure-level))
(define (nsbutton-set-accessibility-document! self accessibility-document)
  (tell #:type _void (coerce-arg self) setAccessibilityDocument: (coerce-arg accessibility-document)))
(define (nsbutton-set-accessibility-edited! self accessibility-edited)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityEdited:") accessibility-edited))
(define (nsbutton-set-accessibility-element! self accessibility-element)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityElement:") accessibility-element))
(define (nsbutton-set-accessibility-enabled! self accessibility-enabled)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityEnabled:") accessibility-enabled))
(define (nsbutton-set-accessibility-expanded! self accessibility-expanded)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityExpanded:") accessibility-expanded))
(define (nsbutton-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityExtrasMenuBar: (coerce-arg accessibility-extras-menu-bar)))
(define (nsbutton-set-accessibility-filename! self accessibility-filename)
  (tell #:type _void (coerce-arg self) setAccessibilityFilename: (coerce-arg accessibility-filename)))
(define (nsbutton-set-accessibility-focused! self accessibility-focused)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityFocused:") accessibility-focused))
(define (nsbutton-set-accessibility-focused-window! self accessibility-focused-window)
  (tell #:type _void (coerce-arg self) setAccessibilityFocusedWindow: (coerce-arg accessibility-focused-window)))
(define (nsbutton-set-accessibility-frame! self accessibility-frame)
  (_msg-24 (coerce-arg self) (sel_registerName "setAccessibilityFrame:") accessibility-frame))
(define (nsbutton-set-accessibility-frontmost! self accessibility-frontmost)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityFrontmost:") accessibility-frontmost))
(define (nsbutton-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (tell #:type _void (coerce-arg self) setAccessibilityFullScreenButton: (coerce-arg accessibility-full-screen-button)))
(define (nsbutton-set-accessibility-grow-area! self accessibility-grow-area)
  (tell #:type _void (coerce-arg self) setAccessibilityGrowArea: (coerce-arg accessibility-grow-area)))
(define (nsbutton-set-accessibility-handles! self accessibility-handles)
  (tell #:type _void (coerce-arg self) setAccessibilityHandles: (coerce-arg accessibility-handles)))
(define (nsbutton-set-accessibility-header! self accessibility-header)
  (tell #:type _void (coerce-arg self) setAccessibilityHeader: (coerce-arg accessibility-header)))
(define (nsbutton-set-accessibility-help! self accessibility-help)
  (tell #:type _void (coerce-arg self) setAccessibilityHelp: (coerce-arg accessibility-help)))
(define (nsbutton-set-accessibility-hidden! self accessibility-hidden)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityHidden:") accessibility-hidden))
(define (nsbutton-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalScrollBar: (coerce-arg accessibility-horizontal-scroll-bar)))
(define (nsbutton-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalUnitDescription: (coerce-arg accessibility-horizontal-unit-description)))
(define (nsbutton-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (_msg-48 (coerce-arg self) (sel_registerName "setAccessibilityHorizontalUnits:") accessibility-horizontal-units))
(define (nsbutton-set-accessibility-identifier! self accessibility-identifier)
  (tell #:type _void (coerce-arg self) setAccessibilityIdentifier: (coerce-arg accessibility-identifier)))
(define (nsbutton-set-accessibility-increment-button! self accessibility-increment-button)
  (tell #:type _void (coerce-arg self) setAccessibilityIncrementButton: (coerce-arg accessibility-increment-button)))
(define (nsbutton-set-accessibility-index! self accessibility-index)
  (_msg-48 (coerce-arg self) (sel_registerName "setAccessibilityIndex:") accessibility-index))
(define (nsbutton-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (_msg-48 (coerce-arg self) (sel_registerName "setAccessibilityInsertionPointLineNumber:") accessibility-insertion-point-line-number))
(define (nsbutton-set-accessibility-label! self accessibility-label)
  (tell #:type _void (coerce-arg self) setAccessibilityLabel: (coerce-arg accessibility-label)))
(define (nsbutton-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLabelUIElements: (coerce-arg accessibility-label-ui-elements)))
(define (nsbutton-set-accessibility-label-value! self accessibility-label-value)
  (_msg-35 (coerce-arg self) (sel_registerName "setAccessibilityLabelValue:") accessibility-label-value))
(define (nsbutton-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLinkedUIElements: (coerce-arg accessibility-linked-ui-elements)))
(define (nsbutton-set-accessibility-main! self accessibility-main)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityMain:") accessibility-main))
(define (nsbutton-set-accessibility-main-window! self accessibility-main-window)
  (tell #:type _void (coerce-arg self) setAccessibilityMainWindow: (coerce-arg accessibility-main-window)))
(define (nsbutton-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerGroupUIElement: (coerce-arg accessibility-marker-group-ui-element)))
(define (nsbutton-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerTypeDescription: (coerce-arg accessibility-marker-type-description)))
(define (nsbutton-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerUIElements: (coerce-arg accessibility-marker-ui-elements)))
(define (nsbutton-set-accessibility-marker-values! self accessibility-marker-values)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerValues: (coerce-arg accessibility-marker-values)))
(define (nsbutton-set-accessibility-max-value! self accessibility-max-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMaxValue: (coerce-arg accessibility-max-value)))
(define (nsbutton-set-accessibility-menu-bar! self accessibility-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityMenuBar: (coerce-arg accessibility-menu-bar)))
(define (nsbutton-set-accessibility-min-value! self accessibility-min-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMinValue: (coerce-arg accessibility-min-value)))
(define (nsbutton-set-accessibility-minimize-button! self accessibility-minimize-button)
  (tell #:type _void (coerce-arg self) setAccessibilityMinimizeButton: (coerce-arg accessibility-minimize-button)))
(define (nsbutton-set-accessibility-minimized! self accessibility-minimized)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityMinimized:") accessibility-minimized))
(define (nsbutton-set-accessibility-modal! self accessibility-modal)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityModal:") accessibility-modal))
(define (nsbutton-set-accessibility-next-contents! self accessibility-next-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityNextContents: (coerce-arg accessibility-next-contents)))
(define (nsbutton-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (_msg-48 (coerce-arg self) (sel_registerName "setAccessibilityNumberOfCharacters:") accessibility-number-of-characters))
(define (nsbutton-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityOrderedByRow:") accessibility-ordered-by-row))
(define (nsbutton-set-accessibility-orientation! self accessibility-orientation)
  (_msg-48 (coerce-arg self) (sel_registerName "setAccessibilityOrientation:") accessibility-orientation))
(define (nsbutton-set-accessibility-overflow-button! self accessibility-overflow-button)
  (tell #:type _void (coerce-arg self) setAccessibilityOverflowButton: (coerce-arg accessibility-overflow-button)))
(define (nsbutton-set-accessibility-parent! self accessibility-parent)
  (tell #:type _void (coerce-arg self) setAccessibilityParent: (coerce-arg accessibility-parent)))
(define (nsbutton-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (tell #:type _void (coerce-arg self) setAccessibilityPlaceholderValue: (coerce-arg accessibility-placeholder-value)))
(define (nsbutton-set-accessibility-previous-contents! self accessibility-previous-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityPreviousContents: (coerce-arg accessibility-previous-contents)))
(define (nsbutton-set-accessibility-protected-content! self accessibility-protected-content)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityProtectedContent:") accessibility-protected-content))
(define (nsbutton-set-accessibility-proxy! self accessibility-proxy)
  (tell #:type _void (coerce-arg self) setAccessibilityProxy: (coerce-arg accessibility-proxy)))
(define (nsbutton-set-accessibility-required! self accessibility-required)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityRequired:") accessibility-required))
(define (nsbutton-set-accessibility-role! self accessibility-role)
  (tell #:type _void (coerce-arg self) setAccessibilityRole: (coerce-arg accessibility-role)))
(define (nsbutton-set-accessibility-role-description! self accessibility-role-description)
  (tell #:type _void (coerce-arg self) setAccessibilityRoleDescription: (coerce-arg accessibility-role-description)))
(define (nsbutton-set-accessibility-row-count! self accessibility-row-count)
  (_msg-48 (coerce-arg self) (sel_registerName "setAccessibilityRowCount:") accessibility-row-count))
(define (nsbutton-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityRowHeaderUIElements: (coerce-arg accessibility-row-header-ui-elements)))
(define (nsbutton-set-accessibility-row-index-range! self accessibility-row-index-range)
  (_msg-20 (coerce-arg self) (sel_registerName "setAccessibilityRowIndexRange:") accessibility-row-index-range))
(define (nsbutton-set-accessibility-rows! self accessibility-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityRows: (coerce-arg accessibility-rows)))
(define (nsbutton-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (_msg-48 (coerce-arg self) (sel_registerName "setAccessibilityRulerMarkerType:") accessibility-ruler-marker-type))
(define (nsbutton-set-accessibility-search-button! self accessibility-search-button)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchButton: (coerce-arg accessibility-search-button)))
(define (nsbutton-set-accessibility-search-menu! self accessibility-search-menu)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchMenu: (coerce-arg accessibility-search-menu)))
(define (nsbutton-set-accessibility-selected! self accessibility-selected)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilitySelected:") accessibility-selected))
(define (nsbutton-set-accessibility-selected-cells! self accessibility-selected-cells)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedCells: (coerce-arg accessibility-selected-cells)))
(define (nsbutton-set-accessibility-selected-children! self accessibility-selected-children)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedChildren: (coerce-arg accessibility-selected-children)))
(define (nsbutton-set-accessibility-selected-columns! self accessibility-selected-columns)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedColumns: (coerce-arg accessibility-selected-columns)))
(define (nsbutton-set-accessibility-selected-rows! self accessibility-selected-rows)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedRows: (coerce-arg accessibility-selected-rows)))
(define (nsbutton-set-accessibility-selected-text! self accessibility-selected-text)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedText: (coerce-arg accessibility-selected-text)))
(define (nsbutton-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (_msg-20 (coerce-arg self) (sel_registerName "setAccessibilitySelectedTextRange:") accessibility-selected-text-range))
(define (nsbutton-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedTextRanges: (coerce-arg accessibility-selected-text-ranges)))
(define (nsbutton-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityServesAsTitleForUIElements: (coerce-arg accessibility-serves-as-title-for-ui-elements)))
(define (nsbutton-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (_msg-20 (coerce-arg self) (sel_registerName "setAccessibilitySharedCharacterRange:") accessibility-shared-character-range))
(define (nsbutton-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedFocusElements: (coerce-arg accessibility-shared-focus-elements)))
(define (nsbutton-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedTextUIElements: (coerce-arg accessibility-shared-text-ui-elements)))
(define (nsbutton-set-accessibility-shown-menu! self accessibility-shown-menu)
  (tell #:type _void (coerce-arg self) setAccessibilityShownMenu: (coerce-arg accessibility-shown-menu)))
(define (nsbutton-set-accessibility-sort-direction! self accessibility-sort-direction)
  (_msg-48 (coerce-arg self) (sel_registerName "setAccessibilitySortDirection:") accessibility-sort-direction))
(define (nsbutton-set-accessibility-splitters! self accessibility-splitters)
  (tell #:type _void (coerce-arg self) setAccessibilitySplitters: (coerce-arg accessibility-splitters)))
(define (nsbutton-set-accessibility-subrole! self accessibility-subrole)
  (tell #:type _void (coerce-arg self) setAccessibilitySubrole: (coerce-arg accessibility-subrole)))
(define (nsbutton-set-accessibility-tabs! self accessibility-tabs)
  (tell #:type _void (coerce-arg self) setAccessibilityTabs: (coerce-arg accessibility-tabs)))
(define (nsbutton-set-accessibility-title! self accessibility-title)
  (tell #:type _void (coerce-arg self) setAccessibilityTitle: (coerce-arg accessibility-title)))
(define (nsbutton-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTitleUIElement: (coerce-arg accessibility-title-ui-element)))
(define (nsbutton-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (tell #:type _void (coerce-arg self) setAccessibilityToolbarButton: (coerce-arg accessibility-toolbar-button)))
(define (nsbutton-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTopLevelUIElement: (coerce-arg accessibility-top-level-ui-element)))
(define (nsbutton-set-accessibility-url! self accessibility-url)
  (tell #:type _void (coerce-arg self) setAccessibilityURL: (coerce-arg accessibility-url)))
(define (nsbutton-set-accessibility-unit-description! self accessibility-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityUnitDescription: (coerce-arg accessibility-unit-description)))
(define (nsbutton-set-accessibility-units! self accessibility-units)
  (_msg-48 (coerce-arg self) (sel_registerName "setAccessibilityUnits:") accessibility-units))
(define (nsbutton-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityUserInputLabels: (coerce-arg accessibility-user-input-labels)))
(define (nsbutton-set-accessibility-value! self accessibility-value)
  (tell #:type _void (coerce-arg self) setAccessibilityValue: (coerce-arg accessibility-value)))
(define (nsbutton-set-accessibility-value-description! self accessibility-value-description)
  (tell #:type _void (coerce-arg self) setAccessibilityValueDescription: (coerce-arg accessibility-value-description)))
(define (nsbutton-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalScrollBar: (coerce-arg accessibility-vertical-scroll-bar)))
(define (nsbutton-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalUnitDescription: (coerce-arg accessibility-vertical-unit-description)))
(define (nsbutton-set-accessibility-vertical-units! self accessibility-vertical-units)
  (_msg-48 (coerce-arg self) (sel_registerName "setAccessibilityVerticalUnits:") accessibility-vertical-units))
(define (nsbutton-set-accessibility-visible-cells! self accessibility-visible-cells)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleCells: (coerce-arg accessibility-visible-cells)))
(define (nsbutton-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (_msg-20 (coerce-arg self) (sel_registerName "setAccessibilityVisibleCharacterRange:") accessibility-visible-character-range))
(define (nsbutton-set-accessibility-visible-children! self accessibility-visible-children)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleChildren: (coerce-arg accessibility-visible-children)))
(define (nsbutton-set-accessibility-visible-columns! self accessibility-visible-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleColumns: (coerce-arg accessibility-visible-columns)))
(define (nsbutton-set-accessibility-visible-rows! self accessibility-visible-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleRows: (coerce-arg accessibility-visible-rows)))
(define (nsbutton-set-accessibility-warning-value! self accessibility-warning-value)
  (tell #:type _void (coerce-arg self) setAccessibilityWarningValue: (coerce-arg accessibility-warning-value)))
(define (nsbutton-set-accessibility-window! self accessibility-window)
  (tell #:type _void (coerce-arg self) setAccessibilityWindow: (coerce-arg accessibility-window)))
(define (nsbutton-set-accessibility-windows! self accessibility-windows)
  (tell #:type _void (coerce-arg self) setAccessibilityWindows: (coerce-arg accessibility-windows)))
(define (nsbutton-set-accessibility-zoom-button! self accessibility-zoom-button)
  (tell #:type _void (coerce-arg self) setAccessibilityZoomButton: (coerce-arg accessibility-zoom-button)))
(define (nsbutton-set-animations! self animations)
  (tell #:type _void (coerce-arg self) setAnimations: (coerce-arg animations)))
(define (nsbutton-set-appearance! self appearance)
  (tell #:type _void (coerce-arg self) setAppearance: (coerce-arg appearance)))
(define (nsbutton-set-bounds-origin! self new-origin)
  (_msg-14 (coerce-arg self) (sel_registerName "setBoundsOrigin:") new-origin))
(define (nsbutton-set-bounds-size! self new-size)
  (_msg-31 (coerce-arg self) (sel_registerName "setBoundsSize:") new-size))
(define (nsbutton-set-button-type! self type)
  (_msg-56 (coerce-arg self) (sel_registerName "setButtonType:") type))
(define (nsbutton-set-frame-origin! self new-origin)
  (_msg-14 (coerce-arg self) (sel_registerName "setFrameOrigin:") new-origin))
(define (nsbutton-set-frame-size! self new-size)
  (_msg-31 (coerce-arg self) (sel_registerName "setFrameSize:") new-size))
(define (nsbutton-set-identifier! self identifier)
  (tell #:type _void (coerce-arg self) setIdentifier: (coerce-arg identifier)))
(define (nsbutton-set-mark! self sender)
  (tell #:type _void (coerce-arg self) setMark: (coerce-arg sender)))
(define (nsbutton-set-needs-display-in-rect! self invalid-rect)
  (_msg-24 (coerce-arg self) (sel_registerName "setNeedsDisplayInRect:") invalid-rect))
(define (nsbutton-set-next-state! self)
  (tell #:type _void (coerce-arg self) setNextState))
(define (nsbutton-set-periodic-delay-interval! self delay interval)
  (_msg-36 (coerce-arg self) (sel_registerName "setPeriodicDelay:interval:") delay interval))
(define (nsbutton-should-be-treated-as-ink-event self event)
  (_msg-38 (coerce-arg self) (sel_registerName "shouldBeTreatedAsInkEvent:") (coerce-arg event)))
(define (nsbutton-should-delay-window-ordering-for-event self event)
  (_msg-38 (coerce-arg self) (sel_registerName "shouldDelayWindowOrderingForEvent:") (coerce-arg event)))
(define (nsbutton-show-context-help self sender)
  (tell #:type _void (coerce-arg self) showContextHelp: (coerce-arg sender)))
(define (nsbutton-show-context-menu-for-selection self sender)
  (tell #:type _void (coerce-arg self) showContextMenuForSelection: (coerce-arg sender)))
(define (nsbutton-size-that-fits self size)
  (_msg-30 (coerce-arg self) (sel_registerName "sizeThatFits:") size))
(define (nsbutton-size-to-fit self)
  (tell #:type _void (coerce-arg self) sizeToFit))
(define (nsbutton-smart-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) smartMagnifyWithEvent: (coerce-arg event)))
(define (nsbutton-sort-subviews-using-function-context self compare context)
  (_msg-54 (coerce-arg self) (sel_registerName "sortSubviewsUsingFunction:context:") compare context))
(define (nsbutton-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (_msg-53 (coerce-arg self) (sel_registerName "supplementalTargetForAction:sender:") (sel_registerName action) (coerce-arg sender))
   ))
(define (nsbutton-swap-with-mark self sender)
  (tell #:type _void (coerce-arg self) swapWithMark: (coerce-arg sender)))
(define (nsbutton-swipe-with-event self event)
  (tell #:type _void (coerce-arg self) swipeWithEvent: (coerce-arg event)))
(define (nsbutton-tablet-point self event)
  (tell #:type _void (coerce-arg self) tabletPoint: (coerce-arg event)))
(define (nsbutton-tablet-proximity self event)
  (tell #:type _void (coerce-arg self) tabletProximity: (coerce-arg event)))
(define (nsbutton-take-double-value-from self sender)
  (tell #:type _void (coerce-arg self) takeDoubleValueFrom: (coerce-arg sender)))
(define (nsbutton-take-float-value-from self sender)
  (tell #:type _void (coerce-arg self) takeFloatValueFrom: (coerce-arg sender)))
(define (nsbutton-take-int-value-from self sender)
  (tell #:type _void (coerce-arg self) takeIntValueFrom: (coerce-arg sender)))
(define (nsbutton-take-integer-value-from self sender)
  (tell #:type _void (coerce-arg self) takeIntegerValueFrom: (coerce-arg sender)))
(define (nsbutton-take-object-value-from self sender)
  (tell #:type _void (coerce-arg self) takeObjectValueFrom: (coerce-arg sender)))
(define (nsbutton-take-string-value-from self sender)
  (tell #:type _void (coerce-arg self) takeStringValueFrom: (coerce-arg sender)))
(define (nsbutton-touches-began-with-event self event)
  (tell #:type _void (coerce-arg self) touchesBeganWithEvent: (coerce-arg event)))
(define (nsbutton-touches-cancelled-with-event self event)
  (tell #:type _void (coerce-arg self) touchesCancelledWithEvent: (coerce-arg event)))
(define (nsbutton-touches-ended-with-event self event)
  (tell #:type _void (coerce-arg self) touchesEndedWithEvent: (coerce-arg event)))
(define (nsbutton-touches-moved-with-event self event)
  (tell #:type _void (coerce-arg self) touchesMovedWithEvent: (coerce-arg event)))
(define (nsbutton-translate-origin-to-point self translation)
  (_msg-14 (coerce-arg self) (sel_registerName "translateOriginToPoint:") translation))
(define (nsbutton-translate-rects-needing-display-in-rect-by self clip-rect delta)
  (_msg-25 (coerce-arg self) (sel_registerName "translateRectsNeedingDisplayInRect:by:") clip-rect delta))
(define (nsbutton-transpose self sender)
  (tell #:type _void (coerce-arg self) transpose: (coerce-arg sender)))
(define (nsbutton-transpose-words self sender)
  (tell #:type _void (coerce-arg self) transposeWords: (coerce-arg sender)))
(define (nsbutton-try-to-perform-with self action object)
  (_msg-52 (coerce-arg self) (sel_registerName "tryToPerform:with:") (sel_registerName action) (coerce-arg object)))
(define (nsbutton-update-dragging-items-for-drag self sender)
  (tell #:type _void (coerce-arg self) updateDraggingItemsForDrag: (coerce-arg sender)))
(define (nsbutton-update-layer self)
  (tell #:type _void (coerce-arg self) updateLayer))
(define (nsbutton-uppercase-word self sender)
  (tell #:type _void (coerce-arg self) uppercaseWord: (coerce-arg sender)))
(define (nsbutton-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (tell (coerce-arg self) validRequestorForSendType: (coerce-arg send-type) returnType: (coerce-arg return-type))))
(define (nsbutton-validate-user-interface-item self item)
  (_msg-38 (coerce-arg self) (sel_registerName "validateUserInterfaceItem:") (coerce-arg item)))
(define (nsbutton-view-did-change-backing-properties self)
  (tell #:type _void (coerce-arg self) viewDidChangeBackingProperties))
(define (nsbutton-view-did-change-effective-appearance self)
  (tell #:type _void (coerce-arg self) viewDidChangeEffectiveAppearance))
(define (nsbutton-view-did-end-live-resize self)
  (tell #:type _void (coerce-arg self) viewDidEndLiveResize))
(define (nsbutton-view-did-hide self)
  (tell #:type _void (coerce-arg self) viewDidHide))
(define (nsbutton-view-did-move-to-superview self)
  (tell #:type _void (coerce-arg self) viewDidMoveToSuperview))
(define (nsbutton-view-did-move-to-window self)
  (tell #:type _void (coerce-arg self) viewDidMoveToWindow))
(define (nsbutton-view-did-unhide self)
  (tell #:type _void (coerce-arg self) viewDidUnhide))
(define (nsbutton-view-will-draw self)
  (tell #:type _void (coerce-arg self) viewWillDraw))
(define (nsbutton-view-will-move-to-superview self new-superview)
  (tell #:type _void (coerce-arg self) viewWillMoveToSuperview: (coerce-arg new-superview)))
(define (nsbutton-view-will-move-to-window self new-window)
  (tell #:type _void (coerce-arg self) viewWillMoveToWindow: (coerce-arg new-window)))
(define (nsbutton-view-will-start-live-resize self)
  (tell #:type _void (coerce-arg self) viewWillStartLiveResize))
(define (nsbutton-view-with-tag self tag)
  (wrap-objc-object
   (_msg-46 (coerce-arg self) (sel_registerName "viewWithTag:") tag)
   ))
(define (nsbutton-wants-forwarded-scroll-events-for-axis self axis)
  (_msg-45 (coerce-arg self) (sel_registerName "wantsForwardedScrollEventsForAxis:") axis))
(define (nsbutton-wants-periodic-dragging-updates self)
  (_msg-3 (coerce-arg self) (sel_registerName "wantsPeriodicDraggingUpdates")))
(define (nsbutton-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (_msg-45 (coerce-arg self) (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:") axis))
(define (nsbutton-will-open-menu-with-event self menu event)
  (tell #:type _void (coerce-arg self) willOpenMenu: (coerce-arg menu) withEvent: (coerce-arg event)))
(define (nsbutton-will-remove-subview self subview)
  (tell #:type _void (coerce-arg self) willRemoveSubview: (coerce-arg subview)))
(define (nsbutton-yank self sender)
  (tell #:type _void (coerce-arg self) yank: (coerce-arg sender)))

;; --- Class methods ---
(define (nsbutton-button-with-image-target-action image target action)
  (wrap-objc-object
   (_msg-41 NSButton (sel_registerName "buttonWithImage:target:action:") (coerce-arg image) (coerce-arg target) (sel_registerName action))
   ))
(define (nsbutton-button-with-title-image-target-action title image target action)
  (wrap-objc-object
   (_msg-40 NSButton (sel_registerName "buttonWithTitle:image:target:action:") (coerce-arg title) (coerce-arg image) (coerce-arg target) (sel_registerName action))
   ))
(define (nsbutton-button-with-title-target-action title target action)
  (wrap-objc-object
   (_msg-41 NSButton (sel_registerName "buttonWithTitle:target:action:") (coerce-arg title) (coerce-arg target) (sel_registerName action))
   ))
(define (nsbutton-checkbox-with-title-target-action title target action)
  (wrap-objc-object
   (_msg-41 NSButton (sel_registerName "checkboxWithTitle:target:action:") (coerce-arg title) (coerce-arg target) (sel_registerName action))
   ))
(define (nsbutton-default-animation-for-key key)
  (wrap-objc-object
   (tell NSButton defaultAnimationForKey: (coerce-arg key))))
(define (nsbutton-is-compatible-with-responsive-scrolling)
  (_msg-3 NSButton (sel_registerName "isCompatibleWithResponsiveScrolling")))
(define (nsbutton-radio-button-with-title-target-action title target action)
  (wrap-objc-object
   (_msg-41 NSButton (sel_registerName "radioButtonWithTitle:target:action:") (coerce-arg title) (coerce-arg target) (sel_registerName action))
   ))
