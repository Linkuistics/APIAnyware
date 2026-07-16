#lang racket/base
;; Generated binding for NSStackView (AppKit)
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
(define (nsstackview? v) (objc-instance-of? v "NSStackView"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (nstextinputcontext? v) (objc-instance-of? v "NSTextInputContext"))
(define (nstouchbar? v) (objc-instance-of? v "NSTouchBar"))
(define (nsurl? v) (objc-instance-of? v "NSURL"))
(define (nsundomanager? v) (objc-instance-of? v "NSUndoManager"))
(define (nsuseractivity? v) (objc-instance-of? v "NSUserActivity"))
(define (nsview? v) (objc-instance-of? v "NSView"))
(define (nswindow? v) (objc-instance-of? v "NSWindow"))
(define (nswritingtoolscoordinator? v) (objc-instance-of? v "NSWritingToolsCoordinator"))
(provide NSStackView)
(provide/contract
  [make-nsstackview-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsstackview-init-with-frame (c-> any/c any/c)]
  [nsstackview-accepts-first-responder (c-> nsstackview? boolean?)]
  [nsstackview-accepts-touch-events (c-> nsstackview? boolean?)]
  [nsstackview-set-accepts-touch-events! (c-> nsstackview? boolean? void?)]
  [nsstackview-additional-safe-area-insets (c-> nsstackview? any/c)]
  [nsstackview-set-additional-safe-area-insets! (c-> nsstackview? any/c void?)]
  [nsstackview-alignment (c-> nsstackview? exact-integer?)]
  [nsstackview-set-alignment! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-alignment-rect-insets (c-> nsstackview? any/c)]
  [nsstackview-allowed-touch-types (c-> nsstackview? exact-nonnegative-integer?)]
  [nsstackview-set-allowed-touch-types! (c-> nsstackview? exact-nonnegative-integer? void?)]
  [nsstackview-allows-vibrancy (c-> nsstackview? boolean?)]
  [nsstackview-alpha-value (c-> nsstackview? real?)]
  [nsstackview-set-alpha-value! (c-> nsstackview? real? void?)]
  [nsstackview-arranged-subviews (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-autoresizes-subviews (c-> nsstackview? boolean?)]
  [nsstackview-set-autoresizes-subviews! (c-> nsstackview? boolean? void?)]
  [nsstackview-autoresizing-mask (c-> nsstackview? exact-nonnegative-integer?)]
  [nsstackview-set-autoresizing-mask! (c-> nsstackview? exact-nonnegative-integer? void?)]
  [nsstackview-background-filters (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-set-background-filters! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-baseline-offset-from-bottom (c-> nsstackview? real?)]
  [nsstackview-bottom-anchor (c-> nsstackview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsstackview-bounds (c-> nsstackview? any/c)]
  [nsstackview-set-bounds! (c-> nsstackview? any/c void?)]
  [nsstackview-bounds-rotation (c-> nsstackview? real?)]
  [nsstackview-set-bounds-rotation! (c-> nsstackview? real? void?)]
  [nsstackview-can-become-key-view (c-> nsstackview? boolean?)]
  [nsstackview-can-draw (c-> nsstackview? boolean?)]
  [nsstackview-can-draw-concurrently (c-> nsstackview? boolean?)]
  [nsstackview-set-can-draw-concurrently! (c-> nsstackview? boolean? void?)]
  [nsstackview-can-draw-subviews-into-layer (c-> nsstackview? boolean?)]
  [nsstackview-set-can-draw-subviews-into-layer! (c-> nsstackview? boolean? void?)]
  [nsstackview-candidate-list-touch-bar-item (c-> nsstackview? (or/c nscandidatelisttouchbaritem? objc-nil?))]
  [nsstackview-center-x-anchor (c-> nsstackview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsstackview-center-y-anchor (c-> nsstackview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsstackview-clips-to-bounds (c-> nsstackview? boolean?)]
  [nsstackview-set-clips-to-bounds! (c-> nsstackview? boolean? void?)]
  [nsstackview-compatible-with-responsive-scrolling (c-> boolean?)]
  [nsstackview-compositing-filter (c-> nsstackview? (or/c cifilter? objc-nil?))]
  [nsstackview-set-compositing-filter! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-constraints (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-content-filters (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-set-content-filters! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-default-focus-ring-type (c-> exact-nonnegative-integer?)]
  [nsstackview-default-menu (c-> (or/c nsmenu? objc-nil?))]
  [nsstackview-delegate (c-> nsstackview? any/c)]
  [nsstackview-set-delegate! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-detached-views (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-detaches-hidden-views (c-> nsstackview? boolean?)]
  [nsstackview-set-detaches-hidden-views! (c-> nsstackview? boolean? void?)]
  [nsstackview-distribution (c-> nsstackview? exact-integer?)]
  [nsstackview-set-distribution! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-drawing-find-indicator (c-> nsstackview? boolean?)]
  [nsstackview-edge-insets (c-> nsstackview? any/c)]
  [nsstackview-set-edge-insets! (c-> nsstackview? any/c void?)]
  [nsstackview-enclosing-menu-item (c-> nsstackview? (or/c nsmenuitem? objc-nil?))]
  [nsstackview-enclosing-scroll-view (c-> nsstackview? (or/c nsscrollview? objc-nil?))]
  [nsstackview-first-baseline-anchor (c-> nsstackview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsstackview-first-baseline-offset-from-top (c-> nsstackview? real?)]
  [nsstackview-fitting-size (c-> nsstackview? any/c)]
  [nsstackview-flipped (c-> nsstackview? boolean?)]
  [nsstackview-focus-ring-mask-bounds (c-> nsstackview? any/c)]
  [nsstackview-focus-ring-type (c-> nsstackview? exact-nonnegative-integer?)]
  [nsstackview-set-focus-ring-type! (c-> nsstackview? exact-nonnegative-integer? void?)]
  [nsstackview-focus-view (c-> (or/c nsview? objc-nil?))]
  [nsstackview-frame (c-> nsstackview? any/c)]
  [nsstackview-set-frame! (c-> nsstackview? any/c void?)]
  [nsstackview-frame-center-rotation (c-> nsstackview? real?)]
  [nsstackview-set-frame-center-rotation! (c-> nsstackview? real? void?)]
  [nsstackview-frame-rotation (c-> nsstackview? real?)]
  [nsstackview-set-frame-rotation! (c-> nsstackview? real? void?)]
  [nsstackview-gesture-recognizers (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-set-gesture-recognizers! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-has-ambiguous-layout (c-> nsstackview? boolean?)]
  [nsstackview-has-equal-spacing (c-> nsstackview? boolean?)]
  [nsstackview-set-has-equal-spacing! (c-> nsstackview? boolean? void?)]
  [nsstackview-height-adjust-limit (c-> nsstackview? real?)]
  [nsstackview-height-anchor (c-> nsstackview? (or/c nslayoutdimension? objc-nil?))]
  [nsstackview-hidden (c-> nsstackview? boolean?)]
  [nsstackview-set-hidden! (c-> nsstackview? boolean? void?)]
  [nsstackview-hidden-or-has-hidden-ancestor (c-> nsstackview? boolean?)]
  [nsstackview-horizontal-content-size-constraint-active (c-> nsstackview? boolean?)]
  [nsstackview-set-horizontal-content-size-constraint-active! (c-> nsstackview? boolean? void?)]
  [nsstackview-in-full-screen-mode (c-> nsstackview? boolean?)]
  [nsstackview-in-live-resize (c-> nsstackview? boolean?)]
  [nsstackview-input-context (c-> nsstackview? (or/c nstextinputcontext? objc-nil?))]
  [nsstackview-intrinsic-content-size (c-> nsstackview? any/c)]
  [nsstackview-last-baseline-anchor (c-> nsstackview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsstackview-last-baseline-offset-from-bottom (c-> nsstackview? real?)]
  [nsstackview-layer (c-> nsstackview? (or/c calayer? objc-nil?))]
  [nsstackview-set-layer! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-layer-contents-placement (c-> nsstackview? exact-integer?)]
  [nsstackview-set-layer-contents-placement! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-layer-contents-redraw-policy (c-> nsstackview? exact-integer?)]
  [nsstackview-set-layer-contents-redraw-policy! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-layer-uses-core-image-filters (c-> nsstackview? boolean?)]
  [nsstackview-set-layer-uses-core-image-filters! (c-> nsstackview? boolean? void?)]
  [nsstackview-layout-guides (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-layout-margins-guide (c-> nsstackview? (or/c nslayoutguide? objc-nil?))]
  [nsstackview-leading-anchor (c-> nsstackview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsstackview-left-anchor (c-> nsstackview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsstackview-menu (c-> nsstackview? (or/c nsmenu? objc-nil?))]
  [nsstackview-set-menu! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-mouse-down-can-move-window (c-> nsstackview? boolean?)]
  [nsstackview-needs-display (c-> nsstackview? boolean?)]
  [nsstackview-set-needs-display! (c-> nsstackview? boolean? void?)]
  [nsstackview-needs-layout (c-> nsstackview? boolean?)]
  [nsstackview-set-needs-layout! (c-> nsstackview? boolean? void?)]
  [nsstackview-needs-panel-to-become-key (c-> nsstackview? boolean?)]
  [nsstackview-needs-update-constraints (c-> nsstackview? boolean?)]
  [nsstackview-set-needs-update-constraints! (c-> nsstackview? boolean? void?)]
  [nsstackview-next-key-view (c-> nsstackview? (or/c nsview? objc-nil?))]
  [nsstackview-set-next-key-view! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-next-responder (c-> nsstackview? (or/c nsresponder? objc-nil?))]
  [nsstackview-set-next-responder! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-next-valid-key-view (c-> nsstackview? (or/c nsview? objc-nil?))]
  [nsstackview-opaque (c-> nsstackview? boolean?)]
  [nsstackview-opaque-ancestor (c-> nsstackview? (or/c nsview? objc-nil?))]
  [nsstackview-orientation (c-> nsstackview? exact-integer?)]
  [nsstackview-set-orientation! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-page-footer (c-> nsstackview? (or/c nsattributedstring? objc-nil?))]
  [nsstackview-page-header (c-> nsstackview? (or/c nsattributedstring? objc-nil?))]
  [nsstackview-posts-bounds-changed-notifications (c-> nsstackview? boolean?)]
  [nsstackview-set-posts-bounds-changed-notifications! (c-> nsstackview? boolean? void?)]
  [nsstackview-posts-frame-changed-notifications (c-> nsstackview? boolean?)]
  [nsstackview-set-posts-frame-changed-notifications! (c-> nsstackview? boolean? void?)]
  [nsstackview-prefers-compact-control-size-metrics (c-> nsstackview? boolean?)]
  [nsstackview-set-prefers-compact-control-size-metrics! (c-> nsstackview? boolean? void?)]
  [nsstackview-prepared-content-rect (c-> nsstackview? any/c)]
  [nsstackview-set-prepared-content-rect! (c-> nsstackview? any/c void?)]
  [nsstackview-preserves-content-during-live-resize (c-> nsstackview? boolean?)]
  [nsstackview-pressure-configuration (c-> nsstackview? (or/c nspressureconfiguration? objc-nil?))]
  [nsstackview-set-pressure-configuration! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-previous-key-view (c-> nsstackview? (or/c nsview? objc-nil?))]
  [nsstackview-previous-valid-key-view (c-> nsstackview? (or/c nsview? objc-nil?))]
  [nsstackview-print-job-title (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-rect-preserved-during-live-resize (c-> nsstackview? any/c)]
  [nsstackview-registered-dragged-types (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-requires-constraint-based-layout (c-> boolean?)]
  [nsstackview-restorable-state-key-paths (c-> (or/c nsarray? objc-nil?))]
  [nsstackview-right-anchor (c-> nsstackview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsstackview-rotated-from-base (c-> nsstackview? boolean?)]
  [nsstackview-rotated-or-scaled-from-base (c-> nsstackview? boolean?)]
  [nsstackview-safe-area-insets (c-> nsstackview? any/c)]
  [nsstackview-safe-area-layout-guide (c-> nsstackview? (or/c nslayoutguide? objc-nil?))]
  [nsstackview-safe-area-rect (c-> nsstackview? any/c)]
  [nsstackview-shadow (c-> nsstackview? (or/c nsshadow? objc-nil?))]
  [nsstackview-set-shadow! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-spacing (c-> nsstackview? real?)]
  [nsstackview-set-spacing! (c-> nsstackview? real? void?)]
  [nsstackview-subviews (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-set-subviews! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-superview (c-> nsstackview? (or/c nsview? objc-nil?))]
  [nsstackview-tag (c-> nsstackview? exact-integer?)]
  [nsstackview-tool-tip (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-set-tool-tip! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-top-anchor (c-> nsstackview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsstackview-touch-bar (c-> nsstackview? (or/c nstouchbar? objc-nil?))]
  [nsstackview-set-touch-bar! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-tracking-areas (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-trailing-anchor (c-> nsstackview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsstackview-translates-autoresizing-mask-into-constraints (c-> nsstackview? boolean?)]
  [nsstackview-set-translates-autoresizing-mask-into-constraints! (c-> nsstackview? boolean? void?)]
  [nsstackview-undo-manager (c-> nsstackview? (or/c nsundomanager? objc-nil?))]
  [nsstackview-user-activity (c-> nsstackview? (or/c nsuseractivity? objc-nil?))]
  [nsstackview-set-user-activity! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-user-interface-layout-direction (c-> nsstackview? exact-integer?)]
  [nsstackview-set-user-interface-layout-direction! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-vertical-content-size-constraint-active (c-> nsstackview? boolean?)]
  [nsstackview-set-vertical-content-size-constraint-active! (c-> nsstackview? boolean? void?)]
  [nsstackview-views (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-visible-rect (c-> nsstackview? any/c)]
  [nsstackview-wants-best-resolution-open-gl-surface (c-> nsstackview? boolean?)]
  [nsstackview-set-wants-best-resolution-open-gl-surface! (c-> nsstackview? boolean? void?)]
  [nsstackview-wants-default-clipping (c-> nsstackview? boolean?)]
  [nsstackview-wants-extended-dynamic-range-open-gl-surface (c-> nsstackview? boolean?)]
  [nsstackview-set-wants-extended-dynamic-range-open-gl-surface! (c-> nsstackview? boolean? void?)]
  [nsstackview-wants-layer (c-> nsstackview? boolean?)]
  [nsstackview-set-wants-layer! (c-> nsstackview? boolean? void?)]
  [nsstackview-wants-resting-touches (c-> nsstackview? boolean?)]
  [nsstackview-set-wants-resting-touches! (c-> nsstackview? boolean? void?)]
  [nsstackview-wants-update-layer (c-> nsstackview? boolean?)]
  [nsstackview-width-adjust-limit (c-> nsstackview? real?)]
  [nsstackview-width-anchor (c-> nsstackview? (or/c nslayoutdimension? objc-nil?))]
  [nsstackview-window (c-> nsstackview? (or/c nswindow? objc-nil?))]
  [nsstackview-writing-tools-coordinator (c-> nsstackview? (or/c nswritingtoolscoordinator? objc-nil?))]
  [nsstackview-set-writing-tools-coordinator! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-accepts-first-mouse (c-> nsstackview? (or/c string? objc-object? #f) boolean?)]
  [nsstackview-accessibility-activation-point (c-> nsstackview? any/c)]
  [nsstackview-accessibility-allowed-values (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-application-focused-ui-element (c-> nsstackview? any/c)]
  [nsstackview-accessibility-attributed-string-for-range (c-> nsstackview? any/c (or/c nsattributedstring? objc-nil?))]
  [nsstackview-accessibility-attributed-user-input-labels (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-cancel-button (c-> nsstackview? any/c)]
  [nsstackview-accessibility-cell-for-column-row (c-> nsstackview? exact-integer? exact-integer? any/c)]
  [nsstackview-accessibility-children (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-children-in-navigation-order (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-clear-button (c-> nsstackview? any/c)]
  [nsstackview-accessibility-close-button (c-> nsstackview? any/c)]
  [nsstackview-accessibility-column-count (c-> nsstackview? exact-integer?)]
  [nsstackview-accessibility-column-header-ui-elements (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-column-index-range (c-> nsstackview? any/c)]
  [nsstackview-accessibility-column-titles (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-columns (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-contents (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-critical-value (c-> nsstackview? any/c)]
  [nsstackview-accessibility-custom-actions (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-custom-rotors (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-decrement-button (c-> nsstackview? any/c)]
  [nsstackview-accessibility-default-button (c-> nsstackview? any/c)]
  [nsstackview-accessibility-disclosed-by-row (c-> nsstackview? any/c)]
  [nsstackview-accessibility-disclosed-rows (c-> nsstackview? any/c)]
  [nsstackview-accessibility-disclosure-level (c-> nsstackview? exact-integer?)]
  [nsstackview-accessibility-document (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-extras-menu-bar (c-> nsstackview? any/c)]
  [nsstackview-accessibility-filename (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-focused-window (c-> nsstackview? any/c)]
  [nsstackview-accessibility-frame (c-> nsstackview? any/c)]
  [nsstackview-accessibility-frame-for-range (c-> nsstackview? any/c any/c)]
  [nsstackview-accessibility-full-screen-button (c-> nsstackview? any/c)]
  [nsstackview-accessibility-grow-area (c-> nsstackview? any/c)]
  [nsstackview-accessibility-handles (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-header (c-> nsstackview? any/c)]
  [nsstackview-accessibility-help (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-horizontal-scroll-bar (c-> nsstackview? any/c)]
  [nsstackview-accessibility-horizontal-unit-description (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-horizontal-units (c-> nsstackview? exact-integer?)]
  [nsstackview-accessibility-identifier (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-increment-button (c-> nsstackview? any/c)]
  [nsstackview-accessibility-index (c-> nsstackview? exact-integer?)]
  [nsstackview-accessibility-insertion-point-line-number (c-> nsstackview? exact-integer?)]
  [nsstackview-accessibility-label (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-label-ui-elements (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-label-value (c-> nsstackview? real?)]
  [nsstackview-accessibility-layout-point-for-screen-point (c-> nsstackview? any/c any/c)]
  [nsstackview-accessibility-layout-size-for-screen-size (c-> nsstackview? any/c any/c)]
  [nsstackview-accessibility-line-for-index (c-> nsstackview? exact-integer? exact-integer?)]
  [nsstackview-accessibility-linked-ui-elements (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-main-window (c-> nsstackview? any/c)]
  [nsstackview-accessibility-marker-group-ui-element (c-> nsstackview? any/c)]
  [nsstackview-accessibility-marker-type-description (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-marker-ui-elements (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-marker-values (c-> nsstackview? any/c)]
  [nsstackview-accessibility-max-value (c-> nsstackview? any/c)]
  [nsstackview-accessibility-menu-bar (c-> nsstackview? any/c)]
  [nsstackview-accessibility-min-value (c-> nsstackview? any/c)]
  [nsstackview-accessibility-minimize-button (c-> nsstackview? any/c)]
  [nsstackview-accessibility-next-contents (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-number-of-characters (c-> nsstackview? exact-integer?)]
  [nsstackview-accessibility-orientation (c-> nsstackview? exact-integer?)]
  [nsstackview-accessibility-overflow-button (c-> nsstackview? any/c)]
  [nsstackview-accessibility-parent (c-> nsstackview? any/c)]
  [nsstackview-accessibility-perform-cancel (c-> nsstackview? boolean?)]
  [nsstackview-accessibility-perform-confirm (c-> nsstackview? boolean?)]
  [nsstackview-accessibility-perform-decrement (c-> nsstackview? boolean?)]
  [nsstackview-accessibility-perform-delete (c-> nsstackview? boolean?)]
  [nsstackview-accessibility-perform-increment (c-> nsstackview? boolean?)]
  [nsstackview-accessibility-perform-pick (c-> nsstackview? boolean?)]
  [nsstackview-accessibility-perform-press (c-> nsstackview? boolean?)]
  [nsstackview-accessibility-perform-raise (c-> nsstackview? boolean?)]
  [nsstackview-accessibility-perform-show-alternate-ui (c-> nsstackview? boolean?)]
  [nsstackview-accessibility-perform-show-default-ui (c-> nsstackview? boolean?)]
  [nsstackview-accessibility-perform-show-menu (c-> nsstackview? boolean?)]
  [nsstackview-accessibility-placeholder-value (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-previous-contents (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-proxy (c-> nsstackview? any/c)]
  [nsstackview-accessibility-rtf-for-range (c-> nsstackview? any/c (or/c nsdata? objc-nil?))]
  [nsstackview-accessibility-range-for-index (c-> nsstackview? exact-integer? any/c)]
  [nsstackview-accessibility-range-for-line (c-> nsstackview? exact-integer? any/c)]
  [nsstackview-accessibility-range-for-position (c-> nsstackview? any/c any/c)]
  [nsstackview-accessibility-role (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-role-description (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-row-count (c-> nsstackview? exact-integer?)]
  [nsstackview-accessibility-row-header-ui-elements (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-row-index-range (c-> nsstackview? any/c)]
  [nsstackview-accessibility-rows (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-ruler-marker-type (c-> nsstackview? exact-integer?)]
  [nsstackview-accessibility-screen-point-for-layout-point (c-> nsstackview? any/c any/c)]
  [nsstackview-accessibility-screen-size-for-layout-size (c-> nsstackview? any/c any/c)]
  [nsstackview-accessibility-search-button (c-> nsstackview? any/c)]
  [nsstackview-accessibility-search-menu (c-> nsstackview? any/c)]
  [nsstackview-accessibility-selected-cells (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-selected-children (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-selected-columns (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-selected-rows (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-selected-text (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-selected-text-range (c-> nsstackview? any/c)]
  [nsstackview-accessibility-selected-text-ranges (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-serves-as-title-for-ui-elements (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-shared-character-range (c-> nsstackview? any/c)]
  [nsstackview-accessibility-shared-focus-elements (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-shared-text-ui-elements (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-shown-menu (c-> nsstackview? any/c)]
  [nsstackview-accessibility-sort-direction (c-> nsstackview? exact-integer?)]
  [nsstackview-accessibility-splitters (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-string-for-range (c-> nsstackview? any/c (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-style-range-for-index (c-> nsstackview? exact-integer? any/c)]
  [nsstackview-accessibility-subrole (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-tabs (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-title (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-title-ui-element (c-> nsstackview? any/c)]
  [nsstackview-accessibility-toolbar-button (c-> nsstackview? any/c)]
  [nsstackview-accessibility-top-level-ui-element (c-> nsstackview? any/c)]
  [nsstackview-accessibility-url (c-> nsstackview? (or/c nsurl? objc-nil?))]
  [nsstackview-accessibility-unit-description (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-units (c-> nsstackview? exact-integer?)]
  [nsstackview-accessibility-user-input-labels (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-value (c-> nsstackview? any/c)]
  [nsstackview-accessibility-value-description (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-vertical-scroll-bar (c-> nsstackview? any/c)]
  [nsstackview-accessibility-vertical-unit-description (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-vertical-units (c-> nsstackview? exact-integer?)]
  [nsstackview-accessibility-visible-cells (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-visible-character-range (c-> nsstackview? any/c)]
  [nsstackview-accessibility-visible-children (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-visible-columns (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-visible-rows (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-warning-value (c-> nsstackview? any/c)]
  [nsstackview-accessibility-window (c-> nsstackview? any/c)]
  [nsstackview-accessibility-windows (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-zoom-button (c-> nsstackview? any/c)]
  [nsstackview-add-arranged-subview! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-add-constraint! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-add-constraints! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-add-cursor-rect-cursor! (c-> nsstackview? any/c (or/c string? objc-object? #f) void?)]
  [nsstackview-add-gesture-recognizer! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-add-layout-guide! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-add-subview! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-add-subview-positioned-relative-to! (c-> nsstackview? (or/c string? objc-object? #f) exact-integer? (or/c string? objc-object? #f) void?)]
  [nsstackview-add-tool-tip-rect-owner-user-data! (c-> nsstackview? any/c (or/c string? objc-object? #f) (or/c cpointer? #f) exact-integer?)]
  [nsstackview-add-tracking-area! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-add-tracking-rect-owner-user-data-assume-inside! (c-> nsstackview? any/c (or/c string? objc-object? #f) (or/c cpointer? #f) boolean? exact-integer?)]
  [nsstackview-add-view-in-gravity! (c-> nsstackview? (or/c string? objc-object? #f) exact-integer? void?)]
  [nsstackview-additional-safe-area-insets! (c-> nsstackview? any/c)]
  [nsstackview-adjust-page-height-new-top-bottom-limit (c-> nsstackview? (or/c cpointer? #f) real? real? real? void?)]
  [nsstackview-adjust-page-width-new-left-right-limit (c-> nsstackview? (or/c cpointer? #f) real? real? real? void?)]
  [nsstackview-adjust-scroll (c-> nsstackview? any/c any/c)]
  [nsstackview-alignment-rect-for-frame (c-> nsstackview? any/c any/c)]
  [nsstackview-ancestor-shared-with-view (c-> nsstackview? (or/c string? objc-object? #f) (or/c nsview? objc-nil?))]
  [nsstackview-animation-for-key (c-> nsstackview? (or/c string? objc-object? #f) any/c)]
  [nsstackview-animations (c-> nsstackview? (or/c nsdictionary? objc-nil?))]
  [nsstackview-animator (c-> nsstackview? any/c)]
  [nsstackview-appearance (c-> nsstackview? (or/c nsappearance? objc-nil?))]
  [nsstackview-autoscroll (c-> nsstackview? (or/c string? objc-object? #f) boolean?)]
  [nsstackview-backing-aligned-rect-options (c-> nsstackview? any/c exact-nonnegative-integer? any/c)]
  [nsstackview-become-first-responder (c-> nsstackview? boolean?)]
  [nsstackview-begin-document! (c-> nsstackview? void?)]
  [nsstackview-begin-dragging-session-with-items-event-source! (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c nsdraggingsession? objc-nil?))]
  [nsstackview-begin-gesture-with-event! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-begin-page-in-rect-at-placement! (c-> nsstackview? any/c any/c void?)]
  [nsstackview-bitmap-image-rep-for-caching-display-in-rect (c-> nsstackview? any/c (or/c nsbitmapimagerep? objc-nil?))]
  [nsstackview-cache-display-in-rect-to-bitmap-image-rep (c-> nsstackview? any/c (or/c string? objc-object? #f) void?)]
  [nsstackview-cancel-operation (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-capitalize-word (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-center-scan-rect! (c-> nsstackview? any/c any/c)]
  [nsstackview-center-selection-in-visible-area! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-center-x-anchor! (c-> nsstackview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsstackview-center-y-anchor! (c-> nsstackview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsstackview-change-case-of-letter (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-change-mode-with-event (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-clipping-resistance-priority-for-orientation (c-> nsstackview? exact-integer? real?)]
  [nsstackview-complete (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-conclude-drag-operation (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-constraints-affecting-layout-for-orientation (c-> nsstackview? exact-integer? (or/c nsarray? objc-nil?))]
  [nsstackview-content-compression-resistance-priority-for-orientation (c-> nsstackview? exact-integer? real?)]
  [nsstackview-content-hugging-priority-for-orientation (c-> nsstackview? exact-integer? real?)]
  [nsstackview-context-menu-key-down (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-convert-point-from-view (c-> nsstackview? any/c (or/c string? objc-object? #f) any/c)]
  [nsstackview-convert-point-to-view (c-> nsstackview? any/c (or/c string? objc-object? #f) any/c)]
  [nsstackview-convert-point-from-backing (c-> nsstackview? any/c any/c)]
  [nsstackview-convert-point-from-layer (c-> nsstackview? any/c any/c)]
  [nsstackview-convert-point-to-backing (c-> nsstackview? any/c any/c)]
  [nsstackview-convert-point-to-layer (c-> nsstackview? any/c any/c)]
  [nsstackview-convert-rect-from-view (c-> nsstackview? any/c (or/c string? objc-object? #f) any/c)]
  [nsstackview-convert-rect-to-view (c-> nsstackview? any/c (or/c string? objc-object? #f) any/c)]
  [nsstackview-convert-rect-from-backing (c-> nsstackview? any/c any/c)]
  [nsstackview-convert-rect-from-layer (c-> nsstackview? any/c any/c)]
  [nsstackview-convert-rect-to-backing (c-> nsstackview? any/c any/c)]
  [nsstackview-convert-rect-to-layer (c-> nsstackview? any/c any/c)]
  [nsstackview-convert-size-from-view (c-> nsstackview? any/c (or/c string? objc-object? #f) any/c)]
  [nsstackview-convert-size-to-view (c-> nsstackview? any/c (or/c string? objc-object? #f) any/c)]
  [nsstackview-convert-size-from-backing (c-> nsstackview? any/c any/c)]
  [nsstackview-convert-size-from-layer (c-> nsstackview? any/c any/c)]
  [nsstackview-convert-size-to-backing (c-> nsstackview? any/c any/c)]
  [nsstackview-convert-size-to-layer (c-> nsstackview? any/c any/c)]
  [nsstackview-cursor-update (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-custom-spacing-after-view (c-> nsstackview? (or/c string? objc-object? #f) real?)]
  [nsstackview-data-with-eps-inside-rect (c-> nsstackview? any/c (or/c nsdata? objc-nil?))]
  [nsstackview-data-with-pdf-inside-rect (c-> nsstackview? any/c (or/c nsdata? objc-nil?))]
  [nsstackview-delete-backward (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-delete-backward-by-decomposing-previous-character (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-delete-forward (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-delete-to-beginning-of-line (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-delete-to-beginning-of-paragraph (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-delete-to-end-of-line (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-delete-to-end-of-paragraph (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-delete-to-mark (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-delete-word-backward (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-delete-word-forward (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-did-add-subview (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-did-close-menu-with-event (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsstackview-discard-cursor-rects (c-> nsstackview? void?)]
  [nsstackview-display! (c-> nsstackview? void?)]
  [nsstackview-display-if-needed! (c-> nsstackview? void?)]
  [nsstackview-display-if-needed-ignoring-opacity! (c-> nsstackview? void?)]
  [nsstackview-display-if-needed-in-rect! (c-> nsstackview? any/c void?)]
  [nsstackview-display-if-needed-in-rect-ignoring-opacity! (c-> nsstackview? any/c void?)]
  [nsstackview-display-link-with-target-selector! (c-> nsstackview? (or/c string? objc-object? #f) string? (or/c cadisplaylink? objc-nil?))]
  [nsstackview-display-rect! (c-> nsstackview? any/c void?)]
  [nsstackview-display-rect-ignoring-opacity! (c-> nsstackview? any/c void?)]
  [nsstackview-display-rect-ignoring-opacity-in-context! (c-> nsstackview? any/c (or/c string? objc-object? #f) void?)]
  [nsstackview-do-command-by-selector (c-> nsstackview? string? void?)]
  [nsstackview-dragging-ended (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-dragging-entered (c-> nsstackview? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nsstackview-dragging-exited (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-dragging-updated (c-> nsstackview? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nsstackview-draw-focus-ring-mask (c-> nsstackview? void?)]
  [nsstackview-draw-page-border-with-size (c-> nsstackview? any/c void?)]
  [nsstackview-draw-rect (c-> nsstackview? any/c void?)]
  [nsstackview-edge-insets-for-layout-region (c-> nsstackview? (or/c string? objc-object? #f) any/c)]
  [nsstackview-effective-appearance (c-> nsstackview? (or/c nsappearance? objc-nil?))]
  [nsstackview-encode-restorable-state-with-coder (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-encode-restorable-state-with-coder-background-queue (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsstackview-encode-with-coder (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-end-document! (c-> nsstackview? void?)]
  [nsstackview-end-gesture-with-event! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-end-page! (c-> nsstackview? void?)]
  [nsstackview-enter-full-screen-mode-with-options (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nsstackview-exercise-ambiguity-in-layout (c-> nsstackview? void?)]
  [nsstackview-exit-full-screen-mode-with-options (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-flags-changed (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-flush-buffered-key-events (c-> nsstackview? void?)]
  [nsstackview-frame-for-alignment-rect (c-> nsstackview? any/c any/c)]
  [nsstackview-get-rects-being-drawn-count (c-> nsstackview? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nsstackview-get-rects-exposed-during-live-resize-count (c-> nsstackview? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nsstackview-help-requested (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-hit-test (c-> nsstackview? any/c (or/c nsview? objc-nil?))]
  [nsstackview-hugging-priority-for-orientation (c-> nsstackview? exact-integer? real?)]
  [nsstackview-identifier (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-indent (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-insert-arranged-subview-at-index! (c-> nsstackview? (or/c string? objc-object? #f) exact-integer? void?)]
  [nsstackview-insert-backtab! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-insert-container-break! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-insert-double-quote-ignoring-substitution! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-insert-line-break! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-insert-newline! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-insert-newline-ignoring-field-editor! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-insert-paragraph-separator! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-insert-single-quote-ignoring-substitution! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-insert-tab! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-insert-tab-ignoring-field-editor! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-insert-text! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-insert-view-at-index-in-gravity! (c-> nsstackview? (or/c string? objc-object? #f) exact-nonnegative-integer? exact-integer? void?)]
  [nsstackview-interpret-key-events (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-invalidate-intrinsic-content-size (c-> nsstackview? void?)]
  [nsstackview-invalidate-restorable-state (c-> nsstackview? void?)]
  [nsstackview-is-accessibility-alternate-ui-visible (c-> nsstackview? boolean?)]
  [nsstackview-is-accessibility-disclosed (c-> nsstackview? boolean?)]
  [nsstackview-is-accessibility-edited (c-> nsstackview? boolean?)]
  [nsstackview-is-accessibility-element (c-> nsstackview? boolean?)]
  [nsstackview-is-accessibility-enabled (c-> nsstackview? boolean?)]
  [nsstackview-is-accessibility-expanded (c-> nsstackview? boolean?)]
  [nsstackview-is-accessibility-focused (c-> nsstackview? boolean?)]
  [nsstackview-is-accessibility-frontmost (c-> nsstackview? boolean?)]
  [nsstackview-is-accessibility-hidden (c-> nsstackview? boolean?)]
  [nsstackview-is-accessibility-main (c-> nsstackview? boolean?)]
  [nsstackview-is-accessibility-minimized (c-> nsstackview? boolean?)]
  [nsstackview-is-accessibility-modal (c-> nsstackview? boolean?)]
  [nsstackview-is-accessibility-ordered-by-row (c-> nsstackview? boolean?)]
  [nsstackview-is-accessibility-protected-content (c-> nsstackview? boolean?)]
  [nsstackview-is-accessibility-required (c-> nsstackview? boolean?)]
  [nsstackview-is-accessibility-selected (c-> nsstackview? boolean?)]
  [nsstackview-is-accessibility-selector-allowed (c-> nsstackview? string? boolean?)]
  [nsstackview-is-descendant-of (c-> nsstackview? (or/c string? objc-object? #f) boolean?)]
  [nsstackview-is-drawing-find-indicator (c-> nsstackview? boolean?)]
  [nsstackview-is-flipped (c-> nsstackview? boolean?)]
  [nsstackview-is-hidden (c-> nsstackview? boolean?)]
  [nsstackview-is-hidden-or-has-hidden-ancestor (c-> nsstackview? boolean?)]
  [nsstackview-is-horizontal-content-size-constraint-active (c-> nsstackview? boolean?)]
  [nsstackview-is-in-full-screen-mode (c-> nsstackview? boolean?)]
  [nsstackview-is-opaque (c-> nsstackview? boolean?)]
  [nsstackview-is-rotated-from-base (c-> nsstackview? boolean?)]
  [nsstackview-is-rotated-or-scaled-from-base (c-> nsstackview? boolean?)]
  [nsstackview-is-vertical-content-size-constraint-active (c-> nsstackview? boolean?)]
  [nsstackview-key-down (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-key-up (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-knows-page-range (c-> nsstackview? (or/c cpointer? #f) boolean?)]
  [nsstackview-layout (c-> nsstackview? void?)]
  [nsstackview-layout-guide-for-layout-region (c-> nsstackview? (or/c string? objc-object? #f) (or/c nslayoutguide? objc-nil?))]
  [nsstackview-layout-subtree-if-needed (c-> nsstackview? void?)]
  [nsstackview-location-of-print-rect (c-> nsstackview? any/c any/c)]
  [nsstackview-lowercase-word (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-magnify-with-event (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-make-backing-layer (c-> nsstackview? (or/c calayer? objc-nil?))]
  [nsstackview-make-base-writing-direction-left-to-right (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-make-base-writing-direction-natural (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-make-base-writing-direction-right-to-left (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-make-text-writing-direction-left-to-right (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-make-text-writing-direction-natural (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-make-text-writing-direction-right-to-left (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-make-touch-bar (c-> nsstackview? (or/c nstouchbar? objc-nil?))]
  [nsstackview-menu-for-event (c-> nsstackview? (or/c string? objc-object? #f) (or/c nsmenu? objc-nil?))]
  [nsstackview-mouse-in-rect (c-> nsstackview? any/c any/c boolean?)]
  [nsstackview-mouse-cancelled (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-mouse-down (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-mouse-dragged (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-mouse-entered (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-mouse-exited (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-mouse-moved (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-mouse-up (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-backward! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-backward-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-down! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-down-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-forward! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-forward-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-left! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-left-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-paragraph-backward-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-paragraph-forward-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-right! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-right-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-to-beginning-of-document! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-to-beginning-of-document-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-to-beginning-of-line! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-to-beginning-of-line-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-to-beginning-of-paragraph! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-to-beginning-of-paragraph-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-to-end-of-document! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-to-end-of-document-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-to-end-of-line! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-to-end-of-line-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-to-end-of-paragraph! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-to-end-of-paragraph-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-to-left-end-of-line! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-to-left-end-of-line-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-to-right-end-of-line! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-to-right-end-of-line-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-up! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-up-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-word-backward! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-word-backward-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-word-forward! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-word-forward-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-word-left! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-word-left-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-word-right! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-move-word-right-and-modify-selection! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-needs-to-draw-rect (c-> nsstackview? any/c boolean?)]
  [nsstackview-new-window-for-tab (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-no-responder-for (c-> nsstackview? string? void?)]
  [nsstackview-note-focus-ring-mask-changed (c-> nsstackview? void?)]
  [nsstackview-other-mouse-down (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-other-mouse-dragged (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-other-mouse-up (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-page-down (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-page-down-and-modify-selection (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-page-up (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-page-up-and-modify-selection (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-perform-drag-operation! (c-> nsstackview? (or/c string? objc-object? #f) boolean?)]
  [nsstackview-perform-key-equivalent! (c-> nsstackview? (or/c string? objc-object? #f) boolean?)]
  [nsstackview-perform-text-finder-action! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-prepare-content-in-rect (c-> nsstackview? any/c void?)]
  [nsstackview-prepare-for-drag-operation (c-> nsstackview? (or/c string? objc-object? #f) boolean?)]
  [nsstackview-prepare-for-reuse (c-> nsstackview? void?)]
  [nsstackview-present-error (c-> nsstackview? (or/c string? objc-object? #f) boolean?)]
  [nsstackview-present-error-modal-for-window-delegate-did-present-selector-context-info (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) string? (or/c cpointer? #f) void?)]
  [nsstackview-pressure-change-with-event (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-print (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-quick-look-preview-items (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-quick-look-with-event (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-rect-for-layout-region (c-> nsstackview? (or/c string? objc-object? #f) any/c)]
  [nsstackview-rect-for-page (c-> nsstackview? exact-integer? any/c)]
  [nsstackview-rect-for-smart-magnification-at-point-in-rect (c-> nsstackview? any/c any/c any/c)]
  [nsstackview-reflect-scrolled-clip-view (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-register-for-dragged-types (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-remove-all-tool-tips! (c-> nsstackview? void?)]
  [nsstackview-remove-arranged-subview! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-remove-constraint! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-remove-constraints! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-remove-cursor-rect-cursor! (c-> nsstackview? any/c (or/c string? objc-object? #f) void?)]
  [nsstackview-remove-from-superview! (c-> nsstackview? void?)]
  [nsstackview-remove-from-superview-without-needing-display! (c-> nsstackview? void?)]
  [nsstackview-remove-gesture-recognizer! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-remove-layout-guide! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-remove-tool-tip! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-remove-tracking-area! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-remove-tracking-rect! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-remove-view! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-replace-subview-with! (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsstackview-reset-cursor-rects! (c-> nsstackview? void?)]
  [nsstackview-resign-first-responder (c-> nsstackview? boolean?)]
  [nsstackview-resize-subviews-with-old-size (c-> nsstackview? any/c void?)]
  [nsstackview-resize-with-old-superview-size (c-> nsstackview? any/c void?)]
  [nsstackview-restore-state-with-coder (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-restore-user-activity-state (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-right-mouse-down (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-right-mouse-dragged (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-right-mouse-up (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-rotate-by-angle (c-> nsstackview? real? void?)]
  [nsstackview-rotate-with-event (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-ruler-view-did-add-marker (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsstackview-ruler-view-did-move-marker (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsstackview-ruler-view-did-remove-marker (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsstackview-ruler-view-handle-mouse-down (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsstackview-ruler-view-location-for-point (c-> nsstackview? (or/c string? objc-object? #f) any/c real?)]
  [nsstackview-ruler-view-point-for-location (c-> nsstackview? (or/c string? objc-object? #f) real? any/c)]
  [nsstackview-ruler-view-should-add-marker (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nsstackview-ruler-view-should-move-marker (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nsstackview-ruler-view-should-remove-marker (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nsstackview-ruler-view-will-add-marker-at-location (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) real? real?)]
  [nsstackview-ruler-view-will-move-marker-to-location (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) real? real?)]
  [nsstackview-ruler-view-will-set-client-view (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsstackview-scale-unit-square-to-size (c-> nsstackview? any/c void?)]
  [nsstackview-scroll-clip-view-to-point (c-> nsstackview? (or/c string? objc-object? #f) any/c void?)]
  [nsstackview-scroll-line-down (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-scroll-line-up (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-scroll-page-down (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-scroll-page-up (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-scroll-point (c-> nsstackview? any/c void?)]
  [nsstackview-scroll-rect-to-visible (c-> nsstackview? any/c boolean?)]
  [nsstackview-scroll-to-beginning-of-document (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-scroll-to-end-of-document (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-scroll-wheel (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-select-all (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-select-line (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-select-paragraph (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-select-to-mark (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-select-word (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-activation-point! (c-> nsstackview? any/c void?)]
  [nsstackview-set-accessibility-allowed-values! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-alternate-ui-visible! (c-> nsstackview? boolean? void?)]
  [nsstackview-set-accessibility-application-focused-ui-element! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-attributed-user-input-labels! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-cancel-button! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-children! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-children-in-navigation-order! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-clear-button! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-close-button! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-column-count! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-set-accessibility-column-header-ui-elements! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-column-index-range! (c-> nsstackview? any/c void?)]
  [nsstackview-set-accessibility-column-titles! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-columns! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-contents! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-critical-value! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-custom-actions! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-custom-rotors! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-decrement-button! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-default-button! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-disclosed! (c-> nsstackview? boolean? void?)]
  [nsstackview-set-accessibility-disclosed-by-row! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-disclosed-rows! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-disclosure-level! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-set-accessibility-document! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-edited! (c-> nsstackview? boolean? void?)]
  [nsstackview-set-accessibility-element! (c-> nsstackview? boolean? void?)]
  [nsstackview-set-accessibility-enabled! (c-> nsstackview? boolean? void?)]
  [nsstackview-set-accessibility-expanded! (c-> nsstackview? boolean? void?)]
  [nsstackview-set-accessibility-extras-menu-bar! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-filename! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-focused! (c-> nsstackview? boolean? void?)]
  [nsstackview-set-accessibility-focused-window! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-frame! (c-> nsstackview? any/c void?)]
  [nsstackview-set-accessibility-frontmost! (c-> nsstackview? boolean? void?)]
  [nsstackview-set-accessibility-full-screen-button! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-grow-area! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-handles! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-header! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-help! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-hidden! (c-> nsstackview? boolean? void?)]
  [nsstackview-set-accessibility-horizontal-scroll-bar! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-horizontal-unit-description! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-horizontal-units! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-set-accessibility-identifier! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-increment-button! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-index! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-set-accessibility-insertion-point-line-number! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-set-accessibility-label! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-label-ui-elements! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-label-value! (c-> nsstackview? real? void?)]
  [nsstackview-set-accessibility-linked-ui-elements! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-main! (c-> nsstackview? boolean? void?)]
  [nsstackview-set-accessibility-main-window! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-marker-group-ui-element! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-marker-type-description! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-marker-ui-elements! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-marker-values! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-max-value! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-menu-bar! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-min-value! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-minimize-button! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-minimized! (c-> nsstackview? boolean? void?)]
  [nsstackview-set-accessibility-modal! (c-> nsstackview? boolean? void?)]
  [nsstackview-set-accessibility-next-contents! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-number-of-characters! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-set-accessibility-ordered-by-row! (c-> nsstackview? boolean? void?)]
  [nsstackview-set-accessibility-orientation! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-set-accessibility-overflow-button! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-parent! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-placeholder-value! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-previous-contents! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-protected-content! (c-> nsstackview? boolean? void?)]
  [nsstackview-set-accessibility-proxy! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-required! (c-> nsstackview? boolean? void?)]
  [nsstackview-set-accessibility-role! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-role-description! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-row-count! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-set-accessibility-row-header-ui-elements! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-row-index-range! (c-> nsstackview? any/c void?)]
  [nsstackview-set-accessibility-rows! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-ruler-marker-type! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-set-accessibility-search-button! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-search-menu! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-selected! (c-> nsstackview? boolean? void?)]
  [nsstackview-set-accessibility-selected-cells! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-selected-children! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-selected-columns! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-selected-rows! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-selected-text! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-selected-text-range! (c-> nsstackview? any/c void?)]
  [nsstackview-set-accessibility-selected-text-ranges! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-serves-as-title-for-ui-elements! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-shared-character-range! (c-> nsstackview? any/c void?)]
  [nsstackview-set-accessibility-shared-focus-elements! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-shared-text-ui-elements! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-shown-menu! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-sort-direction! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-set-accessibility-splitters! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-subrole! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-tabs! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-title! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-title-ui-element! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-toolbar-button! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-top-level-ui-element! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-url! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-unit-description! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-units! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-set-accessibility-user-input-labels! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-value! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-value-description! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-vertical-scroll-bar! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-vertical-unit-description! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-vertical-units! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-set-accessibility-visible-cells! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-visible-character-range! (c-> nsstackview? any/c void?)]
  [nsstackview-set-accessibility-visible-children! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-visible-columns! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-visible-rows! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-warning-value! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-window! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-windows! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-zoom-button! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-animations! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-appearance! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-bounds-origin! (c-> nsstackview? any/c void?)]
  [nsstackview-set-bounds-size! (c-> nsstackview? any/c void?)]
  [nsstackview-set-clipping-resistance-priority-for-orientation! (c-> nsstackview? real? exact-integer? void?)]
  [nsstackview-set-content-compression-resistance-priority-for-orientation! (c-> nsstackview? real? exact-integer? void?)]
  [nsstackview-set-content-hugging-priority-for-orientation! (c-> nsstackview? real? exact-integer? void?)]
  [nsstackview-set-custom-spacing-after-view! (c-> nsstackview? real? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-frame-origin! (c-> nsstackview? any/c void?)]
  [nsstackview-set-frame-size! (c-> nsstackview? any/c void?)]
  [nsstackview-set-hugging-priority-for-orientation! (c-> nsstackview? real? exact-integer? void?)]
  [nsstackview-set-identifier! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-keyboard-focus-ring-needs-display-in-rect! (c-> nsstackview? any/c void?)]
  [nsstackview-set-mark! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-needs-display-in-rect! (c-> nsstackview? any/c void?)]
  [nsstackview-set-views-in-gravity! (c-> nsstackview? (or/c string? objc-object? #f) exact-integer? void?)]
  [nsstackview-set-visibility-priority-for-view! (c-> nsstackview? real? (or/c string? objc-object? #f) void?)]
  [nsstackview-should-be-treated-as-ink-event (c-> nsstackview? (or/c string? objc-object? #f) boolean?)]
  [nsstackview-should-delay-window-ordering-for-event (c-> nsstackview? (or/c string? objc-object? #f) boolean?)]
  [nsstackview-show-context-help (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-show-context-menu-for-selection (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-show-definition-for-attributed-string-at-point (c-> nsstackview? (or/c string? objc-object? #f) any/c void?)]
  [nsstackview-show-definition-for-attributed-string-range-options-baseline-origin-provider (c-> nsstackview? (or/c string? objc-object? #f) any/c (or/c string? objc-object? #f) (or/c procedure? #f) void?)]
  [nsstackview-show-writing-tools (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-smart-magnify-with-event (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-sort-subviews-using-function-context (c-> nsstackview? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nsstackview-supplemental-target-for-action-sender (c-> nsstackview? string? (or/c string? objc-object? #f) any/c)]
  [nsstackview-swap-with-mark (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-swipe-with-event (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-tablet-point (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-tablet-proximity (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-touches-began-with-event (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-touches-cancelled-with-event (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-touches-ended-with-event (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-touches-moved-with-event (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-translate-origin-to-point (c-> nsstackview? any/c void?)]
  [nsstackview-translate-rects-needing-display-in-rect-by (c-> nsstackview? any/c any/c void?)]
  [nsstackview-transpose (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-transpose-words (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-try-to-perform-with (c-> nsstackview? string? (or/c string? objc-object? #f) boolean?)]
  [nsstackview-unregister-dragged-types (c-> nsstackview? void?)]
  [nsstackview-update-constraints (c-> nsstackview? void?)]
  [nsstackview-update-constraints-for-subtree-if-needed (c-> nsstackview? void?)]
  [nsstackview-update-dragging-items-for-drag (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-update-layer (c-> nsstackview? void?)]
  [nsstackview-update-tracking-areas (c-> nsstackview? void?)]
  [nsstackview-update-user-activity-state (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-uppercase-word (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-valid-requestor-for-send-type-return-type (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nsstackview-validate-proposed-first-responder-for-event (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nsstackview-view-did-change-backing-properties (c-> nsstackview? void?)]
  [nsstackview-view-did-change-effective-appearance (c-> nsstackview? void?)]
  [nsstackview-view-did-end-live-resize (c-> nsstackview? void?)]
  [nsstackview-view-did-hide (c-> nsstackview? void?)]
  [nsstackview-view-did-move-to-superview (c-> nsstackview? void?)]
  [nsstackview-view-did-move-to-window (c-> nsstackview? void?)]
  [nsstackview-view-did-unhide (c-> nsstackview? void?)]
  [nsstackview-view-will-draw (c-> nsstackview? void?)]
  [nsstackview-view-will-move-to-superview (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-view-will-move-to-window (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-view-will-start-live-resize (c-> nsstackview? void?)]
  [nsstackview-view-with-tag (c-> nsstackview? exact-integer? (or/c nsview? objc-nil?))]
  [nsstackview-views-in-gravity (c-> nsstackview? exact-integer? (or/c nsarray? objc-nil?))]
  [nsstackview-visibility-priority-for-view (c-> nsstackview? (or/c string? objc-object? #f) real?)]
  [nsstackview-wants-forwarded-scroll-events-for-axis (c-> nsstackview? exact-integer? boolean?)]
  [nsstackview-wants-periodic-dragging-updates (c-> nsstackview? boolean?)]
  [nsstackview-wants-scroll-events-for-swipe-tracking-on-axis (c-> nsstackview? exact-integer? boolean?)]
  [nsstackview-will-open-menu-with-event (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsstackview-will-present-error (c-> nsstackview? (or/c string? objc-object? #f) (or/c nserror? objc-nil?))]
  [nsstackview-will-remove-subview (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-write-eps-inside-rect-to-pasteboard (c-> nsstackview? any/c (or/c string? objc-object? #f) void?)]
  [nsstackview-write-pdf-inside-rect-to-pasteboard (c-> nsstackview? any/c (or/c string? objc-object? #f) void?)]
  [nsstackview-yank (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-allowed-classes-for-restorable-state-key-path (c-> (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsstackview-default-animation-for-key (c-> (or/c string? objc-object? #f) any/c)]
  [nsstackview-is-compatible-with-responsive-scrolling (c-> boolean?)]
  [nsstackview-stack-view-with-views (c-> (or/c string? objc-object? #f) any/c)]
  )

;; --- Class reference ---
(import-class NSStackView)

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
(define-aw-msg aw_racket_msg_P_f (-> ptr_t ptr_t ptr_t float_t))
(define-aw-msg aw_racket_msg_P_d (-> ptr_t ptr_t ptr_t double_t))
(define-aw-msg aw_racket_msg_P_R (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_E (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_b (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PPPPP_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPd_d (-> ptr_t ptr_t ptr_t ptr_t double_t double_t))
(define-aw-msg aw_racket_msg_Pq_v (-> ptr_t ptr_t ptr_t int64_t void_t))
(define-aw-msg aw_racket_msg_PqP_v (-> ptr_t ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PQq_v (-> ptr_t ptr_t ptr_t uint64_t int64_t void_t))
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
(define-aw-msg aw_racket_msg_fP_v (-> ptr_t ptr_t float_t ptr_t void_t))
(define-aw-msg aw_racket_msg_fq_v (-> ptr_t ptr_t float_t int64_t void_t))
(define-aw-msg aw_racket_msg_d_v (-> ptr_t ptr_t double_t void_t))
(define-aw-msg aw_racket_msg_dP_v (-> ptr_t ptr_t double_t ptr_t void_t))
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
(define (make-nsstackview-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSStackView alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nsstackview-init-with-frame frame-rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (tell NSStackView alloc)) (id->ffi2-ptr (sel_registerName "initWithFrame:")) (id->ffi2-ptr frame-rect)))
   #:retained #t))


;; --- Properties ---
(define (nsstackview-accepts-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsFirstResponder"))))
(define (nsstackview-accepts-touch-events self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsTouchEvents"))))
(define (nsstackview-set-accepts-touch-events! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAcceptsTouchEvents:")) value))
(define (nsstackview-additional-safe-area-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "additionalSafeAreaInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nsstackview-set-additional-safe-area-insets! self value)
  (aw_racket_msg_E_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAdditionalSafeAreaInsets:")) (id->ffi2-ptr value)))
(define (nsstackview-alignment self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignment"))))
(define (nsstackview-set-alignment! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlignment:")) value))
(define (nsstackview-alignment-rect-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignmentRectInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nsstackview-allowed-touch-types self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowedTouchTypes"))))
(define (nsstackview-set-allowed-touch-types! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowedTouchTypes:")) value))
(define (nsstackview-allows-vibrancy self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsVibrancy"))))
(define (nsstackview-alpha-value self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alphaValue"))))
(define (nsstackview-set-alpha-value! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlphaValue:")) value))
(define (nsstackview-arranged-subviews self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "arrangedSubviews"))))))
(define (nsstackview-autoresizes-subviews self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoresizesSubviews"))))
(define (nsstackview-set-autoresizes-subviews! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutoresizesSubviews:")) value))
(define (nsstackview-autoresizing-mask self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoresizingMask"))))
(define (nsstackview-set-autoresizing-mask! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutoresizingMask:")) value))
(define (nsstackview-background-filters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backgroundFilters"))))))
(define (nsstackview-set-background-filters! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBackgroundFilters:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsstackview-baseline-offset-from-bottom self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "baselineOffsetFromBottom"))))
(define (nsstackview-bottom-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bottomAnchor"))))))
(define (nsstackview-bounds self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bounds")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-set-bounds! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBounds:")) (id->ffi2-ptr value)))
(define (nsstackview-bounds-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "boundsRotation"))))
(define (nsstackview-set-bounds-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsRotation:")) value))
(define (nsstackview-can-become-key-view self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canBecomeKeyView"))))
(define (nsstackview-can-draw self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDraw"))))
(define (nsstackview-can-draw-concurrently self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDrawConcurrently"))))
(define (nsstackview-set-can-draw-concurrently! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCanDrawConcurrently:")) value))
(define (nsstackview-can-draw-subviews-into-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDrawSubviewsIntoLayer"))))
(define (nsstackview-set-can-draw-subviews-into-layer! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCanDrawSubviewsIntoLayer:")) value))
(define (nsstackview-candidate-list-touch-bar-item self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "candidateListTouchBarItem"))))))
(define (nsstackview-center-x-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerXAnchor"))))))
(define (nsstackview-center-y-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerYAnchor"))))))
(define (nsstackview-clips-to-bounds self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "clipsToBounds"))))
(define (nsstackview-set-clips-to-bounds! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setClipsToBounds:")) value))
(define (nsstackview-compatible-with-responsive-scrolling)
  (aw_racket_msg_0_b (id->ffi2-ptr NSStackView) (id->ffi2-ptr (sel_registerName "compatibleWithResponsiveScrolling"))))
(define (nsstackview-compositing-filter self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "compositingFilter"))))))
(define (nsstackview-set-compositing-filter! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCompositingFilter:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsstackview-constraints self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "constraints"))))))
(define (nsstackview-content-filters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentFilters"))))))
(define (nsstackview-set-content-filters! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentFilters:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsstackview-default-focus-ring-type)
  (aw_racket_msg_0_Q (id->ffi2-ptr NSStackView) (id->ffi2-ptr (sel_registerName "defaultFocusRingType"))))
(define (nsstackview-default-menu)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSStackView) (id->ffi2-ptr (sel_registerName "defaultMenu"))))))
(define (nsstackview-delegate self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "delegate"))))))
(define (nsstackview-set-delegate! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDelegate:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsstackview-detached-views self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "detachedViews"))))))
(define (nsstackview-detaches-hidden-views self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "detachesHiddenViews"))))
(define (nsstackview-set-detaches-hidden-views! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDetachesHiddenViews:")) value))
(define (nsstackview-distribution self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "distribution"))))
(define (nsstackview-set-distribution! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDistribution:")) value))
(define (nsstackview-drawing-find-indicator self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawingFindIndicator"))))
(define (nsstackview-edge-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "edgeInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nsstackview-set-edge-insets! self value)
  (aw_racket_msg_E_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setEdgeInsets:")) (id->ffi2-ptr value)))
(define (nsstackview-enclosing-menu-item self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enclosingMenuItem"))))))
(define (nsstackview-enclosing-scroll-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enclosingScrollView"))))))
(define (nsstackview-first-baseline-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstBaselineAnchor"))))))
(define (nsstackview-first-baseline-offset-from-top self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstBaselineOffsetFromTop"))))
(define (nsstackview-fitting-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fittingSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsstackview-flipped self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flipped"))))
(define (nsstackview-focus-ring-mask-bounds self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "focusRingMaskBounds")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-focus-ring-type self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "focusRingType"))))
(define (nsstackview-set-focus-ring-type! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFocusRingType:")) value))
(define (nsstackview-focus-view)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSStackView) (id->ffi2-ptr (sel_registerName "focusView"))))))
(define (nsstackview-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-set-frame! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrame:")) (id->ffi2-ptr value)))
(define (nsstackview-frame-center-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameCenterRotation"))))
(define (nsstackview-set-frame-center-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameCenterRotation:")) value))
(define (nsstackview-frame-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameRotation"))))
(define (nsstackview-set-frame-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameRotation:")) value))
(define (nsstackview-gesture-recognizers self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "gestureRecognizers"))))))
(define (nsstackview-set-gesture-recognizers! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setGestureRecognizers:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsstackview-has-ambiguous-layout self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasAmbiguousLayout"))))
(define (nsstackview-has-equal-spacing self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasEqualSpacing"))))
(define (nsstackview-set-has-equal-spacing! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHasEqualSpacing:")) value))
(define (nsstackview-height-adjust-limit self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "heightAdjustLimit"))))
(define (nsstackview-height-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "heightAnchor"))))))
(define (nsstackview-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hidden"))))
(define (nsstackview-set-hidden! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHidden:")) value))
(define (nsstackview-hidden-or-has-hidden-ancestor self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hiddenOrHasHiddenAncestor"))))
(define (nsstackview-horizontal-content-size-constraint-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "horizontalContentSizeConstraintActive"))))
(define (nsstackview-set-horizontal-content-size-constraint-active! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHorizontalContentSizeConstraintActive:")) value))
(define (nsstackview-in-full-screen-mode self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inFullScreenMode"))))
(define (nsstackview-in-live-resize self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inLiveResize"))))
(define (nsstackview-input-context self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inputContext"))))))
(define (nsstackview-intrinsic-content-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "intrinsicContentSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsstackview-last-baseline-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastBaselineAnchor"))))))
(define (nsstackview-last-baseline-offset-from-bottom self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastBaselineOffsetFromBottom"))))
(define (nsstackview-layer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layer"))))))
(define (nsstackview-set-layer! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayer:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsstackview-layer-contents-placement self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerContentsPlacement"))))
(define (nsstackview-set-layer-contents-placement! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerContentsPlacement:")) value))
(define (nsstackview-layer-contents-redraw-policy self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerContentsRedrawPolicy"))))
(define (nsstackview-set-layer-contents-redraw-policy! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerContentsRedrawPolicy:")) value))
(define (nsstackview-layer-uses-core-image-filters self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerUsesCoreImageFilters"))))
(define (nsstackview-set-layer-uses-core-image-filters! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerUsesCoreImageFilters:")) value))
(define (nsstackview-layout-guides self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutGuides"))))))
(define (nsstackview-layout-margins-guide self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutMarginsGuide"))))))
(define (nsstackview-leading-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "leadingAnchor"))))))
(define (nsstackview-left-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "leftAnchor"))))))
(define (nsstackview-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menu"))))))
(define (nsstackview-set-menu! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMenu:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsstackview-mouse-down-can-move-window self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDownCanMoveWindow"))))
(define (nsstackview-needs-display self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsDisplay"))))
(define (nsstackview-set-needs-display! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsDisplay:")) value))
(define (nsstackview-needs-layout self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsLayout"))))
(define (nsstackview-set-needs-layout! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsLayout:")) value))
(define (nsstackview-needs-panel-to-become-key self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsPanelToBecomeKey"))))
(define (nsstackview-needs-update-constraints self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsUpdateConstraints"))))
(define (nsstackview-set-needs-update-constraints! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsUpdateConstraints:")) value))
(define (nsstackview-next-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextKeyView"))))))
(define (nsstackview-set-next-key-view! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextKeyView:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsstackview-next-responder self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextResponder"))))))
(define (nsstackview-set-next-responder! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextResponder:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsstackview-next-valid-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextValidKeyView"))))))
(define (nsstackview-opaque self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "opaque"))))
(define (nsstackview-opaque-ancestor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "opaqueAncestor"))))))
(define (nsstackview-orientation self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orientation"))))
(define (nsstackview-set-orientation! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setOrientation:")) value))
(define (nsstackview-page-footer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageFooter"))))))
(define (nsstackview-page-header self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageHeader"))))))
(define (nsstackview-posts-bounds-changed-notifications self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "postsBoundsChangedNotifications"))))
(define (nsstackview-set-posts-bounds-changed-notifications! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPostsBoundsChangedNotifications:")) value))
(define (nsstackview-posts-frame-changed-notifications self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "postsFrameChangedNotifications"))))
(define (nsstackview-set-posts-frame-changed-notifications! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPostsFrameChangedNotifications:")) value))
(define (nsstackview-prefers-compact-control-size-metrics self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prefersCompactControlSizeMetrics"))))
(define (nsstackview-set-prefers-compact-control-size-metrics! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPrefersCompactControlSizeMetrics:")) value))
(define (nsstackview-prepared-content-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preparedContentRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-set-prepared-content-rect! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPreparedContentRect:")) (id->ffi2-ptr value)))
(define (nsstackview-preserves-content-during-live-resize self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preservesContentDuringLiveResize"))))
(define (nsstackview-pressure-configuration self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pressureConfiguration"))))))
(define (nsstackview-set-pressure-configuration! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPressureConfiguration:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsstackview-previous-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "previousKeyView"))))))
(define (nsstackview-previous-valid-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "previousValidKeyView"))))))
(define (nsstackview-print-job-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "printJobTitle"))))))
(define (nsstackview-rect-preserved-during-live-resize self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectPreservedDuringLiveResize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-registered-dragged-types self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "registeredDraggedTypes"))))))
(define (nsstackview-requires-constraint-based-layout)
  (aw_racket_msg_0_b (id->ffi2-ptr NSStackView) (id->ffi2-ptr (sel_registerName "requiresConstraintBasedLayout"))))
(define (nsstackview-restorable-state-key-paths)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSStackView) (id->ffi2-ptr (sel_registerName "restorableStateKeyPaths"))))))
(define (nsstackview-right-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightAnchor"))))))
(define (nsstackview-rotated-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotatedFromBase"))))
(define (nsstackview-rotated-or-scaled-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotatedOrScaledFromBase"))))
(define (nsstackview-safe-area-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nsstackview-safe-area-layout-guide self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaLayoutGuide"))))))
(define (nsstackview-safe-area-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-shadow self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shadow"))))))
(define (nsstackview-set-shadow! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShadow:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsstackview-spacing self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "spacing"))))
(define (nsstackview-set-spacing! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSpacing:")) value))
(define (nsstackview-subviews self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "subviews"))))))
(define (nsstackview-set-subviews! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSubviews:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsstackview-superview self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "superview"))))))
(define (nsstackview-tag self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tag"))))
(define (nsstackview-tool-tip self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "toolTip"))))))
(define (nsstackview-set-tool-tip! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setToolTip:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsstackview-top-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "topAnchor"))))))
(define (nsstackview-touch-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchBar"))))))
(define (nsstackview-set-touch-bar! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTouchBar:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsstackview-tracking-areas self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "trackingAreas"))))))
(define (nsstackview-trailing-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "trailingAnchor"))))))
(define (nsstackview-translates-autoresizing-mask-into-constraints self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translatesAutoresizingMaskIntoConstraints"))))
(define (nsstackview-set-translates-autoresizing-mask-into-constraints! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTranslatesAutoresizingMaskIntoConstraints:")) value))
(define (nsstackview-undo-manager self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "undoManager"))))))
(define (nsstackview-user-activity self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userActivity"))))))
(define (nsstackview-set-user-activity! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserActivity:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsstackview-user-interface-layout-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userInterfaceLayoutDirection"))))
(define (nsstackview-set-user-interface-layout-direction! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserInterfaceLayoutDirection:")) value))
(define (nsstackview-vertical-content-size-constraint-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "verticalContentSizeConstraintActive"))))
(define (nsstackview-set-vertical-content-size-constraint-active! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setVerticalContentSizeConstraintActive:")) value))
(define (nsstackview-views self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "views"))))))
(define (nsstackview-visible-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "visibleRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-wants-best-resolution-open-gl-surface self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsBestResolutionOpenGLSurface"))))
(define (nsstackview-set-wants-best-resolution-open-gl-surface! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsBestResolutionOpenGLSurface:")) value))
(define (nsstackview-wants-default-clipping self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsDefaultClipping"))))
(define (nsstackview-wants-extended-dynamic-range-open-gl-surface self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsExtendedDynamicRangeOpenGLSurface"))))
(define (nsstackview-set-wants-extended-dynamic-range-open-gl-surface! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsExtendedDynamicRangeOpenGLSurface:")) value))
(define (nsstackview-wants-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsLayer"))))
(define (nsstackview-set-wants-layer! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsLayer:")) value))
(define (nsstackview-wants-resting-touches self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsRestingTouches"))))
(define (nsstackview-set-wants-resting-touches! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsRestingTouches:")) value))
(define (nsstackview-wants-update-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsUpdateLayer"))))
(define (nsstackview-width-adjust-limit self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "widthAdjustLimit"))))
(define (nsstackview-width-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "widthAnchor"))))))
(define (nsstackview-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "window"))))))
(define (nsstackview-writing-tools-coordinator self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writingToolsCoordinator"))))))
(define (nsstackview-set-writing-tools-coordinator! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWritingToolsCoordinator:")) (id->ffi2-ptr (coerce-arg value))))

;; --- Instance methods ---
(define (nsstackview-accepts-first-mouse self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsFirstMouse:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-accessibility-activation-point self)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_0_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityActivationPoint")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsstackview-accessibility-allowed-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAllowedValues"))))
   ))
(define (nsstackview-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityApplicationFocusedUIElement"))))
   ))
(define (nsstackview-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nsstackview-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedUserInputLabels"))))
   ))
(define (nsstackview-accessibility-cancel-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCancelButton"))))
   ))
(define (nsstackview-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_qq_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCellForColumn:row:")) column row))
   ))
(define (nsstackview-accessibility-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildren"))))
   ))
(define (nsstackview-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildrenInNavigationOrder"))))
   ))
(define (nsstackview-accessibility-clear-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityClearButton"))))
   ))
(define (nsstackview-accessibility-close-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCloseButton"))))
   ))
(define (nsstackview-accessibility-column-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnCount"))))
(define (nsstackview-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnHeaderUIElements"))))
   ))
(define (nsstackview-accessibility-column-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstackview-accessibility-column-titles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnTitles"))))
   ))
(define (nsstackview-accessibility-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumns"))))
   ))
(define (nsstackview-accessibility-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityContents"))))
   ))
(define (nsstackview-accessibility-critical-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCriticalValue"))))
   ))
(define (nsstackview-accessibility-custom-actions self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomActions"))))
   ))
(define (nsstackview-accessibility-custom-rotors self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomRotors"))))
   ))
(define (nsstackview-accessibility-decrement-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDecrementButton"))))
   ))
(define (nsstackview-accessibility-default-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDefaultButton"))))
   ))
(define (nsstackview-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedByRow"))))
   ))
(define (nsstackview-accessibility-disclosed-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedRows"))))
   ))
(define (nsstackview-accessibility-disclosure-level self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosureLevel"))))
(define (nsstackview-accessibility-document self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDocument"))))
   ))
(define (nsstackview-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityExtrasMenuBar"))))
   ))
(define (nsstackview-accessibility-filename self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFilename"))))
   ))
(define (nsstackview-accessibility-focused-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFocusedWindow"))))
   ))
(define (nsstackview-accessibility-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-accessibility-frame-for-range self range)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_G_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrameForRange:")) (id->ffi2-ptr range) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-accessibility-full-screen-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFullScreenButton"))))
   ))
(define (nsstackview-accessibility-grow-area self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityGrowArea"))))
   ))
(define (nsstackview-accessibility-handles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHandles"))))
   ))
(define (nsstackview-accessibility-header self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHeader"))))
   ))
(define (nsstackview-accessibility-help self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHelp"))))
   ))
(define (nsstackview-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalScrollBar"))))
   ))
(define (nsstackview-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnitDescription"))))
   ))
(define (nsstackview-accessibility-horizontal-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnits"))))
(define (nsstackview-accessibility-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIdentifier"))))
   ))
(define (nsstackview-accessibility-increment-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIncrementButton"))))
   ))
(define (nsstackview-accessibility-index self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIndex"))))
(define (nsstackview-accessibility-insertion-point-line-number self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityInsertionPointLineNumber"))))
(define (nsstackview-accessibility-label self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabel"))))
   ))
(define (nsstackview-accessibility-label-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelUIElements"))))
   ))
(define (nsstackview-accessibility-label-value self)
  (aw_racket_msg_0_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelValue"))))
(define (nsstackview-accessibility-layout-point-for-screen-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutPointForScreenPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsstackview-accessibility-layout-size-for-screen-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutSizeForScreenSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsstackview-accessibility-line-for-index self index)
  (aw_racket_msg_q_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLineForIndex:")) index))
(define (nsstackview-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLinkedUIElements"))))
   ))
(define (nsstackview-accessibility-main-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMainWindow"))))
   ))
(define (nsstackview-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerGroupUIElement"))))
   ))
(define (nsstackview-accessibility-marker-type-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerTypeDescription"))))
   ))
(define (nsstackview-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerUIElements"))))
   ))
(define (nsstackview-accessibility-marker-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerValues"))))
   ))
(define (nsstackview-accessibility-max-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMaxValue"))))
   ))
(define (nsstackview-accessibility-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMenuBar"))))
   ))
(define (nsstackview-accessibility-min-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinValue"))))
   ))
(define (nsstackview-accessibility-minimize-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinimizeButton"))))
   ))
(define (nsstackview-accessibility-next-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNextContents"))))
   ))
(define (nsstackview-accessibility-number-of-characters self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNumberOfCharacters"))))
(define (nsstackview-accessibility-orientation self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOrientation"))))
(define (nsstackview-accessibility-overflow-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOverflowButton"))))
   ))
(define (nsstackview-accessibility-parent self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityParent"))))
   ))
(define (nsstackview-accessibility-perform-cancel self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformCancel"))))
(define (nsstackview-accessibility-perform-confirm self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformConfirm"))))
(define (nsstackview-accessibility-perform-decrement self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDecrement"))))
(define (nsstackview-accessibility-perform-delete self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDelete"))))
(define (nsstackview-accessibility-perform-increment self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformIncrement"))))
(define (nsstackview-accessibility-perform-pick self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPick"))))
(define (nsstackview-accessibility-perform-press self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPress"))))
(define (nsstackview-accessibility-perform-raise self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformRaise"))))
(define (nsstackview-accessibility-perform-show-alternate-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowAlternateUI"))))
(define (nsstackview-accessibility-perform-show-default-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowDefaultUI"))))
(define (nsstackview-accessibility-perform-show-menu self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowMenu"))))
(define (nsstackview-accessibility-placeholder-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPlaceholderValue"))))
   ))
(define (nsstackview-accessibility-previous-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPreviousContents"))))
   ))
(define (nsstackview-accessibility-proxy self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityProxy"))))
   ))
(define (nsstackview-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRTFForRange:")) (id->ffi2-ptr range)))
   ))
(define (nsstackview-accessibility-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstackview-accessibility-range-for-line self line)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForLine:")) line (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstackview-accessibility-range-for-position self point)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_O_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForPosition:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstackview-accessibility-role self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRole"))))
   ))
(define (nsstackview-accessibility-role-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRoleDescription"))))
   ))
(define (nsstackview-accessibility-row-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowCount"))))
(define (nsstackview-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowHeaderUIElements"))))
   ))
(define (nsstackview-accessibility-row-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstackview-accessibility-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRows"))))
   ))
(define (nsstackview-accessibility-ruler-marker-type self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRulerMarkerType"))))
(define (nsstackview-accessibility-screen-point-for-layout-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenPointForLayoutPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsstackview-accessibility-screen-size-for-layout-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenSizeForLayoutSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsstackview-accessibility-search-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchButton"))))
   ))
(define (nsstackview-accessibility-search-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchMenu"))))
   ))
(define (nsstackview-accessibility-selected-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedCells"))))
   ))
(define (nsstackview-accessibility-selected-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedChildren"))))
   ))
(define (nsstackview-accessibility-selected-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedColumns"))))
   ))
(define (nsstackview-accessibility-selected-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedRows"))))
   ))
(define (nsstackview-accessibility-selected-text self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedText"))))
   ))
(define (nsstackview-accessibility-selected-text-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstackview-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRanges"))))
   ))
(define (nsstackview-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityServesAsTitleForUIElements"))))
   ))
(define (nsstackview-accessibility-shared-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstackview-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedFocusElements"))))
   ))
(define (nsstackview-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedTextUIElements"))))
   ))
(define (nsstackview-accessibility-shown-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityShownMenu"))))
   ))
(define (nsstackview-accessibility-sort-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySortDirection"))))
(define (nsstackview-accessibility-splitters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySplitters"))))
   ))
(define (nsstackview-accessibility-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nsstackview-accessibility-style-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStyleRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstackview-accessibility-subrole self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySubrole"))))
   ))
(define (nsstackview-accessibility-tabs self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTabs"))))
   ))
(define (nsstackview-accessibility-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitle"))))
   ))
(define (nsstackview-accessibility-title-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitleUIElement"))))
   ))
(define (nsstackview-accessibility-toolbar-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityToolbarButton"))))
   ))
(define (nsstackview-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTopLevelUIElement"))))
   ))
(define (nsstackview-accessibility-url self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityURL"))))
   ))
(define (nsstackview-accessibility-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnitDescription"))))
   ))
(define (nsstackview-accessibility-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnits"))))
(define (nsstackview-accessibility-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUserInputLabels"))))
   ))
(define (nsstackview-accessibility-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValue"))))
   ))
(define (nsstackview-accessibility-value-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValueDescription"))))
   ))
(define (nsstackview-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalScrollBar"))))
   ))
(define (nsstackview-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnitDescription"))))
   ))
(define (nsstackview-accessibility-vertical-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnits"))))
(define (nsstackview-accessibility-visible-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCells"))))
   ))
(define (nsstackview-accessibility-visible-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsstackview-accessibility-visible-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleChildren"))))
   ))
(define (nsstackview-accessibility-visible-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleColumns"))))
   ))
(define (nsstackview-accessibility-visible-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleRows"))))
   ))
(define (nsstackview-accessibility-warning-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWarningValue"))))
   ))
(define (nsstackview-accessibility-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindow"))))
   ))
(define (nsstackview-accessibility-windows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindows"))))
   ))
(define (nsstackview-accessibility-zoom-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityZoomButton"))))
   ))
(define (nsstackview-add-arranged-subview! self view)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addArrangedSubview:")) (id->ffi2-ptr (coerce-arg view))))
(define (nsstackview-add-constraint! self constraint)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addConstraint:")) (id->ffi2-ptr (coerce-arg constraint))))
(define (nsstackview-add-constraints! self constraints)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addConstraints:")) (id->ffi2-ptr (coerce-arg constraints))))
(define (nsstackview-add-cursor-rect-cursor! self rect object)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addCursorRect:cursor:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg object))))
(define (nsstackview-add-gesture-recognizer! self gesture-recognizer)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addGestureRecognizer:")) (id->ffi2-ptr (coerce-arg gesture-recognizer))))
(define (nsstackview-add-layout-guide! self guide)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addLayoutGuide:")) (id->ffi2-ptr (coerce-arg guide))))
(define (nsstackview-add-subview! self view)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addSubview:")) (id->ffi2-ptr (coerce-arg view))))
(define (nsstackview-add-subview-positioned-relative-to! self view place other-view)
  (aw_racket_msg_PqP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addSubview:positioned:relativeTo:")) (id->ffi2-ptr (coerce-arg view)) place (id->ffi2-ptr (coerce-arg other-view))))
(define (nsstackview-add-tool-tip-rect-owner-user-data! self rect owner data)
  (aw_racket_msg_RPP_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addToolTipRect:owner:userData:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg owner)) (id->ffi2-ptr data)))
(define (nsstackview-add-tracking-area! self tracking-area)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addTrackingArea:")) (id->ffi2-ptr (coerce-arg tracking-area))))
(define (nsstackview-add-tracking-rect-owner-user-data-assume-inside! self rect owner data flag)
  (aw_racket_msg_RPPb_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addTrackingRect:owner:userData:assumeInside:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg owner)) (id->ffi2-ptr data) flag))
(define (nsstackview-add-view-in-gravity! self view gravity)
  (aw_racket_msg_Pq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addView:inGravity:")) (id->ffi2-ptr (coerce-arg view)) gravity))
(define (nsstackview-additional-safe-area-insets! self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "additionalSafeAreaInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nsstackview-adjust-page-height-new-top-bottom-limit self new-bottom old-top old-bottom bottom-limit)
  (aw_racket_msg_Pddd_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "adjustPageHeightNew:top:bottom:limit:")) (id->ffi2-ptr new-bottom) old-top old-bottom bottom-limit))
(define (nsstackview-adjust-page-width-new-left-right-limit self new-right old-left old-right right-limit)
  (aw_racket_msg_Pddd_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "adjustPageWidthNew:left:right:limit:")) (id->ffi2-ptr new-right) old-left old-right right-limit))
(define (nsstackview-adjust-scroll self new-visible)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "adjustScroll:")) (id->ffi2-ptr new-visible) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-alignment-rect-for-frame self frame)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignmentRectForFrame:")) (id->ffi2-ptr frame) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-ancestor-shared-with-view self view)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "ancestorSharedWithView:")) (id->ffi2-ptr (coerce-arg view))))
   ))
(define (nsstackview-animation-for-key self key)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animationForKey:")) (id->ffi2-ptr (coerce-arg key))))
   ))
(define (nsstackview-animations self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animations"))))
   ))
(define (nsstackview-animator self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animator"))))
   ))
(define (nsstackview-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "appearance"))))
   ))
(define (nsstackview-autoscroll self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoscroll:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-backing-aligned-rect-options self rect options)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RQ_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backingAlignedRect:options:")) (id->ffi2-ptr rect) options (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-become-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "becomeFirstResponder"))))
(define (nsstackview-begin-document! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginDocument"))))
(define (nsstackview-begin-dragging-session-with-items-event-source! self items event source)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginDraggingSessionWithItems:event:source:")) (id->ffi2-ptr (coerce-arg items)) (id->ffi2-ptr (coerce-arg event)) (id->ffi2-ptr (coerce-arg source))))
   ))
(define (nsstackview-begin-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-begin-page-in-rect-at-placement! self rect location)
  (aw_racket_msg_RO_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginPageInRect:atPlacement:")) (id->ffi2-ptr rect) (id->ffi2-ptr location)))
(define (nsstackview-bitmap-image-rep-for-caching-display-in-rect self rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bitmapImageRepForCachingDisplayInRect:")) (id->ffi2-ptr rect)))
   ))
(define (nsstackview-cache-display-in-rect-to-bitmap-image-rep self rect bitmap-image-rep)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cacheDisplayInRect:toBitmapImageRep:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg bitmap-image-rep))))
(define (nsstackview-cancel-operation self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cancelOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-capitalize-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "capitalizeWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-center-scan-rect! self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerScanRect:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-center-selection-in-visible-area! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerSelectionInVisibleArea:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-center-x-anchor! self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerXAnchor"))))
   ))
(define (nsstackview-center-y-anchor! self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerYAnchor"))))
   ))
(define (nsstackview-change-case-of-letter self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeCaseOfLetter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-change-mode-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeModeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-clipping-resistance-priority-for-orientation self orientation)
  (aw_racket_msg_q_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "clippingResistancePriorityForOrientation:")) orientation))
(define (nsstackview-complete self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "complete:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-conclude-drag-operation self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "concludeDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-constraints-affecting-layout-for-orientation self orientation)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "constraintsAffectingLayoutForOrientation:")) orientation))
   ))
(define (nsstackview-content-compression-resistance-priority-for-orientation self orientation)
  (aw_racket_msg_q_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentCompressionResistancePriorityForOrientation:")) orientation))
(define (nsstackview-content-hugging-priority-for-orientation self orientation)
  (aw_racket_msg_q_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentHuggingPriorityForOrientation:")) orientation))
(define (nsstackview-context-menu-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contextMenuKeyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-convert-point-from-view self point view)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_OP_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPoint:fromView:")) (id->ffi2-ptr point) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsstackview-convert-point-to-view self point view)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_OP_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPoint:toView:")) (id->ffi2-ptr point) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsstackview-convert-point-from-backing self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointFromBacking:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsstackview-convert-point-from-layer self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointFromLayer:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsstackview-convert-point-to-backing self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointToBacking:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsstackview-convert-point-to-layer self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointToLayer:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsstackview-convert-rect-from-view self rect view)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RP_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRect:fromView:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-convert-rect-to-view self rect view)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RP_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRect:toView:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-convert-rect-from-backing self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectFromBacking:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-convert-rect-from-layer self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectFromLayer:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-convert-rect-to-backing self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectToBacking:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-convert-rect-to-layer self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectToLayer:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-convert-size-from-view self size view)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_ZP_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSize:fromView:")) (id->ffi2-ptr size) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsstackview-convert-size-to-view self size view)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_ZP_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSize:toView:")) (id->ffi2-ptr size) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsstackview-convert-size-from-backing self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeFromBacking:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsstackview-convert-size-from-layer self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeFromLayer:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsstackview-convert-size-to-backing self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeToBacking:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsstackview-convert-size-to-layer self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeToLayer:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsstackview-cursor-update self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cursorUpdate:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-custom-spacing-after-view self view)
  (aw_racket_msg_P_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "customSpacingAfterView:")) (id->ffi2-ptr (coerce-arg view))))
(define (nsstackview-data-with-eps-inside-rect self rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dataWithEPSInsideRect:")) (id->ffi2-ptr rect)))
   ))
(define (nsstackview-data-with-pdf-inside-rect self rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dataWithPDFInsideRect:")) (id->ffi2-ptr rect)))
   ))
(define (nsstackview-delete-backward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-delete-backward-by-decomposing-previous-character self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteBackwardByDecomposingPreviousCharacter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-delete-forward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-delete-to-beginning-of-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToBeginningOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-delete-to-beginning-of-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToBeginningOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-delete-to-end-of-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-delete-to-end-of-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToEndOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-delete-to-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-delete-word-backward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteWordBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-delete-word-forward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteWordForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-did-add-subview self subview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "didAddSubview:")) (id->ffi2-ptr (coerce-arg subview))))
(define (nsstackview-did-close-menu-with-event self menu event)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "didCloseMenu:withEvent:")) (id->ffi2-ptr (coerce-arg menu)) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-discard-cursor-rects self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "discardCursorRects"))))
(define (nsstackview-display! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "display"))))
(define (nsstackview-display-if-needed! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeeded"))))
(define (nsstackview-display-if-needed-ignoring-opacity! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededIgnoringOpacity"))))
(define (nsstackview-display-if-needed-in-rect! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededInRect:")) (id->ffi2-ptr rect)))
(define (nsstackview-display-if-needed-in-rect-ignoring-opacity! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededInRectIgnoringOpacity:")) (id->ffi2-ptr rect)))
(define (nsstackview-display-link-with-target-selector! self target selector)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayLinkWithTarget:selector:")) (id->ffi2-ptr (coerce-arg target)) (id->ffi2-ptr (sel_registerName selector))))
   ))
(define (nsstackview-display-rect! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRect:")) (id->ffi2-ptr rect)))
(define (nsstackview-display-rect-ignoring-opacity! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRectIgnoringOpacity:")) (id->ffi2-ptr rect)))
(define (nsstackview-display-rect-ignoring-opacity-in-context! self rect context)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRectIgnoringOpacity:inContext:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg context))))
(define (nsstackview-do-command-by-selector self selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "doCommandBySelector:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nsstackview-dragging-ended self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingEnded:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-dragging-entered self sender)
  (aw_racket_msg_P_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingEntered:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-dragging-exited self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingExited:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-dragging-updated self sender)
  (aw_racket_msg_P_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingUpdated:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-draw-focus-ring-mask self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawFocusRingMask"))))
(define (nsstackview-draw-page-border-with-size self border-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawPageBorderWithSize:")) (id->ffi2-ptr border-size)))
(define (nsstackview-draw-rect self dirty-rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawRect:")) (id->ffi2-ptr dirty-rect)))
(define (nsstackview-edge-insets-for-layout-region self layout-region)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_P_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "edgeInsetsForLayoutRegion:")) (id->ffi2-ptr (coerce-arg layout-region)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nsstackview-effective-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "effectiveAppearance"))))
   ))
(define (nsstackview-encode-restorable-state-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeRestorableStateWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nsstackview-encode-restorable-state-with-coder-background-queue self coder queue)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeRestorableStateWithCoder:backgroundQueue:")) (id->ffi2-ptr (coerce-arg coder)) (id->ffi2-ptr (coerce-arg queue))))
(define (nsstackview-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nsstackview-end-document! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endDocument"))))
(define (nsstackview-end-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-end-page! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endPage"))))
(define (nsstackview-enter-full-screen-mode-with-options self screen options)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enterFullScreenMode:withOptions:")) (id->ffi2-ptr (coerce-arg screen)) (id->ffi2-ptr (coerce-arg options))))
(define (nsstackview-exercise-ambiguity-in-layout self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "exerciseAmbiguityInLayout"))))
(define (nsstackview-exit-full-screen-mode-with-options self options)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "exitFullScreenModeWithOptions:")) (id->ffi2-ptr (coerce-arg options))))
(define (nsstackview-flags-changed self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flagsChanged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-flush-buffered-key-events self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flushBufferedKeyEvents"))))
(define (nsstackview-frame-for-alignment-rect self alignment-rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameForAlignmentRect:")) (id->ffi2-ptr alignment-rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-get-rects-being-drawn-count self rects count)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getRectsBeingDrawn:count:")) (id->ffi2-ptr rects) (id->ffi2-ptr count)))
(define (nsstackview-get-rects-exposed-during-live-resize-count self exposed-rects count)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getRectsExposedDuringLiveResize:count:")) (id->ffi2-ptr exposed-rects) (id->ffi2-ptr count)))
(define (nsstackview-help-requested self event-ptr)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "helpRequested:")) (id->ffi2-ptr (coerce-arg event-ptr))))
(define (nsstackview-hit-test self point)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_O_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hitTest:")) (id->ffi2-ptr point)))
   ))
(define (nsstackview-hugging-priority-for-orientation self orientation)
  (aw_racket_msg_q_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "huggingPriorityForOrientation:")) orientation))
(define (nsstackview-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "identifier"))))
   ))
(define (nsstackview-indent self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indent:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-insert-arranged-subview-at-index! self view index)
  (aw_racket_msg_Pq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertArrangedSubview:atIndex:")) (id->ffi2-ptr (coerce-arg view)) index))
(define (nsstackview-insert-backtab! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertBacktab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-insert-container-break! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertContainerBreak:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-insert-double-quote-ignoring-substitution! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertDoubleQuoteIgnoringSubstitution:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-insert-line-break! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertLineBreak:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-insert-newline! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertNewline:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-insert-newline-ignoring-field-editor! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertNewlineIgnoringFieldEditor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-insert-paragraph-separator! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertParagraphSeparator:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-insert-single-quote-ignoring-substitution! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertSingleQuoteIgnoringSubstitution:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-insert-tab! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-insert-tab-ignoring-field-editor! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTabIgnoringFieldEditor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-insert-text! self insert-string)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertText:")) (id->ffi2-ptr (coerce-arg insert-string))))
(define (nsstackview-insert-view-at-index-in-gravity! self view index gravity)
  (aw_racket_msg_PQq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertView:atIndex:inGravity:")) (id->ffi2-ptr (coerce-arg view)) index gravity))
(define (nsstackview-interpret-key-events self event-array)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "interpretKeyEvents:")) (id->ffi2-ptr (coerce-arg event-array))))
(define (nsstackview-invalidate-intrinsic-content-size self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "invalidateIntrinsicContentSize"))))
(define (nsstackview-invalidate-restorable-state self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "invalidateRestorableState"))))
(define (nsstackview-is-accessibility-alternate-ui-visible self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityAlternateUIVisible"))))
(define (nsstackview-is-accessibility-disclosed self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityDisclosed"))))
(define (nsstackview-is-accessibility-edited self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEdited"))))
(define (nsstackview-is-accessibility-element self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityElement"))))
(define (nsstackview-is-accessibility-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEnabled"))))
(define (nsstackview-is-accessibility-expanded self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityExpanded"))))
(define (nsstackview-is-accessibility-focused self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFocused"))))
(define (nsstackview-is-accessibility-frontmost self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFrontmost"))))
(define (nsstackview-is-accessibility-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityHidden"))))
(define (nsstackview-is-accessibility-main self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMain"))))
(define (nsstackview-is-accessibility-minimized self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMinimized"))))
(define (nsstackview-is-accessibility-modal self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityModal"))))
(define (nsstackview-is-accessibility-ordered-by-row self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityOrderedByRow"))))
(define (nsstackview-is-accessibility-protected-content self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityProtectedContent"))))
(define (nsstackview-is-accessibility-required self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityRequired"))))
(define (nsstackview-is-accessibility-selected self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelected"))))
(define (nsstackview-is-accessibility-selector-allowed self selector)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelectorAllowed:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nsstackview-is-descendant-of self view)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isDescendantOf:")) (id->ffi2-ptr (coerce-arg view))))
(define (nsstackview-is-drawing-find-indicator self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isDrawingFindIndicator"))))
(define (nsstackview-is-flipped self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isFlipped"))))
(define (nsstackview-is-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHidden"))))
(define (nsstackview-is-hidden-or-has-hidden-ancestor self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHiddenOrHasHiddenAncestor"))))
(define (nsstackview-is-horizontal-content-size-constraint-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHorizontalContentSizeConstraintActive"))))
(define (nsstackview-is-in-full-screen-mode self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isInFullScreenMode"))))
(define (nsstackview-is-opaque self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isOpaque"))))
(define (nsstackview-is-rotated-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRotatedFromBase"))))
(define (nsstackview-is-rotated-or-scaled-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRotatedOrScaledFromBase"))))
(define (nsstackview-is-vertical-content-size-constraint-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isVerticalContentSizeConstraintActive"))))
(define (nsstackview-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-key-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-knows-page-range self range)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "knowsPageRange:")) (id->ffi2-ptr range)))
(define (nsstackview-layout self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layout"))))
(define (nsstackview-layout-guide-for-layout-region self layout-region)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutGuideForLayoutRegion:")) (id->ffi2-ptr (coerce-arg layout-region))))
   ))
(define (nsstackview-layout-subtree-if-needed self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutSubtreeIfNeeded"))))
(define (nsstackview-location-of-print-rect self rect)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_R_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "locationOfPrintRect:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsstackview-lowercase-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lowercaseWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "magnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-make-backing-layer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBackingLayer"))))
   ))
(define (nsstackview-make-base-writing-direction-left-to-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionLeftToRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-make-base-writing-direction-natural self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionNatural:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-make-base-writing-direction-right-to-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionRightToLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-make-text-writing-direction-left-to-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionLeftToRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-make-text-writing-direction-natural self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionNatural:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-make-text-writing-direction-right-to-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionRightToLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-make-touch-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTouchBar"))))
   ))
(define (nsstackview-menu-for-event self event)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menuForEvent:")) (id->ffi2-ptr (coerce-arg event))))
   ))
(define (nsstackview-mouse-in-rect self point rect)
  (aw_racket_msg_OR_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouse:inRect:")) (id->ffi2-ptr point) (id->ffi2-ptr rect)))
(define (nsstackview-mouse-cancelled self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseCancelled:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-mouse-entered self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseEntered:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-mouse-exited self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseExited:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-mouse-moved self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseMoved:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-move-backward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-down! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-down-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveDownAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-forward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-left! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-left-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveLeftAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-paragraph-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveParagraphBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-paragraph-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveParagraphForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-right! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-right-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRightAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-to-beginning-of-document! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-to-beginning-of-document-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfDocumentAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-to-beginning-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-to-beginning-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-to-beginning-of-paragraph! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfParagraphAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-to-end-of-document! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-to-end-of-document-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfDocumentAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-to-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-to-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-to-end-of-paragraph! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-to-end-of-paragraph-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfParagraphAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-to-left-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToLeftEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-to-left-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToLeftEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-to-right-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToRightEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-to-right-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToRightEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-up! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-up-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveUpAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-word-backward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-word-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-word-forward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-word-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-word-left! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-word-left-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordLeftAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-word-right! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-move-word-right-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordRightAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-needs-to-draw-rect self rect)
  (aw_racket_msg_R_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsToDrawRect:")) (id->ffi2-ptr rect)))
(define (nsstackview-new-window-for-tab self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "newWindowForTab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-no-responder-for self event-selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "noResponderFor:")) (id->ffi2-ptr (sel_registerName event-selector))))
(define (nsstackview-note-focus-ring-mask-changed self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "noteFocusRingMaskChanged"))))
(define (nsstackview-other-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-other-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-other-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-page-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-page-down-and-modify-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageDownAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-page-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-page-up-and-modify-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageUpAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-perform-drag-operation! self sender)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-perform-key-equivalent! self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performKeyEquivalent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-perform-text-finder-action! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performTextFinderAction:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-prepare-content-in-rect self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareContentInRect:")) (id->ffi2-ptr rect)))
(define (nsstackview-prepare-for-drag-operation self sender)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareForDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-prepare-for-reuse self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareForReuse"))))
(define (nsstackview-present-error self error)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "presentError:")) (id->ffi2-ptr (coerce-arg error))))
;; param 2: weak reference
(define (nsstackview-present-error-modal-for-window-delegate-did-present-selector-context-info self error window delegate did-present-selector context-info)
  (aw_racket_msg_PPPPP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "presentError:modalForWindow:delegate:didPresentSelector:contextInfo:")) (id->ffi2-ptr (coerce-arg error)) (id->ffi2-ptr (coerce-arg window)) (id->ffi2-ptr (coerce-arg delegate)) (id->ffi2-ptr (sel_registerName did-present-selector)) (id->ffi2-ptr context-info)))
(define (nsstackview-pressure-change-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pressureChangeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-print self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "print:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-quick-look-preview-items self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookPreviewItems:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-quick-look-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-rect-for-layout-region self layout-region)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_P_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectForLayoutRegion:")) (id->ffi2-ptr (coerce-arg layout-region)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-rect-for-page self page)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_q_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectForPage:")) page (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-rect-for-smart-magnification-at-point-in-rect self location visible-rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_OR_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectForSmartMagnificationAtPoint:inRect:")) (id->ffi2-ptr location) (id->ffi2-ptr visible-rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsstackview-reflect-scrolled-clip-view self clip-view)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "reflectScrolledClipView:")) (id->ffi2-ptr (coerce-arg clip-view))))
(define (nsstackview-register-for-dragged-types self new-types)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "registerForDraggedTypes:")) (id->ffi2-ptr (coerce-arg new-types))))
(define (nsstackview-remove-all-tool-tips! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeAllToolTips"))))
(define (nsstackview-remove-arranged-subview! self view)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeArrangedSubview:")) (id->ffi2-ptr (coerce-arg view))))
(define (nsstackview-remove-constraint! self constraint)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeConstraint:")) (id->ffi2-ptr (coerce-arg constraint))))
(define (nsstackview-remove-constraints! self constraints)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeConstraints:")) (id->ffi2-ptr (coerce-arg constraints))))
(define (nsstackview-remove-cursor-rect-cursor! self rect object)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeCursorRect:cursor:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg object))))
(define (nsstackview-remove-from-superview! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeFromSuperview"))))
(define (nsstackview-remove-from-superview-without-needing-display! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeFromSuperviewWithoutNeedingDisplay"))))
(define (nsstackview-remove-gesture-recognizer! self gesture-recognizer)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeGestureRecognizer:")) (id->ffi2-ptr (coerce-arg gesture-recognizer))))
(define (nsstackview-remove-layout-guide! self guide)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeLayoutGuide:")) (id->ffi2-ptr (coerce-arg guide))))
(define (nsstackview-remove-tool-tip! self tag)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeToolTip:")) tag))
(define (nsstackview-remove-tracking-area! self tracking-area)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeTrackingArea:")) (id->ffi2-ptr (coerce-arg tracking-area))))
(define (nsstackview-remove-tracking-rect! self tag)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeTrackingRect:")) tag))
(define (nsstackview-remove-view! self view)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeView:")) (id->ffi2-ptr (coerce-arg view))))
(define (nsstackview-replace-subview-with! self old-view new-view)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "replaceSubview:with:")) (id->ffi2-ptr (coerce-arg old-view)) (id->ffi2-ptr (coerce-arg new-view))))
(define (nsstackview-reset-cursor-rects! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resetCursorRects"))))
(define (nsstackview-resign-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resignFirstResponder"))))
(define (nsstackview-resize-subviews-with-old-size self old-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resizeSubviewsWithOldSize:")) (id->ffi2-ptr old-size)))
(define (nsstackview-resize-with-old-superview-size self old-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resizeWithOldSuperviewSize:")) (id->ffi2-ptr old-size)))
(define (nsstackview-restore-state-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "restoreStateWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nsstackview-restore-user-activity-state self user-activity)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "restoreUserActivityState:")) (id->ffi2-ptr (coerce-arg user-activity))))
(define (nsstackview-right-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-right-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-right-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-rotate-by-angle self angle)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotateByAngle:")) angle))
(define (nsstackview-rotate-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotateWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-ruler-view-did-add-marker self ruler marker)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:didAddMarker:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker))))
(define (nsstackview-ruler-view-did-move-marker self ruler marker)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:didMoveMarker:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker))))
(define (nsstackview-ruler-view-did-remove-marker self ruler marker)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:didRemoveMarker:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker))))
(define (nsstackview-ruler-view-handle-mouse-down self ruler event)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:handleMouseDown:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-ruler-view-location-for-point self ruler point)
  (aw_racket_msg_PO_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:locationForPoint:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr point)))
(define (nsstackview-ruler-view-point-for-location self ruler point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_Pd_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:pointForLocation:")) (id->ffi2-ptr (coerce-arg ruler)) point (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsstackview-ruler-view-should-add-marker self ruler marker)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:shouldAddMarker:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker))))
(define (nsstackview-ruler-view-should-move-marker self ruler marker)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:shouldMoveMarker:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker))))
(define (nsstackview-ruler-view-should-remove-marker self ruler marker)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:shouldRemoveMarker:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker))))
(define (nsstackview-ruler-view-will-add-marker-at-location self ruler marker location)
  (aw_racket_msg_PPd_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:willAddMarker:atLocation:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker)) location))
(define (nsstackview-ruler-view-will-move-marker-to-location self ruler marker location)
  (aw_racket_msg_PPd_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:willMoveMarker:toLocation:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker)) location))
(define (nsstackview-ruler-view-will-set-client-view self ruler new-client)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:willSetClientView:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg new-client))))
(define (nsstackview-scale-unit-square-to-size self new-unit-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scaleUnitSquareToSize:")) (id->ffi2-ptr new-unit-size)))
(define (nsstackview-scroll-clip-view-to-point self clip-view point)
  (aw_racket_msg_PO_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollClipView:toPoint:")) (id->ffi2-ptr (coerce-arg clip-view)) (id->ffi2-ptr point)))
(define (nsstackview-scroll-line-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollLineDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-scroll-line-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollLineUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-scroll-page-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPageDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-scroll-page-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPageUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-scroll-point self point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPoint:")) (id->ffi2-ptr point)))
(define (nsstackview-scroll-rect-to-visible self rect)
  (aw_racket_msg_R_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollRectToVisible:")) (id->ffi2-ptr rect)))
(define (nsstackview-scroll-to-beginning-of-document self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollToBeginningOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-scroll-to-end-of-document self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollToEndOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-scroll-wheel self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollWheel:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-select-all self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectAll:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-select-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-select-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-select-to-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectToMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-select-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-set-accessibility-activation-point! self accessibility-activation-point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityActivationPoint:")) (id->ffi2-ptr accessibility-activation-point)))
(define (nsstackview-set-accessibility-allowed-values! self accessibility-allowed-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAllowedValues:")) (id->ffi2-ptr (coerce-arg accessibility-allowed-values))))
(define (nsstackview-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAlternateUIVisible:")) accessibility-alternate-ui-visible))
(define (nsstackview-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityApplicationFocusedUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-application-focused-ui-element))))
(define (nsstackview-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAttributedUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-attributed-user-input-labels))))
(define (nsstackview-set-accessibility-cancel-button! self accessibility-cancel-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCancelButton:")) (id->ffi2-ptr (coerce-arg accessibility-cancel-button))))
(define (nsstackview-set-accessibility-children! self accessibility-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildren:")) (id->ffi2-ptr (coerce-arg accessibility-children))))
(define (nsstackview-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildrenInNavigationOrder:")) (id->ffi2-ptr (coerce-arg accessibility-children-in-navigation-order))))
(define (nsstackview-set-accessibility-clear-button! self accessibility-clear-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityClearButton:")) (id->ffi2-ptr (coerce-arg accessibility-clear-button))))
(define (nsstackview-set-accessibility-close-button! self accessibility-close-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCloseButton:")) (id->ffi2-ptr (coerce-arg accessibility-close-button))))
(define (nsstackview-set-accessibility-column-count! self accessibility-column-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnCount:")) accessibility-column-count))
(define (nsstackview-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-column-header-ui-elements))))
(define (nsstackview-set-accessibility-column-index-range! self accessibility-column-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnIndexRange:")) (id->ffi2-ptr accessibility-column-index-range)))
(define (nsstackview-set-accessibility-column-titles! self accessibility-column-titles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnTitles:")) (id->ffi2-ptr (coerce-arg accessibility-column-titles))))
(define (nsstackview-set-accessibility-columns! self accessibility-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumns:")) (id->ffi2-ptr (coerce-arg accessibility-columns))))
(define (nsstackview-set-accessibility-contents! self accessibility-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityContents:")) (id->ffi2-ptr (coerce-arg accessibility-contents))))
(define (nsstackview-set-accessibility-critical-value! self accessibility-critical-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCriticalValue:")) (id->ffi2-ptr (coerce-arg accessibility-critical-value))))
(define (nsstackview-set-accessibility-custom-actions! self accessibility-custom-actions)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomActions:")) (id->ffi2-ptr (coerce-arg accessibility-custom-actions))))
(define (nsstackview-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomRotors:")) (id->ffi2-ptr (coerce-arg accessibility-custom-rotors))))
(define (nsstackview-set-accessibility-decrement-button! self accessibility-decrement-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDecrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-decrement-button))))
(define (nsstackview-set-accessibility-default-button! self accessibility-default-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDefaultButton:")) (id->ffi2-ptr (coerce-arg accessibility-default-button))))
(define (nsstackview-set-accessibility-disclosed! self accessibility-disclosed)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosed:")) accessibility-disclosed))
(define (nsstackview-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedByRow:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-by-row))))
(define (nsstackview-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedRows:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-rows))))
(define (nsstackview-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosureLevel:")) accessibility-disclosure-level))
(define (nsstackview-set-accessibility-document! self accessibility-document)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDocument:")) (id->ffi2-ptr (coerce-arg accessibility-document))))
(define (nsstackview-set-accessibility-edited! self accessibility-edited)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEdited:")) accessibility-edited))
(define (nsstackview-set-accessibility-element! self accessibility-element)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityElement:")) accessibility-element))
(define (nsstackview-set-accessibility-enabled! self accessibility-enabled)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEnabled:")) accessibility-enabled))
(define (nsstackview-set-accessibility-expanded! self accessibility-expanded)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExpanded:")) accessibility-expanded))
(define (nsstackview-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExtrasMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-extras-menu-bar))))
(define (nsstackview-set-accessibility-filename! self accessibility-filename)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFilename:")) (id->ffi2-ptr (coerce-arg accessibility-filename))))
(define (nsstackview-set-accessibility-focused! self accessibility-focused)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocused:")) accessibility-focused))
(define (nsstackview-set-accessibility-focused-window! self accessibility-focused-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocusedWindow:")) (id->ffi2-ptr (coerce-arg accessibility-focused-window))))
(define (nsstackview-set-accessibility-frame! self accessibility-frame)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrame:")) (id->ffi2-ptr accessibility-frame)))
(define (nsstackview-set-accessibility-frontmost! self accessibility-frontmost)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrontmost:")) accessibility-frontmost))
(define (nsstackview-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFullScreenButton:")) (id->ffi2-ptr (coerce-arg accessibility-full-screen-button))))
(define (nsstackview-set-accessibility-grow-area! self accessibility-grow-area)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityGrowArea:")) (id->ffi2-ptr (coerce-arg accessibility-grow-area))))
(define (nsstackview-set-accessibility-handles! self accessibility-handles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHandles:")) (id->ffi2-ptr (coerce-arg accessibility-handles))))
(define (nsstackview-set-accessibility-header! self accessibility-header)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHeader:")) (id->ffi2-ptr (coerce-arg accessibility-header))))
(define (nsstackview-set-accessibility-help! self accessibility-help)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHelp:")) (id->ffi2-ptr (coerce-arg accessibility-help))))
(define (nsstackview-set-accessibility-hidden! self accessibility-hidden)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHidden:")) accessibility-hidden))
(define (nsstackview-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-scroll-bar))))
(define (nsstackview-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-unit-description))))
(define (nsstackview-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnits:")) accessibility-horizontal-units))
(define (nsstackview-set-accessibility-identifier! self accessibility-identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIdentifier:")) (id->ffi2-ptr (coerce-arg accessibility-identifier))))
(define (nsstackview-set-accessibility-increment-button! self accessibility-increment-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIncrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-increment-button))))
(define (nsstackview-set-accessibility-index! self accessibility-index)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIndex:")) accessibility-index))
(define (nsstackview-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityInsertionPointLineNumber:")) accessibility-insertion-point-line-number))
(define (nsstackview-set-accessibility-label! self accessibility-label)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabel:")) (id->ffi2-ptr (coerce-arg accessibility-label))))
(define (nsstackview-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-label-ui-elements))))
(define (nsstackview-set-accessibility-label-value! self accessibility-label-value)
  (aw_racket_msg_f_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelValue:")) accessibility-label-value))
(define (nsstackview-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLinkedUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-linked-ui-elements))))
(define (nsstackview-set-accessibility-main! self accessibility-main)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMain:")) accessibility-main))
(define (nsstackview-set-accessibility-main-window! self accessibility-main-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMainWindow:")) (id->ffi2-ptr (coerce-arg accessibility-main-window))))
(define (nsstackview-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerGroupUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-marker-group-ui-element))))
(define (nsstackview-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerTypeDescription:")) (id->ffi2-ptr (coerce-arg accessibility-marker-type-description))))
(define (nsstackview-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-marker-ui-elements))))
(define (nsstackview-set-accessibility-marker-values! self accessibility-marker-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerValues:")) (id->ffi2-ptr (coerce-arg accessibility-marker-values))))
(define (nsstackview-set-accessibility-max-value! self accessibility-max-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMaxValue:")) (id->ffi2-ptr (coerce-arg accessibility-max-value))))
(define (nsstackview-set-accessibility-menu-bar! self accessibility-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-menu-bar))))
(define (nsstackview-set-accessibility-min-value! self accessibility-min-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinValue:")) (id->ffi2-ptr (coerce-arg accessibility-min-value))))
(define (nsstackview-set-accessibility-minimize-button! self accessibility-minimize-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimizeButton:")) (id->ffi2-ptr (coerce-arg accessibility-minimize-button))))
(define (nsstackview-set-accessibility-minimized! self accessibility-minimized)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimized:")) accessibility-minimized))
(define (nsstackview-set-accessibility-modal! self accessibility-modal)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityModal:")) accessibility-modal))
(define (nsstackview-set-accessibility-next-contents! self accessibility-next-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNextContents:")) (id->ffi2-ptr (coerce-arg accessibility-next-contents))))
(define (nsstackview-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNumberOfCharacters:")) accessibility-number-of-characters))
(define (nsstackview-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrderedByRow:")) accessibility-ordered-by-row))
(define (nsstackview-set-accessibility-orientation! self accessibility-orientation)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrientation:")) accessibility-orientation))
(define (nsstackview-set-accessibility-overflow-button! self accessibility-overflow-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOverflowButton:")) (id->ffi2-ptr (coerce-arg accessibility-overflow-button))))
(define (nsstackview-set-accessibility-parent! self accessibility-parent)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityParent:")) (id->ffi2-ptr (coerce-arg accessibility-parent))))
(define (nsstackview-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPlaceholderValue:")) (id->ffi2-ptr (coerce-arg accessibility-placeholder-value))))
(define (nsstackview-set-accessibility-previous-contents! self accessibility-previous-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPreviousContents:")) (id->ffi2-ptr (coerce-arg accessibility-previous-contents))))
(define (nsstackview-set-accessibility-protected-content! self accessibility-protected-content)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProtectedContent:")) accessibility-protected-content))
(define (nsstackview-set-accessibility-proxy! self accessibility-proxy)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProxy:")) (id->ffi2-ptr (coerce-arg accessibility-proxy))))
(define (nsstackview-set-accessibility-required! self accessibility-required)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRequired:")) accessibility-required))
(define (nsstackview-set-accessibility-role! self accessibility-role)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRole:")) (id->ffi2-ptr (coerce-arg accessibility-role))))
(define (nsstackview-set-accessibility-role-description! self accessibility-role-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRoleDescription:")) (id->ffi2-ptr (coerce-arg accessibility-role-description))))
(define (nsstackview-set-accessibility-row-count! self accessibility-row-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowCount:")) accessibility-row-count))
(define (nsstackview-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-row-header-ui-elements))))
(define (nsstackview-set-accessibility-row-index-range! self accessibility-row-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowIndexRange:")) (id->ffi2-ptr accessibility-row-index-range)))
(define (nsstackview-set-accessibility-rows! self accessibility-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRows:")) (id->ffi2-ptr (coerce-arg accessibility-rows))))
(define (nsstackview-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRulerMarkerType:")) accessibility-ruler-marker-type))
(define (nsstackview-set-accessibility-search-button! self accessibility-search-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchButton:")) (id->ffi2-ptr (coerce-arg accessibility-search-button))))
(define (nsstackview-set-accessibility-search-menu! self accessibility-search-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchMenu:")) (id->ffi2-ptr (coerce-arg accessibility-search-menu))))
(define (nsstackview-set-accessibility-selected! self accessibility-selected)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelected:")) accessibility-selected))
(define (nsstackview-set-accessibility-selected-cells! self accessibility-selected-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedCells:")) (id->ffi2-ptr (coerce-arg accessibility-selected-cells))))
(define (nsstackview-set-accessibility-selected-children! self accessibility-selected-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedChildren:")) (id->ffi2-ptr (coerce-arg accessibility-selected-children))))
(define (nsstackview-set-accessibility-selected-columns! self accessibility-selected-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedColumns:")) (id->ffi2-ptr (coerce-arg accessibility-selected-columns))))
(define (nsstackview-set-accessibility-selected-rows! self accessibility-selected-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedRows:")) (id->ffi2-ptr (coerce-arg accessibility-selected-rows))))
(define (nsstackview-set-accessibility-selected-text! self accessibility-selected-text)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedText:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text))))
(define (nsstackview-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRange:")) (id->ffi2-ptr accessibility-selected-text-range)))
(define (nsstackview-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRanges:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text-ranges))))
(define (nsstackview-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityServesAsTitleForUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-serves-as-title-for-ui-elements))))
(define (nsstackview-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedCharacterRange:")) (id->ffi2-ptr accessibility-shared-character-range)))
(define (nsstackview-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedFocusElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-focus-elements))))
(define (nsstackview-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedTextUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-text-ui-elements))))
(define (nsstackview-set-accessibility-shown-menu! self accessibility-shown-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityShownMenu:")) (id->ffi2-ptr (coerce-arg accessibility-shown-menu))))
(define (nsstackview-set-accessibility-sort-direction! self accessibility-sort-direction)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySortDirection:")) accessibility-sort-direction))
(define (nsstackview-set-accessibility-splitters! self accessibility-splitters)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySplitters:")) (id->ffi2-ptr (coerce-arg accessibility-splitters))))
(define (nsstackview-set-accessibility-subrole! self accessibility-subrole)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySubrole:")) (id->ffi2-ptr (coerce-arg accessibility-subrole))))
(define (nsstackview-set-accessibility-tabs! self accessibility-tabs)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTabs:")) (id->ffi2-ptr (coerce-arg accessibility-tabs))))
(define (nsstackview-set-accessibility-title! self accessibility-title)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitle:")) (id->ffi2-ptr (coerce-arg accessibility-title))))
(define (nsstackview-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitleUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-title-ui-element))))
(define (nsstackview-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityToolbarButton:")) (id->ffi2-ptr (coerce-arg accessibility-toolbar-button))))
(define (nsstackview-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTopLevelUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-top-level-ui-element))))
(define (nsstackview-set-accessibility-url! self accessibility-url)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityURL:")) (id->ffi2-ptr (coerce-arg accessibility-url))))
(define (nsstackview-set-accessibility-unit-description! self accessibility-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-unit-description))))
(define (nsstackview-set-accessibility-units! self accessibility-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnits:")) accessibility-units))
(define (nsstackview-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-user-input-labels))))
(define (nsstackview-set-accessibility-value! self accessibility-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValue:")) (id->ffi2-ptr (coerce-arg accessibility-value))))
(define (nsstackview-set-accessibility-value-description! self accessibility-value-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValueDescription:")) (id->ffi2-ptr (coerce-arg accessibility-value-description))))
(define (nsstackview-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-scroll-bar))))
(define (nsstackview-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-unit-description))))
(define (nsstackview-set-accessibility-vertical-units! self accessibility-vertical-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnits:")) accessibility-vertical-units))
(define (nsstackview-set-accessibility-visible-cells! self accessibility-visible-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCells:")) (id->ffi2-ptr (coerce-arg accessibility-visible-cells))))
(define (nsstackview-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCharacterRange:")) (id->ffi2-ptr accessibility-visible-character-range)))
(define (nsstackview-set-accessibility-visible-children! self accessibility-visible-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleChildren:")) (id->ffi2-ptr (coerce-arg accessibility-visible-children))))
(define (nsstackview-set-accessibility-visible-columns! self accessibility-visible-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleColumns:")) (id->ffi2-ptr (coerce-arg accessibility-visible-columns))))
(define (nsstackview-set-accessibility-visible-rows! self accessibility-visible-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleRows:")) (id->ffi2-ptr (coerce-arg accessibility-visible-rows))))
(define (nsstackview-set-accessibility-warning-value! self accessibility-warning-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWarningValue:")) (id->ffi2-ptr (coerce-arg accessibility-warning-value))))
(define (nsstackview-set-accessibility-window! self accessibility-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindow:")) (id->ffi2-ptr (coerce-arg accessibility-window))))
(define (nsstackview-set-accessibility-windows! self accessibility-windows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindows:")) (id->ffi2-ptr (coerce-arg accessibility-windows))))
(define (nsstackview-set-accessibility-zoom-button! self accessibility-zoom-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityZoomButton:")) (id->ffi2-ptr (coerce-arg accessibility-zoom-button))))
(define (nsstackview-set-animations! self animations)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAnimations:")) (id->ffi2-ptr (coerce-arg animations))))
(define (nsstackview-set-appearance! self appearance)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAppearance:")) (id->ffi2-ptr (coerce-arg appearance))))
(define (nsstackview-set-bounds-origin! self new-origin)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsOrigin:")) (id->ffi2-ptr new-origin)))
(define (nsstackview-set-bounds-size! self new-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsSize:")) (id->ffi2-ptr new-size)))
(define (nsstackview-set-clipping-resistance-priority-for-orientation! self clipping-resistance-priority orientation)
  (aw_racket_msg_fq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setClippingResistancePriority:forOrientation:")) clipping-resistance-priority orientation))
(define (nsstackview-set-content-compression-resistance-priority-for-orientation! self priority orientation)
  (aw_racket_msg_fq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentCompressionResistancePriority:forOrientation:")) priority orientation))
(define (nsstackview-set-content-hugging-priority-for-orientation! self priority orientation)
  (aw_racket_msg_fq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentHuggingPriority:forOrientation:")) priority orientation))
(define (nsstackview-set-custom-spacing-after-view! self spacing view)
  (aw_racket_msg_dP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCustomSpacing:afterView:")) spacing (id->ffi2-ptr (coerce-arg view))))
(define (nsstackview-set-frame-origin! self new-origin)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameOrigin:")) (id->ffi2-ptr new-origin)))
(define (nsstackview-set-frame-size! self new-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameSize:")) (id->ffi2-ptr new-size)))
(define (nsstackview-set-hugging-priority-for-orientation! self hugging-priority orientation)
  (aw_racket_msg_fq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHuggingPriority:forOrientation:")) hugging-priority orientation))
(define (nsstackview-set-identifier! self identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIdentifier:")) (id->ffi2-ptr (coerce-arg identifier))))
(define (nsstackview-set-keyboard-focus-ring-needs-display-in-rect! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setKeyboardFocusRingNeedsDisplayInRect:")) (id->ffi2-ptr rect)))
(define (nsstackview-set-mark! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-set-needs-display-in-rect! self invalid-rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsDisplayInRect:")) (id->ffi2-ptr invalid-rect)))
(define (nsstackview-set-views-in-gravity! self views gravity)
  (aw_racket_msg_Pq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setViews:inGravity:")) (id->ffi2-ptr (coerce-arg views)) gravity))
(define (nsstackview-set-visibility-priority-for-view! self priority view)
  (aw_racket_msg_fP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setVisibilityPriority:forView:")) priority (id->ffi2-ptr (coerce-arg view))))
(define (nsstackview-should-be-treated-as-ink-event self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldBeTreatedAsInkEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-should-delay-window-ordering-for-event self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldDelayWindowOrderingForEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-show-context-help self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextHelp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-show-context-menu-for-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextMenuForSelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-show-definition-for-attributed-string-at-point self attr-string text-baseline-origin)
  (aw_racket_msg_PO_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showDefinitionForAttributedString:atPoint:")) (id->ffi2-ptr (coerce-arg attr-string)) (id->ffi2-ptr text-baseline-origin)))
;; block param 3: async-copied (runtime-managed)
(define (nsstackview-show-definition-for-attributed-string-range-options-baseline-origin-provider self attr-string target-range options origin-provider)
  (define-values (_blk3 _blk3-id)
    (make-objc-block origin-provider (list _NSRange) _NSPoint))
  (aw_racket_msg_PGPP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showDefinitionForAttributedString:range:options:baselineOriginProvider:")) (id->ffi2-ptr (coerce-arg attr-string)) (id->ffi2-ptr target-range) (id->ffi2-ptr (coerce-arg options)) (id->ffi2-ptr _blk3)))
(define (nsstackview-show-writing-tools self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showWritingTools:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-smart-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "smartMagnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-sort-subviews-using-function-context self compare context)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sortSubviewsUsingFunction:context:")) (id->ffi2-ptr compare) (id->ffi2-ptr context)))
(define (nsstackview-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "supplementalTargetForAction:sender:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg sender))))
   ))
(define (nsstackview-swap-with-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swapWithMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-swipe-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swipeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-tablet-point self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletPoint:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-tablet-proximity self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletProximity:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-touches-began-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesBeganWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-touches-cancelled-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesCancelledWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-touches-ended-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesEndedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-touches-moved-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesMovedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-translate-origin-to-point self translation)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translateOriginToPoint:")) (id->ffi2-ptr translation)))
(define (nsstackview-translate-rects-needing-display-in-rect-by self clip-rect delta)
  (aw_racket_msg_RZ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translateRectsNeedingDisplayInRect:by:")) (id->ffi2-ptr clip-rect) (id->ffi2-ptr delta)))
(define (nsstackview-transpose self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transpose:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-transpose-words self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transposeWords:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-try-to-perform-with self action object)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tryToPerform:with:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg object))))
(define (nsstackview-unregister-dragged-types self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "unregisterDraggedTypes"))))
(define (nsstackview-update-constraints self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateConstraints"))))
(define (nsstackview-update-constraints-for-subtree-if-needed self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateConstraintsForSubtreeIfNeeded"))))
(define (nsstackview-update-dragging-items-for-drag self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateDraggingItemsForDrag:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-update-layer self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateLayer"))))
(define (nsstackview-update-tracking-areas self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateTrackingAreas"))))
(define (nsstackview-update-user-activity-state self user-activity)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateUserActivityState:")) (id->ffi2-ptr (coerce-arg user-activity))))
(define (nsstackview-uppercase-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "uppercaseWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsstackview-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validRequestorForSendType:returnType:")) (id->ffi2-ptr (coerce-arg send-type)) (id->ffi2-ptr (coerce-arg return-type))))
   ))
(define (nsstackview-validate-proposed-first-responder-for-event self responder event)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validateProposedFirstResponder:forEvent:")) (id->ffi2-ptr (coerce-arg responder)) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-view-did-change-backing-properties self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidChangeBackingProperties"))))
(define (nsstackview-view-did-change-effective-appearance self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidChangeEffectiveAppearance"))))
(define (nsstackview-view-did-end-live-resize self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidEndLiveResize"))))
(define (nsstackview-view-did-hide self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidHide"))))
(define (nsstackview-view-did-move-to-superview self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidMoveToSuperview"))))
(define (nsstackview-view-did-move-to-window self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidMoveToWindow"))))
(define (nsstackview-view-did-unhide self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidUnhide"))))
(define (nsstackview-view-will-draw self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillDraw"))))
(define (nsstackview-view-will-move-to-superview self new-superview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillMoveToSuperview:")) (id->ffi2-ptr (coerce-arg new-superview))))
(define (nsstackview-view-will-move-to-window self new-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillMoveToWindow:")) (id->ffi2-ptr (coerce-arg new-window))))
(define (nsstackview-view-will-start-live-resize self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillStartLiveResize"))))
(define (nsstackview-view-with-tag self tag)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWithTag:")) tag))
   ))
(define (nsstackview-views-in-gravity self gravity)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewsInGravity:")) gravity))
   ))
(define (nsstackview-visibility-priority-for-view self view)
  (aw_racket_msg_P_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "visibilityPriorityForView:")) (id->ffi2-ptr (coerce-arg view))))
(define (nsstackview-wants-forwarded-scroll-events-for-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsForwardedScrollEventsForAxis:")) axis))
(define (nsstackview-wants-periodic-dragging-updates self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsPeriodicDraggingUpdates"))))
(define (nsstackview-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:")) axis))
(define (nsstackview-will-open-menu-with-event self menu event)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "willOpenMenu:withEvent:")) (id->ffi2-ptr (coerce-arg menu)) (id->ffi2-ptr (coerce-arg event))))
(define (nsstackview-will-present-error self error)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "willPresentError:")) (id->ffi2-ptr (coerce-arg error))))
   ))
(define (nsstackview-will-remove-subview self subview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "willRemoveSubview:")) (id->ffi2-ptr (coerce-arg subview))))
(define (nsstackview-write-eps-inside-rect-to-pasteboard self rect pasteboard)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writeEPSInsideRect:toPasteboard:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg pasteboard))))
(define (nsstackview-write-pdf-inside-rect-to-pasteboard self rect pasteboard)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writePDFInsideRect:toPasteboard:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg pasteboard))))
(define (nsstackview-yank self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "yank:")) (id->ffi2-ptr (coerce-arg sender))))

;; --- Class methods ---
(define (nsstackview-allowed-classes-for-restorable-state-key-path key-path)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSStackView) (id->ffi2-ptr (sel_registerName "allowedClassesForRestorableStateKeyPath:")) (id->ffi2-ptr (coerce-arg key-path))))
   ))
(define (nsstackview-default-animation-for-key key)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSStackView) (id->ffi2-ptr (sel_registerName "defaultAnimationForKey:")) (id->ffi2-ptr (coerce-arg key))))
   ))
(define (nsstackview-is-compatible-with-responsive-scrolling)
  (aw_racket_msg_0_b (id->ffi2-ptr NSStackView) (id->ffi2-ptr (sel_registerName "isCompatibleWithResponsiveScrolling"))))
(define (nsstackview-stack-view-with-views views)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSStackView) (id->ffi2-ptr (sel_registerName "stackViewWithViews:")) (id->ffi2-ptr (coerce-arg views))))
   ))
