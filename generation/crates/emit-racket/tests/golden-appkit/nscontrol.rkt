#lang racket/base
;; Generated binding for NSControl (AppKit)
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
(define (nscandidatelisttouchbaritem? v) (objc-instance-of? v "NSCandidateListTouchBarItem"))
(define (nscontrol? v) (objc-instance-of? v "NSControl"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
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
  [nscontrol-alignment (c-> nscontrol? exact-integer?)]
  [nscontrol-set-alignment! (c-> nscontrol? exact-integer? void?)]
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
  [nscontrol-base-writing-direction (c-> nscontrol? exact-integer?)]
  [nscontrol-set-base-writing-direction! (c-> nscontrol? exact-integer? void?)]
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
  [nscontrol-layer-contents-placement (c-> nscontrol? exact-integer?)]
  [nscontrol-set-layer-contents-placement! (c-> nscontrol? exact-integer? void?)]
  [nscontrol-layer-contents-redraw-policy (c-> nscontrol? exact-integer?)]
  [nscontrol-set-layer-contents-redraw-policy! (c-> nscontrol? exact-integer? void?)]
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
  [nscontrol-user-interface-layout-direction (c-> nscontrol? exact-integer?)]
  [nscontrol-set-user-interface-layout-direction! (c-> nscontrol? exact-integer? void?)]
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
  [nscontrol-accessibility-horizontal-units (c-> nscontrol? exact-integer?)]
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
  [nscontrol-accessibility-orientation (c-> nscontrol? exact-integer?)]
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
  [nscontrol-accessibility-ruler-marker-type (c-> nscontrol? exact-integer?)]
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
  [nscontrol-accessibility-sort-direction (c-> nscontrol? exact-integer?)]
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
  [nscontrol-accessibility-units (c-> nscontrol? exact-integer?)]
  [nscontrol-accessibility-user-input-labels (c-> nscontrol? any/c)]
  [nscontrol-accessibility-value (c-> nscontrol? any/c)]
  [nscontrol-accessibility-value-description (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-vertical-scroll-bar (c-> nscontrol? any/c)]
  [nscontrol-accessibility-vertical-unit-description (c-> nscontrol? (or/c nsstring? objc-nil?))]
  [nscontrol-accessibility-vertical-units (c-> nscontrol? exact-integer?)]
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
  [nscontrol-add-subview-positioned-relative-to! (c-> nscontrol? (or/c string? objc-object? #f) exact-integer? (or/c string? objc-object? #f) void?)]
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
  [nscontrol-set-accessibility-horizontal-units! (c-> nscontrol? exact-integer? void?)]
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
  [nscontrol-set-accessibility-orientation! (c-> nscontrol? exact-integer? void?)]
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
  [nscontrol-set-accessibility-ruler-marker-type! (c-> nscontrol? exact-integer? void?)]
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
  [nscontrol-set-accessibility-sort-direction! (c-> nscontrol? exact-integer? void?)]
  [nscontrol-set-accessibility-splitters! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-subrole! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-tabs! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-title! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-title-ui-element! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-toolbar-button! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-top-level-ui-element! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-url! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-unit-description! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-units! (c-> nscontrol? exact-integer? void?)]
  [nscontrol-set-accessibility-user-input-labels! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-value! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-value-description! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-vertical-scroll-bar! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-vertical-unit-description! (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-set-accessibility-vertical-units! (c-> nscontrol? exact-integer? void?)]
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
  [nscontrol-wants-forwarded-scroll-events-for-axis (c-> nscontrol? exact-integer? boolean?)]
  [nscontrol-wants-periodic-dragging-updates (c-> nscontrol? boolean?)]
  [nscontrol-wants-scroll-events-for-swipe-tracking-on-axis (c-> nscontrol? exact-integer? boolean?)]
  [nscontrol-will-open-menu-with-event (c-> nscontrol? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nscontrol-will-remove-subview (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-yank (c-> nscontrol? (or/c string? objc-object? #f) void?)]
  [nscontrol-default-animation-for-key (c-> (or/c string? objc-object? #f) any/c)]
  [nscontrol-is-compatible-with-responsive-scrolling (c-> boolean?)]
  )

;; --- Class reference ---
(import-class NSControl)

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
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_b (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
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
(define (make-nscontrol-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSControl alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nscontrol-init-with-frame frame-rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (tell NSControl alloc)) (id->ffi2-ptr (sel_registerName "initWithFrame:")) (id->ffi2-ptr frame-rect)))
   #:retained #t))


;; --- Properties ---
(define (nscontrol-accepts-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsFirstResponder"))))
(define (nscontrol-accepts-touch-events self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsTouchEvents"))))
(define (nscontrol-set-accepts-touch-events! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAcceptsTouchEvents:")) value))
(define (nscontrol-action self)
  (ptr_t->cpointer (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "action")))))
(define (nscontrol-set-action! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAction:")) (id->ffi2-ptr (sel_registerName value))))
(define (nscontrol-additional-safe-area-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "additionalSafeAreaInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nscontrol-set-additional-safe-area-insets! self value)
  (aw_racket_msg_E_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAdditionalSafeAreaInsets:")) (id->ffi2-ptr value)))
(define (nscontrol-alignment self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignment"))))
(define (nscontrol-set-alignment! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlignment:")) value))
(define (nscontrol-alignment-rect-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignmentRectInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nscontrol-allowed-touch-types self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowedTouchTypes"))))
(define (nscontrol-set-allowed-touch-types! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowedTouchTypes:")) value))
(define (nscontrol-allows-expansion-tool-tips self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsExpansionToolTips"))))
(define (nscontrol-set-allows-expansion-tool-tips! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsExpansionToolTips:")) value))
(define (nscontrol-allows-vibrancy self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsVibrancy"))))
(define (nscontrol-alpha-value self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alphaValue"))))
(define (nscontrol-set-alpha-value! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlphaValue:")) value))
(define (nscontrol-attributed-string-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "attributedStringValue"))))))
(define (nscontrol-set-attributed-string-value! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAttributedStringValue:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-autoresizes-subviews self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoresizesSubviews"))))
(define (nscontrol-set-autoresizes-subviews! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutoresizesSubviews:")) value))
(define (nscontrol-autoresizing-mask self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoresizingMask"))))
(define (nscontrol-set-autoresizing-mask! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutoresizingMask:")) value))
(define (nscontrol-background-filters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backgroundFilters"))))))
(define (nscontrol-set-background-filters! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBackgroundFilters:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-base-writing-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "baseWritingDirection"))))
(define (nscontrol-set-base-writing-direction! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBaseWritingDirection:")) value))
(define (nscontrol-baseline-offset-from-bottom self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "baselineOffsetFromBottom"))))
(define (nscontrol-bottom-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bottomAnchor"))))))
(define (nscontrol-bounds self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bounds")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-set-bounds! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBounds:")) (id->ffi2-ptr value)))
(define (nscontrol-bounds-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "boundsRotation"))))
(define (nscontrol-set-bounds-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsRotation:")) value))
(define (nscontrol-can-become-key-view self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canBecomeKeyView"))))
(define (nscontrol-can-draw self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDraw"))))
(define (nscontrol-can-draw-concurrently self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDrawConcurrently"))))
(define (nscontrol-set-can-draw-concurrently! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCanDrawConcurrently:")) value))
(define (nscontrol-can-draw-subviews-into-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDrawSubviewsIntoLayer"))))
(define (nscontrol-set-can-draw-subviews-into-layer! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCanDrawSubviewsIntoLayer:")) value))
(define (nscontrol-candidate-list-touch-bar-item self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "candidateListTouchBarItem"))))))
(define (nscontrol-cell self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cell"))))))
(define (nscontrol-set-cell! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCell:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-cell-class)
  (ptr_t->cpointer (aw_racket_msg_0_P (id->ffi2-ptr NSControl) (id->ffi2-ptr (sel_registerName "cellClass")))))
(define (nscontrol-set-cell-class! value)
  (aw_racket_msg_P_v (id->ffi2-ptr NSControl) (id->ffi2-ptr (sel_registerName "setCellClass:")) (id->ffi2-ptr value)))
(define (nscontrol-center-x-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerXAnchor"))))))
(define (nscontrol-center-y-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerYAnchor"))))))
(define (nscontrol-clips-to-bounds self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "clipsToBounds"))))
(define (nscontrol-set-clips-to-bounds! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setClipsToBounds:")) value))
(define (nscontrol-compatible-with-responsive-scrolling)
  (aw_racket_msg_0_b (id->ffi2-ptr NSControl) (id->ffi2-ptr (sel_registerName "compatibleWithResponsiveScrolling"))))
(define (nscontrol-compositing-filter self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "compositingFilter"))))))
(define (nscontrol-set-compositing-filter! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCompositingFilter:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-constraints self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "constraints"))))))
(define (nscontrol-content-filters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentFilters"))))))
(define (nscontrol-set-content-filters! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentFilters:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-continuous self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "continuous"))))
(define (nscontrol-set-continuous! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContinuous:")) value))
(define (nscontrol-control-size self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "controlSize"))))
(define (nscontrol-set-control-size! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setControlSize:")) value))
(define (nscontrol-default-focus-ring-type)
  (aw_racket_msg_0_Q (id->ffi2-ptr NSControl) (id->ffi2-ptr (sel_registerName "defaultFocusRingType"))))
(define (nscontrol-default-menu)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSControl) (id->ffi2-ptr (sel_registerName "defaultMenu"))))))
(define (nscontrol-double-value self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "doubleValue"))))
(define (nscontrol-set-double-value! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDoubleValue:")) value))
(define (nscontrol-drawing-find-indicator self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawingFindIndicator"))))
(define (nscontrol-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enabled"))))
(define (nscontrol-set-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setEnabled:")) value))
(define (nscontrol-enclosing-menu-item self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enclosingMenuItem"))))))
(define (nscontrol-enclosing-scroll-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enclosingScrollView"))))))
(define (nscontrol-first-baseline-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstBaselineAnchor"))))))
(define (nscontrol-first-baseline-offset-from-top self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstBaselineOffsetFromTop"))))
(define (nscontrol-fitting-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fittingSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nscontrol-flipped self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flipped"))))
(define (nscontrol-float-value self)
  (aw_racket_msg_0_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "floatValue"))))
(define (nscontrol-set-float-value! self value)
  (aw_racket_msg_f_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFloatValue:")) value))
(define (nscontrol-focus-ring-mask-bounds self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "focusRingMaskBounds")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-focus-ring-type self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "focusRingType"))))
(define (nscontrol-set-focus-ring-type! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFocusRingType:")) value))
(define (nscontrol-focus-view)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSControl) (id->ffi2-ptr (sel_registerName "focusView"))))))
(define (nscontrol-font self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "font"))))))
(define (nscontrol-set-font! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFont:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-formatter self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "formatter"))))))
(define (nscontrol-set-formatter! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFormatter:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-set-frame! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrame:")) (id->ffi2-ptr value)))
(define (nscontrol-frame-center-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameCenterRotation"))))
(define (nscontrol-set-frame-center-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameCenterRotation:")) value))
(define (nscontrol-frame-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameRotation"))))
(define (nscontrol-set-frame-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameRotation:")) value))
(define (nscontrol-gesture-recognizers self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "gestureRecognizers"))))))
(define (nscontrol-set-gesture-recognizers! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setGestureRecognizers:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-has-ambiguous-layout self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasAmbiguousLayout"))))
(define (nscontrol-height-adjust-limit self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "heightAdjustLimit"))))
(define (nscontrol-height-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "heightAnchor"))))))
(define (nscontrol-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hidden"))))
(define (nscontrol-set-hidden! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHidden:")) value))
(define (nscontrol-hidden-or-has-hidden-ancestor self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hiddenOrHasHiddenAncestor"))))
(define (nscontrol-highlighted self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "highlighted"))))
(define (nscontrol-set-highlighted! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHighlighted:")) value))
(define (nscontrol-horizontal-content-size-constraint-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "horizontalContentSizeConstraintActive"))))
(define (nscontrol-set-horizontal-content-size-constraint-active! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHorizontalContentSizeConstraintActive:")) value))
(define (nscontrol-ignores-multi-click self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "ignoresMultiClick"))))
(define (nscontrol-set-ignores-multi-click! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIgnoresMultiClick:")) value))
(define (nscontrol-in-full-screen-mode self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inFullScreenMode"))))
(define (nscontrol-in-live-resize self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inLiveResize"))))
(define (nscontrol-input-context self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inputContext"))))))
(define (nscontrol-int-value self)
  (aw_racket_msg_0_i (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "intValue"))))
(define (nscontrol-set-int-value! self value)
  (aw_racket_msg_i_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIntValue:")) value))
(define (nscontrol-integer-value self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "integerValue"))))
(define (nscontrol-set-integer-value! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIntegerValue:")) value))
(define (nscontrol-intrinsic-content-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "intrinsicContentSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nscontrol-last-baseline-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastBaselineAnchor"))))))
(define (nscontrol-last-baseline-offset-from-bottom self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastBaselineOffsetFromBottom"))))
(define (nscontrol-layer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layer"))))))
(define (nscontrol-set-layer! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayer:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-layer-contents-placement self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerContentsPlacement"))))
(define (nscontrol-set-layer-contents-placement! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerContentsPlacement:")) value))
(define (nscontrol-layer-contents-redraw-policy self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerContentsRedrawPolicy"))))
(define (nscontrol-set-layer-contents-redraw-policy! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerContentsRedrawPolicy:")) value))
(define (nscontrol-layer-uses-core-image-filters self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerUsesCoreImageFilters"))))
(define (nscontrol-set-layer-uses-core-image-filters! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerUsesCoreImageFilters:")) value))
(define (nscontrol-layout-guides self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutGuides"))))))
(define (nscontrol-layout-margins-guide self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutMarginsGuide"))))))
(define (nscontrol-leading-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "leadingAnchor"))))))
(define (nscontrol-left-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "leftAnchor"))))))
(define (nscontrol-line-break-mode self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lineBreakMode"))))
(define (nscontrol-set-line-break-mode! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLineBreakMode:")) value))
(define (nscontrol-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menu"))))))
(define (nscontrol-set-menu! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMenu:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-mouse-down-can-move-window self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDownCanMoveWindow"))))
(define (nscontrol-needs-display self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsDisplay"))))
(define (nscontrol-set-needs-display! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsDisplay:")) value))
(define (nscontrol-needs-layout self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsLayout"))))
(define (nscontrol-set-needs-layout! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsLayout:")) value))
(define (nscontrol-needs-panel-to-become-key self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsPanelToBecomeKey"))))
(define (nscontrol-needs-update-constraints self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsUpdateConstraints"))))
(define (nscontrol-set-needs-update-constraints! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsUpdateConstraints:")) value))
(define (nscontrol-next-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextKeyView"))))))
(define (nscontrol-set-next-key-view! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextKeyView:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-next-responder self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextResponder"))))))
(define (nscontrol-set-next-responder! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextResponder:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-next-valid-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextValidKeyView"))))))
(define (nscontrol-object-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "objectValue"))))))
(define (nscontrol-set-object-value! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setObjectValue:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-opaque self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "opaque"))))
(define (nscontrol-opaque-ancestor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "opaqueAncestor"))))))
(define (nscontrol-page-footer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageFooter"))))))
(define (nscontrol-page-header self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageHeader"))))))
(define (nscontrol-posts-bounds-changed-notifications self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "postsBoundsChangedNotifications"))))
(define (nscontrol-set-posts-bounds-changed-notifications! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPostsBoundsChangedNotifications:")) value))
(define (nscontrol-posts-frame-changed-notifications self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "postsFrameChangedNotifications"))))
(define (nscontrol-set-posts-frame-changed-notifications! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPostsFrameChangedNotifications:")) value))
(define (nscontrol-prefers-compact-control-size-metrics self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prefersCompactControlSizeMetrics"))))
(define (nscontrol-set-prefers-compact-control-size-metrics! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPrefersCompactControlSizeMetrics:")) value))
(define (nscontrol-prepared-content-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preparedContentRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-set-prepared-content-rect! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPreparedContentRect:")) (id->ffi2-ptr value)))
(define (nscontrol-preserves-content-during-live-resize self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preservesContentDuringLiveResize"))))
(define (nscontrol-pressure-configuration self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pressureConfiguration"))))))
(define (nscontrol-set-pressure-configuration! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPressureConfiguration:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-previous-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "previousKeyView"))))))
(define (nscontrol-previous-valid-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "previousValidKeyView"))))))
(define (nscontrol-print-job-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "printJobTitle"))))))
(define (nscontrol-rect-preserved-during-live-resize self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectPreservedDuringLiveResize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-refuses-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "refusesFirstResponder"))))
(define (nscontrol-set-refuses-first-responder! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setRefusesFirstResponder:")) value))
(define (nscontrol-registered-dragged-types self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "registeredDraggedTypes"))))))
(define (nscontrol-requires-constraint-based-layout)
  (aw_racket_msg_0_b (id->ffi2-ptr NSControl) (id->ffi2-ptr (sel_registerName "requiresConstraintBasedLayout"))))
(define (nscontrol-restorable-state-key-paths)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSControl) (id->ffi2-ptr (sel_registerName "restorableStateKeyPaths"))))))
(define (nscontrol-right-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightAnchor"))))))
(define (nscontrol-rotated-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotatedFromBase"))))
(define (nscontrol-rotated-or-scaled-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotatedOrScaledFromBase"))))
(define (nscontrol-safe-area-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nscontrol-safe-area-layout-guide self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaLayoutGuide"))))))
(define (nscontrol-safe-area-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-shadow self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shadow"))))))
(define (nscontrol-set-shadow! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShadow:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-string-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringValue"))))))
(define (nscontrol-set-string-value! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setStringValue:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-subviews self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "subviews"))))))
(define (nscontrol-set-subviews! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSubviews:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-superview self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "superview"))))))
(define (nscontrol-tag self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tag"))))
(define (nscontrol-set-tag! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTag:")) value))
(define (nscontrol-target self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "target"))))))
(define (nscontrol-set-target! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTarget:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-tool-tip self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "toolTip"))))))
(define (nscontrol-set-tool-tip! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setToolTip:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-top-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "topAnchor"))))))
(define (nscontrol-touch-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchBar"))))))
(define (nscontrol-set-touch-bar! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTouchBar:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-tracking-areas self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "trackingAreas"))))))
(define (nscontrol-trailing-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "trailingAnchor"))))))
(define (nscontrol-translates-autoresizing-mask-into-constraints self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translatesAutoresizingMaskIntoConstraints"))))
(define (nscontrol-set-translates-autoresizing-mask-into-constraints! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTranslatesAutoresizingMaskIntoConstraints:")) value))
(define (nscontrol-undo-manager self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "undoManager"))))))
(define (nscontrol-user-activity self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userActivity"))))))
(define (nscontrol-set-user-activity! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserActivity:")) (id->ffi2-ptr (coerce-arg value))))
(define (nscontrol-user-interface-layout-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userInterfaceLayoutDirection"))))
(define (nscontrol-set-user-interface-layout-direction! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserInterfaceLayoutDirection:")) value))
(define (nscontrol-uses-single-line-mode self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "usesSingleLineMode"))))
(define (nscontrol-set-uses-single-line-mode! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUsesSingleLineMode:")) value))
(define (nscontrol-vertical-content-size-constraint-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "verticalContentSizeConstraintActive"))))
(define (nscontrol-set-vertical-content-size-constraint-active! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setVerticalContentSizeConstraintActive:")) value))
(define (nscontrol-visible-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "visibleRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-wants-best-resolution-open-gl-surface self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsBestResolutionOpenGLSurface"))))
(define (nscontrol-set-wants-best-resolution-open-gl-surface! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsBestResolutionOpenGLSurface:")) value))
(define (nscontrol-wants-default-clipping self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsDefaultClipping"))))
(define (nscontrol-wants-extended-dynamic-range-open-gl-surface self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsExtendedDynamicRangeOpenGLSurface"))))
(define (nscontrol-set-wants-extended-dynamic-range-open-gl-surface! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsExtendedDynamicRangeOpenGLSurface:")) value))
(define (nscontrol-wants-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsLayer"))))
(define (nscontrol-set-wants-layer! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsLayer:")) value))
(define (nscontrol-wants-resting-touches self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsRestingTouches"))))
(define (nscontrol-set-wants-resting-touches! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsRestingTouches:")) value))
(define (nscontrol-wants-update-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsUpdateLayer"))))
(define (nscontrol-width-adjust-limit self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "widthAdjustLimit"))))
(define (nscontrol-width-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "widthAnchor"))))))
(define (nscontrol-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "window"))))))
(define (nscontrol-writing-tools-coordinator self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writingToolsCoordinator"))))))
(define (nscontrol-set-writing-tools-coordinator! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWritingToolsCoordinator:")) (id->ffi2-ptr (coerce-arg value))))

;; --- Instance methods ---
(define (nscontrol-accepts-first-mouse self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsFirstMouse:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-accessibility-activation-point self)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_0_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityActivationPoint")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nscontrol-accessibility-allowed-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAllowedValues"))))
   ))
(define (nscontrol-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityApplicationFocusedUIElement"))))
   ))
(define (nscontrol-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nscontrol-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedUserInputLabels"))))
   ))
(define (nscontrol-accessibility-cancel-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCancelButton"))))
   ))
(define (nscontrol-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_qq_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCellForColumn:row:")) column row))
   ))
(define (nscontrol-accessibility-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildren"))))
   ))
(define (nscontrol-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildrenInNavigationOrder"))))
   ))
(define (nscontrol-accessibility-clear-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityClearButton"))))
   ))
(define (nscontrol-accessibility-close-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCloseButton"))))
   ))
(define (nscontrol-accessibility-column-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnCount"))))
(define (nscontrol-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnHeaderUIElements"))))
   ))
(define (nscontrol-accessibility-column-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nscontrol-accessibility-column-titles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnTitles"))))
   ))
(define (nscontrol-accessibility-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumns"))))
   ))
(define (nscontrol-accessibility-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityContents"))))
   ))
(define (nscontrol-accessibility-critical-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCriticalValue"))))
   ))
(define (nscontrol-accessibility-custom-actions self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomActions"))))
   ))
(define (nscontrol-accessibility-custom-rotors self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomRotors"))))
   ))
(define (nscontrol-accessibility-decrement-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDecrementButton"))))
   ))
(define (nscontrol-accessibility-default-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDefaultButton"))))
   ))
(define (nscontrol-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedByRow"))))
   ))
(define (nscontrol-accessibility-disclosed-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedRows"))))
   ))
(define (nscontrol-accessibility-disclosure-level self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosureLevel"))))
(define (nscontrol-accessibility-document self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDocument"))))
   ))
(define (nscontrol-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityExtrasMenuBar"))))
   ))
(define (nscontrol-accessibility-filename self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFilename"))))
   ))
(define (nscontrol-accessibility-focused-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFocusedWindow"))))
   ))
(define (nscontrol-accessibility-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-accessibility-frame-for-range self range)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_G_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrameForRange:")) (id->ffi2-ptr range) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-accessibility-full-screen-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFullScreenButton"))))
   ))
(define (nscontrol-accessibility-grow-area self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityGrowArea"))))
   ))
(define (nscontrol-accessibility-handles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHandles"))))
   ))
(define (nscontrol-accessibility-header self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHeader"))))
   ))
(define (nscontrol-accessibility-help self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHelp"))))
   ))
(define (nscontrol-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalScrollBar"))))
   ))
(define (nscontrol-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnitDescription"))))
   ))
(define (nscontrol-accessibility-horizontal-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnits"))))
(define (nscontrol-accessibility-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIdentifier"))))
   ))
(define (nscontrol-accessibility-increment-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIncrementButton"))))
   ))
(define (nscontrol-accessibility-index self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIndex"))))
(define (nscontrol-accessibility-insertion-point-line-number self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityInsertionPointLineNumber"))))
(define (nscontrol-accessibility-label self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabel"))))
   ))
(define (nscontrol-accessibility-label-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelUIElements"))))
   ))
(define (nscontrol-accessibility-label-value self)
  (aw_racket_msg_0_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelValue"))))
(define (nscontrol-accessibility-layout-point-for-screen-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutPointForScreenPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nscontrol-accessibility-layout-size-for-screen-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutSizeForScreenSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nscontrol-accessibility-line-for-index self index)
  (aw_racket_msg_q_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLineForIndex:")) index))
(define (nscontrol-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLinkedUIElements"))))
   ))
(define (nscontrol-accessibility-main-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMainWindow"))))
   ))
(define (nscontrol-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerGroupUIElement"))))
   ))
(define (nscontrol-accessibility-marker-type-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerTypeDescription"))))
   ))
(define (nscontrol-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerUIElements"))))
   ))
(define (nscontrol-accessibility-marker-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerValues"))))
   ))
(define (nscontrol-accessibility-max-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMaxValue"))))
   ))
(define (nscontrol-accessibility-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMenuBar"))))
   ))
(define (nscontrol-accessibility-min-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinValue"))))
   ))
(define (nscontrol-accessibility-minimize-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinimizeButton"))))
   ))
(define (nscontrol-accessibility-next-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNextContents"))))
   ))
(define (nscontrol-accessibility-number-of-characters self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNumberOfCharacters"))))
(define (nscontrol-accessibility-orientation self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOrientation"))))
(define (nscontrol-accessibility-overflow-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOverflowButton"))))
   ))
(define (nscontrol-accessibility-parent self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityParent"))))
   ))
(define (nscontrol-accessibility-perform-cancel self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformCancel"))))
(define (nscontrol-accessibility-perform-confirm self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformConfirm"))))
(define (nscontrol-accessibility-perform-decrement self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDecrement"))))
(define (nscontrol-accessibility-perform-delete self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDelete"))))
(define (nscontrol-accessibility-perform-increment self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformIncrement"))))
(define (nscontrol-accessibility-perform-pick self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPick"))))
(define (nscontrol-accessibility-perform-press self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPress"))))
(define (nscontrol-accessibility-perform-raise self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformRaise"))))
(define (nscontrol-accessibility-perform-show-alternate-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowAlternateUI"))))
(define (nscontrol-accessibility-perform-show-default-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowDefaultUI"))))
(define (nscontrol-accessibility-perform-show-menu self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowMenu"))))
(define (nscontrol-accessibility-placeholder-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPlaceholderValue"))))
   ))
(define (nscontrol-accessibility-previous-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPreviousContents"))))
   ))
(define (nscontrol-accessibility-proxy self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityProxy"))))
   ))
(define (nscontrol-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRTFForRange:")) (id->ffi2-ptr range)))
   ))
(define (nscontrol-accessibility-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nscontrol-accessibility-range-for-line self line)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForLine:")) line (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nscontrol-accessibility-range-for-position self point)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_O_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForPosition:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nscontrol-accessibility-role self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRole"))))
   ))
(define (nscontrol-accessibility-role-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRoleDescription"))))
   ))
(define (nscontrol-accessibility-row-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowCount"))))
(define (nscontrol-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowHeaderUIElements"))))
   ))
(define (nscontrol-accessibility-row-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nscontrol-accessibility-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRows"))))
   ))
(define (nscontrol-accessibility-ruler-marker-type self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRulerMarkerType"))))
(define (nscontrol-accessibility-screen-point-for-layout-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenPointForLayoutPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nscontrol-accessibility-screen-size-for-layout-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenSizeForLayoutSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nscontrol-accessibility-search-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchButton"))))
   ))
(define (nscontrol-accessibility-search-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchMenu"))))
   ))
(define (nscontrol-accessibility-selected-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedCells"))))
   ))
(define (nscontrol-accessibility-selected-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedChildren"))))
   ))
(define (nscontrol-accessibility-selected-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedColumns"))))
   ))
(define (nscontrol-accessibility-selected-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedRows"))))
   ))
(define (nscontrol-accessibility-selected-text self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedText"))))
   ))
(define (nscontrol-accessibility-selected-text-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nscontrol-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRanges"))))
   ))
(define (nscontrol-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityServesAsTitleForUIElements"))))
   ))
(define (nscontrol-accessibility-shared-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nscontrol-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedFocusElements"))))
   ))
(define (nscontrol-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedTextUIElements"))))
   ))
(define (nscontrol-accessibility-shown-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityShownMenu"))))
   ))
(define (nscontrol-accessibility-sort-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySortDirection"))))
(define (nscontrol-accessibility-splitters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySplitters"))))
   ))
(define (nscontrol-accessibility-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nscontrol-accessibility-style-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStyleRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nscontrol-accessibility-subrole self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySubrole"))))
   ))
(define (nscontrol-accessibility-tabs self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTabs"))))
   ))
(define (nscontrol-accessibility-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitle"))))
   ))
(define (nscontrol-accessibility-title-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitleUIElement"))))
   ))
(define (nscontrol-accessibility-toolbar-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityToolbarButton"))))
   ))
(define (nscontrol-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTopLevelUIElement"))))
   ))
(define (nscontrol-accessibility-url self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityURL"))))
   ))
(define (nscontrol-accessibility-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnitDescription"))))
   ))
(define (nscontrol-accessibility-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnits"))))
(define (nscontrol-accessibility-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUserInputLabels"))))
   ))
(define (nscontrol-accessibility-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValue"))))
   ))
(define (nscontrol-accessibility-value-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValueDescription"))))
   ))
(define (nscontrol-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalScrollBar"))))
   ))
(define (nscontrol-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnitDescription"))))
   ))
(define (nscontrol-accessibility-vertical-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnits"))))
(define (nscontrol-accessibility-visible-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCells"))))
   ))
(define (nscontrol-accessibility-visible-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nscontrol-accessibility-visible-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleChildren"))))
   ))
(define (nscontrol-accessibility-visible-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleColumns"))))
   ))
(define (nscontrol-accessibility-visible-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleRows"))))
   ))
(define (nscontrol-accessibility-warning-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWarningValue"))))
   ))
(define (nscontrol-accessibility-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindow"))))
   ))
(define (nscontrol-accessibility-windows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindows"))))
   ))
(define (nscontrol-accessibility-zoom-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityZoomButton"))))
   ))
(define (nscontrol-add-subview! self view)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addSubview:")) (id->ffi2-ptr (coerce-arg view))))
(define (nscontrol-add-subview-positioned-relative-to! self view place other-view)
  (aw_racket_msg_PqP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addSubview:positioned:relativeTo:")) (id->ffi2-ptr (coerce-arg view)) place (id->ffi2-ptr (coerce-arg other-view))))
(define (nscontrol-add-tool-tip-rect-owner-user-data! self rect owner data)
  (aw_racket_msg_RPP_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addToolTipRect:owner:userData:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg owner)) (id->ffi2-ptr data)))
(define (nscontrol-adjust-scroll self new-visible)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "adjustScroll:")) (id->ffi2-ptr new-visible) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-ancestor-shared-with-view self view)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "ancestorSharedWithView:")) (id->ffi2-ptr (coerce-arg view))))
   ))
(define (nscontrol-animation-for-key self key)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animationForKey:")) (id->ffi2-ptr (coerce-arg key))))
   ))
(define (nscontrol-animations self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animations"))))
   ))
(define (nscontrol-animator self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animator"))))
   ))
(define (nscontrol-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "appearance"))))
   ))
(define (nscontrol-autoscroll self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoscroll:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-backing-aligned-rect-options self rect options)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RQ_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backingAlignedRect:options:")) (id->ffi2-ptr rect) options (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-become-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "becomeFirstResponder"))))
(define (nscontrol-begin-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-bitmap-image-rep-for-caching-display-in-rect self rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bitmapImageRepForCachingDisplayInRect:")) (id->ffi2-ptr rect)))
   ))
(define (nscontrol-cache-display-in-rect-to-bitmap-image-rep self rect bitmap-image-rep)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cacheDisplayInRect:toBitmapImageRep:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg bitmap-image-rep))))
(define (nscontrol-cancel-operation self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cancelOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-capitalize-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "capitalizeWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-center-scan-rect! self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerScanRect:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-center-selection-in-visible-area! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerSelectionInVisibleArea:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-change-case-of-letter self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeCaseOfLetter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-change-mode-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeModeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-complete self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "complete:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-conclude-drag-operation self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "concludeDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-context-menu-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contextMenuKeyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-convert-point-from-view self point view)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_OP_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPoint:fromView:")) (id->ffi2-ptr point) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nscontrol-convert-point-to-view self point view)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_OP_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPoint:toView:")) (id->ffi2-ptr point) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nscontrol-convert-point-from-backing self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointFromBacking:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nscontrol-convert-point-from-layer self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointFromLayer:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nscontrol-convert-point-to-backing self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointToBacking:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nscontrol-convert-point-to-layer self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointToLayer:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nscontrol-convert-rect-from-view self rect view)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RP_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRect:fromView:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-convert-rect-to-view self rect view)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RP_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRect:toView:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-convert-rect-from-backing self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectFromBacking:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-convert-rect-from-layer self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectFromLayer:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-convert-rect-to-backing self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectToBacking:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-convert-rect-to-layer self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectToLayer:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-convert-size-from-view self size view)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_ZP_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSize:fromView:")) (id->ffi2-ptr size) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nscontrol-convert-size-to-view self size view)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_ZP_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSize:toView:")) (id->ffi2-ptr size) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nscontrol-convert-size-from-backing self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeFromBacking:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nscontrol-convert-size-from-layer self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeFromLayer:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nscontrol-convert-size-to-backing self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeToBacking:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nscontrol-convert-size-to-layer self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeToLayer:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nscontrol-cursor-update self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cursorUpdate:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-delete-backward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-delete-backward-by-decomposing-previous-character self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteBackwardByDecomposingPreviousCharacter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-delete-forward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-delete-to-beginning-of-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToBeginningOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-delete-to-beginning-of-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToBeginningOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-delete-to-end-of-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-delete-to-end-of-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToEndOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-delete-to-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-delete-word-backward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteWordBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-delete-word-forward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteWordForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-did-add-subview self subview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "didAddSubview:")) (id->ffi2-ptr (coerce-arg subview))))
(define (nscontrol-did-close-menu-with-event self menu event)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "didCloseMenu:withEvent:")) (id->ffi2-ptr (coerce-arg menu)) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-display! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "display"))))
(define (nscontrol-display-if-needed! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeeded"))))
(define (nscontrol-display-if-needed-ignoring-opacity! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededIgnoringOpacity"))))
(define (nscontrol-display-if-needed-in-rect! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededInRect:")) (id->ffi2-ptr rect)))
(define (nscontrol-display-if-needed-in-rect-ignoring-opacity! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededInRectIgnoringOpacity:")) (id->ffi2-ptr rect)))
(define (nscontrol-display-rect! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRect:")) (id->ffi2-ptr rect)))
(define (nscontrol-display-rect-ignoring-opacity! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRectIgnoringOpacity:")) (id->ffi2-ptr rect)))
(define (nscontrol-display-rect-ignoring-opacity-in-context! self rect context)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRectIgnoringOpacity:inContext:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg context))))
(define (nscontrol-do-command-by-selector self selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "doCommandBySelector:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nscontrol-dragging-ended self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingEnded:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-dragging-entered self sender)
  (aw_racket_msg_P_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingEntered:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-dragging-exited self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingExited:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-dragging-updated self sender)
  (aw_racket_msg_P_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingUpdated:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-draw-rect self dirty-rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawRect:")) (id->ffi2-ptr dirty-rect)))
(define (nscontrol-draw-with-expansion-frame-in-view self content-frame view)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawWithExpansionFrame:inView:")) (id->ffi2-ptr content-frame) (id->ffi2-ptr (coerce-arg view))))
(define (nscontrol-effective-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "effectiveAppearance"))))
   ))
(define (nscontrol-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nscontrol-end-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-expansion-frame-with-frame self content-frame)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "expansionFrameWithFrame:")) (id->ffi2-ptr content-frame) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-flags-changed self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flagsChanged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-flush-buffered-key-events self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flushBufferedKeyEvents"))))
(define (nscontrol-get-rects-being-drawn-count self rects count)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getRectsBeingDrawn:count:")) (id->ffi2-ptr rects) (id->ffi2-ptr count)))
(define (nscontrol-get-rects-exposed-during-live-resize-count self exposed-rects count)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getRectsExposedDuringLiveResize:count:")) (id->ffi2-ptr exposed-rects) (id->ffi2-ptr count)))
(define (nscontrol-help-requested self event-ptr)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "helpRequested:")) (id->ffi2-ptr (coerce-arg event-ptr))))
(define (nscontrol-hit-test self point)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_O_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hitTest:")) (id->ffi2-ptr point)))
   ))
(define (nscontrol-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "identifier"))))
   ))
(define (nscontrol-indent self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indent:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-insert-backtab! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertBacktab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-insert-container-break! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertContainerBreak:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-insert-double-quote-ignoring-substitution! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertDoubleQuoteIgnoringSubstitution:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-insert-line-break! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertLineBreak:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-insert-newline! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertNewline:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-insert-newline-ignoring-field-editor! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertNewlineIgnoringFieldEditor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-insert-paragraph-separator! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertParagraphSeparator:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-insert-single-quote-ignoring-substitution! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertSingleQuoteIgnoringSubstitution:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-insert-tab! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-insert-tab-ignoring-field-editor! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTabIgnoringFieldEditor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-insert-text! self insert-string)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertText:")) (id->ffi2-ptr (coerce-arg insert-string))))
(define (nscontrol-interpret-key-events self event-array)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "interpretKeyEvents:")) (id->ffi2-ptr (coerce-arg event-array))))
(define (nscontrol-is-accessibility-alternate-ui-visible self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityAlternateUIVisible"))))
(define (nscontrol-is-accessibility-disclosed self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityDisclosed"))))
(define (nscontrol-is-accessibility-edited self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEdited"))))
(define (nscontrol-is-accessibility-element self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityElement"))))
(define (nscontrol-is-accessibility-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEnabled"))))
(define (nscontrol-is-accessibility-expanded self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityExpanded"))))
(define (nscontrol-is-accessibility-focused self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFocused"))))
(define (nscontrol-is-accessibility-frontmost self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFrontmost"))))
(define (nscontrol-is-accessibility-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityHidden"))))
(define (nscontrol-is-accessibility-main self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMain"))))
(define (nscontrol-is-accessibility-minimized self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMinimized"))))
(define (nscontrol-is-accessibility-modal self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityModal"))))
(define (nscontrol-is-accessibility-ordered-by-row self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityOrderedByRow"))))
(define (nscontrol-is-accessibility-protected-content self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityProtectedContent"))))
(define (nscontrol-is-accessibility-required self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityRequired"))))
(define (nscontrol-is-accessibility-selected self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelected"))))
(define (nscontrol-is-accessibility-selector-allowed self selector)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelectorAllowed:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nscontrol-is-continuous self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isContinuous"))))
(define (nscontrol-is-descendant-of self view)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isDescendantOf:")) (id->ffi2-ptr (coerce-arg view))))
(define (nscontrol-is-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isEnabled"))))
(define (nscontrol-is-flipped self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isFlipped"))))
(define (nscontrol-is-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHidden"))))
(define (nscontrol-is-hidden-or-has-hidden-ancestor self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHiddenOrHasHiddenAncestor"))))
(define (nscontrol-is-highlighted self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHighlighted"))))
(define (nscontrol-is-opaque self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isOpaque"))))
(define (nscontrol-is-rotated-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRotatedFromBase"))))
(define (nscontrol-is-rotated-or-scaled-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRotatedOrScaledFromBase"))))
(define (nscontrol-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-key-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-layout self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layout"))))
(define (nscontrol-layout-subtree-if-needed self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutSubtreeIfNeeded"))))
(define (nscontrol-lowercase-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lowercaseWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "magnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-make-backing-layer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBackingLayer"))))
   ))
(define (nscontrol-make-base-writing-direction-left-to-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionLeftToRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-make-base-writing-direction-natural self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionNatural:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-make-base-writing-direction-right-to-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionRightToLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-make-text-writing-direction-left-to-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionLeftToRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-make-text-writing-direction-natural self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionNatural:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-make-text-writing-direction-right-to-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionRightToLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-menu-for-event self event)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menuForEvent:")) (id->ffi2-ptr (coerce-arg event))))
   ))
(define (nscontrol-mouse-in-rect self point rect)
  (aw_racket_msg_OR_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouse:inRect:")) (id->ffi2-ptr point) (id->ffi2-ptr rect)))
(define (nscontrol-mouse-cancelled self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseCancelled:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-mouse-entered self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseEntered:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-mouse-exited self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseExited:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-mouse-moved self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseMoved:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-move-backward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-down! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-down-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveDownAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-forward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-left! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-left-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveLeftAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-paragraph-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveParagraphBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-paragraph-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveParagraphForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-right! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-right-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRightAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-to-beginning-of-document! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-to-beginning-of-document-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfDocumentAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-to-beginning-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-to-beginning-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-to-beginning-of-paragraph! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfParagraphAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-to-end-of-document! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-to-end-of-document-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfDocumentAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-to-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-to-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-to-end-of-paragraph! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-to-end-of-paragraph-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfParagraphAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-to-left-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToLeftEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-to-left-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToLeftEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-to-right-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToRightEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-to-right-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToRightEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-up! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-up-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveUpAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-word-backward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-word-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-word-forward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-word-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-word-left! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-word-left-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordLeftAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-word-right! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-move-word-right-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordRightAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-needs-to-draw-rect self rect)
  (aw_racket_msg_R_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsToDrawRect:")) (id->ffi2-ptr rect)))
(define (nscontrol-no-responder-for self event-selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "noResponderFor:")) (id->ffi2-ptr (sel_registerName event-selector))))
(define (nscontrol-other-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-other-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-other-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-page-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-page-down-and-modify-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageDownAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-page-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-page-up-and-modify-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageUpAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-perform-click! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performClick:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-perform-drag-operation! self sender)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-perform-key-equivalent! self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performKeyEquivalent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-prepare-content-in-rect self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareContentInRect:")) (id->ffi2-ptr rect)))
(define (nscontrol-prepare-for-drag-operation self sender)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareForDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-prepare-for-reuse self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareForReuse"))))
(define (nscontrol-pressure-change-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pressureChangeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-quick-look-preview-items self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookPreviewItems:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-quick-look-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-rect-for-smart-magnification-at-point-in-rect self location visible-rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_OR_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectForSmartMagnificationAtPoint:inRect:")) (id->ffi2-ptr location) (id->ffi2-ptr visible-rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nscontrol-remove-all-tool-tips! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeAllToolTips"))))
(define (nscontrol-remove-from-superview! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeFromSuperview"))))
(define (nscontrol-remove-from-superview-without-needing-display! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeFromSuperviewWithoutNeedingDisplay"))))
(define (nscontrol-remove-tool-tip! self tag)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeToolTip:")) tag))
(define (nscontrol-replace-subview-with! self old-view new-view)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "replaceSubview:with:")) (id->ffi2-ptr (coerce-arg old-view)) (id->ffi2-ptr (coerce-arg new-view))))
(define (nscontrol-resign-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resignFirstResponder"))))
(define (nscontrol-resize-subviews-with-old-size self old-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resizeSubviewsWithOldSize:")) (id->ffi2-ptr old-size)))
(define (nscontrol-resize-with-old-superview-size self old-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resizeWithOldSuperviewSize:")) (id->ffi2-ptr old-size)))
(define (nscontrol-restore-user-activity-state self user-activity)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "restoreUserActivityState:")) (id->ffi2-ptr (coerce-arg user-activity))))
(define (nscontrol-right-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-right-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-right-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-rotate-by-angle self angle)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotateByAngle:")) angle))
(define (nscontrol-rotate-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotateWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-scale-unit-square-to-size self new-unit-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scaleUnitSquareToSize:")) (id->ffi2-ptr new-unit-size)))
(define (nscontrol-scroll-line-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollLineDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-scroll-line-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollLineUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-scroll-page-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPageDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-scroll-page-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPageUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-scroll-point self point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPoint:")) (id->ffi2-ptr point)))
(define (nscontrol-scroll-rect-to-visible self rect)
  (aw_racket_msg_R_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollRectToVisible:")) (id->ffi2-ptr rect)))
(define (nscontrol-scroll-to-beginning-of-document self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollToBeginningOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-scroll-to-end-of-document self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollToEndOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-scroll-wheel self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollWheel:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-select-all self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectAll:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-select-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-select-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-select-to-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectToMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-select-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-send-action-to self action target)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sendAction:to:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg target))))
(define (nscontrol-send-action-on self mask)
  (aw_racket_msg_Q_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sendActionOn:")) mask))
(define (nscontrol-set-accessibility-activation-point! self accessibility-activation-point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityActivationPoint:")) (id->ffi2-ptr accessibility-activation-point)))
(define (nscontrol-set-accessibility-allowed-values! self accessibility-allowed-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAllowedValues:")) (id->ffi2-ptr (coerce-arg accessibility-allowed-values))))
(define (nscontrol-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAlternateUIVisible:")) accessibility-alternate-ui-visible))
(define (nscontrol-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityApplicationFocusedUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-application-focused-ui-element))))
(define (nscontrol-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAttributedUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-attributed-user-input-labels))))
(define (nscontrol-set-accessibility-cancel-button! self accessibility-cancel-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCancelButton:")) (id->ffi2-ptr (coerce-arg accessibility-cancel-button))))
(define (nscontrol-set-accessibility-children! self accessibility-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildren:")) (id->ffi2-ptr (coerce-arg accessibility-children))))
(define (nscontrol-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildrenInNavigationOrder:")) (id->ffi2-ptr (coerce-arg accessibility-children-in-navigation-order))))
(define (nscontrol-set-accessibility-clear-button! self accessibility-clear-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityClearButton:")) (id->ffi2-ptr (coerce-arg accessibility-clear-button))))
(define (nscontrol-set-accessibility-close-button! self accessibility-close-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCloseButton:")) (id->ffi2-ptr (coerce-arg accessibility-close-button))))
(define (nscontrol-set-accessibility-column-count! self accessibility-column-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnCount:")) accessibility-column-count))
(define (nscontrol-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-column-header-ui-elements))))
(define (nscontrol-set-accessibility-column-index-range! self accessibility-column-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnIndexRange:")) (id->ffi2-ptr accessibility-column-index-range)))
(define (nscontrol-set-accessibility-column-titles! self accessibility-column-titles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnTitles:")) (id->ffi2-ptr (coerce-arg accessibility-column-titles))))
(define (nscontrol-set-accessibility-columns! self accessibility-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumns:")) (id->ffi2-ptr (coerce-arg accessibility-columns))))
(define (nscontrol-set-accessibility-contents! self accessibility-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityContents:")) (id->ffi2-ptr (coerce-arg accessibility-contents))))
(define (nscontrol-set-accessibility-critical-value! self accessibility-critical-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCriticalValue:")) (id->ffi2-ptr (coerce-arg accessibility-critical-value))))
(define (nscontrol-set-accessibility-custom-actions! self accessibility-custom-actions)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomActions:")) (id->ffi2-ptr (coerce-arg accessibility-custom-actions))))
(define (nscontrol-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomRotors:")) (id->ffi2-ptr (coerce-arg accessibility-custom-rotors))))
(define (nscontrol-set-accessibility-decrement-button! self accessibility-decrement-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDecrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-decrement-button))))
(define (nscontrol-set-accessibility-default-button! self accessibility-default-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDefaultButton:")) (id->ffi2-ptr (coerce-arg accessibility-default-button))))
(define (nscontrol-set-accessibility-disclosed! self accessibility-disclosed)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosed:")) accessibility-disclosed))
(define (nscontrol-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedByRow:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-by-row))))
(define (nscontrol-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedRows:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-rows))))
(define (nscontrol-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosureLevel:")) accessibility-disclosure-level))
(define (nscontrol-set-accessibility-document! self accessibility-document)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDocument:")) (id->ffi2-ptr (coerce-arg accessibility-document))))
(define (nscontrol-set-accessibility-edited! self accessibility-edited)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEdited:")) accessibility-edited))
(define (nscontrol-set-accessibility-element! self accessibility-element)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityElement:")) accessibility-element))
(define (nscontrol-set-accessibility-enabled! self accessibility-enabled)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEnabled:")) accessibility-enabled))
(define (nscontrol-set-accessibility-expanded! self accessibility-expanded)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExpanded:")) accessibility-expanded))
(define (nscontrol-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExtrasMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-extras-menu-bar))))
(define (nscontrol-set-accessibility-filename! self accessibility-filename)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFilename:")) (id->ffi2-ptr (coerce-arg accessibility-filename))))
(define (nscontrol-set-accessibility-focused! self accessibility-focused)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocused:")) accessibility-focused))
(define (nscontrol-set-accessibility-focused-window! self accessibility-focused-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocusedWindow:")) (id->ffi2-ptr (coerce-arg accessibility-focused-window))))
(define (nscontrol-set-accessibility-frame! self accessibility-frame)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrame:")) (id->ffi2-ptr accessibility-frame)))
(define (nscontrol-set-accessibility-frontmost! self accessibility-frontmost)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrontmost:")) accessibility-frontmost))
(define (nscontrol-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFullScreenButton:")) (id->ffi2-ptr (coerce-arg accessibility-full-screen-button))))
(define (nscontrol-set-accessibility-grow-area! self accessibility-grow-area)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityGrowArea:")) (id->ffi2-ptr (coerce-arg accessibility-grow-area))))
(define (nscontrol-set-accessibility-handles! self accessibility-handles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHandles:")) (id->ffi2-ptr (coerce-arg accessibility-handles))))
(define (nscontrol-set-accessibility-header! self accessibility-header)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHeader:")) (id->ffi2-ptr (coerce-arg accessibility-header))))
(define (nscontrol-set-accessibility-help! self accessibility-help)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHelp:")) (id->ffi2-ptr (coerce-arg accessibility-help))))
(define (nscontrol-set-accessibility-hidden! self accessibility-hidden)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHidden:")) accessibility-hidden))
(define (nscontrol-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-scroll-bar))))
(define (nscontrol-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-unit-description))))
(define (nscontrol-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnits:")) accessibility-horizontal-units))
(define (nscontrol-set-accessibility-identifier! self accessibility-identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIdentifier:")) (id->ffi2-ptr (coerce-arg accessibility-identifier))))
(define (nscontrol-set-accessibility-increment-button! self accessibility-increment-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIncrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-increment-button))))
(define (nscontrol-set-accessibility-index! self accessibility-index)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIndex:")) accessibility-index))
(define (nscontrol-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityInsertionPointLineNumber:")) accessibility-insertion-point-line-number))
(define (nscontrol-set-accessibility-label! self accessibility-label)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabel:")) (id->ffi2-ptr (coerce-arg accessibility-label))))
(define (nscontrol-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-label-ui-elements))))
(define (nscontrol-set-accessibility-label-value! self accessibility-label-value)
  (aw_racket_msg_f_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelValue:")) accessibility-label-value))
(define (nscontrol-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLinkedUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-linked-ui-elements))))
(define (nscontrol-set-accessibility-main! self accessibility-main)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMain:")) accessibility-main))
(define (nscontrol-set-accessibility-main-window! self accessibility-main-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMainWindow:")) (id->ffi2-ptr (coerce-arg accessibility-main-window))))
(define (nscontrol-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerGroupUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-marker-group-ui-element))))
(define (nscontrol-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerTypeDescription:")) (id->ffi2-ptr (coerce-arg accessibility-marker-type-description))))
(define (nscontrol-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-marker-ui-elements))))
(define (nscontrol-set-accessibility-marker-values! self accessibility-marker-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerValues:")) (id->ffi2-ptr (coerce-arg accessibility-marker-values))))
(define (nscontrol-set-accessibility-max-value! self accessibility-max-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMaxValue:")) (id->ffi2-ptr (coerce-arg accessibility-max-value))))
(define (nscontrol-set-accessibility-menu-bar! self accessibility-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-menu-bar))))
(define (nscontrol-set-accessibility-min-value! self accessibility-min-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinValue:")) (id->ffi2-ptr (coerce-arg accessibility-min-value))))
(define (nscontrol-set-accessibility-minimize-button! self accessibility-minimize-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimizeButton:")) (id->ffi2-ptr (coerce-arg accessibility-minimize-button))))
(define (nscontrol-set-accessibility-minimized! self accessibility-minimized)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimized:")) accessibility-minimized))
(define (nscontrol-set-accessibility-modal! self accessibility-modal)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityModal:")) accessibility-modal))
(define (nscontrol-set-accessibility-next-contents! self accessibility-next-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNextContents:")) (id->ffi2-ptr (coerce-arg accessibility-next-contents))))
(define (nscontrol-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNumberOfCharacters:")) accessibility-number-of-characters))
(define (nscontrol-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrderedByRow:")) accessibility-ordered-by-row))
(define (nscontrol-set-accessibility-orientation! self accessibility-orientation)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrientation:")) accessibility-orientation))
(define (nscontrol-set-accessibility-overflow-button! self accessibility-overflow-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOverflowButton:")) (id->ffi2-ptr (coerce-arg accessibility-overflow-button))))
(define (nscontrol-set-accessibility-parent! self accessibility-parent)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityParent:")) (id->ffi2-ptr (coerce-arg accessibility-parent))))
(define (nscontrol-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPlaceholderValue:")) (id->ffi2-ptr (coerce-arg accessibility-placeholder-value))))
(define (nscontrol-set-accessibility-previous-contents! self accessibility-previous-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPreviousContents:")) (id->ffi2-ptr (coerce-arg accessibility-previous-contents))))
(define (nscontrol-set-accessibility-protected-content! self accessibility-protected-content)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProtectedContent:")) accessibility-protected-content))
(define (nscontrol-set-accessibility-proxy! self accessibility-proxy)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProxy:")) (id->ffi2-ptr (coerce-arg accessibility-proxy))))
(define (nscontrol-set-accessibility-required! self accessibility-required)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRequired:")) accessibility-required))
(define (nscontrol-set-accessibility-role! self accessibility-role)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRole:")) (id->ffi2-ptr (coerce-arg accessibility-role))))
(define (nscontrol-set-accessibility-role-description! self accessibility-role-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRoleDescription:")) (id->ffi2-ptr (coerce-arg accessibility-role-description))))
(define (nscontrol-set-accessibility-row-count! self accessibility-row-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowCount:")) accessibility-row-count))
(define (nscontrol-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-row-header-ui-elements))))
(define (nscontrol-set-accessibility-row-index-range! self accessibility-row-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowIndexRange:")) (id->ffi2-ptr accessibility-row-index-range)))
(define (nscontrol-set-accessibility-rows! self accessibility-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRows:")) (id->ffi2-ptr (coerce-arg accessibility-rows))))
(define (nscontrol-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRulerMarkerType:")) accessibility-ruler-marker-type))
(define (nscontrol-set-accessibility-search-button! self accessibility-search-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchButton:")) (id->ffi2-ptr (coerce-arg accessibility-search-button))))
(define (nscontrol-set-accessibility-search-menu! self accessibility-search-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchMenu:")) (id->ffi2-ptr (coerce-arg accessibility-search-menu))))
(define (nscontrol-set-accessibility-selected! self accessibility-selected)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelected:")) accessibility-selected))
(define (nscontrol-set-accessibility-selected-cells! self accessibility-selected-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedCells:")) (id->ffi2-ptr (coerce-arg accessibility-selected-cells))))
(define (nscontrol-set-accessibility-selected-children! self accessibility-selected-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedChildren:")) (id->ffi2-ptr (coerce-arg accessibility-selected-children))))
(define (nscontrol-set-accessibility-selected-columns! self accessibility-selected-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedColumns:")) (id->ffi2-ptr (coerce-arg accessibility-selected-columns))))
(define (nscontrol-set-accessibility-selected-rows! self accessibility-selected-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedRows:")) (id->ffi2-ptr (coerce-arg accessibility-selected-rows))))
(define (nscontrol-set-accessibility-selected-text! self accessibility-selected-text)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedText:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text))))
(define (nscontrol-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRange:")) (id->ffi2-ptr accessibility-selected-text-range)))
(define (nscontrol-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRanges:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text-ranges))))
(define (nscontrol-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityServesAsTitleForUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-serves-as-title-for-ui-elements))))
(define (nscontrol-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedCharacterRange:")) (id->ffi2-ptr accessibility-shared-character-range)))
(define (nscontrol-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedFocusElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-focus-elements))))
(define (nscontrol-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedTextUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-text-ui-elements))))
(define (nscontrol-set-accessibility-shown-menu! self accessibility-shown-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityShownMenu:")) (id->ffi2-ptr (coerce-arg accessibility-shown-menu))))
(define (nscontrol-set-accessibility-sort-direction! self accessibility-sort-direction)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySortDirection:")) accessibility-sort-direction))
(define (nscontrol-set-accessibility-splitters! self accessibility-splitters)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySplitters:")) (id->ffi2-ptr (coerce-arg accessibility-splitters))))
(define (nscontrol-set-accessibility-subrole! self accessibility-subrole)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySubrole:")) (id->ffi2-ptr (coerce-arg accessibility-subrole))))
(define (nscontrol-set-accessibility-tabs! self accessibility-tabs)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTabs:")) (id->ffi2-ptr (coerce-arg accessibility-tabs))))
(define (nscontrol-set-accessibility-title! self accessibility-title)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitle:")) (id->ffi2-ptr (coerce-arg accessibility-title))))
(define (nscontrol-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitleUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-title-ui-element))))
(define (nscontrol-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityToolbarButton:")) (id->ffi2-ptr (coerce-arg accessibility-toolbar-button))))
(define (nscontrol-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTopLevelUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-top-level-ui-element))))
(define (nscontrol-set-accessibility-url! self accessibility-url)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityURL:")) (id->ffi2-ptr (coerce-arg accessibility-url))))
(define (nscontrol-set-accessibility-unit-description! self accessibility-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-unit-description))))
(define (nscontrol-set-accessibility-units! self accessibility-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnits:")) accessibility-units))
(define (nscontrol-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-user-input-labels))))
(define (nscontrol-set-accessibility-value! self accessibility-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValue:")) (id->ffi2-ptr (coerce-arg accessibility-value))))
(define (nscontrol-set-accessibility-value-description! self accessibility-value-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValueDescription:")) (id->ffi2-ptr (coerce-arg accessibility-value-description))))
(define (nscontrol-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-scroll-bar))))
(define (nscontrol-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-unit-description))))
(define (nscontrol-set-accessibility-vertical-units! self accessibility-vertical-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnits:")) accessibility-vertical-units))
(define (nscontrol-set-accessibility-visible-cells! self accessibility-visible-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCells:")) (id->ffi2-ptr (coerce-arg accessibility-visible-cells))))
(define (nscontrol-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCharacterRange:")) (id->ffi2-ptr accessibility-visible-character-range)))
(define (nscontrol-set-accessibility-visible-children! self accessibility-visible-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleChildren:")) (id->ffi2-ptr (coerce-arg accessibility-visible-children))))
(define (nscontrol-set-accessibility-visible-columns! self accessibility-visible-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleColumns:")) (id->ffi2-ptr (coerce-arg accessibility-visible-columns))))
(define (nscontrol-set-accessibility-visible-rows! self accessibility-visible-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleRows:")) (id->ffi2-ptr (coerce-arg accessibility-visible-rows))))
(define (nscontrol-set-accessibility-warning-value! self accessibility-warning-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWarningValue:")) (id->ffi2-ptr (coerce-arg accessibility-warning-value))))
(define (nscontrol-set-accessibility-window! self accessibility-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindow:")) (id->ffi2-ptr (coerce-arg accessibility-window))))
(define (nscontrol-set-accessibility-windows! self accessibility-windows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindows:")) (id->ffi2-ptr (coerce-arg accessibility-windows))))
(define (nscontrol-set-accessibility-zoom-button! self accessibility-zoom-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityZoomButton:")) (id->ffi2-ptr (coerce-arg accessibility-zoom-button))))
(define (nscontrol-set-animations! self animations)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAnimations:")) (id->ffi2-ptr (coerce-arg animations))))
(define (nscontrol-set-appearance! self appearance)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAppearance:")) (id->ffi2-ptr (coerce-arg appearance))))
(define (nscontrol-set-bounds-origin! self new-origin)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsOrigin:")) (id->ffi2-ptr new-origin)))
(define (nscontrol-set-bounds-size! self new-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsSize:")) (id->ffi2-ptr new-size)))
(define (nscontrol-set-frame-origin! self new-origin)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameOrigin:")) (id->ffi2-ptr new-origin)))
(define (nscontrol-set-frame-size! self new-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameSize:")) (id->ffi2-ptr new-size)))
(define (nscontrol-set-identifier! self identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIdentifier:")) (id->ffi2-ptr (coerce-arg identifier))))
(define (nscontrol-set-mark! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-set-needs-display-in-rect! self invalid-rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsDisplayInRect:")) (id->ffi2-ptr invalid-rect)))
(define (nscontrol-should-be-treated-as-ink-event self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldBeTreatedAsInkEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-should-delay-window-ordering-for-event self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldDelayWindowOrderingForEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-show-context-help self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextHelp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-show-context-menu-for-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextMenuForSelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-size-that-fits self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sizeThatFits:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nscontrol-size-to-fit self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sizeToFit"))))
(define (nscontrol-smart-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "smartMagnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-sort-subviews-using-function-context self compare context)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sortSubviewsUsingFunction:context:")) (id->ffi2-ptr compare) (id->ffi2-ptr context)))
(define (nscontrol-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "supplementalTargetForAction:sender:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg sender))))
   ))
(define (nscontrol-swap-with-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swapWithMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-swipe-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swipeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-tablet-point self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletPoint:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-tablet-proximity self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletProximity:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-take-double-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeDoubleValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-take-float-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeFloatValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-take-int-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeIntValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-take-integer-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeIntegerValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-take-object-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeObjectValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-take-string-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeStringValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-touches-began-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesBeganWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-touches-cancelled-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesCancelledWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-touches-ended-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesEndedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-touches-moved-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesMovedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-translate-origin-to-point self translation)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translateOriginToPoint:")) (id->ffi2-ptr translation)))
(define (nscontrol-translate-rects-needing-display-in-rect-by self clip-rect delta)
  (aw_racket_msg_RZ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translateRectsNeedingDisplayInRect:by:")) (id->ffi2-ptr clip-rect) (id->ffi2-ptr delta)))
(define (nscontrol-transpose self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transpose:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-transpose-words self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transposeWords:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-try-to-perform-with self action object)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tryToPerform:with:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg object))))
(define (nscontrol-update-dragging-items-for-drag self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateDraggingItemsForDrag:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-update-layer self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateLayer"))))
(define (nscontrol-uppercase-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "uppercaseWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nscontrol-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validRequestorForSendType:returnType:")) (id->ffi2-ptr (coerce-arg send-type)) (id->ffi2-ptr (coerce-arg return-type))))
   ))
(define (nscontrol-view-did-change-backing-properties self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidChangeBackingProperties"))))
(define (nscontrol-view-did-change-effective-appearance self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidChangeEffectiveAppearance"))))
(define (nscontrol-view-did-end-live-resize self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidEndLiveResize"))))
(define (nscontrol-view-did-hide self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidHide"))))
(define (nscontrol-view-did-move-to-superview self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidMoveToSuperview"))))
(define (nscontrol-view-did-move-to-window self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidMoveToWindow"))))
(define (nscontrol-view-did-unhide self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidUnhide"))))
(define (nscontrol-view-will-draw self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillDraw"))))
(define (nscontrol-view-will-move-to-superview self new-superview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillMoveToSuperview:")) (id->ffi2-ptr (coerce-arg new-superview))))
(define (nscontrol-view-will-move-to-window self new-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillMoveToWindow:")) (id->ffi2-ptr (coerce-arg new-window))))
(define (nscontrol-view-will-start-live-resize self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillStartLiveResize"))))
(define (nscontrol-view-with-tag self tag)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWithTag:")) tag))
   ))
(define (nscontrol-wants-forwarded-scroll-events-for-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsForwardedScrollEventsForAxis:")) axis))
(define (nscontrol-wants-periodic-dragging-updates self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsPeriodicDraggingUpdates"))))
(define (nscontrol-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:")) axis))
(define (nscontrol-will-open-menu-with-event self menu event)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "willOpenMenu:withEvent:")) (id->ffi2-ptr (coerce-arg menu)) (id->ffi2-ptr (coerce-arg event))))
(define (nscontrol-will-remove-subview self subview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "willRemoveSubview:")) (id->ffi2-ptr (coerce-arg subview))))
(define (nscontrol-yank self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "yank:")) (id->ffi2-ptr (coerce-arg sender))))

;; --- Class methods ---
(define (nscontrol-default-animation-for-key key)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSControl) (id->ffi2-ptr (sel_registerName "defaultAnimationForKey:")) (id->ffi2-ptr (coerce-arg key))))
   ))
(define (nscontrol-is-compatible-with-responsive-scrolling)
  (aw_racket_msg_0_b (id->ffi2-ptr NSControl) (id->ffi2-ptr (sel_registerName "isCompatibleWithResponsiveScrolling"))))
