#lang racket/base
;; Generated binding for NSStackView (AppKit)
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
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsedgeinsets? v) (objc-instance-of? v "NSEdgeInsets"))
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
  [nsstackview-alignment (c-> nsstackview? exact-nonnegative-integer?)]
  [nsstackview-set-alignment! (c-> nsstackview? exact-nonnegative-integer? void?)]
  [nsstackview-alignment-rect-insets (c-> nsstackview? any/c)]
  [nsstackview-allowed-touch-types (c-> nsstackview? exact-nonnegative-integer?)]
  [nsstackview-set-allowed-touch-types! (c-> nsstackview? exact-nonnegative-integer? void?)]
  [nsstackview-allows-vibrancy (c-> nsstackview? boolean?)]
  [nsstackview-alpha-value (c-> nsstackview? real?)]
  [nsstackview-set-alpha-value! (c-> nsstackview? real? void?)]
  [nsstackview-arranged-subviews (c-> nsstackview? any/c)]
  [nsstackview-autoresizes-subviews (c-> nsstackview? boolean?)]
  [nsstackview-set-autoresizes-subviews! (c-> nsstackview? boolean? void?)]
  [nsstackview-autoresizing-mask (c-> nsstackview? exact-nonnegative-integer?)]
  [nsstackview-set-autoresizing-mask! (c-> nsstackview? exact-nonnegative-integer? void?)]
  [nsstackview-background-filters (c-> nsstackview? any/c)]
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
  [nsstackview-constraints (c-> nsstackview? any/c)]
  [nsstackview-content-filters (c-> nsstackview? any/c)]
  [nsstackview-set-content-filters! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-default-focus-ring-type (c-> exact-nonnegative-integer?)]
  [nsstackview-default-menu (c-> (or/c nsmenu? objc-nil?))]
  [nsstackview-delegate (c-> nsstackview? any/c)]
  [nsstackview-set-delegate! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-detached-views (c-> nsstackview? any/c)]
  [nsstackview-detaches-hidden-views (c-> nsstackview? boolean?)]
  [nsstackview-set-detaches-hidden-views! (c-> nsstackview? boolean? void?)]
  [nsstackview-distribution (c-> nsstackview? exact-nonnegative-integer?)]
  [nsstackview-set-distribution! (c-> nsstackview? exact-nonnegative-integer? void?)]
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
  [nsstackview-gesture-recognizers (c-> nsstackview? any/c)]
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
  [nsstackview-layer-contents-placement (c-> nsstackview? exact-nonnegative-integer?)]
  [nsstackview-set-layer-contents-placement! (c-> nsstackview? exact-nonnegative-integer? void?)]
  [nsstackview-layer-contents-redraw-policy (c-> nsstackview? exact-nonnegative-integer?)]
  [nsstackview-set-layer-contents-redraw-policy! (c-> nsstackview? exact-nonnegative-integer? void?)]
  [nsstackview-layer-uses-core-image-filters (c-> nsstackview? boolean?)]
  [nsstackview-set-layer-uses-core-image-filters! (c-> nsstackview? boolean? void?)]
  [nsstackview-layout-guides (c-> nsstackview? any/c)]
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
  [nsstackview-orientation (c-> nsstackview? exact-nonnegative-integer?)]
  [nsstackview-set-orientation! (c-> nsstackview? exact-nonnegative-integer? void?)]
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
  [nsstackview-registered-dragged-types (c-> nsstackview? any/c)]
  [nsstackview-requires-constraint-based-layout (c-> boolean?)]
  [nsstackview-restorable-state-key-paths (c-> any/c)]
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
  [nsstackview-subviews (c-> nsstackview? any/c)]
  [nsstackview-set-subviews! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-superview (c-> nsstackview? (or/c nsview? objc-nil?))]
  [nsstackview-tag (c-> nsstackview? exact-integer?)]
  [nsstackview-tool-tip (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-set-tool-tip! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-top-anchor (c-> nsstackview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsstackview-touch-bar (c-> nsstackview? (or/c nstouchbar? objc-nil?))]
  [nsstackview-set-touch-bar! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-tracking-areas (c-> nsstackview? any/c)]
  [nsstackview-trailing-anchor (c-> nsstackview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsstackview-translates-autoresizing-mask-into-constraints (c-> nsstackview? boolean?)]
  [nsstackview-set-translates-autoresizing-mask-into-constraints! (c-> nsstackview? boolean? void?)]
  [nsstackview-undo-manager (c-> nsstackview? (or/c nsundomanager? objc-nil?))]
  [nsstackview-user-activity (c-> nsstackview? (or/c nsuseractivity? objc-nil?))]
  [nsstackview-set-user-activity! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-user-interface-layout-direction (c-> nsstackview? exact-nonnegative-integer?)]
  [nsstackview-set-user-interface-layout-direction! (c-> nsstackview? exact-nonnegative-integer? void?)]
  [nsstackview-vertical-content-size-constraint-active (c-> nsstackview? boolean?)]
  [nsstackview-set-vertical-content-size-constraint-active! (c-> nsstackview? boolean? void?)]
  [nsstackview-views (c-> nsstackview? any/c)]
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
  [nsstackview-accessibility-allowed-values (c-> nsstackview? any/c)]
  [nsstackview-accessibility-application-focused-ui-element (c-> nsstackview? any/c)]
  [nsstackview-accessibility-attributed-string-for-range (c-> nsstackview? any/c (or/c nsattributedstring? objc-nil?))]
  [nsstackview-accessibility-attributed-user-input-labels (c-> nsstackview? any/c)]
  [nsstackview-accessibility-cancel-button (c-> nsstackview? any/c)]
  [nsstackview-accessibility-cell-for-column-row (c-> nsstackview? exact-integer? exact-integer? any/c)]
  [nsstackview-accessibility-children (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-children-in-navigation-order (c-> nsstackview? any/c)]
  [nsstackview-accessibility-clear-button (c-> nsstackview? any/c)]
  [nsstackview-accessibility-close-button (c-> nsstackview? any/c)]
  [nsstackview-accessibility-column-count (c-> nsstackview? exact-integer?)]
  [nsstackview-accessibility-column-header-ui-elements (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-column-index-range (c-> nsstackview? any/c)]
  [nsstackview-accessibility-column-titles (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-columns (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-contents (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-critical-value (c-> nsstackview? any/c)]
  [nsstackview-accessibility-custom-actions (c-> nsstackview? any/c)]
  [nsstackview-accessibility-custom-rotors (c-> nsstackview? any/c)]
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
  [nsstackview-accessibility-horizontal-units (c-> nsstackview? exact-nonnegative-integer?)]
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
  [nsstackview-accessibility-orientation (c-> nsstackview? exact-nonnegative-integer?)]
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
  [nsstackview-accessibility-ruler-marker-type (c-> nsstackview? exact-nonnegative-integer?)]
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
  [nsstackview-accessibility-selected-text-ranges (c-> nsstackview? any/c)]
  [nsstackview-accessibility-serves-as-title-for-ui-elements (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-shared-character-range (c-> nsstackview? any/c)]
  [nsstackview-accessibility-shared-focus-elements (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-shared-text-ui-elements (c-> nsstackview? (or/c nsarray? objc-nil?))]
  [nsstackview-accessibility-shown-menu (c-> nsstackview? any/c)]
  [nsstackview-accessibility-sort-direction (c-> nsstackview? exact-nonnegative-integer?)]
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
  [nsstackview-accessibility-units (c-> nsstackview? exact-nonnegative-integer?)]
  [nsstackview-accessibility-user-input-labels (c-> nsstackview? any/c)]
  [nsstackview-accessibility-value (c-> nsstackview? any/c)]
  [nsstackview-accessibility-value-description (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-vertical-scroll-bar (c-> nsstackview? any/c)]
  [nsstackview-accessibility-vertical-unit-description (c-> nsstackview? (or/c nsstring? objc-nil?))]
  [nsstackview-accessibility-vertical-units (c-> nsstackview? exact-nonnegative-integer?)]
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
  [nsstackview-add-subview! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-add-subview-positioned-relative-to! (c-> nsstackview? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c string? objc-object? #f) void?)]
  [nsstackview-add-tool-tip-rect-owner-user-data! (c-> nsstackview? any/c (or/c string? objc-object? #f) (or/c cpointer? #f) exact-integer?)]
  [nsstackview-adjust-scroll (c-> nsstackview? any/c any/c)]
  [nsstackview-ancestor-shared-with-view (c-> nsstackview? (or/c string? objc-object? #f) (or/c nsview? objc-nil?))]
  [nsstackview-animation-for-key (c-> nsstackview? (or/c string? objc-object? #f) any/c)]
  [nsstackview-animations (c-> nsstackview? any/c)]
  [nsstackview-animator (c-> nsstackview? any/c)]
  [nsstackview-appearance (c-> nsstackview? (or/c nsappearance? objc-nil?))]
  [nsstackview-autoscroll (c-> nsstackview? (or/c string? objc-object? #f) boolean?)]
  [nsstackview-backing-aligned-rect-options (c-> nsstackview? any/c exact-nonnegative-integer? any/c)]
  [nsstackview-become-first-responder (c-> nsstackview? boolean?)]
  [nsstackview-begin-gesture-with-event! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-bitmap-image-rep-for-caching-display-in-rect (c-> nsstackview? any/c (or/c nsbitmapimagerep? objc-nil?))]
  [nsstackview-cache-display-in-rect-to-bitmap-image-rep (c-> nsstackview? any/c (or/c string? objc-object? #f) void?)]
  [nsstackview-cancel-operation (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-capitalize-word (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-center-scan-rect! (c-> nsstackview? any/c any/c)]
  [nsstackview-center-selection-in-visible-area! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-change-case-of-letter (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-change-mode-with-event (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-clipping-resistance-priority-for-orientation (c-> nsstackview? exact-nonnegative-integer? real?)]
  [nsstackview-complete (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-conclude-drag-operation (c-> nsstackview? (or/c string? objc-object? #f) void?)]
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
  [nsstackview-display! (c-> nsstackview? void?)]
  [nsstackview-display-if-needed! (c-> nsstackview? void?)]
  [nsstackview-display-if-needed-ignoring-opacity! (c-> nsstackview? void?)]
  [nsstackview-display-if-needed-in-rect! (c-> nsstackview? any/c void?)]
  [nsstackview-display-if-needed-in-rect-ignoring-opacity! (c-> nsstackview? any/c void?)]
  [nsstackview-display-rect! (c-> nsstackview? any/c void?)]
  [nsstackview-display-rect-ignoring-opacity! (c-> nsstackview? any/c void?)]
  [nsstackview-display-rect-ignoring-opacity-in-context! (c-> nsstackview? any/c (or/c string? objc-object? #f) void?)]
  [nsstackview-do-command-by-selector (c-> nsstackview? string? void?)]
  [nsstackview-dragging-ended (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-dragging-entered (c-> nsstackview? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nsstackview-dragging-exited (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-dragging-updated (c-> nsstackview? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nsstackview-draw-rect (c-> nsstackview? any/c void?)]
  [nsstackview-effective-appearance (c-> nsstackview? (or/c nsappearance? objc-nil?))]
  [nsstackview-encode-with-coder (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-end-gesture-with-event! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-flags-changed (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-flush-buffered-key-events (c-> nsstackview? void?)]
  [nsstackview-get-rects-being-drawn-count (c-> nsstackview? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nsstackview-get-rects-exposed-during-live-resize-count (c-> nsstackview? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nsstackview-help-requested (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-hit-test (c-> nsstackview? any/c (or/c nsview? objc-nil?))]
  [nsstackview-hugging-priority-for-orientation (c-> nsstackview? exact-nonnegative-integer? real?)]
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
  [nsstackview-interpret-key-events (c-> nsstackview? (or/c string? objc-object? #f) void?)]
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
  [nsstackview-is-flipped (c-> nsstackview? boolean?)]
  [nsstackview-is-hidden (c-> nsstackview? boolean?)]
  [nsstackview-is-hidden-or-has-hidden-ancestor (c-> nsstackview? boolean?)]
  [nsstackview-is-opaque (c-> nsstackview? boolean?)]
  [nsstackview-is-rotated-from-base (c-> nsstackview? boolean?)]
  [nsstackview-is-rotated-or-scaled-from-base (c-> nsstackview? boolean?)]
  [nsstackview-key-down (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-key-up (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-layout (c-> nsstackview? void?)]
  [nsstackview-layout-subtree-if-needed (c-> nsstackview? void?)]
  [nsstackview-lowercase-word (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-magnify-with-event (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-make-backing-layer (c-> nsstackview? (or/c calayer? objc-nil?))]
  [nsstackview-make-base-writing-direction-left-to-right (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-make-base-writing-direction-natural (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-make-base-writing-direction-right-to-left (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-make-text-writing-direction-left-to-right (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-make-text-writing-direction-natural (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-make-text-writing-direction-right-to-left (c-> nsstackview? (or/c string? objc-object? #f) void?)]
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
  [nsstackview-no-responder-for (c-> nsstackview? string? void?)]
  [nsstackview-other-mouse-down (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-other-mouse-dragged (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-other-mouse-up (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-page-down (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-page-down-and-modify-selection (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-page-up (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-page-up-and-modify-selection (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-perform-drag-operation! (c-> nsstackview? (or/c string? objc-object? #f) boolean?)]
  [nsstackview-perform-key-equivalent! (c-> nsstackview? (or/c string? objc-object? #f) boolean?)]
  [nsstackview-prepare-content-in-rect (c-> nsstackview? any/c void?)]
  [nsstackview-prepare-for-drag-operation (c-> nsstackview? (or/c string? objc-object? #f) boolean?)]
  [nsstackview-prepare-for-reuse (c-> nsstackview? void?)]
  [nsstackview-pressure-change-with-event (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-quick-look-preview-items (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-quick-look-with-event (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-rect-for-smart-magnification-at-point-in-rect (c-> nsstackview? any/c any/c any/c)]
  [nsstackview-remove-all-tool-tips! (c-> nsstackview? void?)]
  [nsstackview-remove-arranged-subview! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-remove-from-superview! (c-> nsstackview? void?)]
  [nsstackview-remove-from-superview-without-needing-display! (c-> nsstackview? void?)]
  [nsstackview-remove-tool-tip! (c-> nsstackview? exact-integer? void?)]
  [nsstackview-replace-subview-with! (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsstackview-resign-first-responder (c-> nsstackview? boolean?)]
  [nsstackview-resize-subviews-with-old-size (c-> nsstackview? any/c void?)]
  [nsstackview-resize-with-old-superview-size (c-> nsstackview? any/c void?)]
  [nsstackview-restore-user-activity-state (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-right-mouse-down (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-right-mouse-dragged (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-right-mouse-up (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-rotate-by-angle (c-> nsstackview? real? void?)]
  [nsstackview-rotate-with-event (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-scale-unit-square-to-size (c-> nsstackview? any/c void?)]
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
  [nsstackview-set-accessibility-horizontal-units! (c-> nsstackview? exact-nonnegative-integer? void?)]
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
  [nsstackview-set-accessibility-orientation! (c-> nsstackview? exact-nonnegative-integer? void?)]
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
  [nsstackview-set-accessibility-ruler-marker-type! (c-> nsstackview? exact-nonnegative-integer? void?)]
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
  [nsstackview-set-accessibility-sort-direction! (c-> nsstackview? exact-nonnegative-integer? void?)]
  [nsstackview-set-accessibility-splitters! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-subrole! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-tabs! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-title! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-title-ui-element! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-toolbar-button! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-top-level-ui-element! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-url! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-unit-description! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-units! (c-> nsstackview? exact-nonnegative-integer? void?)]
  [nsstackview-set-accessibility-user-input-labels! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-value! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-value-description! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-vertical-scroll-bar! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-vertical-unit-description! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-accessibility-vertical-units! (c-> nsstackview? exact-nonnegative-integer? void?)]
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
  [nsstackview-set-clipping-resistance-priority-for-orientation! (c-> nsstackview? real? exact-nonnegative-integer? void?)]
  [nsstackview-set-custom-spacing-after-view! (c-> nsstackview? real? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-frame-origin! (c-> nsstackview? any/c void?)]
  [nsstackview-set-frame-size! (c-> nsstackview? any/c void?)]
  [nsstackview-set-hugging-priority-for-orientation! (c-> nsstackview? real? exact-nonnegative-integer? void?)]
  [nsstackview-set-identifier! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-mark! (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-set-needs-display-in-rect! (c-> nsstackview? any/c void?)]
  [nsstackview-set-visibility-priority-for-view! (c-> nsstackview? real? (or/c string? objc-object? #f) void?)]
  [nsstackview-should-be-treated-as-ink-event (c-> nsstackview? (or/c string? objc-object? #f) boolean?)]
  [nsstackview-should-delay-window-ordering-for-event (c-> nsstackview? (or/c string? objc-object? #f) boolean?)]
  [nsstackview-show-context-help (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-show-context-menu-for-selection (c-> nsstackview? (or/c string? objc-object? #f) void?)]
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
  [nsstackview-update-dragging-items-for-drag (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-update-layer (c-> nsstackview? void?)]
  [nsstackview-uppercase-word (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-valid-requestor-for-send-type-return-type (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
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
  [nsstackview-view-with-tag (c-> nsstackview? exact-integer? any/c)]
  [nsstackview-visibility-priority-for-view (c-> nsstackview? (or/c string? objc-object? #f) real?)]
  [nsstackview-wants-forwarded-scroll-events-for-axis (c-> nsstackview? exact-nonnegative-integer? boolean?)]
  [nsstackview-wants-periodic-dragging-updates (c-> nsstackview? boolean?)]
  [nsstackview-wants-scroll-events-for-swipe-tracking-on-axis (c-> nsstackview? exact-nonnegative-integer? boolean?)]
  [nsstackview-will-open-menu-with-event (c-> nsstackview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsstackview-will-remove-subview (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-yank (c-> nsstackview? (or/c string? objc-object? #f) void?)]
  [nsstackview-default-animation-for-key (c-> (or/c string? objc-object? #f) any/c)]
  [nsstackview-is-compatible-with-responsive-scrolling (c-> boolean?)]
  [nsstackview-stack-view-with-views (c-> (or/c string? objc-object? #f) any/c)]
  )

;; --- Class reference ---
(import-class NSStackView)

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer -> _NSEdgeInsets)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _NSEdgeInsets)))
(define _msg-1  ; (_fun _pointer _pointer -> _NSPoint)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _NSPoint)))
(define _msg-2  ; (_fun _pointer _pointer -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _NSRange)))
(define _msg-3  ; (_fun _pointer _pointer -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _NSRect)))
(define _msg-4  ; (_fun _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _bool)))
(define _msg-5  ; (_fun _pointer _pointer -> _double)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _double)))
(define _msg-6  ; (_fun _pointer _pointer -> _float)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _float)))
(define _msg-7  ; (_fun _pointer _pointer -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _int64)))
(define _msg-8  ; (_fun _pointer _pointer -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _uint64)))
(define _msg-9  ; (_fun _pointer _pointer _NSEdgeInsets -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSEdgeInsets -> _void)))
(define _msg-10  ; (_fun _pointer _pointer _NSPoint -> _NSPoint)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _NSPoint)))
(define _msg-11  ; (_fun _pointer _pointer _NSPoint -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _NSRange)))
(define _msg-12  ; (_fun _pointer _pointer _NSPoint -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _id)))
(define _msg-13  ; (_fun _pointer _pointer _NSPoint -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _void)))
(define _msg-14  ; (_fun _pointer _pointer _NSPoint _NSRect -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint _NSRect -> _NSRect)))
(define _msg-15  ; (_fun _pointer _pointer _NSPoint _NSRect -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint _NSRect -> _bool)))
(define _msg-16  ; (_fun _pointer _pointer _NSPoint _id -> _NSPoint)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint _id -> _NSPoint)))
(define _msg-17  ; (_fun _pointer _pointer _NSRange -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _NSRect)))
(define _msg-18  ; (_fun _pointer _pointer _NSRange -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _id)))
(define _msg-19  ; (_fun _pointer _pointer _NSRange -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _void)))
(define _msg-20  ; (_fun _pointer _pointer _NSRect -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _NSRect)))
(define _msg-21  ; (_fun _pointer _pointer _NSRect -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _bool)))
(define _msg-22  ; (_fun _pointer _pointer _NSRect -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _id)))
(define _msg-23  ; (_fun _pointer _pointer _NSRect -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _void)))
(define _msg-24  ; (_fun _pointer _pointer _NSRect _NSSize -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _NSSize -> _void)))
(define _msg-25  ; (_fun _pointer _pointer _NSRect _id -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id -> _NSRect)))
(define _msg-26  ; (_fun _pointer _pointer _NSRect _id -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id -> _void)))
(define _msg-27  ; (_fun _pointer _pointer _NSRect _id _pointer -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id _pointer -> _int64)))
(define _msg-28  ; (_fun _pointer _pointer _NSRect _uint64 -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _uint64 -> _NSRect)))
(define _msg-29  ; (_fun _pointer _pointer _NSSize -> _NSSize)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize -> _NSSize)))
(define _msg-30  ; (_fun _pointer _pointer _NSSize -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize -> _void)))
(define _msg-31  ; (_fun _pointer _pointer _NSSize _id -> _NSSize)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize _id -> _NSSize)))
(define _msg-32  ; (_fun _pointer _pointer _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _bool -> _void)))
(define _msg-33  ; (_fun _pointer _pointer _double -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double -> _void)))
(define _msg-34  ; (_fun _pointer _pointer _double _id -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double _id -> _void)))
(define _msg-35  ; (_fun _pointer _pointer _float -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _float -> _void)))
(define _msg-36  ; (_fun _pointer _pointer _float _id -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _float _id -> _void)))
(define _msg-37  ; (_fun _pointer _pointer _float _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _float _int64 -> _void)))
(define _msg-38  ; (_fun _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _bool)))
(define _msg-39  ; (_fun _pointer _pointer _id -> _double)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _double)))
(define _msg-40  ; (_fun _pointer _pointer _id -> _float)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _float)))
(define _msg-41  ; (_fun _pointer _pointer _id -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _uint64)))
(define _msg-42  ; (_fun _pointer _pointer _id _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _int64 -> _void)))
(define _msg-43  ; (_fun _pointer _pointer _id _int64 _id -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _int64 _id -> _void)))
(define _msg-44  ; (_fun _pointer _pointer _int64 -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _NSRange)))
(define _msg-45  ; (_fun _pointer _pointer _int64 -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _bool)))
(define _msg-46  ; (_fun _pointer _pointer _int64 -> _float)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _float)))
(define _msg-47  ; (_fun _pointer _pointer _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _id)))
(define _msg-48  ; (_fun _pointer _pointer _int64 -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _int64)))
(define _msg-49  ; (_fun _pointer _pointer _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _void)))
(define _msg-50  ; (_fun _pointer _pointer _int64 _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _int64 -> _id)))
(define _msg-51  ; (_fun _pointer _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _bool)))
(define _msg-52  ; (_fun _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _void)))
(define _msg-53  ; (_fun _pointer _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _bool)))
(define _msg-54  ; (_fun _pointer _pointer _pointer _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _id)))
(define _msg-55  ; (_fun _pointer _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _pointer -> _void)))
(define _msg-56  ; (_fun _pointer _pointer _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _void)))

;; --- Constructors ---
(define (make-nsstackview-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSStackView alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nsstackview-init-with-frame frame-rect)
  (wrap-objc-object
   (_msg-22 (tell NSStackView alloc)
       (sel_registerName "initWithFrame:")
       frame-rect)
   #:retained #t))


;; --- Properties ---
(define (nsstackview-accepts-first-responder self)
  (tell #:type _bool (coerce-arg self) acceptsFirstResponder))
(define (nsstackview-accepts-touch-events self)
  (tell #:type _bool (coerce-arg self) acceptsTouchEvents))
(define (nsstackview-set-accepts-touch-events! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setAcceptsTouchEvents:") value))
(define (nsstackview-additional-safe-area-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) additionalSafeAreaInsets))
(define (nsstackview-set-additional-safe-area-insets! self value)
  (_msg-9 (coerce-arg self) (sel_registerName "setAdditionalSafeAreaInsets:") value))
(define (nsstackview-alignment self)
  (tell #:type _int64 (coerce-arg self) alignment))
(define (nsstackview-set-alignment! self value)
  (_msg-49 (coerce-arg self) (sel_registerName "setAlignment:") value))
(define (nsstackview-alignment-rect-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) alignmentRectInsets))
(define (nsstackview-allowed-touch-types self)
  (tell #:type _uint64 (coerce-arg self) allowedTouchTypes))
(define (nsstackview-set-allowed-touch-types! self value)
  (_msg-56 (coerce-arg self) (sel_registerName "setAllowedTouchTypes:") value))
(define (nsstackview-allows-vibrancy self)
  (tell #:type _bool (coerce-arg self) allowsVibrancy))
(define (nsstackview-alpha-value self)
  (tell #:type _double (coerce-arg self) alphaValue))
(define (nsstackview-set-alpha-value! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setAlphaValue:") value))
(define (nsstackview-arranged-subviews self)
  (wrap-objc-object
   (tell (coerce-arg self) arrangedSubviews)))
(define (nsstackview-autoresizes-subviews self)
  (tell #:type _bool (coerce-arg self) autoresizesSubviews))
(define (nsstackview-set-autoresizes-subviews! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setAutoresizesSubviews:") value))
(define (nsstackview-autoresizing-mask self)
  (tell #:type _uint64 (coerce-arg self) autoresizingMask))
(define (nsstackview-set-autoresizing-mask! self value)
  (_msg-56 (coerce-arg self) (sel_registerName "setAutoresizingMask:") value))
(define (nsstackview-background-filters self)
  (wrap-objc-object
   (tell (coerce-arg self) backgroundFilters)))
(define (nsstackview-set-background-filters! self value)
  (tell #:type _void (coerce-arg self) setBackgroundFilters: (coerce-arg value)))
(define (nsstackview-baseline-offset-from-bottom self)
  (tell #:type _double (coerce-arg self) baselineOffsetFromBottom))
(define (nsstackview-bottom-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) bottomAnchor)))
(define (nsstackview-bounds self)
  (tell #:type _NSRect (coerce-arg self) bounds))
(define (nsstackview-set-bounds! self value)
  (_msg-23 (coerce-arg self) (sel_registerName "setBounds:") value))
(define (nsstackview-bounds-rotation self)
  (tell #:type _double (coerce-arg self) boundsRotation))
(define (nsstackview-set-bounds-rotation! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setBoundsRotation:") value))
(define (nsstackview-can-become-key-view self)
  (tell #:type _bool (coerce-arg self) canBecomeKeyView))
(define (nsstackview-can-draw self)
  (tell #:type _bool (coerce-arg self) canDraw))
(define (nsstackview-can-draw-concurrently self)
  (tell #:type _bool (coerce-arg self) canDrawConcurrently))
(define (nsstackview-set-can-draw-concurrently! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setCanDrawConcurrently:") value))
(define (nsstackview-can-draw-subviews-into-layer self)
  (tell #:type _bool (coerce-arg self) canDrawSubviewsIntoLayer))
(define (nsstackview-set-can-draw-subviews-into-layer! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setCanDrawSubviewsIntoLayer:") value))
(define (nsstackview-candidate-list-touch-bar-item self)
  (wrap-objc-object
   (tell (coerce-arg self) candidateListTouchBarItem)))
(define (nsstackview-center-x-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) centerXAnchor)))
(define (nsstackview-center-y-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) centerYAnchor)))
(define (nsstackview-clips-to-bounds self)
  (tell #:type _bool (coerce-arg self) clipsToBounds))
(define (nsstackview-set-clips-to-bounds! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setClipsToBounds:") value))
(define (nsstackview-compatible-with-responsive-scrolling)
  (tell #:type _bool NSStackView compatibleWithResponsiveScrolling))
(define (nsstackview-compositing-filter self)
  (wrap-objc-object
   (tell (coerce-arg self) compositingFilter)))
(define (nsstackview-set-compositing-filter! self value)
  (tell #:type _void (coerce-arg self) setCompositingFilter: (coerce-arg value)))
(define (nsstackview-constraints self)
  (wrap-objc-object
   (tell (coerce-arg self) constraints)))
(define (nsstackview-content-filters self)
  (wrap-objc-object
   (tell (coerce-arg self) contentFilters)))
(define (nsstackview-set-content-filters! self value)
  (tell #:type _void (coerce-arg self) setContentFilters: (coerce-arg value)))
(define (nsstackview-default-focus-ring-type)
  (tell #:type _uint64 NSStackView defaultFocusRingType))
(define (nsstackview-default-menu)
  (wrap-objc-object
   (tell NSStackView defaultMenu)))
(define (nsstackview-delegate self)
  (wrap-objc-object
   (tell (coerce-arg self) delegate)))
(define (nsstackview-set-delegate! self value)
  (tell #:type _void (coerce-arg self) setDelegate: (coerce-arg value)))
(define (nsstackview-detached-views self)
  (wrap-objc-object
   (tell (coerce-arg self) detachedViews)))
(define (nsstackview-detaches-hidden-views self)
  (tell #:type _bool (coerce-arg self) detachesHiddenViews))
(define (nsstackview-set-detaches-hidden-views! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setDetachesHiddenViews:") value))
(define (nsstackview-distribution self)
  (tell #:type _int64 (coerce-arg self) distribution))
(define (nsstackview-set-distribution! self value)
  (_msg-49 (coerce-arg self) (sel_registerName "setDistribution:") value))
(define (nsstackview-drawing-find-indicator self)
  (tell #:type _bool (coerce-arg self) drawingFindIndicator))
(define (nsstackview-edge-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) edgeInsets))
(define (nsstackview-set-edge-insets! self value)
  (_msg-9 (coerce-arg self) (sel_registerName "setEdgeInsets:") value))
(define (nsstackview-enclosing-menu-item self)
  (wrap-objc-object
   (tell (coerce-arg self) enclosingMenuItem)))
(define (nsstackview-enclosing-scroll-view self)
  (wrap-objc-object
   (tell (coerce-arg self) enclosingScrollView)))
(define (nsstackview-first-baseline-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) firstBaselineAnchor)))
(define (nsstackview-first-baseline-offset-from-top self)
  (tell #:type _double (coerce-arg self) firstBaselineOffsetFromTop))
(define (nsstackview-fitting-size self)
  (tell #:type _NSSize (coerce-arg self) fittingSize))
(define (nsstackview-flipped self)
  (tell #:type _bool (coerce-arg self) flipped))
(define (nsstackview-focus-ring-mask-bounds self)
  (tell #:type _NSRect (coerce-arg self) focusRingMaskBounds))
(define (nsstackview-focus-ring-type self)
  (tell #:type _uint64 (coerce-arg self) focusRingType))
(define (nsstackview-set-focus-ring-type! self value)
  (_msg-56 (coerce-arg self) (sel_registerName "setFocusRingType:") value))
(define (nsstackview-focus-view)
  (wrap-objc-object
   (tell NSStackView focusView)))
(define (nsstackview-frame self)
  (tell #:type _NSRect (coerce-arg self) frame))
(define (nsstackview-set-frame! self value)
  (_msg-23 (coerce-arg self) (sel_registerName "setFrame:") value))
(define (nsstackview-frame-center-rotation self)
  (tell #:type _double (coerce-arg self) frameCenterRotation))
(define (nsstackview-set-frame-center-rotation! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setFrameCenterRotation:") value))
(define (nsstackview-frame-rotation self)
  (tell #:type _double (coerce-arg self) frameRotation))
(define (nsstackview-set-frame-rotation! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setFrameRotation:") value))
(define (nsstackview-gesture-recognizers self)
  (wrap-objc-object
   (tell (coerce-arg self) gestureRecognizers)))
(define (nsstackview-set-gesture-recognizers! self value)
  (tell #:type _void (coerce-arg self) setGestureRecognizers: (coerce-arg value)))
(define (nsstackview-has-ambiguous-layout self)
  (tell #:type _bool (coerce-arg self) hasAmbiguousLayout))
(define (nsstackview-has-equal-spacing self)
  (tell #:type _bool (coerce-arg self) hasEqualSpacing))
(define (nsstackview-set-has-equal-spacing! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setHasEqualSpacing:") value))
(define (nsstackview-height-adjust-limit self)
  (tell #:type _double (coerce-arg self) heightAdjustLimit))
(define (nsstackview-height-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) heightAnchor)))
(define (nsstackview-hidden self)
  (tell #:type _bool (coerce-arg self) hidden))
(define (nsstackview-set-hidden! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setHidden:") value))
(define (nsstackview-hidden-or-has-hidden-ancestor self)
  (tell #:type _bool (coerce-arg self) hiddenOrHasHiddenAncestor))
(define (nsstackview-horizontal-content-size-constraint-active self)
  (tell #:type _bool (coerce-arg self) horizontalContentSizeConstraintActive))
(define (nsstackview-set-horizontal-content-size-constraint-active! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setHorizontalContentSizeConstraintActive:") value))
(define (nsstackview-in-full-screen-mode self)
  (tell #:type _bool (coerce-arg self) inFullScreenMode))
(define (nsstackview-in-live-resize self)
  (tell #:type _bool (coerce-arg self) inLiveResize))
(define (nsstackview-input-context self)
  (wrap-objc-object
   (tell (coerce-arg self) inputContext)))
(define (nsstackview-intrinsic-content-size self)
  (tell #:type _NSSize (coerce-arg self) intrinsicContentSize))
(define (nsstackview-last-baseline-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) lastBaselineAnchor)))
(define (nsstackview-last-baseline-offset-from-bottom self)
  (tell #:type _double (coerce-arg self) lastBaselineOffsetFromBottom))
(define (nsstackview-layer self)
  (wrap-objc-object
   (tell (coerce-arg self) layer)))
(define (nsstackview-set-layer! self value)
  (tell #:type _void (coerce-arg self) setLayer: (coerce-arg value)))
(define (nsstackview-layer-contents-placement self)
  (tell #:type _int64 (coerce-arg self) layerContentsPlacement))
(define (nsstackview-set-layer-contents-placement! self value)
  (_msg-49 (coerce-arg self) (sel_registerName "setLayerContentsPlacement:") value))
(define (nsstackview-layer-contents-redraw-policy self)
  (tell #:type _int64 (coerce-arg self) layerContentsRedrawPolicy))
(define (nsstackview-set-layer-contents-redraw-policy! self value)
  (_msg-49 (coerce-arg self) (sel_registerName "setLayerContentsRedrawPolicy:") value))
(define (nsstackview-layer-uses-core-image-filters self)
  (tell #:type _bool (coerce-arg self) layerUsesCoreImageFilters))
(define (nsstackview-set-layer-uses-core-image-filters! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setLayerUsesCoreImageFilters:") value))
(define (nsstackview-layout-guides self)
  (wrap-objc-object
   (tell (coerce-arg self) layoutGuides)))
(define (nsstackview-layout-margins-guide self)
  (wrap-objc-object
   (tell (coerce-arg self) layoutMarginsGuide)))
(define (nsstackview-leading-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) leadingAnchor)))
(define (nsstackview-left-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) leftAnchor)))
(define (nsstackview-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) menu)))
(define (nsstackview-set-menu! self value)
  (tell #:type _void (coerce-arg self) setMenu: (coerce-arg value)))
(define (nsstackview-mouse-down-can-move-window self)
  (tell #:type _bool (coerce-arg self) mouseDownCanMoveWindow))
(define (nsstackview-needs-display self)
  (tell #:type _bool (coerce-arg self) needsDisplay))
(define (nsstackview-set-needs-display! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setNeedsDisplay:") value))
(define (nsstackview-needs-layout self)
  (tell #:type _bool (coerce-arg self) needsLayout))
(define (nsstackview-set-needs-layout! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setNeedsLayout:") value))
(define (nsstackview-needs-panel-to-become-key self)
  (tell #:type _bool (coerce-arg self) needsPanelToBecomeKey))
(define (nsstackview-needs-update-constraints self)
  (tell #:type _bool (coerce-arg self) needsUpdateConstraints))
(define (nsstackview-set-needs-update-constraints! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setNeedsUpdateConstraints:") value))
(define (nsstackview-next-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) nextKeyView)))
(define (nsstackview-set-next-key-view! self value)
  (tell #:type _void (coerce-arg self) setNextKeyView: (coerce-arg value)))
(define (nsstackview-next-responder self)
  (wrap-objc-object
   (tell (coerce-arg self) nextResponder)))
(define (nsstackview-set-next-responder! self value)
  (tell #:type _void (coerce-arg self) setNextResponder: (coerce-arg value)))
(define (nsstackview-next-valid-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) nextValidKeyView)))
(define (nsstackview-opaque self)
  (tell #:type _bool (coerce-arg self) opaque))
(define (nsstackview-opaque-ancestor self)
  (wrap-objc-object
   (tell (coerce-arg self) opaqueAncestor)))
(define (nsstackview-orientation self)
  (tell #:type _int64 (coerce-arg self) orientation))
(define (nsstackview-set-orientation! self value)
  (_msg-49 (coerce-arg self) (sel_registerName "setOrientation:") value))
(define (nsstackview-page-footer self)
  (wrap-objc-object
   (tell (coerce-arg self) pageFooter)))
(define (nsstackview-page-header self)
  (wrap-objc-object
   (tell (coerce-arg self) pageHeader)))
(define (nsstackview-posts-bounds-changed-notifications self)
  (tell #:type _bool (coerce-arg self) postsBoundsChangedNotifications))
(define (nsstackview-set-posts-bounds-changed-notifications! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setPostsBoundsChangedNotifications:") value))
(define (nsstackview-posts-frame-changed-notifications self)
  (tell #:type _bool (coerce-arg self) postsFrameChangedNotifications))
(define (nsstackview-set-posts-frame-changed-notifications! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setPostsFrameChangedNotifications:") value))
(define (nsstackview-prefers-compact-control-size-metrics self)
  (tell #:type _bool (coerce-arg self) prefersCompactControlSizeMetrics))
(define (nsstackview-set-prefers-compact-control-size-metrics! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setPrefersCompactControlSizeMetrics:") value))
(define (nsstackview-prepared-content-rect self)
  (tell #:type _NSRect (coerce-arg self) preparedContentRect))
(define (nsstackview-set-prepared-content-rect! self value)
  (_msg-23 (coerce-arg self) (sel_registerName "setPreparedContentRect:") value))
(define (nsstackview-preserves-content-during-live-resize self)
  (tell #:type _bool (coerce-arg self) preservesContentDuringLiveResize))
(define (nsstackview-pressure-configuration self)
  (wrap-objc-object
   (tell (coerce-arg self) pressureConfiguration)))
(define (nsstackview-set-pressure-configuration! self value)
  (tell #:type _void (coerce-arg self) setPressureConfiguration: (coerce-arg value)))
(define (nsstackview-previous-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) previousKeyView)))
(define (nsstackview-previous-valid-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) previousValidKeyView)))
(define (nsstackview-print-job-title self)
  (wrap-objc-object
   (tell (coerce-arg self) printJobTitle)))
(define (nsstackview-rect-preserved-during-live-resize self)
  (tell #:type _NSRect (coerce-arg self) rectPreservedDuringLiveResize))
(define (nsstackview-registered-dragged-types self)
  (wrap-objc-object
   (tell (coerce-arg self) registeredDraggedTypes)))
(define (nsstackview-requires-constraint-based-layout)
  (tell #:type _bool NSStackView requiresConstraintBasedLayout))
(define (nsstackview-restorable-state-key-paths)
  (wrap-objc-object
   (tell NSStackView restorableStateKeyPaths)))
(define (nsstackview-right-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) rightAnchor)))
(define (nsstackview-rotated-from-base self)
  (tell #:type _bool (coerce-arg self) rotatedFromBase))
(define (nsstackview-rotated-or-scaled-from-base self)
  (tell #:type _bool (coerce-arg self) rotatedOrScaledFromBase))
(define (nsstackview-safe-area-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) safeAreaInsets))
(define (nsstackview-safe-area-layout-guide self)
  (wrap-objc-object
   (tell (coerce-arg self) safeAreaLayoutGuide)))
(define (nsstackview-safe-area-rect self)
  (tell #:type _NSRect (coerce-arg self) safeAreaRect))
(define (nsstackview-shadow self)
  (wrap-objc-object
   (tell (coerce-arg self) shadow)))
(define (nsstackview-set-shadow! self value)
  (tell #:type _void (coerce-arg self) setShadow: (coerce-arg value)))
(define (nsstackview-spacing self)
  (tell #:type _double (coerce-arg self) spacing))
(define (nsstackview-set-spacing! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setSpacing:") value))
(define (nsstackview-subviews self)
  (wrap-objc-object
   (tell (coerce-arg self) subviews)))
(define (nsstackview-set-subviews! self value)
  (tell #:type _void (coerce-arg self) setSubviews: (coerce-arg value)))
(define (nsstackview-superview self)
  (wrap-objc-object
   (tell (coerce-arg self) superview)))
(define (nsstackview-tag self)
  (tell #:type _int64 (coerce-arg self) tag))
(define (nsstackview-tool-tip self)
  (wrap-objc-object
   (tell (coerce-arg self) toolTip)))
(define (nsstackview-set-tool-tip! self value)
  (tell #:type _void (coerce-arg self) setToolTip: (coerce-arg value)))
(define (nsstackview-top-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) topAnchor)))
(define (nsstackview-touch-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) touchBar)))
(define (nsstackview-set-touch-bar! self value)
  (tell #:type _void (coerce-arg self) setTouchBar: (coerce-arg value)))
(define (nsstackview-tracking-areas self)
  (wrap-objc-object
   (tell (coerce-arg self) trackingAreas)))
(define (nsstackview-trailing-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) trailingAnchor)))
(define (nsstackview-translates-autoresizing-mask-into-constraints self)
  (tell #:type _bool (coerce-arg self) translatesAutoresizingMaskIntoConstraints))
(define (nsstackview-set-translates-autoresizing-mask-into-constraints! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setTranslatesAutoresizingMaskIntoConstraints:") value))
(define (nsstackview-undo-manager self)
  (wrap-objc-object
   (tell (coerce-arg self) undoManager)))
(define (nsstackview-user-activity self)
  (wrap-objc-object
   (tell (coerce-arg self) userActivity)))
(define (nsstackview-set-user-activity! self value)
  (tell #:type _void (coerce-arg self) setUserActivity: (coerce-arg value)))
(define (nsstackview-user-interface-layout-direction self)
  (tell #:type _int64 (coerce-arg self) userInterfaceLayoutDirection))
(define (nsstackview-set-user-interface-layout-direction! self value)
  (_msg-49 (coerce-arg self) (sel_registerName "setUserInterfaceLayoutDirection:") value))
(define (nsstackview-vertical-content-size-constraint-active self)
  (tell #:type _bool (coerce-arg self) verticalContentSizeConstraintActive))
(define (nsstackview-set-vertical-content-size-constraint-active! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setVerticalContentSizeConstraintActive:") value))
(define (nsstackview-views self)
  (wrap-objc-object
   (tell (coerce-arg self) views)))
(define (nsstackview-visible-rect self)
  (tell #:type _NSRect (coerce-arg self) visibleRect))
(define (nsstackview-wants-best-resolution-open-gl-surface self)
  (tell #:type _bool (coerce-arg self) wantsBestResolutionOpenGLSurface))
(define (nsstackview-set-wants-best-resolution-open-gl-surface! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setWantsBestResolutionOpenGLSurface:") value))
(define (nsstackview-wants-default-clipping self)
  (tell #:type _bool (coerce-arg self) wantsDefaultClipping))
(define (nsstackview-wants-extended-dynamic-range-open-gl-surface self)
  (tell #:type _bool (coerce-arg self) wantsExtendedDynamicRangeOpenGLSurface))
(define (nsstackview-set-wants-extended-dynamic-range-open-gl-surface! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setWantsExtendedDynamicRangeOpenGLSurface:") value))
(define (nsstackview-wants-layer self)
  (tell #:type _bool (coerce-arg self) wantsLayer))
(define (nsstackview-set-wants-layer! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setWantsLayer:") value))
(define (nsstackview-wants-resting-touches self)
  (tell #:type _bool (coerce-arg self) wantsRestingTouches))
(define (nsstackview-set-wants-resting-touches! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setWantsRestingTouches:") value))
(define (nsstackview-wants-update-layer self)
  (tell #:type _bool (coerce-arg self) wantsUpdateLayer))
(define (nsstackview-width-adjust-limit self)
  (tell #:type _double (coerce-arg self) widthAdjustLimit))
(define (nsstackview-width-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) widthAnchor)))
(define (nsstackview-window self)
  (wrap-objc-object
   (tell (coerce-arg self) window)))
(define (nsstackview-writing-tools-coordinator self)
  (wrap-objc-object
   (tell (coerce-arg self) writingToolsCoordinator)))
(define (nsstackview-set-writing-tools-coordinator! self value)
  (tell #:type _void (coerce-arg self) setWritingToolsCoordinator: (coerce-arg value)))

;; --- Instance methods ---
(define (nsstackview-accepts-first-mouse self event)
  (_msg-38 (coerce-arg self) (sel_registerName "acceptsFirstMouse:") (coerce-arg event)))
(define (nsstackview-accessibility-activation-point self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityActivationPoint")))
(define (nsstackview-accessibility-allowed-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAllowedValues)))
(define (nsstackview-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityApplicationFocusedUIElement)))
(define (nsstackview-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (_msg-18 (coerce-arg self) (sel_registerName "accessibilityAttributedStringForRange:") range)
   ))
(define (nsstackview-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAttributedUserInputLabels)))
(define (nsstackview-accessibility-cancel-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCancelButton)))
(define (nsstackview-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (_msg-50 (coerce-arg self) (sel_registerName "accessibilityCellForColumn:row:") column row)
   ))
(define (nsstackview-accessibility-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildren)))
(define (nsstackview-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildrenInNavigationOrder)))
(define (nsstackview-accessibility-clear-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityClearButton)))
(define (nsstackview-accessibility-close-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCloseButton)))
(define (nsstackview-accessibility-column-count self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityColumnCount")))
(define (nsstackview-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnHeaderUIElements)))
(define (nsstackview-accessibility-column-index-range self)
  (_msg-2 (coerce-arg self) (sel_registerName "accessibilityColumnIndexRange")))
(define (nsstackview-accessibility-column-titles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnTitles)))
(define (nsstackview-accessibility-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumns)))
(define (nsstackview-accessibility-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityContents)))
(define (nsstackview-accessibility-critical-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCriticalValue)))
(define (nsstackview-accessibility-custom-actions self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomActions)))
(define (nsstackview-accessibility-custom-rotors self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomRotors)))
(define (nsstackview-accessibility-decrement-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDecrementButton)))
(define (nsstackview-accessibility-default-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDefaultButton)))
(define (nsstackview-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedByRow)))
(define (nsstackview-accessibility-disclosed-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedRows)))
(define (nsstackview-accessibility-disclosure-level self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityDisclosureLevel")))
(define (nsstackview-accessibility-document self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDocument)))
(define (nsstackview-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityExtrasMenuBar)))
(define (nsstackview-accessibility-filename self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFilename)))
(define (nsstackview-accessibility-focused-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFocusedWindow)))
(define (nsstackview-accessibility-frame self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityFrame")))
(define (nsstackview-accessibility-frame-for-range self range)
  (_msg-17 (coerce-arg self) (sel_registerName "accessibilityFrameForRange:") range))
(define (nsstackview-accessibility-full-screen-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFullScreenButton)))
(define (nsstackview-accessibility-grow-area self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityGrowArea)))
(define (nsstackview-accessibility-handles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHandles)))
(define (nsstackview-accessibility-header self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHeader)))
(define (nsstackview-accessibility-help self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHelp)))
(define (nsstackview-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalScrollBar)))
(define (nsstackview-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalUnitDescription)))
(define (nsstackview-accessibility-horizontal-units self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityHorizontalUnits")))
(define (nsstackview-accessibility-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIdentifier)))
(define (nsstackview-accessibility-increment-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIncrementButton)))
(define (nsstackview-accessibility-index self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityIndex")))
(define (nsstackview-accessibility-insertion-point-line-number self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityInsertionPointLineNumber")))
(define (nsstackview-accessibility-label self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabel)))
(define (nsstackview-accessibility-label-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabelUIElements)))
(define (nsstackview-accessibility-label-value self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityLabelValue")))
(define (nsstackview-accessibility-layout-point-for-screen-point self point)
  (_msg-10 (coerce-arg self) (sel_registerName "accessibilityLayoutPointForScreenPoint:") point))
(define (nsstackview-accessibility-layout-size-for-screen-size self size)
  (_msg-29 (coerce-arg self) (sel_registerName "accessibilityLayoutSizeForScreenSize:") size))
(define (nsstackview-accessibility-line-for-index self index)
  (_msg-48 (coerce-arg self) (sel_registerName "accessibilityLineForIndex:") index))
(define (nsstackview-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLinkedUIElements)))
(define (nsstackview-accessibility-main-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMainWindow)))
(define (nsstackview-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerGroupUIElement)))
(define (nsstackview-accessibility-marker-type-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerTypeDescription)))
(define (nsstackview-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerUIElements)))
(define (nsstackview-accessibility-marker-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerValues)))
(define (nsstackview-accessibility-max-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMaxValue)))
(define (nsstackview-accessibility-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMenuBar)))
(define (nsstackview-accessibility-min-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinValue)))
(define (nsstackview-accessibility-minimize-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinimizeButton)))
(define (nsstackview-accessibility-next-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityNextContents)))
(define (nsstackview-accessibility-number-of-characters self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityNumberOfCharacters")))
(define (nsstackview-accessibility-orientation self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityOrientation")))
(define (nsstackview-accessibility-overflow-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityOverflowButton)))
(define (nsstackview-accessibility-parent self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityParent)))
(define (nsstackview-accessibility-perform-cancel self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformCancel")))
(define (nsstackview-accessibility-perform-confirm self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformConfirm")))
(define (nsstackview-accessibility-perform-decrement self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformDecrement")))
(define (nsstackview-accessibility-perform-delete self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformDelete")))
(define (nsstackview-accessibility-perform-increment self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformIncrement")))
(define (nsstackview-accessibility-perform-pick self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformPick")))
(define (nsstackview-accessibility-perform-press self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformPress")))
(define (nsstackview-accessibility-perform-raise self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformRaise")))
(define (nsstackview-accessibility-perform-show-alternate-ui self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformShowAlternateUI")))
(define (nsstackview-accessibility-perform-show-default-ui self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformShowDefaultUI")))
(define (nsstackview-accessibility-perform-show-menu self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformShowMenu")))
(define (nsstackview-accessibility-placeholder-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPlaceholderValue)))
(define (nsstackview-accessibility-previous-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPreviousContents)))
(define (nsstackview-accessibility-proxy self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityProxy)))
(define (nsstackview-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (_msg-18 (coerce-arg self) (sel_registerName "accessibilityRTFForRange:") range)
   ))
(define (nsstackview-accessibility-range-for-index self index)
  (_msg-44 (coerce-arg self) (sel_registerName "accessibilityRangeForIndex:") index))
(define (nsstackview-accessibility-range-for-line self line)
  (_msg-44 (coerce-arg self) (sel_registerName "accessibilityRangeForLine:") line))
(define (nsstackview-accessibility-range-for-position self point)
  (_msg-11 (coerce-arg self) (sel_registerName "accessibilityRangeForPosition:") point))
(define (nsstackview-accessibility-role self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRole)))
(define (nsstackview-accessibility-role-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRoleDescription)))
(define (nsstackview-accessibility-row-count self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityRowCount")))
(define (nsstackview-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRowHeaderUIElements)))
(define (nsstackview-accessibility-row-index-range self)
  (_msg-2 (coerce-arg self) (sel_registerName "accessibilityRowIndexRange")))
(define (nsstackview-accessibility-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRows)))
(define (nsstackview-accessibility-ruler-marker-type self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityRulerMarkerType")))
(define (nsstackview-accessibility-screen-point-for-layout-point self point)
  (_msg-10 (coerce-arg self) (sel_registerName "accessibilityScreenPointForLayoutPoint:") point))
(define (nsstackview-accessibility-screen-size-for-layout-size self size)
  (_msg-29 (coerce-arg self) (sel_registerName "accessibilityScreenSizeForLayoutSize:") size))
(define (nsstackview-accessibility-search-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchButton)))
(define (nsstackview-accessibility-search-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchMenu)))
(define (nsstackview-accessibility-selected-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedCells)))
(define (nsstackview-accessibility-selected-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedChildren)))
(define (nsstackview-accessibility-selected-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedColumns)))
(define (nsstackview-accessibility-selected-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedRows)))
(define (nsstackview-accessibility-selected-text self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedText)))
(define (nsstackview-accessibility-selected-text-range self)
  (_msg-2 (coerce-arg self) (sel_registerName "accessibilitySelectedTextRange")))
(define (nsstackview-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedTextRanges)))
(define (nsstackview-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityServesAsTitleForUIElements)))
(define (nsstackview-accessibility-shared-character-range self)
  (_msg-2 (coerce-arg self) (sel_registerName "accessibilitySharedCharacterRange")))
(define (nsstackview-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedFocusElements)))
(define (nsstackview-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedTextUIElements)))
(define (nsstackview-accessibility-shown-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityShownMenu)))
(define (nsstackview-accessibility-sort-direction self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilitySortDirection")))
(define (nsstackview-accessibility-splitters self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySplitters)))
(define (nsstackview-accessibility-string-for-range self range)
  (wrap-objc-object
   (_msg-18 (coerce-arg self) (sel_registerName "accessibilityStringForRange:") range)
   ))
(define (nsstackview-accessibility-style-range-for-index self index)
  (_msg-44 (coerce-arg self) (sel_registerName "accessibilityStyleRangeForIndex:") index))
(define (nsstackview-accessibility-subrole self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySubrole)))
(define (nsstackview-accessibility-tabs self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTabs)))
(define (nsstackview-accessibility-title self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitle)))
(define (nsstackview-accessibility-title-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitleUIElement)))
(define (nsstackview-accessibility-toolbar-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityToolbarButton)))
(define (nsstackview-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTopLevelUIElement)))
(define (nsstackview-accessibility-url self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityURL)))
(define (nsstackview-accessibility-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUnitDescription)))
(define (nsstackview-accessibility-units self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityUnits")))
(define (nsstackview-accessibility-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUserInputLabels)))
(define (nsstackview-accessibility-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValue)))
(define (nsstackview-accessibility-value-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValueDescription)))
(define (nsstackview-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalScrollBar)))
(define (nsstackview-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalUnitDescription)))
(define (nsstackview-accessibility-vertical-units self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityVerticalUnits")))
(define (nsstackview-accessibility-visible-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleCells)))
(define (nsstackview-accessibility-visible-character-range self)
  (_msg-2 (coerce-arg self) (sel_registerName "accessibilityVisibleCharacterRange")))
(define (nsstackview-accessibility-visible-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleChildren)))
(define (nsstackview-accessibility-visible-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleColumns)))
(define (nsstackview-accessibility-visible-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleRows)))
(define (nsstackview-accessibility-warning-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWarningValue)))
(define (nsstackview-accessibility-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindow)))
(define (nsstackview-accessibility-windows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindows)))
(define (nsstackview-accessibility-zoom-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityZoomButton)))
(define (nsstackview-add-arranged-subview! self view)
  (tell #:type _void (coerce-arg self) addArrangedSubview: (coerce-arg view)))
(define (nsstackview-add-subview! self view)
  (tell #:type _void (coerce-arg self) addSubview: (coerce-arg view)))
(define (nsstackview-add-subview-positioned-relative-to! self view place other-view)
  (_msg-43 (coerce-arg self) (sel_registerName "addSubview:positioned:relativeTo:") (coerce-arg view) place (coerce-arg other-view)))
(define (nsstackview-add-tool-tip-rect-owner-user-data! self rect owner data)
  (_msg-27 (coerce-arg self) (sel_registerName "addToolTipRect:owner:userData:") rect (coerce-arg owner) data))
(define (nsstackview-adjust-scroll self new-visible)
  (_msg-20 (coerce-arg self) (sel_registerName "adjustScroll:") new-visible))
(define (nsstackview-ancestor-shared-with-view self view)
  (wrap-objc-object
   (tell (coerce-arg self) ancestorSharedWithView: (coerce-arg view))))
(define (nsstackview-animation-for-key self key)
  (wrap-objc-object
   (tell (coerce-arg self) animationForKey: (coerce-arg key))))
(define (nsstackview-animations self)
  (wrap-objc-object
   (tell (coerce-arg self) animations)))
(define (nsstackview-animator self)
  (wrap-objc-object
   (tell (coerce-arg self) animator)))
(define (nsstackview-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) appearance)))
(define (nsstackview-autoscroll self event)
  (_msg-38 (coerce-arg self) (sel_registerName "autoscroll:") (coerce-arg event)))
(define (nsstackview-backing-aligned-rect-options self rect options)
  (_msg-28 (coerce-arg self) (sel_registerName "backingAlignedRect:options:") rect options))
(define (nsstackview-become-first-responder self)
  (_msg-4 (coerce-arg self) (sel_registerName "becomeFirstResponder")))
(define (nsstackview-begin-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) beginGestureWithEvent: (coerce-arg event)))
(define (nsstackview-bitmap-image-rep-for-caching-display-in-rect self rect)
  (wrap-objc-object
   (_msg-22 (coerce-arg self) (sel_registerName "bitmapImageRepForCachingDisplayInRect:") rect)
   ))
(define (nsstackview-cache-display-in-rect-to-bitmap-image-rep self rect bitmap-image-rep)
  (_msg-26 (coerce-arg self) (sel_registerName "cacheDisplayInRect:toBitmapImageRep:") rect (coerce-arg bitmap-image-rep)))
(define (nsstackview-cancel-operation self sender)
  (tell #:type _void (coerce-arg self) cancelOperation: (coerce-arg sender)))
(define (nsstackview-capitalize-word self sender)
  (tell #:type _void (coerce-arg self) capitalizeWord: (coerce-arg sender)))
(define (nsstackview-center-scan-rect! self rect)
  (_msg-20 (coerce-arg self) (sel_registerName "centerScanRect:") rect))
(define (nsstackview-center-selection-in-visible-area! self sender)
  (tell #:type _void (coerce-arg self) centerSelectionInVisibleArea: (coerce-arg sender)))
(define (nsstackview-change-case-of-letter self sender)
  (tell #:type _void (coerce-arg self) changeCaseOfLetter: (coerce-arg sender)))
(define (nsstackview-change-mode-with-event self event)
  (tell #:type _void (coerce-arg self) changeModeWithEvent: (coerce-arg event)))
(define (nsstackview-clipping-resistance-priority-for-orientation self orientation)
  (_msg-46 (coerce-arg self) (sel_registerName "clippingResistancePriorityForOrientation:") orientation))
(define (nsstackview-complete self sender)
  (tell #:type _void (coerce-arg self) complete: (coerce-arg sender)))
(define (nsstackview-conclude-drag-operation self sender)
  (tell #:type _void (coerce-arg self) concludeDragOperation: (coerce-arg sender)))
(define (nsstackview-context-menu-key-down self event)
  (tell #:type _void (coerce-arg self) contextMenuKeyDown: (coerce-arg event)))
(define (nsstackview-convert-point-from-view self point view)
  (_msg-16 (coerce-arg self) (sel_registerName "convertPoint:fromView:") point (coerce-arg view)))
(define (nsstackview-convert-point-to-view self point view)
  (_msg-16 (coerce-arg self) (sel_registerName "convertPoint:toView:") point (coerce-arg view)))
(define (nsstackview-convert-point-from-backing self point)
  (_msg-10 (coerce-arg self) (sel_registerName "convertPointFromBacking:") point))
(define (nsstackview-convert-point-from-layer self point)
  (_msg-10 (coerce-arg self) (sel_registerName "convertPointFromLayer:") point))
(define (nsstackview-convert-point-to-backing self point)
  (_msg-10 (coerce-arg self) (sel_registerName "convertPointToBacking:") point))
(define (nsstackview-convert-point-to-layer self point)
  (_msg-10 (coerce-arg self) (sel_registerName "convertPointToLayer:") point))
(define (nsstackview-convert-rect-from-view self rect view)
  (_msg-25 (coerce-arg self) (sel_registerName "convertRect:fromView:") rect (coerce-arg view)))
(define (nsstackview-convert-rect-to-view self rect view)
  (_msg-25 (coerce-arg self) (sel_registerName "convertRect:toView:") rect (coerce-arg view)))
(define (nsstackview-convert-rect-from-backing self rect)
  (_msg-20 (coerce-arg self) (sel_registerName "convertRectFromBacking:") rect))
(define (nsstackview-convert-rect-from-layer self rect)
  (_msg-20 (coerce-arg self) (sel_registerName "convertRectFromLayer:") rect))
(define (nsstackview-convert-rect-to-backing self rect)
  (_msg-20 (coerce-arg self) (sel_registerName "convertRectToBacking:") rect))
(define (nsstackview-convert-rect-to-layer self rect)
  (_msg-20 (coerce-arg self) (sel_registerName "convertRectToLayer:") rect))
(define (nsstackview-convert-size-from-view self size view)
  (_msg-31 (coerce-arg self) (sel_registerName "convertSize:fromView:") size (coerce-arg view)))
(define (nsstackview-convert-size-to-view self size view)
  (_msg-31 (coerce-arg self) (sel_registerName "convertSize:toView:") size (coerce-arg view)))
(define (nsstackview-convert-size-from-backing self size)
  (_msg-29 (coerce-arg self) (sel_registerName "convertSizeFromBacking:") size))
(define (nsstackview-convert-size-from-layer self size)
  (_msg-29 (coerce-arg self) (sel_registerName "convertSizeFromLayer:") size))
(define (nsstackview-convert-size-to-backing self size)
  (_msg-29 (coerce-arg self) (sel_registerName "convertSizeToBacking:") size))
(define (nsstackview-convert-size-to-layer self size)
  (_msg-29 (coerce-arg self) (sel_registerName "convertSizeToLayer:") size))
(define (nsstackview-cursor-update self event)
  (tell #:type _void (coerce-arg self) cursorUpdate: (coerce-arg event)))
(define (nsstackview-custom-spacing-after-view self view)
  (_msg-39 (coerce-arg self) (sel_registerName "customSpacingAfterView:") (coerce-arg view)))
(define (nsstackview-delete-backward self sender)
  (tell #:type _void (coerce-arg self) deleteBackward: (coerce-arg sender)))
(define (nsstackview-delete-backward-by-decomposing-previous-character self sender)
  (tell #:type _void (coerce-arg self) deleteBackwardByDecomposingPreviousCharacter: (coerce-arg sender)))
(define (nsstackview-delete-forward self sender)
  (tell #:type _void (coerce-arg self) deleteForward: (coerce-arg sender)))
(define (nsstackview-delete-to-beginning-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfLine: (coerce-arg sender)))
(define (nsstackview-delete-to-beginning-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfParagraph: (coerce-arg sender)))
(define (nsstackview-delete-to-end-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfLine: (coerce-arg sender)))
(define (nsstackview-delete-to-end-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfParagraph: (coerce-arg sender)))
(define (nsstackview-delete-to-mark self sender)
  (tell #:type _void (coerce-arg self) deleteToMark: (coerce-arg sender)))
(define (nsstackview-delete-word-backward self sender)
  (tell #:type _void (coerce-arg self) deleteWordBackward: (coerce-arg sender)))
(define (nsstackview-delete-word-forward self sender)
  (tell #:type _void (coerce-arg self) deleteWordForward: (coerce-arg sender)))
(define (nsstackview-did-add-subview self subview)
  (tell #:type _void (coerce-arg self) didAddSubview: (coerce-arg subview)))
(define (nsstackview-did-close-menu-with-event self menu event)
  (tell #:type _void (coerce-arg self) didCloseMenu: (coerce-arg menu) withEvent: (coerce-arg event)))
(define (nsstackview-display! self)
  (tell #:type _void (coerce-arg self) display))
(define (nsstackview-display-if-needed! self)
  (tell #:type _void (coerce-arg self) displayIfNeeded))
(define (nsstackview-display-if-needed-ignoring-opacity! self)
  (tell #:type _void (coerce-arg self) displayIfNeededIgnoringOpacity))
(define (nsstackview-display-if-needed-in-rect! self rect)
  (_msg-23 (coerce-arg self) (sel_registerName "displayIfNeededInRect:") rect))
(define (nsstackview-display-if-needed-in-rect-ignoring-opacity! self rect)
  (_msg-23 (coerce-arg self) (sel_registerName "displayIfNeededInRectIgnoringOpacity:") rect))
(define (nsstackview-display-rect! self rect)
  (_msg-23 (coerce-arg self) (sel_registerName "displayRect:") rect))
(define (nsstackview-display-rect-ignoring-opacity! self rect)
  (_msg-23 (coerce-arg self) (sel_registerName "displayRectIgnoringOpacity:") rect))
(define (nsstackview-display-rect-ignoring-opacity-in-context! self rect context)
  (_msg-26 (coerce-arg self) (sel_registerName "displayRectIgnoringOpacity:inContext:") rect (coerce-arg context)))
(define (nsstackview-do-command-by-selector self selector)
  (_msg-52 (coerce-arg self) (sel_registerName "doCommandBySelector:") (sel_registerName selector)))
(define (nsstackview-dragging-ended self sender)
  (tell #:type _void (coerce-arg self) draggingEnded: (coerce-arg sender)))
(define (nsstackview-dragging-entered self sender)
  (_msg-41 (coerce-arg self) (sel_registerName "draggingEntered:") (coerce-arg sender)))
(define (nsstackview-dragging-exited self sender)
  (tell #:type _void (coerce-arg self) draggingExited: (coerce-arg sender)))
(define (nsstackview-dragging-updated self sender)
  (_msg-41 (coerce-arg self) (sel_registerName "draggingUpdated:") (coerce-arg sender)))
(define (nsstackview-draw-rect self dirty-rect)
  (_msg-23 (coerce-arg self) (sel_registerName "drawRect:") dirty-rect))
(define (nsstackview-effective-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) effectiveAppearance)))
(define (nsstackview-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nsstackview-end-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) endGestureWithEvent: (coerce-arg event)))
(define (nsstackview-flags-changed self event)
  (tell #:type _void (coerce-arg self) flagsChanged: (coerce-arg event)))
(define (nsstackview-flush-buffered-key-events self)
  (tell #:type _void (coerce-arg self) flushBufferedKeyEvents))
(define (nsstackview-get-rects-being-drawn-count self rects count)
  (_msg-55 (coerce-arg self) (sel_registerName "getRectsBeingDrawn:count:") rects count))
(define (nsstackview-get-rects-exposed-during-live-resize-count self exposed-rects count)
  (_msg-55 (coerce-arg self) (sel_registerName "getRectsExposedDuringLiveResize:count:") exposed-rects count))
(define (nsstackview-help-requested self event-ptr)
  (tell #:type _void (coerce-arg self) helpRequested: (coerce-arg event-ptr)))
(define (nsstackview-hit-test self point)
  (wrap-objc-object
   (_msg-12 (coerce-arg self) (sel_registerName "hitTest:") point)
   ))
(define (nsstackview-hugging-priority-for-orientation self orientation)
  (_msg-46 (coerce-arg self) (sel_registerName "huggingPriorityForOrientation:") orientation))
(define (nsstackview-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) identifier)))
(define (nsstackview-indent self sender)
  (tell #:type _void (coerce-arg self) indent: (coerce-arg sender)))
(define (nsstackview-insert-arranged-subview-at-index! self view index)
  (_msg-42 (coerce-arg self) (sel_registerName "insertArrangedSubview:atIndex:") (coerce-arg view) index))
(define (nsstackview-insert-backtab! self sender)
  (tell #:type _void (coerce-arg self) insertBacktab: (coerce-arg sender)))
(define (nsstackview-insert-container-break! self sender)
  (tell #:type _void (coerce-arg self) insertContainerBreak: (coerce-arg sender)))
(define (nsstackview-insert-double-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertDoubleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nsstackview-insert-line-break! self sender)
  (tell #:type _void (coerce-arg self) insertLineBreak: (coerce-arg sender)))
(define (nsstackview-insert-newline! self sender)
  (tell #:type _void (coerce-arg self) insertNewline: (coerce-arg sender)))
(define (nsstackview-insert-newline-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertNewlineIgnoringFieldEditor: (coerce-arg sender)))
(define (nsstackview-insert-paragraph-separator! self sender)
  (tell #:type _void (coerce-arg self) insertParagraphSeparator: (coerce-arg sender)))
(define (nsstackview-insert-single-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertSingleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nsstackview-insert-tab! self sender)
  (tell #:type _void (coerce-arg self) insertTab: (coerce-arg sender)))
(define (nsstackview-insert-tab-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertTabIgnoringFieldEditor: (coerce-arg sender)))
(define (nsstackview-insert-text! self insert-string)
  (tell #:type _void (coerce-arg self) insertText: (coerce-arg insert-string)))
(define (nsstackview-interpret-key-events self event-array)
  (tell #:type _void (coerce-arg self) interpretKeyEvents: (coerce-arg event-array)))
(define (nsstackview-is-accessibility-alternate-ui-visible self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityAlternateUIVisible")))
(define (nsstackview-is-accessibility-disclosed self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityDisclosed")))
(define (nsstackview-is-accessibility-edited self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityEdited")))
(define (nsstackview-is-accessibility-element self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityElement")))
(define (nsstackview-is-accessibility-enabled self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityEnabled")))
(define (nsstackview-is-accessibility-expanded self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityExpanded")))
(define (nsstackview-is-accessibility-focused self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityFocused")))
(define (nsstackview-is-accessibility-frontmost self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityFrontmost")))
(define (nsstackview-is-accessibility-hidden self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityHidden")))
(define (nsstackview-is-accessibility-main self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityMain")))
(define (nsstackview-is-accessibility-minimized self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityMinimized")))
(define (nsstackview-is-accessibility-modal self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityModal")))
(define (nsstackview-is-accessibility-ordered-by-row self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityOrderedByRow")))
(define (nsstackview-is-accessibility-protected-content self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityProtectedContent")))
(define (nsstackview-is-accessibility-required self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityRequired")))
(define (nsstackview-is-accessibility-selected self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilitySelected")))
(define (nsstackview-is-accessibility-selector-allowed self selector)
  (_msg-51 (coerce-arg self) (sel_registerName "isAccessibilitySelectorAllowed:") (sel_registerName selector)))
(define (nsstackview-is-descendant-of self view)
  (_msg-38 (coerce-arg self) (sel_registerName "isDescendantOf:") (coerce-arg view)))
(define (nsstackview-is-flipped self)
  (_msg-4 (coerce-arg self) (sel_registerName "isFlipped")))
(define (nsstackview-is-hidden self)
  (_msg-4 (coerce-arg self) (sel_registerName "isHidden")))
(define (nsstackview-is-hidden-or-has-hidden-ancestor self)
  (_msg-4 (coerce-arg self) (sel_registerName "isHiddenOrHasHiddenAncestor")))
(define (nsstackview-is-opaque self)
  (_msg-4 (coerce-arg self) (sel_registerName "isOpaque")))
(define (nsstackview-is-rotated-from-base self)
  (_msg-4 (coerce-arg self) (sel_registerName "isRotatedFromBase")))
(define (nsstackview-is-rotated-or-scaled-from-base self)
  (_msg-4 (coerce-arg self) (sel_registerName "isRotatedOrScaledFromBase")))
(define (nsstackview-key-down self event)
  (tell #:type _void (coerce-arg self) keyDown: (coerce-arg event)))
(define (nsstackview-key-up self event)
  (tell #:type _void (coerce-arg self) keyUp: (coerce-arg event)))
(define (nsstackview-layout self)
  (tell #:type _void (coerce-arg self) layout))
(define (nsstackview-layout-subtree-if-needed self)
  (tell #:type _void (coerce-arg self) layoutSubtreeIfNeeded))
(define (nsstackview-lowercase-word self sender)
  (tell #:type _void (coerce-arg self) lowercaseWord: (coerce-arg sender)))
(define (nsstackview-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) magnifyWithEvent: (coerce-arg event)))
(define (nsstackview-make-backing-layer self)
  (wrap-objc-object
   (tell (coerce-arg self) makeBackingLayer)))
(define (nsstackview-make-base-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nsstackview-make-base-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionNatural: (coerce-arg sender)))
(define (nsstackview-make-base-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nsstackview-make-text-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nsstackview-make-text-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionNatural: (coerce-arg sender)))
(define (nsstackview-make-text-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nsstackview-menu-for-event self event)
  (wrap-objc-object
   (tell (coerce-arg self) menuForEvent: (coerce-arg event))))
(define (nsstackview-mouse-in-rect self point rect)
  (_msg-15 (coerce-arg self) (sel_registerName "mouse:inRect:") point rect))
(define (nsstackview-mouse-cancelled self event)
  (tell #:type _void (coerce-arg self) mouseCancelled: (coerce-arg event)))
(define (nsstackview-mouse-down self event)
  (tell #:type _void (coerce-arg self) mouseDown: (coerce-arg event)))
(define (nsstackview-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) mouseDragged: (coerce-arg event)))
(define (nsstackview-mouse-entered self event)
  (tell #:type _void (coerce-arg self) mouseEntered: (coerce-arg event)))
(define (nsstackview-mouse-exited self event)
  (tell #:type _void (coerce-arg self) mouseExited: (coerce-arg event)))
(define (nsstackview-mouse-moved self event)
  (tell #:type _void (coerce-arg self) mouseMoved: (coerce-arg event)))
(define (nsstackview-mouse-up self event)
  (tell #:type _void (coerce-arg self) mouseUp: (coerce-arg event)))
(define (nsstackview-move-backward! self sender)
  (tell #:type _void (coerce-arg self) moveBackward: (coerce-arg sender)))
(define (nsstackview-move-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveBackwardAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-down! self sender)
  (tell #:type _void (coerce-arg self) moveDown: (coerce-arg sender)))
(define (nsstackview-move-down-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveDownAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-forward! self sender)
  (tell #:type _void (coerce-arg self) moveForward: (coerce-arg sender)))
(define (nsstackview-move-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveForwardAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-left! self sender)
  (tell #:type _void (coerce-arg self) moveLeft: (coerce-arg sender)))
(define (nsstackview-move-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveLeftAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-paragraph-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphBackwardAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-paragraph-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphForwardAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-right! self sender)
  (tell #:type _void (coerce-arg self) moveRight: (coerce-arg sender)))
(define (nsstackview-move-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveRightAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-to-beginning-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocument: (coerce-arg sender)))
(define (nsstackview-move-to-beginning-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-to-beginning-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLine: (coerce-arg sender)))
(define (nsstackview-move-to-beginning-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLineAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-to-beginning-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraph: (coerce-arg sender)))
(define (nsstackview-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-to-end-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocument: (coerce-arg sender)))
(define (nsstackview-move-to-end-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-to-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLine: (coerce-arg sender)))
(define (nsstackview-move-to-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-to-end-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraph: (coerce-arg sender)))
(define (nsstackview-move-to-end-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-to-left-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLine: (coerce-arg sender)))
(define (nsstackview-move-to-left-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-to-right-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLine: (coerce-arg sender)))
(define (nsstackview-move-to-right-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-up! self sender)
  (tell #:type _void (coerce-arg self) moveUp: (coerce-arg sender)))
(define (nsstackview-move-up-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveUpAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-word-backward! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackward: (coerce-arg sender)))
(define (nsstackview-move-word-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackwardAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-word-forward! self sender)
  (tell #:type _void (coerce-arg self) moveWordForward: (coerce-arg sender)))
(define (nsstackview-move-word-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordForwardAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-word-left! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeft: (coerce-arg sender)))
(define (nsstackview-move-word-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeftAndModifySelection: (coerce-arg sender)))
(define (nsstackview-move-word-right! self sender)
  (tell #:type _void (coerce-arg self) moveWordRight: (coerce-arg sender)))
(define (nsstackview-move-word-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordRightAndModifySelection: (coerce-arg sender)))
(define (nsstackview-needs-to-draw-rect self rect)
  (_msg-21 (coerce-arg self) (sel_registerName "needsToDrawRect:") rect))
(define (nsstackview-no-responder-for self event-selector)
  (_msg-52 (coerce-arg self) (sel_registerName "noResponderFor:") (sel_registerName event-selector)))
(define (nsstackview-other-mouse-down self event)
  (tell #:type _void (coerce-arg self) otherMouseDown: (coerce-arg event)))
(define (nsstackview-other-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) otherMouseDragged: (coerce-arg event)))
(define (nsstackview-other-mouse-up self event)
  (tell #:type _void (coerce-arg self) otherMouseUp: (coerce-arg event)))
(define (nsstackview-page-down self sender)
  (tell #:type _void (coerce-arg self) pageDown: (coerce-arg sender)))
(define (nsstackview-page-down-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageDownAndModifySelection: (coerce-arg sender)))
(define (nsstackview-page-up self sender)
  (tell #:type _void (coerce-arg self) pageUp: (coerce-arg sender)))
(define (nsstackview-page-up-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageUpAndModifySelection: (coerce-arg sender)))
(define (nsstackview-perform-drag-operation! self sender)
  (_msg-38 (coerce-arg self) (sel_registerName "performDragOperation:") (coerce-arg sender)))
(define (nsstackview-perform-key-equivalent! self event)
  (_msg-38 (coerce-arg self) (sel_registerName "performKeyEquivalent:") (coerce-arg event)))
(define (nsstackview-prepare-content-in-rect self rect)
  (_msg-23 (coerce-arg self) (sel_registerName "prepareContentInRect:") rect))
(define (nsstackview-prepare-for-drag-operation self sender)
  (_msg-38 (coerce-arg self) (sel_registerName "prepareForDragOperation:") (coerce-arg sender)))
(define (nsstackview-prepare-for-reuse self)
  (tell #:type _void (coerce-arg self) prepareForReuse))
(define (nsstackview-pressure-change-with-event self event)
  (tell #:type _void (coerce-arg self) pressureChangeWithEvent: (coerce-arg event)))
(define (nsstackview-quick-look-preview-items self sender)
  (tell #:type _void (coerce-arg self) quickLookPreviewItems: (coerce-arg sender)))
(define (nsstackview-quick-look-with-event self event)
  (tell #:type _void (coerce-arg self) quickLookWithEvent: (coerce-arg event)))
(define (nsstackview-rect-for-smart-magnification-at-point-in-rect self location visible-rect)
  (_msg-14 (coerce-arg self) (sel_registerName "rectForSmartMagnificationAtPoint:inRect:") location visible-rect))
(define (nsstackview-remove-all-tool-tips! self)
  (tell #:type _void (coerce-arg self) removeAllToolTips))
(define (nsstackview-remove-arranged-subview! self view)
  (tell #:type _void (coerce-arg self) removeArrangedSubview: (coerce-arg view)))
(define (nsstackview-remove-from-superview! self)
  (tell #:type _void (coerce-arg self) removeFromSuperview))
(define (nsstackview-remove-from-superview-without-needing-display! self)
  (tell #:type _void (coerce-arg self) removeFromSuperviewWithoutNeedingDisplay))
(define (nsstackview-remove-tool-tip! self tag)
  (_msg-49 (coerce-arg self) (sel_registerName "removeToolTip:") tag))
(define (nsstackview-replace-subview-with! self old-view new-view)
  (tell #:type _void (coerce-arg self) replaceSubview: (coerce-arg old-view) with: (coerce-arg new-view)))
(define (nsstackview-resign-first-responder self)
  (_msg-4 (coerce-arg self) (sel_registerName "resignFirstResponder")))
(define (nsstackview-resize-subviews-with-old-size self old-size)
  (_msg-30 (coerce-arg self) (sel_registerName "resizeSubviewsWithOldSize:") old-size))
(define (nsstackview-resize-with-old-superview-size self old-size)
  (_msg-30 (coerce-arg self) (sel_registerName "resizeWithOldSuperviewSize:") old-size))
(define (nsstackview-restore-user-activity-state self user-activity)
  (tell #:type _void (coerce-arg self) restoreUserActivityState: (coerce-arg user-activity)))
(define (nsstackview-right-mouse-down self event)
  (tell #:type _void (coerce-arg self) rightMouseDown: (coerce-arg event)))
(define (nsstackview-right-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) rightMouseDragged: (coerce-arg event)))
(define (nsstackview-right-mouse-up self event)
  (tell #:type _void (coerce-arg self) rightMouseUp: (coerce-arg event)))
(define (nsstackview-rotate-by-angle self angle)
  (_msg-33 (coerce-arg self) (sel_registerName "rotateByAngle:") angle))
(define (nsstackview-rotate-with-event self event)
  (tell #:type _void (coerce-arg self) rotateWithEvent: (coerce-arg event)))
(define (nsstackview-scale-unit-square-to-size self new-unit-size)
  (_msg-30 (coerce-arg self) (sel_registerName "scaleUnitSquareToSize:") new-unit-size))
(define (nsstackview-scroll-line-down self sender)
  (tell #:type _void (coerce-arg self) scrollLineDown: (coerce-arg sender)))
(define (nsstackview-scroll-line-up self sender)
  (tell #:type _void (coerce-arg self) scrollLineUp: (coerce-arg sender)))
(define (nsstackview-scroll-page-down self sender)
  (tell #:type _void (coerce-arg self) scrollPageDown: (coerce-arg sender)))
(define (nsstackview-scroll-page-up self sender)
  (tell #:type _void (coerce-arg self) scrollPageUp: (coerce-arg sender)))
(define (nsstackview-scroll-point self point)
  (_msg-13 (coerce-arg self) (sel_registerName "scrollPoint:") point))
(define (nsstackview-scroll-rect-to-visible self rect)
  (_msg-21 (coerce-arg self) (sel_registerName "scrollRectToVisible:") rect))
(define (nsstackview-scroll-to-beginning-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToBeginningOfDocument: (coerce-arg sender)))
(define (nsstackview-scroll-to-end-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToEndOfDocument: (coerce-arg sender)))
(define (nsstackview-scroll-wheel self event)
  (tell #:type _void (coerce-arg self) scrollWheel: (coerce-arg event)))
(define (nsstackview-select-all self sender)
  (tell #:type _void (coerce-arg self) selectAll: (coerce-arg sender)))
(define (nsstackview-select-line self sender)
  (tell #:type _void (coerce-arg self) selectLine: (coerce-arg sender)))
(define (nsstackview-select-paragraph self sender)
  (tell #:type _void (coerce-arg self) selectParagraph: (coerce-arg sender)))
(define (nsstackview-select-to-mark self sender)
  (tell #:type _void (coerce-arg self) selectToMark: (coerce-arg sender)))
(define (nsstackview-select-word self sender)
  (tell #:type _void (coerce-arg self) selectWord: (coerce-arg sender)))
(define (nsstackview-set-accessibility-activation-point! self accessibility-activation-point)
  (_msg-13 (coerce-arg self) (sel_registerName "setAccessibilityActivationPoint:") accessibility-activation-point))
(define (nsstackview-set-accessibility-allowed-values! self accessibility-allowed-values)
  (tell #:type _void (coerce-arg self) setAccessibilityAllowedValues: (coerce-arg accessibility-allowed-values)))
(define (nsstackview-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (_msg-32 (coerce-arg self) (sel_registerName "setAccessibilityAlternateUIVisible:") accessibility-alternate-ui-visible))
(define (nsstackview-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityApplicationFocusedUIElement: (coerce-arg accessibility-application-focused-ui-element)))
(define (nsstackview-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityAttributedUserInputLabels: (coerce-arg accessibility-attributed-user-input-labels)))
(define (nsstackview-set-accessibility-cancel-button! self accessibility-cancel-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCancelButton: (coerce-arg accessibility-cancel-button)))
(define (nsstackview-set-accessibility-children! self accessibility-children)
  (tell #:type _void (coerce-arg self) setAccessibilityChildren: (coerce-arg accessibility-children)))
(define (nsstackview-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (tell #:type _void (coerce-arg self) setAccessibilityChildrenInNavigationOrder: (coerce-arg accessibility-children-in-navigation-order)))
(define (nsstackview-set-accessibility-clear-button! self accessibility-clear-button)
  (tell #:type _void (coerce-arg self) setAccessibilityClearButton: (coerce-arg accessibility-clear-button)))
(define (nsstackview-set-accessibility-close-button! self accessibility-close-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCloseButton: (coerce-arg accessibility-close-button)))
(define (nsstackview-set-accessibility-column-count! self accessibility-column-count)
  (_msg-49 (coerce-arg self) (sel_registerName "setAccessibilityColumnCount:") accessibility-column-count))
(define (nsstackview-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnHeaderUIElements: (coerce-arg accessibility-column-header-ui-elements)))
(define (nsstackview-set-accessibility-column-index-range! self accessibility-column-index-range)
  (_msg-19 (coerce-arg self) (sel_registerName "setAccessibilityColumnIndexRange:") accessibility-column-index-range))
(define (nsstackview-set-accessibility-column-titles! self accessibility-column-titles)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnTitles: (coerce-arg accessibility-column-titles)))
(define (nsstackview-set-accessibility-columns! self accessibility-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityColumns: (coerce-arg accessibility-columns)))
(define (nsstackview-set-accessibility-contents! self accessibility-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityContents: (coerce-arg accessibility-contents)))
(define (nsstackview-set-accessibility-critical-value! self accessibility-critical-value)
  (tell #:type _void (coerce-arg self) setAccessibilityCriticalValue: (coerce-arg accessibility-critical-value)))
(define (nsstackview-set-accessibility-custom-actions! self accessibility-custom-actions)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomActions: (coerce-arg accessibility-custom-actions)))
(define (nsstackview-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomRotors: (coerce-arg accessibility-custom-rotors)))
(define (nsstackview-set-accessibility-decrement-button! self accessibility-decrement-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDecrementButton: (coerce-arg accessibility-decrement-button)))
(define (nsstackview-set-accessibility-default-button! self accessibility-default-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDefaultButton: (coerce-arg accessibility-default-button)))
(define (nsstackview-set-accessibility-disclosed! self accessibility-disclosed)
  (_msg-32 (coerce-arg self) (sel_registerName "setAccessibilityDisclosed:") accessibility-disclosed))
(define (nsstackview-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedByRow: (coerce-arg accessibility-disclosed-by-row)))
(define (nsstackview-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedRows: (coerce-arg accessibility-disclosed-rows)))
(define (nsstackview-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (_msg-49 (coerce-arg self) (sel_registerName "setAccessibilityDisclosureLevel:") accessibility-disclosure-level))
(define (nsstackview-set-accessibility-document! self accessibility-document)
  (tell #:type _void (coerce-arg self) setAccessibilityDocument: (coerce-arg accessibility-document)))
(define (nsstackview-set-accessibility-edited! self accessibility-edited)
  (_msg-32 (coerce-arg self) (sel_registerName "setAccessibilityEdited:") accessibility-edited))
(define (nsstackview-set-accessibility-element! self accessibility-element)
  (_msg-32 (coerce-arg self) (sel_registerName "setAccessibilityElement:") accessibility-element))
(define (nsstackview-set-accessibility-enabled! self accessibility-enabled)
  (_msg-32 (coerce-arg self) (sel_registerName "setAccessibilityEnabled:") accessibility-enabled))
(define (nsstackview-set-accessibility-expanded! self accessibility-expanded)
  (_msg-32 (coerce-arg self) (sel_registerName "setAccessibilityExpanded:") accessibility-expanded))
(define (nsstackview-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityExtrasMenuBar: (coerce-arg accessibility-extras-menu-bar)))
(define (nsstackview-set-accessibility-filename! self accessibility-filename)
  (tell #:type _void (coerce-arg self) setAccessibilityFilename: (coerce-arg accessibility-filename)))
(define (nsstackview-set-accessibility-focused! self accessibility-focused)
  (_msg-32 (coerce-arg self) (sel_registerName "setAccessibilityFocused:") accessibility-focused))
(define (nsstackview-set-accessibility-focused-window! self accessibility-focused-window)
  (tell #:type _void (coerce-arg self) setAccessibilityFocusedWindow: (coerce-arg accessibility-focused-window)))
(define (nsstackview-set-accessibility-frame! self accessibility-frame)
  (_msg-23 (coerce-arg self) (sel_registerName "setAccessibilityFrame:") accessibility-frame))
(define (nsstackview-set-accessibility-frontmost! self accessibility-frontmost)
  (_msg-32 (coerce-arg self) (sel_registerName "setAccessibilityFrontmost:") accessibility-frontmost))
(define (nsstackview-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (tell #:type _void (coerce-arg self) setAccessibilityFullScreenButton: (coerce-arg accessibility-full-screen-button)))
(define (nsstackview-set-accessibility-grow-area! self accessibility-grow-area)
  (tell #:type _void (coerce-arg self) setAccessibilityGrowArea: (coerce-arg accessibility-grow-area)))
(define (nsstackview-set-accessibility-handles! self accessibility-handles)
  (tell #:type _void (coerce-arg self) setAccessibilityHandles: (coerce-arg accessibility-handles)))
(define (nsstackview-set-accessibility-header! self accessibility-header)
  (tell #:type _void (coerce-arg self) setAccessibilityHeader: (coerce-arg accessibility-header)))
(define (nsstackview-set-accessibility-help! self accessibility-help)
  (tell #:type _void (coerce-arg self) setAccessibilityHelp: (coerce-arg accessibility-help)))
(define (nsstackview-set-accessibility-hidden! self accessibility-hidden)
  (_msg-32 (coerce-arg self) (sel_registerName "setAccessibilityHidden:") accessibility-hidden))
(define (nsstackview-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalScrollBar: (coerce-arg accessibility-horizontal-scroll-bar)))
(define (nsstackview-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalUnitDescription: (coerce-arg accessibility-horizontal-unit-description)))
(define (nsstackview-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (_msg-49 (coerce-arg self) (sel_registerName "setAccessibilityHorizontalUnits:") accessibility-horizontal-units))
(define (nsstackview-set-accessibility-identifier! self accessibility-identifier)
  (tell #:type _void (coerce-arg self) setAccessibilityIdentifier: (coerce-arg accessibility-identifier)))
(define (nsstackview-set-accessibility-increment-button! self accessibility-increment-button)
  (tell #:type _void (coerce-arg self) setAccessibilityIncrementButton: (coerce-arg accessibility-increment-button)))
(define (nsstackview-set-accessibility-index! self accessibility-index)
  (_msg-49 (coerce-arg self) (sel_registerName "setAccessibilityIndex:") accessibility-index))
(define (nsstackview-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (_msg-49 (coerce-arg self) (sel_registerName "setAccessibilityInsertionPointLineNumber:") accessibility-insertion-point-line-number))
(define (nsstackview-set-accessibility-label! self accessibility-label)
  (tell #:type _void (coerce-arg self) setAccessibilityLabel: (coerce-arg accessibility-label)))
(define (nsstackview-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLabelUIElements: (coerce-arg accessibility-label-ui-elements)))
(define (nsstackview-set-accessibility-label-value! self accessibility-label-value)
  (_msg-35 (coerce-arg self) (sel_registerName "setAccessibilityLabelValue:") accessibility-label-value))
(define (nsstackview-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLinkedUIElements: (coerce-arg accessibility-linked-ui-elements)))
(define (nsstackview-set-accessibility-main! self accessibility-main)
  (_msg-32 (coerce-arg self) (sel_registerName "setAccessibilityMain:") accessibility-main))
(define (nsstackview-set-accessibility-main-window! self accessibility-main-window)
  (tell #:type _void (coerce-arg self) setAccessibilityMainWindow: (coerce-arg accessibility-main-window)))
(define (nsstackview-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerGroupUIElement: (coerce-arg accessibility-marker-group-ui-element)))
(define (nsstackview-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerTypeDescription: (coerce-arg accessibility-marker-type-description)))
(define (nsstackview-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerUIElements: (coerce-arg accessibility-marker-ui-elements)))
(define (nsstackview-set-accessibility-marker-values! self accessibility-marker-values)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerValues: (coerce-arg accessibility-marker-values)))
(define (nsstackview-set-accessibility-max-value! self accessibility-max-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMaxValue: (coerce-arg accessibility-max-value)))
(define (nsstackview-set-accessibility-menu-bar! self accessibility-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityMenuBar: (coerce-arg accessibility-menu-bar)))
(define (nsstackview-set-accessibility-min-value! self accessibility-min-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMinValue: (coerce-arg accessibility-min-value)))
(define (nsstackview-set-accessibility-minimize-button! self accessibility-minimize-button)
  (tell #:type _void (coerce-arg self) setAccessibilityMinimizeButton: (coerce-arg accessibility-minimize-button)))
(define (nsstackview-set-accessibility-minimized! self accessibility-minimized)
  (_msg-32 (coerce-arg self) (sel_registerName "setAccessibilityMinimized:") accessibility-minimized))
(define (nsstackview-set-accessibility-modal! self accessibility-modal)
  (_msg-32 (coerce-arg self) (sel_registerName "setAccessibilityModal:") accessibility-modal))
(define (nsstackview-set-accessibility-next-contents! self accessibility-next-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityNextContents: (coerce-arg accessibility-next-contents)))
(define (nsstackview-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (_msg-49 (coerce-arg self) (sel_registerName "setAccessibilityNumberOfCharacters:") accessibility-number-of-characters))
(define (nsstackview-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (_msg-32 (coerce-arg self) (sel_registerName "setAccessibilityOrderedByRow:") accessibility-ordered-by-row))
(define (nsstackview-set-accessibility-orientation! self accessibility-orientation)
  (_msg-49 (coerce-arg self) (sel_registerName "setAccessibilityOrientation:") accessibility-orientation))
(define (nsstackview-set-accessibility-overflow-button! self accessibility-overflow-button)
  (tell #:type _void (coerce-arg self) setAccessibilityOverflowButton: (coerce-arg accessibility-overflow-button)))
(define (nsstackview-set-accessibility-parent! self accessibility-parent)
  (tell #:type _void (coerce-arg self) setAccessibilityParent: (coerce-arg accessibility-parent)))
(define (nsstackview-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (tell #:type _void (coerce-arg self) setAccessibilityPlaceholderValue: (coerce-arg accessibility-placeholder-value)))
(define (nsstackview-set-accessibility-previous-contents! self accessibility-previous-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityPreviousContents: (coerce-arg accessibility-previous-contents)))
(define (nsstackview-set-accessibility-protected-content! self accessibility-protected-content)
  (_msg-32 (coerce-arg self) (sel_registerName "setAccessibilityProtectedContent:") accessibility-protected-content))
(define (nsstackview-set-accessibility-proxy! self accessibility-proxy)
  (tell #:type _void (coerce-arg self) setAccessibilityProxy: (coerce-arg accessibility-proxy)))
(define (nsstackview-set-accessibility-required! self accessibility-required)
  (_msg-32 (coerce-arg self) (sel_registerName "setAccessibilityRequired:") accessibility-required))
(define (nsstackview-set-accessibility-role! self accessibility-role)
  (tell #:type _void (coerce-arg self) setAccessibilityRole: (coerce-arg accessibility-role)))
(define (nsstackview-set-accessibility-role-description! self accessibility-role-description)
  (tell #:type _void (coerce-arg self) setAccessibilityRoleDescription: (coerce-arg accessibility-role-description)))
(define (nsstackview-set-accessibility-row-count! self accessibility-row-count)
  (_msg-49 (coerce-arg self) (sel_registerName "setAccessibilityRowCount:") accessibility-row-count))
(define (nsstackview-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityRowHeaderUIElements: (coerce-arg accessibility-row-header-ui-elements)))
(define (nsstackview-set-accessibility-row-index-range! self accessibility-row-index-range)
  (_msg-19 (coerce-arg self) (sel_registerName "setAccessibilityRowIndexRange:") accessibility-row-index-range))
(define (nsstackview-set-accessibility-rows! self accessibility-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityRows: (coerce-arg accessibility-rows)))
(define (nsstackview-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (_msg-49 (coerce-arg self) (sel_registerName "setAccessibilityRulerMarkerType:") accessibility-ruler-marker-type))
(define (nsstackview-set-accessibility-search-button! self accessibility-search-button)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchButton: (coerce-arg accessibility-search-button)))
(define (nsstackview-set-accessibility-search-menu! self accessibility-search-menu)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchMenu: (coerce-arg accessibility-search-menu)))
(define (nsstackview-set-accessibility-selected! self accessibility-selected)
  (_msg-32 (coerce-arg self) (sel_registerName "setAccessibilitySelected:") accessibility-selected))
(define (nsstackview-set-accessibility-selected-cells! self accessibility-selected-cells)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedCells: (coerce-arg accessibility-selected-cells)))
(define (nsstackview-set-accessibility-selected-children! self accessibility-selected-children)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedChildren: (coerce-arg accessibility-selected-children)))
(define (nsstackview-set-accessibility-selected-columns! self accessibility-selected-columns)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedColumns: (coerce-arg accessibility-selected-columns)))
(define (nsstackview-set-accessibility-selected-rows! self accessibility-selected-rows)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedRows: (coerce-arg accessibility-selected-rows)))
(define (nsstackview-set-accessibility-selected-text! self accessibility-selected-text)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedText: (coerce-arg accessibility-selected-text)))
(define (nsstackview-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (_msg-19 (coerce-arg self) (sel_registerName "setAccessibilitySelectedTextRange:") accessibility-selected-text-range))
(define (nsstackview-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedTextRanges: (coerce-arg accessibility-selected-text-ranges)))
(define (nsstackview-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityServesAsTitleForUIElements: (coerce-arg accessibility-serves-as-title-for-ui-elements)))
(define (nsstackview-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (_msg-19 (coerce-arg self) (sel_registerName "setAccessibilitySharedCharacterRange:") accessibility-shared-character-range))
(define (nsstackview-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedFocusElements: (coerce-arg accessibility-shared-focus-elements)))
(define (nsstackview-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedTextUIElements: (coerce-arg accessibility-shared-text-ui-elements)))
(define (nsstackview-set-accessibility-shown-menu! self accessibility-shown-menu)
  (tell #:type _void (coerce-arg self) setAccessibilityShownMenu: (coerce-arg accessibility-shown-menu)))
(define (nsstackview-set-accessibility-sort-direction! self accessibility-sort-direction)
  (_msg-49 (coerce-arg self) (sel_registerName "setAccessibilitySortDirection:") accessibility-sort-direction))
(define (nsstackview-set-accessibility-splitters! self accessibility-splitters)
  (tell #:type _void (coerce-arg self) setAccessibilitySplitters: (coerce-arg accessibility-splitters)))
(define (nsstackview-set-accessibility-subrole! self accessibility-subrole)
  (tell #:type _void (coerce-arg self) setAccessibilitySubrole: (coerce-arg accessibility-subrole)))
(define (nsstackview-set-accessibility-tabs! self accessibility-tabs)
  (tell #:type _void (coerce-arg self) setAccessibilityTabs: (coerce-arg accessibility-tabs)))
(define (nsstackview-set-accessibility-title! self accessibility-title)
  (tell #:type _void (coerce-arg self) setAccessibilityTitle: (coerce-arg accessibility-title)))
(define (nsstackview-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTitleUIElement: (coerce-arg accessibility-title-ui-element)))
(define (nsstackview-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (tell #:type _void (coerce-arg self) setAccessibilityToolbarButton: (coerce-arg accessibility-toolbar-button)))
(define (nsstackview-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTopLevelUIElement: (coerce-arg accessibility-top-level-ui-element)))
(define (nsstackview-set-accessibility-url! self accessibility-url)
  (tell #:type _void (coerce-arg self) setAccessibilityURL: (coerce-arg accessibility-url)))
(define (nsstackview-set-accessibility-unit-description! self accessibility-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityUnitDescription: (coerce-arg accessibility-unit-description)))
(define (nsstackview-set-accessibility-units! self accessibility-units)
  (_msg-49 (coerce-arg self) (sel_registerName "setAccessibilityUnits:") accessibility-units))
(define (nsstackview-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityUserInputLabels: (coerce-arg accessibility-user-input-labels)))
(define (nsstackview-set-accessibility-value! self accessibility-value)
  (tell #:type _void (coerce-arg self) setAccessibilityValue: (coerce-arg accessibility-value)))
(define (nsstackview-set-accessibility-value-description! self accessibility-value-description)
  (tell #:type _void (coerce-arg self) setAccessibilityValueDescription: (coerce-arg accessibility-value-description)))
(define (nsstackview-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalScrollBar: (coerce-arg accessibility-vertical-scroll-bar)))
(define (nsstackview-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalUnitDescription: (coerce-arg accessibility-vertical-unit-description)))
(define (nsstackview-set-accessibility-vertical-units! self accessibility-vertical-units)
  (_msg-49 (coerce-arg self) (sel_registerName "setAccessibilityVerticalUnits:") accessibility-vertical-units))
(define (nsstackview-set-accessibility-visible-cells! self accessibility-visible-cells)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleCells: (coerce-arg accessibility-visible-cells)))
(define (nsstackview-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (_msg-19 (coerce-arg self) (sel_registerName "setAccessibilityVisibleCharacterRange:") accessibility-visible-character-range))
(define (nsstackview-set-accessibility-visible-children! self accessibility-visible-children)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleChildren: (coerce-arg accessibility-visible-children)))
(define (nsstackview-set-accessibility-visible-columns! self accessibility-visible-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleColumns: (coerce-arg accessibility-visible-columns)))
(define (nsstackview-set-accessibility-visible-rows! self accessibility-visible-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleRows: (coerce-arg accessibility-visible-rows)))
(define (nsstackview-set-accessibility-warning-value! self accessibility-warning-value)
  (tell #:type _void (coerce-arg self) setAccessibilityWarningValue: (coerce-arg accessibility-warning-value)))
(define (nsstackview-set-accessibility-window! self accessibility-window)
  (tell #:type _void (coerce-arg self) setAccessibilityWindow: (coerce-arg accessibility-window)))
(define (nsstackview-set-accessibility-windows! self accessibility-windows)
  (tell #:type _void (coerce-arg self) setAccessibilityWindows: (coerce-arg accessibility-windows)))
(define (nsstackview-set-accessibility-zoom-button! self accessibility-zoom-button)
  (tell #:type _void (coerce-arg self) setAccessibilityZoomButton: (coerce-arg accessibility-zoom-button)))
(define (nsstackview-set-animations! self animations)
  (tell #:type _void (coerce-arg self) setAnimations: (coerce-arg animations)))
(define (nsstackview-set-appearance! self appearance)
  (tell #:type _void (coerce-arg self) setAppearance: (coerce-arg appearance)))
(define (nsstackview-set-bounds-origin! self new-origin)
  (_msg-13 (coerce-arg self) (sel_registerName "setBoundsOrigin:") new-origin))
(define (nsstackview-set-bounds-size! self new-size)
  (_msg-30 (coerce-arg self) (sel_registerName "setBoundsSize:") new-size))
(define (nsstackview-set-clipping-resistance-priority-for-orientation! self clipping-resistance-priority orientation)
  (_msg-37 (coerce-arg self) (sel_registerName "setClippingResistancePriority:forOrientation:") clipping-resistance-priority orientation))
(define (nsstackview-set-custom-spacing-after-view! self spacing view)
  (_msg-34 (coerce-arg self) (sel_registerName "setCustomSpacing:afterView:") spacing (coerce-arg view)))
(define (nsstackview-set-frame-origin! self new-origin)
  (_msg-13 (coerce-arg self) (sel_registerName "setFrameOrigin:") new-origin))
(define (nsstackview-set-frame-size! self new-size)
  (_msg-30 (coerce-arg self) (sel_registerName "setFrameSize:") new-size))
(define (nsstackview-set-hugging-priority-for-orientation! self hugging-priority orientation)
  (_msg-37 (coerce-arg self) (sel_registerName "setHuggingPriority:forOrientation:") hugging-priority orientation))
(define (nsstackview-set-identifier! self identifier)
  (tell #:type _void (coerce-arg self) setIdentifier: (coerce-arg identifier)))
(define (nsstackview-set-mark! self sender)
  (tell #:type _void (coerce-arg self) setMark: (coerce-arg sender)))
(define (nsstackview-set-needs-display-in-rect! self invalid-rect)
  (_msg-23 (coerce-arg self) (sel_registerName "setNeedsDisplayInRect:") invalid-rect))
(define (nsstackview-set-visibility-priority-for-view! self priority view)
  (_msg-36 (coerce-arg self) (sel_registerName "setVisibilityPriority:forView:") priority (coerce-arg view)))
(define (nsstackview-should-be-treated-as-ink-event self event)
  (_msg-38 (coerce-arg self) (sel_registerName "shouldBeTreatedAsInkEvent:") (coerce-arg event)))
(define (nsstackview-should-delay-window-ordering-for-event self event)
  (_msg-38 (coerce-arg self) (sel_registerName "shouldDelayWindowOrderingForEvent:") (coerce-arg event)))
(define (nsstackview-show-context-help self sender)
  (tell #:type _void (coerce-arg self) showContextHelp: (coerce-arg sender)))
(define (nsstackview-show-context-menu-for-selection self sender)
  (tell #:type _void (coerce-arg self) showContextMenuForSelection: (coerce-arg sender)))
(define (nsstackview-smart-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) smartMagnifyWithEvent: (coerce-arg event)))
(define (nsstackview-sort-subviews-using-function-context self compare context)
  (_msg-55 (coerce-arg self) (sel_registerName "sortSubviewsUsingFunction:context:") compare context))
(define (nsstackview-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (_msg-54 (coerce-arg self) (sel_registerName "supplementalTargetForAction:sender:") (sel_registerName action) (coerce-arg sender))
   ))
(define (nsstackview-swap-with-mark self sender)
  (tell #:type _void (coerce-arg self) swapWithMark: (coerce-arg sender)))
(define (nsstackview-swipe-with-event self event)
  (tell #:type _void (coerce-arg self) swipeWithEvent: (coerce-arg event)))
(define (nsstackview-tablet-point self event)
  (tell #:type _void (coerce-arg self) tabletPoint: (coerce-arg event)))
(define (nsstackview-tablet-proximity self event)
  (tell #:type _void (coerce-arg self) tabletProximity: (coerce-arg event)))
(define (nsstackview-touches-began-with-event self event)
  (tell #:type _void (coerce-arg self) touchesBeganWithEvent: (coerce-arg event)))
(define (nsstackview-touches-cancelled-with-event self event)
  (tell #:type _void (coerce-arg self) touchesCancelledWithEvent: (coerce-arg event)))
(define (nsstackview-touches-ended-with-event self event)
  (tell #:type _void (coerce-arg self) touchesEndedWithEvent: (coerce-arg event)))
(define (nsstackview-touches-moved-with-event self event)
  (tell #:type _void (coerce-arg self) touchesMovedWithEvent: (coerce-arg event)))
(define (nsstackview-translate-origin-to-point self translation)
  (_msg-13 (coerce-arg self) (sel_registerName "translateOriginToPoint:") translation))
(define (nsstackview-translate-rects-needing-display-in-rect-by self clip-rect delta)
  (_msg-24 (coerce-arg self) (sel_registerName "translateRectsNeedingDisplayInRect:by:") clip-rect delta))
(define (nsstackview-transpose self sender)
  (tell #:type _void (coerce-arg self) transpose: (coerce-arg sender)))
(define (nsstackview-transpose-words self sender)
  (tell #:type _void (coerce-arg self) transposeWords: (coerce-arg sender)))
(define (nsstackview-try-to-perform-with self action object)
  (_msg-53 (coerce-arg self) (sel_registerName "tryToPerform:with:") (sel_registerName action) (coerce-arg object)))
(define (nsstackview-update-dragging-items-for-drag self sender)
  (tell #:type _void (coerce-arg self) updateDraggingItemsForDrag: (coerce-arg sender)))
(define (nsstackview-update-layer self)
  (tell #:type _void (coerce-arg self) updateLayer))
(define (nsstackview-uppercase-word self sender)
  (tell #:type _void (coerce-arg self) uppercaseWord: (coerce-arg sender)))
(define (nsstackview-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (tell (coerce-arg self) validRequestorForSendType: (coerce-arg send-type) returnType: (coerce-arg return-type))))
(define (nsstackview-view-did-change-backing-properties self)
  (tell #:type _void (coerce-arg self) viewDidChangeBackingProperties))
(define (nsstackview-view-did-change-effective-appearance self)
  (tell #:type _void (coerce-arg self) viewDidChangeEffectiveAppearance))
(define (nsstackview-view-did-end-live-resize self)
  (tell #:type _void (coerce-arg self) viewDidEndLiveResize))
(define (nsstackview-view-did-hide self)
  (tell #:type _void (coerce-arg self) viewDidHide))
(define (nsstackview-view-did-move-to-superview self)
  (tell #:type _void (coerce-arg self) viewDidMoveToSuperview))
(define (nsstackview-view-did-move-to-window self)
  (tell #:type _void (coerce-arg self) viewDidMoveToWindow))
(define (nsstackview-view-did-unhide self)
  (tell #:type _void (coerce-arg self) viewDidUnhide))
(define (nsstackview-view-will-draw self)
  (tell #:type _void (coerce-arg self) viewWillDraw))
(define (nsstackview-view-will-move-to-superview self new-superview)
  (tell #:type _void (coerce-arg self) viewWillMoveToSuperview: (coerce-arg new-superview)))
(define (nsstackview-view-will-move-to-window self new-window)
  (tell #:type _void (coerce-arg self) viewWillMoveToWindow: (coerce-arg new-window)))
(define (nsstackview-view-will-start-live-resize self)
  (tell #:type _void (coerce-arg self) viewWillStartLiveResize))
(define (nsstackview-view-with-tag self tag)
  (wrap-objc-object
   (_msg-47 (coerce-arg self) (sel_registerName "viewWithTag:") tag)
   ))
(define (nsstackview-visibility-priority-for-view self view)
  (_msg-40 (coerce-arg self) (sel_registerName "visibilityPriorityForView:") (coerce-arg view)))
(define (nsstackview-wants-forwarded-scroll-events-for-axis self axis)
  (_msg-45 (coerce-arg self) (sel_registerName "wantsForwardedScrollEventsForAxis:") axis))
(define (nsstackview-wants-periodic-dragging-updates self)
  (_msg-4 (coerce-arg self) (sel_registerName "wantsPeriodicDraggingUpdates")))
(define (nsstackview-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (_msg-45 (coerce-arg self) (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:") axis))
(define (nsstackview-will-open-menu-with-event self menu event)
  (tell #:type _void (coerce-arg self) willOpenMenu: (coerce-arg menu) withEvent: (coerce-arg event)))
(define (nsstackview-will-remove-subview self subview)
  (tell #:type _void (coerce-arg self) willRemoveSubview: (coerce-arg subview)))
(define (nsstackview-yank self sender)
  (tell #:type _void (coerce-arg self) yank: (coerce-arg sender)))

;; --- Class methods ---
(define (nsstackview-default-animation-for-key key)
  (wrap-objc-object
   (tell NSStackView defaultAnimationForKey: (coerce-arg key))))
(define (nsstackview-is-compatible-with-responsive-scrolling)
  (_msg-4 NSStackView (sel_registerName "isCompatibleWithResponsiveScrolling")))
(define (nsstackview-stack-view-with-views views)
  (wrap-objc-object
   (tell NSStackView stackViewWithViews: (coerce-arg views))))
