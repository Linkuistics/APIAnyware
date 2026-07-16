#lang racket/base
;; Generated binding for NSView (AppKit)
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

;; Threading: this class has main-thread-only methods.

;; --- Class predicates ---
(define (cadisplaylink? v) (objc-instance-of? v "CADisplayLink"))
(define (calayer? v) (objc-instance-of? v "CALayer"))
(define (cifilter? v) (objc-instance-of? v "CIFilter"))
(define (nsappearance? v) (objc-instance-of? v "NSAppearance"))
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsattributedstring? v) (objc-instance-of? v "NSAttributedString"))
(define (nsbitmapimagerep? v) (objc-instance-of? v "NSBitmapImageRep"))
(define (nscandidatelisttouchbaritem? v) (objc-instance-of? v "NSCandidateListTouchBarItem"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsdictionary? v) (objc-instance-of? v "NSDictionary"))
(define (nsdraggingsession? v) (objc-instance-of? v "NSDraggingSession"))
(define (nserror? v) (objc-instance-of? v "NSError"))
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
(provide NSView)
(provide/contract
  [make-nsview-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsview-init-with-frame (c-> any/c any/c)]
  [nsview-accepts-first-responder (c-> nsview? boolean?)]
  [nsview-accepts-touch-events (c-> nsview? boolean?)]
  [nsview-set-accepts-touch-events! (c-> nsview? boolean? void?)]
  [nsview-additional-safe-area-insets (c-> nsview? any/c)]
  [nsview-set-additional-safe-area-insets! (c-> nsview? any/c void?)]
  [nsview-alignment-rect-insets (c-> nsview? any/c)]
  [nsview-allowed-touch-types (c-> nsview? exact-nonnegative-integer?)]
  [nsview-set-allowed-touch-types! (c-> nsview? exact-nonnegative-integer? void?)]
  [nsview-allows-vibrancy (c-> nsview? boolean?)]
  [nsview-alpha-value (c-> nsview? real?)]
  [nsview-set-alpha-value! (c-> nsview? real? void?)]
  [nsview-autoresizes-subviews (c-> nsview? boolean?)]
  [nsview-set-autoresizes-subviews! (c-> nsview? boolean? void?)]
  [nsview-autoresizing-mask (c-> nsview? exact-nonnegative-integer?)]
  [nsview-set-autoresizing-mask! (c-> nsview? exact-nonnegative-integer? void?)]
  [nsview-background-filters (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-set-background-filters! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-baseline-offset-from-bottom (c-> nsview? real?)]
  [nsview-bottom-anchor (c-> nsview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsview-bounds (c-> nsview? any/c)]
  [nsview-set-bounds! (c-> nsview? any/c void?)]
  [nsview-bounds-rotation (c-> nsview? real?)]
  [nsview-set-bounds-rotation! (c-> nsview? real? void?)]
  [nsview-can-become-key-view (c-> nsview? boolean?)]
  [nsview-can-draw (c-> nsview? boolean?)]
  [nsview-can-draw-concurrently (c-> nsview? boolean?)]
  [nsview-set-can-draw-concurrently! (c-> nsview? boolean? void?)]
  [nsview-can-draw-subviews-into-layer (c-> nsview? boolean?)]
  [nsview-set-can-draw-subviews-into-layer! (c-> nsview? boolean? void?)]
  [nsview-candidate-list-touch-bar-item (c-> nsview? (or/c nscandidatelisttouchbaritem? objc-nil?))]
  [nsview-center-x-anchor (c-> nsview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsview-center-y-anchor (c-> nsview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsview-clips-to-bounds (c-> nsview? boolean?)]
  [nsview-set-clips-to-bounds! (c-> nsview? boolean? void?)]
  [nsview-compatible-with-responsive-scrolling (c-> boolean?)]
  [nsview-compositing-filter (c-> nsview? (or/c cifilter? objc-nil?))]
  [nsview-set-compositing-filter! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-constraints (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-content-filters (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-set-content-filters! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-default-focus-ring-type (c-> exact-nonnegative-integer?)]
  [nsview-default-menu (c-> (or/c nsmenu? objc-nil?))]
  [nsview-drawing-find-indicator (c-> nsview? boolean?)]
  [nsview-enclosing-menu-item (c-> nsview? (or/c nsmenuitem? objc-nil?))]
  [nsview-enclosing-scroll-view (c-> nsview? (or/c nsscrollview? objc-nil?))]
  [nsview-first-baseline-anchor (c-> nsview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsview-first-baseline-offset-from-top (c-> nsview? real?)]
  [nsview-fitting-size (c-> nsview? any/c)]
  [nsview-flipped (c-> nsview? boolean?)]
  [nsview-focus-ring-mask-bounds (c-> nsview? any/c)]
  [nsview-focus-ring-type (c-> nsview? exact-nonnegative-integer?)]
  [nsview-set-focus-ring-type! (c-> nsview? exact-nonnegative-integer? void?)]
  [nsview-focus-view (c-> (or/c nsview? objc-nil?))]
  [nsview-frame (c-> nsview? any/c)]
  [nsview-set-frame! (c-> nsview? any/c void?)]
  [nsview-frame-center-rotation (c-> nsview? real?)]
  [nsview-set-frame-center-rotation! (c-> nsview? real? void?)]
  [nsview-frame-rotation (c-> nsview? real?)]
  [nsview-set-frame-rotation! (c-> nsview? real? void?)]
  [nsview-gesture-recognizers (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-set-gesture-recognizers! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-has-ambiguous-layout (c-> nsview? boolean?)]
  [nsview-height-adjust-limit (c-> nsview? real?)]
  [nsview-height-anchor (c-> nsview? (or/c nslayoutdimension? objc-nil?))]
  [nsview-hidden (c-> nsview? boolean?)]
  [nsview-set-hidden! (c-> nsview? boolean? void?)]
  [nsview-hidden-or-has-hidden-ancestor (c-> nsview? boolean?)]
  [nsview-horizontal-content-size-constraint-active (c-> nsview? boolean?)]
  [nsview-set-horizontal-content-size-constraint-active! (c-> nsview? boolean? void?)]
  [nsview-in-full-screen-mode (c-> nsview? boolean?)]
  [nsview-in-live-resize (c-> nsview? boolean?)]
  [nsview-input-context (c-> nsview? (or/c nstextinputcontext? objc-nil?))]
  [nsview-intrinsic-content-size (c-> nsview? any/c)]
  [nsview-last-baseline-anchor (c-> nsview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsview-last-baseline-offset-from-bottom (c-> nsview? real?)]
  [nsview-layer (c-> nsview? (or/c calayer? objc-nil?))]
  [nsview-set-layer! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-layer-contents-placement (c-> nsview? exact-integer?)]
  [nsview-set-layer-contents-placement! (c-> nsview? exact-integer? void?)]
  [nsview-layer-contents-redraw-policy (c-> nsview? exact-integer?)]
  [nsview-set-layer-contents-redraw-policy! (c-> nsview? exact-integer? void?)]
  [nsview-layer-uses-core-image-filters (c-> nsview? boolean?)]
  [nsview-set-layer-uses-core-image-filters! (c-> nsview? boolean? void?)]
  [nsview-layout-guides (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-layout-margins-guide (c-> nsview? (or/c nslayoutguide? objc-nil?))]
  [nsview-leading-anchor (c-> nsview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsview-left-anchor (c-> nsview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsview-menu (c-> nsview? (or/c nsmenu? objc-nil?))]
  [nsview-set-menu! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-mouse-down-can-move-window (c-> nsview? boolean?)]
  [nsview-needs-display (c-> nsview? boolean?)]
  [nsview-set-needs-display! (c-> nsview? boolean? void?)]
  [nsview-needs-layout (c-> nsview? boolean?)]
  [nsview-set-needs-layout! (c-> nsview? boolean? void?)]
  [nsview-needs-panel-to-become-key (c-> nsview? boolean?)]
  [nsview-needs-update-constraints (c-> nsview? boolean?)]
  [nsview-set-needs-update-constraints! (c-> nsview? boolean? void?)]
  [nsview-next-key-view (c-> nsview? (or/c nsview? objc-nil?))]
  [nsview-set-next-key-view! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-next-responder (c-> nsview? (or/c nsresponder? objc-nil?))]
  [nsview-set-next-responder! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-next-valid-key-view (c-> nsview? (or/c nsview? objc-nil?))]
  [nsview-opaque (c-> nsview? boolean?)]
  [nsview-opaque-ancestor (c-> nsview? (or/c nsview? objc-nil?))]
  [nsview-page-footer (c-> nsview? (or/c nsattributedstring? objc-nil?))]
  [nsview-page-header (c-> nsview? (or/c nsattributedstring? objc-nil?))]
  [nsview-posts-bounds-changed-notifications (c-> nsview? boolean?)]
  [nsview-set-posts-bounds-changed-notifications! (c-> nsview? boolean? void?)]
  [nsview-posts-frame-changed-notifications (c-> nsview? boolean?)]
  [nsview-set-posts-frame-changed-notifications! (c-> nsview? boolean? void?)]
  [nsview-prefers-compact-control-size-metrics (c-> nsview? boolean?)]
  [nsview-set-prefers-compact-control-size-metrics! (c-> nsview? boolean? void?)]
  [nsview-prepared-content-rect (c-> nsview? any/c)]
  [nsview-set-prepared-content-rect! (c-> nsview? any/c void?)]
  [nsview-preserves-content-during-live-resize (c-> nsview? boolean?)]
  [nsview-pressure-configuration (c-> nsview? (or/c nspressureconfiguration? objc-nil?))]
  [nsview-set-pressure-configuration! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-previous-key-view (c-> nsview? (or/c nsview? objc-nil?))]
  [nsview-previous-valid-key-view (c-> nsview? (or/c nsview? objc-nil?))]
  [nsview-print-job-title (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-rect-preserved-during-live-resize (c-> nsview? any/c)]
  [nsview-registered-dragged-types (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-requires-constraint-based-layout (c-> boolean?)]
  [nsview-restorable-state-key-paths (c-> (or/c nsarray? objc-nil?))]
  [nsview-right-anchor (c-> nsview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsview-rotated-from-base (c-> nsview? boolean?)]
  [nsview-rotated-or-scaled-from-base (c-> nsview? boolean?)]
  [nsview-safe-area-insets (c-> nsview? any/c)]
  [nsview-safe-area-layout-guide (c-> nsview? (or/c nslayoutguide? objc-nil?))]
  [nsview-safe-area-rect (c-> nsview? any/c)]
  [nsview-shadow (c-> nsview? (or/c nsshadow? objc-nil?))]
  [nsview-set-shadow! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-subviews (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-set-subviews! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-superview (c-> nsview? (or/c nsview? objc-nil?))]
  [nsview-tag (c-> nsview? exact-integer?)]
  [nsview-tool-tip (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-set-tool-tip! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-top-anchor (c-> nsview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsview-touch-bar (c-> nsview? (or/c nstouchbar? objc-nil?))]
  [nsview-set-touch-bar! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-tracking-areas (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-trailing-anchor (c-> nsview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsview-translates-autoresizing-mask-into-constraints (c-> nsview? boolean?)]
  [nsview-set-translates-autoresizing-mask-into-constraints! (c-> nsview? boolean? void?)]
  [nsview-undo-manager (c-> nsview? (or/c nsundomanager? objc-nil?))]
  [nsview-user-activity (c-> nsview? (or/c nsuseractivity? objc-nil?))]
  [nsview-set-user-activity! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-user-interface-layout-direction (c-> nsview? exact-integer?)]
  [nsview-set-user-interface-layout-direction! (c-> nsview? exact-integer? void?)]
  [nsview-vertical-content-size-constraint-active (c-> nsview? boolean?)]
  [nsview-set-vertical-content-size-constraint-active! (c-> nsview? boolean? void?)]
  [nsview-visible-rect (c-> nsview? any/c)]
  [nsview-wants-best-resolution-open-gl-surface (c-> nsview? boolean?)]
  [nsview-set-wants-best-resolution-open-gl-surface! (c-> nsview? boolean? void?)]
  [nsview-wants-default-clipping (c-> nsview? boolean?)]
  [nsview-wants-extended-dynamic-range-open-gl-surface (c-> nsview? boolean?)]
  [nsview-set-wants-extended-dynamic-range-open-gl-surface! (c-> nsview? boolean? void?)]
  [nsview-wants-layer (c-> nsview? boolean?)]
  [nsview-set-wants-layer! (c-> nsview? boolean? void?)]
  [nsview-wants-resting-touches (c-> nsview? boolean?)]
  [nsview-set-wants-resting-touches! (c-> nsview? boolean? void?)]
  [nsview-wants-update-layer (c-> nsview? boolean?)]
  [nsview-width-adjust-limit (c-> nsview? real?)]
  [nsview-width-anchor (c-> nsview? (or/c nslayoutdimension? objc-nil?))]
  [nsview-window (c-> nsview? (or/c nswindow? objc-nil?))]
  [nsview-writing-tools-coordinator (c-> nsview? (or/c nswritingtoolscoordinator? objc-nil?))]
  [nsview-set-writing-tools-coordinator! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-accepts-first-mouse (c-> nsview? (or/c string? objc-object? #f) boolean?)]
  [nsview-accessibility-activation-point (c-> nsview? any/c)]
  [nsview-accessibility-allowed-values (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-application-focused-ui-element (c-> nsview? any/c)]
  [nsview-accessibility-attributed-string-for-range (c-> nsview? any/c (or/c nsattributedstring? objc-nil?))]
  [nsview-accessibility-attributed-user-input-labels (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-cancel-button (c-> nsview? any/c)]
  [nsview-accessibility-cell-for-column-row (c-> nsview? exact-integer? exact-integer? any/c)]
  [nsview-accessibility-children (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-children-in-navigation-order (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-clear-button (c-> nsview? any/c)]
  [nsview-accessibility-close-button (c-> nsview? any/c)]
  [nsview-accessibility-column-count (c-> nsview? exact-integer?)]
  [nsview-accessibility-column-header-ui-elements (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-column-index-range (c-> nsview? any/c)]
  [nsview-accessibility-column-titles (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-columns (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-contents (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-critical-value (c-> nsview? any/c)]
  [nsview-accessibility-custom-actions (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-custom-rotors (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-decrement-button (c-> nsview? any/c)]
  [nsview-accessibility-default-button (c-> nsview? any/c)]
  [nsview-accessibility-disclosed-by-row (c-> nsview? any/c)]
  [nsview-accessibility-disclosed-rows (c-> nsview? any/c)]
  [nsview-accessibility-disclosure-level (c-> nsview? exact-integer?)]
  [nsview-accessibility-document (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-accessibility-extras-menu-bar (c-> nsview? any/c)]
  [nsview-accessibility-filename (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-accessibility-focused-window (c-> nsview? any/c)]
  [nsview-accessibility-frame (c-> nsview? any/c)]
  [nsview-accessibility-frame-for-range (c-> nsview? any/c any/c)]
  [nsview-accessibility-full-screen-button (c-> nsview? any/c)]
  [nsview-accessibility-grow-area (c-> nsview? any/c)]
  [nsview-accessibility-handles (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-header (c-> nsview? any/c)]
  [nsview-accessibility-help (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-accessibility-horizontal-scroll-bar (c-> nsview? any/c)]
  [nsview-accessibility-horizontal-unit-description (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-accessibility-horizontal-units (c-> nsview? exact-integer?)]
  [nsview-accessibility-identifier (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-accessibility-increment-button (c-> nsview? any/c)]
  [nsview-accessibility-index (c-> nsview? exact-integer?)]
  [nsview-accessibility-insertion-point-line-number (c-> nsview? exact-integer?)]
  [nsview-accessibility-label (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-accessibility-label-ui-elements (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-label-value (c-> nsview? real?)]
  [nsview-accessibility-layout-point-for-screen-point (c-> nsview? any/c any/c)]
  [nsview-accessibility-layout-size-for-screen-size (c-> nsview? any/c any/c)]
  [nsview-accessibility-line-for-index (c-> nsview? exact-integer? exact-integer?)]
  [nsview-accessibility-linked-ui-elements (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-main-window (c-> nsview? any/c)]
  [nsview-accessibility-marker-group-ui-element (c-> nsview? any/c)]
  [nsview-accessibility-marker-type-description (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-accessibility-marker-ui-elements (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-marker-values (c-> nsview? any/c)]
  [nsview-accessibility-max-value (c-> nsview? any/c)]
  [nsview-accessibility-menu-bar (c-> nsview? any/c)]
  [nsview-accessibility-min-value (c-> nsview? any/c)]
  [nsview-accessibility-minimize-button (c-> nsview? any/c)]
  [nsview-accessibility-next-contents (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-number-of-characters (c-> nsview? exact-integer?)]
  [nsview-accessibility-orientation (c-> nsview? exact-integer?)]
  [nsview-accessibility-overflow-button (c-> nsview? any/c)]
  [nsview-accessibility-parent (c-> nsview? any/c)]
  [nsview-accessibility-perform-cancel (c-> nsview? boolean?)]
  [nsview-accessibility-perform-confirm (c-> nsview? boolean?)]
  [nsview-accessibility-perform-decrement (c-> nsview? boolean?)]
  [nsview-accessibility-perform-delete (c-> nsview? boolean?)]
  [nsview-accessibility-perform-increment (c-> nsview? boolean?)]
  [nsview-accessibility-perform-pick (c-> nsview? boolean?)]
  [nsview-accessibility-perform-press (c-> nsview? boolean?)]
  [nsview-accessibility-perform-raise (c-> nsview? boolean?)]
  [nsview-accessibility-perform-show-alternate-ui (c-> nsview? boolean?)]
  [nsview-accessibility-perform-show-default-ui (c-> nsview? boolean?)]
  [nsview-accessibility-perform-show-menu (c-> nsview? boolean?)]
  [nsview-accessibility-placeholder-value (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-accessibility-previous-contents (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-proxy (c-> nsview? any/c)]
  [nsview-accessibility-rtf-for-range (c-> nsview? any/c (or/c nsdata? objc-nil?))]
  [nsview-accessibility-range-for-index (c-> nsview? exact-integer? any/c)]
  [nsview-accessibility-range-for-line (c-> nsview? exact-integer? any/c)]
  [nsview-accessibility-range-for-position (c-> nsview? any/c any/c)]
  [nsview-accessibility-role (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-accessibility-role-description (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-accessibility-row-count (c-> nsview? exact-integer?)]
  [nsview-accessibility-row-header-ui-elements (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-row-index-range (c-> nsview? any/c)]
  [nsview-accessibility-rows (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-ruler-marker-type (c-> nsview? exact-integer?)]
  [nsview-accessibility-screen-point-for-layout-point (c-> nsview? any/c any/c)]
  [nsview-accessibility-screen-size-for-layout-size (c-> nsview? any/c any/c)]
  [nsview-accessibility-search-button (c-> nsview? any/c)]
  [nsview-accessibility-search-menu (c-> nsview? any/c)]
  [nsview-accessibility-selected-cells (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-selected-children (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-selected-columns (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-selected-rows (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-selected-text (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-accessibility-selected-text-range (c-> nsview? any/c)]
  [nsview-accessibility-selected-text-ranges (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-serves-as-title-for-ui-elements (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-shared-character-range (c-> nsview? any/c)]
  [nsview-accessibility-shared-focus-elements (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-shared-text-ui-elements (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-shown-menu (c-> nsview? any/c)]
  [nsview-accessibility-sort-direction (c-> nsview? exact-integer?)]
  [nsview-accessibility-splitters (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-string-for-range (c-> nsview? any/c (or/c nsstring? objc-nil?))]
  [nsview-accessibility-style-range-for-index (c-> nsview? exact-integer? any/c)]
  [nsview-accessibility-subrole (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-accessibility-tabs (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-title (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-accessibility-title-ui-element (c-> nsview? any/c)]
  [nsview-accessibility-toolbar-button (c-> nsview? any/c)]
  [nsview-accessibility-top-level-ui-element (c-> nsview? any/c)]
  [nsview-accessibility-url (c-> nsview? (or/c nsurl? objc-nil?))]
  [nsview-accessibility-unit-description (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-accessibility-units (c-> nsview? exact-integer?)]
  [nsview-accessibility-user-input-labels (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-value (c-> nsview? any/c)]
  [nsview-accessibility-value-description (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-accessibility-vertical-scroll-bar (c-> nsview? any/c)]
  [nsview-accessibility-vertical-unit-description (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-accessibility-vertical-units (c-> nsview? exact-integer?)]
  [nsview-accessibility-visible-cells (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-visible-character-range (c-> nsview? any/c)]
  [nsview-accessibility-visible-children (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-visible-columns (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-visible-rows (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-warning-value (c-> nsview? any/c)]
  [nsview-accessibility-window (c-> nsview? any/c)]
  [nsview-accessibility-windows (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-zoom-button (c-> nsview? any/c)]
  [nsview-add-constraint! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-add-constraints! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-add-cursor-rect-cursor! (c-> nsview? any/c (or/c string? objc-object? #f) void?)]
  [nsview-add-gesture-recognizer! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-add-layout-guide! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-add-subview! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-add-subview-positioned-relative-to! (c-> nsview? (or/c string? objc-object? #f) exact-integer? (or/c string? objc-object? #f) void?)]
  [nsview-add-tool-tip-rect-owner-user-data! (c-> nsview? any/c (or/c string? objc-object? #f) (or/c cpointer? #f) exact-integer?)]
  [nsview-add-tracking-area! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-add-tracking-rect-owner-user-data-assume-inside! (c-> nsview? any/c (or/c string? objc-object? #f) (or/c cpointer? #f) boolean? exact-integer?)]
  [nsview-additional-safe-area-insets! (c-> nsview? any/c)]
  [nsview-adjust-page-height-new-top-bottom-limit (c-> nsview? (or/c cpointer? #f) real? real? real? void?)]
  [nsview-adjust-page-width-new-left-right-limit (c-> nsview? (or/c cpointer? #f) real? real? real? void?)]
  [nsview-adjust-scroll (c-> nsview? any/c any/c)]
  [nsview-alignment-rect-for-frame (c-> nsview? any/c any/c)]
  [nsview-ancestor-shared-with-view (c-> nsview? (or/c string? objc-object? #f) (or/c nsview? objc-nil?))]
  [nsview-animation-for-key (c-> nsview? (or/c string? objc-object? #f) any/c)]
  [nsview-animations (c-> nsview? (or/c nsdictionary? objc-nil?))]
  [nsview-animator (c-> nsview? any/c)]
  [nsview-appearance (c-> nsview? (or/c nsappearance? objc-nil?))]
  [nsview-autoscroll (c-> nsview? (or/c string? objc-object? #f) boolean?)]
  [nsview-backing-aligned-rect-options (c-> nsview? any/c exact-nonnegative-integer? any/c)]
  [nsview-become-first-responder (c-> nsview? boolean?)]
  [nsview-begin-document! (c-> nsview? void?)]
  [nsview-begin-dragging-session-with-items-event-source! (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c nsdraggingsession? objc-nil?))]
  [nsview-begin-gesture-with-event! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-begin-page-in-rect-at-placement! (c-> nsview? any/c any/c void?)]
  [nsview-bitmap-image-rep-for-caching-display-in-rect (c-> nsview? any/c (or/c nsbitmapimagerep? objc-nil?))]
  [nsview-cache-display-in-rect-to-bitmap-image-rep (c-> nsview? any/c (or/c string? objc-object? #f) void?)]
  [nsview-cancel-operation (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-capitalize-word (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-center-scan-rect! (c-> nsview? any/c any/c)]
  [nsview-center-selection-in-visible-area! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-center-x-anchor! (c-> nsview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsview-center-y-anchor! (c-> nsview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsview-change-case-of-letter (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-change-mode-with-event (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-complete (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-conclude-drag-operation (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-constraints-affecting-layout-for-orientation (c-> nsview? exact-integer? (or/c nsarray? objc-nil?))]
  [nsview-content-compression-resistance-priority-for-orientation (c-> nsview? exact-integer? real?)]
  [nsview-content-hugging-priority-for-orientation (c-> nsview? exact-integer? real?)]
  [nsview-context-menu-key-down (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-convert-point-from-view (c-> nsview? any/c (or/c string? objc-object? #f) any/c)]
  [nsview-convert-point-to-view (c-> nsview? any/c (or/c string? objc-object? #f) any/c)]
  [nsview-convert-point-from-backing (c-> nsview? any/c any/c)]
  [nsview-convert-point-from-layer (c-> nsview? any/c any/c)]
  [nsview-convert-point-to-backing (c-> nsview? any/c any/c)]
  [nsview-convert-point-to-layer (c-> nsview? any/c any/c)]
  [nsview-convert-rect-from-view (c-> nsview? any/c (or/c string? objc-object? #f) any/c)]
  [nsview-convert-rect-to-view (c-> nsview? any/c (or/c string? objc-object? #f) any/c)]
  [nsview-convert-rect-from-backing (c-> nsview? any/c any/c)]
  [nsview-convert-rect-from-layer (c-> nsview? any/c any/c)]
  [nsview-convert-rect-to-backing (c-> nsview? any/c any/c)]
  [nsview-convert-rect-to-layer (c-> nsview? any/c any/c)]
  [nsview-convert-size-from-view (c-> nsview? any/c (or/c string? objc-object? #f) any/c)]
  [nsview-convert-size-to-view (c-> nsview? any/c (or/c string? objc-object? #f) any/c)]
  [nsview-convert-size-from-backing (c-> nsview? any/c any/c)]
  [nsview-convert-size-from-layer (c-> nsview? any/c any/c)]
  [nsview-convert-size-to-backing (c-> nsview? any/c any/c)]
  [nsview-convert-size-to-layer (c-> nsview? any/c any/c)]
  [nsview-cursor-update (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-data-with-eps-inside-rect (c-> nsview? any/c (or/c nsdata? objc-nil?))]
  [nsview-data-with-pdf-inside-rect (c-> nsview? any/c (or/c nsdata? objc-nil?))]
  [nsview-delete-backward (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-delete-backward-by-decomposing-previous-character (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-delete-forward (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-delete-to-beginning-of-line (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-delete-to-beginning-of-paragraph (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-delete-to-end-of-line (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-delete-to-end-of-paragraph (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-delete-to-mark (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-delete-word-backward (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-delete-word-forward (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-did-add-subview (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-did-close-menu-with-event (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsview-discard-cursor-rects (c-> nsview? void?)]
  [nsview-display! (c-> nsview? void?)]
  [nsview-display-if-needed! (c-> nsview? void?)]
  [nsview-display-if-needed-ignoring-opacity! (c-> nsview? void?)]
  [nsview-display-if-needed-in-rect! (c-> nsview? any/c void?)]
  [nsview-display-if-needed-in-rect-ignoring-opacity! (c-> nsview? any/c void?)]
  [nsview-display-link-with-target-selector! (c-> nsview? (or/c string? objc-object? #f) string? (or/c cadisplaylink? objc-nil?))]
  [nsview-display-rect! (c-> nsview? any/c void?)]
  [nsview-display-rect-ignoring-opacity! (c-> nsview? any/c void?)]
  [nsview-display-rect-ignoring-opacity-in-context! (c-> nsview? any/c (or/c string? objc-object? #f) void?)]
  [nsview-do-command-by-selector (c-> nsview? string? void?)]
  [nsview-dragging-ended (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-dragging-entered (c-> nsview? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nsview-dragging-exited (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-dragging-updated (c-> nsview? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nsview-draw-focus-ring-mask (c-> nsview? void?)]
  [nsview-draw-page-border-with-size (c-> nsview? any/c void?)]
  [nsview-draw-rect (c-> nsview? any/c void?)]
  [nsview-edge-insets-for-layout-region (c-> nsview? (or/c string? objc-object? #f) any/c)]
  [nsview-effective-appearance (c-> nsview? (or/c nsappearance? objc-nil?))]
  [nsview-encode-restorable-state-with-coder (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-encode-restorable-state-with-coder-background-queue (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsview-encode-with-coder (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-end-document! (c-> nsview? void?)]
  [nsview-end-gesture-with-event! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-end-page! (c-> nsview? void?)]
  [nsview-enter-full-screen-mode-with-options (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nsview-exercise-ambiguity-in-layout (c-> nsview? void?)]
  [nsview-exit-full-screen-mode-with-options (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-flags-changed (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-flush-buffered-key-events (c-> nsview? void?)]
  [nsview-frame-for-alignment-rect (c-> nsview? any/c any/c)]
  [nsview-get-rects-being-drawn-count (c-> nsview? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nsview-get-rects-exposed-during-live-resize-count (c-> nsview? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nsview-help-requested (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-hit-test (c-> nsview? any/c (or/c nsview? objc-nil?))]
  [nsview-identifier (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-indent (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-insert-backtab! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-insert-container-break! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-insert-double-quote-ignoring-substitution! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-insert-line-break! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-insert-newline! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-insert-newline-ignoring-field-editor! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-insert-paragraph-separator! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-insert-single-quote-ignoring-substitution! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-insert-tab! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-insert-tab-ignoring-field-editor! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-insert-text! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-interpret-key-events (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-invalidate-intrinsic-content-size (c-> nsview? void?)]
  [nsview-invalidate-restorable-state (c-> nsview? void?)]
  [nsview-is-accessibility-alternate-ui-visible (c-> nsview? boolean?)]
  [nsview-is-accessibility-disclosed (c-> nsview? boolean?)]
  [nsview-is-accessibility-edited (c-> nsview? boolean?)]
  [nsview-is-accessibility-element (c-> nsview? boolean?)]
  [nsview-is-accessibility-enabled (c-> nsview? boolean?)]
  [nsview-is-accessibility-expanded (c-> nsview? boolean?)]
  [nsview-is-accessibility-focused (c-> nsview? boolean?)]
  [nsview-is-accessibility-frontmost (c-> nsview? boolean?)]
  [nsview-is-accessibility-hidden (c-> nsview? boolean?)]
  [nsview-is-accessibility-main (c-> nsview? boolean?)]
  [nsview-is-accessibility-minimized (c-> nsview? boolean?)]
  [nsview-is-accessibility-modal (c-> nsview? boolean?)]
  [nsview-is-accessibility-ordered-by-row (c-> nsview? boolean?)]
  [nsview-is-accessibility-protected-content (c-> nsview? boolean?)]
  [nsview-is-accessibility-required (c-> nsview? boolean?)]
  [nsview-is-accessibility-selected (c-> nsview? boolean?)]
  [nsview-is-accessibility-selector-allowed (c-> nsview? string? boolean?)]
  [nsview-is-descendant-of (c-> nsview? (or/c string? objc-object? #f) boolean?)]
  [nsview-is-drawing-find-indicator (c-> nsview? boolean?)]
  [nsview-is-flipped (c-> nsview? boolean?)]
  [nsview-is-hidden (c-> nsview? boolean?)]
  [nsview-is-hidden-or-has-hidden-ancestor (c-> nsview? boolean?)]
  [nsview-is-horizontal-content-size-constraint-active (c-> nsview? boolean?)]
  [nsview-is-in-full-screen-mode (c-> nsview? boolean?)]
  [nsview-is-opaque (c-> nsview? boolean?)]
  [nsview-is-rotated-from-base (c-> nsview? boolean?)]
  [nsview-is-rotated-or-scaled-from-base (c-> nsview? boolean?)]
  [nsview-is-vertical-content-size-constraint-active (c-> nsview? boolean?)]
  [nsview-key-down (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-key-up (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-knows-page-range (c-> nsview? (or/c cpointer? #f) boolean?)]
  [nsview-layout (c-> nsview? void?)]
  [nsview-layout-guide-for-layout-region (c-> nsview? (or/c string? objc-object? #f) (or/c nslayoutguide? objc-nil?))]
  [nsview-layout-subtree-if-needed (c-> nsview? void?)]
  [nsview-location-of-print-rect (c-> nsview? any/c any/c)]
  [nsview-lowercase-word (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-magnify-with-event (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-make-backing-layer (c-> nsview? (or/c calayer? objc-nil?))]
  [nsview-make-base-writing-direction-left-to-right (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-make-base-writing-direction-natural (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-make-base-writing-direction-right-to-left (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-make-text-writing-direction-left-to-right (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-make-text-writing-direction-natural (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-make-text-writing-direction-right-to-left (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-make-touch-bar (c-> nsview? (or/c nstouchbar? objc-nil?))]
  [nsview-menu-for-event (c-> nsview? (or/c string? objc-object? #f) (or/c nsmenu? objc-nil?))]
  [nsview-mouse-in-rect (c-> nsview? any/c any/c boolean?)]
  [nsview-mouse-cancelled (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-mouse-down (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-mouse-dragged (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-mouse-entered (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-mouse-exited (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-mouse-moved (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-mouse-up (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-backward! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-backward-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-down! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-down-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-forward! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-forward-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-left! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-left-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-paragraph-backward-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-paragraph-forward-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-right! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-right-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-to-beginning-of-document! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-to-beginning-of-document-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-to-beginning-of-line! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-to-beginning-of-line-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-to-beginning-of-paragraph! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-to-beginning-of-paragraph-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-to-end-of-document! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-to-end-of-document-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-to-end-of-line! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-to-end-of-line-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-to-end-of-paragraph! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-to-end-of-paragraph-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-to-left-end-of-line! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-to-left-end-of-line-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-to-right-end-of-line! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-to-right-end-of-line-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-up! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-up-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-word-backward! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-word-backward-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-word-forward! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-word-forward-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-word-left! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-word-left-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-word-right! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-move-word-right-and-modify-selection! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-needs-to-draw-rect (c-> nsview? any/c boolean?)]
  [nsview-new-window-for-tab (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-no-responder-for (c-> nsview? string? void?)]
  [nsview-note-focus-ring-mask-changed (c-> nsview? void?)]
  [nsview-other-mouse-down (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-other-mouse-dragged (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-other-mouse-up (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-page-down (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-page-down-and-modify-selection (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-page-up (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-page-up-and-modify-selection (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-perform-drag-operation! (c-> nsview? (or/c string? objc-object? #f) boolean?)]
  [nsview-perform-key-equivalent! (c-> nsview? (or/c string? objc-object? #f) boolean?)]
  [nsview-perform-text-finder-action! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-prepare-content-in-rect (c-> nsview? any/c void?)]
  [nsview-prepare-for-drag-operation (c-> nsview? (or/c string? objc-object? #f) boolean?)]
  [nsview-prepare-for-reuse (c-> nsview? void?)]
  [nsview-present-error (c-> nsview? (or/c string? objc-object? #f) boolean?)]
  [nsview-present-error-modal-for-window-delegate-did-present-selector-context-info (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) string? (or/c cpointer? #f) void?)]
  [nsview-pressure-change-with-event (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-print (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-quick-look-preview-items (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-quick-look-with-event (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-rect-for-layout-region (c-> nsview? (or/c string? objc-object? #f) any/c)]
  [nsview-rect-for-page (c-> nsview? exact-integer? any/c)]
  [nsview-rect-for-smart-magnification-at-point-in-rect (c-> nsview? any/c any/c any/c)]
  [nsview-reflect-scrolled-clip-view (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-register-for-dragged-types (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-remove-all-tool-tips! (c-> nsview? void?)]
  [nsview-remove-constraint! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-remove-constraints! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-remove-cursor-rect-cursor! (c-> nsview? any/c (or/c string? objc-object? #f) void?)]
  [nsview-remove-from-superview! (c-> nsview? void?)]
  [nsview-remove-from-superview-without-needing-display! (c-> nsview? void?)]
  [nsview-remove-gesture-recognizer! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-remove-layout-guide! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-remove-tool-tip! (c-> nsview? exact-integer? void?)]
  [nsview-remove-tracking-area! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-remove-tracking-rect! (c-> nsview? exact-integer? void?)]
  [nsview-replace-subview-with! (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsview-reset-cursor-rects! (c-> nsview? void?)]
  [nsview-resign-first-responder (c-> nsview? boolean?)]
  [nsview-resize-subviews-with-old-size (c-> nsview? any/c void?)]
  [nsview-resize-with-old-superview-size (c-> nsview? any/c void?)]
  [nsview-restore-state-with-coder (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-restore-user-activity-state (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-right-mouse-down (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-right-mouse-dragged (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-right-mouse-up (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-rotate-by-angle (c-> nsview? real? void?)]
  [nsview-rotate-with-event (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-ruler-view-did-add-marker (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsview-ruler-view-did-move-marker (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsview-ruler-view-did-remove-marker (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsview-ruler-view-handle-mouse-down (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsview-ruler-view-location-for-point (c-> nsview? (or/c string? objc-object? #f) any/c real?)]
  [nsview-ruler-view-point-for-location (c-> nsview? (or/c string? objc-object? #f) real? any/c)]
  [nsview-ruler-view-should-add-marker (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nsview-ruler-view-should-move-marker (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nsview-ruler-view-should-remove-marker (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nsview-ruler-view-will-add-marker-at-location (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) real? real?)]
  [nsview-ruler-view-will-move-marker-to-location (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) real? real?)]
  [nsview-ruler-view-will-set-client-view (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsview-scale-unit-square-to-size (c-> nsview? any/c void?)]
  [nsview-scroll-clip-view-to-point (c-> nsview? (or/c string? objc-object? #f) any/c void?)]
  [nsview-scroll-line-down (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-scroll-line-up (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-scroll-page-down (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-scroll-page-up (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-scroll-point (c-> nsview? any/c void?)]
  [nsview-scroll-rect-to-visible (c-> nsview? any/c boolean?)]
  [nsview-scroll-to-beginning-of-document (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-scroll-to-end-of-document (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-scroll-wheel (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-select-all (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-select-line (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-select-paragraph (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-select-to-mark (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-select-word (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-activation-point! (c-> nsview? any/c void?)]
  [nsview-set-accessibility-allowed-values! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-alternate-ui-visible! (c-> nsview? boolean? void?)]
  [nsview-set-accessibility-application-focused-ui-element! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-attributed-user-input-labels! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-cancel-button! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-children! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-children-in-navigation-order! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-clear-button! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-close-button! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-column-count! (c-> nsview? exact-integer? void?)]
  [nsview-set-accessibility-column-header-ui-elements! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-column-index-range! (c-> nsview? any/c void?)]
  [nsview-set-accessibility-column-titles! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-columns! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-contents! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-critical-value! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-custom-actions! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-custom-rotors! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-decrement-button! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-default-button! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-disclosed! (c-> nsview? boolean? void?)]
  [nsview-set-accessibility-disclosed-by-row! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-disclosed-rows! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-disclosure-level! (c-> nsview? exact-integer? void?)]
  [nsview-set-accessibility-document! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-edited! (c-> nsview? boolean? void?)]
  [nsview-set-accessibility-element! (c-> nsview? boolean? void?)]
  [nsview-set-accessibility-enabled! (c-> nsview? boolean? void?)]
  [nsview-set-accessibility-expanded! (c-> nsview? boolean? void?)]
  [nsview-set-accessibility-extras-menu-bar! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-filename! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-focused! (c-> nsview? boolean? void?)]
  [nsview-set-accessibility-focused-window! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-frame! (c-> nsview? any/c void?)]
  [nsview-set-accessibility-frontmost! (c-> nsview? boolean? void?)]
  [nsview-set-accessibility-full-screen-button! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-grow-area! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-handles! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-header! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-help! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-hidden! (c-> nsview? boolean? void?)]
  [nsview-set-accessibility-horizontal-scroll-bar! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-horizontal-unit-description! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-horizontal-units! (c-> nsview? exact-integer? void?)]
  [nsview-set-accessibility-identifier! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-increment-button! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-index! (c-> nsview? exact-integer? void?)]
  [nsview-set-accessibility-insertion-point-line-number! (c-> nsview? exact-integer? void?)]
  [nsview-set-accessibility-label! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-label-ui-elements! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-label-value! (c-> nsview? real? void?)]
  [nsview-set-accessibility-linked-ui-elements! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-main! (c-> nsview? boolean? void?)]
  [nsview-set-accessibility-main-window! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-marker-group-ui-element! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-marker-type-description! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-marker-ui-elements! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-marker-values! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-max-value! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-menu-bar! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-min-value! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-minimize-button! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-minimized! (c-> nsview? boolean? void?)]
  [nsview-set-accessibility-modal! (c-> nsview? boolean? void?)]
  [nsview-set-accessibility-next-contents! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-number-of-characters! (c-> nsview? exact-integer? void?)]
  [nsview-set-accessibility-ordered-by-row! (c-> nsview? boolean? void?)]
  [nsview-set-accessibility-orientation! (c-> nsview? exact-integer? void?)]
  [nsview-set-accessibility-overflow-button! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-parent! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-placeholder-value! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-previous-contents! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-protected-content! (c-> nsview? boolean? void?)]
  [nsview-set-accessibility-proxy! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-required! (c-> nsview? boolean? void?)]
  [nsview-set-accessibility-role! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-role-description! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-row-count! (c-> nsview? exact-integer? void?)]
  [nsview-set-accessibility-row-header-ui-elements! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-row-index-range! (c-> nsview? any/c void?)]
  [nsview-set-accessibility-rows! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-ruler-marker-type! (c-> nsview? exact-integer? void?)]
  [nsview-set-accessibility-search-button! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-search-menu! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-selected! (c-> nsview? boolean? void?)]
  [nsview-set-accessibility-selected-cells! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-selected-children! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-selected-columns! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-selected-rows! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-selected-text! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-selected-text-range! (c-> nsview? any/c void?)]
  [nsview-set-accessibility-selected-text-ranges! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-serves-as-title-for-ui-elements! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-shared-character-range! (c-> nsview? any/c void?)]
  [nsview-set-accessibility-shared-focus-elements! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-shared-text-ui-elements! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-shown-menu! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-sort-direction! (c-> nsview? exact-integer? void?)]
  [nsview-set-accessibility-splitters! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-subrole! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-tabs! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-title! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-title-ui-element! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-toolbar-button! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-top-level-ui-element! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-url! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-unit-description! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-units! (c-> nsview? exact-integer? void?)]
  [nsview-set-accessibility-user-input-labels! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-value! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-value-description! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-vertical-scroll-bar! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-vertical-unit-description! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-vertical-units! (c-> nsview? exact-integer? void?)]
  [nsview-set-accessibility-visible-cells! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-visible-character-range! (c-> nsview? any/c void?)]
  [nsview-set-accessibility-visible-children! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-visible-columns! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-visible-rows! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-warning-value! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-window! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-windows! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-zoom-button! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-animations! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-appearance! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-bounds-origin! (c-> nsview? any/c void?)]
  [nsview-set-bounds-size! (c-> nsview? any/c void?)]
  [nsview-set-content-compression-resistance-priority-for-orientation! (c-> nsview? real? exact-integer? void?)]
  [nsview-set-content-hugging-priority-for-orientation! (c-> nsview? real? exact-integer? void?)]
  [nsview-set-frame-origin! (c-> nsview? any/c void?)]
  [nsview-set-frame-size! (c-> nsview? any/c void?)]
  [nsview-set-identifier! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-keyboard-focus-ring-needs-display-in-rect! (c-> nsview? any/c void?)]
  [nsview-set-mark! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-needs-display-in-rect! (c-> nsview? any/c void?)]
  [nsview-should-be-treated-as-ink-event (c-> nsview? (or/c string? objc-object? #f) boolean?)]
  [nsview-should-delay-window-ordering-for-event (c-> nsview? (or/c string? objc-object? #f) boolean?)]
  [nsview-show-context-help (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-show-context-menu-for-selection (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-show-definition-for-attributed-string-at-point (c-> nsview? (or/c string? objc-object? #f) any/c void?)]
  [nsview-show-definition-for-attributed-string-range-options-baseline-origin-provider (c-> nsview? (or/c string? objc-object? #f) any/c (or/c string? objc-object? #f) (or/c procedure? #f) void?)]
  [nsview-show-writing-tools (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-smart-magnify-with-event (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-sort-subviews-using-function-context (c-> nsview? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nsview-supplemental-target-for-action-sender (c-> nsview? string? (or/c string? objc-object? #f) any/c)]
  [nsview-swap-with-mark (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-swipe-with-event (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-tablet-point (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-tablet-proximity (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-touches-began-with-event (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-touches-cancelled-with-event (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-touches-ended-with-event (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-touches-moved-with-event (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-translate-origin-to-point (c-> nsview? any/c void?)]
  [nsview-translate-rects-needing-display-in-rect-by (c-> nsview? any/c any/c void?)]
  [nsview-transpose (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-transpose-words (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-try-to-perform-with (c-> nsview? string? (or/c string? objc-object? #f) boolean?)]
  [nsview-unregister-dragged-types (c-> nsview? void?)]
  [nsview-update-constraints (c-> nsview? void?)]
  [nsview-update-constraints-for-subtree-if-needed (c-> nsview? void?)]
  [nsview-update-dragging-items-for-drag (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-update-layer (c-> nsview? void?)]
  [nsview-update-tracking-areas (c-> nsview? void?)]
  [nsview-update-user-activity-state (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-uppercase-word (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-valid-requestor-for-send-type-return-type (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nsview-validate-proposed-first-responder-for-event (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nsview-view-did-change-backing-properties (c-> nsview? void?)]
  [nsview-view-did-change-effective-appearance (c-> nsview? void?)]
  [nsview-view-did-end-live-resize (c-> nsview? void?)]
  [nsview-view-did-hide (c-> nsview? void?)]
  [nsview-view-did-move-to-superview (c-> nsview? void?)]
  [nsview-view-did-move-to-window (c-> nsview? void?)]
  [nsview-view-did-unhide (c-> nsview? void?)]
  [nsview-view-will-draw (c-> nsview? void?)]
  [nsview-view-will-move-to-superview (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-view-will-move-to-window (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-view-will-start-live-resize (c-> nsview? void?)]
  [nsview-view-with-tag (c-> nsview? exact-integer? (or/c nsview? objc-nil?))]
  [nsview-wants-forwarded-scroll-events-for-axis (c-> nsview? exact-integer? boolean?)]
  [nsview-wants-periodic-dragging-updates (c-> nsview? boolean?)]
  [nsview-wants-scroll-events-for-swipe-tracking-on-axis (c-> nsview? exact-integer? boolean?)]
  [nsview-will-open-menu-with-event (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsview-will-present-error (c-> nsview? (or/c string? objc-object? #f) (or/c nserror? objc-nil?))]
  [nsview-will-remove-subview (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-write-eps-inside-rect-to-pasteboard (c-> nsview? any/c (or/c string? objc-object? #f) void?)]
  [nsview-write-pdf-inside-rect-to-pasteboard (c-> nsview? any/c (or/c string? objc-object? #f) void?)]
  [nsview-yank (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-allowed-classes-for-restorable-state-key-path (c-> (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsview-default-animation-for-key (c-> (or/c string? objc-object? #f) any/c)]
  [nsview-is-compatible-with-responsive-scrolling (c-> boolean?)]
  )

;; --- Class reference ---
(import-class NSView)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
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
(define-aw-msg aw_racket_msg_P_R (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_E (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_b (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PPPPP_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPd_d (-> ptr_t ptr_t ptr_t ptr_t double_t double_t))
(define-aw-msg aw_racket_msg_PqP_v (-> ptr_t ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_Pd_O (-> ptr_t ptr_t ptr_t double_t ptr_t void_t))
(define-aw-msg aw_racket_msg_Pddd_v (-> ptr_t ptr_t ptr_t double_t double_t double_t void_t))
(define-aw-msg aw_racket_msg_PO_d (-> ptr_t ptr_t ptr_t ptr_t double_t))
(define-aw-msg aw_racket_msg_PO_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PGPP_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_b_v (-> ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_q_P (-> ptr_t ptr_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_q_b (-> ptr_t ptr_t int64_t bool_t))
(define-aw-msg aw_racket_msg_q_q (-> ptr_t ptr_t int64_t int64_t))
(define-aw-msg aw_racket_msg_q_f (-> ptr_t ptr_t int64_t float_t))
(define-aw-msg aw_racket_msg_q_R (-> ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_q_G (-> ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_q_v (-> ptr_t ptr_t int64_t void_t))
(define-aw-msg aw_racket_msg_qq_P (-> ptr_t ptr_t int64_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_Q_v (-> ptr_t ptr_t uint64_t void_t))
(define-aw-msg aw_racket_msg_f_v (-> ptr_t ptr_t float_t void_t))
(define-aw-msg aw_racket_msg_fq_v (-> ptr_t ptr_t float_t int64_t void_t))
(define-aw-msg aw_racket_msg_d_v (-> ptr_t ptr_t double_t void_t))
(define-aw-msg aw_racket_msg_R_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_R_b (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_R_R (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_R_O (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_R_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RP_R (-> ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RPP_q (-> ptr_t ptr_t ptr_t ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_RPPb_q (-> ptr_t ptr_t ptr_t ptr_t ptr_t bool_t int64_t))
(define-aw-msg aw_racket_msg_RQ_R (-> ptr_t ptr_t ptr_t uint64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RO_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
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
(define (make-nsview-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSView alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nsview-init-with-frame frame-rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (tell NSView alloc)) (id->ffi2-ptr (sel_registerName "initWithFrame:")) (id->ffi2-ptr frame-rect)))
   #:retained #t))


;; --- Properties ---
(define (nsview-accepts-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsFirstResponder"))))
(define (nsview-accepts-touch-events self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsTouchEvents"))))
(define (nsview-set-accepts-touch-events! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAcceptsTouchEvents:")) value))
(define (nsview-additional-safe-area-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "additionalSafeAreaInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nsview-set-additional-safe-area-insets! self value)
  (aw_racket_msg_E_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAdditionalSafeAreaInsets:")) (id->ffi2-ptr value)))
(define (nsview-alignment-rect-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignmentRectInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nsview-allowed-touch-types self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowedTouchTypes"))))
(define (nsview-set-allowed-touch-types! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowedTouchTypes:")) value))
(define (nsview-allows-vibrancy self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsVibrancy"))))
(define (nsview-alpha-value self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alphaValue"))))
(define (nsview-set-alpha-value! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlphaValue:")) value))
(define (nsview-autoresizes-subviews self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoresizesSubviews"))))
(define (nsview-set-autoresizes-subviews! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutoresizesSubviews:")) value))
(define (nsview-autoresizing-mask self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoresizingMask"))))
(define (nsview-set-autoresizing-mask! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutoresizingMask:")) value))
(define (nsview-background-filters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backgroundFilters"))))))
(define (nsview-set-background-filters! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBackgroundFilters:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsview-baseline-offset-from-bottom self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "baselineOffsetFromBottom"))))
(define (nsview-bottom-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bottomAnchor"))))))
(define (nsview-bounds self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bounds")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-set-bounds! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBounds:")) (id->ffi2-ptr value)))
(define (nsview-bounds-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "boundsRotation"))))
(define (nsview-set-bounds-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsRotation:")) value))
(define (nsview-can-become-key-view self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canBecomeKeyView"))))
(define (nsview-can-draw self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDraw"))))
(define (nsview-can-draw-concurrently self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDrawConcurrently"))))
(define (nsview-set-can-draw-concurrently! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCanDrawConcurrently:")) value))
(define (nsview-can-draw-subviews-into-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDrawSubviewsIntoLayer"))))
(define (nsview-set-can-draw-subviews-into-layer! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCanDrawSubviewsIntoLayer:")) value))
(define (nsview-candidate-list-touch-bar-item self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "candidateListTouchBarItem"))))))
(define (nsview-center-x-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerXAnchor"))))))
(define (nsview-center-y-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerYAnchor"))))))
(define (nsview-clips-to-bounds self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "clipsToBounds"))))
(define (nsview-set-clips-to-bounds! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setClipsToBounds:")) value))
(define (nsview-compatible-with-responsive-scrolling)
  (aw_racket_msg_0_b (id->ffi2-ptr NSView) (id->ffi2-ptr (sel_registerName "compatibleWithResponsiveScrolling"))))
(define (nsview-compositing-filter self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "compositingFilter"))))))
(define (nsview-set-compositing-filter! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCompositingFilter:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsview-constraints self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "constraints"))))))
(define (nsview-content-filters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentFilters"))))))
(define (nsview-set-content-filters! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentFilters:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsview-default-focus-ring-type)
  (aw_racket_msg_0_Q (id->ffi2-ptr NSView) (id->ffi2-ptr (sel_registerName "defaultFocusRingType"))))
(define (nsview-default-menu)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSView) (id->ffi2-ptr (sel_registerName "defaultMenu"))))))
(define (nsview-drawing-find-indicator self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawingFindIndicator"))))
(define (nsview-enclosing-menu-item self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enclosingMenuItem"))))))
(define (nsview-enclosing-scroll-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enclosingScrollView"))))))
(define (nsview-first-baseline-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstBaselineAnchor"))))))
(define (nsview-first-baseline-offset-from-top self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstBaselineOffsetFromTop"))))
(define (nsview-fitting-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fittingSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsview-flipped self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flipped"))))
(define (nsview-focus-ring-mask-bounds self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "focusRingMaskBounds")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-focus-ring-type self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "focusRingType"))))
(define (nsview-set-focus-ring-type! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFocusRingType:")) value))
(define (nsview-focus-view)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSView) (id->ffi2-ptr (sel_registerName "focusView"))))))
(define (nsview-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-set-frame! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrame:")) (id->ffi2-ptr value)))
(define (nsview-frame-center-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameCenterRotation"))))
(define (nsview-set-frame-center-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameCenterRotation:")) value))
(define (nsview-frame-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameRotation"))))
(define (nsview-set-frame-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameRotation:")) value))
(define (nsview-gesture-recognizers self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "gestureRecognizers"))))))
(define (nsview-set-gesture-recognizers! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setGestureRecognizers:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsview-has-ambiguous-layout self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasAmbiguousLayout"))))
(define (nsview-height-adjust-limit self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "heightAdjustLimit"))))
(define (nsview-height-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "heightAnchor"))))))
(define (nsview-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hidden"))))
(define (nsview-set-hidden! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHidden:")) value))
(define (nsview-hidden-or-has-hidden-ancestor self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hiddenOrHasHiddenAncestor"))))
(define (nsview-horizontal-content-size-constraint-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "horizontalContentSizeConstraintActive"))))
(define (nsview-set-horizontal-content-size-constraint-active! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHorizontalContentSizeConstraintActive:")) value))
(define (nsview-in-full-screen-mode self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inFullScreenMode"))))
(define (nsview-in-live-resize self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inLiveResize"))))
(define (nsview-input-context self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inputContext"))))))
(define (nsview-intrinsic-content-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "intrinsicContentSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsview-last-baseline-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastBaselineAnchor"))))))
(define (nsview-last-baseline-offset-from-bottom self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastBaselineOffsetFromBottom"))))
(define (nsview-layer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layer"))))))
(define (nsview-set-layer! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayer:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsview-layer-contents-placement self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerContentsPlacement"))))
(define (nsview-set-layer-contents-placement! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerContentsPlacement:")) value))
(define (nsview-layer-contents-redraw-policy self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerContentsRedrawPolicy"))))
(define (nsview-set-layer-contents-redraw-policy! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerContentsRedrawPolicy:")) value))
(define (nsview-layer-uses-core-image-filters self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerUsesCoreImageFilters"))))
(define (nsview-set-layer-uses-core-image-filters! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerUsesCoreImageFilters:")) value))
(define (nsview-layout-guides self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutGuides"))))))
(define (nsview-layout-margins-guide self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutMarginsGuide"))))))
(define (nsview-leading-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "leadingAnchor"))))))
(define (nsview-left-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "leftAnchor"))))))
(define (nsview-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menu"))))))
(define (nsview-set-menu! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMenu:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsview-mouse-down-can-move-window self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDownCanMoveWindow"))))
(define (nsview-needs-display self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsDisplay"))))
(define (nsview-set-needs-display! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsDisplay:")) value))
(define (nsview-needs-layout self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsLayout"))))
(define (nsview-set-needs-layout! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsLayout:")) value))
(define (nsview-needs-panel-to-become-key self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsPanelToBecomeKey"))))
(define (nsview-needs-update-constraints self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsUpdateConstraints"))))
(define (nsview-set-needs-update-constraints! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsUpdateConstraints:")) value))
(define (nsview-next-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextKeyView"))))))
(define (nsview-set-next-key-view! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextKeyView:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsview-next-responder self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextResponder"))))))
(define (nsview-set-next-responder! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextResponder:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsview-next-valid-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextValidKeyView"))))))
(define (nsview-opaque self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "opaque"))))
(define (nsview-opaque-ancestor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "opaqueAncestor"))))))
(define (nsview-page-footer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageFooter"))))))
(define (nsview-page-header self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageHeader"))))))
(define (nsview-posts-bounds-changed-notifications self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "postsBoundsChangedNotifications"))))
(define (nsview-set-posts-bounds-changed-notifications! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPostsBoundsChangedNotifications:")) value))
(define (nsview-posts-frame-changed-notifications self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "postsFrameChangedNotifications"))))
(define (nsview-set-posts-frame-changed-notifications! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPostsFrameChangedNotifications:")) value))
(define (nsview-prefers-compact-control-size-metrics self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prefersCompactControlSizeMetrics"))))
(define (nsview-set-prefers-compact-control-size-metrics! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPrefersCompactControlSizeMetrics:")) value))
(define (nsview-prepared-content-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preparedContentRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-set-prepared-content-rect! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPreparedContentRect:")) (id->ffi2-ptr value)))
(define (nsview-preserves-content-during-live-resize self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preservesContentDuringLiveResize"))))
(define (nsview-pressure-configuration self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pressureConfiguration"))))))
(define (nsview-set-pressure-configuration! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPressureConfiguration:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsview-previous-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "previousKeyView"))))))
(define (nsview-previous-valid-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "previousValidKeyView"))))))
(define (nsview-print-job-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "printJobTitle"))))))
(define (nsview-rect-preserved-during-live-resize self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectPreservedDuringLiveResize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-registered-dragged-types self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "registeredDraggedTypes"))))))
(define (nsview-requires-constraint-based-layout)
  (aw_racket_msg_0_b (id->ffi2-ptr NSView) (id->ffi2-ptr (sel_registerName "requiresConstraintBasedLayout"))))
(define (nsview-restorable-state-key-paths)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSView) (id->ffi2-ptr (sel_registerName "restorableStateKeyPaths"))))))
(define (nsview-right-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightAnchor"))))))
(define (nsview-rotated-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotatedFromBase"))))
(define (nsview-rotated-or-scaled-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotatedOrScaledFromBase"))))
(define (nsview-safe-area-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nsview-safe-area-layout-guide self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaLayoutGuide"))))))
(define (nsview-safe-area-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-shadow self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shadow"))))))
(define (nsview-set-shadow! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShadow:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsview-subviews self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "subviews"))))))
(define (nsview-set-subviews! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSubviews:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsview-superview self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "superview"))))))
(define (nsview-tag self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tag"))))
(define (nsview-tool-tip self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "toolTip"))))))
(define (nsview-set-tool-tip! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setToolTip:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsview-top-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "topAnchor"))))))
(define (nsview-touch-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchBar"))))))
(define (nsview-set-touch-bar! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTouchBar:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsview-tracking-areas self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "trackingAreas"))))))
(define (nsview-trailing-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "trailingAnchor"))))))
(define (nsview-translates-autoresizing-mask-into-constraints self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translatesAutoresizingMaskIntoConstraints"))))
(define (nsview-set-translates-autoresizing-mask-into-constraints! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTranslatesAutoresizingMaskIntoConstraints:")) value))
(define (nsview-undo-manager self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "undoManager"))))))
(define (nsview-user-activity self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userActivity"))))))
(define (nsview-set-user-activity! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserActivity:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsview-user-interface-layout-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userInterfaceLayoutDirection"))))
(define (nsview-set-user-interface-layout-direction! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserInterfaceLayoutDirection:")) value))
(define (nsview-vertical-content-size-constraint-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "verticalContentSizeConstraintActive"))))
(define (nsview-set-vertical-content-size-constraint-active! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setVerticalContentSizeConstraintActive:")) value))
(define (nsview-visible-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "visibleRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-wants-best-resolution-open-gl-surface self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsBestResolutionOpenGLSurface"))))
(define (nsview-set-wants-best-resolution-open-gl-surface! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsBestResolutionOpenGLSurface:")) value))
(define (nsview-wants-default-clipping self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsDefaultClipping"))))
(define (nsview-wants-extended-dynamic-range-open-gl-surface self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsExtendedDynamicRangeOpenGLSurface"))))
(define (nsview-set-wants-extended-dynamic-range-open-gl-surface! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsExtendedDynamicRangeOpenGLSurface:")) value))
(define (nsview-wants-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsLayer"))))
(define (nsview-set-wants-layer! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsLayer:")) value))
(define (nsview-wants-resting-touches self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsRestingTouches"))))
(define (nsview-set-wants-resting-touches! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsRestingTouches:")) value))
(define (nsview-wants-update-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsUpdateLayer"))))
(define (nsview-width-adjust-limit self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "widthAdjustLimit"))))
(define (nsview-width-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "widthAnchor"))))))
(define (nsview-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "window"))))))
(define (nsview-writing-tools-coordinator self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writingToolsCoordinator"))))))
(define (nsview-set-writing-tools-coordinator! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWritingToolsCoordinator:")) (id->ffi2-ptr (coerce-arg value))))

;; --- Instance methods ---
(define (nsview-accepts-first-mouse self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsFirstMouse:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-accessibility-activation-point self)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_0_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityActivationPoint")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsview-accessibility-allowed-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAllowedValues"))))
   ))
(define (nsview-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityApplicationFocusedUIElement"))))
   ))
(define (nsview-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nsview-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedUserInputLabels"))))
   ))
(define (nsview-accessibility-cancel-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCancelButton"))))
   ))
(define (nsview-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_qq_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCellForColumn:row:")) column row))
   ))
(define (nsview-accessibility-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildren"))))
   ))
(define (nsview-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildrenInNavigationOrder"))))
   ))
(define (nsview-accessibility-clear-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityClearButton"))))
   ))
(define (nsview-accessibility-close-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCloseButton"))))
   ))
(define (nsview-accessibility-column-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnCount"))))
(define (nsview-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnHeaderUIElements"))))
   ))
(define (nsview-accessibility-column-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsview-accessibility-column-titles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnTitles"))))
   ))
(define (nsview-accessibility-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumns"))))
   ))
(define (nsview-accessibility-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityContents"))))
   ))
(define (nsview-accessibility-critical-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCriticalValue"))))
   ))
(define (nsview-accessibility-custom-actions self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomActions"))))
   ))
(define (nsview-accessibility-custom-rotors self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomRotors"))))
   ))
(define (nsview-accessibility-decrement-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDecrementButton"))))
   ))
(define (nsview-accessibility-default-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDefaultButton"))))
   ))
(define (nsview-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedByRow"))))
   ))
(define (nsview-accessibility-disclosed-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedRows"))))
   ))
(define (nsview-accessibility-disclosure-level self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosureLevel"))))
(define (nsview-accessibility-document self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDocument"))))
   ))
(define (nsview-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityExtrasMenuBar"))))
   ))
(define (nsview-accessibility-filename self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFilename"))))
   ))
(define (nsview-accessibility-focused-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFocusedWindow"))))
   ))
(define (nsview-accessibility-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-accessibility-frame-for-range self range)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_G_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrameForRange:")) (id->ffi2-ptr range) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-accessibility-full-screen-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFullScreenButton"))))
   ))
(define (nsview-accessibility-grow-area self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityGrowArea"))))
   ))
(define (nsview-accessibility-handles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHandles"))))
   ))
(define (nsview-accessibility-header self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHeader"))))
   ))
(define (nsview-accessibility-help self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHelp"))))
   ))
(define (nsview-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalScrollBar"))))
   ))
(define (nsview-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnitDescription"))))
   ))
(define (nsview-accessibility-horizontal-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnits"))))
(define (nsview-accessibility-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIdentifier"))))
   ))
(define (nsview-accessibility-increment-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIncrementButton"))))
   ))
(define (nsview-accessibility-index self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIndex"))))
(define (nsview-accessibility-insertion-point-line-number self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityInsertionPointLineNumber"))))
(define (nsview-accessibility-label self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabel"))))
   ))
(define (nsview-accessibility-label-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelUIElements"))))
   ))
(define (nsview-accessibility-label-value self)
  (aw_racket_msg_0_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelValue"))))
(define (nsview-accessibility-layout-point-for-screen-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutPointForScreenPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsview-accessibility-layout-size-for-screen-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutSizeForScreenSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsview-accessibility-line-for-index self index)
  (aw_racket_msg_q_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLineForIndex:")) index))
(define (nsview-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLinkedUIElements"))))
   ))
(define (nsview-accessibility-main-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMainWindow"))))
   ))
(define (nsview-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerGroupUIElement"))))
   ))
(define (nsview-accessibility-marker-type-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerTypeDescription"))))
   ))
(define (nsview-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerUIElements"))))
   ))
(define (nsview-accessibility-marker-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerValues"))))
   ))
(define (nsview-accessibility-max-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMaxValue"))))
   ))
(define (nsview-accessibility-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMenuBar"))))
   ))
(define (nsview-accessibility-min-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinValue"))))
   ))
(define (nsview-accessibility-minimize-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinimizeButton"))))
   ))
(define (nsview-accessibility-next-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNextContents"))))
   ))
(define (nsview-accessibility-number-of-characters self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNumberOfCharacters"))))
(define (nsview-accessibility-orientation self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOrientation"))))
(define (nsview-accessibility-overflow-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOverflowButton"))))
   ))
(define (nsview-accessibility-parent self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityParent"))))
   ))
(define (nsview-accessibility-perform-cancel self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformCancel"))))
(define (nsview-accessibility-perform-confirm self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformConfirm"))))
(define (nsview-accessibility-perform-decrement self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDecrement"))))
(define (nsview-accessibility-perform-delete self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDelete"))))
(define (nsview-accessibility-perform-increment self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformIncrement"))))
(define (nsview-accessibility-perform-pick self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPick"))))
(define (nsview-accessibility-perform-press self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPress"))))
(define (nsview-accessibility-perform-raise self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformRaise"))))
(define (nsview-accessibility-perform-show-alternate-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowAlternateUI"))))
(define (nsview-accessibility-perform-show-default-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowDefaultUI"))))
(define (nsview-accessibility-perform-show-menu self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowMenu"))))
(define (nsview-accessibility-placeholder-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPlaceholderValue"))))
   ))
(define (nsview-accessibility-previous-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPreviousContents"))))
   ))
(define (nsview-accessibility-proxy self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityProxy"))))
   ))
(define (nsview-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRTFForRange:")) (id->ffi2-ptr range)))
   ))
(define (nsview-accessibility-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsview-accessibility-range-for-line self line)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForLine:")) line (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsview-accessibility-range-for-position self point)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_O_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForPosition:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsview-accessibility-role self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRole"))))
   ))
(define (nsview-accessibility-role-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRoleDescription"))))
   ))
(define (nsview-accessibility-row-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowCount"))))
(define (nsview-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowHeaderUIElements"))))
   ))
(define (nsview-accessibility-row-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsview-accessibility-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRows"))))
   ))
(define (nsview-accessibility-ruler-marker-type self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRulerMarkerType"))))
(define (nsview-accessibility-screen-point-for-layout-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenPointForLayoutPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsview-accessibility-screen-size-for-layout-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenSizeForLayoutSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsview-accessibility-search-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchButton"))))
   ))
(define (nsview-accessibility-search-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchMenu"))))
   ))
(define (nsview-accessibility-selected-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedCells"))))
   ))
(define (nsview-accessibility-selected-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedChildren"))))
   ))
(define (nsview-accessibility-selected-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedColumns"))))
   ))
(define (nsview-accessibility-selected-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedRows"))))
   ))
(define (nsview-accessibility-selected-text self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedText"))))
   ))
(define (nsview-accessibility-selected-text-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsview-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRanges"))))
   ))
(define (nsview-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityServesAsTitleForUIElements"))))
   ))
(define (nsview-accessibility-shared-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsview-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedFocusElements"))))
   ))
(define (nsview-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedTextUIElements"))))
   ))
(define (nsview-accessibility-shown-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityShownMenu"))))
   ))
(define (nsview-accessibility-sort-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySortDirection"))))
(define (nsview-accessibility-splitters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySplitters"))))
   ))
(define (nsview-accessibility-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nsview-accessibility-style-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStyleRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsview-accessibility-subrole self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySubrole"))))
   ))
(define (nsview-accessibility-tabs self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTabs"))))
   ))
(define (nsview-accessibility-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitle"))))
   ))
(define (nsview-accessibility-title-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitleUIElement"))))
   ))
(define (nsview-accessibility-toolbar-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityToolbarButton"))))
   ))
(define (nsview-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTopLevelUIElement"))))
   ))
(define (nsview-accessibility-url self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityURL"))))
   ))
(define (nsview-accessibility-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnitDescription"))))
   ))
(define (nsview-accessibility-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnits"))))
(define (nsview-accessibility-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUserInputLabels"))))
   ))
(define (nsview-accessibility-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValue"))))
   ))
(define (nsview-accessibility-value-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValueDescription"))))
   ))
(define (nsview-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalScrollBar"))))
   ))
(define (nsview-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnitDescription"))))
   ))
(define (nsview-accessibility-vertical-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnits"))))
(define (nsview-accessibility-visible-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCells"))))
   ))
(define (nsview-accessibility-visible-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsview-accessibility-visible-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleChildren"))))
   ))
(define (nsview-accessibility-visible-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleColumns"))))
   ))
(define (nsview-accessibility-visible-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleRows"))))
   ))
(define (nsview-accessibility-warning-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWarningValue"))))
   ))
(define (nsview-accessibility-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindow"))))
   ))
(define (nsview-accessibility-windows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindows"))))
   ))
(define (nsview-accessibility-zoom-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityZoomButton"))))
   ))
(define (nsview-add-constraint! self constraint)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addConstraint:")) (id->ffi2-ptr (coerce-arg constraint))))
(define (nsview-add-constraints! self constraints)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addConstraints:")) (id->ffi2-ptr (coerce-arg constraints))))
(define (nsview-add-cursor-rect-cursor! self rect object)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addCursorRect:cursor:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg object))))
(define (nsview-add-gesture-recognizer! self gesture-recognizer)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addGestureRecognizer:")) (id->ffi2-ptr (coerce-arg gesture-recognizer))))
(define (nsview-add-layout-guide! self guide)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addLayoutGuide:")) (id->ffi2-ptr (coerce-arg guide))))
(define (nsview-add-subview! self view)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addSubview:")) (id->ffi2-ptr (coerce-arg view))))
(define (nsview-add-subview-positioned-relative-to! self view place other-view)
  (aw_racket_msg_PqP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addSubview:positioned:relativeTo:")) (id->ffi2-ptr (coerce-arg view)) place (id->ffi2-ptr (coerce-arg other-view))))
(define (nsview-add-tool-tip-rect-owner-user-data! self rect owner data)
  (aw_racket_msg_RPP_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addToolTipRect:owner:userData:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg owner)) (id->ffi2-ptr data)))
(define (nsview-add-tracking-area! self tracking-area)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addTrackingArea:")) (id->ffi2-ptr (coerce-arg tracking-area))))
(define (nsview-add-tracking-rect-owner-user-data-assume-inside! self rect owner data flag)
  (aw_racket_msg_RPPb_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addTrackingRect:owner:userData:assumeInside:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg owner)) (id->ffi2-ptr data) flag))
(define (nsview-additional-safe-area-insets! self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "additionalSafeAreaInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nsview-adjust-page-height-new-top-bottom-limit self new-bottom old-top old-bottom bottom-limit)
  (aw_racket_msg_Pddd_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "adjustPageHeightNew:top:bottom:limit:")) (id->ffi2-ptr new-bottom) old-top old-bottom bottom-limit))
(define (nsview-adjust-page-width-new-left-right-limit self new-right old-left old-right right-limit)
  (aw_racket_msg_Pddd_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "adjustPageWidthNew:left:right:limit:")) (id->ffi2-ptr new-right) old-left old-right right-limit))
(define (nsview-adjust-scroll self new-visible)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "adjustScroll:")) (id->ffi2-ptr new-visible) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-alignment-rect-for-frame self frame)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignmentRectForFrame:")) (id->ffi2-ptr frame) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-ancestor-shared-with-view self view)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "ancestorSharedWithView:")) (id->ffi2-ptr (coerce-arg view))))
   ))
(define (nsview-animation-for-key self key)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animationForKey:")) (id->ffi2-ptr (coerce-arg key))))
   ))
(define (nsview-animations self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animations"))))
   ))
(define (nsview-animator self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animator"))))
   ))
(define (nsview-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "appearance"))))
   ))
(define (nsview-autoscroll self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoscroll:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-backing-aligned-rect-options self rect options)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RQ_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backingAlignedRect:options:")) (id->ffi2-ptr rect) options (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-become-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "becomeFirstResponder"))))
(define (nsview-begin-document! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginDocument"))))
(define (nsview-begin-dragging-session-with-items-event-source! self items event source)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginDraggingSessionWithItems:event:source:")) (id->ffi2-ptr (coerce-arg items)) (id->ffi2-ptr (coerce-arg event)) (id->ffi2-ptr (coerce-arg source))))
   ))
(define (nsview-begin-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-begin-page-in-rect-at-placement! self rect location)
  (aw_racket_msg_RO_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginPageInRect:atPlacement:")) (id->ffi2-ptr rect) (id->ffi2-ptr location)))
(define (nsview-bitmap-image-rep-for-caching-display-in-rect self rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bitmapImageRepForCachingDisplayInRect:")) (id->ffi2-ptr rect)))
   ))
(define (nsview-cache-display-in-rect-to-bitmap-image-rep self rect bitmap-image-rep)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cacheDisplayInRect:toBitmapImageRep:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg bitmap-image-rep))))
(define (nsview-cancel-operation self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cancelOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-capitalize-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "capitalizeWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-center-scan-rect! self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerScanRect:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-center-selection-in-visible-area! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerSelectionInVisibleArea:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-center-x-anchor! self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerXAnchor"))))
   ))
(define (nsview-center-y-anchor! self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerYAnchor"))))
   ))
(define (nsview-change-case-of-letter self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeCaseOfLetter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-change-mode-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeModeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-complete self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "complete:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-conclude-drag-operation self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "concludeDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-constraints-affecting-layout-for-orientation self orientation)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "constraintsAffectingLayoutForOrientation:")) orientation))
   ))
(define (nsview-content-compression-resistance-priority-for-orientation self orientation)
  (aw_racket_msg_q_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentCompressionResistancePriorityForOrientation:")) orientation))
(define (nsview-content-hugging-priority-for-orientation self orientation)
  (aw_racket_msg_q_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentHuggingPriorityForOrientation:")) orientation))
(define (nsview-context-menu-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contextMenuKeyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-convert-point-from-view self point view)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_OP_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPoint:fromView:")) (id->ffi2-ptr point) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsview-convert-point-to-view self point view)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_OP_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPoint:toView:")) (id->ffi2-ptr point) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsview-convert-point-from-backing self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointFromBacking:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsview-convert-point-from-layer self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointFromLayer:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsview-convert-point-to-backing self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointToBacking:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsview-convert-point-to-layer self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointToLayer:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsview-convert-rect-from-view self rect view)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RP_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRect:fromView:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-convert-rect-to-view self rect view)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RP_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRect:toView:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-convert-rect-from-backing self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectFromBacking:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-convert-rect-from-layer self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectFromLayer:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-convert-rect-to-backing self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectToBacking:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-convert-rect-to-layer self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectToLayer:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-convert-size-from-view self size view)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_ZP_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSize:fromView:")) (id->ffi2-ptr size) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsview-convert-size-to-view self size view)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_ZP_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSize:toView:")) (id->ffi2-ptr size) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsview-convert-size-from-backing self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeFromBacking:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsview-convert-size-from-layer self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeFromLayer:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsview-convert-size-to-backing self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeToBacking:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsview-convert-size-to-layer self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeToLayer:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsview-cursor-update self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cursorUpdate:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-data-with-eps-inside-rect self rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dataWithEPSInsideRect:")) (id->ffi2-ptr rect)))
   ))
(define (nsview-data-with-pdf-inside-rect self rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dataWithPDFInsideRect:")) (id->ffi2-ptr rect)))
   ))
(define (nsview-delete-backward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-delete-backward-by-decomposing-previous-character self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteBackwardByDecomposingPreviousCharacter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-delete-forward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-delete-to-beginning-of-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToBeginningOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-delete-to-beginning-of-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToBeginningOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-delete-to-end-of-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-delete-to-end-of-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToEndOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-delete-to-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-delete-word-backward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteWordBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-delete-word-forward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteWordForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-did-add-subview self subview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "didAddSubview:")) (id->ffi2-ptr (coerce-arg subview))))
(define (nsview-did-close-menu-with-event self menu event)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "didCloseMenu:withEvent:")) (id->ffi2-ptr (coerce-arg menu)) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-discard-cursor-rects self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "discardCursorRects"))))
(define (nsview-display! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "display"))))
(define (nsview-display-if-needed! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeeded"))))
(define (nsview-display-if-needed-ignoring-opacity! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededIgnoringOpacity"))))
(define (nsview-display-if-needed-in-rect! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededInRect:")) (id->ffi2-ptr rect)))
(define (nsview-display-if-needed-in-rect-ignoring-opacity! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededInRectIgnoringOpacity:")) (id->ffi2-ptr rect)))
(define (nsview-display-link-with-target-selector! self target selector)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayLinkWithTarget:selector:")) (id->ffi2-ptr (coerce-arg target)) (id->ffi2-ptr (sel_registerName selector))))
   ))
(define (nsview-display-rect! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRect:")) (id->ffi2-ptr rect)))
(define (nsview-display-rect-ignoring-opacity! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRectIgnoringOpacity:")) (id->ffi2-ptr rect)))
(define (nsview-display-rect-ignoring-opacity-in-context! self rect context)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRectIgnoringOpacity:inContext:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg context))))
(define (nsview-do-command-by-selector self selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "doCommandBySelector:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nsview-dragging-ended self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingEnded:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-dragging-entered self sender)
  (aw_racket_msg_P_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingEntered:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-dragging-exited self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingExited:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-dragging-updated self sender)
  (aw_racket_msg_P_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingUpdated:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-draw-focus-ring-mask self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawFocusRingMask"))))
(define (nsview-draw-page-border-with-size self border-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawPageBorderWithSize:")) (id->ffi2-ptr border-size)))
(define (nsview-draw-rect self dirty-rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawRect:")) (id->ffi2-ptr dirty-rect)))
(define (nsview-edge-insets-for-layout-region self layout-region)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_P_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "edgeInsetsForLayoutRegion:")) (id->ffi2-ptr (coerce-arg layout-region)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nsview-effective-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "effectiveAppearance"))))
   ))
(define (nsview-encode-restorable-state-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeRestorableStateWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nsview-encode-restorable-state-with-coder-background-queue self coder queue)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeRestorableStateWithCoder:backgroundQueue:")) (id->ffi2-ptr (coerce-arg coder)) (id->ffi2-ptr (coerce-arg queue))))
(define (nsview-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nsview-end-document! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endDocument"))))
(define (nsview-end-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-end-page! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endPage"))))
(define (nsview-enter-full-screen-mode-with-options self screen options)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enterFullScreenMode:withOptions:")) (id->ffi2-ptr (coerce-arg screen)) (id->ffi2-ptr (coerce-arg options))))
(define (nsview-exercise-ambiguity-in-layout self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "exerciseAmbiguityInLayout"))))
(define (nsview-exit-full-screen-mode-with-options self options)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "exitFullScreenModeWithOptions:")) (id->ffi2-ptr (coerce-arg options))))
(define (nsview-flags-changed self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flagsChanged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-flush-buffered-key-events self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flushBufferedKeyEvents"))))
(define (nsview-frame-for-alignment-rect self alignment-rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameForAlignmentRect:")) (id->ffi2-ptr alignment-rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-get-rects-being-drawn-count self rects count)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getRectsBeingDrawn:count:")) (id->ffi2-ptr rects) (id->ffi2-ptr count)))
(define (nsview-get-rects-exposed-during-live-resize-count self exposed-rects count)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getRectsExposedDuringLiveResize:count:")) (id->ffi2-ptr exposed-rects) (id->ffi2-ptr count)))
(define (nsview-help-requested self event-ptr)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "helpRequested:")) (id->ffi2-ptr (coerce-arg event-ptr))))
(define (nsview-hit-test self point)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_O_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hitTest:")) (id->ffi2-ptr point)))
   ))
(define (nsview-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "identifier"))))
   ))
(define (nsview-indent self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indent:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-insert-backtab! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertBacktab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-insert-container-break! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertContainerBreak:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-insert-double-quote-ignoring-substitution! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertDoubleQuoteIgnoringSubstitution:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-insert-line-break! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertLineBreak:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-insert-newline! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertNewline:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-insert-newline-ignoring-field-editor! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertNewlineIgnoringFieldEditor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-insert-paragraph-separator! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertParagraphSeparator:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-insert-single-quote-ignoring-substitution! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertSingleQuoteIgnoringSubstitution:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-insert-tab! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-insert-tab-ignoring-field-editor! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTabIgnoringFieldEditor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-insert-text! self insert-string)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertText:")) (id->ffi2-ptr (coerce-arg insert-string))))
(define (nsview-interpret-key-events self event-array)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "interpretKeyEvents:")) (id->ffi2-ptr (coerce-arg event-array))))
(define (nsview-invalidate-intrinsic-content-size self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "invalidateIntrinsicContentSize"))))
(define (nsview-invalidate-restorable-state self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "invalidateRestorableState"))))
(define (nsview-is-accessibility-alternate-ui-visible self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityAlternateUIVisible"))))
(define (nsview-is-accessibility-disclosed self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityDisclosed"))))
(define (nsview-is-accessibility-edited self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEdited"))))
(define (nsview-is-accessibility-element self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityElement"))))
(define (nsview-is-accessibility-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEnabled"))))
(define (nsview-is-accessibility-expanded self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityExpanded"))))
(define (nsview-is-accessibility-focused self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFocused"))))
(define (nsview-is-accessibility-frontmost self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFrontmost"))))
(define (nsview-is-accessibility-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityHidden"))))
(define (nsview-is-accessibility-main self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMain"))))
(define (nsview-is-accessibility-minimized self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMinimized"))))
(define (nsview-is-accessibility-modal self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityModal"))))
(define (nsview-is-accessibility-ordered-by-row self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityOrderedByRow"))))
(define (nsview-is-accessibility-protected-content self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityProtectedContent"))))
(define (nsview-is-accessibility-required self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityRequired"))))
(define (nsview-is-accessibility-selected self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelected"))))
(define (nsview-is-accessibility-selector-allowed self selector)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelectorAllowed:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nsview-is-descendant-of self view)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isDescendantOf:")) (id->ffi2-ptr (coerce-arg view))))
(define (nsview-is-drawing-find-indicator self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isDrawingFindIndicator"))))
(define (nsview-is-flipped self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isFlipped"))))
(define (nsview-is-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHidden"))))
(define (nsview-is-hidden-or-has-hidden-ancestor self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHiddenOrHasHiddenAncestor"))))
(define (nsview-is-horizontal-content-size-constraint-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHorizontalContentSizeConstraintActive"))))
(define (nsview-is-in-full-screen-mode self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isInFullScreenMode"))))
(define (nsview-is-opaque self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isOpaque"))))
(define (nsview-is-rotated-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRotatedFromBase"))))
(define (nsview-is-rotated-or-scaled-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRotatedOrScaledFromBase"))))
(define (nsview-is-vertical-content-size-constraint-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isVerticalContentSizeConstraintActive"))))
(define (nsview-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-key-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-knows-page-range self range)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "knowsPageRange:")) (id->ffi2-ptr range)))
(define (nsview-layout self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layout"))))
(define (nsview-layout-guide-for-layout-region self layout-region)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutGuideForLayoutRegion:")) (id->ffi2-ptr (coerce-arg layout-region))))
   ))
(define (nsview-layout-subtree-if-needed self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutSubtreeIfNeeded"))))
(define (nsview-location-of-print-rect self rect)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_R_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "locationOfPrintRect:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsview-lowercase-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lowercaseWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "magnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-make-backing-layer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBackingLayer"))))
   ))
(define (nsview-make-base-writing-direction-left-to-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionLeftToRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-make-base-writing-direction-natural self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionNatural:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-make-base-writing-direction-right-to-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionRightToLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-make-text-writing-direction-left-to-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionLeftToRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-make-text-writing-direction-natural self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionNatural:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-make-text-writing-direction-right-to-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionRightToLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-make-touch-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTouchBar"))))
   ))
(define (nsview-menu-for-event self event)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menuForEvent:")) (id->ffi2-ptr (coerce-arg event))))
   ))
(define (nsview-mouse-in-rect self point rect)
  (aw_racket_msg_OR_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouse:inRect:")) (id->ffi2-ptr point) (id->ffi2-ptr rect)))
(define (nsview-mouse-cancelled self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseCancelled:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-mouse-entered self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseEntered:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-mouse-exited self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseExited:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-mouse-moved self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseMoved:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-move-backward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-down! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-down-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveDownAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-forward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-left! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-left-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveLeftAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-paragraph-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveParagraphBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-paragraph-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveParagraphForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-right! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-right-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRightAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-to-beginning-of-document! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-to-beginning-of-document-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfDocumentAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-to-beginning-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-to-beginning-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-to-beginning-of-paragraph! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfParagraphAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-to-end-of-document! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-to-end-of-document-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfDocumentAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-to-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-to-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-to-end-of-paragraph! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-to-end-of-paragraph-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfParagraphAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-to-left-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToLeftEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-to-left-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToLeftEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-to-right-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToRightEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-to-right-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToRightEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-up! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-up-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveUpAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-word-backward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-word-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-word-forward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-word-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-word-left! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-word-left-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordLeftAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-word-right! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-move-word-right-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordRightAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-needs-to-draw-rect self rect)
  (aw_racket_msg_R_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsToDrawRect:")) (id->ffi2-ptr rect)))
(define (nsview-new-window-for-tab self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "newWindowForTab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-no-responder-for self event-selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "noResponderFor:")) (id->ffi2-ptr (sel_registerName event-selector))))
(define (nsview-note-focus-ring-mask-changed self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "noteFocusRingMaskChanged"))))
(define (nsview-other-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-other-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-other-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-page-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-page-down-and-modify-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageDownAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-page-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-page-up-and-modify-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageUpAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-perform-drag-operation! self sender)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-perform-key-equivalent! self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performKeyEquivalent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-perform-text-finder-action! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performTextFinderAction:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-prepare-content-in-rect self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareContentInRect:")) (id->ffi2-ptr rect)))
(define (nsview-prepare-for-drag-operation self sender)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareForDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-prepare-for-reuse self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareForReuse"))))
(define (nsview-present-error self error)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "presentError:")) (id->ffi2-ptr (coerce-arg error))))
;; param 2: weak reference
(define (nsview-present-error-modal-for-window-delegate-did-present-selector-context-info self error window delegate did-present-selector context-info)
  (aw_racket_msg_PPPPP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "presentError:modalForWindow:delegate:didPresentSelector:contextInfo:")) (id->ffi2-ptr (coerce-arg error)) (id->ffi2-ptr (coerce-arg window)) (id->ffi2-ptr (coerce-arg delegate)) (id->ffi2-ptr (sel_registerName did-present-selector)) (id->ffi2-ptr context-info)))
(define (nsview-pressure-change-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pressureChangeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-print self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "print:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-quick-look-preview-items self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookPreviewItems:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-quick-look-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-rect-for-layout-region self layout-region)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_P_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectForLayoutRegion:")) (id->ffi2-ptr (coerce-arg layout-region)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-rect-for-page self page)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_q_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectForPage:")) page (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-rect-for-smart-magnification-at-point-in-rect self location visible-rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_OR_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectForSmartMagnificationAtPoint:inRect:")) (id->ffi2-ptr location) (id->ffi2-ptr visible-rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsview-reflect-scrolled-clip-view self clip-view)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "reflectScrolledClipView:")) (id->ffi2-ptr (coerce-arg clip-view))))
(define (nsview-register-for-dragged-types self new-types)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "registerForDraggedTypes:")) (id->ffi2-ptr (coerce-arg new-types))))
(define (nsview-remove-all-tool-tips! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeAllToolTips"))))
(define (nsview-remove-constraint! self constraint)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeConstraint:")) (id->ffi2-ptr (coerce-arg constraint))))
(define (nsview-remove-constraints! self constraints)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeConstraints:")) (id->ffi2-ptr (coerce-arg constraints))))
(define (nsview-remove-cursor-rect-cursor! self rect object)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeCursorRect:cursor:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg object))))
(define (nsview-remove-from-superview! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeFromSuperview"))))
(define (nsview-remove-from-superview-without-needing-display! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeFromSuperviewWithoutNeedingDisplay"))))
(define (nsview-remove-gesture-recognizer! self gesture-recognizer)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeGestureRecognizer:")) (id->ffi2-ptr (coerce-arg gesture-recognizer))))
(define (nsview-remove-layout-guide! self guide)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeLayoutGuide:")) (id->ffi2-ptr (coerce-arg guide))))
(define (nsview-remove-tool-tip! self tag)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeToolTip:")) tag))
(define (nsview-remove-tracking-area! self tracking-area)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeTrackingArea:")) (id->ffi2-ptr (coerce-arg tracking-area))))
(define (nsview-remove-tracking-rect! self tag)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeTrackingRect:")) tag))
(define (nsview-replace-subview-with! self old-view new-view)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "replaceSubview:with:")) (id->ffi2-ptr (coerce-arg old-view)) (id->ffi2-ptr (coerce-arg new-view))))
(define (nsview-reset-cursor-rects! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resetCursorRects"))))
(define (nsview-resign-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resignFirstResponder"))))
(define (nsview-resize-subviews-with-old-size self old-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resizeSubviewsWithOldSize:")) (id->ffi2-ptr old-size)))
(define (nsview-resize-with-old-superview-size self old-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resizeWithOldSuperviewSize:")) (id->ffi2-ptr old-size)))
(define (nsview-restore-state-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "restoreStateWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nsview-restore-user-activity-state self user-activity)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "restoreUserActivityState:")) (id->ffi2-ptr (coerce-arg user-activity))))
(define (nsview-right-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-right-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-right-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-rotate-by-angle self angle)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotateByAngle:")) angle))
(define (nsview-rotate-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotateWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-ruler-view-did-add-marker self ruler marker)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:didAddMarker:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker))))
(define (nsview-ruler-view-did-move-marker self ruler marker)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:didMoveMarker:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker))))
(define (nsview-ruler-view-did-remove-marker self ruler marker)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:didRemoveMarker:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker))))
(define (nsview-ruler-view-handle-mouse-down self ruler event)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:handleMouseDown:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-ruler-view-location-for-point self ruler point)
  (aw_racket_msg_PO_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:locationForPoint:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr point)))
(define (nsview-ruler-view-point-for-location self ruler point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_Pd_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:pointForLocation:")) (id->ffi2-ptr (coerce-arg ruler)) point (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsview-ruler-view-should-add-marker self ruler marker)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:shouldAddMarker:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker))))
(define (nsview-ruler-view-should-move-marker self ruler marker)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:shouldMoveMarker:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker))))
(define (nsview-ruler-view-should-remove-marker self ruler marker)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:shouldRemoveMarker:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker))))
(define (nsview-ruler-view-will-add-marker-at-location self ruler marker location)
  (aw_racket_msg_PPd_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:willAddMarker:atLocation:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker)) location))
(define (nsview-ruler-view-will-move-marker-to-location self ruler marker location)
  (aw_racket_msg_PPd_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:willMoveMarker:toLocation:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker)) location))
(define (nsview-ruler-view-will-set-client-view self ruler new-client)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:willSetClientView:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg new-client))))
(define (nsview-scale-unit-square-to-size self new-unit-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scaleUnitSquareToSize:")) (id->ffi2-ptr new-unit-size)))
(define (nsview-scroll-clip-view-to-point self clip-view point)
  (aw_racket_msg_PO_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollClipView:toPoint:")) (id->ffi2-ptr (coerce-arg clip-view)) (id->ffi2-ptr point)))
(define (nsview-scroll-line-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollLineDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-scroll-line-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollLineUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-scroll-page-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPageDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-scroll-page-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPageUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-scroll-point self point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPoint:")) (id->ffi2-ptr point)))
(define (nsview-scroll-rect-to-visible self rect)
  (aw_racket_msg_R_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollRectToVisible:")) (id->ffi2-ptr rect)))
(define (nsview-scroll-to-beginning-of-document self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollToBeginningOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-scroll-to-end-of-document self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollToEndOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-scroll-wheel self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollWheel:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-select-all self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectAll:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-select-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-select-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-select-to-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectToMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-select-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-set-accessibility-activation-point! self accessibility-activation-point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityActivationPoint:")) (id->ffi2-ptr accessibility-activation-point)))
(define (nsview-set-accessibility-allowed-values! self accessibility-allowed-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAllowedValues:")) (id->ffi2-ptr (coerce-arg accessibility-allowed-values))))
(define (nsview-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAlternateUIVisible:")) accessibility-alternate-ui-visible))
(define (nsview-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityApplicationFocusedUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-application-focused-ui-element))))
(define (nsview-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAttributedUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-attributed-user-input-labels))))
(define (nsview-set-accessibility-cancel-button! self accessibility-cancel-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCancelButton:")) (id->ffi2-ptr (coerce-arg accessibility-cancel-button))))
(define (nsview-set-accessibility-children! self accessibility-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildren:")) (id->ffi2-ptr (coerce-arg accessibility-children))))
(define (nsview-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildrenInNavigationOrder:")) (id->ffi2-ptr (coerce-arg accessibility-children-in-navigation-order))))
(define (nsview-set-accessibility-clear-button! self accessibility-clear-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityClearButton:")) (id->ffi2-ptr (coerce-arg accessibility-clear-button))))
(define (nsview-set-accessibility-close-button! self accessibility-close-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCloseButton:")) (id->ffi2-ptr (coerce-arg accessibility-close-button))))
(define (nsview-set-accessibility-column-count! self accessibility-column-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnCount:")) accessibility-column-count))
(define (nsview-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-column-header-ui-elements))))
(define (nsview-set-accessibility-column-index-range! self accessibility-column-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnIndexRange:")) (id->ffi2-ptr accessibility-column-index-range)))
(define (nsview-set-accessibility-column-titles! self accessibility-column-titles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnTitles:")) (id->ffi2-ptr (coerce-arg accessibility-column-titles))))
(define (nsview-set-accessibility-columns! self accessibility-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumns:")) (id->ffi2-ptr (coerce-arg accessibility-columns))))
(define (nsview-set-accessibility-contents! self accessibility-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityContents:")) (id->ffi2-ptr (coerce-arg accessibility-contents))))
(define (nsview-set-accessibility-critical-value! self accessibility-critical-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCriticalValue:")) (id->ffi2-ptr (coerce-arg accessibility-critical-value))))
(define (nsview-set-accessibility-custom-actions! self accessibility-custom-actions)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomActions:")) (id->ffi2-ptr (coerce-arg accessibility-custom-actions))))
(define (nsview-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomRotors:")) (id->ffi2-ptr (coerce-arg accessibility-custom-rotors))))
(define (nsview-set-accessibility-decrement-button! self accessibility-decrement-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDecrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-decrement-button))))
(define (nsview-set-accessibility-default-button! self accessibility-default-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDefaultButton:")) (id->ffi2-ptr (coerce-arg accessibility-default-button))))
(define (nsview-set-accessibility-disclosed! self accessibility-disclosed)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosed:")) accessibility-disclosed))
(define (nsview-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedByRow:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-by-row))))
(define (nsview-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedRows:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-rows))))
(define (nsview-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosureLevel:")) accessibility-disclosure-level))
(define (nsview-set-accessibility-document! self accessibility-document)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDocument:")) (id->ffi2-ptr (coerce-arg accessibility-document))))
(define (nsview-set-accessibility-edited! self accessibility-edited)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEdited:")) accessibility-edited))
(define (nsview-set-accessibility-element! self accessibility-element)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityElement:")) accessibility-element))
(define (nsview-set-accessibility-enabled! self accessibility-enabled)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEnabled:")) accessibility-enabled))
(define (nsview-set-accessibility-expanded! self accessibility-expanded)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExpanded:")) accessibility-expanded))
(define (nsview-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExtrasMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-extras-menu-bar))))
(define (nsview-set-accessibility-filename! self accessibility-filename)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFilename:")) (id->ffi2-ptr (coerce-arg accessibility-filename))))
(define (nsview-set-accessibility-focused! self accessibility-focused)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocused:")) accessibility-focused))
(define (nsview-set-accessibility-focused-window! self accessibility-focused-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocusedWindow:")) (id->ffi2-ptr (coerce-arg accessibility-focused-window))))
(define (nsview-set-accessibility-frame! self accessibility-frame)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrame:")) (id->ffi2-ptr accessibility-frame)))
(define (nsview-set-accessibility-frontmost! self accessibility-frontmost)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrontmost:")) accessibility-frontmost))
(define (nsview-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFullScreenButton:")) (id->ffi2-ptr (coerce-arg accessibility-full-screen-button))))
(define (nsview-set-accessibility-grow-area! self accessibility-grow-area)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityGrowArea:")) (id->ffi2-ptr (coerce-arg accessibility-grow-area))))
(define (nsview-set-accessibility-handles! self accessibility-handles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHandles:")) (id->ffi2-ptr (coerce-arg accessibility-handles))))
(define (nsview-set-accessibility-header! self accessibility-header)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHeader:")) (id->ffi2-ptr (coerce-arg accessibility-header))))
(define (nsview-set-accessibility-help! self accessibility-help)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHelp:")) (id->ffi2-ptr (coerce-arg accessibility-help))))
(define (nsview-set-accessibility-hidden! self accessibility-hidden)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHidden:")) accessibility-hidden))
(define (nsview-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-scroll-bar))))
(define (nsview-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-unit-description))))
(define (nsview-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnits:")) accessibility-horizontal-units))
(define (nsview-set-accessibility-identifier! self accessibility-identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIdentifier:")) (id->ffi2-ptr (coerce-arg accessibility-identifier))))
(define (nsview-set-accessibility-increment-button! self accessibility-increment-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIncrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-increment-button))))
(define (nsview-set-accessibility-index! self accessibility-index)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIndex:")) accessibility-index))
(define (nsview-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityInsertionPointLineNumber:")) accessibility-insertion-point-line-number))
(define (nsview-set-accessibility-label! self accessibility-label)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabel:")) (id->ffi2-ptr (coerce-arg accessibility-label))))
(define (nsview-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-label-ui-elements))))
(define (nsview-set-accessibility-label-value! self accessibility-label-value)
  (aw_racket_msg_f_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelValue:")) accessibility-label-value))
(define (nsview-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLinkedUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-linked-ui-elements))))
(define (nsview-set-accessibility-main! self accessibility-main)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMain:")) accessibility-main))
(define (nsview-set-accessibility-main-window! self accessibility-main-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMainWindow:")) (id->ffi2-ptr (coerce-arg accessibility-main-window))))
(define (nsview-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerGroupUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-marker-group-ui-element))))
(define (nsview-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerTypeDescription:")) (id->ffi2-ptr (coerce-arg accessibility-marker-type-description))))
(define (nsview-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-marker-ui-elements))))
(define (nsview-set-accessibility-marker-values! self accessibility-marker-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerValues:")) (id->ffi2-ptr (coerce-arg accessibility-marker-values))))
(define (nsview-set-accessibility-max-value! self accessibility-max-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMaxValue:")) (id->ffi2-ptr (coerce-arg accessibility-max-value))))
(define (nsview-set-accessibility-menu-bar! self accessibility-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-menu-bar))))
(define (nsview-set-accessibility-min-value! self accessibility-min-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinValue:")) (id->ffi2-ptr (coerce-arg accessibility-min-value))))
(define (nsview-set-accessibility-minimize-button! self accessibility-minimize-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimizeButton:")) (id->ffi2-ptr (coerce-arg accessibility-minimize-button))))
(define (nsview-set-accessibility-minimized! self accessibility-minimized)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimized:")) accessibility-minimized))
(define (nsview-set-accessibility-modal! self accessibility-modal)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityModal:")) accessibility-modal))
(define (nsview-set-accessibility-next-contents! self accessibility-next-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNextContents:")) (id->ffi2-ptr (coerce-arg accessibility-next-contents))))
(define (nsview-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNumberOfCharacters:")) accessibility-number-of-characters))
(define (nsview-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrderedByRow:")) accessibility-ordered-by-row))
(define (nsview-set-accessibility-orientation! self accessibility-orientation)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrientation:")) accessibility-orientation))
(define (nsview-set-accessibility-overflow-button! self accessibility-overflow-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOverflowButton:")) (id->ffi2-ptr (coerce-arg accessibility-overflow-button))))
(define (nsview-set-accessibility-parent! self accessibility-parent)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityParent:")) (id->ffi2-ptr (coerce-arg accessibility-parent))))
(define (nsview-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPlaceholderValue:")) (id->ffi2-ptr (coerce-arg accessibility-placeholder-value))))
(define (nsview-set-accessibility-previous-contents! self accessibility-previous-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPreviousContents:")) (id->ffi2-ptr (coerce-arg accessibility-previous-contents))))
(define (nsview-set-accessibility-protected-content! self accessibility-protected-content)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProtectedContent:")) accessibility-protected-content))
(define (nsview-set-accessibility-proxy! self accessibility-proxy)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProxy:")) (id->ffi2-ptr (coerce-arg accessibility-proxy))))
(define (nsview-set-accessibility-required! self accessibility-required)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRequired:")) accessibility-required))
(define (nsview-set-accessibility-role! self accessibility-role)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRole:")) (id->ffi2-ptr (coerce-arg accessibility-role))))
(define (nsview-set-accessibility-role-description! self accessibility-role-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRoleDescription:")) (id->ffi2-ptr (coerce-arg accessibility-role-description))))
(define (nsview-set-accessibility-row-count! self accessibility-row-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowCount:")) accessibility-row-count))
(define (nsview-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-row-header-ui-elements))))
(define (nsview-set-accessibility-row-index-range! self accessibility-row-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowIndexRange:")) (id->ffi2-ptr accessibility-row-index-range)))
(define (nsview-set-accessibility-rows! self accessibility-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRows:")) (id->ffi2-ptr (coerce-arg accessibility-rows))))
(define (nsview-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRulerMarkerType:")) accessibility-ruler-marker-type))
(define (nsview-set-accessibility-search-button! self accessibility-search-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchButton:")) (id->ffi2-ptr (coerce-arg accessibility-search-button))))
(define (nsview-set-accessibility-search-menu! self accessibility-search-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchMenu:")) (id->ffi2-ptr (coerce-arg accessibility-search-menu))))
(define (nsview-set-accessibility-selected! self accessibility-selected)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelected:")) accessibility-selected))
(define (nsview-set-accessibility-selected-cells! self accessibility-selected-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedCells:")) (id->ffi2-ptr (coerce-arg accessibility-selected-cells))))
(define (nsview-set-accessibility-selected-children! self accessibility-selected-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedChildren:")) (id->ffi2-ptr (coerce-arg accessibility-selected-children))))
(define (nsview-set-accessibility-selected-columns! self accessibility-selected-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedColumns:")) (id->ffi2-ptr (coerce-arg accessibility-selected-columns))))
(define (nsview-set-accessibility-selected-rows! self accessibility-selected-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedRows:")) (id->ffi2-ptr (coerce-arg accessibility-selected-rows))))
(define (nsview-set-accessibility-selected-text! self accessibility-selected-text)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedText:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text))))
(define (nsview-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRange:")) (id->ffi2-ptr accessibility-selected-text-range)))
(define (nsview-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRanges:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text-ranges))))
(define (nsview-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityServesAsTitleForUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-serves-as-title-for-ui-elements))))
(define (nsview-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedCharacterRange:")) (id->ffi2-ptr accessibility-shared-character-range)))
(define (nsview-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedFocusElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-focus-elements))))
(define (nsview-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedTextUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-text-ui-elements))))
(define (nsview-set-accessibility-shown-menu! self accessibility-shown-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityShownMenu:")) (id->ffi2-ptr (coerce-arg accessibility-shown-menu))))
(define (nsview-set-accessibility-sort-direction! self accessibility-sort-direction)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySortDirection:")) accessibility-sort-direction))
(define (nsview-set-accessibility-splitters! self accessibility-splitters)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySplitters:")) (id->ffi2-ptr (coerce-arg accessibility-splitters))))
(define (nsview-set-accessibility-subrole! self accessibility-subrole)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySubrole:")) (id->ffi2-ptr (coerce-arg accessibility-subrole))))
(define (nsview-set-accessibility-tabs! self accessibility-tabs)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTabs:")) (id->ffi2-ptr (coerce-arg accessibility-tabs))))
(define (nsview-set-accessibility-title! self accessibility-title)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitle:")) (id->ffi2-ptr (coerce-arg accessibility-title))))
(define (nsview-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitleUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-title-ui-element))))
(define (nsview-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityToolbarButton:")) (id->ffi2-ptr (coerce-arg accessibility-toolbar-button))))
(define (nsview-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTopLevelUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-top-level-ui-element))))
(define (nsview-set-accessibility-url! self accessibility-url)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityURL:")) (id->ffi2-ptr (coerce-arg accessibility-url))))
(define (nsview-set-accessibility-unit-description! self accessibility-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-unit-description))))
(define (nsview-set-accessibility-units! self accessibility-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnits:")) accessibility-units))
(define (nsview-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-user-input-labels))))
(define (nsview-set-accessibility-value! self accessibility-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValue:")) (id->ffi2-ptr (coerce-arg accessibility-value))))
(define (nsview-set-accessibility-value-description! self accessibility-value-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValueDescription:")) (id->ffi2-ptr (coerce-arg accessibility-value-description))))
(define (nsview-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-scroll-bar))))
(define (nsview-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-unit-description))))
(define (nsview-set-accessibility-vertical-units! self accessibility-vertical-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnits:")) accessibility-vertical-units))
(define (nsview-set-accessibility-visible-cells! self accessibility-visible-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCells:")) (id->ffi2-ptr (coerce-arg accessibility-visible-cells))))
(define (nsview-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCharacterRange:")) (id->ffi2-ptr accessibility-visible-character-range)))
(define (nsview-set-accessibility-visible-children! self accessibility-visible-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleChildren:")) (id->ffi2-ptr (coerce-arg accessibility-visible-children))))
(define (nsview-set-accessibility-visible-columns! self accessibility-visible-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleColumns:")) (id->ffi2-ptr (coerce-arg accessibility-visible-columns))))
(define (nsview-set-accessibility-visible-rows! self accessibility-visible-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleRows:")) (id->ffi2-ptr (coerce-arg accessibility-visible-rows))))
(define (nsview-set-accessibility-warning-value! self accessibility-warning-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWarningValue:")) (id->ffi2-ptr (coerce-arg accessibility-warning-value))))
(define (nsview-set-accessibility-window! self accessibility-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindow:")) (id->ffi2-ptr (coerce-arg accessibility-window))))
(define (nsview-set-accessibility-windows! self accessibility-windows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindows:")) (id->ffi2-ptr (coerce-arg accessibility-windows))))
(define (nsview-set-accessibility-zoom-button! self accessibility-zoom-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityZoomButton:")) (id->ffi2-ptr (coerce-arg accessibility-zoom-button))))
(define (nsview-set-animations! self animations)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAnimations:")) (id->ffi2-ptr (coerce-arg animations))))
(define (nsview-set-appearance! self appearance)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAppearance:")) (id->ffi2-ptr (coerce-arg appearance))))
(define (nsview-set-bounds-origin! self new-origin)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsOrigin:")) (id->ffi2-ptr new-origin)))
(define (nsview-set-bounds-size! self new-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsSize:")) (id->ffi2-ptr new-size)))
(define (nsview-set-content-compression-resistance-priority-for-orientation! self priority orientation)
  (aw_racket_msg_fq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentCompressionResistancePriority:forOrientation:")) priority orientation))
(define (nsview-set-content-hugging-priority-for-orientation! self priority orientation)
  (aw_racket_msg_fq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentHuggingPriority:forOrientation:")) priority orientation))
(define (nsview-set-frame-origin! self new-origin)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameOrigin:")) (id->ffi2-ptr new-origin)))
(define (nsview-set-frame-size! self new-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameSize:")) (id->ffi2-ptr new-size)))
(define (nsview-set-identifier! self identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIdentifier:")) (id->ffi2-ptr (coerce-arg identifier))))
(define (nsview-set-keyboard-focus-ring-needs-display-in-rect! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setKeyboardFocusRingNeedsDisplayInRect:")) (id->ffi2-ptr rect)))
(define (nsview-set-mark! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-set-needs-display-in-rect! self invalid-rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsDisplayInRect:")) (id->ffi2-ptr invalid-rect)))
(define (nsview-should-be-treated-as-ink-event self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldBeTreatedAsInkEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-should-delay-window-ordering-for-event self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldDelayWindowOrderingForEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-show-context-help self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextHelp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-show-context-menu-for-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextMenuForSelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-show-definition-for-attributed-string-at-point self attr-string text-baseline-origin)
  (aw_racket_msg_PO_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showDefinitionForAttributedString:atPoint:")) (id->ffi2-ptr (coerce-arg attr-string)) (id->ffi2-ptr text-baseline-origin)))
;; block param 3: stored (retained across calls)
(define (nsview-show-definition-for-attributed-string-range-options-baseline-origin-provider self attr-string target-range options origin-provider)
  (define-values (_blk3 _blk3-id)
    (make-objc-block origin-provider (list _NSRange) _NSPoint))
  (aw_racket_msg_PGPP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showDefinitionForAttributedString:range:options:baselineOriginProvider:")) (id->ffi2-ptr (coerce-arg attr-string)) (id->ffi2-ptr target-range) (id->ffi2-ptr (coerce-arg options)) (id->ffi2-ptr _blk3)))
(define (nsview-show-writing-tools self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showWritingTools:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-smart-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "smartMagnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-sort-subviews-using-function-context self compare context)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sortSubviewsUsingFunction:context:")) (id->ffi2-ptr compare) (id->ffi2-ptr context)))
(define (nsview-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "supplementalTargetForAction:sender:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg sender))))
   ))
(define (nsview-swap-with-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swapWithMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-swipe-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swipeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-tablet-point self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletPoint:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-tablet-proximity self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletProximity:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-touches-began-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesBeganWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-touches-cancelled-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesCancelledWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-touches-ended-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesEndedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-touches-moved-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesMovedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-translate-origin-to-point self translation)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translateOriginToPoint:")) (id->ffi2-ptr translation)))
(define (nsview-translate-rects-needing-display-in-rect-by self clip-rect delta)
  (aw_racket_msg_RZ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translateRectsNeedingDisplayInRect:by:")) (id->ffi2-ptr clip-rect) (id->ffi2-ptr delta)))
(define (nsview-transpose self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transpose:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-transpose-words self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transposeWords:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-try-to-perform-with self action object)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tryToPerform:with:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg object))))
(define (nsview-unregister-dragged-types self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "unregisterDraggedTypes"))))
(define (nsview-update-constraints self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateConstraints"))))
(define (nsview-update-constraints-for-subtree-if-needed self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateConstraintsForSubtreeIfNeeded"))))
(define (nsview-update-dragging-items-for-drag self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateDraggingItemsForDrag:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-update-layer self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateLayer"))))
(define (nsview-update-tracking-areas self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateTrackingAreas"))))
(define (nsview-update-user-activity-state self user-activity)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateUserActivityState:")) (id->ffi2-ptr (coerce-arg user-activity))))
(define (nsview-uppercase-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "uppercaseWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsview-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validRequestorForSendType:returnType:")) (id->ffi2-ptr (coerce-arg send-type)) (id->ffi2-ptr (coerce-arg return-type))))
   ))
(define (nsview-validate-proposed-first-responder-for-event self responder event)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validateProposedFirstResponder:forEvent:")) (id->ffi2-ptr (coerce-arg responder)) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-view-did-change-backing-properties self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidChangeBackingProperties"))))
(define (nsview-view-did-change-effective-appearance self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidChangeEffectiveAppearance"))))
(define (nsview-view-did-end-live-resize self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidEndLiveResize"))))
(define (nsview-view-did-hide self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidHide"))))
(define (nsview-view-did-move-to-superview self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidMoveToSuperview"))))
(define (nsview-view-did-move-to-window self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidMoveToWindow"))))
(define (nsview-view-did-unhide self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidUnhide"))))
(define (nsview-view-will-draw self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillDraw"))))
(define (nsview-view-will-move-to-superview self new-superview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillMoveToSuperview:")) (id->ffi2-ptr (coerce-arg new-superview))))
(define (nsview-view-will-move-to-window self new-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillMoveToWindow:")) (id->ffi2-ptr (coerce-arg new-window))))
(define (nsview-view-will-start-live-resize self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillStartLiveResize"))))
(define (nsview-view-with-tag self tag)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWithTag:")) tag))
   ))
(define (nsview-wants-forwarded-scroll-events-for-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsForwardedScrollEventsForAxis:")) axis))
(define (nsview-wants-periodic-dragging-updates self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsPeriodicDraggingUpdates"))))
(define (nsview-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:")) axis))
(define (nsview-will-open-menu-with-event self menu event)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "willOpenMenu:withEvent:")) (id->ffi2-ptr (coerce-arg menu)) (id->ffi2-ptr (coerce-arg event))))
(define (nsview-will-present-error self error)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "willPresentError:")) (id->ffi2-ptr (coerce-arg error))))
   ))
(define (nsview-will-remove-subview self subview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "willRemoveSubview:")) (id->ffi2-ptr (coerce-arg subview))))
(define (nsview-write-eps-inside-rect-to-pasteboard self rect pasteboard)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writeEPSInsideRect:toPasteboard:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg pasteboard))))
(define (nsview-write-pdf-inside-rect-to-pasteboard self rect pasteboard)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writePDFInsideRect:toPasteboard:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg pasteboard))))
(define (nsview-yank self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "yank:")) (id->ffi2-ptr (coerce-arg sender))))

;; --- Class methods ---
(define (nsview-allowed-classes-for-restorable-state-key-path key-path)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSView) (id->ffi2-ptr (sel_registerName "allowedClassesForRestorableStateKeyPath:")) (id->ffi2-ptr (coerce-arg key-path))))
   ))
(define (nsview-default-animation-for-key key)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSView) (id->ffi2-ptr (sel_registerName "defaultAnimationForKey:")) (id->ffi2-ptr (coerce-arg key))))
   ))
(define (nsview-is-compatible-with-responsive-scrolling)
  (aw_racket_msg_0_b (id->ffi2-ptr NSView) (id->ffi2-ptr (sel_registerName "isCompatibleWithResponsiveScrolling"))))
