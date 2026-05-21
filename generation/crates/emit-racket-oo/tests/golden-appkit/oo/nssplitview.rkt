#lang racket/base
;; Generated binding for NSSplitView (AppKit)
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
(define (nscolor? v) (objc-instance-of? v "NSColor"))
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
(define (nssplitview? v) (objc-instance-of? v "NSSplitView"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (nstextinputcontext? v) (objc-instance-of? v "NSTextInputContext"))
(define (nstouchbar? v) (objc-instance-of? v "NSTouchBar"))
(define (nsurl? v) (objc-instance-of? v "NSURL"))
(define (nsundomanager? v) (objc-instance-of? v "NSUndoManager"))
(define (nsuseractivity? v) (objc-instance-of? v "NSUserActivity"))
(define (nsview? v) (objc-instance-of? v "NSView"))
(define (nswindow? v) (objc-instance-of? v "NSWindow"))
(define (nswritingtoolscoordinator? v) (objc-instance-of? v "NSWritingToolsCoordinator"))
(provide NSSplitView)
(provide/contract
  [make-nssplitview-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nssplitview-init-with-frame (c-> any/c any/c)]
  [nssplitview-accepts-first-responder (c-> nssplitview? boolean?)]
  [nssplitview-accepts-touch-events (c-> nssplitview? boolean?)]
  [nssplitview-set-accepts-touch-events! (c-> nssplitview? boolean? void?)]
  [nssplitview-additional-safe-area-insets (c-> nssplitview? any/c)]
  [nssplitview-set-additional-safe-area-insets! (c-> nssplitview? any/c void?)]
  [nssplitview-alignment-rect-insets (c-> nssplitview? any/c)]
  [nssplitview-allowed-touch-types (c-> nssplitview? exact-nonnegative-integer?)]
  [nssplitview-set-allowed-touch-types! (c-> nssplitview? exact-nonnegative-integer? void?)]
  [nssplitview-allows-vibrancy (c-> nssplitview? boolean?)]
  [nssplitview-alpha-value (c-> nssplitview? real?)]
  [nssplitview-set-alpha-value! (c-> nssplitview? real? void?)]
  [nssplitview-arranged-subviews (c-> nssplitview? any/c)]
  [nssplitview-arranges-all-subviews (c-> nssplitview? boolean?)]
  [nssplitview-set-arranges-all-subviews! (c-> nssplitview? boolean? void?)]
  [nssplitview-autoresizes-subviews (c-> nssplitview? boolean?)]
  [nssplitview-set-autoresizes-subviews! (c-> nssplitview? boolean? void?)]
  [nssplitview-autoresizing-mask (c-> nssplitview? exact-nonnegative-integer?)]
  [nssplitview-set-autoresizing-mask! (c-> nssplitview? exact-nonnegative-integer? void?)]
  [nssplitview-autosave-name (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-set-autosave-name! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-background-filters (c-> nssplitview? any/c)]
  [nssplitview-set-background-filters! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-baseline-offset-from-bottom (c-> nssplitview? real?)]
  [nssplitview-bottom-anchor (c-> nssplitview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nssplitview-bounds (c-> nssplitview? any/c)]
  [nssplitview-set-bounds! (c-> nssplitview? any/c void?)]
  [nssplitview-bounds-rotation (c-> nssplitview? real?)]
  [nssplitview-set-bounds-rotation! (c-> nssplitview? real? void?)]
  [nssplitview-can-become-key-view (c-> nssplitview? boolean?)]
  [nssplitview-can-draw (c-> nssplitview? boolean?)]
  [nssplitview-can-draw-concurrently (c-> nssplitview? boolean?)]
  [nssplitview-set-can-draw-concurrently! (c-> nssplitview? boolean? void?)]
  [nssplitview-can-draw-subviews-into-layer (c-> nssplitview? boolean?)]
  [nssplitview-set-can-draw-subviews-into-layer! (c-> nssplitview? boolean? void?)]
  [nssplitview-candidate-list-touch-bar-item (c-> nssplitview? (or/c nscandidatelisttouchbaritem? objc-nil?))]
  [nssplitview-center-x-anchor (c-> nssplitview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nssplitview-center-y-anchor (c-> nssplitview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nssplitview-clips-to-bounds (c-> nssplitview? boolean?)]
  [nssplitview-set-clips-to-bounds! (c-> nssplitview? boolean? void?)]
  [nssplitview-compatible-with-responsive-scrolling (c-> boolean?)]
  [nssplitview-compositing-filter (c-> nssplitview? (or/c cifilter? objc-nil?))]
  [nssplitview-set-compositing-filter! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-constraints (c-> nssplitview? any/c)]
  [nssplitview-content-filters (c-> nssplitview? any/c)]
  [nssplitview-set-content-filters! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-default-focus-ring-type (c-> exact-nonnegative-integer?)]
  [nssplitview-default-menu (c-> (or/c nsmenu? objc-nil?))]
  [nssplitview-delegate (c-> nssplitview? any/c)]
  [nssplitview-set-delegate! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-divider-color (c-> nssplitview? (or/c nscolor? objc-nil?))]
  [nssplitview-divider-style (c-> nssplitview? exact-integer?)]
  [nssplitview-set-divider-style! (c-> nssplitview? exact-integer? void?)]
  [nssplitview-divider-thickness (c-> nssplitview? real?)]
  [nssplitview-drawing-find-indicator (c-> nssplitview? boolean?)]
  [nssplitview-enclosing-menu-item (c-> nssplitview? (or/c nsmenuitem? objc-nil?))]
  [nssplitview-enclosing-scroll-view (c-> nssplitview? (or/c nsscrollview? objc-nil?))]
  [nssplitview-first-baseline-anchor (c-> nssplitview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nssplitview-first-baseline-offset-from-top (c-> nssplitview? real?)]
  [nssplitview-fitting-size (c-> nssplitview? any/c)]
  [nssplitview-flipped (c-> nssplitview? boolean?)]
  [nssplitview-focus-ring-mask-bounds (c-> nssplitview? any/c)]
  [nssplitview-focus-ring-type (c-> nssplitview? exact-nonnegative-integer?)]
  [nssplitview-set-focus-ring-type! (c-> nssplitview? exact-nonnegative-integer? void?)]
  [nssplitview-focus-view (c-> (or/c nsview? objc-nil?))]
  [nssplitview-frame (c-> nssplitview? any/c)]
  [nssplitview-set-frame! (c-> nssplitview? any/c void?)]
  [nssplitview-frame-center-rotation (c-> nssplitview? real?)]
  [nssplitview-set-frame-center-rotation! (c-> nssplitview? real? void?)]
  [nssplitview-frame-rotation (c-> nssplitview? real?)]
  [nssplitview-set-frame-rotation! (c-> nssplitview? real? void?)]
  [nssplitview-gesture-recognizers (c-> nssplitview? any/c)]
  [nssplitview-set-gesture-recognizers! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-has-ambiguous-layout (c-> nssplitview? boolean?)]
  [nssplitview-height-adjust-limit (c-> nssplitview? real?)]
  [nssplitview-height-anchor (c-> nssplitview? (or/c nslayoutdimension? objc-nil?))]
  [nssplitview-hidden (c-> nssplitview? boolean?)]
  [nssplitview-set-hidden! (c-> nssplitview? boolean? void?)]
  [nssplitview-hidden-or-has-hidden-ancestor (c-> nssplitview? boolean?)]
  [nssplitview-horizontal-content-size-constraint-active (c-> nssplitview? boolean?)]
  [nssplitview-set-horizontal-content-size-constraint-active! (c-> nssplitview? boolean? void?)]
  [nssplitview-in-full-screen-mode (c-> nssplitview? boolean?)]
  [nssplitview-in-live-resize (c-> nssplitview? boolean?)]
  [nssplitview-input-context (c-> nssplitview? (or/c nstextinputcontext? objc-nil?))]
  [nssplitview-intrinsic-content-size (c-> nssplitview? any/c)]
  [nssplitview-last-baseline-anchor (c-> nssplitview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nssplitview-last-baseline-offset-from-bottom (c-> nssplitview? real?)]
  [nssplitview-layer (c-> nssplitview? (or/c calayer? objc-nil?))]
  [nssplitview-set-layer! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-layer-contents-placement (c-> nssplitview? exact-integer?)]
  [nssplitview-set-layer-contents-placement! (c-> nssplitview? exact-integer? void?)]
  [nssplitview-layer-contents-redraw-policy (c-> nssplitview? exact-integer?)]
  [nssplitview-set-layer-contents-redraw-policy! (c-> nssplitview? exact-integer? void?)]
  [nssplitview-layer-uses-core-image-filters (c-> nssplitview? boolean?)]
  [nssplitview-set-layer-uses-core-image-filters! (c-> nssplitview? boolean? void?)]
  [nssplitview-layout-guides (c-> nssplitview? any/c)]
  [nssplitview-layout-margins-guide (c-> nssplitview? (or/c nslayoutguide? objc-nil?))]
  [nssplitview-leading-anchor (c-> nssplitview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nssplitview-left-anchor (c-> nssplitview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nssplitview-menu (c-> nssplitview? (or/c nsmenu? objc-nil?))]
  [nssplitview-set-menu! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-mouse-down-can-move-window (c-> nssplitview? boolean?)]
  [nssplitview-needs-display (c-> nssplitview? boolean?)]
  [nssplitview-set-needs-display! (c-> nssplitview? boolean? void?)]
  [nssplitview-needs-layout (c-> nssplitview? boolean?)]
  [nssplitview-set-needs-layout! (c-> nssplitview? boolean? void?)]
  [nssplitview-needs-panel-to-become-key (c-> nssplitview? boolean?)]
  [nssplitview-needs-update-constraints (c-> nssplitview? boolean?)]
  [nssplitview-set-needs-update-constraints! (c-> nssplitview? boolean? void?)]
  [nssplitview-next-key-view (c-> nssplitview? (or/c nsview? objc-nil?))]
  [nssplitview-set-next-key-view! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-next-responder (c-> nssplitview? (or/c nsresponder? objc-nil?))]
  [nssplitview-set-next-responder! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-next-valid-key-view (c-> nssplitview? (or/c nsview? objc-nil?))]
  [nssplitview-opaque (c-> nssplitview? boolean?)]
  [nssplitview-opaque-ancestor (c-> nssplitview? (or/c nsview? objc-nil?))]
  [nssplitview-page-footer (c-> nssplitview? (or/c nsattributedstring? objc-nil?))]
  [nssplitview-page-header (c-> nssplitview? (or/c nsattributedstring? objc-nil?))]
  [nssplitview-posts-bounds-changed-notifications (c-> nssplitview? boolean?)]
  [nssplitview-set-posts-bounds-changed-notifications! (c-> nssplitview? boolean? void?)]
  [nssplitview-posts-frame-changed-notifications (c-> nssplitview? boolean?)]
  [nssplitview-set-posts-frame-changed-notifications! (c-> nssplitview? boolean? void?)]
  [nssplitview-prefers-compact-control-size-metrics (c-> nssplitview? boolean?)]
  [nssplitview-set-prefers-compact-control-size-metrics! (c-> nssplitview? boolean? void?)]
  [nssplitview-prepared-content-rect (c-> nssplitview? any/c)]
  [nssplitview-set-prepared-content-rect! (c-> nssplitview? any/c void?)]
  [nssplitview-preserves-content-during-live-resize (c-> nssplitview? boolean?)]
  [nssplitview-pressure-configuration (c-> nssplitview? (or/c nspressureconfiguration? objc-nil?))]
  [nssplitview-set-pressure-configuration! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-previous-key-view (c-> nssplitview? (or/c nsview? objc-nil?))]
  [nssplitview-previous-valid-key-view (c-> nssplitview? (or/c nsview? objc-nil?))]
  [nssplitview-print-job-title (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-rect-preserved-during-live-resize (c-> nssplitview? any/c)]
  [nssplitview-registered-dragged-types (c-> nssplitview? any/c)]
  [nssplitview-requires-constraint-based-layout (c-> boolean?)]
  [nssplitview-restorable-state-key-paths (c-> any/c)]
  [nssplitview-right-anchor (c-> nssplitview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nssplitview-rotated-from-base (c-> nssplitview? boolean?)]
  [nssplitview-rotated-or-scaled-from-base (c-> nssplitview? boolean?)]
  [nssplitview-safe-area-insets (c-> nssplitview? any/c)]
  [nssplitview-safe-area-layout-guide (c-> nssplitview? (or/c nslayoutguide? objc-nil?))]
  [nssplitview-safe-area-rect (c-> nssplitview? any/c)]
  [nssplitview-shadow (c-> nssplitview? (or/c nsshadow? objc-nil?))]
  [nssplitview-set-shadow! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-subviews (c-> nssplitview? any/c)]
  [nssplitview-set-subviews! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-superview (c-> nssplitview? (or/c nsview? objc-nil?))]
  [nssplitview-tag (c-> nssplitview? exact-integer?)]
  [nssplitview-tool-tip (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-set-tool-tip! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-top-anchor (c-> nssplitview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nssplitview-touch-bar (c-> nssplitview? (or/c nstouchbar? objc-nil?))]
  [nssplitview-set-touch-bar! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-tracking-areas (c-> nssplitview? any/c)]
  [nssplitview-trailing-anchor (c-> nssplitview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nssplitview-translates-autoresizing-mask-into-constraints (c-> nssplitview? boolean?)]
  [nssplitview-set-translates-autoresizing-mask-into-constraints! (c-> nssplitview? boolean? void?)]
  [nssplitview-undo-manager (c-> nssplitview? (or/c nsundomanager? objc-nil?))]
  [nssplitview-user-activity (c-> nssplitview? (or/c nsuseractivity? objc-nil?))]
  [nssplitview-set-user-activity! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-user-interface-layout-direction (c-> nssplitview? exact-integer?)]
  [nssplitview-set-user-interface-layout-direction! (c-> nssplitview? exact-integer? void?)]
  [nssplitview-vertical (c-> nssplitview? boolean?)]
  [nssplitview-set-vertical! (c-> nssplitview? boolean? void?)]
  [nssplitview-vertical-content-size-constraint-active (c-> nssplitview? boolean?)]
  [nssplitview-set-vertical-content-size-constraint-active! (c-> nssplitview? boolean? void?)]
  [nssplitview-visible-rect (c-> nssplitview? any/c)]
  [nssplitview-wants-best-resolution-open-gl-surface (c-> nssplitview? boolean?)]
  [nssplitview-set-wants-best-resolution-open-gl-surface! (c-> nssplitview? boolean? void?)]
  [nssplitview-wants-default-clipping (c-> nssplitview? boolean?)]
  [nssplitview-wants-extended-dynamic-range-open-gl-surface (c-> nssplitview? boolean?)]
  [nssplitview-set-wants-extended-dynamic-range-open-gl-surface! (c-> nssplitview? boolean? void?)]
  [nssplitview-wants-layer (c-> nssplitview? boolean?)]
  [nssplitview-set-wants-layer! (c-> nssplitview? boolean? void?)]
  [nssplitview-wants-resting-touches (c-> nssplitview? boolean?)]
  [nssplitview-set-wants-resting-touches! (c-> nssplitview? boolean? void?)]
  [nssplitview-wants-update-layer (c-> nssplitview? boolean?)]
  [nssplitview-width-adjust-limit (c-> nssplitview? real?)]
  [nssplitview-width-anchor (c-> nssplitview? (or/c nslayoutdimension? objc-nil?))]
  [nssplitview-window (c-> nssplitview? (or/c nswindow? objc-nil?))]
  [nssplitview-writing-tools-coordinator (c-> nssplitview? (or/c nswritingtoolscoordinator? objc-nil?))]
  [nssplitview-set-writing-tools-coordinator! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-accepts-first-mouse (c-> nssplitview? (or/c string? objc-object? #f) boolean?)]
  [nssplitview-accessibility-activation-point (c-> nssplitview? any/c)]
  [nssplitview-accessibility-allowed-values (c-> nssplitview? any/c)]
  [nssplitview-accessibility-application-focused-ui-element (c-> nssplitview? any/c)]
  [nssplitview-accessibility-attributed-string-for-range (c-> nssplitview? any/c (or/c nsattributedstring? objc-nil?))]
  [nssplitview-accessibility-attributed-user-input-labels (c-> nssplitview? any/c)]
  [nssplitview-accessibility-cancel-button (c-> nssplitview? any/c)]
  [nssplitview-accessibility-cell-for-column-row (c-> nssplitview? exact-integer? exact-integer? any/c)]
  [nssplitview-accessibility-children (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-children-in-navigation-order (c-> nssplitview? any/c)]
  [nssplitview-accessibility-clear-button (c-> nssplitview? any/c)]
  [nssplitview-accessibility-close-button (c-> nssplitview? any/c)]
  [nssplitview-accessibility-column-count (c-> nssplitview? exact-integer?)]
  [nssplitview-accessibility-column-header-ui-elements (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-column-index-range (c-> nssplitview? any/c)]
  [nssplitview-accessibility-column-titles (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-columns (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-contents (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-critical-value (c-> nssplitview? any/c)]
  [nssplitview-accessibility-custom-actions (c-> nssplitview? any/c)]
  [nssplitview-accessibility-custom-rotors (c-> nssplitview? any/c)]
  [nssplitview-accessibility-decrement-button (c-> nssplitview? any/c)]
  [nssplitview-accessibility-default-button (c-> nssplitview? any/c)]
  [nssplitview-accessibility-disclosed-by-row (c-> nssplitview? any/c)]
  [nssplitview-accessibility-disclosed-rows (c-> nssplitview? any/c)]
  [nssplitview-accessibility-disclosure-level (c-> nssplitview? exact-integer?)]
  [nssplitview-accessibility-document (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-accessibility-extras-menu-bar (c-> nssplitview? any/c)]
  [nssplitview-accessibility-filename (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-accessibility-focused-window (c-> nssplitview? any/c)]
  [nssplitview-accessibility-frame (c-> nssplitview? any/c)]
  [nssplitview-accessibility-frame-for-range (c-> nssplitview? any/c any/c)]
  [nssplitview-accessibility-full-screen-button (c-> nssplitview? any/c)]
  [nssplitview-accessibility-grow-area (c-> nssplitview? any/c)]
  [nssplitview-accessibility-handles (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-header (c-> nssplitview? any/c)]
  [nssplitview-accessibility-help (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-accessibility-horizontal-scroll-bar (c-> nssplitview? any/c)]
  [nssplitview-accessibility-horizontal-unit-description (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-accessibility-horizontal-units (c-> nssplitview? exact-integer?)]
  [nssplitview-accessibility-identifier (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-accessibility-increment-button (c-> nssplitview? any/c)]
  [nssplitview-accessibility-index (c-> nssplitview? exact-integer?)]
  [nssplitview-accessibility-insertion-point-line-number (c-> nssplitview? exact-integer?)]
  [nssplitview-accessibility-label (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-accessibility-label-ui-elements (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-label-value (c-> nssplitview? real?)]
  [nssplitview-accessibility-layout-point-for-screen-point (c-> nssplitview? any/c any/c)]
  [nssplitview-accessibility-layout-size-for-screen-size (c-> nssplitview? any/c any/c)]
  [nssplitview-accessibility-line-for-index (c-> nssplitview? exact-integer? exact-integer?)]
  [nssplitview-accessibility-linked-ui-elements (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-main-window (c-> nssplitview? any/c)]
  [nssplitview-accessibility-marker-group-ui-element (c-> nssplitview? any/c)]
  [nssplitview-accessibility-marker-type-description (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-accessibility-marker-ui-elements (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-marker-values (c-> nssplitview? any/c)]
  [nssplitview-accessibility-max-value (c-> nssplitview? any/c)]
  [nssplitview-accessibility-menu-bar (c-> nssplitview? any/c)]
  [nssplitview-accessibility-min-value (c-> nssplitview? any/c)]
  [nssplitview-accessibility-minimize-button (c-> nssplitview? any/c)]
  [nssplitview-accessibility-next-contents (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-number-of-characters (c-> nssplitview? exact-integer?)]
  [nssplitview-accessibility-orientation (c-> nssplitview? exact-integer?)]
  [nssplitview-accessibility-overflow-button (c-> nssplitview? any/c)]
  [nssplitview-accessibility-parent (c-> nssplitview? any/c)]
  [nssplitview-accessibility-perform-cancel (c-> nssplitview? boolean?)]
  [nssplitview-accessibility-perform-confirm (c-> nssplitview? boolean?)]
  [nssplitview-accessibility-perform-decrement (c-> nssplitview? boolean?)]
  [nssplitview-accessibility-perform-delete (c-> nssplitview? boolean?)]
  [nssplitview-accessibility-perform-increment (c-> nssplitview? boolean?)]
  [nssplitview-accessibility-perform-pick (c-> nssplitview? boolean?)]
  [nssplitview-accessibility-perform-press (c-> nssplitview? boolean?)]
  [nssplitview-accessibility-perform-raise (c-> nssplitview? boolean?)]
  [nssplitview-accessibility-perform-show-alternate-ui (c-> nssplitview? boolean?)]
  [nssplitview-accessibility-perform-show-default-ui (c-> nssplitview? boolean?)]
  [nssplitview-accessibility-perform-show-menu (c-> nssplitview? boolean?)]
  [nssplitview-accessibility-placeholder-value (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-accessibility-previous-contents (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-proxy (c-> nssplitview? any/c)]
  [nssplitview-accessibility-rtf-for-range (c-> nssplitview? any/c (or/c nsdata? objc-nil?))]
  [nssplitview-accessibility-range-for-index (c-> nssplitview? exact-integer? any/c)]
  [nssplitview-accessibility-range-for-line (c-> nssplitview? exact-integer? any/c)]
  [nssplitview-accessibility-range-for-position (c-> nssplitview? any/c any/c)]
  [nssplitview-accessibility-role (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-accessibility-role-description (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-accessibility-row-count (c-> nssplitview? exact-integer?)]
  [nssplitview-accessibility-row-header-ui-elements (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-row-index-range (c-> nssplitview? any/c)]
  [nssplitview-accessibility-rows (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-ruler-marker-type (c-> nssplitview? exact-integer?)]
  [nssplitview-accessibility-screen-point-for-layout-point (c-> nssplitview? any/c any/c)]
  [nssplitview-accessibility-screen-size-for-layout-size (c-> nssplitview? any/c any/c)]
  [nssplitview-accessibility-search-button (c-> nssplitview? any/c)]
  [nssplitview-accessibility-search-menu (c-> nssplitview? any/c)]
  [nssplitview-accessibility-selected-cells (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-selected-children (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-selected-columns (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-selected-rows (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-selected-text (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-accessibility-selected-text-range (c-> nssplitview? any/c)]
  [nssplitview-accessibility-selected-text-ranges (c-> nssplitview? any/c)]
  [nssplitview-accessibility-serves-as-title-for-ui-elements (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-shared-character-range (c-> nssplitview? any/c)]
  [nssplitview-accessibility-shared-focus-elements (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-shared-text-ui-elements (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-shown-menu (c-> nssplitview? any/c)]
  [nssplitview-accessibility-sort-direction (c-> nssplitview? exact-integer?)]
  [nssplitview-accessibility-splitters (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-string-for-range (c-> nssplitview? any/c (or/c nsstring? objc-nil?))]
  [nssplitview-accessibility-style-range-for-index (c-> nssplitview? exact-integer? any/c)]
  [nssplitview-accessibility-subrole (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-accessibility-tabs (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-title (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-accessibility-title-ui-element (c-> nssplitview? any/c)]
  [nssplitview-accessibility-toolbar-button (c-> nssplitview? any/c)]
  [nssplitview-accessibility-top-level-ui-element (c-> nssplitview? any/c)]
  [nssplitview-accessibility-url (c-> nssplitview? (or/c nsurl? objc-nil?))]
  [nssplitview-accessibility-unit-description (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-accessibility-units (c-> nssplitview? exact-integer?)]
  [nssplitview-accessibility-user-input-labels (c-> nssplitview? any/c)]
  [nssplitview-accessibility-value (c-> nssplitview? any/c)]
  [nssplitview-accessibility-value-description (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-accessibility-vertical-scroll-bar (c-> nssplitview? any/c)]
  [nssplitview-accessibility-vertical-unit-description (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-accessibility-vertical-units (c-> nssplitview? exact-integer?)]
  [nssplitview-accessibility-visible-cells (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-visible-character-range (c-> nssplitview? any/c)]
  [nssplitview-accessibility-visible-children (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-visible-columns (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-visible-rows (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-warning-value (c-> nssplitview? any/c)]
  [nssplitview-accessibility-window (c-> nssplitview? any/c)]
  [nssplitview-accessibility-windows (c-> nssplitview? (or/c nsarray? objc-nil?))]
  [nssplitview-accessibility-zoom-button (c-> nssplitview? any/c)]
  [nssplitview-add-subview! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-add-subview-positioned-relative-to! (c-> nssplitview? (or/c string? objc-object? #f) exact-integer? (or/c string? objc-object? #f) void?)]
  [nssplitview-add-tool-tip-rect-owner-user-data! (c-> nssplitview? any/c (or/c string? objc-object? #f) (or/c cpointer? #f) exact-integer?)]
  [nssplitview-adjust-scroll (c-> nssplitview? any/c any/c)]
  [nssplitview-adjust-subviews (c-> nssplitview? void?)]
  [nssplitview-ancestor-shared-with-view (c-> nssplitview? (or/c string? objc-object? #f) (or/c nsview? objc-nil?))]
  [nssplitview-animation-for-key (c-> nssplitview? (or/c string? objc-object? #f) any/c)]
  [nssplitview-animations (c-> nssplitview? any/c)]
  [nssplitview-animator (c-> nssplitview? any/c)]
  [nssplitview-appearance (c-> nssplitview? (or/c nsappearance? objc-nil?))]
  [nssplitview-autoscroll (c-> nssplitview? (or/c string? objc-object? #f) boolean?)]
  [nssplitview-backing-aligned-rect-options (c-> nssplitview? any/c exact-nonnegative-integer? any/c)]
  [nssplitview-become-first-responder (c-> nssplitview? boolean?)]
  [nssplitview-begin-gesture-with-event! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-bitmap-image-rep-for-caching-display-in-rect (c-> nssplitview? any/c (or/c nsbitmapimagerep? objc-nil?))]
  [nssplitview-cache-display-in-rect-to-bitmap-image-rep (c-> nssplitview? any/c (or/c string? objc-object? #f) void?)]
  [nssplitview-cancel-operation (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-capitalize-word (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-center-scan-rect! (c-> nssplitview? any/c any/c)]
  [nssplitview-center-selection-in-visible-area! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-change-case-of-letter (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-change-mode-with-event (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-complete (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-conclude-drag-operation (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-context-menu-key-down (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-convert-point-from-view (c-> nssplitview? any/c (or/c string? objc-object? #f) any/c)]
  [nssplitview-convert-point-to-view (c-> nssplitview? any/c (or/c string? objc-object? #f) any/c)]
  [nssplitview-convert-point-from-backing (c-> nssplitview? any/c any/c)]
  [nssplitview-convert-point-from-layer (c-> nssplitview? any/c any/c)]
  [nssplitview-convert-point-to-backing (c-> nssplitview? any/c any/c)]
  [nssplitview-convert-point-to-layer (c-> nssplitview? any/c any/c)]
  [nssplitview-convert-rect-from-view (c-> nssplitview? any/c (or/c string? objc-object? #f) any/c)]
  [nssplitview-convert-rect-to-view (c-> nssplitview? any/c (or/c string? objc-object? #f) any/c)]
  [nssplitview-convert-rect-from-backing (c-> nssplitview? any/c any/c)]
  [nssplitview-convert-rect-from-layer (c-> nssplitview? any/c any/c)]
  [nssplitview-convert-rect-to-backing (c-> nssplitview? any/c any/c)]
  [nssplitview-convert-rect-to-layer (c-> nssplitview? any/c any/c)]
  [nssplitview-convert-size-from-view (c-> nssplitview? any/c (or/c string? objc-object? #f) any/c)]
  [nssplitview-convert-size-to-view (c-> nssplitview? any/c (or/c string? objc-object? #f) any/c)]
  [nssplitview-convert-size-from-backing (c-> nssplitview? any/c any/c)]
  [nssplitview-convert-size-from-layer (c-> nssplitview? any/c any/c)]
  [nssplitview-convert-size-to-backing (c-> nssplitview? any/c any/c)]
  [nssplitview-convert-size-to-layer (c-> nssplitview? any/c any/c)]
  [nssplitview-cursor-update (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-delete-backward (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-delete-backward-by-decomposing-previous-character (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-delete-forward (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-delete-to-beginning-of-line (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-delete-to-beginning-of-paragraph (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-delete-to-end-of-line (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-delete-to-end-of-paragraph (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-delete-to-mark (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-delete-word-backward (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-delete-word-forward (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-did-add-subview (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-did-close-menu-with-event (c-> nssplitview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nssplitview-display! (c-> nssplitview? void?)]
  [nssplitview-display-if-needed! (c-> nssplitview? void?)]
  [nssplitview-display-if-needed-ignoring-opacity! (c-> nssplitview? void?)]
  [nssplitview-display-if-needed-in-rect! (c-> nssplitview? any/c void?)]
  [nssplitview-display-if-needed-in-rect-ignoring-opacity! (c-> nssplitview? any/c void?)]
  [nssplitview-display-rect! (c-> nssplitview? any/c void?)]
  [nssplitview-display-rect-ignoring-opacity! (c-> nssplitview? any/c void?)]
  [nssplitview-display-rect-ignoring-opacity-in-context! (c-> nssplitview? any/c (or/c string? objc-object? #f) void?)]
  [nssplitview-do-command-by-selector (c-> nssplitview? string? void?)]
  [nssplitview-dragging-ended (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-dragging-entered (c-> nssplitview? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nssplitview-dragging-exited (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-dragging-updated (c-> nssplitview? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nssplitview-draw-divider-in-rect (c-> nssplitview? any/c void?)]
  [nssplitview-draw-rect (c-> nssplitview? any/c void?)]
  [nssplitview-effective-appearance (c-> nssplitview? (or/c nsappearance? objc-nil?))]
  [nssplitview-encode-with-coder (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-end-gesture-with-event! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-flags-changed (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-flush-buffered-key-events (c-> nssplitview? void?)]
  [nssplitview-get-rects-being-drawn-count (c-> nssplitview? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nssplitview-get-rects-exposed-during-live-resize-count (c-> nssplitview? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nssplitview-help-requested (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-hit-test (c-> nssplitview? any/c (or/c nsview? objc-nil?))]
  [nssplitview-holding-priority-for-subview-at-index (c-> nssplitview? exact-integer? real?)]
  [nssplitview-identifier (c-> nssplitview? (or/c nsstring? objc-nil?))]
  [nssplitview-indent (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-insert-backtab! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-insert-container-break! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-insert-double-quote-ignoring-substitution! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-insert-line-break! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-insert-newline! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-insert-newline-ignoring-field-editor! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-insert-paragraph-separator! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-insert-single-quote-ignoring-substitution! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-insert-tab! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-insert-tab-ignoring-field-editor! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-insert-text! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-interpret-key-events (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-is-accessibility-alternate-ui-visible (c-> nssplitview? boolean?)]
  [nssplitview-is-accessibility-disclosed (c-> nssplitview? boolean?)]
  [nssplitview-is-accessibility-edited (c-> nssplitview? boolean?)]
  [nssplitview-is-accessibility-element (c-> nssplitview? boolean?)]
  [nssplitview-is-accessibility-enabled (c-> nssplitview? boolean?)]
  [nssplitview-is-accessibility-expanded (c-> nssplitview? boolean?)]
  [nssplitview-is-accessibility-focused (c-> nssplitview? boolean?)]
  [nssplitview-is-accessibility-frontmost (c-> nssplitview? boolean?)]
  [nssplitview-is-accessibility-hidden (c-> nssplitview? boolean?)]
  [nssplitview-is-accessibility-main (c-> nssplitview? boolean?)]
  [nssplitview-is-accessibility-minimized (c-> nssplitview? boolean?)]
  [nssplitview-is-accessibility-modal (c-> nssplitview? boolean?)]
  [nssplitview-is-accessibility-ordered-by-row (c-> nssplitview? boolean?)]
  [nssplitview-is-accessibility-protected-content (c-> nssplitview? boolean?)]
  [nssplitview-is-accessibility-required (c-> nssplitview? boolean?)]
  [nssplitview-is-accessibility-selected (c-> nssplitview? boolean?)]
  [nssplitview-is-accessibility-selector-allowed (c-> nssplitview? string? boolean?)]
  [nssplitview-is-descendant-of (c-> nssplitview? (or/c string? objc-object? #f) boolean?)]
  [nssplitview-is-flipped (c-> nssplitview? boolean?)]
  [nssplitview-is-hidden (c-> nssplitview? boolean?)]
  [nssplitview-is-hidden-or-has-hidden-ancestor (c-> nssplitview? boolean?)]
  [nssplitview-is-opaque (c-> nssplitview? boolean?)]
  [nssplitview-is-rotated-from-base (c-> nssplitview? boolean?)]
  [nssplitview-is-rotated-or-scaled-from-base (c-> nssplitview? boolean?)]
  [nssplitview-is-subview-collapsed (c-> nssplitview? (or/c string? objc-object? #f) boolean?)]
  [nssplitview-is-vertical (c-> nssplitview? boolean?)]
  [nssplitview-key-down (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-key-up (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-layout (c-> nssplitview? void?)]
  [nssplitview-layout-subtree-if-needed (c-> nssplitview? void?)]
  [nssplitview-lowercase-word (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-magnify-with-event (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-make-backing-layer (c-> nssplitview? (or/c calayer? objc-nil?))]
  [nssplitview-make-base-writing-direction-left-to-right (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-make-base-writing-direction-natural (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-make-base-writing-direction-right-to-left (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-make-text-writing-direction-left-to-right (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-make-text-writing-direction-natural (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-make-text-writing-direction-right-to-left (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-max-possible-position-of-divider-at-index (c-> nssplitview? exact-integer? real?)]
  [nssplitview-menu-for-event (c-> nssplitview? (or/c string? objc-object? #f) (or/c nsmenu? objc-nil?))]
  [nssplitview-min-possible-position-of-divider-at-index (c-> nssplitview? exact-integer? real?)]
  [nssplitview-mouse-in-rect (c-> nssplitview? any/c any/c boolean?)]
  [nssplitview-mouse-cancelled (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-mouse-down (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-mouse-dragged (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-mouse-entered (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-mouse-exited (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-mouse-moved (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-mouse-up (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-backward! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-backward-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-down! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-down-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-forward! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-forward-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-left! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-left-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-paragraph-backward-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-paragraph-forward-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-right! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-right-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-to-beginning-of-document! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-to-beginning-of-document-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-to-beginning-of-line! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-to-beginning-of-line-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-to-beginning-of-paragraph! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-to-beginning-of-paragraph-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-to-end-of-document! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-to-end-of-document-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-to-end-of-line! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-to-end-of-line-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-to-end-of-paragraph! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-to-end-of-paragraph-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-to-left-end-of-line! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-to-left-end-of-line-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-to-right-end-of-line! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-to-right-end-of-line-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-up! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-up-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-word-backward! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-word-backward-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-word-forward! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-word-forward-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-word-left! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-word-left-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-word-right! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-move-word-right-and-modify-selection! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-needs-to-draw-rect (c-> nssplitview? any/c boolean?)]
  [nssplitview-no-responder-for (c-> nssplitview? string? void?)]
  [nssplitview-other-mouse-down (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-other-mouse-dragged (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-other-mouse-up (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-page-down (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-page-down-and-modify-selection (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-page-up (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-page-up-and-modify-selection (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-perform-drag-operation! (c-> nssplitview? (or/c string? objc-object? #f) boolean?)]
  [nssplitview-perform-key-equivalent! (c-> nssplitview? (or/c string? objc-object? #f) boolean?)]
  [nssplitview-prepare-content-in-rect (c-> nssplitview? any/c void?)]
  [nssplitview-prepare-for-drag-operation (c-> nssplitview? (or/c string? objc-object? #f) boolean?)]
  [nssplitview-prepare-for-reuse (c-> nssplitview? void?)]
  [nssplitview-pressure-change-with-event (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-quick-look-preview-items (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-quick-look-with-event (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-rect-for-smart-magnification-at-point-in-rect (c-> nssplitview? any/c any/c any/c)]
  [nssplitview-remove-all-tool-tips! (c-> nssplitview? void?)]
  [nssplitview-remove-from-superview! (c-> nssplitview? void?)]
  [nssplitview-remove-from-superview-without-needing-display! (c-> nssplitview? void?)]
  [nssplitview-remove-tool-tip! (c-> nssplitview? exact-integer? void?)]
  [nssplitview-replace-subview-with! (c-> nssplitview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nssplitview-resign-first-responder (c-> nssplitview? boolean?)]
  [nssplitview-resize-subviews-with-old-size (c-> nssplitview? any/c void?)]
  [nssplitview-resize-with-old-superview-size (c-> nssplitview? any/c void?)]
  [nssplitview-restore-user-activity-state (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-right-mouse-down (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-right-mouse-dragged (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-right-mouse-up (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-rotate-by-angle (c-> nssplitview? real? void?)]
  [nssplitview-rotate-with-event (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-scale-unit-square-to-size (c-> nssplitview? any/c void?)]
  [nssplitview-scroll-line-down (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-scroll-line-up (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-scroll-page-down (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-scroll-page-up (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-scroll-point (c-> nssplitview? any/c void?)]
  [nssplitview-scroll-rect-to-visible (c-> nssplitview? any/c boolean?)]
  [nssplitview-scroll-to-beginning-of-document (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-scroll-to-end-of-document (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-scroll-wheel (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-select-all (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-select-line (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-select-paragraph (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-select-to-mark (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-select-word (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-activation-point! (c-> nssplitview? any/c void?)]
  [nssplitview-set-accessibility-allowed-values! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-alternate-ui-visible! (c-> nssplitview? boolean? void?)]
  [nssplitview-set-accessibility-application-focused-ui-element! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-attributed-user-input-labels! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-cancel-button! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-children! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-children-in-navigation-order! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-clear-button! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-close-button! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-column-count! (c-> nssplitview? exact-integer? void?)]
  [nssplitview-set-accessibility-column-header-ui-elements! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-column-index-range! (c-> nssplitview? any/c void?)]
  [nssplitview-set-accessibility-column-titles! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-columns! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-contents! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-critical-value! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-custom-actions! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-custom-rotors! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-decrement-button! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-default-button! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-disclosed! (c-> nssplitview? boolean? void?)]
  [nssplitview-set-accessibility-disclosed-by-row! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-disclosed-rows! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-disclosure-level! (c-> nssplitview? exact-integer? void?)]
  [nssplitview-set-accessibility-document! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-edited! (c-> nssplitview? boolean? void?)]
  [nssplitview-set-accessibility-element! (c-> nssplitview? boolean? void?)]
  [nssplitview-set-accessibility-enabled! (c-> nssplitview? boolean? void?)]
  [nssplitview-set-accessibility-expanded! (c-> nssplitview? boolean? void?)]
  [nssplitview-set-accessibility-extras-menu-bar! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-filename! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-focused! (c-> nssplitview? boolean? void?)]
  [nssplitview-set-accessibility-focused-window! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-frame! (c-> nssplitview? any/c void?)]
  [nssplitview-set-accessibility-frontmost! (c-> nssplitview? boolean? void?)]
  [nssplitview-set-accessibility-full-screen-button! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-grow-area! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-handles! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-header! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-help! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-hidden! (c-> nssplitview? boolean? void?)]
  [nssplitview-set-accessibility-horizontal-scroll-bar! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-horizontal-unit-description! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-horizontal-units! (c-> nssplitview? exact-integer? void?)]
  [nssplitview-set-accessibility-identifier! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-increment-button! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-index! (c-> nssplitview? exact-integer? void?)]
  [nssplitview-set-accessibility-insertion-point-line-number! (c-> nssplitview? exact-integer? void?)]
  [nssplitview-set-accessibility-label! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-label-ui-elements! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-label-value! (c-> nssplitview? real? void?)]
  [nssplitview-set-accessibility-linked-ui-elements! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-main! (c-> nssplitview? boolean? void?)]
  [nssplitview-set-accessibility-main-window! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-marker-group-ui-element! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-marker-type-description! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-marker-ui-elements! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-marker-values! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-max-value! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-menu-bar! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-min-value! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-minimize-button! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-minimized! (c-> nssplitview? boolean? void?)]
  [nssplitview-set-accessibility-modal! (c-> nssplitview? boolean? void?)]
  [nssplitview-set-accessibility-next-contents! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-number-of-characters! (c-> nssplitview? exact-integer? void?)]
  [nssplitview-set-accessibility-ordered-by-row! (c-> nssplitview? boolean? void?)]
  [nssplitview-set-accessibility-orientation! (c-> nssplitview? exact-integer? void?)]
  [nssplitview-set-accessibility-overflow-button! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-parent! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-placeholder-value! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-previous-contents! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-protected-content! (c-> nssplitview? boolean? void?)]
  [nssplitview-set-accessibility-proxy! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-required! (c-> nssplitview? boolean? void?)]
  [nssplitview-set-accessibility-role! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-role-description! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-row-count! (c-> nssplitview? exact-integer? void?)]
  [nssplitview-set-accessibility-row-header-ui-elements! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-row-index-range! (c-> nssplitview? any/c void?)]
  [nssplitview-set-accessibility-rows! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-ruler-marker-type! (c-> nssplitview? exact-integer? void?)]
  [nssplitview-set-accessibility-search-button! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-search-menu! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-selected! (c-> nssplitview? boolean? void?)]
  [nssplitview-set-accessibility-selected-cells! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-selected-children! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-selected-columns! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-selected-rows! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-selected-text! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-selected-text-range! (c-> nssplitview? any/c void?)]
  [nssplitview-set-accessibility-selected-text-ranges! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-serves-as-title-for-ui-elements! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-shared-character-range! (c-> nssplitview? any/c void?)]
  [nssplitview-set-accessibility-shared-focus-elements! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-shared-text-ui-elements! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-shown-menu! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-sort-direction! (c-> nssplitview? exact-integer? void?)]
  [nssplitview-set-accessibility-splitters! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-subrole! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-tabs! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-title! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-title-ui-element! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-toolbar-button! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-top-level-ui-element! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-url! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-unit-description! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-units! (c-> nssplitview? exact-integer? void?)]
  [nssplitview-set-accessibility-user-input-labels! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-value! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-value-description! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-vertical-scroll-bar! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-vertical-unit-description! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-vertical-units! (c-> nssplitview? exact-integer? void?)]
  [nssplitview-set-accessibility-visible-cells! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-visible-character-range! (c-> nssplitview? any/c void?)]
  [nssplitview-set-accessibility-visible-children! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-visible-columns! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-visible-rows! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-warning-value! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-window! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-windows! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-accessibility-zoom-button! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-animations! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-appearance! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-bounds-origin! (c-> nssplitview? any/c void?)]
  [nssplitview-set-bounds-size! (c-> nssplitview? any/c void?)]
  [nssplitview-set-frame-origin! (c-> nssplitview? any/c void?)]
  [nssplitview-set-frame-size! (c-> nssplitview? any/c void?)]
  [nssplitview-set-holding-priority-for-subview-at-index! (c-> nssplitview? real? exact-integer? void?)]
  [nssplitview-set-identifier! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-mark! (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-set-needs-display-in-rect! (c-> nssplitview? any/c void?)]
  [nssplitview-set-position-of-divider-at-index! (c-> nssplitview? real? exact-integer? void?)]
  [nssplitview-should-be-treated-as-ink-event (c-> nssplitview? (or/c string? objc-object? #f) boolean?)]
  [nssplitview-should-delay-window-ordering-for-event (c-> nssplitview? (or/c string? objc-object? #f) boolean?)]
  [nssplitview-show-context-help (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-show-context-menu-for-selection (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-smart-magnify-with-event (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-sort-subviews-using-function-context (c-> nssplitview? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nssplitview-supplemental-target-for-action-sender (c-> nssplitview? string? (or/c string? objc-object? #f) any/c)]
  [nssplitview-swap-with-mark (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-swipe-with-event (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-tablet-point (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-tablet-proximity (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-touches-began-with-event (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-touches-cancelled-with-event (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-touches-ended-with-event (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-touches-moved-with-event (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-translate-origin-to-point (c-> nssplitview? any/c void?)]
  [nssplitview-translate-rects-needing-display-in-rect-by (c-> nssplitview? any/c any/c void?)]
  [nssplitview-transpose (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-transpose-words (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-try-to-perform-with (c-> nssplitview? string? (or/c string? objc-object? #f) boolean?)]
  [nssplitview-update-dragging-items-for-drag (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-update-layer (c-> nssplitview? void?)]
  [nssplitview-uppercase-word (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-valid-requestor-for-send-type-return-type (c-> nssplitview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nssplitview-view-did-change-backing-properties (c-> nssplitview? void?)]
  [nssplitview-view-did-change-effective-appearance (c-> nssplitview? void?)]
  [nssplitview-view-did-end-live-resize (c-> nssplitview? void?)]
  [nssplitview-view-did-hide (c-> nssplitview? void?)]
  [nssplitview-view-did-move-to-superview (c-> nssplitview? void?)]
  [nssplitview-view-did-move-to-window (c-> nssplitview? void?)]
  [nssplitview-view-did-unhide (c-> nssplitview? void?)]
  [nssplitview-view-will-draw (c-> nssplitview? void?)]
  [nssplitview-view-will-move-to-superview (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-view-will-move-to-window (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-view-will-start-live-resize (c-> nssplitview? void?)]
  [nssplitview-view-with-tag (c-> nssplitview? exact-integer? any/c)]
  [nssplitview-wants-forwarded-scroll-events-for-axis (c-> nssplitview? exact-integer? boolean?)]
  [nssplitview-wants-periodic-dragging-updates (c-> nssplitview? boolean?)]
  [nssplitview-wants-scroll-events-for-swipe-tracking-on-axis (c-> nssplitview? exact-integer? boolean?)]
  [nssplitview-will-open-menu-with-event (c-> nssplitview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nssplitview-will-remove-subview (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-yank (c-> nssplitview? (or/c string? objc-object? #f) void?)]
  [nssplitview-default-animation-for-key (c-> (or/c string? objc-object? #f) any/c)]
  [nssplitview-is-compatible-with-responsive-scrolling (c-> boolean?)]
  )

;; --- Class reference ---
(import-class NSSplitView)

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
(define _msg-6  ; (_fun _pointer _pointer -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _int64)))
(define _msg-7  ; (_fun _pointer _pointer -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _uint64)))
(define _msg-8  ; (_fun _pointer _pointer _NSEdgeInsets -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSEdgeInsets -> _void)))
(define _msg-9  ; (_fun _pointer _pointer _NSPoint -> _NSPoint)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _NSPoint)))
(define _msg-10  ; (_fun _pointer _pointer _NSPoint -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _NSRange)))
(define _msg-11  ; (_fun _pointer _pointer _NSPoint -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _id)))
(define _msg-12  ; (_fun _pointer _pointer _NSPoint -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _void)))
(define _msg-13  ; (_fun _pointer _pointer _NSPoint _NSRect -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint _NSRect -> _NSRect)))
(define _msg-14  ; (_fun _pointer _pointer _NSPoint _NSRect -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint _NSRect -> _bool)))
(define _msg-15  ; (_fun _pointer _pointer _NSPoint _id -> _NSPoint)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint _id -> _NSPoint)))
(define _msg-16  ; (_fun _pointer _pointer _NSRange -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _NSRect)))
(define _msg-17  ; (_fun _pointer _pointer _NSRange -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _id)))
(define _msg-18  ; (_fun _pointer _pointer _NSRange -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _void)))
(define _msg-19  ; (_fun _pointer _pointer _NSRect -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _NSRect)))
(define _msg-20  ; (_fun _pointer _pointer _NSRect -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _bool)))
(define _msg-21  ; (_fun _pointer _pointer _NSRect -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _id)))
(define _msg-22  ; (_fun _pointer _pointer _NSRect -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _void)))
(define _msg-23  ; (_fun _pointer _pointer _NSRect _NSSize -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _NSSize -> _void)))
(define _msg-24  ; (_fun _pointer _pointer _NSRect _id -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id -> _NSRect)))
(define _msg-25  ; (_fun _pointer _pointer _NSRect _id -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id -> _void)))
(define _msg-26  ; (_fun _pointer _pointer _NSRect _id _pointer -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id _pointer -> _int64)))
(define _msg-27  ; (_fun _pointer _pointer _NSRect _uint64 -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _uint64 -> _NSRect)))
(define _msg-28  ; (_fun _pointer _pointer _NSSize -> _NSSize)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize -> _NSSize)))
(define _msg-29  ; (_fun _pointer _pointer _NSSize -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize -> _void)))
(define _msg-30  ; (_fun _pointer _pointer _NSSize _id -> _NSSize)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize _id -> _NSSize)))
(define _msg-31  ; (_fun _pointer _pointer _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _bool -> _void)))
(define _msg-32  ; (_fun _pointer _pointer _double -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double -> _void)))
(define _msg-33  ; (_fun _pointer _pointer _double _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double _int64 -> _void)))
(define _msg-34  ; (_fun _pointer _pointer _float -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _float -> _void)))
(define _msg-35  ; (_fun _pointer _pointer _float _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _float _int64 -> _void)))
(define _msg-36  ; (_fun _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _bool)))
(define _msg-37  ; (_fun _pointer _pointer _id -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _uint64)))
(define _msg-38  ; (_fun _pointer _pointer _id _int64 _id -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _int64 _id -> _void)))
(define _msg-39  ; (_fun _pointer _pointer _int64 -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _NSRange)))
(define _msg-40  ; (_fun _pointer _pointer _int64 -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _bool)))
(define _msg-41  ; (_fun _pointer _pointer _int64 -> _double)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _double)))
(define _msg-42  ; (_fun _pointer _pointer _int64 -> _float)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _float)))
(define _msg-43  ; (_fun _pointer _pointer _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _id)))
(define _msg-44  ; (_fun _pointer _pointer _int64 -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _int64)))
(define _msg-45  ; (_fun _pointer _pointer _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _void)))
(define _msg-46  ; (_fun _pointer _pointer _int64 _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _int64 -> _id)))
(define _msg-47  ; (_fun _pointer _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _bool)))
(define _msg-48  ; (_fun _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _void)))
(define _msg-49  ; (_fun _pointer _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _bool)))
(define _msg-50  ; (_fun _pointer _pointer _pointer _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _id)))
(define _msg-51  ; (_fun _pointer _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _pointer -> _void)))
(define _msg-52  ; (_fun _pointer _pointer _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _void)))

;; --- Constructors ---
(define (make-nssplitview-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSSplitView alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nssplitview-init-with-frame frame-rect)
  (wrap-objc-object
   (_msg-21 (tell NSSplitView alloc)
       (sel_registerName "initWithFrame:")
       frame-rect)
   #:retained #t))


;; --- Properties ---
(define (nssplitview-accepts-first-responder self)
  (tell #:type _bool (coerce-arg self) acceptsFirstResponder))
(define (nssplitview-accepts-touch-events self)
  (tell #:type _bool (coerce-arg self) acceptsTouchEvents))
(define (nssplitview-set-accepts-touch-events! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setAcceptsTouchEvents:") value))
(define (nssplitview-additional-safe-area-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) additionalSafeAreaInsets))
(define (nssplitview-set-additional-safe-area-insets! self value)
  (_msg-8 (coerce-arg self) (sel_registerName "setAdditionalSafeAreaInsets:") value))
(define (nssplitview-alignment-rect-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) alignmentRectInsets))
(define (nssplitview-allowed-touch-types self)
  (tell #:type _uint64 (coerce-arg self) allowedTouchTypes))
(define (nssplitview-set-allowed-touch-types! self value)
  (_msg-52 (coerce-arg self) (sel_registerName "setAllowedTouchTypes:") value))
(define (nssplitview-allows-vibrancy self)
  (tell #:type _bool (coerce-arg self) allowsVibrancy))
(define (nssplitview-alpha-value self)
  (tell #:type _double (coerce-arg self) alphaValue))
(define (nssplitview-set-alpha-value! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setAlphaValue:") value))
(define (nssplitview-arranged-subviews self)
  (wrap-objc-object
   (tell (coerce-arg self) arrangedSubviews)))
(define (nssplitview-arranges-all-subviews self)
  (tell #:type _bool (coerce-arg self) arrangesAllSubviews))
(define (nssplitview-set-arranges-all-subviews! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setArrangesAllSubviews:") value))
(define (nssplitview-autoresizes-subviews self)
  (tell #:type _bool (coerce-arg self) autoresizesSubviews))
(define (nssplitview-set-autoresizes-subviews! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setAutoresizesSubviews:") value))
(define (nssplitview-autoresizing-mask self)
  (tell #:type _uint64 (coerce-arg self) autoresizingMask))
(define (nssplitview-set-autoresizing-mask! self value)
  (_msg-52 (coerce-arg self) (sel_registerName "setAutoresizingMask:") value))
(define (nssplitview-autosave-name self)
  (wrap-objc-object
   (tell (coerce-arg self) autosaveName)))
(define (nssplitview-set-autosave-name! self value)
  (tell #:type _void (coerce-arg self) setAutosaveName: (coerce-arg value)))
(define (nssplitview-background-filters self)
  (wrap-objc-object
   (tell (coerce-arg self) backgroundFilters)))
(define (nssplitview-set-background-filters! self value)
  (tell #:type _void (coerce-arg self) setBackgroundFilters: (coerce-arg value)))
(define (nssplitview-baseline-offset-from-bottom self)
  (tell #:type _double (coerce-arg self) baselineOffsetFromBottom))
(define (nssplitview-bottom-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) bottomAnchor)))
(define (nssplitview-bounds self)
  (tell #:type _NSRect (coerce-arg self) bounds))
(define (nssplitview-set-bounds! self value)
  (_msg-22 (coerce-arg self) (sel_registerName "setBounds:") value))
(define (nssplitview-bounds-rotation self)
  (tell #:type _double (coerce-arg self) boundsRotation))
(define (nssplitview-set-bounds-rotation! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setBoundsRotation:") value))
(define (nssplitview-can-become-key-view self)
  (tell #:type _bool (coerce-arg self) canBecomeKeyView))
(define (nssplitview-can-draw self)
  (tell #:type _bool (coerce-arg self) canDraw))
(define (nssplitview-can-draw-concurrently self)
  (tell #:type _bool (coerce-arg self) canDrawConcurrently))
(define (nssplitview-set-can-draw-concurrently! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setCanDrawConcurrently:") value))
(define (nssplitview-can-draw-subviews-into-layer self)
  (tell #:type _bool (coerce-arg self) canDrawSubviewsIntoLayer))
(define (nssplitview-set-can-draw-subviews-into-layer! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setCanDrawSubviewsIntoLayer:") value))
(define (nssplitview-candidate-list-touch-bar-item self)
  (wrap-objc-object
   (tell (coerce-arg self) candidateListTouchBarItem)))
(define (nssplitview-center-x-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) centerXAnchor)))
(define (nssplitview-center-y-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) centerYAnchor)))
(define (nssplitview-clips-to-bounds self)
  (tell #:type _bool (coerce-arg self) clipsToBounds))
(define (nssplitview-set-clips-to-bounds! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setClipsToBounds:") value))
(define (nssplitview-compatible-with-responsive-scrolling)
  (tell #:type _bool NSSplitView compatibleWithResponsiveScrolling))
(define (nssplitview-compositing-filter self)
  (wrap-objc-object
   (tell (coerce-arg self) compositingFilter)))
(define (nssplitview-set-compositing-filter! self value)
  (tell #:type _void (coerce-arg self) setCompositingFilter: (coerce-arg value)))
(define (nssplitview-constraints self)
  (wrap-objc-object
   (tell (coerce-arg self) constraints)))
(define (nssplitview-content-filters self)
  (wrap-objc-object
   (tell (coerce-arg self) contentFilters)))
(define (nssplitview-set-content-filters! self value)
  (tell #:type _void (coerce-arg self) setContentFilters: (coerce-arg value)))
(define (nssplitview-default-focus-ring-type)
  (tell #:type _uint64 NSSplitView defaultFocusRingType))
(define (nssplitview-default-menu)
  (wrap-objc-object
   (tell NSSplitView defaultMenu)))
(define (nssplitview-delegate self)
  (wrap-objc-object
   (tell (coerce-arg self) delegate)))
(define (nssplitview-set-delegate! self value)
  (tell #:type _void (coerce-arg self) setDelegate: (coerce-arg value)))
(define (nssplitview-divider-color self)
  (wrap-objc-object
   (tell (coerce-arg self) dividerColor)))
(define (nssplitview-divider-style self)
  (tell #:type _int64 (coerce-arg self) dividerStyle))
(define (nssplitview-set-divider-style! self value)
  (_msg-45 (coerce-arg self) (sel_registerName "setDividerStyle:") value))
(define (nssplitview-divider-thickness self)
  (tell #:type _double (coerce-arg self) dividerThickness))
(define (nssplitview-drawing-find-indicator self)
  (tell #:type _bool (coerce-arg self) drawingFindIndicator))
(define (nssplitview-enclosing-menu-item self)
  (wrap-objc-object
   (tell (coerce-arg self) enclosingMenuItem)))
(define (nssplitview-enclosing-scroll-view self)
  (wrap-objc-object
   (tell (coerce-arg self) enclosingScrollView)))
(define (nssplitview-first-baseline-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) firstBaselineAnchor)))
(define (nssplitview-first-baseline-offset-from-top self)
  (tell #:type _double (coerce-arg self) firstBaselineOffsetFromTop))
(define (nssplitview-fitting-size self)
  (tell #:type _NSSize (coerce-arg self) fittingSize))
(define (nssplitview-flipped self)
  (tell #:type _bool (coerce-arg self) flipped))
(define (nssplitview-focus-ring-mask-bounds self)
  (tell #:type _NSRect (coerce-arg self) focusRingMaskBounds))
(define (nssplitview-focus-ring-type self)
  (tell #:type _uint64 (coerce-arg self) focusRingType))
(define (nssplitview-set-focus-ring-type! self value)
  (_msg-52 (coerce-arg self) (sel_registerName "setFocusRingType:") value))
(define (nssplitview-focus-view)
  (wrap-objc-object
   (tell NSSplitView focusView)))
(define (nssplitview-frame self)
  (tell #:type _NSRect (coerce-arg self) frame))
(define (nssplitview-set-frame! self value)
  (_msg-22 (coerce-arg self) (sel_registerName "setFrame:") value))
(define (nssplitview-frame-center-rotation self)
  (tell #:type _double (coerce-arg self) frameCenterRotation))
(define (nssplitview-set-frame-center-rotation! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setFrameCenterRotation:") value))
(define (nssplitview-frame-rotation self)
  (tell #:type _double (coerce-arg self) frameRotation))
(define (nssplitview-set-frame-rotation! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setFrameRotation:") value))
(define (nssplitview-gesture-recognizers self)
  (wrap-objc-object
   (tell (coerce-arg self) gestureRecognizers)))
(define (nssplitview-set-gesture-recognizers! self value)
  (tell #:type _void (coerce-arg self) setGestureRecognizers: (coerce-arg value)))
(define (nssplitview-has-ambiguous-layout self)
  (tell #:type _bool (coerce-arg self) hasAmbiguousLayout))
(define (nssplitview-height-adjust-limit self)
  (tell #:type _double (coerce-arg self) heightAdjustLimit))
(define (nssplitview-height-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) heightAnchor)))
(define (nssplitview-hidden self)
  (tell #:type _bool (coerce-arg self) hidden))
(define (nssplitview-set-hidden! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setHidden:") value))
(define (nssplitview-hidden-or-has-hidden-ancestor self)
  (tell #:type _bool (coerce-arg self) hiddenOrHasHiddenAncestor))
(define (nssplitview-horizontal-content-size-constraint-active self)
  (tell #:type _bool (coerce-arg self) horizontalContentSizeConstraintActive))
(define (nssplitview-set-horizontal-content-size-constraint-active! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setHorizontalContentSizeConstraintActive:") value))
(define (nssplitview-in-full-screen-mode self)
  (tell #:type _bool (coerce-arg self) inFullScreenMode))
(define (nssplitview-in-live-resize self)
  (tell #:type _bool (coerce-arg self) inLiveResize))
(define (nssplitview-input-context self)
  (wrap-objc-object
   (tell (coerce-arg self) inputContext)))
(define (nssplitview-intrinsic-content-size self)
  (tell #:type _NSSize (coerce-arg self) intrinsicContentSize))
(define (nssplitview-last-baseline-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) lastBaselineAnchor)))
(define (nssplitview-last-baseline-offset-from-bottom self)
  (tell #:type _double (coerce-arg self) lastBaselineOffsetFromBottom))
(define (nssplitview-layer self)
  (wrap-objc-object
   (tell (coerce-arg self) layer)))
(define (nssplitview-set-layer! self value)
  (tell #:type _void (coerce-arg self) setLayer: (coerce-arg value)))
(define (nssplitview-layer-contents-placement self)
  (tell #:type _int64 (coerce-arg self) layerContentsPlacement))
(define (nssplitview-set-layer-contents-placement! self value)
  (_msg-45 (coerce-arg self) (sel_registerName "setLayerContentsPlacement:") value))
(define (nssplitview-layer-contents-redraw-policy self)
  (tell #:type _int64 (coerce-arg self) layerContentsRedrawPolicy))
(define (nssplitview-set-layer-contents-redraw-policy! self value)
  (_msg-45 (coerce-arg self) (sel_registerName "setLayerContentsRedrawPolicy:") value))
(define (nssplitview-layer-uses-core-image-filters self)
  (tell #:type _bool (coerce-arg self) layerUsesCoreImageFilters))
(define (nssplitview-set-layer-uses-core-image-filters! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setLayerUsesCoreImageFilters:") value))
(define (nssplitview-layout-guides self)
  (wrap-objc-object
   (tell (coerce-arg self) layoutGuides)))
(define (nssplitview-layout-margins-guide self)
  (wrap-objc-object
   (tell (coerce-arg self) layoutMarginsGuide)))
(define (nssplitview-leading-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) leadingAnchor)))
(define (nssplitview-left-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) leftAnchor)))
(define (nssplitview-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) menu)))
(define (nssplitview-set-menu! self value)
  (tell #:type _void (coerce-arg self) setMenu: (coerce-arg value)))
(define (nssplitview-mouse-down-can-move-window self)
  (tell #:type _bool (coerce-arg self) mouseDownCanMoveWindow))
(define (nssplitview-needs-display self)
  (tell #:type _bool (coerce-arg self) needsDisplay))
(define (nssplitview-set-needs-display! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setNeedsDisplay:") value))
(define (nssplitview-needs-layout self)
  (tell #:type _bool (coerce-arg self) needsLayout))
(define (nssplitview-set-needs-layout! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setNeedsLayout:") value))
(define (nssplitview-needs-panel-to-become-key self)
  (tell #:type _bool (coerce-arg self) needsPanelToBecomeKey))
(define (nssplitview-needs-update-constraints self)
  (tell #:type _bool (coerce-arg self) needsUpdateConstraints))
(define (nssplitview-set-needs-update-constraints! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setNeedsUpdateConstraints:") value))
(define (nssplitview-next-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) nextKeyView)))
(define (nssplitview-set-next-key-view! self value)
  (tell #:type _void (coerce-arg self) setNextKeyView: (coerce-arg value)))
(define (nssplitview-next-responder self)
  (wrap-objc-object
   (tell (coerce-arg self) nextResponder)))
(define (nssplitview-set-next-responder! self value)
  (tell #:type _void (coerce-arg self) setNextResponder: (coerce-arg value)))
(define (nssplitview-next-valid-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) nextValidKeyView)))
(define (nssplitview-opaque self)
  (tell #:type _bool (coerce-arg self) opaque))
(define (nssplitview-opaque-ancestor self)
  (wrap-objc-object
   (tell (coerce-arg self) opaqueAncestor)))
(define (nssplitview-page-footer self)
  (wrap-objc-object
   (tell (coerce-arg self) pageFooter)))
(define (nssplitview-page-header self)
  (wrap-objc-object
   (tell (coerce-arg self) pageHeader)))
(define (nssplitview-posts-bounds-changed-notifications self)
  (tell #:type _bool (coerce-arg self) postsBoundsChangedNotifications))
(define (nssplitview-set-posts-bounds-changed-notifications! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setPostsBoundsChangedNotifications:") value))
(define (nssplitview-posts-frame-changed-notifications self)
  (tell #:type _bool (coerce-arg self) postsFrameChangedNotifications))
(define (nssplitview-set-posts-frame-changed-notifications! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setPostsFrameChangedNotifications:") value))
(define (nssplitview-prefers-compact-control-size-metrics self)
  (tell #:type _bool (coerce-arg self) prefersCompactControlSizeMetrics))
(define (nssplitview-set-prefers-compact-control-size-metrics! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setPrefersCompactControlSizeMetrics:") value))
(define (nssplitview-prepared-content-rect self)
  (tell #:type _NSRect (coerce-arg self) preparedContentRect))
(define (nssplitview-set-prepared-content-rect! self value)
  (_msg-22 (coerce-arg self) (sel_registerName "setPreparedContentRect:") value))
(define (nssplitview-preserves-content-during-live-resize self)
  (tell #:type _bool (coerce-arg self) preservesContentDuringLiveResize))
(define (nssplitview-pressure-configuration self)
  (wrap-objc-object
   (tell (coerce-arg self) pressureConfiguration)))
(define (nssplitview-set-pressure-configuration! self value)
  (tell #:type _void (coerce-arg self) setPressureConfiguration: (coerce-arg value)))
(define (nssplitview-previous-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) previousKeyView)))
(define (nssplitview-previous-valid-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) previousValidKeyView)))
(define (nssplitview-print-job-title self)
  (wrap-objc-object
   (tell (coerce-arg self) printJobTitle)))
(define (nssplitview-rect-preserved-during-live-resize self)
  (tell #:type _NSRect (coerce-arg self) rectPreservedDuringLiveResize))
(define (nssplitview-registered-dragged-types self)
  (wrap-objc-object
   (tell (coerce-arg self) registeredDraggedTypes)))
(define (nssplitview-requires-constraint-based-layout)
  (tell #:type _bool NSSplitView requiresConstraintBasedLayout))
(define (nssplitview-restorable-state-key-paths)
  (wrap-objc-object
   (tell NSSplitView restorableStateKeyPaths)))
(define (nssplitview-right-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) rightAnchor)))
(define (nssplitview-rotated-from-base self)
  (tell #:type _bool (coerce-arg self) rotatedFromBase))
(define (nssplitview-rotated-or-scaled-from-base self)
  (tell #:type _bool (coerce-arg self) rotatedOrScaledFromBase))
(define (nssplitview-safe-area-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) safeAreaInsets))
(define (nssplitview-safe-area-layout-guide self)
  (wrap-objc-object
   (tell (coerce-arg self) safeAreaLayoutGuide)))
(define (nssplitview-safe-area-rect self)
  (tell #:type _NSRect (coerce-arg self) safeAreaRect))
(define (nssplitview-shadow self)
  (wrap-objc-object
   (tell (coerce-arg self) shadow)))
(define (nssplitview-set-shadow! self value)
  (tell #:type _void (coerce-arg self) setShadow: (coerce-arg value)))
(define (nssplitview-subviews self)
  (wrap-objc-object
   (tell (coerce-arg self) subviews)))
(define (nssplitview-set-subviews! self value)
  (tell #:type _void (coerce-arg self) setSubviews: (coerce-arg value)))
(define (nssplitview-superview self)
  (wrap-objc-object
   (tell (coerce-arg self) superview)))
(define (nssplitview-tag self)
  (tell #:type _int64 (coerce-arg self) tag))
(define (nssplitview-tool-tip self)
  (wrap-objc-object
   (tell (coerce-arg self) toolTip)))
(define (nssplitview-set-tool-tip! self value)
  (tell #:type _void (coerce-arg self) setToolTip: (coerce-arg value)))
(define (nssplitview-top-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) topAnchor)))
(define (nssplitview-touch-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) touchBar)))
(define (nssplitview-set-touch-bar! self value)
  (tell #:type _void (coerce-arg self) setTouchBar: (coerce-arg value)))
(define (nssplitview-tracking-areas self)
  (wrap-objc-object
   (tell (coerce-arg self) trackingAreas)))
(define (nssplitview-trailing-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) trailingAnchor)))
(define (nssplitview-translates-autoresizing-mask-into-constraints self)
  (tell #:type _bool (coerce-arg self) translatesAutoresizingMaskIntoConstraints))
(define (nssplitview-set-translates-autoresizing-mask-into-constraints! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setTranslatesAutoresizingMaskIntoConstraints:") value))
(define (nssplitview-undo-manager self)
  (wrap-objc-object
   (tell (coerce-arg self) undoManager)))
(define (nssplitview-user-activity self)
  (wrap-objc-object
   (tell (coerce-arg self) userActivity)))
(define (nssplitview-set-user-activity! self value)
  (tell #:type _void (coerce-arg self) setUserActivity: (coerce-arg value)))
(define (nssplitview-user-interface-layout-direction self)
  (tell #:type _int64 (coerce-arg self) userInterfaceLayoutDirection))
(define (nssplitview-set-user-interface-layout-direction! self value)
  (_msg-45 (coerce-arg self) (sel_registerName "setUserInterfaceLayoutDirection:") value))
(define (nssplitview-vertical self)
  (tell #:type _bool (coerce-arg self) vertical))
(define (nssplitview-set-vertical! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setVertical:") value))
(define (nssplitview-vertical-content-size-constraint-active self)
  (tell #:type _bool (coerce-arg self) verticalContentSizeConstraintActive))
(define (nssplitview-set-vertical-content-size-constraint-active! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setVerticalContentSizeConstraintActive:") value))
(define (nssplitview-visible-rect self)
  (tell #:type _NSRect (coerce-arg self) visibleRect))
(define (nssplitview-wants-best-resolution-open-gl-surface self)
  (tell #:type _bool (coerce-arg self) wantsBestResolutionOpenGLSurface))
(define (nssplitview-set-wants-best-resolution-open-gl-surface! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setWantsBestResolutionOpenGLSurface:") value))
(define (nssplitview-wants-default-clipping self)
  (tell #:type _bool (coerce-arg self) wantsDefaultClipping))
(define (nssplitview-wants-extended-dynamic-range-open-gl-surface self)
  (tell #:type _bool (coerce-arg self) wantsExtendedDynamicRangeOpenGLSurface))
(define (nssplitview-set-wants-extended-dynamic-range-open-gl-surface! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setWantsExtendedDynamicRangeOpenGLSurface:") value))
(define (nssplitview-wants-layer self)
  (tell #:type _bool (coerce-arg self) wantsLayer))
(define (nssplitview-set-wants-layer! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setWantsLayer:") value))
(define (nssplitview-wants-resting-touches self)
  (tell #:type _bool (coerce-arg self) wantsRestingTouches))
(define (nssplitview-set-wants-resting-touches! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setWantsRestingTouches:") value))
(define (nssplitview-wants-update-layer self)
  (tell #:type _bool (coerce-arg self) wantsUpdateLayer))
(define (nssplitview-width-adjust-limit self)
  (tell #:type _double (coerce-arg self) widthAdjustLimit))
(define (nssplitview-width-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) widthAnchor)))
(define (nssplitview-window self)
  (wrap-objc-object
   (tell (coerce-arg self) window)))
(define (nssplitview-writing-tools-coordinator self)
  (wrap-objc-object
   (tell (coerce-arg self) writingToolsCoordinator)))
(define (nssplitview-set-writing-tools-coordinator! self value)
  (tell #:type _void (coerce-arg self) setWritingToolsCoordinator: (coerce-arg value)))

;; --- Instance methods ---
(define (nssplitview-accepts-first-mouse self event)
  (_msg-36 (coerce-arg self) (sel_registerName "acceptsFirstMouse:") (coerce-arg event)))
(define (nssplitview-accessibility-activation-point self)
  (_msg-0 (coerce-arg self) (sel_registerName "accessibilityActivationPoint")))
(define (nssplitview-accessibility-allowed-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAllowedValues)))
(define (nssplitview-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityApplicationFocusedUIElement)))
(define (nssplitview-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (_msg-17 (coerce-arg self) (sel_registerName "accessibilityAttributedStringForRange:") range)
   ))
(define (nssplitview-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAttributedUserInputLabels)))
(define (nssplitview-accessibility-cancel-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCancelButton)))
(define (nssplitview-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (_msg-46 (coerce-arg self) (sel_registerName "accessibilityCellForColumn:row:") column row)
   ))
(define (nssplitview-accessibility-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildren)))
(define (nssplitview-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildrenInNavigationOrder)))
(define (nssplitview-accessibility-clear-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityClearButton)))
(define (nssplitview-accessibility-close-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCloseButton)))
(define (nssplitview-accessibility-column-count self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityColumnCount")))
(define (nssplitview-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnHeaderUIElements)))
(define (nssplitview-accessibility-column-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityColumnIndexRange")))
(define (nssplitview-accessibility-column-titles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnTitles)))
(define (nssplitview-accessibility-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumns)))
(define (nssplitview-accessibility-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityContents)))
(define (nssplitview-accessibility-critical-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCriticalValue)))
(define (nssplitview-accessibility-custom-actions self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomActions)))
(define (nssplitview-accessibility-custom-rotors self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomRotors)))
(define (nssplitview-accessibility-decrement-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDecrementButton)))
(define (nssplitview-accessibility-default-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDefaultButton)))
(define (nssplitview-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedByRow)))
(define (nssplitview-accessibility-disclosed-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedRows)))
(define (nssplitview-accessibility-disclosure-level self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityDisclosureLevel")))
(define (nssplitview-accessibility-document self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDocument)))
(define (nssplitview-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityExtrasMenuBar)))
(define (nssplitview-accessibility-filename self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFilename)))
(define (nssplitview-accessibility-focused-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFocusedWindow)))
(define (nssplitview-accessibility-frame self)
  (_msg-2 (coerce-arg self) (sel_registerName "accessibilityFrame")))
(define (nssplitview-accessibility-frame-for-range self range)
  (_msg-16 (coerce-arg self) (sel_registerName "accessibilityFrameForRange:") range))
(define (nssplitview-accessibility-full-screen-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFullScreenButton)))
(define (nssplitview-accessibility-grow-area self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityGrowArea)))
(define (nssplitview-accessibility-handles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHandles)))
(define (nssplitview-accessibility-header self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHeader)))
(define (nssplitview-accessibility-help self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHelp)))
(define (nssplitview-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalScrollBar)))
(define (nssplitview-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalUnitDescription)))
(define (nssplitview-accessibility-horizontal-units self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityHorizontalUnits")))
(define (nssplitview-accessibility-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIdentifier)))
(define (nssplitview-accessibility-increment-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIncrementButton)))
(define (nssplitview-accessibility-index self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityIndex")))
(define (nssplitview-accessibility-insertion-point-line-number self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityInsertionPointLineNumber")))
(define (nssplitview-accessibility-label self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabel)))
(define (nssplitview-accessibility-label-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabelUIElements)))
(define (nssplitview-accessibility-label-value self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityLabelValue")))
(define (nssplitview-accessibility-layout-point-for-screen-point self point)
  (_msg-9 (coerce-arg self) (sel_registerName "accessibilityLayoutPointForScreenPoint:") point))
(define (nssplitview-accessibility-layout-size-for-screen-size self size)
  (_msg-28 (coerce-arg self) (sel_registerName "accessibilityLayoutSizeForScreenSize:") size))
(define (nssplitview-accessibility-line-for-index self index)
  (_msg-44 (coerce-arg self) (sel_registerName "accessibilityLineForIndex:") index))
(define (nssplitview-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLinkedUIElements)))
(define (nssplitview-accessibility-main-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMainWindow)))
(define (nssplitview-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerGroupUIElement)))
(define (nssplitview-accessibility-marker-type-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerTypeDescription)))
(define (nssplitview-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerUIElements)))
(define (nssplitview-accessibility-marker-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerValues)))
(define (nssplitview-accessibility-max-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMaxValue)))
(define (nssplitview-accessibility-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMenuBar)))
(define (nssplitview-accessibility-min-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinValue)))
(define (nssplitview-accessibility-minimize-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinimizeButton)))
(define (nssplitview-accessibility-next-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityNextContents)))
(define (nssplitview-accessibility-number-of-characters self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityNumberOfCharacters")))
(define (nssplitview-accessibility-orientation self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityOrientation")))
(define (nssplitview-accessibility-overflow-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityOverflowButton)))
(define (nssplitview-accessibility-parent self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityParent)))
(define (nssplitview-accessibility-perform-cancel self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformCancel")))
(define (nssplitview-accessibility-perform-confirm self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformConfirm")))
(define (nssplitview-accessibility-perform-decrement self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformDecrement")))
(define (nssplitview-accessibility-perform-delete self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformDelete")))
(define (nssplitview-accessibility-perform-increment self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformIncrement")))
(define (nssplitview-accessibility-perform-pick self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformPick")))
(define (nssplitview-accessibility-perform-press self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformPress")))
(define (nssplitview-accessibility-perform-raise self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformRaise")))
(define (nssplitview-accessibility-perform-show-alternate-ui self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowAlternateUI")))
(define (nssplitview-accessibility-perform-show-default-ui self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowDefaultUI")))
(define (nssplitview-accessibility-perform-show-menu self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowMenu")))
(define (nssplitview-accessibility-placeholder-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPlaceholderValue)))
(define (nssplitview-accessibility-previous-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPreviousContents)))
(define (nssplitview-accessibility-proxy self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityProxy)))
(define (nssplitview-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (_msg-17 (coerce-arg self) (sel_registerName "accessibilityRTFForRange:") range)
   ))
(define (nssplitview-accessibility-range-for-index self index)
  (_msg-39 (coerce-arg self) (sel_registerName "accessibilityRangeForIndex:") index))
(define (nssplitview-accessibility-range-for-line self line)
  (_msg-39 (coerce-arg self) (sel_registerName "accessibilityRangeForLine:") line))
(define (nssplitview-accessibility-range-for-position self point)
  (_msg-10 (coerce-arg self) (sel_registerName "accessibilityRangeForPosition:") point))
(define (nssplitview-accessibility-role self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRole)))
(define (nssplitview-accessibility-role-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRoleDescription)))
(define (nssplitview-accessibility-row-count self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityRowCount")))
(define (nssplitview-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRowHeaderUIElements)))
(define (nssplitview-accessibility-row-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityRowIndexRange")))
(define (nssplitview-accessibility-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRows)))
(define (nssplitview-accessibility-ruler-marker-type self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityRulerMarkerType")))
(define (nssplitview-accessibility-screen-point-for-layout-point self point)
  (_msg-9 (coerce-arg self) (sel_registerName "accessibilityScreenPointForLayoutPoint:") point))
(define (nssplitview-accessibility-screen-size-for-layout-size self size)
  (_msg-28 (coerce-arg self) (sel_registerName "accessibilityScreenSizeForLayoutSize:") size))
(define (nssplitview-accessibility-search-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchButton)))
(define (nssplitview-accessibility-search-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchMenu)))
(define (nssplitview-accessibility-selected-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedCells)))
(define (nssplitview-accessibility-selected-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedChildren)))
(define (nssplitview-accessibility-selected-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedColumns)))
(define (nssplitview-accessibility-selected-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedRows)))
(define (nssplitview-accessibility-selected-text self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedText)))
(define (nssplitview-accessibility-selected-text-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySelectedTextRange")))
(define (nssplitview-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedTextRanges)))
(define (nssplitview-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityServesAsTitleForUIElements)))
(define (nssplitview-accessibility-shared-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySharedCharacterRange")))
(define (nssplitview-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedFocusElements)))
(define (nssplitview-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedTextUIElements)))
(define (nssplitview-accessibility-shown-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityShownMenu)))
(define (nssplitview-accessibility-sort-direction self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilitySortDirection")))
(define (nssplitview-accessibility-splitters self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySplitters)))
(define (nssplitview-accessibility-string-for-range self range)
  (wrap-objc-object
   (_msg-17 (coerce-arg self) (sel_registerName "accessibilityStringForRange:") range)
   ))
(define (nssplitview-accessibility-style-range-for-index self index)
  (_msg-39 (coerce-arg self) (sel_registerName "accessibilityStyleRangeForIndex:") index))
(define (nssplitview-accessibility-subrole self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySubrole)))
(define (nssplitview-accessibility-tabs self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTabs)))
(define (nssplitview-accessibility-title self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitle)))
(define (nssplitview-accessibility-title-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitleUIElement)))
(define (nssplitview-accessibility-toolbar-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityToolbarButton)))
(define (nssplitview-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTopLevelUIElement)))
(define (nssplitview-accessibility-url self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityURL)))
(define (nssplitview-accessibility-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUnitDescription)))
(define (nssplitview-accessibility-units self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityUnits")))
(define (nssplitview-accessibility-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUserInputLabels)))
(define (nssplitview-accessibility-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValue)))
(define (nssplitview-accessibility-value-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValueDescription)))
(define (nssplitview-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalScrollBar)))
(define (nssplitview-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalUnitDescription)))
(define (nssplitview-accessibility-vertical-units self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityVerticalUnits")))
(define (nssplitview-accessibility-visible-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleCells)))
(define (nssplitview-accessibility-visible-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityVisibleCharacterRange")))
(define (nssplitview-accessibility-visible-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleChildren)))
(define (nssplitview-accessibility-visible-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleColumns)))
(define (nssplitview-accessibility-visible-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleRows)))
(define (nssplitview-accessibility-warning-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWarningValue)))
(define (nssplitview-accessibility-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindow)))
(define (nssplitview-accessibility-windows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindows)))
(define (nssplitview-accessibility-zoom-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityZoomButton)))
(define (nssplitview-add-subview! self view)
  (tell #:type _void (coerce-arg self) addSubview: (coerce-arg view)))
(define (nssplitview-add-subview-positioned-relative-to! self view place other-view)
  (_msg-38 (coerce-arg self) (sel_registerName "addSubview:positioned:relativeTo:") (coerce-arg view) place (coerce-arg other-view)))
(define (nssplitview-add-tool-tip-rect-owner-user-data! self rect owner data)
  (_msg-26 (coerce-arg self) (sel_registerName "addToolTipRect:owner:userData:") rect (coerce-arg owner) data))
(define (nssplitview-adjust-scroll self new-visible)
  (_msg-19 (coerce-arg self) (sel_registerName "adjustScroll:") new-visible))
(define (nssplitview-adjust-subviews self)
  (tell #:type _void (coerce-arg self) adjustSubviews))
(define (nssplitview-ancestor-shared-with-view self view)
  (wrap-objc-object
   (tell (coerce-arg self) ancestorSharedWithView: (coerce-arg view))))
(define (nssplitview-animation-for-key self key)
  (wrap-objc-object
   (tell (coerce-arg self) animationForKey: (coerce-arg key))))
(define (nssplitview-animations self)
  (wrap-objc-object
   (tell (coerce-arg self) animations)))
(define (nssplitview-animator self)
  (wrap-objc-object
   (tell (coerce-arg self) animator)))
(define (nssplitview-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) appearance)))
(define (nssplitview-autoscroll self event)
  (_msg-36 (coerce-arg self) (sel_registerName "autoscroll:") (coerce-arg event)))
(define (nssplitview-backing-aligned-rect-options self rect options)
  (_msg-27 (coerce-arg self) (sel_registerName "backingAlignedRect:options:") rect options))
(define (nssplitview-become-first-responder self)
  (_msg-3 (coerce-arg self) (sel_registerName "becomeFirstResponder")))
(define (nssplitview-begin-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) beginGestureWithEvent: (coerce-arg event)))
(define (nssplitview-bitmap-image-rep-for-caching-display-in-rect self rect)
  (wrap-objc-object
   (_msg-21 (coerce-arg self) (sel_registerName "bitmapImageRepForCachingDisplayInRect:") rect)
   ))
(define (nssplitview-cache-display-in-rect-to-bitmap-image-rep self rect bitmap-image-rep)
  (_msg-25 (coerce-arg self) (sel_registerName "cacheDisplayInRect:toBitmapImageRep:") rect (coerce-arg bitmap-image-rep)))
(define (nssplitview-cancel-operation self sender)
  (tell #:type _void (coerce-arg self) cancelOperation: (coerce-arg sender)))
(define (nssplitview-capitalize-word self sender)
  (tell #:type _void (coerce-arg self) capitalizeWord: (coerce-arg sender)))
(define (nssplitview-center-scan-rect! self rect)
  (_msg-19 (coerce-arg self) (sel_registerName "centerScanRect:") rect))
(define (nssplitview-center-selection-in-visible-area! self sender)
  (tell #:type _void (coerce-arg self) centerSelectionInVisibleArea: (coerce-arg sender)))
(define (nssplitview-change-case-of-letter self sender)
  (tell #:type _void (coerce-arg self) changeCaseOfLetter: (coerce-arg sender)))
(define (nssplitview-change-mode-with-event self event)
  (tell #:type _void (coerce-arg self) changeModeWithEvent: (coerce-arg event)))
(define (nssplitview-complete self sender)
  (tell #:type _void (coerce-arg self) complete: (coerce-arg sender)))
(define (nssplitview-conclude-drag-operation self sender)
  (tell #:type _void (coerce-arg self) concludeDragOperation: (coerce-arg sender)))
(define (nssplitview-context-menu-key-down self event)
  (tell #:type _void (coerce-arg self) contextMenuKeyDown: (coerce-arg event)))
(define (nssplitview-convert-point-from-view self point view)
  (_msg-15 (coerce-arg self) (sel_registerName "convertPoint:fromView:") point (coerce-arg view)))
(define (nssplitview-convert-point-to-view self point view)
  (_msg-15 (coerce-arg self) (sel_registerName "convertPoint:toView:") point (coerce-arg view)))
(define (nssplitview-convert-point-from-backing self point)
  (_msg-9 (coerce-arg self) (sel_registerName "convertPointFromBacking:") point))
(define (nssplitview-convert-point-from-layer self point)
  (_msg-9 (coerce-arg self) (sel_registerName "convertPointFromLayer:") point))
(define (nssplitview-convert-point-to-backing self point)
  (_msg-9 (coerce-arg self) (sel_registerName "convertPointToBacking:") point))
(define (nssplitview-convert-point-to-layer self point)
  (_msg-9 (coerce-arg self) (sel_registerName "convertPointToLayer:") point))
(define (nssplitview-convert-rect-from-view self rect view)
  (_msg-24 (coerce-arg self) (sel_registerName "convertRect:fromView:") rect (coerce-arg view)))
(define (nssplitview-convert-rect-to-view self rect view)
  (_msg-24 (coerce-arg self) (sel_registerName "convertRect:toView:") rect (coerce-arg view)))
(define (nssplitview-convert-rect-from-backing self rect)
  (_msg-19 (coerce-arg self) (sel_registerName "convertRectFromBacking:") rect))
(define (nssplitview-convert-rect-from-layer self rect)
  (_msg-19 (coerce-arg self) (sel_registerName "convertRectFromLayer:") rect))
(define (nssplitview-convert-rect-to-backing self rect)
  (_msg-19 (coerce-arg self) (sel_registerName "convertRectToBacking:") rect))
(define (nssplitview-convert-rect-to-layer self rect)
  (_msg-19 (coerce-arg self) (sel_registerName "convertRectToLayer:") rect))
(define (nssplitview-convert-size-from-view self size view)
  (_msg-30 (coerce-arg self) (sel_registerName "convertSize:fromView:") size (coerce-arg view)))
(define (nssplitview-convert-size-to-view self size view)
  (_msg-30 (coerce-arg self) (sel_registerName "convertSize:toView:") size (coerce-arg view)))
(define (nssplitview-convert-size-from-backing self size)
  (_msg-28 (coerce-arg self) (sel_registerName "convertSizeFromBacking:") size))
(define (nssplitview-convert-size-from-layer self size)
  (_msg-28 (coerce-arg self) (sel_registerName "convertSizeFromLayer:") size))
(define (nssplitview-convert-size-to-backing self size)
  (_msg-28 (coerce-arg self) (sel_registerName "convertSizeToBacking:") size))
(define (nssplitview-convert-size-to-layer self size)
  (_msg-28 (coerce-arg self) (sel_registerName "convertSizeToLayer:") size))
(define (nssplitview-cursor-update self event)
  (tell #:type _void (coerce-arg self) cursorUpdate: (coerce-arg event)))
(define (nssplitview-delete-backward self sender)
  (tell #:type _void (coerce-arg self) deleteBackward: (coerce-arg sender)))
(define (nssplitview-delete-backward-by-decomposing-previous-character self sender)
  (tell #:type _void (coerce-arg self) deleteBackwardByDecomposingPreviousCharacter: (coerce-arg sender)))
(define (nssplitview-delete-forward self sender)
  (tell #:type _void (coerce-arg self) deleteForward: (coerce-arg sender)))
(define (nssplitview-delete-to-beginning-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfLine: (coerce-arg sender)))
(define (nssplitview-delete-to-beginning-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfParagraph: (coerce-arg sender)))
(define (nssplitview-delete-to-end-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfLine: (coerce-arg sender)))
(define (nssplitview-delete-to-end-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfParagraph: (coerce-arg sender)))
(define (nssplitview-delete-to-mark self sender)
  (tell #:type _void (coerce-arg self) deleteToMark: (coerce-arg sender)))
(define (nssplitview-delete-word-backward self sender)
  (tell #:type _void (coerce-arg self) deleteWordBackward: (coerce-arg sender)))
(define (nssplitview-delete-word-forward self sender)
  (tell #:type _void (coerce-arg self) deleteWordForward: (coerce-arg sender)))
(define (nssplitview-did-add-subview self subview)
  (tell #:type _void (coerce-arg self) didAddSubview: (coerce-arg subview)))
(define (nssplitview-did-close-menu-with-event self menu event)
  (tell #:type _void (coerce-arg self) didCloseMenu: (coerce-arg menu) withEvent: (coerce-arg event)))
(define (nssplitview-display! self)
  (tell #:type _void (coerce-arg self) display))
(define (nssplitview-display-if-needed! self)
  (tell #:type _void (coerce-arg self) displayIfNeeded))
(define (nssplitview-display-if-needed-ignoring-opacity! self)
  (tell #:type _void (coerce-arg self) displayIfNeededIgnoringOpacity))
(define (nssplitview-display-if-needed-in-rect! self rect)
  (_msg-22 (coerce-arg self) (sel_registerName "displayIfNeededInRect:") rect))
(define (nssplitview-display-if-needed-in-rect-ignoring-opacity! self rect)
  (_msg-22 (coerce-arg self) (sel_registerName "displayIfNeededInRectIgnoringOpacity:") rect))
(define (nssplitview-display-rect! self rect)
  (_msg-22 (coerce-arg self) (sel_registerName "displayRect:") rect))
(define (nssplitview-display-rect-ignoring-opacity! self rect)
  (_msg-22 (coerce-arg self) (sel_registerName "displayRectIgnoringOpacity:") rect))
(define (nssplitview-display-rect-ignoring-opacity-in-context! self rect context)
  (_msg-25 (coerce-arg self) (sel_registerName "displayRectIgnoringOpacity:inContext:") rect (coerce-arg context)))
(define (nssplitview-do-command-by-selector self selector)
  (_msg-48 (coerce-arg self) (sel_registerName "doCommandBySelector:") (sel_registerName selector)))
(define (nssplitview-dragging-ended self sender)
  (tell #:type _void (coerce-arg self) draggingEnded: (coerce-arg sender)))
(define (nssplitview-dragging-entered self sender)
  (_msg-37 (coerce-arg self) (sel_registerName "draggingEntered:") (coerce-arg sender)))
(define (nssplitview-dragging-exited self sender)
  (tell #:type _void (coerce-arg self) draggingExited: (coerce-arg sender)))
(define (nssplitview-dragging-updated self sender)
  (_msg-37 (coerce-arg self) (sel_registerName "draggingUpdated:") (coerce-arg sender)))
(define (nssplitview-draw-divider-in-rect self rect)
  (_msg-22 (coerce-arg self) (sel_registerName "drawDividerInRect:") rect))
(define (nssplitview-draw-rect self dirty-rect)
  (_msg-22 (coerce-arg self) (sel_registerName "drawRect:") dirty-rect))
(define (nssplitview-effective-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) effectiveAppearance)))
(define (nssplitview-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nssplitview-end-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) endGestureWithEvent: (coerce-arg event)))
(define (nssplitview-flags-changed self event)
  (tell #:type _void (coerce-arg self) flagsChanged: (coerce-arg event)))
(define (nssplitview-flush-buffered-key-events self)
  (tell #:type _void (coerce-arg self) flushBufferedKeyEvents))
(define (nssplitview-get-rects-being-drawn-count self rects count)
  (_msg-51 (coerce-arg self) (sel_registerName "getRectsBeingDrawn:count:") rects count))
(define (nssplitview-get-rects-exposed-during-live-resize-count self exposed-rects count)
  (_msg-51 (coerce-arg self) (sel_registerName "getRectsExposedDuringLiveResize:count:") exposed-rects count))
(define (nssplitview-help-requested self event-ptr)
  (tell #:type _void (coerce-arg self) helpRequested: (coerce-arg event-ptr)))
(define (nssplitview-hit-test self point)
  (wrap-objc-object
   (_msg-11 (coerce-arg self) (sel_registerName "hitTest:") point)
   ))
(define (nssplitview-holding-priority-for-subview-at-index self subview-index)
  (_msg-42 (coerce-arg self) (sel_registerName "holdingPriorityForSubviewAtIndex:") subview-index))
(define (nssplitview-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) identifier)))
(define (nssplitview-indent self sender)
  (tell #:type _void (coerce-arg self) indent: (coerce-arg sender)))
(define (nssplitview-insert-backtab! self sender)
  (tell #:type _void (coerce-arg self) insertBacktab: (coerce-arg sender)))
(define (nssplitview-insert-container-break! self sender)
  (tell #:type _void (coerce-arg self) insertContainerBreak: (coerce-arg sender)))
(define (nssplitview-insert-double-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertDoubleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nssplitview-insert-line-break! self sender)
  (tell #:type _void (coerce-arg self) insertLineBreak: (coerce-arg sender)))
(define (nssplitview-insert-newline! self sender)
  (tell #:type _void (coerce-arg self) insertNewline: (coerce-arg sender)))
(define (nssplitview-insert-newline-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertNewlineIgnoringFieldEditor: (coerce-arg sender)))
(define (nssplitview-insert-paragraph-separator! self sender)
  (tell #:type _void (coerce-arg self) insertParagraphSeparator: (coerce-arg sender)))
(define (nssplitview-insert-single-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertSingleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nssplitview-insert-tab! self sender)
  (tell #:type _void (coerce-arg self) insertTab: (coerce-arg sender)))
(define (nssplitview-insert-tab-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertTabIgnoringFieldEditor: (coerce-arg sender)))
(define (nssplitview-insert-text! self insert-string)
  (tell #:type _void (coerce-arg self) insertText: (coerce-arg insert-string)))
(define (nssplitview-interpret-key-events self event-array)
  (tell #:type _void (coerce-arg self) interpretKeyEvents: (coerce-arg event-array)))
(define (nssplitview-is-accessibility-alternate-ui-visible self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityAlternateUIVisible")))
(define (nssplitview-is-accessibility-disclosed self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityDisclosed")))
(define (nssplitview-is-accessibility-edited self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityEdited")))
(define (nssplitview-is-accessibility-element self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityElement")))
(define (nssplitview-is-accessibility-enabled self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityEnabled")))
(define (nssplitview-is-accessibility-expanded self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityExpanded")))
(define (nssplitview-is-accessibility-focused self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityFocused")))
(define (nssplitview-is-accessibility-frontmost self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityFrontmost")))
(define (nssplitview-is-accessibility-hidden self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityHidden")))
(define (nssplitview-is-accessibility-main self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityMain")))
(define (nssplitview-is-accessibility-minimized self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityMinimized")))
(define (nssplitview-is-accessibility-modal self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityModal")))
(define (nssplitview-is-accessibility-ordered-by-row self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityOrderedByRow")))
(define (nssplitview-is-accessibility-protected-content self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityProtectedContent")))
(define (nssplitview-is-accessibility-required self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityRequired")))
(define (nssplitview-is-accessibility-selected self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilitySelected")))
(define (nssplitview-is-accessibility-selector-allowed self selector)
  (_msg-47 (coerce-arg self) (sel_registerName "isAccessibilitySelectorAllowed:") (sel_registerName selector)))
(define (nssplitview-is-descendant-of self view)
  (_msg-36 (coerce-arg self) (sel_registerName "isDescendantOf:") (coerce-arg view)))
(define (nssplitview-is-flipped self)
  (_msg-3 (coerce-arg self) (sel_registerName "isFlipped")))
(define (nssplitview-is-hidden self)
  (_msg-3 (coerce-arg self) (sel_registerName "isHidden")))
(define (nssplitview-is-hidden-or-has-hidden-ancestor self)
  (_msg-3 (coerce-arg self) (sel_registerName "isHiddenOrHasHiddenAncestor")))
(define (nssplitview-is-opaque self)
  (_msg-3 (coerce-arg self) (sel_registerName "isOpaque")))
(define (nssplitview-is-rotated-from-base self)
  (_msg-3 (coerce-arg self) (sel_registerName "isRotatedFromBase")))
(define (nssplitview-is-rotated-or-scaled-from-base self)
  (_msg-3 (coerce-arg self) (sel_registerName "isRotatedOrScaledFromBase")))
(define (nssplitview-is-subview-collapsed self subview)
  (_msg-36 (coerce-arg self) (sel_registerName "isSubviewCollapsed:") (coerce-arg subview)))
(define (nssplitview-is-vertical self)
  (_msg-3 (coerce-arg self) (sel_registerName "isVertical")))
(define (nssplitview-key-down self event)
  (tell #:type _void (coerce-arg self) keyDown: (coerce-arg event)))
(define (nssplitview-key-up self event)
  (tell #:type _void (coerce-arg self) keyUp: (coerce-arg event)))
(define (nssplitview-layout self)
  (tell #:type _void (coerce-arg self) layout))
(define (nssplitview-layout-subtree-if-needed self)
  (tell #:type _void (coerce-arg self) layoutSubtreeIfNeeded))
(define (nssplitview-lowercase-word self sender)
  (tell #:type _void (coerce-arg self) lowercaseWord: (coerce-arg sender)))
(define (nssplitview-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) magnifyWithEvent: (coerce-arg event)))
(define (nssplitview-make-backing-layer self)
  (wrap-objc-object
   (tell (coerce-arg self) makeBackingLayer)))
(define (nssplitview-make-base-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nssplitview-make-base-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionNatural: (coerce-arg sender)))
(define (nssplitview-make-base-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nssplitview-make-text-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nssplitview-make-text-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionNatural: (coerce-arg sender)))
(define (nssplitview-make-text-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nssplitview-max-possible-position-of-divider-at-index self divider-index)
  (_msg-41 (coerce-arg self) (sel_registerName "maxPossiblePositionOfDividerAtIndex:") divider-index))
(define (nssplitview-menu-for-event self event)
  (wrap-objc-object
   (tell (coerce-arg self) menuForEvent: (coerce-arg event))))
(define (nssplitview-min-possible-position-of-divider-at-index self divider-index)
  (_msg-41 (coerce-arg self) (sel_registerName "minPossiblePositionOfDividerAtIndex:") divider-index))
(define (nssplitview-mouse-in-rect self point rect)
  (_msg-14 (coerce-arg self) (sel_registerName "mouse:inRect:") point rect))
(define (nssplitview-mouse-cancelled self event)
  (tell #:type _void (coerce-arg self) mouseCancelled: (coerce-arg event)))
(define (nssplitview-mouse-down self event)
  (tell #:type _void (coerce-arg self) mouseDown: (coerce-arg event)))
(define (nssplitview-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) mouseDragged: (coerce-arg event)))
(define (nssplitview-mouse-entered self event)
  (tell #:type _void (coerce-arg self) mouseEntered: (coerce-arg event)))
(define (nssplitview-mouse-exited self event)
  (tell #:type _void (coerce-arg self) mouseExited: (coerce-arg event)))
(define (nssplitview-mouse-moved self event)
  (tell #:type _void (coerce-arg self) mouseMoved: (coerce-arg event)))
(define (nssplitview-mouse-up self event)
  (tell #:type _void (coerce-arg self) mouseUp: (coerce-arg event)))
(define (nssplitview-move-backward! self sender)
  (tell #:type _void (coerce-arg self) moveBackward: (coerce-arg sender)))
(define (nssplitview-move-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveBackwardAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-down! self sender)
  (tell #:type _void (coerce-arg self) moveDown: (coerce-arg sender)))
(define (nssplitview-move-down-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveDownAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-forward! self sender)
  (tell #:type _void (coerce-arg self) moveForward: (coerce-arg sender)))
(define (nssplitview-move-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveForwardAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-left! self sender)
  (tell #:type _void (coerce-arg self) moveLeft: (coerce-arg sender)))
(define (nssplitview-move-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveLeftAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-paragraph-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphBackwardAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-paragraph-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphForwardAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-right! self sender)
  (tell #:type _void (coerce-arg self) moveRight: (coerce-arg sender)))
(define (nssplitview-move-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveRightAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-to-beginning-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocument: (coerce-arg sender)))
(define (nssplitview-move-to-beginning-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-to-beginning-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLine: (coerce-arg sender)))
(define (nssplitview-move-to-beginning-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLineAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-to-beginning-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraph: (coerce-arg sender)))
(define (nssplitview-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-to-end-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocument: (coerce-arg sender)))
(define (nssplitview-move-to-end-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-to-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLine: (coerce-arg sender)))
(define (nssplitview-move-to-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-to-end-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraph: (coerce-arg sender)))
(define (nssplitview-move-to-end-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-to-left-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLine: (coerce-arg sender)))
(define (nssplitview-move-to-left-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-to-right-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLine: (coerce-arg sender)))
(define (nssplitview-move-to-right-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-up! self sender)
  (tell #:type _void (coerce-arg self) moveUp: (coerce-arg sender)))
(define (nssplitview-move-up-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveUpAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-word-backward! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackward: (coerce-arg sender)))
(define (nssplitview-move-word-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackwardAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-word-forward! self sender)
  (tell #:type _void (coerce-arg self) moveWordForward: (coerce-arg sender)))
(define (nssplitview-move-word-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordForwardAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-word-left! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeft: (coerce-arg sender)))
(define (nssplitview-move-word-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeftAndModifySelection: (coerce-arg sender)))
(define (nssplitview-move-word-right! self sender)
  (tell #:type _void (coerce-arg self) moveWordRight: (coerce-arg sender)))
(define (nssplitview-move-word-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordRightAndModifySelection: (coerce-arg sender)))
(define (nssplitview-needs-to-draw-rect self rect)
  (_msg-20 (coerce-arg self) (sel_registerName "needsToDrawRect:") rect))
(define (nssplitview-no-responder-for self event-selector)
  (_msg-48 (coerce-arg self) (sel_registerName "noResponderFor:") (sel_registerName event-selector)))
(define (nssplitview-other-mouse-down self event)
  (tell #:type _void (coerce-arg self) otherMouseDown: (coerce-arg event)))
(define (nssplitview-other-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) otherMouseDragged: (coerce-arg event)))
(define (nssplitview-other-mouse-up self event)
  (tell #:type _void (coerce-arg self) otherMouseUp: (coerce-arg event)))
(define (nssplitview-page-down self sender)
  (tell #:type _void (coerce-arg self) pageDown: (coerce-arg sender)))
(define (nssplitview-page-down-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageDownAndModifySelection: (coerce-arg sender)))
(define (nssplitview-page-up self sender)
  (tell #:type _void (coerce-arg self) pageUp: (coerce-arg sender)))
(define (nssplitview-page-up-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageUpAndModifySelection: (coerce-arg sender)))
(define (nssplitview-perform-drag-operation! self sender)
  (_msg-36 (coerce-arg self) (sel_registerName "performDragOperation:") (coerce-arg sender)))
(define (nssplitview-perform-key-equivalent! self event)
  (_msg-36 (coerce-arg self) (sel_registerName "performKeyEquivalent:") (coerce-arg event)))
(define (nssplitview-prepare-content-in-rect self rect)
  (_msg-22 (coerce-arg self) (sel_registerName "prepareContentInRect:") rect))
(define (nssplitview-prepare-for-drag-operation self sender)
  (_msg-36 (coerce-arg self) (sel_registerName "prepareForDragOperation:") (coerce-arg sender)))
(define (nssplitview-prepare-for-reuse self)
  (tell #:type _void (coerce-arg self) prepareForReuse))
(define (nssplitview-pressure-change-with-event self event)
  (tell #:type _void (coerce-arg self) pressureChangeWithEvent: (coerce-arg event)))
(define (nssplitview-quick-look-preview-items self sender)
  (tell #:type _void (coerce-arg self) quickLookPreviewItems: (coerce-arg sender)))
(define (nssplitview-quick-look-with-event self event)
  (tell #:type _void (coerce-arg self) quickLookWithEvent: (coerce-arg event)))
(define (nssplitview-rect-for-smart-magnification-at-point-in-rect self location visible-rect)
  (_msg-13 (coerce-arg self) (sel_registerName "rectForSmartMagnificationAtPoint:inRect:") location visible-rect))
(define (nssplitview-remove-all-tool-tips! self)
  (tell #:type _void (coerce-arg self) removeAllToolTips))
(define (nssplitview-remove-from-superview! self)
  (tell #:type _void (coerce-arg self) removeFromSuperview))
(define (nssplitview-remove-from-superview-without-needing-display! self)
  (tell #:type _void (coerce-arg self) removeFromSuperviewWithoutNeedingDisplay))
(define (nssplitview-remove-tool-tip! self tag)
  (_msg-45 (coerce-arg self) (sel_registerName "removeToolTip:") tag))
(define (nssplitview-replace-subview-with! self old-view new-view)
  (tell #:type _void (coerce-arg self) replaceSubview: (coerce-arg old-view) with: (coerce-arg new-view)))
(define (nssplitview-resign-first-responder self)
  (_msg-3 (coerce-arg self) (sel_registerName "resignFirstResponder")))
(define (nssplitview-resize-subviews-with-old-size self old-size)
  (_msg-29 (coerce-arg self) (sel_registerName "resizeSubviewsWithOldSize:") old-size))
(define (nssplitview-resize-with-old-superview-size self old-size)
  (_msg-29 (coerce-arg self) (sel_registerName "resizeWithOldSuperviewSize:") old-size))
(define (nssplitview-restore-user-activity-state self user-activity)
  (tell #:type _void (coerce-arg self) restoreUserActivityState: (coerce-arg user-activity)))
(define (nssplitview-right-mouse-down self event)
  (tell #:type _void (coerce-arg self) rightMouseDown: (coerce-arg event)))
(define (nssplitview-right-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) rightMouseDragged: (coerce-arg event)))
(define (nssplitview-right-mouse-up self event)
  (tell #:type _void (coerce-arg self) rightMouseUp: (coerce-arg event)))
(define (nssplitview-rotate-by-angle self angle)
  (_msg-32 (coerce-arg self) (sel_registerName "rotateByAngle:") angle))
(define (nssplitview-rotate-with-event self event)
  (tell #:type _void (coerce-arg self) rotateWithEvent: (coerce-arg event)))
(define (nssplitview-scale-unit-square-to-size self new-unit-size)
  (_msg-29 (coerce-arg self) (sel_registerName "scaleUnitSquareToSize:") new-unit-size))
(define (nssplitview-scroll-line-down self sender)
  (tell #:type _void (coerce-arg self) scrollLineDown: (coerce-arg sender)))
(define (nssplitview-scroll-line-up self sender)
  (tell #:type _void (coerce-arg self) scrollLineUp: (coerce-arg sender)))
(define (nssplitview-scroll-page-down self sender)
  (tell #:type _void (coerce-arg self) scrollPageDown: (coerce-arg sender)))
(define (nssplitview-scroll-page-up self sender)
  (tell #:type _void (coerce-arg self) scrollPageUp: (coerce-arg sender)))
(define (nssplitview-scroll-point self point)
  (_msg-12 (coerce-arg self) (sel_registerName "scrollPoint:") point))
(define (nssplitview-scroll-rect-to-visible self rect)
  (_msg-20 (coerce-arg self) (sel_registerName "scrollRectToVisible:") rect))
(define (nssplitview-scroll-to-beginning-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToBeginningOfDocument: (coerce-arg sender)))
(define (nssplitview-scroll-to-end-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToEndOfDocument: (coerce-arg sender)))
(define (nssplitview-scroll-wheel self event)
  (tell #:type _void (coerce-arg self) scrollWheel: (coerce-arg event)))
(define (nssplitview-select-all self sender)
  (tell #:type _void (coerce-arg self) selectAll: (coerce-arg sender)))
(define (nssplitview-select-line self sender)
  (tell #:type _void (coerce-arg self) selectLine: (coerce-arg sender)))
(define (nssplitview-select-paragraph self sender)
  (tell #:type _void (coerce-arg self) selectParagraph: (coerce-arg sender)))
(define (nssplitview-select-to-mark self sender)
  (tell #:type _void (coerce-arg self) selectToMark: (coerce-arg sender)))
(define (nssplitview-select-word self sender)
  (tell #:type _void (coerce-arg self) selectWord: (coerce-arg sender)))
(define (nssplitview-set-accessibility-activation-point! self accessibility-activation-point)
  (_msg-12 (coerce-arg self) (sel_registerName "setAccessibilityActivationPoint:") accessibility-activation-point))
(define (nssplitview-set-accessibility-allowed-values! self accessibility-allowed-values)
  (tell #:type _void (coerce-arg self) setAccessibilityAllowedValues: (coerce-arg accessibility-allowed-values)))
(define (nssplitview-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityAlternateUIVisible:") accessibility-alternate-ui-visible))
(define (nssplitview-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityApplicationFocusedUIElement: (coerce-arg accessibility-application-focused-ui-element)))
(define (nssplitview-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityAttributedUserInputLabels: (coerce-arg accessibility-attributed-user-input-labels)))
(define (nssplitview-set-accessibility-cancel-button! self accessibility-cancel-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCancelButton: (coerce-arg accessibility-cancel-button)))
(define (nssplitview-set-accessibility-children! self accessibility-children)
  (tell #:type _void (coerce-arg self) setAccessibilityChildren: (coerce-arg accessibility-children)))
(define (nssplitview-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (tell #:type _void (coerce-arg self) setAccessibilityChildrenInNavigationOrder: (coerce-arg accessibility-children-in-navigation-order)))
(define (nssplitview-set-accessibility-clear-button! self accessibility-clear-button)
  (tell #:type _void (coerce-arg self) setAccessibilityClearButton: (coerce-arg accessibility-clear-button)))
(define (nssplitview-set-accessibility-close-button! self accessibility-close-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCloseButton: (coerce-arg accessibility-close-button)))
(define (nssplitview-set-accessibility-column-count! self accessibility-column-count)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityColumnCount:") accessibility-column-count))
(define (nssplitview-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnHeaderUIElements: (coerce-arg accessibility-column-header-ui-elements)))
(define (nssplitview-set-accessibility-column-index-range! self accessibility-column-index-range)
  (_msg-18 (coerce-arg self) (sel_registerName "setAccessibilityColumnIndexRange:") accessibility-column-index-range))
(define (nssplitview-set-accessibility-column-titles! self accessibility-column-titles)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnTitles: (coerce-arg accessibility-column-titles)))
(define (nssplitview-set-accessibility-columns! self accessibility-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityColumns: (coerce-arg accessibility-columns)))
(define (nssplitview-set-accessibility-contents! self accessibility-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityContents: (coerce-arg accessibility-contents)))
(define (nssplitview-set-accessibility-critical-value! self accessibility-critical-value)
  (tell #:type _void (coerce-arg self) setAccessibilityCriticalValue: (coerce-arg accessibility-critical-value)))
(define (nssplitview-set-accessibility-custom-actions! self accessibility-custom-actions)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomActions: (coerce-arg accessibility-custom-actions)))
(define (nssplitview-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomRotors: (coerce-arg accessibility-custom-rotors)))
(define (nssplitview-set-accessibility-decrement-button! self accessibility-decrement-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDecrementButton: (coerce-arg accessibility-decrement-button)))
(define (nssplitview-set-accessibility-default-button! self accessibility-default-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDefaultButton: (coerce-arg accessibility-default-button)))
(define (nssplitview-set-accessibility-disclosed! self accessibility-disclosed)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityDisclosed:") accessibility-disclosed))
(define (nssplitview-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedByRow: (coerce-arg accessibility-disclosed-by-row)))
(define (nssplitview-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedRows: (coerce-arg accessibility-disclosed-rows)))
(define (nssplitview-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityDisclosureLevel:") accessibility-disclosure-level))
(define (nssplitview-set-accessibility-document! self accessibility-document)
  (tell #:type _void (coerce-arg self) setAccessibilityDocument: (coerce-arg accessibility-document)))
(define (nssplitview-set-accessibility-edited! self accessibility-edited)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityEdited:") accessibility-edited))
(define (nssplitview-set-accessibility-element! self accessibility-element)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityElement:") accessibility-element))
(define (nssplitview-set-accessibility-enabled! self accessibility-enabled)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityEnabled:") accessibility-enabled))
(define (nssplitview-set-accessibility-expanded! self accessibility-expanded)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityExpanded:") accessibility-expanded))
(define (nssplitview-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityExtrasMenuBar: (coerce-arg accessibility-extras-menu-bar)))
(define (nssplitview-set-accessibility-filename! self accessibility-filename)
  (tell #:type _void (coerce-arg self) setAccessibilityFilename: (coerce-arg accessibility-filename)))
(define (nssplitview-set-accessibility-focused! self accessibility-focused)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityFocused:") accessibility-focused))
(define (nssplitview-set-accessibility-focused-window! self accessibility-focused-window)
  (tell #:type _void (coerce-arg self) setAccessibilityFocusedWindow: (coerce-arg accessibility-focused-window)))
(define (nssplitview-set-accessibility-frame! self accessibility-frame)
  (_msg-22 (coerce-arg self) (sel_registerName "setAccessibilityFrame:") accessibility-frame))
(define (nssplitview-set-accessibility-frontmost! self accessibility-frontmost)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityFrontmost:") accessibility-frontmost))
(define (nssplitview-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (tell #:type _void (coerce-arg self) setAccessibilityFullScreenButton: (coerce-arg accessibility-full-screen-button)))
(define (nssplitview-set-accessibility-grow-area! self accessibility-grow-area)
  (tell #:type _void (coerce-arg self) setAccessibilityGrowArea: (coerce-arg accessibility-grow-area)))
(define (nssplitview-set-accessibility-handles! self accessibility-handles)
  (tell #:type _void (coerce-arg self) setAccessibilityHandles: (coerce-arg accessibility-handles)))
(define (nssplitview-set-accessibility-header! self accessibility-header)
  (tell #:type _void (coerce-arg self) setAccessibilityHeader: (coerce-arg accessibility-header)))
(define (nssplitview-set-accessibility-help! self accessibility-help)
  (tell #:type _void (coerce-arg self) setAccessibilityHelp: (coerce-arg accessibility-help)))
(define (nssplitview-set-accessibility-hidden! self accessibility-hidden)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityHidden:") accessibility-hidden))
(define (nssplitview-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalScrollBar: (coerce-arg accessibility-horizontal-scroll-bar)))
(define (nssplitview-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalUnitDescription: (coerce-arg accessibility-horizontal-unit-description)))
(define (nssplitview-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityHorizontalUnits:") accessibility-horizontal-units))
(define (nssplitview-set-accessibility-identifier! self accessibility-identifier)
  (tell #:type _void (coerce-arg self) setAccessibilityIdentifier: (coerce-arg accessibility-identifier)))
(define (nssplitview-set-accessibility-increment-button! self accessibility-increment-button)
  (tell #:type _void (coerce-arg self) setAccessibilityIncrementButton: (coerce-arg accessibility-increment-button)))
(define (nssplitview-set-accessibility-index! self accessibility-index)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityIndex:") accessibility-index))
(define (nssplitview-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityInsertionPointLineNumber:") accessibility-insertion-point-line-number))
(define (nssplitview-set-accessibility-label! self accessibility-label)
  (tell #:type _void (coerce-arg self) setAccessibilityLabel: (coerce-arg accessibility-label)))
(define (nssplitview-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLabelUIElements: (coerce-arg accessibility-label-ui-elements)))
(define (nssplitview-set-accessibility-label-value! self accessibility-label-value)
  (_msg-34 (coerce-arg self) (sel_registerName "setAccessibilityLabelValue:") accessibility-label-value))
(define (nssplitview-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLinkedUIElements: (coerce-arg accessibility-linked-ui-elements)))
(define (nssplitview-set-accessibility-main! self accessibility-main)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityMain:") accessibility-main))
(define (nssplitview-set-accessibility-main-window! self accessibility-main-window)
  (tell #:type _void (coerce-arg self) setAccessibilityMainWindow: (coerce-arg accessibility-main-window)))
(define (nssplitview-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerGroupUIElement: (coerce-arg accessibility-marker-group-ui-element)))
(define (nssplitview-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerTypeDescription: (coerce-arg accessibility-marker-type-description)))
(define (nssplitview-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerUIElements: (coerce-arg accessibility-marker-ui-elements)))
(define (nssplitview-set-accessibility-marker-values! self accessibility-marker-values)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerValues: (coerce-arg accessibility-marker-values)))
(define (nssplitview-set-accessibility-max-value! self accessibility-max-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMaxValue: (coerce-arg accessibility-max-value)))
(define (nssplitview-set-accessibility-menu-bar! self accessibility-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityMenuBar: (coerce-arg accessibility-menu-bar)))
(define (nssplitview-set-accessibility-min-value! self accessibility-min-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMinValue: (coerce-arg accessibility-min-value)))
(define (nssplitview-set-accessibility-minimize-button! self accessibility-minimize-button)
  (tell #:type _void (coerce-arg self) setAccessibilityMinimizeButton: (coerce-arg accessibility-minimize-button)))
(define (nssplitview-set-accessibility-minimized! self accessibility-minimized)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityMinimized:") accessibility-minimized))
(define (nssplitview-set-accessibility-modal! self accessibility-modal)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityModal:") accessibility-modal))
(define (nssplitview-set-accessibility-next-contents! self accessibility-next-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityNextContents: (coerce-arg accessibility-next-contents)))
(define (nssplitview-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityNumberOfCharacters:") accessibility-number-of-characters))
(define (nssplitview-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityOrderedByRow:") accessibility-ordered-by-row))
(define (nssplitview-set-accessibility-orientation! self accessibility-orientation)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityOrientation:") accessibility-orientation))
(define (nssplitview-set-accessibility-overflow-button! self accessibility-overflow-button)
  (tell #:type _void (coerce-arg self) setAccessibilityOverflowButton: (coerce-arg accessibility-overflow-button)))
(define (nssplitview-set-accessibility-parent! self accessibility-parent)
  (tell #:type _void (coerce-arg self) setAccessibilityParent: (coerce-arg accessibility-parent)))
(define (nssplitview-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (tell #:type _void (coerce-arg self) setAccessibilityPlaceholderValue: (coerce-arg accessibility-placeholder-value)))
(define (nssplitview-set-accessibility-previous-contents! self accessibility-previous-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityPreviousContents: (coerce-arg accessibility-previous-contents)))
(define (nssplitview-set-accessibility-protected-content! self accessibility-protected-content)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityProtectedContent:") accessibility-protected-content))
(define (nssplitview-set-accessibility-proxy! self accessibility-proxy)
  (tell #:type _void (coerce-arg self) setAccessibilityProxy: (coerce-arg accessibility-proxy)))
(define (nssplitview-set-accessibility-required! self accessibility-required)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityRequired:") accessibility-required))
(define (nssplitview-set-accessibility-role! self accessibility-role)
  (tell #:type _void (coerce-arg self) setAccessibilityRole: (coerce-arg accessibility-role)))
(define (nssplitview-set-accessibility-role-description! self accessibility-role-description)
  (tell #:type _void (coerce-arg self) setAccessibilityRoleDescription: (coerce-arg accessibility-role-description)))
(define (nssplitview-set-accessibility-row-count! self accessibility-row-count)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityRowCount:") accessibility-row-count))
(define (nssplitview-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityRowHeaderUIElements: (coerce-arg accessibility-row-header-ui-elements)))
(define (nssplitview-set-accessibility-row-index-range! self accessibility-row-index-range)
  (_msg-18 (coerce-arg self) (sel_registerName "setAccessibilityRowIndexRange:") accessibility-row-index-range))
(define (nssplitview-set-accessibility-rows! self accessibility-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityRows: (coerce-arg accessibility-rows)))
(define (nssplitview-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityRulerMarkerType:") accessibility-ruler-marker-type))
(define (nssplitview-set-accessibility-search-button! self accessibility-search-button)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchButton: (coerce-arg accessibility-search-button)))
(define (nssplitview-set-accessibility-search-menu! self accessibility-search-menu)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchMenu: (coerce-arg accessibility-search-menu)))
(define (nssplitview-set-accessibility-selected! self accessibility-selected)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilitySelected:") accessibility-selected))
(define (nssplitview-set-accessibility-selected-cells! self accessibility-selected-cells)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedCells: (coerce-arg accessibility-selected-cells)))
(define (nssplitview-set-accessibility-selected-children! self accessibility-selected-children)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedChildren: (coerce-arg accessibility-selected-children)))
(define (nssplitview-set-accessibility-selected-columns! self accessibility-selected-columns)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedColumns: (coerce-arg accessibility-selected-columns)))
(define (nssplitview-set-accessibility-selected-rows! self accessibility-selected-rows)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedRows: (coerce-arg accessibility-selected-rows)))
(define (nssplitview-set-accessibility-selected-text! self accessibility-selected-text)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedText: (coerce-arg accessibility-selected-text)))
(define (nssplitview-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (_msg-18 (coerce-arg self) (sel_registerName "setAccessibilitySelectedTextRange:") accessibility-selected-text-range))
(define (nssplitview-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedTextRanges: (coerce-arg accessibility-selected-text-ranges)))
(define (nssplitview-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityServesAsTitleForUIElements: (coerce-arg accessibility-serves-as-title-for-ui-elements)))
(define (nssplitview-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (_msg-18 (coerce-arg self) (sel_registerName "setAccessibilitySharedCharacterRange:") accessibility-shared-character-range))
(define (nssplitview-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedFocusElements: (coerce-arg accessibility-shared-focus-elements)))
(define (nssplitview-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedTextUIElements: (coerce-arg accessibility-shared-text-ui-elements)))
(define (nssplitview-set-accessibility-shown-menu! self accessibility-shown-menu)
  (tell #:type _void (coerce-arg self) setAccessibilityShownMenu: (coerce-arg accessibility-shown-menu)))
(define (nssplitview-set-accessibility-sort-direction! self accessibility-sort-direction)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilitySortDirection:") accessibility-sort-direction))
(define (nssplitview-set-accessibility-splitters! self accessibility-splitters)
  (tell #:type _void (coerce-arg self) setAccessibilitySplitters: (coerce-arg accessibility-splitters)))
(define (nssplitview-set-accessibility-subrole! self accessibility-subrole)
  (tell #:type _void (coerce-arg self) setAccessibilitySubrole: (coerce-arg accessibility-subrole)))
(define (nssplitview-set-accessibility-tabs! self accessibility-tabs)
  (tell #:type _void (coerce-arg self) setAccessibilityTabs: (coerce-arg accessibility-tabs)))
(define (nssplitview-set-accessibility-title! self accessibility-title)
  (tell #:type _void (coerce-arg self) setAccessibilityTitle: (coerce-arg accessibility-title)))
(define (nssplitview-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTitleUIElement: (coerce-arg accessibility-title-ui-element)))
(define (nssplitview-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (tell #:type _void (coerce-arg self) setAccessibilityToolbarButton: (coerce-arg accessibility-toolbar-button)))
(define (nssplitview-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTopLevelUIElement: (coerce-arg accessibility-top-level-ui-element)))
(define (nssplitview-set-accessibility-url! self accessibility-url)
  (tell #:type _void (coerce-arg self) setAccessibilityURL: (coerce-arg accessibility-url)))
(define (nssplitview-set-accessibility-unit-description! self accessibility-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityUnitDescription: (coerce-arg accessibility-unit-description)))
(define (nssplitview-set-accessibility-units! self accessibility-units)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityUnits:") accessibility-units))
(define (nssplitview-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityUserInputLabels: (coerce-arg accessibility-user-input-labels)))
(define (nssplitview-set-accessibility-value! self accessibility-value)
  (tell #:type _void (coerce-arg self) setAccessibilityValue: (coerce-arg accessibility-value)))
(define (nssplitview-set-accessibility-value-description! self accessibility-value-description)
  (tell #:type _void (coerce-arg self) setAccessibilityValueDescription: (coerce-arg accessibility-value-description)))
(define (nssplitview-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalScrollBar: (coerce-arg accessibility-vertical-scroll-bar)))
(define (nssplitview-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalUnitDescription: (coerce-arg accessibility-vertical-unit-description)))
(define (nssplitview-set-accessibility-vertical-units! self accessibility-vertical-units)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityVerticalUnits:") accessibility-vertical-units))
(define (nssplitview-set-accessibility-visible-cells! self accessibility-visible-cells)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleCells: (coerce-arg accessibility-visible-cells)))
(define (nssplitview-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (_msg-18 (coerce-arg self) (sel_registerName "setAccessibilityVisibleCharacterRange:") accessibility-visible-character-range))
(define (nssplitview-set-accessibility-visible-children! self accessibility-visible-children)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleChildren: (coerce-arg accessibility-visible-children)))
(define (nssplitview-set-accessibility-visible-columns! self accessibility-visible-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleColumns: (coerce-arg accessibility-visible-columns)))
(define (nssplitview-set-accessibility-visible-rows! self accessibility-visible-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleRows: (coerce-arg accessibility-visible-rows)))
(define (nssplitview-set-accessibility-warning-value! self accessibility-warning-value)
  (tell #:type _void (coerce-arg self) setAccessibilityWarningValue: (coerce-arg accessibility-warning-value)))
(define (nssplitview-set-accessibility-window! self accessibility-window)
  (tell #:type _void (coerce-arg self) setAccessibilityWindow: (coerce-arg accessibility-window)))
(define (nssplitview-set-accessibility-windows! self accessibility-windows)
  (tell #:type _void (coerce-arg self) setAccessibilityWindows: (coerce-arg accessibility-windows)))
(define (nssplitview-set-accessibility-zoom-button! self accessibility-zoom-button)
  (tell #:type _void (coerce-arg self) setAccessibilityZoomButton: (coerce-arg accessibility-zoom-button)))
(define (nssplitview-set-animations! self animations)
  (tell #:type _void (coerce-arg self) setAnimations: (coerce-arg animations)))
(define (nssplitview-set-appearance! self appearance)
  (tell #:type _void (coerce-arg self) setAppearance: (coerce-arg appearance)))
(define (nssplitview-set-bounds-origin! self new-origin)
  (_msg-12 (coerce-arg self) (sel_registerName "setBoundsOrigin:") new-origin))
(define (nssplitview-set-bounds-size! self new-size)
  (_msg-29 (coerce-arg self) (sel_registerName "setBoundsSize:") new-size))
(define (nssplitview-set-frame-origin! self new-origin)
  (_msg-12 (coerce-arg self) (sel_registerName "setFrameOrigin:") new-origin))
(define (nssplitview-set-frame-size! self new-size)
  (_msg-29 (coerce-arg self) (sel_registerName "setFrameSize:") new-size))
(define (nssplitview-set-holding-priority-for-subview-at-index! self priority subview-index)
  (_msg-35 (coerce-arg self) (sel_registerName "setHoldingPriority:forSubviewAtIndex:") priority subview-index))
(define (nssplitview-set-identifier! self identifier)
  (tell #:type _void (coerce-arg self) setIdentifier: (coerce-arg identifier)))
(define (nssplitview-set-mark! self sender)
  (tell #:type _void (coerce-arg self) setMark: (coerce-arg sender)))
(define (nssplitview-set-needs-display-in-rect! self invalid-rect)
  (_msg-22 (coerce-arg self) (sel_registerName "setNeedsDisplayInRect:") invalid-rect))
(define (nssplitview-set-position-of-divider-at-index! self position divider-index)
  (_msg-33 (coerce-arg self) (sel_registerName "setPosition:ofDividerAtIndex:") position divider-index))
(define (nssplitview-should-be-treated-as-ink-event self event)
  (_msg-36 (coerce-arg self) (sel_registerName "shouldBeTreatedAsInkEvent:") (coerce-arg event)))
(define (nssplitview-should-delay-window-ordering-for-event self event)
  (_msg-36 (coerce-arg self) (sel_registerName "shouldDelayWindowOrderingForEvent:") (coerce-arg event)))
(define (nssplitview-show-context-help self sender)
  (tell #:type _void (coerce-arg self) showContextHelp: (coerce-arg sender)))
(define (nssplitview-show-context-menu-for-selection self sender)
  (tell #:type _void (coerce-arg self) showContextMenuForSelection: (coerce-arg sender)))
(define (nssplitview-smart-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) smartMagnifyWithEvent: (coerce-arg event)))
(define (nssplitview-sort-subviews-using-function-context self compare context)
  (_msg-51 (coerce-arg self) (sel_registerName "sortSubviewsUsingFunction:context:") compare context))
(define (nssplitview-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (_msg-50 (coerce-arg self) (sel_registerName "supplementalTargetForAction:sender:") (sel_registerName action) (coerce-arg sender))
   ))
(define (nssplitview-swap-with-mark self sender)
  (tell #:type _void (coerce-arg self) swapWithMark: (coerce-arg sender)))
(define (nssplitview-swipe-with-event self event)
  (tell #:type _void (coerce-arg self) swipeWithEvent: (coerce-arg event)))
(define (nssplitview-tablet-point self event)
  (tell #:type _void (coerce-arg self) tabletPoint: (coerce-arg event)))
(define (nssplitview-tablet-proximity self event)
  (tell #:type _void (coerce-arg self) tabletProximity: (coerce-arg event)))
(define (nssplitview-touches-began-with-event self event)
  (tell #:type _void (coerce-arg self) touchesBeganWithEvent: (coerce-arg event)))
(define (nssplitview-touches-cancelled-with-event self event)
  (tell #:type _void (coerce-arg self) touchesCancelledWithEvent: (coerce-arg event)))
(define (nssplitview-touches-ended-with-event self event)
  (tell #:type _void (coerce-arg self) touchesEndedWithEvent: (coerce-arg event)))
(define (nssplitview-touches-moved-with-event self event)
  (tell #:type _void (coerce-arg self) touchesMovedWithEvent: (coerce-arg event)))
(define (nssplitview-translate-origin-to-point self translation)
  (_msg-12 (coerce-arg self) (sel_registerName "translateOriginToPoint:") translation))
(define (nssplitview-translate-rects-needing-display-in-rect-by self clip-rect delta)
  (_msg-23 (coerce-arg self) (sel_registerName "translateRectsNeedingDisplayInRect:by:") clip-rect delta))
(define (nssplitview-transpose self sender)
  (tell #:type _void (coerce-arg self) transpose: (coerce-arg sender)))
(define (nssplitview-transpose-words self sender)
  (tell #:type _void (coerce-arg self) transposeWords: (coerce-arg sender)))
(define (nssplitview-try-to-perform-with self action object)
  (_msg-49 (coerce-arg self) (sel_registerName "tryToPerform:with:") (sel_registerName action) (coerce-arg object)))
(define (nssplitview-update-dragging-items-for-drag self sender)
  (tell #:type _void (coerce-arg self) updateDraggingItemsForDrag: (coerce-arg sender)))
(define (nssplitview-update-layer self)
  (tell #:type _void (coerce-arg self) updateLayer))
(define (nssplitview-uppercase-word self sender)
  (tell #:type _void (coerce-arg self) uppercaseWord: (coerce-arg sender)))
(define (nssplitview-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (tell (coerce-arg self) validRequestorForSendType: (coerce-arg send-type) returnType: (coerce-arg return-type))))
(define (nssplitview-view-did-change-backing-properties self)
  (tell #:type _void (coerce-arg self) viewDidChangeBackingProperties))
(define (nssplitview-view-did-change-effective-appearance self)
  (tell #:type _void (coerce-arg self) viewDidChangeEffectiveAppearance))
(define (nssplitview-view-did-end-live-resize self)
  (tell #:type _void (coerce-arg self) viewDidEndLiveResize))
(define (nssplitview-view-did-hide self)
  (tell #:type _void (coerce-arg self) viewDidHide))
(define (nssplitview-view-did-move-to-superview self)
  (tell #:type _void (coerce-arg self) viewDidMoveToSuperview))
(define (nssplitview-view-did-move-to-window self)
  (tell #:type _void (coerce-arg self) viewDidMoveToWindow))
(define (nssplitview-view-did-unhide self)
  (tell #:type _void (coerce-arg self) viewDidUnhide))
(define (nssplitview-view-will-draw self)
  (tell #:type _void (coerce-arg self) viewWillDraw))
(define (nssplitview-view-will-move-to-superview self new-superview)
  (tell #:type _void (coerce-arg self) viewWillMoveToSuperview: (coerce-arg new-superview)))
(define (nssplitview-view-will-move-to-window self new-window)
  (tell #:type _void (coerce-arg self) viewWillMoveToWindow: (coerce-arg new-window)))
(define (nssplitview-view-will-start-live-resize self)
  (tell #:type _void (coerce-arg self) viewWillStartLiveResize))
(define (nssplitview-view-with-tag self tag)
  (wrap-objc-object
   (_msg-43 (coerce-arg self) (sel_registerName "viewWithTag:") tag)
   ))
(define (nssplitview-wants-forwarded-scroll-events-for-axis self axis)
  (_msg-40 (coerce-arg self) (sel_registerName "wantsForwardedScrollEventsForAxis:") axis))
(define (nssplitview-wants-periodic-dragging-updates self)
  (_msg-3 (coerce-arg self) (sel_registerName "wantsPeriodicDraggingUpdates")))
(define (nssplitview-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (_msg-40 (coerce-arg self) (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:") axis))
(define (nssplitview-will-open-menu-with-event self menu event)
  (tell #:type _void (coerce-arg self) willOpenMenu: (coerce-arg menu) withEvent: (coerce-arg event)))
(define (nssplitview-will-remove-subview self subview)
  (tell #:type _void (coerce-arg self) willRemoveSubview: (coerce-arg subview)))
(define (nssplitview-yank self sender)
  (tell #:type _void (coerce-arg self) yank: (coerce-arg sender)))

;; --- Class methods ---
(define (nssplitview-default-animation-for-key key)
  (wrap-objc-object
   (tell NSSplitView defaultAnimationForKey: (coerce-arg key))))
(define (nssplitview-is-compatible-with-responsive-scrolling)
  (_msg-3 NSSplitView (sel_registerName "isCompatibleWithResponsiveScrolling")))
