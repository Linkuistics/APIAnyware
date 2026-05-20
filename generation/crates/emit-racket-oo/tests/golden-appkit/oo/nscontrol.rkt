#lang racket/base
;; Generated binding for NSControl (AppKit)
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
(define (nscandidatelisttouchbaritem? v) (objc-instance-of? v "NSCandidateListTouchBarItem"))
(define (nscontrol? v) (objc-instance-of? v "NSControl"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsedgeinsets? v) (objc-instance-of? v "NSEdgeInsets"))
(define (nsfont? v) (objc-instance-of? v "NSFont"))
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
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (nstextinputcontext? v) (objc-instance-of? v "NSTextInputContext"))
(define (nstouchbar? v) (objc-instance-of? v "NSTouchBar"))
(define (nsurl? v) (objc-instance-of? v "NSURL"))
(define (nsundomanager? v) (objc-instance-of? v "NSUndoManager"))
(define (nsuseractivity? v) (objc-instance-of? v "NSUserActivity"))
(define (nsview? v) (objc-instance-of? v "NSView"))
(define (nswindow? v) (objc-instance-of? v "NSWindow"))
(define (nswritingtoolscoordinator? v) (objc-instance-of? v "NSWritingToolsCoordinator"))
(provide NSControl)
(provide/contract
  [make-nscontrol-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nscontrol-init-with-frame (c-> any/c any/c)]
  [nscontrol-accepts-first-responder (c-> nscontrol? boolean?)]
  [nscontrol-accepts-touch-events (c-> nscontrol? boolean?)]
  [nscontrol-set-accepts-touch-events! (c-> nscontrol? boolean? void?)]
  [nscontrol-action (c-> nscontrol? cpointer?)]
  [nscontrol-set-action! (c-> nscontrol? string? void?)]
  [nscontrol-additional-safe-area-insets (c-> nscontrol? any/c)]
  [nscontrol-set-additional-safe-area-insets! (c-> nscontrol? any/c void?)]
  [nscontrol-alignment (c-> nscontrol? exact-nonnegative-integer?)]
  [nscontrol-set-alignment! (c-> nscontrol? exact-nonnegative-integer? void?)]
  [nscontrol-alignment-rect-insets (c-> nscontrol? any/c)]
  [nscontrol-allowed-touch-types (c-> nscontrol? exact-nonnegative-integer?)]
  [nscontrol-set-allowed-touch-types! (c-> nscontrol? exact-nonnegative-integer? void?)]
  [nscontrol-allows-expansion-tool-tips (c-> nscontrol? boolean?)]
  [nscontrol-set-allows-expansion-tool-tips! (c-> nscontrol? boolean? void?)]
  [nscontrol-allows-vibrancy (c-> nscontrol? boolean?)]
  [nscontrol-alpha-value (c-> nscontrol? real?)]
  [nscontrol-set-alpha-value! (c-> nscontrol? real? void?)]
  [nscontrol-attributed-string-value (c-> nscontrol? (or/c nsattributedstring? objc-nil?))]
  [nscontrol-set-attributed-string-value! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-autoresizes-subviews (c-> nscontrol? boolean?)]
  [nscontrol-set-autoresizes-subviews! (c-> nscontrol? boolean? void?)]
  [nscontrol-autoresizing-mask (c-> nscontrol? exact-nonnegative-integer?)]
  [nscontrol-set-autoresizing-mask! (c-> nscontrol? exact-nonnegative-integer? void?)]
  [nscontrol-background-filters (c-> nscontrol? any/c)]
  [nscontrol-set-background-filters! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-base-writing-direction (c-> nscontrol? exact-nonnegative-integer?)]
  [nscontrol-set-base-writing-direction! (c-> nscontrol? exact-nonnegative-integer? void?)]
  [nscontrol-baseline-offset-from-bottom (c-> nscontrol? real?)]
  [nscontrol-bottom-anchor (c-> nscontrol? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nscontrol-bounds (c-> nscontrol? any/c)]
  [nscontrol-set-bounds! (c-> nscontrol? any/c void?)]
  [nscontrol-bounds-rotation (c-> nscontrol? real?)]
  [nscontrol-set-bounds-rotation! (c-> nscontrol? real? void?)]
  [nscontrol-can-become-key-view (c-> nscontrol? boolean?)]
  [nscontrol-can-draw (c-> nscontrol? boolean?)]
  [nscontrol-can-draw-concurrently (c-> nscontrol? boolean?)]
  [nscontrol-set-can-draw-concurrently! (c-> nscontrol? boolean? void?)]
  [nscontrol-can-draw-subviews-into-layer (c-> nscontrol? boolean?)]
  [nscontrol-set-can-draw-subviews-into-layer! (c-> nscontrol? boolean? void?)]
  [nscontrol-candidate-list-touch-bar-item (c-> nscontrol? (or/c nscandidatelisttouchbaritem? objc-nil?))]
  [nscontrol-cell (c-> nscontrol? any/c)]
  [nscontrol-set-cell! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-cell-class (c-> cpointer?)]
  [nscontrol-set-cell-class! (c-> cpointer? void?)]
  [nscontrol-center-x-anchor (c-> nscontrol? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nscontrol-center-y-anchor (c-> nscontrol? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nscontrol-clips-to-bounds (c-> nscontrol? boolean?)]
  [nscontrol-set-clips-to-bounds! (c-> nscontrol? boolean? void?)]
  [nscontrol-compatible-with-responsive-scrolling (c-> boolean?)]
  [nscontrol-compositing-filter (c-> nscontrol? (or/c cifilter? objc-nil?))]
  [nscontrol-set-compositing-filter! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-constraints (c-> nscontrol? any/c)]
  [nscontrol-content-filters (c-> nscontrol? any/c)]
  [nscontrol-set-content-filters! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-continuous (c-> nscontrol? boolean?)]
  [nscontrol-set-continuous! (c-> nscontrol? boolean? void?)]
  [nscontrol-control-size (c-> nscontrol? exact-nonnegative-integer?)]
  [nscontrol-set-control-size! (c-> nscontrol? exact-nonnegative-integer? void?)]
  [nscontrol-default-focus-ring-type (c-> exact-nonnegative-integer?)]
  [nscontrol-default-menu (c-> (or/c nsmenu? objc-nil?))]
  [nscontrol-double-value (c-> nscontrol? real?)]
  [nscontrol-set-double-value! (c-> nscontrol? real? void?)]
  [nscontrol-drawing-find-indicator (c-> nscontrol? boolean?)]
  [nscontrol-enabled (c-> nscontrol? boolean?)]
  [nscontrol-set-enabled! (c-> nscontrol? boolean? void?)]
  [nscontrol-enclosing-menu-item (c-> nscontrol? (or/c nsmenuitem? objc-nil?))]
  [nscontrol-enclosing-scroll-view (c-> nscontrol? (or/c nsscrollview? objc-nil?))]
  [nscontrol-first-baseline-anchor (c-> nscontrol? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nscontrol-first-baseline-offset-from-top (c-> nscontrol? real?)]
  [nscontrol-fitting-size (c-> nscontrol? any/c)]
  [nscontrol-flipped (c-> nscontrol? boolean?)]
  [nscontrol-float-value (c-> nscontrol? real?)]
  [nscontrol-set-float-value! (c-> nscontrol? real? void?)]
  [nscontrol-focus-ring-mask-bounds (c-> nscontrol? any/c)]
  [nscontrol-focus-ring-type (c-> nscontrol? exact-nonnegative-integer?)]
  [nscontrol-set-focus-ring-type! (c-> nscontrol? exact-nonnegative-integer? void?)]
  [nscontrol-focus-view (c-> (or/c nsview? objc-nil?))]
  [nscontrol-font (c-> nscontrol? (or/c nsfont? objc-nil?))]
  [nscontrol-set-font! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-formatter (c-> nscontrol? any/c)]
  [nscontrol-set-formatter! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-frame (c-> nscontrol? any/c)]
  [nscontrol-set-frame! (c-> nscontrol? any/c void?)]
  [nscontrol-frame-center-rotation (c-> nscontrol? real?)]
  [nscontrol-set-frame-center-rotation! (c-> nscontrol? real? void?)]
  [nscontrol-frame-rotation (c-> nscontrol? real?)]
  [nscontrol-set-frame-rotation! (c-> nscontrol? real? void?)]
  [nscontrol-gesture-recognizers (c-> nscontrol? any/c)]
  [nscontrol-set-gesture-recognizers! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-has-ambiguous-layout (c-> nscontrol? boolean?)]
  [nscontrol-height-adjust-limit (c-> nscontrol? real?)]
  [nscontrol-height-anchor (c-> nscontrol? (or/c nslayoutdimension? objc-nil?))]
  [nscontrol-hidden (c-> nscontrol? boolean?)]
  [nscontrol-set-hidden! (c-> nscontrol? boolean? void?)]
  [nscontrol-hidden-or-has-hidden-ancestor (c-> nscontrol? boolean?)]
  [nscontrol-highlighted (c-> nscontrol? boolean?)]
  [nscontrol-set-highlighted! (c-> nscontrol? boolean? void?)]
  [nscontrol-horizontal-content-size-constraint-active (c-> nscontrol? boolean?)]
  [nscontrol-set-horizontal-content-size-constraint-active! (c-> nscontrol? boolean? void?)]
  [nscontrol-ignores-multi-click (c-> nscontrol? boolean?)]
  [nscontrol-set-ignores-multi-click! (c-> nscontrol? boolean? void?)]
  [nscontrol-in-full-screen-mode (c-> nscontrol? boolean?)]
  [nscontrol-in-live-resize (c-> nscontrol? boolean?)]
  [nscontrol-input-context (c-> nscontrol? (or/c nstextinputcontext? objc-nil?))]
  [nscontrol-int-value (c-> nscontrol? exact-integer?)]
  [nscontrol-set-int-value! (c-> nscontrol? exact-integer? void?)]
  [nscontrol-integer-value (c-> nscontrol? exact-integer?)]
  [nscontrol-set-integer-value! (c-> nscontrol? exact-integer? void?)]
  [nscontrol-intrinsic-content-size (c-> nscontrol? any/c)]
  [nscontrol-last-baseline-anchor (c-> nscontrol? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nscontrol-last-baseline-offset-from-bottom (c-> nscontrol? real?)]
  [nscontrol-layer (c-> nscontrol? (or/c calayer? objc-nil?))]
  [nscontrol-set-layer! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-layer-contents-placement (c-> nscontrol? exact-nonnegative-integer?)]
  [nscontrol-set-layer-contents-placement! (c-> nscontrol? exact-nonnegative-integer? void?)]
  [nscontrol-layer-contents-redraw-policy (c-> nscontrol? exact-nonnegative-integer?)]
  [nscontrol-set-layer-contents-redraw-policy! (c-> nscontrol? exact-nonnegative-integer? void?)]
  [nscontrol-layer-uses-core-image-filters (c-> nscontrol? boolean?)]
  [nscontrol-set-layer-uses-core-image-filters! (c-> nscontrol? boolean? void?)]
  [nscontrol-layout-guides (c-> nscontrol? any/c)]
  [nscontrol-layout-margins-guide (c-> nscontrol? (or/c nslayoutguide? objc-nil?))]
  [nscontrol-leading-anchor (c-> nscontrol? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nscontrol-left-anchor (c-> nscontrol? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nscontrol-line-break-mode (c-> nscontrol? exact-nonnegative-integer?)]
  [nscontrol-set-line-break-mode! (c-> nscontrol? exact-nonnegative-integer? void?)]
  [nscontrol-menu (c-> nscontrol? (or/c nsmenu? objc-nil?))]
  [nscontrol-set-menu! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-mouse-down-can-move-window (c-> nscontrol? boolean?)]
  [nscontrol-needs-display (c-> nscontrol? boolean?)]
  [nscontrol-set-needs-display! (c-> nscontrol? boolean? void?)]
  [nscontrol-needs-layout (c-> nscontrol? boolean?)]
  [nscontrol-set-needs-layout! (c-> nscontrol? boolean? void?)]
  [nscontrol-needs-panel-to-become-key (c-> nscontrol? boolean?)]
  [nscontrol-needs-update-constraints (c-> nscontrol? boolean?)]
  [nscontrol-set-needs-update-constraints! (c-> nscontrol? boolean? void?)]
  [nscontrol-next-key-view (c-> nscontrol? (or/c nsview? objc-nil?))]
  [nscontrol-set-next-key-view! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-next-responder (c-> nscontrol? (or/c nsresponder? objc-nil?))]
  [nscontrol-set-next-responder! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-next-valid-key-view (c-> nscontrol? (or/c nsview? objc-nil?))]
  [nscontrol-object-value (c-> nscontrol? any/c)]
  [nscontrol-set-object-value! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-opaque (c-> nscontrol? boolean?)]
  [nscontrol-opaque-ancestor (c-> nscontrol? (or/c nsview? objc-nil?))]
  [nscontrol-page-footer (c-> nscontrol? (or/c nsattributedstring? objc-nil?))]
  [nscontrol-page-header (c-> nscontrol? (or/c nsattributedstring? objc-nil?))]
  [nscontrol-posts-bounds-changed-notifications (c-> nscontrol? boolean?)]
  [nscontrol-set-posts-bounds-changed-notifications! (c-> nscontrol? boolean? void?)]
  [nscontrol-posts-frame-changed-notifications (c-> nscontrol? boolean?)]
  [nscontrol-set-posts-frame-changed-notifications! (c-> nscontrol? boolean? void?)]
  [nscontrol-prefers-compact-control-size-metrics (c-> nscontrol? boolean?)]
  [nscontrol-set-prefers-compact-control-size-metrics! (c-> nscontrol? boolean? void?)]
  [nscontrol-prepared-content-rect (c-> nscontrol? any/c)]
  [nscontrol-set-prepared-content-rect! (c-> nscontrol? any/c void?)]
  [nscontrol-preserves-content-during-live-resize (c-> nscontrol? boolean?)]
  [nscontrol-pressure-configuration (c-> nscontrol? (or/c nspressureconfiguration? objc-nil?))]
  [nscontrol-set-pressure-configuration! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-previous-key-view (c-> nscontrol? (or/c nsview? objc-nil?))]
  [nscontrol-previous-valid-key-view (c-> nscontrol? (or/c nsview? objc-nil?))]
  [nscontrol-print-job-title (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-rect-preserved-during-live-resize (c-> nscontrol? any/c)]
  [nscontrol-refuses-first-responder (c-> nscontrol? boolean?)]
  [nscontrol-set-refuses-first-responder! (c-> nscontrol? boolean? void?)]
  [nscontrol-registered-dragged-types (c-> nscontrol? any/c)]
  [nscontrol-requires-constraint-based-layout (c-> boolean?)]
  [nscontrol-restorable-state-key-paths (c-> any/c)]
  [nscontrol-right-anchor (c-> nscontrol? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nscontrol-rotated-from-base (c-> nscontrol? boolean?)]
  [nscontrol-rotated-or-scaled-from-base (c-> nscontrol? boolean?)]
  [nscontrol-safe-area-insets (c-> nscontrol? any/c)]
  [nscontrol-safe-area-layout-guide (c-> nscontrol? (or/c nslayoutguide? objc-nil?))]
  [nscontrol-safe-area-rect (c-> nscontrol? any/c)]
  [nscontrol-shadow (c-> nscontrol? (or/c nsshadow? objc-nil?))]
  [nscontrol-set-shadow! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-string-value (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-set-string-value! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-subviews (c-> nscontrol? any/c)]
  [nscontrol-set-subviews! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-superview (c-> nscontrol? (or/c nsview? objc-nil?))]
  [nscontrol-tag (c-> nscontrol? exact-integer?)]
  [nscontrol-set-tag! (c-> nscontrol? exact-integer? void?)]
  [nscontrol-target (c-> nscontrol? any/c)]
  [nscontrol-set-target! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-tool-tip (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-set-tool-tip! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-top-anchor (c-> nscontrol? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nscontrol-touch-bar (c-> nscontrol? (or/c nstouchbar? objc-nil?))]
  [nscontrol-set-touch-bar! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-tracking-areas (c-> nscontrol? any/c)]
  [nscontrol-trailing-anchor (c-> nscontrol? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nscontrol-translates-autoresizing-mask-into-constraints (c-> nscontrol? boolean?)]
  [nscontrol-set-translates-autoresizing-mask-into-constraints! (c-> nscontrol? boolean? void?)]
  [nscontrol-undo-manager (c-> nscontrol? (or/c nsundomanager? objc-nil?))]
  [nscontrol-user-activity (c-> nscontrol? (or/c nsuseractivity? objc-nil?))]
  [nscontrol-set-user-activity! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-user-interface-layout-direction (c-> nscontrol? exact-nonnegative-integer?)]
  [nscontrol-set-user-interface-layout-direction! (c-> nscontrol? exact-nonnegative-integer? void?)]
  [nscontrol-uses-single-line-mode (c-> nscontrol? boolean?)]
  [nscontrol-set-uses-single-line-mode! (c-> nscontrol? boolean? void?)]
  [nscontrol-vertical-content-size-constraint-active (c-> nscontrol? boolean?)]
  [nscontrol-set-vertical-content-size-constraint-active! (c-> nscontrol? boolean? void?)]
  [nscontrol-visible-rect (c-> nscontrol? any/c)]
  [nscontrol-wants-best-resolution-open-gl-surface (c-> nscontrol? boolean?)]
  [nscontrol-set-wants-best-resolution-open-gl-surface! (c-> nscontrol? boolean? void?)]
  [nscontrol-wants-default-clipping (c-> nscontrol? boolean?)]
  [nscontrol-wants-extended-dynamic-range-open-gl-surface (c-> nscontrol? boolean?)]
  [nscontrol-set-wants-extended-dynamic-range-open-gl-surface! (c-> nscontrol? boolean? void?)]
  [nscontrol-wants-layer (c-> nscontrol? boolean?)]
  [nscontrol-set-wants-layer! (c-> nscontrol? boolean? void?)]
  [nscontrol-wants-resting-touches (c-> nscontrol? boolean?)]
  [nscontrol-set-wants-resting-touches! (c-> nscontrol? boolean? void?)]
  [nscontrol-wants-update-layer (c-> nscontrol? boolean?)]
  [nscontrol-width-adjust-limit (c-> nscontrol? real?)]
  [nscontrol-width-anchor (c-> nscontrol? (or/c nslayoutdimension? objc-nil?))]
  [nscontrol-window (c-> nscontrol? (or/c nswindow? objc-nil?))]
  [nscontrol-writing-tools-coordinator (c-> nscontrol? (or/c nswritingtoolscoordinator? objc-nil?))]
  [nscontrol-set-writing-tools-coordinator! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-accepts-first-mouse (c-> nscontrol? (or/c string? objc-object? #f) boolean?)]
  [nscontrol-accessibility-activation-point (c-> nscontrol? any/c)]
  [nscontrol-accessibility-allowed-values (c-> nscontrol? any/c)]
  [nscontrol-accessibility-application-focused-ui-element (c-> nscontrol? any/c)]
  [nscontrol-accessibility-attributed-string-for-range (c-> nscontrol? any/c (or/c nsattributedstring? objc-nil?))]
  [nscontrol-accessibility-attributed-user-input-labels (c-> nscontrol? any/c)]
  [nscontrol-accessibility-cancel-button (c-> nscontrol? any/c)]
  [nscontrol-accessibility-cell-for-column-row (c-> nscontrol? exact-integer? exact-integer? any/c)]
  [nscontrol-accessibility-children (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-children-in-navigation-order (c-> nscontrol? any/c)]
  [nscontrol-accessibility-clear-button (c-> nscontrol? any/c)]
  [nscontrol-accessibility-close-button (c-> nscontrol? any/c)]
  [nscontrol-accessibility-column-count (c-> nscontrol? exact-integer?)]
  [nscontrol-accessibility-column-header-ui-elements (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-column-index-range (c-> nscontrol? any/c)]
  [nscontrol-accessibility-column-titles (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-columns (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-contents (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-critical-value (c-> nscontrol? any/c)]
  [nscontrol-accessibility-custom-actions (c-> nscontrol? any/c)]
  [nscontrol-accessibility-custom-rotors (c-> nscontrol? any/c)]
  [nscontrol-accessibility-decrement-button (c-> nscontrol? any/c)]
  [nscontrol-accessibility-default-button (c-> nscontrol? any/c)]
  [nscontrol-accessibility-disclosed-by-row (c-> nscontrol? any/c)]
  [nscontrol-accessibility-disclosed-rows (c-> nscontrol? any/c)]
  [nscontrol-accessibility-disclosure-level (c-> nscontrol? exact-integer?)]
  [nscontrol-accessibility-document (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-extras-menu-bar (c-> nscontrol? any/c)]
  [nscontrol-accessibility-filename (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-focused-window (c-> nscontrol? any/c)]
  [nscontrol-accessibility-frame (c-> nscontrol? any/c)]
  [nscontrol-accessibility-frame-for-range (c-> nscontrol? any/c any/c)]
  [nscontrol-accessibility-full-screen-button (c-> nscontrol? any/c)]
  [nscontrol-accessibility-grow-area (c-> nscontrol? any/c)]
  [nscontrol-accessibility-handles (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-header (c-> nscontrol? any/c)]
  [nscontrol-accessibility-help (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-horizontal-scroll-bar (c-> nscontrol? any/c)]
  [nscontrol-accessibility-horizontal-unit-description (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-horizontal-units (c-> nscontrol? exact-nonnegative-integer?)]
  [nscontrol-accessibility-identifier (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-increment-button (c-> nscontrol? any/c)]
  [nscontrol-accessibility-index (c-> nscontrol? exact-integer?)]
  [nscontrol-accessibility-insertion-point-line-number (c-> nscontrol? exact-integer?)]
  [nscontrol-accessibility-label (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-label-ui-elements (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-label-value (c-> nscontrol? real?)]
  [nscontrol-accessibility-layout-point-for-screen-point (c-> nscontrol? any/c any/c)]
  [nscontrol-accessibility-layout-size-for-screen-size (c-> nscontrol? any/c any/c)]
  [nscontrol-accessibility-line-for-index (c-> nscontrol? exact-integer? exact-integer?)]
  [nscontrol-accessibility-linked-ui-elements (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-main-window (c-> nscontrol? any/c)]
  [nscontrol-accessibility-marker-group-ui-element (c-> nscontrol? any/c)]
  [nscontrol-accessibility-marker-type-description (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-marker-ui-elements (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-marker-values (c-> nscontrol? any/c)]
  [nscontrol-accessibility-max-value (c-> nscontrol? any/c)]
  [nscontrol-accessibility-menu-bar (c-> nscontrol? any/c)]
  [nscontrol-accessibility-min-value (c-> nscontrol? any/c)]
  [nscontrol-accessibility-minimize-button (c-> nscontrol? any/c)]
  [nscontrol-accessibility-next-contents (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-number-of-characters (c-> nscontrol? exact-integer?)]
  [nscontrol-accessibility-orientation (c-> nscontrol? exact-nonnegative-integer?)]
  [nscontrol-accessibility-overflow-button (c-> nscontrol? any/c)]
  [nscontrol-accessibility-parent (c-> nscontrol? any/c)]
  [nscontrol-accessibility-perform-cancel (c-> nscontrol? boolean?)]
  [nscontrol-accessibility-perform-confirm (c-> nscontrol? boolean?)]
  [nscontrol-accessibility-perform-decrement (c-> nscontrol? boolean?)]
  [nscontrol-accessibility-perform-delete (c-> nscontrol? boolean?)]
  [nscontrol-accessibility-perform-increment (c-> nscontrol? boolean?)]
  [nscontrol-accessibility-perform-pick (c-> nscontrol? boolean?)]
  [nscontrol-accessibility-perform-press (c-> nscontrol? boolean?)]
  [nscontrol-accessibility-perform-raise (c-> nscontrol? boolean?)]
  [nscontrol-accessibility-perform-show-alternate-ui (c-> nscontrol? boolean?)]
  [nscontrol-accessibility-perform-show-default-ui (c-> nscontrol? boolean?)]
  [nscontrol-accessibility-perform-show-menu (c-> nscontrol? boolean?)]
  [nscontrol-accessibility-placeholder-value (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-previous-contents (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-proxy (c-> nscontrol? any/c)]
  [nscontrol-accessibility-rtf-for-range (c-> nscontrol? any/c (or/c nsdata? objc-nil?))]
  [nscontrol-accessibility-range-for-index (c-> nscontrol? exact-integer? any/c)]
  [nscontrol-accessibility-range-for-line (c-> nscontrol? exact-integer? any/c)]
  [nscontrol-accessibility-range-for-position (c-> nscontrol? any/c any/c)]
  [nscontrol-accessibility-role (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-role-description (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-row-count (c-> nscontrol? exact-integer?)]
  [nscontrol-accessibility-row-header-ui-elements (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-row-index-range (c-> nscontrol? any/c)]
  [nscontrol-accessibility-rows (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-ruler-marker-type (c-> nscontrol? exact-nonnegative-integer?)]
  [nscontrol-accessibility-screen-point-for-layout-point (c-> nscontrol? any/c any/c)]
  [nscontrol-accessibility-screen-size-for-layout-size (c-> nscontrol? any/c any/c)]
  [nscontrol-accessibility-search-button (c-> nscontrol? any/c)]
  [nscontrol-accessibility-search-menu (c-> nscontrol? any/c)]
  [nscontrol-accessibility-selected-cells (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-selected-children (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-selected-columns (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-selected-rows (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-selected-text (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-selected-text-range (c-> nscontrol? any/c)]
  [nscontrol-accessibility-selected-text-ranges (c-> nscontrol? any/c)]
  [nscontrol-accessibility-serves-as-title-for-ui-elements (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-shared-character-range (c-> nscontrol? any/c)]
  [nscontrol-accessibility-shared-focus-elements (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-shared-text-ui-elements (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-shown-menu (c-> nscontrol? any/c)]
  [nscontrol-accessibility-sort-direction (c-> nscontrol? exact-nonnegative-integer?)]
  [nscontrol-accessibility-splitters (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-string-for-range (c-> nscontrol? any/c (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-style-range-for-index (c-> nscontrol? exact-integer? any/c)]
  [nscontrol-accessibility-subrole (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-tabs (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-title (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-title-ui-element (c-> nscontrol? any/c)]
  [nscontrol-accessibility-toolbar-button (c-> nscontrol? any/c)]
  [nscontrol-accessibility-top-level-ui-element (c-> nscontrol? any/c)]
  [nscontrol-accessibility-url (c-> nscontrol? (or/c nsurl? objc-nil?))]
  [nscontrol-accessibility-unit-description (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-units (c-> nscontrol? exact-nonnegative-integer?)]
  [nscontrol-accessibility-user-input-labels (c-> nscontrol? any/c)]
  [nscontrol-accessibility-value (c-> nscontrol? any/c)]
  [nscontrol-accessibility-value-description (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-vertical-scroll-bar (c-> nscontrol? any/c)]
  [nscontrol-accessibility-vertical-unit-description (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-vertical-units (c-> nscontrol? exact-nonnegative-integer?)]
  [nscontrol-accessibility-visible-cells (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-visible-character-range (c-> nscontrol? any/c)]
  [nscontrol-accessibility-visible-children (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-visible-columns (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-visible-rows (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-warning-value (c-> nscontrol? any/c)]
  [nscontrol-accessibility-window (c-> nscontrol? any/c)]
  [nscontrol-accessibility-windows (c-> nscontrol? (or/c nsarray? objc-nil?))]
  [nscontrol-accessibility-zoom-button (c-> nscontrol? any/c)]
  [nscontrol-add-subview! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-add-subview-positioned-relative-to! (c-> nscontrol? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c string? objc-object? #f) void?)]
  [nscontrol-add-tool-tip-rect-owner-user-data! (c-> nscontrol? any/c (or/c string? objc-object? #f) (or/c cpointer? #f) exact-integer?)]
  [nscontrol-adjust-scroll (c-> nscontrol? any/c any/c)]
  [nscontrol-ancestor-shared-with-view (c-> nscontrol? (or/c string? objc-object? #f) (or/c nsview? objc-nil?))]
  [nscontrol-animation-for-key (c-> nscontrol? (or/c string? objc-object? #f) any/c)]
  [nscontrol-animations (c-> nscontrol? any/c)]
  [nscontrol-animator (c-> nscontrol? any/c)]
  [nscontrol-appearance (c-> nscontrol? (or/c nsappearance? objc-nil?))]
  [nscontrol-autoscroll (c-> nscontrol? (or/c string? objc-object? #f) boolean?)]
  [nscontrol-backing-aligned-rect-options (c-> nscontrol? any/c exact-nonnegative-integer? any/c)]
  [nscontrol-become-first-responder (c-> nscontrol? boolean?)]
  [nscontrol-begin-gesture-with-event! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-bitmap-image-rep-for-caching-display-in-rect (c-> nscontrol? any/c (or/c nsbitmapimagerep? objc-nil?))]
  [nscontrol-cache-display-in-rect-to-bitmap-image-rep (c-> nscontrol? any/c (or/c string? objc-object? #f) void?)]
  [nscontrol-cancel-operation (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-capitalize-word (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-center-scan-rect! (c-> nscontrol? any/c any/c)]
  [nscontrol-center-selection-in-visible-area! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-change-case-of-letter (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-change-mode-with-event (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-complete (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-conclude-drag-operation (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-context-menu-key-down (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-convert-point-from-view (c-> nscontrol? any/c (or/c string? objc-object? #f) any/c)]
  [nscontrol-convert-point-to-view (c-> nscontrol? any/c (or/c string? objc-object? #f) any/c)]
  [nscontrol-convert-point-from-backing (c-> nscontrol? any/c any/c)]
  [nscontrol-convert-point-from-layer (c-> nscontrol? any/c any/c)]
  [nscontrol-convert-point-to-backing (c-> nscontrol? any/c any/c)]
  [nscontrol-convert-point-to-layer (c-> nscontrol? any/c any/c)]
  [nscontrol-convert-rect-from-view (c-> nscontrol? any/c (or/c string? objc-object? #f) any/c)]
  [nscontrol-convert-rect-to-view (c-> nscontrol? any/c (or/c string? objc-object? #f) any/c)]
  [nscontrol-convert-rect-from-backing (c-> nscontrol? any/c any/c)]
  [nscontrol-convert-rect-from-layer (c-> nscontrol? any/c any/c)]
  [nscontrol-convert-rect-to-backing (c-> nscontrol? any/c any/c)]
  [nscontrol-convert-rect-to-layer (c-> nscontrol? any/c any/c)]
  [nscontrol-convert-size-from-view (c-> nscontrol? any/c (or/c string? objc-object? #f) any/c)]
  [nscontrol-convert-size-to-view (c-> nscontrol? any/c (or/c string? objc-object? #f) any/c)]
  [nscontrol-convert-size-from-backing (c-> nscontrol? any/c any/c)]
  [nscontrol-convert-size-from-layer (c-> nscontrol? any/c any/c)]
  [nscontrol-convert-size-to-backing (c-> nscontrol? any/c any/c)]
  [nscontrol-convert-size-to-layer (c-> nscontrol? any/c any/c)]
  [nscontrol-cursor-update (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-delete-backward (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-delete-backward-by-decomposing-previous-character (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-delete-forward (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-delete-to-beginning-of-line (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-delete-to-beginning-of-paragraph (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-delete-to-end-of-line (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-delete-to-end-of-paragraph (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-delete-to-mark (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-delete-word-backward (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-delete-word-forward (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-did-add-subview (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-did-close-menu-with-event (c-> nscontrol? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nscontrol-display! (c-> nscontrol? void?)]
  [nscontrol-display-if-needed! (c-> nscontrol? void?)]
  [nscontrol-display-if-needed-ignoring-opacity! (c-> nscontrol? void?)]
  [nscontrol-display-if-needed-in-rect! (c-> nscontrol? any/c void?)]
  [nscontrol-display-if-needed-in-rect-ignoring-opacity! (c-> nscontrol? any/c void?)]
  [nscontrol-display-rect! (c-> nscontrol? any/c void?)]
  [nscontrol-display-rect-ignoring-opacity! (c-> nscontrol? any/c void?)]
  [nscontrol-display-rect-ignoring-opacity-in-context! (c-> nscontrol? any/c (or/c string? objc-object? #f) void?)]
  [nscontrol-do-command-by-selector (c-> nscontrol? string? void?)]
  [nscontrol-dragging-ended (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-dragging-entered (c-> nscontrol? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nscontrol-dragging-exited (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-dragging-updated (c-> nscontrol? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nscontrol-draw-rect (c-> nscontrol? any/c void?)]
  [nscontrol-draw-with-expansion-frame-in-view (c-> nscontrol? any/c (or/c string? objc-object? #f) void?)]
  [nscontrol-effective-appearance (c-> nscontrol? (or/c nsappearance? objc-nil?))]
  [nscontrol-encode-with-coder (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-end-gesture-with-event! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-expansion-frame-with-frame (c-> nscontrol? any/c any/c)]
  [nscontrol-flags-changed (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-flush-buffered-key-events (c-> nscontrol? void?)]
  [nscontrol-get-rects-being-drawn-count (c-> nscontrol? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nscontrol-get-rects-exposed-during-live-resize-count (c-> nscontrol? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nscontrol-help-requested (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-hit-test (c-> nscontrol? any/c (or/c nsview? objc-nil?))]
  [nscontrol-identifier (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-indent (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-insert-backtab! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-insert-container-break! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-insert-double-quote-ignoring-substitution! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-insert-line-break! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-insert-newline! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-insert-newline-ignoring-field-editor! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-insert-paragraph-separator! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-insert-single-quote-ignoring-substitution! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-insert-tab! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-insert-tab-ignoring-field-editor! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-insert-text! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-interpret-key-events (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-is-accessibility-alternate-ui-visible (c-> nscontrol? boolean?)]
  [nscontrol-is-accessibility-disclosed (c-> nscontrol? boolean?)]
  [nscontrol-is-accessibility-edited (c-> nscontrol? boolean?)]
  [nscontrol-is-accessibility-element (c-> nscontrol? boolean?)]
  [nscontrol-is-accessibility-enabled (c-> nscontrol? boolean?)]
  [nscontrol-is-accessibility-expanded (c-> nscontrol? boolean?)]
  [nscontrol-is-accessibility-focused (c-> nscontrol? boolean?)]
  [nscontrol-is-accessibility-frontmost (c-> nscontrol? boolean?)]
  [nscontrol-is-accessibility-hidden (c-> nscontrol? boolean?)]
  [nscontrol-is-accessibility-main (c-> nscontrol? boolean?)]
  [nscontrol-is-accessibility-minimized (c-> nscontrol? boolean?)]
  [nscontrol-is-accessibility-modal (c-> nscontrol? boolean?)]
  [nscontrol-is-accessibility-ordered-by-row (c-> nscontrol? boolean?)]
  [nscontrol-is-accessibility-protected-content (c-> nscontrol? boolean?)]
  [nscontrol-is-accessibility-required (c-> nscontrol? boolean?)]
  [nscontrol-is-accessibility-selected (c-> nscontrol? boolean?)]
  [nscontrol-is-accessibility-selector-allowed (c-> nscontrol? string? boolean?)]
  [nscontrol-is-continuous (c-> nscontrol? boolean?)]
  [nscontrol-is-descendant-of (c-> nscontrol? (or/c string? objc-object? #f) boolean?)]
  [nscontrol-is-enabled (c-> nscontrol? boolean?)]
  [nscontrol-is-flipped (c-> nscontrol? boolean?)]
  [nscontrol-is-hidden (c-> nscontrol? boolean?)]
  [nscontrol-is-hidden-or-has-hidden-ancestor (c-> nscontrol? boolean?)]
  [nscontrol-is-highlighted (c-> nscontrol? boolean?)]
  [nscontrol-is-opaque (c-> nscontrol? boolean?)]
  [nscontrol-is-rotated-from-base (c-> nscontrol? boolean?)]
  [nscontrol-is-rotated-or-scaled-from-base (c-> nscontrol? boolean?)]
  [nscontrol-key-down (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-key-up (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-layout (c-> nscontrol? void?)]
  [nscontrol-layout-subtree-if-needed (c-> nscontrol? void?)]
  [nscontrol-lowercase-word (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-magnify-with-event (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-make-backing-layer (c-> nscontrol? (or/c calayer? objc-nil?))]
  [nscontrol-make-base-writing-direction-left-to-right (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-make-base-writing-direction-natural (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-make-base-writing-direction-right-to-left (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-make-text-writing-direction-left-to-right (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-make-text-writing-direction-natural (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-make-text-writing-direction-right-to-left (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-menu-for-event (c-> nscontrol? (or/c string? objc-object? #f) (or/c nsmenu? objc-nil?))]
  [nscontrol-mouse-in-rect (c-> nscontrol? any/c any/c boolean?)]
  [nscontrol-mouse-cancelled (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-mouse-down (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-mouse-dragged (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-mouse-entered (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-mouse-exited (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-mouse-moved (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-mouse-up (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-backward! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-backward-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-down! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-down-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-forward! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-forward-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-left! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-left-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-paragraph-backward-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-paragraph-forward-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-right! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-right-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-to-beginning-of-document! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-to-beginning-of-document-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-to-beginning-of-line! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-to-beginning-of-line-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-to-beginning-of-paragraph! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-to-beginning-of-paragraph-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-to-end-of-document! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-to-end-of-document-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-to-end-of-line! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-to-end-of-line-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-to-end-of-paragraph! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-to-end-of-paragraph-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-to-left-end-of-line! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-to-left-end-of-line-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-to-right-end-of-line! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-to-right-end-of-line-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-up! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-up-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-word-backward! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-word-backward-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-word-forward! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-word-forward-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-word-left! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-word-left-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-word-right! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-move-word-right-and-modify-selection! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-needs-to-draw-rect (c-> nscontrol? any/c boolean?)]
  [nscontrol-no-responder-for (c-> nscontrol? string? void?)]
  [nscontrol-other-mouse-down (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-other-mouse-dragged (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-other-mouse-up (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-page-down (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-page-down-and-modify-selection (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-page-up (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-page-up-and-modify-selection (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-perform-click! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-perform-drag-operation! (c-> nscontrol? (or/c string? objc-object? #f) boolean?)]
  [nscontrol-perform-key-equivalent! (c-> nscontrol? (or/c string? objc-object? #f) boolean?)]
  [nscontrol-prepare-content-in-rect (c-> nscontrol? any/c void?)]
  [nscontrol-prepare-for-drag-operation (c-> nscontrol? (or/c string? objc-object? #f) boolean?)]
  [nscontrol-prepare-for-reuse (c-> nscontrol? void?)]
  [nscontrol-pressure-change-with-event (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-quick-look-preview-items (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-quick-look-with-event (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-rect-for-smart-magnification-at-point-in-rect (c-> nscontrol? any/c any/c any/c)]
  [nscontrol-remove-all-tool-tips! (c-> nscontrol? void?)]
  [nscontrol-remove-from-superview! (c-> nscontrol? void?)]
  [nscontrol-remove-from-superview-without-needing-display! (c-> nscontrol? void?)]
  [nscontrol-remove-tool-tip! (c-> nscontrol? exact-integer? void?)]
  [nscontrol-replace-subview-with! (c-> nscontrol? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nscontrol-resign-first-responder (c-> nscontrol? boolean?)]
  [nscontrol-resize-subviews-with-old-size (c-> nscontrol? any/c void?)]
  [nscontrol-resize-with-old-superview-size (c-> nscontrol? any/c void?)]
  [nscontrol-restore-user-activity-state (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-right-mouse-down (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-right-mouse-dragged (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-right-mouse-up (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-rotate-by-angle (c-> nscontrol? real? void?)]
  [nscontrol-rotate-with-event (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-scale-unit-square-to-size (c-> nscontrol? any/c void?)]
  [nscontrol-scroll-line-down (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-scroll-line-up (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-scroll-page-down (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-scroll-page-up (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-scroll-point (c-> nscontrol? any/c void?)]
  [nscontrol-scroll-rect-to-visible (c-> nscontrol? any/c boolean?)]
  [nscontrol-scroll-to-beginning-of-document (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-scroll-to-end-of-document (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-scroll-wheel (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-select-all (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-select-line (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-select-paragraph (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-select-to-mark (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-select-word (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-send-action-to (c-> nscontrol? string? (or/c string? objc-object? #f) boolean?)]
  [nscontrol-send-action-on (c-> nscontrol? exact-nonnegative-integer? exact-integer?)]
  [nscontrol-set-accessibility-activation-point! (c-> nscontrol? any/c void?)]
  [nscontrol-set-accessibility-allowed-values! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-alternate-ui-visible! (c-> nscontrol? boolean? void?)]
  [nscontrol-set-accessibility-application-focused-ui-element! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-attributed-user-input-labels! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-cancel-button! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-children! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-children-in-navigation-order! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-clear-button! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-close-button! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-column-count! (c-> nscontrol? exact-integer? void?)]
  [nscontrol-set-accessibility-column-header-ui-elements! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-column-index-range! (c-> nscontrol? any/c void?)]
  [nscontrol-set-accessibility-column-titles! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-columns! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-contents! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-critical-value! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-custom-actions! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-custom-rotors! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-decrement-button! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-default-button! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-disclosed! (c-> nscontrol? boolean? void?)]
  [nscontrol-set-accessibility-disclosed-by-row! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-disclosed-rows! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-disclosure-level! (c-> nscontrol? exact-integer? void?)]
  [nscontrol-set-accessibility-document! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-edited! (c-> nscontrol? boolean? void?)]
  [nscontrol-set-accessibility-element! (c-> nscontrol? boolean? void?)]
  [nscontrol-set-accessibility-enabled! (c-> nscontrol? boolean? void?)]
  [nscontrol-set-accessibility-expanded! (c-> nscontrol? boolean? void?)]
  [nscontrol-set-accessibility-extras-menu-bar! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-filename! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-focused! (c-> nscontrol? boolean? void?)]
  [nscontrol-set-accessibility-focused-window! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-frame! (c-> nscontrol? any/c void?)]
  [nscontrol-set-accessibility-frontmost! (c-> nscontrol? boolean? void?)]
  [nscontrol-set-accessibility-full-screen-button! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-grow-area! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-handles! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-header! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-help! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-hidden! (c-> nscontrol? boolean? void?)]
  [nscontrol-set-accessibility-horizontal-scroll-bar! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-horizontal-unit-description! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-horizontal-units! (c-> nscontrol? exact-nonnegative-integer? void?)]
  [nscontrol-set-accessibility-identifier! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-increment-button! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-index! (c-> nscontrol? exact-integer? void?)]
  [nscontrol-set-accessibility-insertion-point-line-number! (c-> nscontrol? exact-integer? void?)]
  [nscontrol-set-accessibility-label! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-label-ui-elements! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-label-value! (c-> nscontrol? real? void?)]
  [nscontrol-set-accessibility-linked-ui-elements! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-main! (c-> nscontrol? boolean? void?)]
  [nscontrol-set-accessibility-main-window! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-marker-group-ui-element! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-marker-type-description! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-marker-ui-elements! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-marker-values! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-max-value! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-menu-bar! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-min-value! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-minimize-button! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-minimized! (c-> nscontrol? boolean? void?)]
  [nscontrol-set-accessibility-modal! (c-> nscontrol? boolean? void?)]
  [nscontrol-set-accessibility-next-contents! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-number-of-characters! (c-> nscontrol? exact-integer? void?)]
  [nscontrol-set-accessibility-ordered-by-row! (c-> nscontrol? boolean? void?)]
  [nscontrol-set-accessibility-orientation! (c-> nscontrol? exact-nonnegative-integer? void?)]
  [nscontrol-set-accessibility-overflow-button! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-parent! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-placeholder-value! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-previous-contents! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-protected-content! (c-> nscontrol? boolean? void?)]
  [nscontrol-set-accessibility-proxy! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-required! (c-> nscontrol? boolean? void?)]
  [nscontrol-set-accessibility-role! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-role-description! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-row-count! (c-> nscontrol? exact-integer? void?)]
  [nscontrol-set-accessibility-row-header-ui-elements! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-row-index-range! (c-> nscontrol? any/c void?)]
  [nscontrol-set-accessibility-rows! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-ruler-marker-type! (c-> nscontrol? exact-nonnegative-integer? void?)]
  [nscontrol-set-accessibility-search-button! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-search-menu! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-selected! (c-> nscontrol? boolean? void?)]
  [nscontrol-set-accessibility-selected-cells! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-selected-children! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-selected-columns! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-selected-rows! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-selected-text! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-selected-text-range! (c-> nscontrol? any/c void?)]
  [nscontrol-set-accessibility-selected-text-ranges! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-serves-as-title-for-ui-elements! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-shared-character-range! (c-> nscontrol? any/c void?)]
  [nscontrol-set-accessibility-shared-focus-elements! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-shared-text-ui-elements! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-shown-menu! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-sort-direction! (c-> nscontrol? exact-nonnegative-integer? void?)]
  [nscontrol-set-accessibility-splitters! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-subrole! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-tabs! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-title! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-title-ui-element! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-toolbar-button! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-top-level-ui-element! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-url! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-unit-description! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-units! (c-> nscontrol? exact-nonnegative-integer? void?)]
  [nscontrol-set-accessibility-user-input-labels! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-value! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-value-description! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-vertical-scroll-bar! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-vertical-unit-description! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-vertical-units! (c-> nscontrol? exact-nonnegative-integer? void?)]
  [nscontrol-set-accessibility-visible-cells! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-visible-character-range! (c-> nscontrol? any/c void?)]
  [nscontrol-set-accessibility-visible-children! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-visible-columns! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-visible-rows! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-warning-value! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-window! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-windows! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-zoom-button! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-animations! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-appearance! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-bounds-origin! (c-> nscontrol? any/c void?)]
  [nscontrol-set-bounds-size! (c-> nscontrol? any/c void?)]
  [nscontrol-set-frame-origin! (c-> nscontrol? any/c void?)]
  [nscontrol-set-frame-size! (c-> nscontrol? any/c void?)]
  [nscontrol-set-identifier! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-mark! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-needs-display-in-rect! (c-> nscontrol? any/c void?)]
  [nscontrol-should-be-treated-as-ink-event (c-> nscontrol? (or/c string? objc-object? #f) boolean?)]
  [nscontrol-should-delay-window-ordering-for-event (c-> nscontrol? (or/c string? objc-object? #f) boolean?)]
  [nscontrol-show-context-help (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-show-context-menu-for-selection (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-size-that-fits (c-> nscontrol? any/c any/c)]
  [nscontrol-size-to-fit (c-> nscontrol? void?)]
  [nscontrol-smart-magnify-with-event (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-sort-subviews-using-function-context (c-> nscontrol? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nscontrol-supplemental-target-for-action-sender (c-> nscontrol? string? (or/c string? objc-object? #f) any/c)]
  [nscontrol-swap-with-mark (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-swipe-with-event (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-tablet-point (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-tablet-proximity (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-take-double-value-from (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-take-float-value-from (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-take-int-value-from (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-take-integer-value-from (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-take-object-value-from (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-take-string-value-from (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-touches-began-with-event (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-touches-cancelled-with-event (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-touches-ended-with-event (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-touches-moved-with-event (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-translate-origin-to-point (c-> nscontrol? any/c void?)]
  [nscontrol-translate-rects-needing-display-in-rect-by (c-> nscontrol? any/c any/c void?)]
  [nscontrol-transpose (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-transpose-words (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-try-to-perform-with (c-> nscontrol? string? (or/c string? objc-object? #f) boolean?)]
  [nscontrol-update-dragging-items-for-drag (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-update-layer (c-> nscontrol? void?)]
  [nscontrol-uppercase-word (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-valid-requestor-for-send-type-return-type (c-> nscontrol? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nscontrol-view-did-change-backing-properties (c-> nscontrol? void?)]
  [nscontrol-view-did-change-effective-appearance (c-> nscontrol? void?)]
  [nscontrol-view-did-end-live-resize (c-> nscontrol? void?)]
  [nscontrol-view-did-hide (c-> nscontrol? void?)]
  [nscontrol-view-did-move-to-superview (c-> nscontrol? void?)]
  [nscontrol-view-did-move-to-window (c-> nscontrol? void?)]
  [nscontrol-view-did-unhide (c-> nscontrol? void?)]
  [nscontrol-view-will-draw (c-> nscontrol? void?)]
  [nscontrol-view-will-move-to-superview (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-view-will-move-to-window (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-view-will-start-live-resize (c-> nscontrol? void?)]
  [nscontrol-view-with-tag (c-> nscontrol? exact-integer? any/c)]
  [nscontrol-wants-forwarded-scroll-events-for-axis (c-> nscontrol? exact-nonnegative-integer? boolean?)]
  [nscontrol-wants-periodic-dragging-updates (c-> nscontrol? boolean?)]
  [nscontrol-wants-scroll-events-for-swipe-tracking-on-axis (c-> nscontrol? exact-nonnegative-integer? boolean?)]
  [nscontrol-will-open-menu-with-event (c-> nscontrol? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nscontrol-will-remove-subview (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-yank (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-default-animation-for-key (c-> (or/c string? objc-object? #f) any/c)]
  [nscontrol-is-compatible-with-responsive-scrolling (c-> boolean?)]
  )

;; --- Class reference ---
(import-class NSControl)

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
(define _msg-36  ; (_fun _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _bool)))
(define _msg-37  ; (_fun _pointer _pointer _id -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _uint64)))
(define _msg-38  ; (_fun _pointer _pointer _id _int64 _id -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _int64 _id -> _void)))
(define _msg-39  ; (_fun _pointer _pointer _int32 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int32 -> _void)))
(define _msg-40  ; (_fun _pointer _pointer _int64 -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _NSRange)))
(define _msg-41  ; (_fun _pointer _pointer _int64 -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _bool)))
(define _msg-42  ; (_fun _pointer _pointer _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _id)))
(define _msg-43  ; (_fun _pointer _pointer _int64 -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _int64)))
(define _msg-44  ; (_fun _pointer _pointer _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _void)))
(define _msg-45  ; (_fun _pointer _pointer _int64 _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _int64 -> _id)))
(define _msg-46  ; (_fun _pointer _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _bool)))
(define _msg-47  ; (_fun _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _void)))
(define _msg-48  ; (_fun _pointer _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _bool)))
(define _msg-49  ; (_fun _pointer _pointer _pointer _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _id)))
(define _msg-50  ; (_fun _pointer _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _pointer -> _void)))
(define _msg-51  ; (_fun _pointer _pointer _uint64 -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _int64)))
(define _msg-52  ; (_fun _pointer _pointer _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _void)))

;; --- Constructors ---
(define (make-nscontrol-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSControl alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nscontrol-init-with-frame frame-rect)
  (wrap-objc-object
   (_msg-23 (tell NSControl alloc)
       (sel_registerName "initWithFrame:")
       frame-rect)
   #:retained #t))


;; --- Properties ---
(define (nscontrol-accepts-first-responder self)
  (tell #:type _bool (coerce-arg self) acceptsFirstResponder))
(define (nscontrol-accepts-touch-events self)
  (tell #:type _bool (coerce-arg self) acceptsTouchEvents))
(define (nscontrol-set-accepts-touch-events! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setAcceptsTouchEvents:") value))
(define (nscontrol-action self)
  (tell #:type _pointer (coerce-arg self) action))
(define (nscontrol-set-action! self value)
  (_msg-47 (coerce-arg self) (sel_registerName "setAction:") (sel_registerName value)))
(define (nscontrol-additional-safe-area-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) additionalSafeAreaInsets))
(define (nscontrol-set-additional-safe-area-insets! self value)
  (_msg-10 (coerce-arg self) (sel_registerName "setAdditionalSafeAreaInsets:") value))
(define (nscontrol-alignment self)
  (tell #:type _int64 (coerce-arg self) alignment))
(define (nscontrol-set-alignment! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setAlignment:") value))
(define (nscontrol-alignment-rect-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) alignmentRectInsets))
(define (nscontrol-allowed-touch-types self)
  (tell #:type _uint64 (coerce-arg self) allowedTouchTypes))
(define (nscontrol-set-allowed-touch-types! self value)
  (_msg-52 (coerce-arg self) (sel_registerName "setAllowedTouchTypes:") value))
(define (nscontrol-allows-expansion-tool-tips self)
  (tell #:type _bool (coerce-arg self) allowsExpansionToolTips))
(define (nscontrol-set-allows-expansion-tool-tips! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setAllowsExpansionToolTips:") value))
(define (nscontrol-allows-vibrancy self)
  (tell #:type _bool (coerce-arg self) allowsVibrancy))
(define (nscontrol-alpha-value self)
  (tell #:type _double (coerce-arg self) alphaValue))
(define (nscontrol-set-alpha-value! self value)
  (_msg-34 (coerce-arg self) (sel_registerName "setAlphaValue:") value))
(define (nscontrol-attributed-string-value self)
  (wrap-objc-object
   (tell (coerce-arg self) attributedStringValue)))
(define (nscontrol-set-attributed-string-value! self value)
  (tell #:type _void (coerce-arg self) setAttributedStringValue: (coerce-arg value)))
(define (nscontrol-autoresizes-subviews self)
  (tell #:type _bool (coerce-arg self) autoresizesSubviews))
(define (nscontrol-set-autoresizes-subviews! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setAutoresizesSubviews:") value))
(define (nscontrol-autoresizing-mask self)
  (tell #:type _uint64 (coerce-arg self) autoresizingMask))
(define (nscontrol-set-autoresizing-mask! self value)
  (_msg-52 (coerce-arg self) (sel_registerName "setAutoresizingMask:") value))
(define (nscontrol-background-filters self)
  (wrap-objc-object
   (tell (coerce-arg self) backgroundFilters)))
(define (nscontrol-set-background-filters! self value)
  (tell #:type _void (coerce-arg self) setBackgroundFilters: (coerce-arg value)))
(define (nscontrol-base-writing-direction self)
  (tell #:type _int64 (coerce-arg self) baseWritingDirection))
(define (nscontrol-set-base-writing-direction! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setBaseWritingDirection:") value))
(define (nscontrol-baseline-offset-from-bottom self)
  (tell #:type _double (coerce-arg self) baselineOffsetFromBottom))
(define (nscontrol-bottom-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) bottomAnchor)))
(define (nscontrol-bounds self)
  (tell #:type _NSRect (coerce-arg self) bounds))
(define (nscontrol-set-bounds! self value)
  (_msg-24 (coerce-arg self) (sel_registerName "setBounds:") value))
(define (nscontrol-bounds-rotation self)
  (tell #:type _double (coerce-arg self) boundsRotation))
(define (nscontrol-set-bounds-rotation! self value)
  (_msg-34 (coerce-arg self) (sel_registerName "setBoundsRotation:") value))
(define (nscontrol-can-become-key-view self)
  (tell #:type _bool (coerce-arg self) canBecomeKeyView))
(define (nscontrol-can-draw self)
  (tell #:type _bool (coerce-arg self) canDraw))
(define (nscontrol-can-draw-concurrently self)
  (tell #:type _bool (coerce-arg self) canDrawConcurrently))
(define (nscontrol-set-can-draw-concurrently! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setCanDrawConcurrently:") value))
(define (nscontrol-can-draw-subviews-into-layer self)
  (tell #:type _bool (coerce-arg self) canDrawSubviewsIntoLayer))
(define (nscontrol-set-can-draw-subviews-into-layer! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setCanDrawSubviewsIntoLayer:") value))
(define (nscontrol-candidate-list-touch-bar-item self)
  (wrap-objc-object
   (tell (coerce-arg self) candidateListTouchBarItem)))
(define (nscontrol-cell self)
  (wrap-objc-object
   (tell (coerce-arg self) cell)))
(define (nscontrol-set-cell! self value)
  (tell #:type _void (coerce-arg self) setCell: (coerce-arg value)))
(define (nscontrol-cell-class)
  (tell #:type _pointer NSControl cellClass))
(define (nscontrol-set-cell-class! value)
  (_msg-47 NSControl (sel_registerName "setCellClass:") value))
(define (nscontrol-center-x-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) centerXAnchor)))
(define (nscontrol-center-y-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) centerYAnchor)))
(define (nscontrol-clips-to-bounds self)
  (tell #:type _bool (coerce-arg self) clipsToBounds))
(define (nscontrol-set-clips-to-bounds! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setClipsToBounds:") value))
(define (nscontrol-compatible-with-responsive-scrolling)
  (tell #:type _bool NSControl compatibleWithResponsiveScrolling))
(define (nscontrol-compositing-filter self)
  (wrap-objc-object
   (tell (coerce-arg self) compositingFilter)))
(define (nscontrol-set-compositing-filter! self value)
  (tell #:type _void (coerce-arg self) setCompositingFilter: (coerce-arg value)))
(define (nscontrol-constraints self)
  (wrap-objc-object
   (tell (coerce-arg self) constraints)))
(define (nscontrol-content-filters self)
  (wrap-objc-object
   (tell (coerce-arg self) contentFilters)))
(define (nscontrol-set-content-filters! self value)
  (tell #:type _void (coerce-arg self) setContentFilters: (coerce-arg value)))
(define (nscontrol-continuous self)
  (tell #:type _bool (coerce-arg self) continuous))
(define (nscontrol-set-continuous! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setContinuous:") value))
(define (nscontrol-control-size self)
  (tell #:type _uint64 (coerce-arg self) controlSize))
(define (nscontrol-set-control-size! self value)
  (_msg-52 (coerce-arg self) (sel_registerName "setControlSize:") value))
(define (nscontrol-default-focus-ring-type)
  (tell #:type _uint64 NSControl defaultFocusRingType))
(define (nscontrol-default-menu)
  (wrap-objc-object
   (tell NSControl defaultMenu)))
(define (nscontrol-double-value self)
  (tell #:type _double (coerce-arg self) doubleValue))
(define (nscontrol-set-double-value! self value)
  (_msg-34 (coerce-arg self) (sel_registerName "setDoubleValue:") value))
(define (nscontrol-drawing-find-indicator self)
  (tell #:type _bool (coerce-arg self) drawingFindIndicator))
(define (nscontrol-enabled self)
  (tell #:type _bool (coerce-arg self) enabled))
(define (nscontrol-set-enabled! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setEnabled:") value))
(define (nscontrol-enclosing-menu-item self)
  (wrap-objc-object
   (tell (coerce-arg self) enclosingMenuItem)))
(define (nscontrol-enclosing-scroll-view self)
  (wrap-objc-object
   (tell (coerce-arg self) enclosingScrollView)))
(define (nscontrol-first-baseline-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) firstBaselineAnchor)))
(define (nscontrol-first-baseline-offset-from-top self)
  (tell #:type _double (coerce-arg self) firstBaselineOffsetFromTop))
(define (nscontrol-fitting-size self)
  (tell #:type _NSSize (coerce-arg self) fittingSize))
(define (nscontrol-flipped self)
  (tell #:type _bool (coerce-arg self) flipped))
(define (nscontrol-float-value self)
  (tell #:type _float (coerce-arg self) floatValue))
(define (nscontrol-set-float-value! self value)
  (_msg-35 (coerce-arg self) (sel_registerName "setFloatValue:") value))
(define (nscontrol-focus-ring-mask-bounds self)
  (tell #:type _NSRect (coerce-arg self) focusRingMaskBounds))
(define (nscontrol-focus-ring-type self)
  (tell #:type _uint64 (coerce-arg self) focusRingType))
(define (nscontrol-set-focus-ring-type! self value)
  (_msg-52 (coerce-arg self) (sel_registerName "setFocusRingType:") value))
(define (nscontrol-focus-view)
  (wrap-objc-object
   (tell NSControl focusView)))
(define (nscontrol-font self)
  (wrap-objc-object
   (tell (coerce-arg self) font)))
(define (nscontrol-set-font! self value)
  (tell #:type _void (coerce-arg self) setFont: (coerce-arg value)))
(define (nscontrol-formatter self)
  (wrap-objc-object
   (tell (coerce-arg self) formatter)))
(define (nscontrol-set-formatter! self value)
  (tell #:type _void (coerce-arg self) setFormatter: (coerce-arg value)))
(define (nscontrol-frame self)
  (tell #:type _NSRect (coerce-arg self) frame))
(define (nscontrol-set-frame! self value)
  (_msg-24 (coerce-arg self) (sel_registerName "setFrame:") value))
(define (nscontrol-frame-center-rotation self)
  (tell #:type _double (coerce-arg self) frameCenterRotation))
(define (nscontrol-set-frame-center-rotation! self value)
  (_msg-34 (coerce-arg self) (sel_registerName "setFrameCenterRotation:") value))
(define (nscontrol-frame-rotation self)
  (tell #:type _double (coerce-arg self) frameRotation))
(define (nscontrol-set-frame-rotation! self value)
  (_msg-34 (coerce-arg self) (sel_registerName "setFrameRotation:") value))
(define (nscontrol-gesture-recognizers self)
  (wrap-objc-object
   (tell (coerce-arg self) gestureRecognizers)))
(define (nscontrol-set-gesture-recognizers! self value)
  (tell #:type _void (coerce-arg self) setGestureRecognizers: (coerce-arg value)))
(define (nscontrol-has-ambiguous-layout self)
  (tell #:type _bool (coerce-arg self) hasAmbiguousLayout))
(define (nscontrol-height-adjust-limit self)
  (tell #:type _double (coerce-arg self) heightAdjustLimit))
(define (nscontrol-height-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) heightAnchor)))
(define (nscontrol-hidden self)
  (tell #:type _bool (coerce-arg self) hidden))
(define (nscontrol-set-hidden! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setHidden:") value))
(define (nscontrol-hidden-or-has-hidden-ancestor self)
  (tell #:type _bool (coerce-arg self) hiddenOrHasHiddenAncestor))
(define (nscontrol-highlighted self)
  (tell #:type _bool (coerce-arg self) highlighted))
(define (nscontrol-set-highlighted! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setHighlighted:") value))
(define (nscontrol-horizontal-content-size-constraint-active self)
  (tell #:type _bool (coerce-arg self) horizontalContentSizeConstraintActive))
(define (nscontrol-set-horizontal-content-size-constraint-active! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setHorizontalContentSizeConstraintActive:") value))
(define (nscontrol-ignores-multi-click self)
  (tell #:type _bool (coerce-arg self) ignoresMultiClick))
(define (nscontrol-set-ignores-multi-click! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setIgnoresMultiClick:") value))
(define (nscontrol-in-full-screen-mode self)
  (tell #:type _bool (coerce-arg self) inFullScreenMode))
(define (nscontrol-in-live-resize self)
  (tell #:type _bool (coerce-arg self) inLiveResize))
(define (nscontrol-input-context self)
  (wrap-objc-object
   (tell (coerce-arg self) inputContext)))
(define (nscontrol-int-value self)
  (tell #:type _int32 (coerce-arg self) intValue))
(define (nscontrol-set-int-value! self value)
  (_msg-39 (coerce-arg self) (sel_registerName "setIntValue:") value))
(define (nscontrol-integer-value self)
  (tell #:type _int64 (coerce-arg self) integerValue))
(define (nscontrol-set-integer-value! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setIntegerValue:") value))
(define (nscontrol-intrinsic-content-size self)
  (tell #:type _NSSize (coerce-arg self) intrinsicContentSize))
(define (nscontrol-last-baseline-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) lastBaselineAnchor)))
(define (nscontrol-last-baseline-offset-from-bottom self)
  (tell #:type _double (coerce-arg self) lastBaselineOffsetFromBottom))
(define (nscontrol-layer self)
  (wrap-objc-object
   (tell (coerce-arg self) layer)))
(define (nscontrol-set-layer! self value)
  (tell #:type _void (coerce-arg self) setLayer: (coerce-arg value)))
(define (nscontrol-layer-contents-placement self)
  (tell #:type _int64 (coerce-arg self) layerContentsPlacement))
(define (nscontrol-set-layer-contents-placement! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setLayerContentsPlacement:") value))
(define (nscontrol-layer-contents-redraw-policy self)
  (tell #:type _int64 (coerce-arg self) layerContentsRedrawPolicy))
(define (nscontrol-set-layer-contents-redraw-policy! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setLayerContentsRedrawPolicy:") value))
(define (nscontrol-layer-uses-core-image-filters self)
  (tell #:type _bool (coerce-arg self) layerUsesCoreImageFilters))
(define (nscontrol-set-layer-uses-core-image-filters! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setLayerUsesCoreImageFilters:") value))
(define (nscontrol-layout-guides self)
  (wrap-objc-object
   (tell (coerce-arg self) layoutGuides)))
(define (nscontrol-layout-margins-guide self)
  (wrap-objc-object
   (tell (coerce-arg self) layoutMarginsGuide)))
(define (nscontrol-leading-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) leadingAnchor)))
(define (nscontrol-left-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) leftAnchor)))
(define (nscontrol-line-break-mode self)
  (tell #:type _uint64 (coerce-arg self) lineBreakMode))
(define (nscontrol-set-line-break-mode! self value)
  (_msg-52 (coerce-arg self) (sel_registerName "setLineBreakMode:") value))
(define (nscontrol-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) menu)))
(define (nscontrol-set-menu! self value)
  (tell #:type _void (coerce-arg self) setMenu: (coerce-arg value)))
(define (nscontrol-mouse-down-can-move-window self)
  (tell #:type _bool (coerce-arg self) mouseDownCanMoveWindow))
(define (nscontrol-needs-display self)
  (tell #:type _bool (coerce-arg self) needsDisplay))
(define (nscontrol-set-needs-display! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setNeedsDisplay:") value))
(define (nscontrol-needs-layout self)
  (tell #:type _bool (coerce-arg self) needsLayout))
(define (nscontrol-set-needs-layout! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setNeedsLayout:") value))
(define (nscontrol-needs-panel-to-become-key self)
  (tell #:type _bool (coerce-arg self) needsPanelToBecomeKey))
(define (nscontrol-needs-update-constraints self)
  (tell #:type _bool (coerce-arg self) needsUpdateConstraints))
(define (nscontrol-set-needs-update-constraints! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setNeedsUpdateConstraints:") value))
(define (nscontrol-next-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) nextKeyView)))
(define (nscontrol-set-next-key-view! self value)
  (tell #:type _void (coerce-arg self) setNextKeyView: (coerce-arg value)))
(define (nscontrol-next-responder self)
  (wrap-objc-object
   (tell (coerce-arg self) nextResponder)))
(define (nscontrol-set-next-responder! self value)
  (tell #:type _void (coerce-arg self) setNextResponder: (coerce-arg value)))
(define (nscontrol-next-valid-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) nextValidKeyView)))
(define (nscontrol-object-value self)
  (wrap-objc-object
   (tell (coerce-arg self) objectValue)))
(define (nscontrol-set-object-value! self value)
  (tell #:type _void (coerce-arg self) setObjectValue: (coerce-arg value)))
(define (nscontrol-opaque self)
  (tell #:type _bool (coerce-arg self) opaque))
(define (nscontrol-opaque-ancestor self)
  (wrap-objc-object
   (tell (coerce-arg self) opaqueAncestor)))
(define (nscontrol-page-footer self)
  (wrap-objc-object
   (tell (coerce-arg self) pageFooter)))
(define (nscontrol-page-header self)
  (wrap-objc-object
   (tell (coerce-arg self) pageHeader)))
(define (nscontrol-posts-bounds-changed-notifications self)
  (tell #:type _bool (coerce-arg self) postsBoundsChangedNotifications))
(define (nscontrol-set-posts-bounds-changed-notifications! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setPostsBoundsChangedNotifications:") value))
(define (nscontrol-posts-frame-changed-notifications self)
  (tell #:type _bool (coerce-arg self) postsFrameChangedNotifications))
(define (nscontrol-set-posts-frame-changed-notifications! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setPostsFrameChangedNotifications:") value))
(define (nscontrol-prefers-compact-control-size-metrics self)
  (tell #:type _bool (coerce-arg self) prefersCompactControlSizeMetrics))
(define (nscontrol-set-prefers-compact-control-size-metrics! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setPrefersCompactControlSizeMetrics:") value))
(define (nscontrol-prepared-content-rect self)
  (tell #:type _NSRect (coerce-arg self) preparedContentRect))
(define (nscontrol-set-prepared-content-rect! self value)
  (_msg-24 (coerce-arg self) (sel_registerName "setPreparedContentRect:") value))
(define (nscontrol-preserves-content-during-live-resize self)
  (tell #:type _bool (coerce-arg self) preservesContentDuringLiveResize))
(define (nscontrol-pressure-configuration self)
  (wrap-objc-object
   (tell (coerce-arg self) pressureConfiguration)))
(define (nscontrol-set-pressure-configuration! self value)
  (tell #:type _void (coerce-arg self) setPressureConfiguration: (coerce-arg value)))
(define (nscontrol-previous-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) previousKeyView)))
(define (nscontrol-previous-valid-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) previousValidKeyView)))
(define (nscontrol-print-job-title self)
  (wrap-objc-object
   (tell (coerce-arg self) printJobTitle)))
(define (nscontrol-rect-preserved-during-live-resize self)
  (tell #:type _NSRect (coerce-arg self) rectPreservedDuringLiveResize))
(define (nscontrol-refuses-first-responder self)
  (tell #:type _bool (coerce-arg self) refusesFirstResponder))
(define (nscontrol-set-refuses-first-responder! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setRefusesFirstResponder:") value))
(define (nscontrol-registered-dragged-types self)
  (wrap-objc-object
   (tell (coerce-arg self) registeredDraggedTypes)))
(define (nscontrol-requires-constraint-based-layout)
  (tell #:type _bool NSControl requiresConstraintBasedLayout))
(define (nscontrol-restorable-state-key-paths)
  (wrap-objc-object
   (tell NSControl restorableStateKeyPaths)))
(define (nscontrol-right-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) rightAnchor)))
(define (nscontrol-rotated-from-base self)
  (tell #:type _bool (coerce-arg self) rotatedFromBase))
(define (nscontrol-rotated-or-scaled-from-base self)
  (tell #:type _bool (coerce-arg self) rotatedOrScaledFromBase))
(define (nscontrol-safe-area-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) safeAreaInsets))
(define (nscontrol-safe-area-layout-guide self)
  (wrap-objc-object
   (tell (coerce-arg self) safeAreaLayoutGuide)))
(define (nscontrol-safe-area-rect self)
  (tell #:type _NSRect (coerce-arg self) safeAreaRect))
(define (nscontrol-shadow self)
  (wrap-objc-object
   (tell (coerce-arg self) shadow)))
(define (nscontrol-set-shadow! self value)
  (tell #:type _void (coerce-arg self) setShadow: (coerce-arg value)))
(define (nscontrol-string-value self)
  (wrap-objc-object
   (tell (coerce-arg self) stringValue)))
(define (nscontrol-set-string-value! self value)
  (tell #:type _void (coerce-arg self) setStringValue: (coerce-arg value)))
(define (nscontrol-subviews self)
  (wrap-objc-object
   (tell (coerce-arg self) subviews)))
(define (nscontrol-set-subviews! self value)
  (tell #:type _void (coerce-arg self) setSubviews: (coerce-arg value)))
(define (nscontrol-superview self)
  (wrap-objc-object
   (tell (coerce-arg self) superview)))
(define (nscontrol-tag self)
  (tell #:type _int64 (coerce-arg self) tag))
(define (nscontrol-set-tag! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setTag:") value))
(define (nscontrol-target self)
  (wrap-objc-object
   (tell (coerce-arg self) target)))
(define (nscontrol-set-target! self value)
  (tell #:type _void (coerce-arg self) setTarget: (coerce-arg value)))
(define (nscontrol-tool-tip self)
  (wrap-objc-object
   (tell (coerce-arg self) toolTip)))
(define (nscontrol-set-tool-tip! self value)
  (tell #:type _void (coerce-arg self) setToolTip: (coerce-arg value)))
(define (nscontrol-top-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) topAnchor)))
(define (nscontrol-touch-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) touchBar)))
(define (nscontrol-set-touch-bar! self value)
  (tell #:type _void (coerce-arg self) setTouchBar: (coerce-arg value)))
(define (nscontrol-tracking-areas self)
  (wrap-objc-object
   (tell (coerce-arg self) trackingAreas)))
(define (nscontrol-trailing-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) trailingAnchor)))
(define (nscontrol-translates-autoresizing-mask-into-constraints self)
  (tell #:type _bool (coerce-arg self) translatesAutoresizingMaskIntoConstraints))
(define (nscontrol-set-translates-autoresizing-mask-into-constraints! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setTranslatesAutoresizingMaskIntoConstraints:") value))
(define (nscontrol-undo-manager self)
  (wrap-objc-object
   (tell (coerce-arg self) undoManager)))
(define (nscontrol-user-activity self)
  (wrap-objc-object
   (tell (coerce-arg self) userActivity)))
(define (nscontrol-set-user-activity! self value)
  (tell #:type _void (coerce-arg self) setUserActivity: (coerce-arg value)))
(define (nscontrol-user-interface-layout-direction self)
  (tell #:type _int64 (coerce-arg self) userInterfaceLayoutDirection))
(define (nscontrol-set-user-interface-layout-direction! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setUserInterfaceLayoutDirection:") value))
(define (nscontrol-uses-single-line-mode self)
  (tell #:type _bool (coerce-arg self) usesSingleLineMode))
(define (nscontrol-set-uses-single-line-mode! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setUsesSingleLineMode:") value))
(define (nscontrol-vertical-content-size-constraint-active self)
  (tell #:type _bool (coerce-arg self) verticalContentSizeConstraintActive))
(define (nscontrol-set-vertical-content-size-constraint-active! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setVerticalContentSizeConstraintActive:") value))
(define (nscontrol-visible-rect self)
  (tell #:type _NSRect (coerce-arg self) visibleRect))
(define (nscontrol-wants-best-resolution-open-gl-surface self)
  (tell #:type _bool (coerce-arg self) wantsBestResolutionOpenGLSurface))
(define (nscontrol-set-wants-best-resolution-open-gl-surface! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setWantsBestResolutionOpenGLSurface:") value))
(define (nscontrol-wants-default-clipping self)
  (tell #:type _bool (coerce-arg self) wantsDefaultClipping))
(define (nscontrol-wants-extended-dynamic-range-open-gl-surface self)
  (tell #:type _bool (coerce-arg self) wantsExtendedDynamicRangeOpenGLSurface))
(define (nscontrol-set-wants-extended-dynamic-range-open-gl-surface! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setWantsExtendedDynamicRangeOpenGLSurface:") value))
(define (nscontrol-wants-layer self)
  (tell #:type _bool (coerce-arg self) wantsLayer))
(define (nscontrol-set-wants-layer! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setWantsLayer:") value))
(define (nscontrol-wants-resting-touches self)
  (tell #:type _bool (coerce-arg self) wantsRestingTouches))
(define (nscontrol-set-wants-resting-touches! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setWantsRestingTouches:") value))
(define (nscontrol-wants-update-layer self)
  (tell #:type _bool (coerce-arg self) wantsUpdateLayer))
(define (nscontrol-width-adjust-limit self)
  (tell #:type _double (coerce-arg self) widthAdjustLimit))
(define (nscontrol-width-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) widthAnchor)))
(define (nscontrol-window self)
  (wrap-objc-object
   (tell (coerce-arg self) window)))
(define (nscontrol-writing-tools-coordinator self)
  (wrap-objc-object
   (tell (coerce-arg self) writingToolsCoordinator)))
(define (nscontrol-set-writing-tools-coordinator! self value)
  (tell #:type _void (coerce-arg self) setWritingToolsCoordinator: (coerce-arg value)))

;; --- Instance methods ---
(define (nscontrol-accepts-first-mouse self event)
  (_msg-36 (coerce-arg self) (sel_registerName "acceptsFirstMouse:") (coerce-arg event)))
(define (nscontrol-accessibility-activation-point self)
  (_msg-0 (coerce-arg self) (sel_registerName "accessibilityActivationPoint")))
(define (nscontrol-accessibility-allowed-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAllowedValues)))
(define (nscontrol-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityApplicationFocusedUIElement)))
(define (nscontrol-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (_msg-19 (coerce-arg self) (sel_registerName "accessibilityAttributedStringForRange:") range)
   ))
(define (nscontrol-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAttributedUserInputLabels)))
(define (nscontrol-accessibility-cancel-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCancelButton)))
(define (nscontrol-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (_msg-45 (coerce-arg self) (sel_registerName "accessibilityCellForColumn:row:") column row)
   ))
(define (nscontrol-accessibility-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildren)))
(define (nscontrol-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildrenInNavigationOrder)))
(define (nscontrol-accessibility-clear-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityClearButton)))
(define (nscontrol-accessibility-close-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCloseButton)))
(define (nscontrol-accessibility-column-count self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityColumnCount")))
(define (nscontrol-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnHeaderUIElements)))
(define (nscontrol-accessibility-column-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityColumnIndexRange")))
(define (nscontrol-accessibility-column-titles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnTitles)))
(define (nscontrol-accessibility-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumns)))
(define (nscontrol-accessibility-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityContents)))
(define (nscontrol-accessibility-critical-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCriticalValue)))
(define (nscontrol-accessibility-custom-actions self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomActions)))
(define (nscontrol-accessibility-custom-rotors self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomRotors)))
(define (nscontrol-accessibility-decrement-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDecrementButton)))
(define (nscontrol-accessibility-default-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDefaultButton)))
(define (nscontrol-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedByRow)))
(define (nscontrol-accessibility-disclosed-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedRows)))
(define (nscontrol-accessibility-disclosure-level self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityDisclosureLevel")))
(define (nscontrol-accessibility-document self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDocument)))
(define (nscontrol-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityExtrasMenuBar)))
(define (nscontrol-accessibility-filename self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFilename)))
(define (nscontrol-accessibility-focused-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFocusedWindow)))
(define (nscontrol-accessibility-frame self)
  (_msg-2 (coerce-arg self) (sel_registerName "accessibilityFrame")))
(define (nscontrol-accessibility-frame-for-range self range)
  (_msg-18 (coerce-arg self) (sel_registerName "accessibilityFrameForRange:") range))
(define (nscontrol-accessibility-full-screen-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFullScreenButton)))
(define (nscontrol-accessibility-grow-area self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityGrowArea)))
(define (nscontrol-accessibility-handles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHandles)))
(define (nscontrol-accessibility-header self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHeader)))
(define (nscontrol-accessibility-help self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHelp)))
(define (nscontrol-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalScrollBar)))
(define (nscontrol-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalUnitDescription)))
(define (nscontrol-accessibility-horizontal-units self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityHorizontalUnits")))
(define (nscontrol-accessibility-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIdentifier)))
(define (nscontrol-accessibility-increment-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIncrementButton)))
(define (nscontrol-accessibility-index self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityIndex")))
(define (nscontrol-accessibility-insertion-point-line-number self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityInsertionPointLineNumber")))
(define (nscontrol-accessibility-label self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabel)))
(define (nscontrol-accessibility-label-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabelUIElements)))
(define (nscontrol-accessibility-label-value self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityLabelValue")))
(define (nscontrol-accessibility-layout-point-for-screen-point self point)
  (_msg-11 (coerce-arg self) (sel_registerName "accessibilityLayoutPointForScreenPoint:") point))
(define (nscontrol-accessibility-layout-size-for-screen-size self size)
  (_msg-30 (coerce-arg self) (sel_registerName "accessibilityLayoutSizeForScreenSize:") size))
(define (nscontrol-accessibility-line-for-index self index)
  (_msg-43 (coerce-arg self) (sel_registerName "accessibilityLineForIndex:") index))
(define (nscontrol-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLinkedUIElements)))
(define (nscontrol-accessibility-main-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMainWindow)))
(define (nscontrol-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerGroupUIElement)))
(define (nscontrol-accessibility-marker-type-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerTypeDescription)))
(define (nscontrol-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerUIElements)))
(define (nscontrol-accessibility-marker-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerValues)))
(define (nscontrol-accessibility-max-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMaxValue)))
(define (nscontrol-accessibility-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMenuBar)))
(define (nscontrol-accessibility-min-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinValue)))
(define (nscontrol-accessibility-minimize-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinimizeButton)))
(define (nscontrol-accessibility-next-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityNextContents)))
(define (nscontrol-accessibility-number-of-characters self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityNumberOfCharacters")))
(define (nscontrol-accessibility-orientation self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityOrientation")))
(define (nscontrol-accessibility-overflow-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityOverflowButton)))
(define (nscontrol-accessibility-parent self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityParent)))
(define (nscontrol-accessibility-perform-cancel self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformCancel")))
(define (nscontrol-accessibility-perform-confirm self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformConfirm")))
(define (nscontrol-accessibility-perform-decrement self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformDecrement")))
(define (nscontrol-accessibility-perform-delete self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformDelete")))
(define (nscontrol-accessibility-perform-increment self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformIncrement")))
(define (nscontrol-accessibility-perform-pick self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformPick")))
(define (nscontrol-accessibility-perform-press self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformPress")))
(define (nscontrol-accessibility-perform-raise self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformRaise")))
(define (nscontrol-accessibility-perform-show-alternate-ui self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowAlternateUI")))
(define (nscontrol-accessibility-perform-show-default-ui self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowDefaultUI")))
(define (nscontrol-accessibility-perform-show-menu self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowMenu")))
(define (nscontrol-accessibility-placeholder-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPlaceholderValue)))
(define (nscontrol-accessibility-previous-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPreviousContents)))
(define (nscontrol-accessibility-proxy self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityProxy)))
(define (nscontrol-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (_msg-19 (coerce-arg self) (sel_registerName "accessibilityRTFForRange:") range)
   ))
(define (nscontrol-accessibility-range-for-index self index)
  (_msg-40 (coerce-arg self) (sel_registerName "accessibilityRangeForIndex:") index))
(define (nscontrol-accessibility-range-for-line self line)
  (_msg-40 (coerce-arg self) (sel_registerName "accessibilityRangeForLine:") line))
(define (nscontrol-accessibility-range-for-position self point)
  (_msg-12 (coerce-arg self) (sel_registerName "accessibilityRangeForPosition:") point))
(define (nscontrol-accessibility-role self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRole)))
(define (nscontrol-accessibility-role-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRoleDescription)))
(define (nscontrol-accessibility-row-count self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityRowCount")))
(define (nscontrol-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRowHeaderUIElements)))
(define (nscontrol-accessibility-row-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityRowIndexRange")))
(define (nscontrol-accessibility-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRows)))
(define (nscontrol-accessibility-ruler-marker-type self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityRulerMarkerType")))
(define (nscontrol-accessibility-screen-point-for-layout-point self point)
  (_msg-11 (coerce-arg self) (sel_registerName "accessibilityScreenPointForLayoutPoint:") point))
(define (nscontrol-accessibility-screen-size-for-layout-size self size)
  (_msg-30 (coerce-arg self) (sel_registerName "accessibilityScreenSizeForLayoutSize:") size))
(define (nscontrol-accessibility-search-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchButton)))
(define (nscontrol-accessibility-search-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchMenu)))
(define (nscontrol-accessibility-selected-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedCells)))
(define (nscontrol-accessibility-selected-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedChildren)))
(define (nscontrol-accessibility-selected-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedColumns)))
(define (nscontrol-accessibility-selected-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedRows)))
(define (nscontrol-accessibility-selected-text self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedText)))
(define (nscontrol-accessibility-selected-text-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySelectedTextRange")))
(define (nscontrol-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedTextRanges)))
(define (nscontrol-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityServesAsTitleForUIElements)))
(define (nscontrol-accessibility-shared-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySharedCharacterRange")))
(define (nscontrol-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedFocusElements)))
(define (nscontrol-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedTextUIElements)))
(define (nscontrol-accessibility-shown-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityShownMenu)))
(define (nscontrol-accessibility-sort-direction self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilitySortDirection")))
(define (nscontrol-accessibility-splitters self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySplitters)))
(define (nscontrol-accessibility-string-for-range self range)
  (wrap-objc-object
   (_msg-19 (coerce-arg self) (sel_registerName "accessibilityStringForRange:") range)
   ))
(define (nscontrol-accessibility-style-range-for-index self index)
  (_msg-40 (coerce-arg self) (sel_registerName "accessibilityStyleRangeForIndex:") index))
(define (nscontrol-accessibility-subrole self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySubrole)))
(define (nscontrol-accessibility-tabs self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTabs)))
(define (nscontrol-accessibility-title self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitle)))
(define (nscontrol-accessibility-title-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitleUIElement)))
(define (nscontrol-accessibility-toolbar-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityToolbarButton)))
(define (nscontrol-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTopLevelUIElement)))
(define (nscontrol-accessibility-url self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityURL)))
(define (nscontrol-accessibility-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUnitDescription)))
(define (nscontrol-accessibility-units self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityUnits")))
(define (nscontrol-accessibility-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUserInputLabels)))
(define (nscontrol-accessibility-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValue)))
(define (nscontrol-accessibility-value-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValueDescription)))
(define (nscontrol-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalScrollBar)))
(define (nscontrol-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalUnitDescription)))
(define (nscontrol-accessibility-vertical-units self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityVerticalUnits")))
(define (nscontrol-accessibility-visible-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleCells)))
(define (nscontrol-accessibility-visible-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityVisibleCharacterRange")))
(define (nscontrol-accessibility-visible-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleChildren)))
(define (nscontrol-accessibility-visible-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleColumns)))
(define (nscontrol-accessibility-visible-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleRows)))
(define (nscontrol-accessibility-warning-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWarningValue)))
(define (nscontrol-accessibility-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindow)))
(define (nscontrol-accessibility-windows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindows)))
(define (nscontrol-accessibility-zoom-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityZoomButton)))
(define (nscontrol-add-subview! self view)
  (tell #:type _void (coerce-arg self) addSubview: (coerce-arg view)))
(define (nscontrol-add-subview-positioned-relative-to! self view place other-view)
  (_msg-38 (coerce-arg self) (sel_registerName "addSubview:positioned:relativeTo:") (coerce-arg view) place (coerce-arg other-view)))
(define (nscontrol-add-tool-tip-rect-owner-user-data! self rect owner data)
  (_msg-28 (coerce-arg self) (sel_registerName "addToolTipRect:owner:userData:") rect (coerce-arg owner) data))
(define (nscontrol-adjust-scroll self new-visible)
  (_msg-21 (coerce-arg self) (sel_registerName "adjustScroll:") new-visible))
(define (nscontrol-ancestor-shared-with-view self view)
  (wrap-objc-object
   (tell (coerce-arg self) ancestorSharedWithView: (coerce-arg view))))
(define (nscontrol-animation-for-key self key)
  (wrap-objc-object
   (tell (coerce-arg self) animationForKey: (coerce-arg key))))
(define (nscontrol-animations self)
  (wrap-objc-object
   (tell (coerce-arg self) animations)))
(define (nscontrol-animator self)
  (wrap-objc-object
   (tell (coerce-arg self) animator)))
(define (nscontrol-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) appearance)))
(define (nscontrol-autoscroll self event)
  (_msg-36 (coerce-arg self) (sel_registerName "autoscroll:") (coerce-arg event)))
(define (nscontrol-backing-aligned-rect-options self rect options)
  (_msg-29 (coerce-arg self) (sel_registerName "backingAlignedRect:options:") rect options))
(define (nscontrol-become-first-responder self)
  (_msg-3 (coerce-arg self) (sel_registerName "becomeFirstResponder")))
(define (nscontrol-begin-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) beginGestureWithEvent: (coerce-arg event)))
(define (nscontrol-bitmap-image-rep-for-caching-display-in-rect self rect)
  (wrap-objc-object
   (_msg-23 (coerce-arg self) (sel_registerName "bitmapImageRepForCachingDisplayInRect:") rect)
   ))
(define (nscontrol-cache-display-in-rect-to-bitmap-image-rep self rect bitmap-image-rep)
  (_msg-27 (coerce-arg self) (sel_registerName "cacheDisplayInRect:toBitmapImageRep:") rect (coerce-arg bitmap-image-rep)))
(define (nscontrol-cancel-operation self sender)
  (tell #:type _void (coerce-arg self) cancelOperation: (coerce-arg sender)))
(define (nscontrol-capitalize-word self sender)
  (tell #:type _void (coerce-arg self) capitalizeWord: (coerce-arg sender)))
(define (nscontrol-center-scan-rect! self rect)
  (_msg-21 (coerce-arg self) (sel_registerName "centerScanRect:") rect))
(define (nscontrol-center-selection-in-visible-area! self sender)
  (tell #:type _void (coerce-arg self) centerSelectionInVisibleArea: (coerce-arg sender)))
(define (nscontrol-change-case-of-letter self sender)
  (tell #:type _void (coerce-arg self) changeCaseOfLetter: (coerce-arg sender)))
(define (nscontrol-change-mode-with-event self event)
  (tell #:type _void (coerce-arg self) changeModeWithEvent: (coerce-arg event)))
(define (nscontrol-complete self sender)
  (tell #:type _void (coerce-arg self) complete: (coerce-arg sender)))
(define (nscontrol-conclude-drag-operation self sender)
  (tell #:type _void (coerce-arg self) concludeDragOperation: (coerce-arg sender)))
(define (nscontrol-context-menu-key-down self event)
  (tell #:type _void (coerce-arg self) contextMenuKeyDown: (coerce-arg event)))
(define (nscontrol-convert-point-from-view self point view)
  (_msg-17 (coerce-arg self) (sel_registerName "convertPoint:fromView:") point (coerce-arg view)))
(define (nscontrol-convert-point-to-view self point view)
  (_msg-17 (coerce-arg self) (sel_registerName "convertPoint:toView:") point (coerce-arg view)))
(define (nscontrol-convert-point-from-backing self point)
  (_msg-11 (coerce-arg self) (sel_registerName "convertPointFromBacking:") point))
(define (nscontrol-convert-point-from-layer self point)
  (_msg-11 (coerce-arg self) (sel_registerName "convertPointFromLayer:") point))
(define (nscontrol-convert-point-to-backing self point)
  (_msg-11 (coerce-arg self) (sel_registerName "convertPointToBacking:") point))
(define (nscontrol-convert-point-to-layer self point)
  (_msg-11 (coerce-arg self) (sel_registerName "convertPointToLayer:") point))
(define (nscontrol-convert-rect-from-view self rect view)
  (_msg-26 (coerce-arg self) (sel_registerName "convertRect:fromView:") rect (coerce-arg view)))
(define (nscontrol-convert-rect-to-view self rect view)
  (_msg-26 (coerce-arg self) (sel_registerName "convertRect:toView:") rect (coerce-arg view)))
(define (nscontrol-convert-rect-from-backing self rect)
  (_msg-21 (coerce-arg self) (sel_registerName "convertRectFromBacking:") rect))
(define (nscontrol-convert-rect-from-layer self rect)
  (_msg-21 (coerce-arg self) (sel_registerName "convertRectFromLayer:") rect))
(define (nscontrol-convert-rect-to-backing self rect)
  (_msg-21 (coerce-arg self) (sel_registerName "convertRectToBacking:") rect))
(define (nscontrol-convert-rect-to-layer self rect)
  (_msg-21 (coerce-arg self) (sel_registerName "convertRectToLayer:") rect))
(define (nscontrol-convert-size-from-view self size view)
  (_msg-32 (coerce-arg self) (sel_registerName "convertSize:fromView:") size (coerce-arg view)))
(define (nscontrol-convert-size-to-view self size view)
  (_msg-32 (coerce-arg self) (sel_registerName "convertSize:toView:") size (coerce-arg view)))
(define (nscontrol-convert-size-from-backing self size)
  (_msg-30 (coerce-arg self) (sel_registerName "convertSizeFromBacking:") size))
(define (nscontrol-convert-size-from-layer self size)
  (_msg-30 (coerce-arg self) (sel_registerName "convertSizeFromLayer:") size))
(define (nscontrol-convert-size-to-backing self size)
  (_msg-30 (coerce-arg self) (sel_registerName "convertSizeToBacking:") size))
(define (nscontrol-convert-size-to-layer self size)
  (_msg-30 (coerce-arg self) (sel_registerName "convertSizeToLayer:") size))
(define (nscontrol-cursor-update self event)
  (tell #:type _void (coerce-arg self) cursorUpdate: (coerce-arg event)))
(define (nscontrol-delete-backward self sender)
  (tell #:type _void (coerce-arg self) deleteBackward: (coerce-arg sender)))
(define (nscontrol-delete-backward-by-decomposing-previous-character self sender)
  (tell #:type _void (coerce-arg self) deleteBackwardByDecomposingPreviousCharacter: (coerce-arg sender)))
(define (nscontrol-delete-forward self sender)
  (tell #:type _void (coerce-arg self) deleteForward: (coerce-arg sender)))
(define (nscontrol-delete-to-beginning-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfLine: (coerce-arg sender)))
(define (nscontrol-delete-to-beginning-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfParagraph: (coerce-arg sender)))
(define (nscontrol-delete-to-end-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfLine: (coerce-arg sender)))
(define (nscontrol-delete-to-end-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfParagraph: (coerce-arg sender)))
(define (nscontrol-delete-to-mark self sender)
  (tell #:type _void (coerce-arg self) deleteToMark: (coerce-arg sender)))
(define (nscontrol-delete-word-backward self sender)
  (tell #:type _void (coerce-arg self) deleteWordBackward: (coerce-arg sender)))
(define (nscontrol-delete-word-forward self sender)
  (tell #:type _void (coerce-arg self) deleteWordForward: (coerce-arg sender)))
(define (nscontrol-did-add-subview self subview)
  (tell #:type _void (coerce-arg self) didAddSubview: (coerce-arg subview)))
(define (nscontrol-did-close-menu-with-event self menu event)
  (tell #:type _void (coerce-arg self) didCloseMenu: (coerce-arg menu) withEvent: (coerce-arg event)))
(define (nscontrol-display! self)
  (tell #:type _void (coerce-arg self) display))
(define (nscontrol-display-if-needed! self)
  (tell #:type _void (coerce-arg self) displayIfNeeded))
(define (nscontrol-display-if-needed-ignoring-opacity! self)
  (tell #:type _void (coerce-arg self) displayIfNeededIgnoringOpacity))
(define (nscontrol-display-if-needed-in-rect! self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "displayIfNeededInRect:") rect))
(define (nscontrol-display-if-needed-in-rect-ignoring-opacity! self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "displayIfNeededInRectIgnoringOpacity:") rect))
(define (nscontrol-display-rect! self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "displayRect:") rect))
(define (nscontrol-display-rect-ignoring-opacity! self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "displayRectIgnoringOpacity:") rect))
(define (nscontrol-display-rect-ignoring-opacity-in-context! self rect context)
  (_msg-27 (coerce-arg self) (sel_registerName "displayRectIgnoringOpacity:inContext:") rect (coerce-arg context)))
(define (nscontrol-do-command-by-selector self selector)
  (_msg-47 (coerce-arg self) (sel_registerName "doCommandBySelector:") (sel_registerName selector)))
(define (nscontrol-dragging-ended self sender)
  (tell #:type _void (coerce-arg self) draggingEnded: (coerce-arg sender)))
(define (nscontrol-dragging-entered self sender)
  (_msg-37 (coerce-arg self) (sel_registerName "draggingEntered:") (coerce-arg sender)))
(define (nscontrol-dragging-exited self sender)
  (tell #:type _void (coerce-arg self) draggingExited: (coerce-arg sender)))
(define (nscontrol-dragging-updated self sender)
  (_msg-37 (coerce-arg self) (sel_registerName "draggingUpdated:") (coerce-arg sender)))
(define (nscontrol-draw-rect self dirty-rect)
  (_msg-24 (coerce-arg self) (sel_registerName "drawRect:") dirty-rect))
(define (nscontrol-draw-with-expansion-frame-in-view self content-frame view)
  (_msg-27 (coerce-arg self) (sel_registerName "drawWithExpansionFrame:inView:") content-frame (coerce-arg view)))
(define (nscontrol-effective-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) effectiveAppearance)))
(define (nscontrol-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nscontrol-end-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) endGestureWithEvent: (coerce-arg event)))
(define (nscontrol-expansion-frame-with-frame self content-frame)
  (_msg-21 (coerce-arg self) (sel_registerName "expansionFrameWithFrame:") content-frame))
(define (nscontrol-flags-changed self event)
  (tell #:type _void (coerce-arg self) flagsChanged: (coerce-arg event)))
(define (nscontrol-flush-buffered-key-events self)
  (tell #:type _void (coerce-arg self) flushBufferedKeyEvents))
(define (nscontrol-get-rects-being-drawn-count self rects count)
  (_msg-50 (coerce-arg self) (sel_registerName "getRectsBeingDrawn:count:") rects count))
(define (nscontrol-get-rects-exposed-during-live-resize-count self exposed-rects count)
  (_msg-50 (coerce-arg self) (sel_registerName "getRectsExposedDuringLiveResize:count:") exposed-rects count))
(define (nscontrol-help-requested self event-ptr)
  (tell #:type _void (coerce-arg self) helpRequested: (coerce-arg event-ptr)))
(define (nscontrol-hit-test self point)
  (wrap-objc-object
   (_msg-13 (coerce-arg self) (sel_registerName "hitTest:") point)
   ))
(define (nscontrol-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) identifier)))
(define (nscontrol-indent self sender)
  (tell #:type _void (coerce-arg self) indent: (coerce-arg sender)))
(define (nscontrol-insert-backtab! self sender)
  (tell #:type _void (coerce-arg self) insertBacktab: (coerce-arg sender)))
(define (nscontrol-insert-container-break! self sender)
  (tell #:type _void (coerce-arg self) insertContainerBreak: (coerce-arg sender)))
(define (nscontrol-insert-double-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertDoubleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nscontrol-insert-line-break! self sender)
  (tell #:type _void (coerce-arg self) insertLineBreak: (coerce-arg sender)))
(define (nscontrol-insert-newline! self sender)
  (tell #:type _void (coerce-arg self) insertNewline: (coerce-arg sender)))
(define (nscontrol-insert-newline-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertNewlineIgnoringFieldEditor: (coerce-arg sender)))
(define (nscontrol-insert-paragraph-separator! self sender)
  (tell #:type _void (coerce-arg self) insertParagraphSeparator: (coerce-arg sender)))
(define (nscontrol-insert-single-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertSingleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nscontrol-insert-tab! self sender)
  (tell #:type _void (coerce-arg self) insertTab: (coerce-arg sender)))
(define (nscontrol-insert-tab-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertTabIgnoringFieldEditor: (coerce-arg sender)))
(define (nscontrol-insert-text! self insert-string)
  (tell #:type _void (coerce-arg self) insertText: (coerce-arg insert-string)))
(define (nscontrol-interpret-key-events self event-array)
  (tell #:type _void (coerce-arg self) interpretKeyEvents: (coerce-arg event-array)))
(define (nscontrol-is-accessibility-alternate-ui-visible self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityAlternateUIVisible")))
(define (nscontrol-is-accessibility-disclosed self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityDisclosed")))
(define (nscontrol-is-accessibility-edited self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityEdited")))
(define (nscontrol-is-accessibility-element self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityElement")))
(define (nscontrol-is-accessibility-enabled self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityEnabled")))
(define (nscontrol-is-accessibility-expanded self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityExpanded")))
(define (nscontrol-is-accessibility-focused self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityFocused")))
(define (nscontrol-is-accessibility-frontmost self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityFrontmost")))
(define (nscontrol-is-accessibility-hidden self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityHidden")))
(define (nscontrol-is-accessibility-main self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityMain")))
(define (nscontrol-is-accessibility-minimized self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityMinimized")))
(define (nscontrol-is-accessibility-modal self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityModal")))
(define (nscontrol-is-accessibility-ordered-by-row self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityOrderedByRow")))
(define (nscontrol-is-accessibility-protected-content self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityProtectedContent")))
(define (nscontrol-is-accessibility-required self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityRequired")))
(define (nscontrol-is-accessibility-selected self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilitySelected")))
(define (nscontrol-is-accessibility-selector-allowed self selector)
  (_msg-46 (coerce-arg self) (sel_registerName "isAccessibilitySelectorAllowed:") (sel_registerName selector)))
(define (nscontrol-is-continuous self)
  (_msg-3 (coerce-arg self) (sel_registerName "isContinuous")))
(define (nscontrol-is-descendant-of self view)
  (_msg-36 (coerce-arg self) (sel_registerName "isDescendantOf:") (coerce-arg view)))
(define (nscontrol-is-enabled self)
  (_msg-3 (coerce-arg self) (sel_registerName "isEnabled")))
(define (nscontrol-is-flipped self)
  (_msg-3 (coerce-arg self) (sel_registerName "isFlipped")))
(define (nscontrol-is-hidden self)
  (_msg-3 (coerce-arg self) (sel_registerName "isHidden")))
(define (nscontrol-is-hidden-or-has-hidden-ancestor self)
  (_msg-3 (coerce-arg self) (sel_registerName "isHiddenOrHasHiddenAncestor")))
(define (nscontrol-is-highlighted self)
  (_msg-3 (coerce-arg self) (sel_registerName "isHighlighted")))
(define (nscontrol-is-opaque self)
  (_msg-3 (coerce-arg self) (sel_registerName "isOpaque")))
(define (nscontrol-is-rotated-from-base self)
  (_msg-3 (coerce-arg self) (sel_registerName "isRotatedFromBase")))
(define (nscontrol-is-rotated-or-scaled-from-base self)
  (_msg-3 (coerce-arg self) (sel_registerName "isRotatedOrScaledFromBase")))
(define (nscontrol-key-down self event)
  (tell #:type _void (coerce-arg self) keyDown: (coerce-arg event)))
(define (nscontrol-key-up self event)
  (tell #:type _void (coerce-arg self) keyUp: (coerce-arg event)))
(define (nscontrol-layout self)
  (tell #:type _void (coerce-arg self) layout))
(define (nscontrol-layout-subtree-if-needed self)
  (tell #:type _void (coerce-arg self) layoutSubtreeIfNeeded))
(define (nscontrol-lowercase-word self sender)
  (tell #:type _void (coerce-arg self) lowercaseWord: (coerce-arg sender)))
(define (nscontrol-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) magnifyWithEvent: (coerce-arg event)))
(define (nscontrol-make-backing-layer self)
  (wrap-objc-object
   (tell (coerce-arg self) makeBackingLayer)))
(define (nscontrol-make-base-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nscontrol-make-base-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionNatural: (coerce-arg sender)))
(define (nscontrol-make-base-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nscontrol-make-text-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nscontrol-make-text-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionNatural: (coerce-arg sender)))
(define (nscontrol-make-text-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nscontrol-menu-for-event self event)
  (wrap-objc-object
   (tell (coerce-arg self) menuForEvent: (coerce-arg event))))
(define (nscontrol-mouse-in-rect self point rect)
  (_msg-16 (coerce-arg self) (sel_registerName "mouse:inRect:") point rect))
(define (nscontrol-mouse-cancelled self event)
  (tell #:type _void (coerce-arg self) mouseCancelled: (coerce-arg event)))
(define (nscontrol-mouse-down self event)
  (tell #:type _void (coerce-arg self) mouseDown: (coerce-arg event)))
(define (nscontrol-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) mouseDragged: (coerce-arg event)))
(define (nscontrol-mouse-entered self event)
  (tell #:type _void (coerce-arg self) mouseEntered: (coerce-arg event)))
(define (nscontrol-mouse-exited self event)
  (tell #:type _void (coerce-arg self) mouseExited: (coerce-arg event)))
(define (nscontrol-mouse-moved self event)
  (tell #:type _void (coerce-arg self) mouseMoved: (coerce-arg event)))
(define (nscontrol-mouse-up self event)
  (tell #:type _void (coerce-arg self) mouseUp: (coerce-arg event)))
(define (nscontrol-move-backward! self sender)
  (tell #:type _void (coerce-arg self) moveBackward: (coerce-arg sender)))
(define (nscontrol-move-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveBackwardAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-down! self sender)
  (tell #:type _void (coerce-arg self) moveDown: (coerce-arg sender)))
(define (nscontrol-move-down-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveDownAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-forward! self sender)
  (tell #:type _void (coerce-arg self) moveForward: (coerce-arg sender)))
(define (nscontrol-move-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveForwardAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-left! self sender)
  (tell #:type _void (coerce-arg self) moveLeft: (coerce-arg sender)))
(define (nscontrol-move-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveLeftAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-paragraph-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphBackwardAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-paragraph-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphForwardAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-right! self sender)
  (tell #:type _void (coerce-arg self) moveRight: (coerce-arg sender)))
(define (nscontrol-move-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveRightAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-to-beginning-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocument: (coerce-arg sender)))
(define (nscontrol-move-to-beginning-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-to-beginning-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLine: (coerce-arg sender)))
(define (nscontrol-move-to-beginning-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLineAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-to-beginning-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraph: (coerce-arg sender)))
(define (nscontrol-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-to-end-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocument: (coerce-arg sender)))
(define (nscontrol-move-to-end-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-to-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLine: (coerce-arg sender)))
(define (nscontrol-move-to-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-to-end-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraph: (coerce-arg sender)))
(define (nscontrol-move-to-end-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-to-left-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLine: (coerce-arg sender)))
(define (nscontrol-move-to-left-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-to-right-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLine: (coerce-arg sender)))
(define (nscontrol-move-to-right-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-up! self sender)
  (tell #:type _void (coerce-arg self) moveUp: (coerce-arg sender)))
(define (nscontrol-move-up-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveUpAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-word-backward! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackward: (coerce-arg sender)))
(define (nscontrol-move-word-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackwardAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-word-forward! self sender)
  (tell #:type _void (coerce-arg self) moveWordForward: (coerce-arg sender)))
(define (nscontrol-move-word-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordForwardAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-word-left! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeft: (coerce-arg sender)))
(define (nscontrol-move-word-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeftAndModifySelection: (coerce-arg sender)))
(define (nscontrol-move-word-right! self sender)
  (tell #:type _void (coerce-arg self) moveWordRight: (coerce-arg sender)))
(define (nscontrol-move-word-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordRightAndModifySelection: (coerce-arg sender)))
(define (nscontrol-needs-to-draw-rect self rect)
  (_msg-22 (coerce-arg self) (sel_registerName "needsToDrawRect:") rect))
(define (nscontrol-no-responder-for self event-selector)
  (_msg-47 (coerce-arg self) (sel_registerName "noResponderFor:") (sel_registerName event-selector)))
(define (nscontrol-other-mouse-down self event)
  (tell #:type _void (coerce-arg self) otherMouseDown: (coerce-arg event)))
(define (nscontrol-other-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) otherMouseDragged: (coerce-arg event)))
(define (nscontrol-other-mouse-up self event)
  (tell #:type _void (coerce-arg self) otherMouseUp: (coerce-arg event)))
(define (nscontrol-page-down self sender)
  (tell #:type _void (coerce-arg self) pageDown: (coerce-arg sender)))
(define (nscontrol-page-down-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageDownAndModifySelection: (coerce-arg sender)))
(define (nscontrol-page-up self sender)
  (tell #:type _void (coerce-arg self) pageUp: (coerce-arg sender)))
(define (nscontrol-page-up-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageUpAndModifySelection: (coerce-arg sender)))
(define (nscontrol-perform-click! self sender)
  (tell #:type _void (coerce-arg self) performClick: (coerce-arg sender)))
(define (nscontrol-perform-drag-operation! self sender)
  (_msg-36 (coerce-arg self) (sel_registerName "performDragOperation:") (coerce-arg sender)))
(define (nscontrol-perform-key-equivalent! self event)
  (_msg-36 (coerce-arg self) (sel_registerName "performKeyEquivalent:") (coerce-arg event)))
(define (nscontrol-prepare-content-in-rect self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "prepareContentInRect:") rect))
(define (nscontrol-prepare-for-drag-operation self sender)
  (_msg-36 (coerce-arg self) (sel_registerName "prepareForDragOperation:") (coerce-arg sender)))
(define (nscontrol-prepare-for-reuse self)
  (tell #:type _void (coerce-arg self) prepareForReuse))
(define (nscontrol-pressure-change-with-event self event)
  (tell #:type _void (coerce-arg self) pressureChangeWithEvent: (coerce-arg event)))
(define (nscontrol-quick-look-preview-items self sender)
  (tell #:type _void (coerce-arg self) quickLookPreviewItems: (coerce-arg sender)))
(define (nscontrol-quick-look-with-event self event)
  (tell #:type _void (coerce-arg self) quickLookWithEvent: (coerce-arg event)))
(define (nscontrol-rect-for-smart-magnification-at-point-in-rect self location visible-rect)
  (_msg-15 (coerce-arg self) (sel_registerName "rectForSmartMagnificationAtPoint:inRect:") location visible-rect))
(define (nscontrol-remove-all-tool-tips! self)
  (tell #:type _void (coerce-arg self) removeAllToolTips))
(define (nscontrol-remove-from-superview! self)
  (tell #:type _void (coerce-arg self) removeFromSuperview))
(define (nscontrol-remove-from-superview-without-needing-display! self)
  (tell #:type _void (coerce-arg self) removeFromSuperviewWithoutNeedingDisplay))
(define (nscontrol-remove-tool-tip! self tag)
  (_msg-44 (coerce-arg self) (sel_registerName "removeToolTip:") tag))
(define (nscontrol-replace-subview-with! self old-view new-view)
  (tell #:type _void (coerce-arg self) replaceSubview: (coerce-arg old-view) with: (coerce-arg new-view)))
(define (nscontrol-resign-first-responder self)
  (_msg-3 (coerce-arg self) (sel_registerName "resignFirstResponder")))
(define (nscontrol-resize-subviews-with-old-size self old-size)
  (_msg-31 (coerce-arg self) (sel_registerName "resizeSubviewsWithOldSize:") old-size))
(define (nscontrol-resize-with-old-superview-size self old-size)
  (_msg-31 (coerce-arg self) (sel_registerName "resizeWithOldSuperviewSize:") old-size))
(define (nscontrol-restore-user-activity-state self user-activity)
  (tell #:type _void (coerce-arg self) restoreUserActivityState: (coerce-arg user-activity)))
(define (nscontrol-right-mouse-down self event)
  (tell #:type _void (coerce-arg self) rightMouseDown: (coerce-arg event)))
(define (nscontrol-right-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) rightMouseDragged: (coerce-arg event)))
(define (nscontrol-right-mouse-up self event)
  (tell #:type _void (coerce-arg self) rightMouseUp: (coerce-arg event)))
(define (nscontrol-rotate-by-angle self angle)
  (_msg-34 (coerce-arg self) (sel_registerName "rotateByAngle:") angle))
(define (nscontrol-rotate-with-event self event)
  (tell #:type _void (coerce-arg self) rotateWithEvent: (coerce-arg event)))
(define (nscontrol-scale-unit-square-to-size self new-unit-size)
  (_msg-31 (coerce-arg self) (sel_registerName "scaleUnitSquareToSize:") new-unit-size))
(define (nscontrol-scroll-line-down self sender)
  (tell #:type _void (coerce-arg self) scrollLineDown: (coerce-arg sender)))
(define (nscontrol-scroll-line-up self sender)
  (tell #:type _void (coerce-arg self) scrollLineUp: (coerce-arg sender)))
(define (nscontrol-scroll-page-down self sender)
  (tell #:type _void (coerce-arg self) scrollPageDown: (coerce-arg sender)))
(define (nscontrol-scroll-page-up self sender)
  (tell #:type _void (coerce-arg self) scrollPageUp: (coerce-arg sender)))
(define (nscontrol-scroll-point self point)
  (_msg-14 (coerce-arg self) (sel_registerName "scrollPoint:") point))
(define (nscontrol-scroll-rect-to-visible self rect)
  (_msg-22 (coerce-arg self) (sel_registerName "scrollRectToVisible:") rect))
(define (nscontrol-scroll-to-beginning-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToBeginningOfDocument: (coerce-arg sender)))
(define (nscontrol-scroll-to-end-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToEndOfDocument: (coerce-arg sender)))
(define (nscontrol-scroll-wheel self event)
  (tell #:type _void (coerce-arg self) scrollWheel: (coerce-arg event)))
(define (nscontrol-select-all self sender)
  (tell #:type _void (coerce-arg self) selectAll: (coerce-arg sender)))
(define (nscontrol-select-line self sender)
  (tell #:type _void (coerce-arg self) selectLine: (coerce-arg sender)))
(define (nscontrol-select-paragraph self sender)
  (tell #:type _void (coerce-arg self) selectParagraph: (coerce-arg sender)))
(define (nscontrol-select-to-mark self sender)
  (tell #:type _void (coerce-arg self) selectToMark: (coerce-arg sender)))
(define (nscontrol-select-word self sender)
  (tell #:type _void (coerce-arg self) selectWord: (coerce-arg sender)))
(define (nscontrol-send-action-to self action target)
  (_msg-48 (coerce-arg self) (sel_registerName "sendAction:to:") (sel_registerName action) (coerce-arg target)))
(define (nscontrol-send-action-on self mask)
  (_msg-51 (coerce-arg self) (sel_registerName "sendActionOn:") mask))
(define (nscontrol-set-accessibility-activation-point! self accessibility-activation-point)
  (_msg-14 (coerce-arg self) (sel_registerName "setAccessibilityActivationPoint:") accessibility-activation-point))
(define (nscontrol-set-accessibility-allowed-values! self accessibility-allowed-values)
  (tell #:type _void (coerce-arg self) setAccessibilityAllowedValues: (coerce-arg accessibility-allowed-values)))
(define (nscontrol-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityAlternateUIVisible:") accessibility-alternate-ui-visible))
(define (nscontrol-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityApplicationFocusedUIElement: (coerce-arg accessibility-application-focused-ui-element)))
(define (nscontrol-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityAttributedUserInputLabels: (coerce-arg accessibility-attributed-user-input-labels)))
(define (nscontrol-set-accessibility-cancel-button! self accessibility-cancel-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCancelButton: (coerce-arg accessibility-cancel-button)))
(define (nscontrol-set-accessibility-children! self accessibility-children)
  (tell #:type _void (coerce-arg self) setAccessibilityChildren: (coerce-arg accessibility-children)))
(define (nscontrol-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (tell #:type _void (coerce-arg self) setAccessibilityChildrenInNavigationOrder: (coerce-arg accessibility-children-in-navigation-order)))
(define (nscontrol-set-accessibility-clear-button! self accessibility-clear-button)
  (tell #:type _void (coerce-arg self) setAccessibilityClearButton: (coerce-arg accessibility-clear-button)))
(define (nscontrol-set-accessibility-close-button! self accessibility-close-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCloseButton: (coerce-arg accessibility-close-button)))
(define (nscontrol-set-accessibility-column-count! self accessibility-column-count)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityColumnCount:") accessibility-column-count))
(define (nscontrol-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnHeaderUIElements: (coerce-arg accessibility-column-header-ui-elements)))
(define (nscontrol-set-accessibility-column-index-range! self accessibility-column-index-range)
  (_msg-20 (coerce-arg self) (sel_registerName "setAccessibilityColumnIndexRange:") accessibility-column-index-range))
(define (nscontrol-set-accessibility-column-titles! self accessibility-column-titles)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnTitles: (coerce-arg accessibility-column-titles)))
(define (nscontrol-set-accessibility-columns! self accessibility-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityColumns: (coerce-arg accessibility-columns)))
(define (nscontrol-set-accessibility-contents! self accessibility-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityContents: (coerce-arg accessibility-contents)))
(define (nscontrol-set-accessibility-critical-value! self accessibility-critical-value)
  (tell #:type _void (coerce-arg self) setAccessibilityCriticalValue: (coerce-arg accessibility-critical-value)))
(define (nscontrol-set-accessibility-custom-actions! self accessibility-custom-actions)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomActions: (coerce-arg accessibility-custom-actions)))
(define (nscontrol-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomRotors: (coerce-arg accessibility-custom-rotors)))
(define (nscontrol-set-accessibility-decrement-button! self accessibility-decrement-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDecrementButton: (coerce-arg accessibility-decrement-button)))
(define (nscontrol-set-accessibility-default-button! self accessibility-default-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDefaultButton: (coerce-arg accessibility-default-button)))
(define (nscontrol-set-accessibility-disclosed! self accessibility-disclosed)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityDisclosed:") accessibility-disclosed))
(define (nscontrol-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedByRow: (coerce-arg accessibility-disclosed-by-row)))
(define (nscontrol-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedRows: (coerce-arg accessibility-disclosed-rows)))
(define (nscontrol-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityDisclosureLevel:") accessibility-disclosure-level))
(define (nscontrol-set-accessibility-document! self accessibility-document)
  (tell #:type _void (coerce-arg self) setAccessibilityDocument: (coerce-arg accessibility-document)))
(define (nscontrol-set-accessibility-edited! self accessibility-edited)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityEdited:") accessibility-edited))
(define (nscontrol-set-accessibility-element! self accessibility-element)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityElement:") accessibility-element))
(define (nscontrol-set-accessibility-enabled! self accessibility-enabled)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityEnabled:") accessibility-enabled))
(define (nscontrol-set-accessibility-expanded! self accessibility-expanded)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityExpanded:") accessibility-expanded))
(define (nscontrol-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityExtrasMenuBar: (coerce-arg accessibility-extras-menu-bar)))
(define (nscontrol-set-accessibility-filename! self accessibility-filename)
  (tell #:type _void (coerce-arg self) setAccessibilityFilename: (coerce-arg accessibility-filename)))
(define (nscontrol-set-accessibility-focused! self accessibility-focused)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityFocused:") accessibility-focused))
(define (nscontrol-set-accessibility-focused-window! self accessibility-focused-window)
  (tell #:type _void (coerce-arg self) setAccessibilityFocusedWindow: (coerce-arg accessibility-focused-window)))
(define (nscontrol-set-accessibility-frame! self accessibility-frame)
  (_msg-24 (coerce-arg self) (sel_registerName "setAccessibilityFrame:") accessibility-frame))
(define (nscontrol-set-accessibility-frontmost! self accessibility-frontmost)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityFrontmost:") accessibility-frontmost))
(define (nscontrol-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (tell #:type _void (coerce-arg self) setAccessibilityFullScreenButton: (coerce-arg accessibility-full-screen-button)))
(define (nscontrol-set-accessibility-grow-area! self accessibility-grow-area)
  (tell #:type _void (coerce-arg self) setAccessibilityGrowArea: (coerce-arg accessibility-grow-area)))
(define (nscontrol-set-accessibility-handles! self accessibility-handles)
  (tell #:type _void (coerce-arg self) setAccessibilityHandles: (coerce-arg accessibility-handles)))
(define (nscontrol-set-accessibility-header! self accessibility-header)
  (tell #:type _void (coerce-arg self) setAccessibilityHeader: (coerce-arg accessibility-header)))
(define (nscontrol-set-accessibility-help! self accessibility-help)
  (tell #:type _void (coerce-arg self) setAccessibilityHelp: (coerce-arg accessibility-help)))
(define (nscontrol-set-accessibility-hidden! self accessibility-hidden)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityHidden:") accessibility-hidden))
(define (nscontrol-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalScrollBar: (coerce-arg accessibility-horizontal-scroll-bar)))
(define (nscontrol-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalUnitDescription: (coerce-arg accessibility-horizontal-unit-description)))
(define (nscontrol-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityHorizontalUnits:") accessibility-horizontal-units))
(define (nscontrol-set-accessibility-identifier! self accessibility-identifier)
  (tell #:type _void (coerce-arg self) setAccessibilityIdentifier: (coerce-arg accessibility-identifier)))
(define (nscontrol-set-accessibility-increment-button! self accessibility-increment-button)
  (tell #:type _void (coerce-arg self) setAccessibilityIncrementButton: (coerce-arg accessibility-increment-button)))
(define (nscontrol-set-accessibility-index! self accessibility-index)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityIndex:") accessibility-index))
(define (nscontrol-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityInsertionPointLineNumber:") accessibility-insertion-point-line-number))
(define (nscontrol-set-accessibility-label! self accessibility-label)
  (tell #:type _void (coerce-arg self) setAccessibilityLabel: (coerce-arg accessibility-label)))
(define (nscontrol-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLabelUIElements: (coerce-arg accessibility-label-ui-elements)))
(define (nscontrol-set-accessibility-label-value! self accessibility-label-value)
  (_msg-35 (coerce-arg self) (sel_registerName "setAccessibilityLabelValue:") accessibility-label-value))
(define (nscontrol-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLinkedUIElements: (coerce-arg accessibility-linked-ui-elements)))
(define (nscontrol-set-accessibility-main! self accessibility-main)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityMain:") accessibility-main))
(define (nscontrol-set-accessibility-main-window! self accessibility-main-window)
  (tell #:type _void (coerce-arg self) setAccessibilityMainWindow: (coerce-arg accessibility-main-window)))
(define (nscontrol-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerGroupUIElement: (coerce-arg accessibility-marker-group-ui-element)))
(define (nscontrol-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerTypeDescription: (coerce-arg accessibility-marker-type-description)))
(define (nscontrol-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerUIElements: (coerce-arg accessibility-marker-ui-elements)))
(define (nscontrol-set-accessibility-marker-values! self accessibility-marker-values)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerValues: (coerce-arg accessibility-marker-values)))
(define (nscontrol-set-accessibility-max-value! self accessibility-max-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMaxValue: (coerce-arg accessibility-max-value)))
(define (nscontrol-set-accessibility-menu-bar! self accessibility-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityMenuBar: (coerce-arg accessibility-menu-bar)))
(define (nscontrol-set-accessibility-min-value! self accessibility-min-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMinValue: (coerce-arg accessibility-min-value)))
(define (nscontrol-set-accessibility-minimize-button! self accessibility-minimize-button)
  (tell #:type _void (coerce-arg self) setAccessibilityMinimizeButton: (coerce-arg accessibility-minimize-button)))
(define (nscontrol-set-accessibility-minimized! self accessibility-minimized)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityMinimized:") accessibility-minimized))
(define (nscontrol-set-accessibility-modal! self accessibility-modal)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityModal:") accessibility-modal))
(define (nscontrol-set-accessibility-next-contents! self accessibility-next-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityNextContents: (coerce-arg accessibility-next-contents)))
(define (nscontrol-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityNumberOfCharacters:") accessibility-number-of-characters))
(define (nscontrol-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityOrderedByRow:") accessibility-ordered-by-row))
(define (nscontrol-set-accessibility-orientation! self accessibility-orientation)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityOrientation:") accessibility-orientation))
(define (nscontrol-set-accessibility-overflow-button! self accessibility-overflow-button)
  (tell #:type _void (coerce-arg self) setAccessibilityOverflowButton: (coerce-arg accessibility-overflow-button)))
(define (nscontrol-set-accessibility-parent! self accessibility-parent)
  (tell #:type _void (coerce-arg self) setAccessibilityParent: (coerce-arg accessibility-parent)))
(define (nscontrol-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (tell #:type _void (coerce-arg self) setAccessibilityPlaceholderValue: (coerce-arg accessibility-placeholder-value)))
(define (nscontrol-set-accessibility-previous-contents! self accessibility-previous-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityPreviousContents: (coerce-arg accessibility-previous-contents)))
(define (nscontrol-set-accessibility-protected-content! self accessibility-protected-content)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityProtectedContent:") accessibility-protected-content))
(define (nscontrol-set-accessibility-proxy! self accessibility-proxy)
  (tell #:type _void (coerce-arg self) setAccessibilityProxy: (coerce-arg accessibility-proxy)))
(define (nscontrol-set-accessibility-required! self accessibility-required)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityRequired:") accessibility-required))
(define (nscontrol-set-accessibility-role! self accessibility-role)
  (tell #:type _void (coerce-arg self) setAccessibilityRole: (coerce-arg accessibility-role)))
(define (nscontrol-set-accessibility-role-description! self accessibility-role-description)
  (tell #:type _void (coerce-arg self) setAccessibilityRoleDescription: (coerce-arg accessibility-role-description)))
(define (nscontrol-set-accessibility-row-count! self accessibility-row-count)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityRowCount:") accessibility-row-count))
(define (nscontrol-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityRowHeaderUIElements: (coerce-arg accessibility-row-header-ui-elements)))
(define (nscontrol-set-accessibility-row-index-range! self accessibility-row-index-range)
  (_msg-20 (coerce-arg self) (sel_registerName "setAccessibilityRowIndexRange:") accessibility-row-index-range))
(define (nscontrol-set-accessibility-rows! self accessibility-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityRows: (coerce-arg accessibility-rows)))
(define (nscontrol-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityRulerMarkerType:") accessibility-ruler-marker-type))
(define (nscontrol-set-accessibility-search-button! self accessibility-search-button)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchButton: (coerce-arg accessibility-search-button)))
(define (nscontrol-set-accessibility-search-menu! self accessibility-search-menu)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchMenu: (coerce-arg accessibility-search-menu)))
(define (nscontrol-set-accessibility-selected! self accessibility-selected)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilitySelected:") accessibility-selected))
(define (nscontrol-set-accessibility-selected-cells! self accessibility-selected-cells)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedCells: (coerce-arg accessibility-selected-cells)))
(define (nscontrol-set-accessibility-selected-children! self accessibility-selected-children)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedChildren: (coerce-arg accessibility-selected-children)))
(define (nscontrol-set-accessibility-selected-columns! self accessibility-selected-columns)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedColumns: (coerce-arg accessibility-selected-columns)))
(define (nscontrol-set-accessibility-selected-rows! self accessibility-selected-rows)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedRows: (coerce-arg accessibility-selected-rows)))
(define (nscontrol-set-accessibility-selected-text! self accessibility-selected-text)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedText: (coerce-arg accessibility-selected-text)))
(define (nscontrol-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (_msg-20 (coerce-arg self) (sel_registerName "setAccessibilitySelectedTextRange:") accessibility-selected-text-range))
(define (nscontrol-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedTextRanges: (coerce-arg accessibility-selected-text-ranges)))
(define (nscontrol-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityServesAsTitleForUIElements: (coerce-arg accessibility-serves-as-title-for-ui-elements)))
(define (nscontrol-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (_msg-20 (coerce-arg self) (sel_registerName "setAccessibilitySharedCharacterRange:") accessibility-shared-character-range))
(define (nscontrol-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedFocusElements: (coerce-arg accessibility-shared-focus-elements)))
(define (nscontrol-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedTextUIElements: (coerce-arg accessibility-shared-text-ui-elements)))
(define (nscontrol-set-accessibility-shown-menu! self accessibility-shown-menu)
  (tell #:type _void (coerce-arg self) setAccessibilityShownMenu: (coerce-arg accessibility-shown-menu)))
(define (nscontrol-set-accessibility-sort-direction! self accessibility-sort-direction)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilitySortDirection:") accessibility-sort-direction))
(define (nscontrol-set-accessibility-splitters! self accessibility-splitters)
  (tell #:type _void (coerce-arg self) setAccessibilitySplitters: (coerce-arg accessibility-splitters)))
(define (nscontrol-set-accessibility-subrole! self accessibility-subrole)
  (tell #:type _void (coerce-arg self) setAccessibilitySubrole: (coerce-arg accessibility-subrole)))
(define (nscontrol-set-accessibility-tabs! self accessibility-tabs)
  (tell #:type _void (coerce-arg self) setAccessibilityTabs: (coerce-arg accessibility-tabs)))
(define (nscontrol-set-accessibility-title! self accessibility-title)
  (tell #:type _void (coerce-arg self) setAccessibilityTitle: (coerce-arg accessibility-title)))
(define (nscontrol-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTitleUIElement: (coerce-arg accessibility-title-ui-element)))
(define (nscontrol-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (tell #:type _void (coerce-arg self) setAccessibilityToolbarButton: (coerce-arg accessibility-toolbar-button)))
(define (nscontrol-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTopLevelUIElement: (coerce-arg accessibility-top-level-ui-element)))
(define (nscontrol-set-accessibility-url! self accessibility-url)
  (tell #:type _void (coerce-arg self) setAccessibilityURL: (coerce-arg accessibility-url)))
(define (nscontrol-set-accessibility-unit-description! self accessibility-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityUnitDescription: (coerce-arg accessibility-unit-description)))
(define (nscontrol-set-accessibility-units! self accessibility-units)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityUnits:") accessibility-units))
(define (nscontrol-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityUserInputLabels: (coerce-arg accessibility-user-input-labels)))
(define (nscontrol-set-accessibility-value! self accessibility-value)
  (tell #:type _void (coerce-arg self) setAccessibilityValue: (coerce-arg accessibility-value)))
(define (nscontrol-set-accessibility-value-description! self accessibility-value-description)
  (tell #:type _void (coerce-arg self) setAccessibilityValueDescription: (coerce-arg accessibility-value-description)))
(define (nscontrol-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalScrollBar: (coerce-arg accessibility-vertical-scroll-bar)))
(define (nscontrol-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalUnitDescription: (coerce-arg accessibility-vertical-unit-description)))
(define (nscontrol-set-accessibility-vertical-units! self accessibility-vertical-units)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityVerticalUnits:") accessibility-vertical-units))
(define (nscontrol-set-accessibility-visible-cells! self accessibility-visible-cells)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleCells: (coerce-arg accessibility-visible-cells)))
(define (nscontrol-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (_msg-20 (coerce-arg self) (sel_registerName "setAccessibilityVisibleCharacterRange:") accessibility-visible-character-range))
(define (nscontrol-set-accessibility-visible-children! self accessibility-visible-children)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleChildren: (coerce-arg accessibility-visible-children)))
(define (nscontrol-set-accessibility-visible-columns! self accessibility-visible-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleColumns: (coerce-arg accessibility-visible-columns)))
(define (nscontrol-set-accessibility-visible-rows! self accessibility-visible-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleRows: (coerce-arg accessibility-visible-rows)))
(define (nscontrol-set-accessibility-warning-value! self accessibility-warning-value)
  (tell #:type _void (coerce-arg self) setAccessibilityWarningValue: (coerce-arg accessibility-warning-value)))
(define (nscontrol-set-accessibility-window! self accessibility-window)
  (tell #:type _void (coerce-arg self) setAccessibilityWindow: (coerce-arg accessibility-window)))
(define (nscontrol-set-accessibility-windows! self accessibility-windows)
  (tell #:type _void (coerce-arg self) setAccessibilityWindows: (coerce-arg accessibility-windows)))
(define (nscontrol-set-accessibility-zoom-button! self accessibility-zoom-button)
  (tell #:type _void (coerce-arg self) setAccessibilityZoomButton: (coerce-arg accessibility-zoom-button)))
(define (nscontrol-set-animations! self animations)
  (tell #:type _void (coerce-arg self) setAnimations: (coerce-arg animations)))
(define (nscontrol-set-appearance! self appearance)
  (tell #:type _void (coerce-arg self) setAppearance: (coerce-arg appearance)))
(define (nscontrol-set-bounds-origin! self new-origin)
  (_msg-14 (coerce-arg self) (sel_registerName "setBoundsOrigin:") new-origin))
(define (nscontrol-set-bounds-size! self new-size)
  (_msg-31 (coerce-arg self) (sel_registerName "setBoundsSize:") new-size))
(define (nscontrol-set-frame-origin! self new-origin)
  (_msg-14 (coerce-arg self) (sel_registerName "setFrameOrigin:") new-origin))
(define (nscontrol-set-frame-size! self new-size)
  (_msg-31 (coerce-arg self) (sel_registerName "setFrameSize:") new-size))
(define (nscontrol-set-identifier! self identifier)
  (tell #:type _void (coerce-arg self) setIdentifier: (coerce-arg identifier)))
(define (nscontrol-set-mark! self sender)
  (tell #:type _void (coerce-arg self) setMark: (coerce-arg sender)))
(define (nscontrol-set-needs-display-in-rect! self invalid-rect)
  (_msg-24 (coerce-arg self) (sel_registerName "setNeedsDisplayInRect:") invalid-rect))
(define (nscontrol-should-be-treated-as-ink-event self event)
  (_msg-36 (coerce-arg self) (sel_registerName "shouldBeTreatedAsInkEvent:") (coerce-arg event)))
(define (nscontrol-should-delay-window-ordering-for-event self event)
  (_msg-36 (coerce-arg self) (sel_registerName "shouldDelayWindowOrderingForEvent:") (coerce-arg event)))
(define (nscontrol-show-context-help self sender)
  (tell #:type _void (coerce-arg self) showContextHelp: (coerce-arg sender)))
(define (nscontrol-show-context-menu-for-selection self sender)
  (tell #:type _void (coerce-arg self) showContextMenuForSelection: (coerce-arg sender)))
(define (nscontrol-size-that-fits self size)
  (_msg-30 (coerce-arg self) (sel_registerName "sizeThatFits:") size))
(define (nscontrol-size-to-fit self)
  (tell #:type _void (coerce-arg self) sizeToFit))
(define (nscontrol-smart-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) smartMagnifyWithEvent: (coerce-arg event)))
(define (nscontrol-sort-subviews-using-function-context self compare context)
  (_msg-50 (coerce-arg self) (sel_registerName "sortSubviewsUsingFunction:context:") compare context))
(define (nscontrol-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (_msg-49 (coerce-arg self) (sel_registerName "supplementalTargetForAction:sender:") (sel_registerName action) (coerce-arg sender))
   ))
(define (nscontrol-swap-with-mark self sender)
  (tell #:type _void (coerce-arg self) swapWithMark: (coerce-arg sender)))
(define (nscontrol-swipe-with-event self event)
  (tell #:type _void (coerce-arg self) swipeWithEvent: (coerce-arg event)))
(define (nscontrol-tablet-point self event)
  (tell #:type _void (coerce-arg self) tabletPoint: (coerce-arg event)))
(define (nscontrol-tablet-proximity self event)
  (tell #:type _void (coerce-arg self) tabletProximity: (coerce-arg event)))
(define (nscontrol-take-double-value-from self sender)
  (tell #:type _void (coerce-arg self) takeDoubleValueFrom: (coerce-arg sender)))
(define (nscontrol-take-float-value-from self sender)
  (tell #:type _void (coerce-arg self) takeFloatValueFrom: (coerce-arg sender)))
(define (nscontrol-take-int-value-from self sender)
  (tell #:type _void (coerce-arg self) takeIntValueFrom: (coerce-arg sender)))
(define (nscontrol-take-integer-value-from self sender)
  (tell #:type _void (coerce-arg self) takeIntegerValueFrom: (coerce-arg sender)))
(define (nscontrol-take-object-value-from self sender)
  (tell #:type _void (coerce-arg self) takeObjectValueFrom: (coerce-arg sender)))
(define (nscontrol-take-string-value-from self sender)
  (tell #:type _void (coerce-arg self) takeStringValueFrom: (coerce-arg sender)))
(define (nscontrol-touches-began-with-event self event)
  (tell #:type _void (coerce-arg self) touchesBeganWithEvent: (coerce-arg event)))
(define (nscontrol-touches-cancelled-with-event self event)
  (tell #:type _void (coerce-arg self) touchesCancelledWithEvent: (coerce-arg event)))
(define (nscontrol-touches-ended-with-event self event)
  (tell #:type _void (coerce-arg self) touchesEndedWithEvent: (coerce-arg event)))
(define (nscontrol-touches-moved-with-event self event)
  (tell #:type _void (coerce-arg self) touchesMovedWithEvent: (coerce-arg event)))
(define (nscontrol-translate-origin-to-point self translation)
  (_msg-14 (coerce-arg self) (sel_registerName "translateOriginToPoint:") translation))
(define (nscontrol-translate-rects-needing-display-in-rect-by self clip-rect delta)
  (_msg-25 (coerce-arg self) (sel_registerName "translateRectsNeedingDisplayInRect:by:") clip-rect delta))
(define (nscontrol-transpose self sender)
  (tell #:type _void (coerce-arg self) transpose: (coerce-arg sender)))
(define (nscontrol-transpose-words self sender)
  (tell #:type _void (coerce-arg self) transposeWords: (coerce-arg sender)))
(define (nscontrol-try-to-perform-with self action object)
  (_msg-48 (coerce-arg self) (sel_registerName "tryToPerform:with:") (sel_registerName action) (coerce-arg object)))
(define (nscontrol-update-dragging-items-for-drag self sender)
  (tell #:type _void (coerce-arg self) updateDraggingItemsForDrag: (coerce-arg sender)))
(define (nscontrol-update-layer self)
  (tell #:type _void (coerce-arg self) updateLayer))
(define (nscontrol-uppercase-word self sender)
  (tell #:type _void (coerce-arg self) uppercaseWord: (coerce-arg sender)))
(define (nscontrol-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (tell (coerce-arg self) validRequestorForSendType: (coerce-arg send-type) returnType: (coerce-arg return-type))))
(define (nscontrol-view-did-change-backing-properties self)
  (tell #:type _void (coerce-arg self) viewDidChangeBackingProperties))
(define (nscontrol-view-did-change-effective-appearance self)
  (tell #:type _void (coerce-arg self) viewDidChangeEffectiveAppearance))
(define (nscontrol-view-did-end-live-resize self)
  (tell #:type _void (coerce-arg self) viewDidEndLiveResize))
(define (nscontrol-view-did-hide self)
  (tell #:type _void (coerce-arg self) viewDidHide))
(define (nscontrol-view-did-move-to-superview self)
  (tell #:type _void (coerce-arg self) viewDidMoveToSuperview))
(define (nscontrol-view-did-move-to-window self)
  (tell #:type _void (coerce-arg self) viewDidMoveToWindow))
(define (nscontrol-view-did-unhide self)
  (tell #:type _void (coerce-arg self) viewDidUnhide))
(define (nscontrol-view-will-draw self)
  (tell #:type _void (coerce-arg self) viewWillDraw))
(define (nscontrol-view-will-move-to-superview self new-superview)
  (tell #:type _void (coerce-arg self) viewWillMoveToSuperview: (coerce-arg new-superview)))
(define (nscontrol-view-will-move-to-window self new-window)
  (tell #:type _void (coerce-arg self) viewWillMoveToWindow: (coerce-arg new-window)))
(define (nscontrol-view-will-start-live-resize self)
  (tell #:type _void (coerce-arg self) viewWillStartLiveResize))
(define (nscontrol-view-with-tag self tag)
  (wrap-objc-object
   (_msg-42 (coerce-arg self) (sel_registerName "viewWithTag:") tag)
   ))
(define (nscontrol-wants-forwarded-scroll-events-for-axis self axis)
  (_msg-41 (coerce-arg self) (sel_registerName "wantsForwardedScrollEventsForAxis:") axis))
(define (nscontrol-wants-periodic-dragging-updates self)
  (_msg-3 (coerce-arg self) (sel_registerName "wantsPeriodicDraggingUpdates")))
(define (nscontrol-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (_msg-41 (coerce-arg self) (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:") axis))
(define (nscontrol-will-open-menu-with-event self menu event)
  (tell #:type _void (coerce-arg self) willOpenMenu: (coerce-arg menu) withEvent: (coerce-arg event)))
(define (nscontrol-will-remove-subview self subview)
  (tell #:type _void (coerce-arg self) willRemoveSubview: (coerce-arg subview)))
(define (nscontrol-yank self sender)
  (tell #:type _void (coerce-arg self) yank: (coerce-arg sender)))

;; --- Class methods ---
(define (nscontrol-default-animation-for-key key)
  (wrap-objc-object
   (tell NSControl defaultAnimationForKey: (coerce-arg key))))
(define (nscontrol-is-compatible-with-responsive-scrolling)
  (_msg-3 NSControl (sel_registerName "isCompatibleWithResponsiveScrolling")))
