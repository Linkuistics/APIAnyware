#lang racket/base
;; Generated binding for NSView (AppKit)
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
  [nsview-background-filters (c-> nsview? any/c)]
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
  [nsview-constraints (c-> nsview? any/c)]
  [nsview-content-filters (c-> nsview? any/c)]
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
  [nsview-gesture-recognizers (c-> nsview? any/c)]
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
  [nsview-layer-contents-placement (c-> nsview? exact-nonnegative-integer?)]
  [nsview-set-layer-contents-placement! (c-> nsview? exact-nonnegative-integer? void?)]
  [nsview-layer-contents-redraw-policy (c-> nsview? exact-nonnegative-integer?)]
  [nsview-set-layer-contents-redraw-policy! (c-> nsview? exact-nonnegative-integer? void?)]
  [nsview-layer-uses-core-image-filters (c-> nsview? boolean?)]
  [nsview-set-layer-uses-core-image-filters! (c-> nsview? boolean? void?)]
  [nsview-layout-guides (c-> nsview? any/c)]
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
  [nsview-registered-dragged-types (c-> nsview? any/c)]
  [nsview-requires-constraint-based-layout (c-> boolean?)]
  [nsview-restorable-state-key-paths (c-> any/c)]
  [nsview-right-anchor (c-> nsview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsview-rotated-from-base (c-> nsview? boolean?)]
  [nsview-rotated-or-scaled-from-base (c-> nsview? boolean?)]
  [nsview-safe-area-insets (c-> nsview? any/c)]
  [nsview-safe-area-layout-guide (c-> nsview? (or/c nslayoutguide? objc-nil?))]
  [nsview-safe-area-rect (c-> nsview? any/c)]
  [nsview-shadow (c-> nsview? (or/c nsshadow? objc-nil?))]
  [nsview-set-shadow! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-subviews (c-> nsview? any/c)]
  [nsview-set-subviews! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-superview (c-> nsview? (or/c nsview? objc-nil?))]
  [nsview-tag (c-> nsview? exact-integer?)]
  [nsview-tool-tip (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-set-tool-tip! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-top-anchor (c-> nsview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nsview-touch-bar (c-> nsview? (or/c nstouchbar? objc-nil?))]
  [nsview-set-touch-bar! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-tracking-areas (c-> nsview? any/c)]
  [nsview-trailing-anchor (c-> nsview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nsview-translates-autoresizing-mask-into-constraints (c-> nsview? boolean?)]
  [nsview-set-translates-autoresizing-mask-into-constraints! (c-> nsview? boolean? void?)]
  [nsview-undo-manager (c-> nsview? (or/c nsundomanager? objc-nil?))]
  [nsview-user-activity (c-> nsview? (or/c nsuseractivity? objc-nil?))]
  [nsview-set-user-activity! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-user-interface-layout-direction (c-> nsview? exact-nonnegative-integer?)]
  [nsview-set-user-interface-layout-direction! (c-> nsview? exact-nonnegative-integer? void?)]
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
  [nsview-accessibility-allowed-values (c-> nsview? any/c)]
  [nsview-accessibility-application-focused-ui-element (c-> nsview? any/c)]
  [nsview-accessibility-attributed-string-for-range (c-> nsview? any/c (or/c nsattributedstring? objc-nil?))]
  [nsview-accessibility-attributed-user-input-labels (c-> nsview? any/c)]
  [nsview-accessibility-cancel-button (c-> nsview? any/c)]
  [nsview-accessibility-cell-for-column-row (c-> nsview? exact-integer? exact-integer? any/c)]
  [nsview-accessibility-children (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-children-in-navigation-order (c-> nsview? any/c)]
  [nsview-accessibility-clear-button (c-> nsview? any/c)]
  [nsview-accessibility-close-button (c-> nsview? any/c)]
  [nsview-accessibility-column-count (c-> nsview? exact-integer?)]
  [nsview-accessibility-column-header-ui-elements (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-column-index-range (c-> nsview? any/c)]
  [nsview-accessibility-column-titles (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-columns (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-contents (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-critical-value (c-> nsview? any/c)]
  [nsview-accessibility-custom-actions (c-> nsview? any/c)]
  [nsview-accessibility-custom-rotors (c-> nsview? any/c)]
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
  [nsview-accessibility-horizontal-units (c-> nsview? exact-nonnegative-integer?)]
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
  [nsview-accessibility-orientation (c-> nsview? exact-nonnegative-integer?)]
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
  [nsview-accessibility-ruler-marker-type (c-> nsview? exact-nonnegative-integer?)]
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
  [nsview-accessibility-selected-text-ranges (c-> nsview? any/c)]
  [nsview-accessibility-serves-as-title-for-ui-elements (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-shared-character-range (c-> nsview? any/c)]
  [nsview-accessibility-shared-focus-elements (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-shared-text-ui-elements (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-shown-menu (c-> nsview? any/c)]
  [nsview-accessibility-sort-direction (c-> nsview? exact-nonnegative-integer?)]
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
  [nsview-accessibility-units (c-> nsview? exact-nonnegative-integer?)]
  [nsview-accessibility-user-input-labels (c-> nsview? any/c)]
  [nsview-accessibility-value (c-> nsview? any/c)]
  [nsview-accessibility-value-description (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-accessibility-vertical-scroll-bar (c-> nsview? any/c)]
  [nsview-accessibility-vertical-unit-description (c-> nsview? (or/c nsstring? objc-nil?))]
  [nsview-accessibility-vertical-units (c-> nsview? exact-nonnegative-integer?)]
  [nsview-accessibility-visible-cells (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-visible-character-range (c-> nsview? any/c)]
  [nsview-accessibility-visible-children (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-visible-columns (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-visible-rows (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-warning-value (c-> nsview? any/c)]
  [nsview-accessibility-window (c-> nsview? any/c)]
  [nsview-accessibility-windows (c-> nsview? (or/c nsarray? objc-nil?))]
  [nsview-accessibility-zoom-button (c-> nsview? any/c)]
  [nsview-add-subview! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-add-subview-positioned-relative-to! (c-> nsview? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c string? objc-object? #f) void?)]
  [nsview-add-tool-tip-rect-owner-user-data! (c-> nsview? any/c (or/c string? objc-object? #f) (or/c cpointer? #f) exact-integer?)]
  [nsview-adjust-scroll (c-> nsview? any/c any/c)]
  [nsview-ancestor-shared-with-view (c-> nsview? (or/c string? objc-object? #f) (or/c nsview? objc-nil?))]
  [nsview-animation-for-key (c-> nsview? (or/c string? objc-object? #f) any/c)]
  [nsview-animations (c-> nsview? any/c)]
  [nsview-animator (c-> nsview? any/c)]
  [nsview-appearance (c-> nsview? (or/c nsappearance? objc-nil?))]
  [nsview-autoscroll (c-> nsview? (or/c string? objc-object? #f) boolean?)]
  [nsview-backing-aligned-rect-options (c-> nsview? any/c exact-nonnegative-integer? any/c)]
  [nsview-become-first-responder (c-> nsview? boolean?)]
  [nsview-begin-gesture-with-event! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-bitmap-image-rep-for-caching-display-in-rect (c-> nsview? any/c (or/c nsbitmapimagerep? objc-nil?))]
  [nsview-cache-display-in-rect-to-bitmap-image-rep (c-> nsview? any/c (or/c string? objc-object? #f) void?)]
  [nsview-cancel-operation (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-capitalize-word (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-center-scan-rect! (c-> nsview? any/c any/c)]
  [nsview-center-selection-in-visible-area! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-change-case-of-letter (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-change-mode-with-event (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-complete (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-conclude-drag-operation (c-> nsview? (or/c string? objc-object? #f) void?)]
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
  [nsview-display! (c-> nsview? void?)]
  [nsview-display-if-needed! (c-> nsview? void?)]
  [nsview-display-if-needed-ignoring-opacity! (c-> nsview? void?)]
  [nsview-display-if-needed-in-rect! (c-> nsview? any/c void?)]
  [nsview-display-if-needed-in-rect-ignoring-opacity! (c-> nsview? any/c void?)]
  [nsview-display-rect! (c-> nsview? any/c void?)]
  [nsview-display-rect-ignoring-opacity! (c-> nsview? any/c void?)]
  [nsview-display-rect-ignoring-opacity-in-context! (c-> nsview? any/c (or/c string? objc-object? #f) void?)]
  [nsview-do-command-by-selector (c-> nsview? string? void?)]
  [nsview-dragging-ended (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-dragging-entered (c-> nsview? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nsview-dragging-exited (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-dragging-updated (c-> nsview? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nsview-draw-rect (c-> nsview? any/c void?)]
  [nsview-effective-appearance (c-> nsview? (or/c nsappearance? objc-nil?))]
  [nsview-encode-with-coder (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-end-gesture-with-event! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-flags-changed (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-flush-buffered-key-events (c-> nsview? void?)]
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
  [nsview-is-flipped (c-> nsview? boolean?)]
  [nsview-is-hidden (c-> nsview? boolean?)]
  [nsview-is-hidden-or-has-hidden-ancestor (c-> nsview? boolean?)]
  [nsview-is-opaque (c-> nsview? boolean?)]
  [nsview-is-rotated-from-base (c-> nsview? boolean?)]
  [nsview-is-rotated-or-scaled-from-base (c-> nsview? boolean?)]
  [nsview-key-down (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-key-up (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-layout (c-> nsview? void?)]
  [nsview-layout-subtree-if-needed (c-> nsview? void?)]
  [nsview-lowercase-word (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-magnify-with-event (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-make-backing-layer (c-> nsview? (or/c calayer? objc-nil?))]
  [nsview-make-base-writing-direction-left-to-right (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-make-base-writing-direction-natural (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-make-base-writing-direction-right-to-left (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-make-text-writing-direction-left-to-right (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-make-text-writing-direction-natural (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-make-text-writing-direction-right-to-left (c-> nsview? (or/c string? objc-object? #f) void?)]
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
  [nsview-no-responder-for (c-> nsview? string? void?)]
  [nsview-other-mouse-down (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-other-mouse-dragged (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-other-mouse-up (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-page-down (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-page-down-and-modify-selection (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-page-up (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-page-up-and-modify-selection (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-perform-drag-operation! (c-> nsview? (or/c string? objc-object? #f) boolean?)]
  [nsview-perform-key-equivalent! (c-> nsview? (or/c string? objc-object? #f) boolean?)]
  [nsview-prepare-content-in-rect (c-> nsview? any/c void?)]
  [nsview-prepare-for-drag-operation (c-> nsview? (or/c string? objc-object? #f) boolean?)]
  [nsview-prepare-for-reuse (c-> nsview? void?)]
  [nsview-pressure-change-with-event (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-quick-look-preview-items (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-quick-look-with-event (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-rect-for-smart-magnification-at-point-in-rect (c-> nsview? any/c any/c any/c)]
  [nsview-remove-all-tool-tips! (c-> nsview? void?)]
  [nsview-remove-from-superview! (c-> nsview? void?)]
  [nsview-remove-from-superview-without-needing-display! (c-> nsview? void?)]
  [nsview-remove-tool-tip! (c-> nsview? exact-integer? void?)]
  [nsview-replace-subview-with! (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsview-resign-first-responder (c-> nsview? boolean?)]
  [nsview-resize-subviews-with-old-size (c-> nsview? any/c void?)]
  [nsview-resize-with-old-superview-size (c-> nsview? any/c void?)]
  [nsview-restore-user-activity-state (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-right-mouse-down (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-right-mouse-dragged (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-right-mouse-up (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-rotate-by-angle (c-> nsview? real? void?)]
  [nsview-rotate-with-event (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-scale-unit-square-to-size (c-> nsview? any/c void?)]
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
  [nsview-set-accessibility-horizontal-units! (c-> nsview? exact-nonnegative-integer? void?)]
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
  [nsview-set-accessibility-orientation! (c-> nsview? exact-nonnegative-integer? void?)]
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
  [nsview-set-accessibility-ruler-marker-type! (c-> nsview? exact-nonnegative-integer? void?)]
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
  [nsview-set-accessibility-sort-direction! (c-> nsview? exact-nonnegative-integer? void?)]
  [nsview-set-accessibility-splitters! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-subrole! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-tabs! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-title! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-title-ui-element! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-toolbar-button! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-top-level-ui-element! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-url! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-unit-description! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-units! (c-> nsview? exact-nonnegative-integer? void?)]
  [nsview-set-accessibility-user-input-labels! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-value! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-value-description! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-vertical-scroll-bar! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-vertical-unit-description! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-accessibility-vertical-units! (c-> nsview? exact-nonnegative-integer? void?)]
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
  [nsview-set-frame-origin! (c-> nsview? any/c void?)]
  [nsview-set-frame-size! (c-> nsview? any/c void?)]
  [nsview-set-identifier! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-mark! (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-set-needs-display-in-rect! (c-> nsview? any/c void?)]
  [nsview-should-be-treated-as-ink-event (c-> nsview? (or/c string? objc-object? #f) boolean?)]
  [nsview-should-delay-window-ordering-for-event (c-> nsview? (or/c string? objc-object? #f) boolean?)]
  [nsview-show-context-help (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-show-context-menu-for-selection (c-> nsview? (or/c string? objc-object? #f) void?)]
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
  [nsview-update-dragging-items-for-drag (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-update-layer (c-> nsview? void?)]
  [nsview-uppercase-word (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-valid-requestor-for-send-type-return-type (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
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
  [nsview-view-with-tag (c-> nsview? exact-integer? any/c)]
  [nsview-wants-forwarded-scroll-events-for-axis (c-> nsview? exact-nonnegative-integer? boolean?)]
  [nsview-wants-periodic-dragging-updates (c-> nsview? boolean?)]
  [nsview-wants-scroll-events-for-swipe-tracking-on-axis (c-> nsview? exact-nonnegative-integer? boolean?)]
  [nsview-will-open-menu-with-event (c-> nsview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsview-will-remove-subview (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-yank (c-> nsview? (or/c string? objc-object? #f) void?)]
  [nsview-default-animation-for-key (c-> (or/c string? objc-object? #f) any/c)]
  [nsview-is-compatible-with-responsive-scrolling (c-> boolean?)]
  )

;; --- Class reference ---
(import-class NSView)

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
(define _msg-33  ; (_fun _pointer _pointer _float -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _float -> _void)))
(define _msg-34  ; (_fun _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _bool)))
(define _msg-35  ; (_fun _pointer _pointer _id -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _uint64)))
(define _msg-36  ; (_fun _pointer _pointer _id _int64 _id -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _int64 _id -> _void)))
(define _msg-37  ; (_fun _pointer _pointer _int64 -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _NSRange)))
(define _msg-38  ; (_fun _pointer _pointer _int64 -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _bool)))
(define _msg-39  ; (_fun _pointer _pointer _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _id)))
(define _msg-40  ; (_fun _pointer _pointer _int64 -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _int64)))
(define _msg-41  ; (_fun _pointer _pointer _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _void)))
(define _msg-42  ; (_fun _pointer _pointer _int64 _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _int64 -> _id)))
(define _msg-43  ; (_fun _pointer _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _bool)))
(define _msg-44  ; (_fun _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _void)))
(define _msg-45  ; (_fun _pointer _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _bool)))
(define _msg-46  ; (_fun _pointer _pointer _pointer _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _id)))
(define _msg-47  ; (_fun _pointer _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _pointer -> _void)))
(define _msg-48  ; (_fun _pointer _pointer _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _void)))

;; --- Constructors ---
(define (make-nsview-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSView alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nsview-init-with-frame frame-rect)
  (wrap-objc-object
   (_msg-21 (tell NSView alloc)
       (sel_registerName "initWithFrame:")
       frame-rect)
   #:retained #t))


;; --- Properties ---
(define (nsview-accepts-first-responder self)
  (tell #:type _bool (coerce-arg self) acceptsFirstResponder))
(define (nsview-accepts-touch-events self)
  (tell #:type _bool (coerce-arg self) acceptsTouchEvents))
(define (nsview-set-accepts-touch-events! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setAcceptsTouchEvents:") value))
(define (nsview-additional-safe-area-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) additionalSafeAreaInsets))
(define (nsview-set-additional-safe-area-insets! self value)
  (_msg-8 (coerce-arg self) (sel_registerName "setAdditionalSafeAreaInsets:") value))
(define (nsview-alignment-rect-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) alignmentRectInsets))
(define (nsview-allowed-touch-types self)
  (tell #:type _uint64 (coerce-arg self) allowedTouchTypes))
(define (nsview-set-allowed-touch-types! self value)
  (_msg-48 (coerce-arg self) (sel_registerName "setAllowedTouchTypes:") value))
(define (nsview-allows-vibrancy self)
  (tell #:type _bool (coerce-arg self) allowsVibrancy))
(define (nsview-alpha-value self)
  (tell #:type _double (coerce-arg self) alphaValue))
(define (nsview-set-alpha-value! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setAlphaValue:") value))
(define (nsview-autoresizes-subviews self)
  (tell #:type _bool (coerce-arg self) autoresizesSubviews))
(define (nsview-set-autoresizes-subviews! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setAutoresizesSubviews:") value))
(define (nsview-autoresizing-mask self)
  (tell #:type _uint64 (coerce-arg self) autoresizingMask))
(define (nsview-set-autoresizing-mask! self value)
  (_msg-48 (coerce-arg self) (sel_registerName "setAutoresizingMask:") value))
(define (nsview-background-filters self)
  (wrap-objc-object
   (tell (coerce-arg self) backgroundFilters)))
(define (nsview-set-background-filters! self value)
  (tell #:type _void (coerce-arg self) setBackgroundFilters: (coerce-arg value)))
(define (nsview-baseline-offset-from-bottom self)
  (tell #:type _double (coerce-arg self) baselineOffsetFromBottom))
(define (nsview-bottom-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) bottomAnchor)))
(define (nsview-bounds self)
  (tell #:type _NSRect (coerce-arg self) bounds))
(define (nsview-set-bounds! self value)
  (_msg-22 (coerce-arg self) (sel_registerName "setBounds:") value))
(define (nsview-bounds-rotation self)
  (tell #:type _double (coerce-arg self) boundsRotation))
(define (nsview-set-bounds-rotation! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setBoundsRotation:") value))
(define (nsview-can-become-key-view self)
  (tell #:type _bool (coerce-arg self) canBecomeKeyView))
(define (nsview-can-draw self)
  (tell #:type _bool (coerce-arg self) canDraw))
(define (nsview-can-draw-concurrently self)
  (tell #:type _bool (coerce-arg self) canDrawConcurrently))
(define (nsview-set-can-draw-concurrently! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setCanDrawConcurrently:") value))
(define (nsview-can-draw-subviews-into-layer self)
  (tell #:type _bool (coerce-arg self) canDrawSubviewsIntoLayer))
(define (nsview-set-can-draw-subviews-into-layer! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setCanDrawSubviewsIntoLayer:") value))
(define (nsview-candidate-list-touch-bar-item self)
  (wrap-objc-object
   (tell (coerce-arg self) candidateListTouchBarItem)))
(define (nsview-center-x-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) centerXAnchor)))
(define (nsview-center-y-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) centerYAnchor)))
(define (nsview-clips-to-bounds self)
  (tell #:type _bool (coerce-arg self) clipsToBounds))
(define (nsview-set-clips-to-bounds! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setClipsToBounds:") value))
(define (nsview-compatible-with-responsive-scrolling)
  (tell #:type _bool NSView compatibleWithResponsiveScrolling))
(define (nsview-compositing-filter self)
  (wrap-objc-object
   (tell (coerce-arg self) compositingFilter)))
(define (nsview-set-compositing-filter! self value)
  (tell #:type _void (coerce-arg self) setCompositingFilter: (coerce-arg value)))
(define (nsview-constraints self)
  (wrap-objc-object
   (tell (coerce-arg self) constraints)))
(define (nsview-content-filters self)
  (wrap-objc-object
   (tell (coerce-arg self) contentFilters)))
(define (nsview-set-content-filters! self value)
  (tell #:type _void (coerce-arg self) setContentFilters: (coerce-arg value)))
(define (nsview-default-focus-ring-type)
  (tell #:type _uint64 NSView defaultFocusRingType))
(define (nsview-default-menu)
  (wrap-objc-object
   (tell NSView defaultMenu)))
(define (nsview-drawing-find-indicator self)
  (tell #:type _bool (coerce-arg self) drawingFindIndicator))
(define (nsview-enclosing-menu-item self)
  (wrap-objc-object
   (tell (coerce-arg self) enclosingMenuItem)))
(define (nsview-enclosing-scroll-view self)
  (wrap-objc-object
   (tell (coerce-arg self) enclosingScrollView)))
(define (nsview-first-baseline-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) firstBaselineAnchor)))
(define (nsview-first-baseline-offset-from-top self)
  (tell #:type _double (coerce-arg self) firstBaselineOffsetFromTop))
(define (nsview-fitting-size self)
  (tell #:type _NSSize (coerce-arg self) fittingSize))
(define (nsview-flipped self)
  (tell #:type _bool (coerce-arg self) flipped))
(define (nsview-focus-ring-mask-bounds self)
  (tell #:type _NSRect (coerce-arg self) focusRingMaskBounds))
(define (nsview-focus-ring-type self)
  (tell #:type _uint64 (coerce-arg self) focusRingType))
(define (nsview-set-focus-ring-type! self value)
  (_msg-48 (coerce-arg self) (sel_registerName "setFocusRingType:") value))
(define (nsview-focus-view)
  (wrap-objc-object
   (tell NSView focusView)))
(define (nsview-frame self)
  (tell #:type _NSRect (coerce-arg self) frame))
(define (nsview-set-frame! self value)
  (_msg-22 (coerce-arg self) (sel_registerName "setFrame:") value))
(define (nsview-frame-center-rotation self)
  (tell #:type _double (coerce-arg self) frameCenterRotation))
(define (nsview-set-frame-center-rotation! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setFrameCenterRotation:") value))
(define (nsview-frame-rotation self)
  (tell #:type _double (coerce-arg self) frameRotation))
(define (nsview-set-frame-rotation! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setFrameRotation:") value))
(define (nsview-gesture-recognizers self)
  (wrap-objc-object
   (tell (coerce-arg self) gestureRecognizers)))
(define (nsview-set-gesture-recognizers! self value)
  (tell #:type _void (coerce-arg self) setGestureRecognizers: (coerce-arg value)))
(define (nsview-has-ambiguous-layout self)
  (tell #:type _bool (coerce-arg self) hasAmbiguousLayout))
(define (nsview-height-adjust-limit self)
  (tell #:type _double (coerce-arg self) heightAdjustLimit))
(define (nsview-height-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) heightAnchor)))
(define (nsview-hidden self)
  (tell #:type _bool (coerce-arg self) hidden))
(define (nsview-set-hidden! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setHidden:") value))
(define (nsview-hidden-or-has-hidden-ancestor self)
  (tell #:type _bool (coerce-arg self) hiddenOrHasHiddenAncestor))
(define (nsview-horizontal-content-size-constraint-active self)
  (tell #:type _bool (coerce-arg self) horizontalContentSizeConstraintActive))
(define (nsview-set-horizontal-content-size-constraint-active! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setHorizontalContentSizeConstraintActive:") value))
(define (nsview-in-full-screen-mode self)
  (tell #:type _bool (coerce-arg self) inFullScreenMode))
(define (nsview-in-live-resize self)
  (tell #:type _bool (coerce-arg self) inLiveResize))
(define (nsview-input-context self)
  (wrap-objc-object
   (tell (coerce-arg self) inputContext)))
(define (nsview-intrinsic-content-size self)
  (tell #:type _NSSize (coerce-arg self) intrinsicContentSize))
(define (nsview-last-baseline-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) lastBaselineAnchor)))
(define (nsview-last-baseline-offset-from-bottom self)
  (tell #:type _double (coerce-arg self) lastBaselineOffsetFromBottom))
(define (nsview-layer self)
  (wrap-objc-object
   (tell (coerce-arg self) layer)))
(define (nsview-set-layer! self value)
  (tell #:type _void (coerce-arg self) setLayer: (coerce-arg value)))
(define (nsview-layer-contents-placement self)
  (tell #:type _int64 (coerce-arg self) layerContentsPlacement))
(define (nsview-set-layer-contents-placement! self value)
  (_msg-41 (coerce-arg self) (sel_registerName "setLayerContentsPlacement:") value))
(define (nsview-layer-contents-redraw-policy self)
  (tell #:type _int64 (coerce-arg self) layerContentsRedrawPolicy))
(define (nsview-set-layer-contents-redraw-policy! self value)
  (_msg-41 (coerce-arg self) (sel_registerName "setLayerContentsRedrawPolicy:") value))
(define (nsview-layer-uses-core-image-filters self)
  (tell #:type _bool (coerce-arg self) layerUsesCoreImageFilters))
(define (nsview-set-layer-uses-core-image-filters! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setLayerUsesCoreImageFilters:") value))
(define (nsview-layout-guides self)
  (wrap-objc-object
   (tell (coerce-arg self) layoutGuides)))
(define (nsview-layout-margins-guide self)
  (wrap-objc-object
   (tell (coerce-arg self) layoutMarginsGuide)))
(define (nsview-leading-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) leadingAnchor)))
(define (nsview-left-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) leftAnchor)))
(define (nsview-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) menu)))
(define (nsview-set-menu! self value)
  (tell #:type _void (coerce-arg self) setMenu: (coerce-arg value)))
(define (nsview-mouse-down-can-move-window self)
  (tell #:type _bool (coerce-arg self) mouseDownCanMoveWindow))
(define (nsview-needs-display self)
  (tell #:type _bool (coerce-arg self) needsDisplay))
(define (nsview-set-needs-display! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setNeedsDisplay:") value))
(define (nsview-needs-layout self)
  (tell #:type _bool (coerce-arg self) needsLayout))
(define (nsview-set-needs-layout! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setNeedsLayout:") value))
(define (nsview-needs-panel-to-become-key self)
  (tell #:type _bool (coerce-arg self) needsPanelToBecomeKey))
(define (nsview-needs-update-constraints self)
  (tell #:type _bool (coerce-arg self) needsUpdateConstraints))
(define (nsview-set-needs-update-constraints! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setNeedsUpdateConstraints:") value))
(define (nsview-next-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) nextKeyView)))
(define (nsview-set-next-key-view! self value)
  (tell #:type _void (coerce-arg self) setNextKeyView: (coerce-arg value)))
(define (nsview-next-responder self)
  (wrap-objc-object
   (tell (coerce-arg self) nextResponder)))
(define (nsview-set-next-responder! self value)
  (tell #:type _void (coerce-arg self) setNextResponder: (coerce-arg value)))
(define (nsview-next-valid-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) nextValidKeyView)))
(define (nsview-opaque self)
  (tell #:type _bool (coerce-arg self) opaque))
(define (nsview-opaque-ancestor self)
  (wrap-objc-object
   (tell (coerce-arg self) opaqueAncestor)))
(define (nsview-page-footer self)
  (wrap-objc-object
   (tell (coerce-arg self) pageFooter)))
(define (nsview-page-header self)
  (wrap-objc-object
   (tell (coerce-arg self) pageHeader)))
(define (nsview-posts-bounds-changed-notifications self)
  (tell #:type _bool (coerce-arg self) postsBoundsChangedNotifications))
(define (nsview-set-posts-bounds-changed-notifications! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setPostsBoundsChangedNotifications:") value))
(define (nsview-posts-frame-changed-notifications self)
  (tell #:type _bool (coerce-arg self) postsFrameChangedNotifications))
(define (nsview-set-posts-frame-changed-notifications! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setPostsFrameChangedNotifications:") value))
(define (nsview-prefers-compact-control-size-metrics self)
  (tell #:type _bool (coerce-arg self) prefersCompactControlSizeMetrics))
(define (nsview-set-prefers-compact-control-size-metrics! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setPrefersCompactControlSizeMetrics:") value))
(define (nsview-prepared-content-rect self)
  (tell #:type _NSRect (coerce-arg self) preparedContentRect))
(define (nsview-set-prepared-content-rect! self value)
  (_msg-22 (coerce-arg self) (sel_registerName "setPreparedContentRect:") value))
(define (nsview-preserves-content-during-live-resize self)
  (tell #:type _bool (coerce-arg self) preservesContentDuringLiveResize))
(define (nsview-pressure-configuration self)
  (wrap-objc-object
   (tell (coerce-arg self) pressureConfiguration)))
(define (nsview-set-pressure-configuration! self value)
  (tell #:type _void (coerce-arg self) setPressureConfiguration: (coerce-arg value)))
(define (nsview-previous-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) previousKeyView)))
(define (nsview-previous-valid-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) previousValidKeyView)))
(define (nsview-print-job-title self)
  (wrap-objc-object
   (tell (coerce-arg self) printJobTitle)))
(define (nsview-rect-preserved-during-live-resize self)
  (tell #:type _NSRect (coerce-arg self) rectPreservedDuringLiveResize))
(define (nsview-registered-dragged-types self)
  (wrap-objc-object
   (tell (coerce-arg self) registeredDraggedTypes)))
(define (nsview-requires-constraint-based-layout)
  (tell #:type _bool NSView requiresConstraintBasedLayout))
(define (nsview-restorable-state-key-paths)
  (wrap-objc-object
   (tell NSView restorableStateKeyPaths)))
(define (nsview-right-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) rightAnchor)))
(define (nsview-rotated-from-base self)
  (tell #:type _bool (coerce-arg self) rotatedFromBase))
(define (nsview-rotated-or-scaled-from-base self)
  (tell #:type _bool (coerce-arg self) rotatedOrScaledFromBase))
(define (nsview-safe-area-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) safeAreaInsets))
(define (nsview-safe-area-layout-guide self)
  (wrap-objc-object
   (tell (coerce-arg self) safeAreaLayoutGuide)))
(define (nsview-safe-area-rect self)
  (tell #:type _NSRect (coerce-arg self) safeAreaRect))
(define (nsview-shadow self)
  (wrap-objc-object
   (tell (coerce-arg self) shadow)))
(define (nsview-set-shadow! self value)
  (tell #:type _void (coerce-arg self) setShadow: (coerce-arg value)))
(define (nsview-subviews self)
  (wrap-objc-object
   (tell (coerce-arg self) subviews)))
(define (nsview-set-subviews! self value)
  (tell #:type _void (coerce-arg self) setSubviews: (coerce-arg value)))
(define (nsview-superview self)
  (wrap-objc-object
   (tell (coerce-arg self) superview)))
(define (nsview-tag self)
  (tell #:type _int64 (coerce-arg self) tag))
(define (nsview-tool-tip self)
  (wrap-objc-object
   (tell (coerce-arg self) toolTip)))
(define (nsview-set-tool-tip! self value)
  (tell #:type _void (coerce-arg self) setToolTip: (coerce-arg value)))
(define (nsview-top-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) topAnchor)))
(define (nsview-touch-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) touchBar)))
(define (nsview-set-touch-bar! self value)
  (tell #:type _void (coerce-arg self) setTouchBar: (coerce-arg value)))
(define (nsview-tracking-areas self)
  (wrap-objc-object
   (tell (coerce-arg self) trackingAreas)))
(define (nsview-trailing-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) trailingAnchor)))
(define (nsview-translates-autoresizing-mask-into-constraints self)
  (tell #:type _bool (coerce-arg self) translatesAutoresizingMaskIntoConstraints))
(define (nsview-set-translates-autoresizing-mask-into-constraints! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setTranslatesAutoresizingMaskIntoConstraints:") value))
(define (nsview-undo-manager self)
  (wrap-objc-object
   (tell (coerce-arg self) undoManager)))
(define (nsview-user-activity self)
  (wrap-objc-object
   (tell (coerce-arg self) userActivity)))
(define (nsview-set-user-activity! self value)
  (tell #:type _void (coerce-arg self) setUserActivity: (coerce-arg value)))
(define (nsview-user-interface-layout-direction self)
  (tell #:type _int64 (coerce-arg self) userInterfaceLayoutDirection))
(define (nsview-set-user-interface-layout-direction! self value)
  (_msg-41 (coerce-arg self) (sel_registerName "setUserInterfaceLayoutDirection:") value))
(define (nsview-vertical-content-size-constraint-active self)
  (tell #:type _bool (coerce-arg self) verticalContentSizeConstraintActive))
(define (nsview-set-vertical-content-size-constraint-active! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setVerticalContentSizeConstraintActive:") value))
(define (nsview-visible-rect self)
  (tell #:type _NSRect (coerce-arg self) visibleRect))
(define (nsview-wants-best-resolution-open-gl-surface self)
  (tell #:type _bool (coerce-arg self) wantsBestResolutionOpenGLSurface))
(define (nsview-set-wants-best-resolution-open-gl-surface! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setWantsBestResolutionOpenGLSurface:") value))
(define (nsview-wants-default-clipping self)
  (tell #:type _bool (coerce-arg self) wantsDefaultClipping))
(define (nsview-wants-extended-dynamic-range-open-gl-surface self)
  (tell #:type _bool (coerce-arg self) wantsExtendedDynamicRangeOpenGLSurface))
(define (nsview-set-wants-extended-dynamic-range-open-gl-surface! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setWantsExtendedDynamicRangeOpenGLSurface:") value))
(define (nsview-wants-layer self)
  (tell #:type _bool (coerce-arg self) wantsLayer))
(define (nsview-set-wants-layer! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setWantsLayer:") value))
(define (nsview-wants-resting-touches self)
  (tell #:type _bool (coerce-arg self) wantsRestingTouches))
(define (nsview-set-wants-resting-touches! self value)
  (_msg-31 (coerce-arg self) (sel_registerName "setWantsRestingTouches:") value))
(define (nsview-wants-update-layer self)
  (tell #:type _bool (coerce-arg self) wantsUpdateLayer))
(define (nsview-width-adjust-limit self)
  (tell #:type _double (coerce-arg self) widthAdjustLimit))
(define (nsview-width-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) widthAnchor)))
(define (nsview-window self)
  (wrap-objc-object
   (tell (coerce-arg self) window)))
(define (nsview-writing-tools-coordinator self)
  (wrap-objc-object
   (tell (coerce-arg self) writingToolsCoordinator)))
(define (nsview-set-writing-tools-coordinator! self value)
  (tell #:type _void (coerce-arg self) setWritingToolsCoordinator: (coerce-arg value)))

;; --- Instance methods ---
(define (nsview-accepts-first-mouse self event)
  (_msg-34 (coerce-arg self) (sel_registerName "acceptsFirstMouse:") (coerce-arg event)))
(define (nsview-accessibility-activation-point self)
  (_msg-0 (coerce-arg self) (sel_registerName "accessibilityActivationPoint")))
(define (nsview-accessibility-allowed-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAllowedValues)))
(define (nsview-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityApplicationFocusedUIElement)))
(define (nsview-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (_msg-17 (coerce-arg self) (sel_registerName "accessibilityAttributedStringForRange:") range)
   ))
(define (nsview-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAttributedUserInputLabels)))
(define (nsview-accessibility-cancel-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCancelButton)))
(define (nsview-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (_msg-42 (coerce-arg self) (sel_registerName "accessibilityCellForColumn:row:") column row)
   ))
(define (nsview-accessibility-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildren)))
(define (nsview-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildrenInNavigationOrder)))
(define (nsview-accessibility-clear-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityClearButton)))
(define (nsview-accessibility-close-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCloseButton)))
(define (nsview-accessibility-column-count self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityColumnCount")))
(define (nsview-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnHeaderUIElements)))
(define (nsview-accessibility-column-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityColumnIndexRange")))
(define (nsview-accessibility-column-titles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnTitles)))
(define (nsview-accessibility-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumns)))
(define (nsview-accessibility-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityContents)))
(define (nsview-accessibility-critical-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCriticalValue)))
(define (nsview-accessibility-custom-actions self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomActions)))
(define (nsview-accessibility-custom-rotors self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomRotors)))
(define (nsview-accessibility-decrement-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDecrementButton)))
(define (nsview-accessibility-default-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDefaultButton)))
(define (nsview-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedByRow)))
(define (nsview-accessibility-disclosed-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedRows)))
(define (nsview-accessibility-disclosure-level self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityDisclosureLevel")))
(define (nsview-accessibility-document self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDocument)))
(define (nsview-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityExtrasMenuBar)))
(define (nsview-accessibility-filename self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFilename)))
(define (nsview-accessibility-focused-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFocusedWindow)))
(define (nsview-accessibility-frame self)
  (_msg-2 (coerce-arg self) (sel_registerName "accessibilityFrame")))
(define (nsview-accessibility-frame-for-range self range)
  (_msg-16 (coerce-arg self) (sel_registerName "accessibilityFrameForRange:") range))
(define (nsview-accessibility-full-screen-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFullScreenButton)))
(define (nsview-accessibility-grow-area self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityGrowArea)))
(define (nsview-accessibility-handles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHandles)))
(define (nsview-accessibility-header self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHeader)))
(define (nsview-accessibility-help self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHelp)))
(define (nsview-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalScrollBar)))
(define (nsview-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalUnitDescription)))
(define (nsview-accessibility-horizontal-units self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityHorizontalUnits")))
(define (nsview-accessibility-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIdentifier)))
(define (nsview-accessibility-increment-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIncrementButton)))
(define (nsview-accessibility-index self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityIndex")))
(define (nsview-accessibility-insertion-point-line-number self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityInsertionPointLineNumber")))
(define (nsview-accessibility-label self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabel)))
(define (nsview-accessibility-label-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabelUIElements)))
(define (nsview-accessibility-label-value self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityLabelValue")))
(define (nsview-accessibility-layout-point-for-screen-point self point)
  (_msg-9 (coerce-arg self) (sel_registerName "accessibilityLayoutPointForScreenPoint:") point))
(define (nsview-accessibility-layout-size-for-screen-size self size)
  (_msg-28 (coerce-arg self) (sel_registerName "accessibilityLayoutSizeForScreenSize:") size))
(define (nsview-accessibility-line-for-index self index)
  (_msg-40 (coerce-arg self) (sel_registerName "accessibilityLineForIndex:") index))
(define (nsview-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLinkedUIElements)))
(define (nsview-accessibility-main-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMainWindow)))
(define (nsview-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerGroupUIElement)))
(define (nsview-accessibility-marker-type-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerTypeDescription)))
(define (nsview-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerUIElements)))
(define (nsview-accessibility-marker-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerValues)))
(define (nsview-accessibility-max-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMaxValue)))
(define (nsview-accessibility-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMenuBar)))
(define (nsview-accessibility-min-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinValue)))
(define (nsview-accessibility-minimize-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinimizeButton)))
(define (nsview-accessibility-next-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityNextContents)))
(define (nsview-accessibility-number-of-characters self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityNumberOfCharacters")))
(define (nsview-accessibility-orientation self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityOrientation")))
(define (nsview-accessibility-overflow-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityOverflowButton)))
(define (nsview-accessibility-parent self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityParent)))
(define (nsview-accessibility-perform-cancel self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformCancel")))
(define (nsview-accessibility-perform-confirm self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformConfirm")))
(define (nsview-accessibility-perform-decrement self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformDecrement")))
(define (nsview-accessibility-perform-delete self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformDelete")))
(define (nsview-accessibility-perform-increment self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformIncrement")))
(define (nsview-accessibility-perform-pick self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformPick")))
(define (nsview-accessibility-perform-press self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformPress")))
(define (nsview-accessibility-perform-raise self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformRaise")))
(define (nsview-accessibility-perform-show-alternate-ui self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowAlternateUI")))
(define (nsview-accessibility-perform-show-default-ui self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowDefaultUI")))
(define (nsview-accessibility-perform-show-menu self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowMenu")))
(define (nsview-accessibility-placeholder-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPlaceholderValue)))
(define (nsview-accessibility-previous-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPreviousContents)))
(define (nsview-accessibility-proxy self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityProxy)))
(define (nsview-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (_msg-17 (coerce-arg self) (sel_registerName "accessibilityRTFForRange:") range)
   ))
(define (nsview-accessibility-range-for-index self index)
  (_msg-37 (coerce-arg self) (sel_registerName "accessibilityRangeForIndex:") index))
(define (nsview-accessibility-range-for-line self line)
  (_msg-37 (coerce-arg self) (sel_registerName "accessibilityRangeForLine:") line))
(define (nsview-accessibility-range-for-position self point)
  (_msg-10 (coerce-arg self) (sel_registerName "accessibilityRangeForPosition:") point))
(define (nsview-accessibility-role self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRole)))
(define (nsview-accessibility-role-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRoleDescription)))
(define (nsview-accessibility-row-count self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityRowCount")))
(define (nsview-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRowHeaderUIElements)))
(define (nsview-accessibility-row-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityRowIndexRange")))
(define (nsview-accessibility-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRows)))
(define (nsview-accessibility-ruler-marker-type self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityRulerMarkerType")))
(define (nsview-accessibility-screen-point-for-layout-point self point)
  (_msg-9 (coerce-arg self) (sel_registerName "accessibilityScreenPointForLayoutPoint:") point))
(define (nsview-accessibility-screen-size-for-layout-size self size)
  (_msg-28 (coerce-arg self) (sel_registerName "accessibilityScreenSizeForLayoutSize:") size))
(define (nsview-accessibility-search-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchButton)))
(define (nsview-accessibility-search-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchMenu)))
(define (nsview-accessibility-selected-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedCells)))
(define (nsview-accessibility-selected-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedChildren)))
(define (nsview-accessibility-selected-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedColumns)))
(define (nsview-accessibility-selected-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedRows)))
(define (nsview-accessibility-selected-text self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedText)))
(define (nsview-accessibility-selected-text-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySelectedTextRange")))
(define (nsview-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedTextRanges)))
(define (nsview-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityServesAsTitleForUIElements)))
(define (nsview-accessibility-shared-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySharedCharacterRange")))
(define (nsview-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedFocusElements)))
(define (nsview-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedTextUIElements)))
(define (nsview-accessibility-shown-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityShownMenu)))
(define (nsview-accessibility-sort-direction self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilitySortDirection")))
(define (nsview-accessibility-splitters self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySplitters)))
(define (nsview-accessibility-string-for-range self range)
  (wrap-objc-object
   (_msg-17 (coerce-arg self) (sel_registerName "accessibilityStringForRange:") range)
   ))
(define (nsview-accessibility-style-range-for-index self index)
  (_msg-37 (coerce-arg self) (sel_registerName "accessibilityStyleRangeForIndex:") index))
(define (nsview-accessibility-subrole self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySubrole)))
(define (nsview-accessibility-tabs self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTabs)))
(define (nsview-accessibility-title self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitle)))
(define (nsview-accessibility-title-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitleUIElement)))
(define (nsview-accessibility-toolbar-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityToolbarButton)))
(define (nsview-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTopLevelUIElement)))
(define (nsview-accessibility-url self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityURL)))
(define (nsview-accessibility-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUnitDescription)))
(define (nsview-accessibility-units self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityUnits")))
(define (nsview-accessibility-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUserInputLabels)))
(define (nsview-accessibility-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValue)))
(define (nsview-accessibility-value-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValueDescription)))
(define (nsview-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalScrollBar)))
(define (nsview-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalUnitDescription)))
(define (nsview-accessibility-vertical-units self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityVerticalUnits")))
(define (nsview-accessibility-visible-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleCells)))
(define (nsview-accessibility-visible-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityVisibleCharacterRange")))
(define (nsview-accessibility-visible-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleChildren)))
(define (nsview-accessibility-visible-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleColumns)))
(define (nsview-accessibility-visible-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleRows)))
(define (nsview-accessibility-warning-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWarningValue)))
(define (nsview-accessibility-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindow)))
(define (nsview-accessibility-windows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindows)))
(define (nsview-accessibility-zoom-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityZoomButton)))
(define (nsview-add-subview! self view)
  (tell #:type _void (coerce-arg self) addSubview: (coerce-arg view)))
(define (nsview-add-subview-positioned-relative-to! self view place other-view)
  (_msg-36 (coerce-arg self) (sel_registerName "addSubview:positioned:relativeTo:") (coerce-arg view) place (coerce-arg other-view)))
(define (nsview-add-tool-tip-rect-owner-user-data! self rect owner data)
  (_msg-26 (coerce-arg self) (sel_registerName "addToolTipRect:owner:userData:") rect (coerce-arg owner) data))
(define (nsview-adjust-scroll self new-visible)
  (_msg-19 (coerce-arg self) (sel_registerName "adjustScroll:") new-visible))
(define (nsview-ancestor-shared-with-view self view)
  (wrap-objc-object
   (tell (coerce-arg self) ancestorSharedWithView: (coerce-arg view))))
(define (nsview-animation-for-key self key)
  (wrap-objc-object
   (tell (coerce-arg self) animationForKey: (coerce-arg key))))
(define (nsview-animations self)
  (wrap-objc-object
   (tell (coerce-arg self) animations)))
(define (nsview-animator self)
  (wrap-objc-object
   (tell (coerce-arg self) animator)))
(define (nsview-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) appearance)))
(define (nsview-autoscroll self event)
  (_msg-34 (coerce-arg self) (sel_registerName "autoscroll:") (coerce-arg event)))
(define (nsview-backing-aligned-rect-options self rect options)
  (_msg-27 (coerce-arg self) (sel_registerName "backingAlignedRect:options:") rect options))
(define (nsview-become-first-responder self)
  (_msg-3 (coerce-arg self) (sel_registerName "becomeFirstResponder")))
(define (nsview-begin-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) beginGestureWithEvent: (coerce-arg event)))
(define (nsview-bitmap-image-rep-for-caching-display-in-rect self rect)
  (wrap-objc-object
   (_msg-21 (coerce-arg self) (sel_registerName "bitmapImageRepForCachingDisplayInRect:") rect)
   ))
(define (nsview-cache-display-in-rect-to-bitmap-image-rep self rect bitmap-image-rep)
  (_msg-25 (coerce-arg self) (sel_registerName "cacheDisplayInRect:toBitmapImageRep:") rect (coerce-arg bitmap-image-rep)))
(define (nsview-cancel-operation self sender)
  (tell #:type _void (coerce-arg self) cancelOperation: (coerce-arg sender)))
(define (nsview-capitalize-word self sender)
  (tell #:type _void (coerce-arg self) capitalizeWord: (coerce-arg sender)))
(define (nsview-center-scan-rect! self rect)
  (_msg-19 (coerce-arg self) (sel_registerName "centerScanRect:") rect))
(define (nsview-center-selection-in-visible-area! self sender)
  (tell #:type _void (coerce-arg self) centerSelectionInVisibleArea: (coerce-arg sender)))
(define (nsview-change-case-of-letter self sender)
  (tell #:type _void (coerce-arg self) changeCaseOfLetter: (coerce-arg sender)))
(define (nsview-change-mode-with-event self event)
  (tell #:type _void (coerce-arg self) changeModeWithEvent: (coerce-arg event)))
(define (nsview-complete self sender)
  (tell #:type _void (coerce-arg self) complete: (coerce-arg sender)))
(define (nsview-conclude-drag-operation self sender)
  (tell #:type _void (coerce-arg self) concludeDragOperation: (coerce-arg sender)))
(define (nsview-context-menu-key-down self event)
  (tell #:type _void (coerce-arg self) contextMenuKeyDown: (coerce-arg event)))
(define (nsview-convert-point-from-view self point view)
  (_msg-15 (coerce-arg self) (sel_registerName "convertPoint:fromView:") point (coerce-arg view)))
(define (nsview-convert-point-to-view self point view)
  (_msg-15 (coerce-arg self) (sel_registerName "convertPoint:toView:") point (coerce-arg view)))
(define (nsview-convert-point-from-backing self point)
  (_msg-9 (coerce-arg self) (sel_registerName "convertPointFromBacking:") point))
(define (nsview-convert-point-from-layer self point)
  (_msg-9 (coerce-arg self) (sel_registerName "convertPointFromLayer:") point))
(define (nsview-convert-point-to-backing self point)
  (_msg-9 (coerce-arg self) (sel_registerName "convertPointToBacking:") point))
(define (nsview-convert-point-to-layer self point)
  (_msg-9 (coerce-arg self) (sel_registerName "convertPointToLayer:") point))
(define (nsview-convert-rect-from-view self rect view)
  (_msg-24 (coerce-arg self) (sel_registerName "convertRect:fromView:") rect (coerce-arg view)))
(define (nsview-convert-rect-to-view self rect view)
  (_msg-24 (coerce-arg self) (sel_registerName "convertRect:toView:") rect (coerce-arg view)))
(define (nsview-convert-rect-from-backing self rect)
  (_msg-19 (coerce-arg self) (sel_registerName "convertRectFromBacking:") rect))
(define (nsview-convert-rect-from-layer self rect)
  (_msg-19 (coerce-arg self) (sel_registerName "convertRectFromLayer:") rect))
(define (nsview-convert-rect-to-backing self rect)
  (_msg-19 (coerce-arg self) (sel_registerName "convertRectToBacking:") rect))
(define (nsview-convert-rect-to-layer self rect)
  (_msg-19 (coerce-arg self) (sel_registerName "convertRectToLayer:") rect))
(define (nsview-convert-size-from-view self size view)
  (_msg-30 (coerce-arg self) (sel_registerName "convertSize:fromView:") size (coerce-arg view)))
(define (nsview-convert-size-to-view self size view)
  (_msg-30 (coerce-arg self) (sel_registerName "convertSize:toView:") size (coerce-arg view)))
(define (nsview-convert-size-from-backing self size)
  (_msg-28 (coerce-arg self) (sel_registerName "convertSizeFromBacking:") size))
(define (nsview-convert-size-from-layer self size)
  (_msg-28 (coerce-arg self) (sel_registerName "convertSizeFromLayer:") size))
(define (nsview-convert-size-to-backing self size)
  (_msg-28 (coerce-arg self) (sel_registerName "convertSizeToBacking:") size))
(define (nsview-convert-size-to-layer self size)
  (_msg-28 (coerce-arg self) (sel_registerName "convertSizeToLayer:") size))
(define (nsview-cursor-update self event)
  (tell #:type _void (coerce-arg self) cursorUpdate: (coerce-arg event)))
(define (nsview-delete-backward self sender)
  (tell #:type _void (coerce-arg self) deleteBackward: (coerce-arg sender)))
(define (nsview-delete-backward-by-decomposing-previous-character self sender)
  (tell #:type _void (coerce-arg self) deleteBackwardByDecomposingPreviousCharacter: (coerce-arg sender)))
(define (nsview-delete-forward self sender)
  (tell #:type _void (coerce-arg self) deleteForward: (coerce-arg sender)))
(define (nsview-delete-to-beginning-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfLine: (coerce-arg sender)))
(define (nsview-delete-to-beginning-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfParagraph: (coerce-arg sender)))
(define (nsview-delete-to-end-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfLine: (coerce-arg sender)))
(define (nsview-delete-to-end-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfParagraph: (coerce-arg sender)))
(define (nsview-delete-to-mark self sender)
  (tell #:type _void (coerce-arg self) deleteToMark: (coerce-arg sender)))
(define (nsview-delete-word-backward self sender)
  (tell #:type _void (coerce-arg self) deleteWordBackward: (coerce-arg sender)))
(define (nsview-delete-word-forward self sender)
  (tell #:type _void (coerce-arg self) deleteWordForward: (coerce-arg sender)))
(define (nsview-did-add-subview self subview)
  (tell #:type _void (coerce-arg self) didAddSubview: (coerce-arg subview)))
(define (nsview-did-close-menu-with-event self menu event)
  (tell #:type _void (coerce-arg self) didCloseMenu: (coerce-arg menu) withEvent: (coerce-arg event)))
(define (nsview-display! self)
  (tell #:type _void (coerce-arg self) display))
(define (nsview-display-if-needed! self)
  (tell #:type _void (coerce-arg self) displayIfNeeded))
(define (nsview-display-if-needed-ignoring-opacity! self)
  (tell #:type _void (coerce-arg self) displayIfNeededIgnoringOpacity))
(define (nsview-display-if-needed-in-rect! self rect)
  (_msg-22 (coerce-arg self) (sel_registerName "displayIfNeededInRect:") rect))
(define (nsview-display-if-needed-in-rect-ignoring-opacity! self rect)
  (_msg-22 (coerce-arg self) (sel_registerName "displayIfNeededInRectIgnoringOpacity:") rect))
(define (nsview-display-rect! self rect)
  (_msg-22 (coerce-arg self) (sel_registerName "displayRect:") rect))
(define (nsview-display-rect-ignoring-opacity! self rect)
  (_msg-22 (coerce-arg self) (sel_registerName "displayRectIgnoringOpacity:") rect))
(define (nsview-display-rect-ignoring-opacity-in-context! self rect context)
  (_msg-25 (coerce-arg self) (sel_registerName "displayRectIgnoringOpacity:inContext:") rect (coerce-arg context)))
(define (nsview-do-command-by-selector self selector)
  (_msg-44 (coerce-arg self) (sel_registerName "doCommandBySelector:") (sel_registerName selector)))
(define (nsview-dragging-ended self sender)
  (tell #:type _void (coerce-arg self) draggingEnded: (coerce-arg sender)))
(define (nsview-dragging-entered self sender)
  (_msg-35 (coerce-arg self) (sel_registerName "draggingEntered:") (coerce-arg sender)))
(define (nsview-dragging-exited self sender)
  (tell #:type _void (coerce-arg self) draggingExited: (coerce-arg sender)))
(define (nsview-dragging-updated self sender)
  (_msg-35 (coerce-arg self) (sel_registerName "draggingUpdated:") (coerce-arg sender)))
(define (nsview-draw-rect self dirty-rect)
  (_msg-22 (coerce-arg self) (sel_registerName "drawRect:") dirty-rect))
(define (nsview-effective-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) effectiveAppearance)))
(define (nsview-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nsview-end-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) endGestureWithEvent: (coerce-arg event)))
(define (nsview-flags-changed self event)
  (tell #:type _void (coerce-arg self) flagsChanged: (coerce-arg event)))
(define (nsview-flush-buffered-key-events self)
  (tell #:type _void (coerce-arg self) flushBufferedKeyEvents))
(define (nsview-get-rects-being-drawn-count self rects count)
  (_msg-47 (coerce-arg self) (sel_registerName "getRectsBeingDrawn:count:") rects count))
(define (nsview-get-rects-exposed-during-live-resize-count self exposed-rects count)
  (_msg-47 (coerce-arg self) (sel_registerName "getRectsExposedDuringLiveResize:count:") exposed-rects count))
(define (nsview-help-requested self event-ptr)
  (tell #:type _void (coerce-arg self) helpRequested: (coerce-arg event-ptr)))
(define (nsview-hit-test self point)
  (wrap-objc-object
   (_msg-11 (coerce-arg self) (sel_registerName "hitTest:") point)
   ))
(define (nsview-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) identifier)))
(define (nsview-indent self sender)
  (tell #:type _void (coerce-arg self) indent: (coerce-arg sender)))
(define (nsview-insert-backtab! self sender)
  (tell #:type _void (coerce-arg self) insertBacktab: (coerce-arg sender)))
(define (nsview-insert-container-break! self sender)
  (tell #:type _void (coerce-arg self) insertContainerBreak: (coerce-arg sender)))
(define (nsview-insert-double-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertDoubleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nsview-insert-line-break! self sender)
  (tell #:type _void (coerce-arg self) insertLineBreak: (coerce-arg sender)))
(define (nsview-insert-newline! self sender)
  (tell #:type _void (coerce-arg self) insertNewline: (coerce-arg sender)))
(define (nsview-insert-newline-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertNewlineIgnoringFieldEditor: (coerce-arg sender)))
(define (nsview-insert-paragraph-separator! self sender)
  (tell #:type _void (coerce-arg self) insertParagraphSeparator: (coerce-arg sender)))
(define (nsview-insert-single-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertSingleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nsview-insert-tab! self sender)
  (tell #:type _void (coerce-arg self) insertTab: (coerce-arg sender)))
(define (nsview-insert-tab-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertTabIgnoringFieldEditor: (coerce-arg sender)))
(define (nsview-insert-text! self insert-string)
  (tell #:type _void (coerce-arg self) insertText: (coerce-arg insert-string)))
(define (nsview-interpret-key-events self event-array)
  (tell #:type _void (coerce-arg self) interpretKeyEvents: (coerce-arg event-array)))
(define (nsview-is-accessibility-alternate-ui-visible self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityAlternateUIVisible")))
(define (nsview-is-accessibility-disclosed self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityDisclosed")))
(define (nsview-is-accessibility-edited self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityEdited")))
(define (nsview-is-accessibility-element self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityElement")))
(define (nsview-is-accessibility-enabled self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityEnabled")))
(define (nsview-is-accessibility-expanded self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityExpanded")))
(define (nsview-is-accessibility-focused self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityFocused")))
(define (nsview-is-accessibility-frontmost self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityFrontmost")))
(define (nsview-is-accessibility-hidden self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityHidden")))
(define (nsview-is-accessibility-main self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityMain")))
(define (nsview-is-accessibility-minimized self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityMinimized")))
(define (nsview-is-accessibility-modal self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityModal")))
(define (nsview-is-accessibility-ordered-by-row self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityOrderedByRow")))
(define (nsview-is-accessibility-protected-content self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityProtectedContent")))
(define (nsview-is-accessibility-required self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityRequired")))
(define (nsview-is-accessibility-selected self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilitySelected")))
(define (nsview-is-accessibility-selector-allowed self selector)
  (_msg-43 (coerce-arg self) (sel_registerName "isAccessibilitySelectorAllowed:") (sel_registerName selector)))
(define (nsview-is-descendant-of self view)
  (_msg-34 (coerce-arg self) (sel_registerName "isDescendantOf:") (coerce-arg view)))
(define (nsview-is-flipped self)
  (_msg-3 (coerce-arg self) (sel_registerName "isFlipped")))
(define (nsview-is-hidden self)
  (_msg-3 (coerce-arg self) (sel_registerName "isHidden")))
(define (nsview-is-hidden-or-has-hidden-ancestor self)
  (_msg-3 (coerce-arg self) (sel_registerName "isHiddenOrHasHiddenAncestor")))
(define (nsview-is-opaque self)
  (_msg-3 (coerce-arg self) (sel_registerName "isOpaque")))
(define (nsview-is-rotated-from-base self)
  (_msg-3 (coerce-arg self) (sel_registerName "isRotatedFromBase")))
(define (nsview-is-rotated-or-scaled-from-base self)
  (_msg-3 (coerce-arg self) (sel_registerName "isRotatedOrScaledFromBase")))
(define (nsview-key-down self event)
  (tell #:type _void (coerce-arg self) keyDown: (coerce-arg event)))
(define (nsview-key-up self event)
  (tell #:type _void (coerce-arg self) keyUp: (coerce-arg event)))
(define (nsview-layout self)
  (tell #:type _void (coerce-arg self) layout))
(define (nsview-layout-subtree-if-needed self)
  (tell #:type _void (coerce-arg self) layoutSubtreeIfNeeded))
(define (nsview-lowercase-word self sender)
  (tell #:type _void (coerce-arg self) lowercaseWord: (coerce-arg sender)))
(define (nsview-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) magnifyWithEvent: (coerce-arg event)))
(define (nsview-make-backing-layer self)
  (wrap-objc-object
   (tell (coerce-arg self) makeBackingLayer)))
(define (nsview-make-base-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nsview-make-base-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionNatural: (coerce-arg sender)))
(define (nsview-make-base-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nsview-make-text-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nsview-make-text-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionNatural: (coerce-arg sender)))
(define (nsview-make-text-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nsview-menu-for-event self event)
  (wrap-objc-object
   (tell (coerce-arg self) menuForEvent: (coerce-arg event))))
(define (nsview-mouse-in-rect self point rect)
  (_msg-14 (coerce-arg self) (sel_registerName "mouse:inRect:") point rect))
(define (nsview-mouse-cancelled self event)
  (tell #:type _void (coerce-arg self) mouseCancelled: (coerce-arg event)))
(define (nsview-mouse-down self event)
  (tell #:type _void (coerce-arg self) mouseDown: (coerce-arg event)))
(define (nsview-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) mouseDragged: (coerce-arg event)))
(define (nsview-mouse-entered self event)
  (tell #:type _void (coerce-arg self) mouseEntered: (coerce-arg event)))
(define (nsview-mouse-exited self event)
  (tell #:type _void (coerce-arg self) mouseExited: (coerce-arg event)))
(define (nsview-mouse-moved self event)
  (tell #:type _void (coerce-arg self) mouseMoved: (coerce-arg event)))
(define (nsview-mouse-up self event)
  (tell #:type _void (coerce-arg self) mouseUp: (coerce-arg event)))
(define (nsview-move-backward! self sender)
  (tell #:type _void (coerce-arg self) moveBackward: (coerce-arg sender)))
(define (nsview-move-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveBackwardAndModifySelection: (coerce-arg sender)))
(define (nsview-move-down! self sender)
  (tell #:type _void (coerce-arg self) moveDown: (coerce-arg sender)))
(define (nsview-move-down-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveDownAndModifySelection: (coerce-arg sender)))
(define (nsview-move-forward! self sender)
  (tell #:type _void (coerce-arg self) moveForward: (coerce-arg sender)))
(define (nsview-move-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveForwardAndModifySelection: (coerce-arg sender)))
(define (nsview-move-left! self sender)
  (tell #:type _void (coerce-arg self) moveLeft: (coerce-arg sender)))
(define (nsview-move-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveLeftAndModifySelection: (coerce-arg sender)))
(define (nsview-move-paragraph-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphBackwardAndModifySelection: (coerce-arg sender)))
(define (nsview-move-paragraph-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphForwardAndModifySelection: (coerce-arg sender)))
(define (nsview-move-right! self sender)
  (tell #:type _void (coerce-arg self) moveRight: (coerce-arg sender)))
(define (nsview-move-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveRightAndModifySelection: (coerce-arg sender)))
(define (nsview-move-to-beginning-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocument: (coerce-arg sender)))
(define (nsview-move-to-beginning-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nsview-move-to-beginning-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLine: (coerce-arg sender)))
(define (nsview-move-to-beginning-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLineAndModifySelection: (coerce-arg sender)))
(define (nsview-move-to-beginning-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraph: (coerce-arg sender)))
(define (nsview-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nsview-move-to-end-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocument: (coerce-arg sender)))
(define (nsview-move-to-end-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nsview-move-to-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLine: (coerce-arg sender)))
(define (nsview-move-to-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nsview-move-to-end-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraph: (coerce-arg sender)))
(define (nsview-move-to-end-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nsview-move-to-left-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLine: (coerce-arg sender)))
(define (nsview-move-to-left-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nsview-move-to-right-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLine: (coerce-arg sender)))
(define (nsview-move-to-right-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nsview-move-up! self sender)
  (tell #:type _void (coerce-arg self) moveUp: (coerce-arg sender)))
(define (nsview-move-up-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveUpAndModifySelection: (coerce-arg sender)))
(define (nsview-move-word-backward! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackward: (coerce-arg sender)))
(define (nsview-move-word-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackwardAndModifySelection: (coerce-arg sender)))
(define (nsview-move-word-forward! self sender)
  (tell #:type _void (coerce-arg self) moveWordForward: (coerce-arg sender)))
(define (nsview-move-word-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordForwardAndModifySelection: (coerce-arg sender)))
(define (nsview-move-word-left! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeft: (coerce-arg sender)))
(define (nsview-move-word-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeftAndModifySelection: (coerce-arg sender)))
(define (nsview-move-word-right! self sender)
  (tell #:type _void (coerce-arg self) moveWordRight: (coerce-arg sender)))
(define (nsview-move-word-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordRightAndModifySelection: (coerce-arg sender)))
(define (nsview-needs-to-draw-rect self rect)
  (_msg-20 (coerce-arg self) (sel_registerName "needsToDrawRect:") rect))
(define (nsview-no-responder-for self event-selector)
  (_msg-44 (coerce-arg self) (sel_registerName "noResponderFor:") (sel_registerName event-selector)))
(define (nsview-other-mouse-down self event)
  (tell #:type _void (coerce-arg self) otherMouseDown: (coerce-arg event)))
(define (nsview-other-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) otherMouseDragged: (coerce-arg event)))
(define (nsview-other-mouse-up self event)
  (tell #:type _void (coerce-arg self) otherMouseUp: (coerce-arg event)))
(define (nsview-page-down self sender)
  (tell #:type _void (coerce-arg self) pageDown: (coerce-arg sender)))
(define (nsview-page-down-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageDownAndModifySelection: (coerce-arg sender)))
(define (nsview-page-up self sender)
  (tell #:type _void (coerce-arg self) pageUp: (coerce-arg sender)))
(define (nsview-page-up-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageUpAndModifySelection: (coerce-arg sender)))
(define (nsview-perform-drag-operation! self sender)
  (_msg-34 (coerce-arg self) (sel_registerName "performDragOperation:") (coerce-arg sender)))
(define (nsview-perform-key-equivalent! self event)
  (_msg-34 (coerce-arg self) (sel_registerName "performKeyEquivalent:") (coerce-arg event)))
(define (nsview-prepare-content-in-rect self rect)
  (_msg-22 (coerce-arg self) (sel_registerName "prepareContentInRect:") rect))
(define (nsview-prepare-for-drag-operation self sender)
  (_msg-34 (coerce-arg self) (sel_registerName "prepareForDragOperation:") (coerce-arg sender)))
(define (nsview-prepare-for-reuse self)
  (tell #:type _void (coerce-arg self) prepareForReuse))
(define (nsview-pressure-change-with-event self event)
  (tell #:type _void (coerce-arg self) pressureChangeWithEvent: (coerce-arg event)))
(define (nsview-quick-look-preview-items self sender)
  (tell #:type _void (coerce-arg self) quickLookPreviewItems: (coerce-arg sender)))
(define (nsview-quick-look-with-event self event)
  (tell #:type _void (coerce-arg self) quickLookWithEvent: (coerce-arg event)))
(define (nsview-rect-for-smart-magnification-at-point-in-rect self location visible-rect)
  (_msg-13 (coerce-arg self) (sel_registerName "rectForSmartMagnificationAtPoint:inRect:") location visible-rect))
(define (nsview-remove-all-tool-tips! self)
  (tell #:type _void (coerce-arg self) removeAllToolTips))
(define (nsview-remove-from-superview! self)
  (tell #:type _void (coerce-arg self) removeFromSuperview))
(define (nsview-remove-from-superview-without-needing-display! self)
  (tell #:type _void (coerce-arg self) removeFromSuperviewWithoutNeedingDisplay))
(define (nsview-remove-tool-tip! self tag)
  (_msg-41 (coerce-arg self) (sel_registerName "removeToolTip:") tag))
(define (nsview-replace-subview-with! self old-view new-view)
  (tell #:type _void (coerce-arg self) replaceSubview: (coerce-arg old-view) with: (coerce-arg new-view)))
(define (nsview-resign-first-responder self)
  (_msg-3 (coerce-arg self) (sel_registerName "resignFirstResponder")))
(define (nsview-resize-subviews-with-old-size self old-size)
  (_msg-29 (coerce-arg self) (sel_registerName "resizeSubviewsWithOldSize:") old-size))
(define (nsview-resize-with-old-superview-size self old-size)
  (_msg-29 (coerce-arg self) (sel_registerName "resizeWithOldSuperviewSize:") old-size))
(define (nsview-restore-user-activity-state self user-activity)
  (tell #:type _void (coerce-arg self) restoreUserActivityState: (coerce-arg user-activity)))
(define (nsview-right-mouse-down self event)
  (tell #:type _void (coerce-arg self) rightMouseDown: (coerce-arg event)))
(define (nsview-right-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) rightMouseDragged: (coerce-arg event)))
(define (nsview-right-mouse-up self event)
  (tell #:type _void (coerce-arg self) rightMouseUp: (coerce-arg event)))
(define (nsview-rotate-by-angle self angle)
  (_msg-32 (coerce-arg self) (sel_registerName "rotateByAngle:") angle))
(define (nsview-rotate-with-event self event)
  (tell #:type _void (coerce-arg self) rotateWithEvent: (coerce-arg event)))
(define (nsview-scale-unit-square-to-size self new-unit-size)
  (_msg-29 (coerce-arg self) (sel_registerName "scaleUnitSquareToSize:") new-unit-size))
(define (nsview-scroll-line-down self sender)
  (tell #:type _void (coerce-arg self) scrollLineDown: (coerce-arg sender)))
(define (nsview-scroll-line-up self sender)
  (tell #:type _void (coerce-arg self) scrollLineUp: (coerce-arg sender)))
(define (nsview-scroll-page-down self sender)
  (tell #:type _void (coerce-arg self) scrollPageDown: (coerce-arg sender)))
(define (nsview-scroll-page-up self sender)
  (tell #:type _void (coerce-arg self) scrollPageUp: (coerce-arg sender)))
(define (nsview-scroll-point self point)
  (_msg-12 (coerce-arg self) (sel_registerName "scrollPoint:") point))
(define (nsview-scroll-rect-to-visible self rect)
  (_msg-20 (coerce-arg self) (sel_registerName "scrollRectToVisible:") rect))
(define (nsview-scroll-to-beginning-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToBeginningOfDocument: (coerce-arg sender)))
(define (nsview-scroll-to-end-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToEndOfDocument: (coerce-arg sender)))
(define (nsview-scroll-wheel self event)
  (tell #:type _void (coerce-arg self) scrollWheel: (coerce-arg event)))
(define (nsview-select-all self sender)
  (tell #:type _void (coerce-arg self) selectAll: (coerce-arg sender)))
(define (nsview-select-line self sender)
  (tell #:type _void (coerce-arg self) selectLine: (coerce-arg sender)))
(define (nsview-select-paragraph self sender)
  (tell #:type _void (coerce-arg self) selectParagraph: (coerce-arg sender)))
(define (nsview-select-to-mark self sender)
  (tell #:type _void (coerce-arg self) selectToMark: (coerce-arg sender)))
(define (nsview-select-word self sender)
  (tell #:type _void (coerce-arg self) selectWord: (coerce-arg sender)))
(define (nsview-set-accessibility-activation-point! self accessibility-activation-point)
  (_msg-12 (coerce-arg self) (sel_registerName "setAccessibilityActivationPoint:") accessibility-activation-point))
(define (nsview-set-accessibility-allowed-values! self accessibility-allowed-values)
  (tell #:type _void (coerce-arg self) setAccessibilityAllowedValues: (coerce-arg accessibility-allowed-values)))
(define (nsview-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityAlternateUIVisible:") accessibility-alternate-ui-visible))
(define (nsview-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityApplicationFocusedUIElement: (coerce-arg accessibility-application-focused-ui-element)))
(define (nsview-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityAttributedUserInputLabels: (coerce-arg accessibility-attributed-user-input-labels)))
(define (nsview-set-accessibility-cancel-button! self accessibility-cancel-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCancelButton: (coerce-arg accessibility-cancel-button)))
(define (nsview-set-accessibility-children! self accessibility-children)
  (tell #:type _void (coerce-arg self) setAccessibilityChildren: (coerce-arg accessibility-children)))
(define (nsview-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (tell #:type _void (coerce-arg self) setAccessibilityChildrenInNavigationOrder: (coerce-arg accessibility-children-in-navigation-order)))
(define (nsview-set-accessibility-clear-button! self accessibility-clear-button)
  (tell #:type _void (coerce-arg self) setAccessibilityClearButton: (coerce-arg accessibility-clear-button)))
(define (nsview-set-accessibility-close-button! self accessibility-close-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCloseButton: (coerce-arg accessibility-close-button)))
(define (nsview-set-accessibility-column-count! self accessibility-column-count)
  (_msg-41 (coerce-arg self) (sel_registerName "setAccessibilityColumnCount:") accessibility-column-count))
(define (nsview-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnHeaderUIElements: (coerce-arg accessibility-column-header-ui-elements)))
(define (nsview-set-accessibility-column-index-range! self accessibility-column-index-range)
  (_msg-18 (coerce-arg self) (sel_registerName "setAccessibilityColumnIndexRange:") accessibility-column-index-range))
(define (nsview-set-accessibility-column-titles! self accessibility-column-titles)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnTitles: (coerce-arg accessibility-column-titles)))
(define (nsview-set-accessibility-columns! self accessibility-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityColumns: (coerce-arg accessibility-columns)))
(define (nsview-set-accessibility-contents! self accessibility-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityContents: (coerce-arg accessibility-contents)))
(define (nsview-set-accessibility-critical-value! self accessibility-critical-value)
  (tell #:type _void (coerce-arg self) setAccessibilityCriticalValue: (coerce-arg accessibility-critical-value)))
(define (nsview-set-accessibility-custom-actions! self accessibility-custom-actions)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomActions: (coerce-arg accessibility-custom-actions)))
(define (nsview-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomRotors: (coerce-arg accessibility-custom-rotors)))
(define (nsview-set-accessibility-decrement-button! self accessibility-decrement-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDecrementButton: (coerce-arg accessibility-decrement-button)))
(define (nsview-set-accessibility-default-button! self accessibility-default-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDefaultButton: (coerce-arg accessibility-default-button)))
(define (nsview-set-accessibility-disclosed! self accessibility-disclosed)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityDisclosed:") accessibility-disclosed))
(define (nsview-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedByRow: (coerce-arg accessibility-disclosed-by-row)))
(define (nsview-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedRows: (coerce-arg accessibility-disclosed-rows)))
(define (nsview-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (_msg-41 (coerce-arg self) (sel_registerName "setAccessibilityDisclosureLevel:") accessibility-disclosure-level))
(define (nsview-set-accessibility-document! self accessibility-document)
  (tell #:type _void (coerce-arg self) setAccessibilityDocument: (coerce-arg accessibility-document)))
(define (nsview-set-accessibility-edited! self accessibility-edited)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityEdited:") accessibility-edited))
(define (nsview-set-accessibility-element! self accessibility-element)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityElement:") accessibility-element))
(define (nsview-set-accessibility-enabled! self accessibility-enabled)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityEnabled:") accessibility-enabled))
(define (nsview-set-accessibility-expanded! self accessibility-expanded)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityExpanded:") accessibility-expanded))
(define (nsview-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityExtrasMenuBar: (coerce-arg accessibility-extras-menu-bar)))
(define (nsview-set-accessibility-filename! self accessibility-filename)
  (tell #:type _void (coerce-arg self) setAccessibilityFilename: (coerce-arg accessibility-filename)))
(define (nsview-set-accessibility-focused! self accessibility-focused)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityFocused:") accessibility-focused))
(define (nsview-set-accessibility-focused-window! self accessibility-focused-window)
  (tell #:type _void (coerce-arg self) setAccessibilityFocusedWindow: (coerce-arg accessibility-focused-window)))
(define (nsview-set-accessibility-frame! self accessibility-frame)
  (_msg-22 (coerce-arg self) (sel_registerName "setAccessibilityFrame:") accessibility-frame))
(define (nsview-set-accessibility-frontmost! self accessibility-frontmost)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityFrontmost:") accessibility-frontmost))
(define (nsview-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (tell #:type _void (coerce-arg self) setAccessibilityFullScreenButton: (coerce-arg accessibility-full-screen-button)))
(define (nsview-set-accessibility-grow-area! self accessibility-grow-area)
  (tell #:type _void (coerce-arg self) setAccessibilityGrowArea: (coerce-arg accessibility-grow-area)))
(define (nsview-set-accessibility-handles! self accessibility-handles)
  (tell #:type _void (coerce-arg self) setAccessibilityHandles: (coerce-arg accessibility-handles)))
(define (nsview-set-accessibility-header! self accessibility-header)
  (tell #:type _void (coerce-arg self) setAccessibilityHeader: (coerce-arg accessibility-header)))
(define (nsview-set-accessibility-help! self accessibility-help)
  (tell #:type _void (coerce-arg self) setAccessibilityHelp: (coerce-arg accessibility-help)))
(define (nsview-set-accessibility-hidden! self accessibility-hidden)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityHidden:") accessibility-hidden))
(define (nsview-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalScrollBar: (coerce-arg accessibility-horizontal-scroll-bar)))
(define (nsview-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalUnitDescription: (coerce-arg accessibility-horizontal-unit-description)))
(define (nsview-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (_msg-41 (coerce-arg self) (sel_registerName "setAccessibilityHorizontalUnits:") accessibility-horizontal-units))
(define (nsview-set-accessibility-identifier! self accessibility-identifier)
  (tell #:type _void (coerce-arg self) setAccessibilityIdentifier: (coerce-arg accessibility-identifier)))
(define (nsview-set-accessibility-increment-button! self accessibility-increment-button)
  (tell #:type _void (coerce-arg self) setAccessibilityIncrementButton: (coerce-arg accessibility-increment-button)))
(define (nsview-set-accessibility-index! self accessibility-index)
  (_msg-41 (coerce-arg self) (sel_registerName "setAccessibilityIndex:") accessibility-index))
(define (nsview-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (_msg-41 (coerce-arg self) (sel_registerName "setAccessibilityInsertionPointLineNumber:") accessibility-insertion-point-line-number))
(define (nsview-set-accessibility-label! self accessibility-label)
  (tell #:type _void (coerce-arg self) setAccessibilityLabel: (coerce-arg accessibility-label)))
(define (nsview-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLabelUIElements: (coerce-arg accessibility-label-ui-elements)))
(define (nsview-set-accessibility-label-value! self accessibility-label-value)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityLabelValue:") accessibility-label-value))
(define (nsview-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLinkedUIElements: (coerce-arg accessibility-linked-ui-elements)))
(define (nsview-set-accessibility-main! self accessibility-main)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityMain:") accessibility-main))
(define (nsview-set-accessibility-main-window! self accessibility-main-window)
  (tell #:type _void (coerce-arg self) setAccessibilityMainWindow: (coerce-arg accessibility-main-window)))
(define (nsview-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerGroupUIElement: (coerce-arg accessibility-marker-group-ui-element)))
(define (nsview-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerTypeDescription: (coerce-arg accessibility-marker-type-description)))
(define (nsview-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerUIElements: (coerce-arg accessibility-marker-ui-elements)))
(define (nsview-set-accessibility-marker-values! self accessibility-marker-values)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerValues: (coerce-arg accessibility-marker-values)))
(define (nsview-set-accessibility-max-value! self accessibility-max-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMaxValue: (coerce-arg accessibility-max-value)))
(define (nsview-set-accessibility-menu-bar! self accessibility-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityMenuBar: (coerce-arg accessibility-menu-bar)))
(define (nsview-set-accessibility-min-value! self accessibility-min-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMinValue: (coerce-arg accessibility-min-value)))
(define (nsview-set-accessibility-minimize-button! self accessibility-minimize-button)
  (tell #:type _void (coerce-arg self) setAccessibilityMinimizeButton: (coerce-arg accessibility-minimize-button)))
(define (nsview-set-accessibility-minimized! self accessibility-minimized)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityMinimized:") accessibility-minimized))
(define (nsview-set-accessibility-modal! self accessibility-modal)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityModal:") accessibility-modal))
(define (nsview-set-accessibility-next-contents! self accessibility-next-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityNextContents: (coerce-arg accessibility-next-contents)))
(define (nsview-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (_msg-41 (coerce-arg self) (sel_registerName "setAccessibilityNumberOfCharacters:") accessibility-number-of-characters))
(define (nsview-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityOrderedByRow:") accessibility-ordered-by-row))
(define (nsview-set-accessibility-orientation! self accessibility-orientation)
  (_msg-41 (coerce-arg self) (sel_registerName "setAccessibilityOrientation:") accessibility-orientation))
(define (nsview-set-accessibility-overflow-button! self accessibility-overflow-button)
  (tell #:type _void (coerce-arg self) setAccessibilityOverflowButton: (coerce-arg accessibility-overflow-button)))
(define (nsview-set-accessibility-parent! self accessibility-parent)
  (tell #:type _void (coerce-arg self) setAccessibilityParent: (coerce-arg accessibility-parent)))
(define (nsview-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (tell #:type _void (coerce-arg self) setAccessibilityPlaceholderValue: (coerce-arg accessibility-placeholder-value)))
(define (nsview-set-accessibility-previous-contents! self accessibility-previous-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityPreviousContents: (coerce-arg accessibility-previous-contents)))
(define (nsview-set-accessibility-protected-content! self accessibility-protected-content)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityProtectedContent:") accessibility-protected-content))
(define (nsview-set-accessibility-proxy! self accessibility-proxy)
  (tell #:type _void (coerce-arg self) setAccessibilityProxy: (coerce-arg accessibility-proxy)))
(define (nsview-set-accessibility-required! self accessibility-required)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilityRequired:") accessibility-required))
(define (nsview-set-accessibility-role! self accessibility-role)
  (tell #:type _void (coerce-arg self) setAccessibilityRole: (coerce-arg accessibility-role)))
(define (nsview-set-accessibility-role-description! self accessibility-role-description)
  (tell #:type _void (coerce-arg self) setAccessibilityRoleDescription: (coerce-arg accessibility-role-description)))
(define (nsview-set-accessibility-row-count! self accessibility-row-count)
  (_msg-41 (coerce-arg self) (sel_registerName "setAccessibilityRowCount:") accessibility-row-count))
(define (nsview-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityRowHeaderUIElements: (coerce-arg accessibility-row-header-ui-elements)))
(define (nsview-set-accessibility-row-index-range! self accessibility-row-index-range)
  (_msg-18 (coerce-arg self) (sel_registerName "setAccessibilityRowIndexRange:") accessibility-row-index-range))
(define (nsview-set-accessibility-rows! self accessibility-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityRows: (coerce-arg accessibility-rows)))
(define (nsview-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (_msg-41 (coerce-arg self) (sel_registerName "setAccessibilityRulerMarkerType:") accessibility-ruler-marker-type))
(define (nsview-set-accessibility-search-button! self accessibility-search-button)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchButton: (coerce-arg accessibility-search-button)))
(define (nsview-set-accessibility-search-menu! self accessibility-search-menu)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchMenu: (coerce-arg accessibility-search-menu)))
(define (nsview-set-accessibility-selected! self accessibility-selected)
  (_msg-31 (coerce-arg self) (sel_registerName "setAccessibilitySelected:") accessibility-selected))
(define (nsview-set-accessibility-selected-cells! self accessibility-selected-cells)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedCells: (coerce-arg accessibility-selected-cells)))
(define (nsview-set-accessibility-selected-children! self accessibility-selected-children)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedChildren: (coerce-arg accessibility-selected-children)))
(define (nsview-set-accessibility-selected-columns! self accessibility-selected-columns)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedColumns: (coerce-arg accessibility-selected-columns)))
(define (nsview-set-accessibility-selected-rows! self accessibility-selected-rows)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedRows: (coerce-arg accessibility-selected-rows)))
(define (nsview-set-accessibility-selected-text! self accessibility-selected-text)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedText: (coerce-arg accessibility-selected-text)))
(define (nsview-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (_msg-18 (coerce-arg self) (sel_registerName "setAccessibilitySelectedTextRange:") accessibility-selected-text-range))
(define (nsview-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedTextRanges: (coerce-arg accessibility-selected-text-ranges)))
(define (nsview-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityServesAsTitleForUIElements: (coerce-arg accessibility-serves-as-title-for-ui-elements)))
(define (nsview-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (_msg-18 (coerce-arg self) (sel_registerName "setAccessibilitySharedCharacterRange:") accessibility-shared-character-range))
(define (nsview-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedFocusElements: (coerce-arg accessibility-shared-focus-elements)))
(define (nsview-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedTextUIElements: (coerce-arg accessibility-shared-text-ui-elements)))
(define (nsview-set-accessibility-shown-menu! self accessibility-shown-menu)
  (tell #:type _void (coerce-arg self) setAccessibilityShownMenu: (coerce-arg accessibility-shown-menu)))
(define (nsview-set-accessibility-sort-direction! self accessibility-sort-direction)
  (_msg-41 (coerce-arg self) (sel_registerName "setAccessibilitySortDirection:") accessibility-sort-direction))
(define (nsview-set-accessibility-splitters! self accessibility-splitters)
  (tell #:type _void (coerce-arg self) setAccessibilitySplitters: (coerce-arg accessibility-splitters)))
(define (nsview-set-accessibility-subrole! self accessibility-subrole)
  (tell #:type _void (coerce-arg self) setAccessibilitySubrole: (coerce-arg accessibility-subrole)))
(define (nsview-set-accessibility-tabs! self accessibility-tabs)
  (tell #:type _void (coerce-arg self) setAccessibilityTabs: (coerce-arg accessibility-tabs)))
(define (nsview-set-accessibility-title! self accessibility-title)
  (tell #:type _void (coerce-arg self) setAccessibilityTitle: (coerce-arg accessibility-title)))
(define (nsview-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTitleUIElement: (coerce-arg accessibility-title-ui-element)))
(define (nsview-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (tell #:type _void (coerce-arg self) setAccessibilityToolbarButton: (coerce-arg accessibility-toolbar-button)))
(define (nsview-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTopLevelUIElement: (coerce-arg accessibility-top-level-ui-element)))
(define (nsview-set-accessibility-url! self accessibility-url)
  (tell #:type _void (coerce-arg self) setAccessibilityURL: (coerce-arg accessibility-url)))
(define (nsview-set-accessibility-unit-description! self accessibility-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityUnitDescription: (coerce-arg accessibility-unit-description)))
(define (nsview-set-accessibility-units! self accessibility-units)
  (_msg-41 (coerce-arg self) (sel_registerName "setAccessibilityUnits:") accessibility-units))
(define (nsview-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityUserInputLabels: (coerce-arg accessibility-user-input-labels)))
(define (nsview-set-accessibility-value! self accessibility-value)
  (tell #:type _void (coerce-arg self) setAccessibilityValue: (coerce-arg accessibility-value)))
(define (nsview-set-accessibility-value-description! self accessibility-value-description)
  (tell #:type _void (coerce-arg self) setAccessibilityValueDescription: (coerce-arg accessibility-value-description)))
(define (nsview-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalScrollBar: (coerce-arg accessibility-vertical-scroll-bar)))
(define (nsview-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalUnitDescription: (coerce-arg accessibility-vertical-unit-description)))
(define (nsview-set-accessibility-vertical-units! self accessibility-vertical-units)
  (_msg-41 (coerce-arg self) (sel_registerName "setAccessibilityVerticalUnits:") accessibility-vertical-units))
(define (nsview-set-accessibility-visible-cells! self accessibility-visible-cells)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleCells: (coerce-arg accessibility-visible-cells)))
(define (nsview-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (_msg-18 (coerce-arg self) (sel_registerName "setAccessibilityVisibleCharacterRange:") accessibility-visible-character-range))
(define (nsview-set-accessibility-visible-children! self accessibility-visible-children)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleChildren: (coerce-arg accessibility-visible-children)))
(define (nsview-set-accessibility-visible-columns! self accessibility-visible-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleColumns: (coerce-arg accessibility-visible-columns)))
(define (nsview-set-accessibility-visible-rows! self accessibility-visible-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleRows: (coerce-arg accessibility-visible-rows)))
(define (nsview-set-accessibility-warning-value! self accessibility-warning-value)
  (tell #:type _void (coerce-arg self) setAccessibilityWarningValue: (coerce-arg accessibility-warning-value)))
(define (nsview-set-accessibility-window! self accessibility-window)
  (tell #:type _void (coerce-arg self) setAccessibilityWindow: (coerce-arg accessibility-window)))
(define (nsview-set-accessibility-windows! self accessibility-windows)
  (tell #:type _void (coerce-arg self) setAccessibilityWindows: (coerce-arg accessibility-windows)))
(define (nsview-set-accessibility-zoom-button! self accessibility-zoom-button)
  (tell #:type _void (coerce-arg self) setAccessibilityZoomButton: (coerce-arg accessibility-zoom-button)))
(define (nsview-set-animations! self animations)
  (tell #:type _void (coerce-arg self) setAnimations: (coerce-arg animations)))
(define (nsview-set-appearance! self appearance)
  (tell #:type _void (coerce-arg self) setAppearance: (coerce-arg appearance)))
(define (nsview-set-bounds-origin! self new-origin)
  (_msg-12 (coerce-arg self) (sel_registerName "setBoundsOrigin:") new-origin))
(define (nsview-set-bounds-size! self new-size)
  (_msg-29 (coerce-arg self) (sel_registerName "setBoundsSize:") new-size))
(define (nsview-set-frame-origin! self new-origin)
  (_msg-12 (coerce-arg self) (sel_registerName "setFrameOrigin:") new-origin))
(define (nsview-set-frame-size! self new-size)
  (_msg-29 (coerce-arg self) (sel_registerName "setFrameSize:") new-size))
(define (nsview-set-identifier! self identifier)
  (tell #:type _void (coerce-arg self) setIdentifier: (coerce-arg identifier)))
(define (nsview-set-mark! self sender)
  (tell #:type _void (coerce-arg self) setMark: (coerce-arg sender)))
(define (nsview-set-needs-display-in-rect! self invalid-rect)
  (_msg-22 (coerce-arg self) (sel_registerName "setNeedsDisplayInRect:") invalid-rect))
(define (nsview-should-be-treated-as-ink-event self event)
  (_msg-34 (coerce-arg self) (sel_registerName "shouldBeTreatedAsInkEvent:") (coerce-arg event)))
(define (nsview-should-delay-window-ordering-for-event self event)
  (_msg-34 (coerce-arg self) (sel_registerName "shouldDelayWindowOrderingForEvent:") (coerce-arg event)))
(define (nsview-show-context-help self sender)
  (tell #:type _void (coerce-arg self) showContextHelp: (coerce-arg sender)))
(define (nsview-show-context-menu-for-selection self sender)
  (tell #:type _void (coerce-arg self) showContextMenuForSelection: (coerce-arg sender)))
(define (nsview-smart-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) smartMagnifyWithEvent: (coerce-arg event)))
(define (nsview-sort-subviews-using-function-context self compare context)
  (_msg-47 (coerce-arg self) (sel_registerName "sortSubviewsUsingFunction:context:") compare context))
(define (nsview-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (_msg-46 (coerce-arg self) (sel_registerName "supplementalTargetForAction:sender:") (sel_registerName action) (coerce-arg sender))
   ))
(define (nsview-swap-with-mark self sender)
  (tell #:type _void (coerce-arg self) swapWithMark: (coerce-arg sender)))
(define (nsview-swipe-with-event self event)
  (tell #:type _void (coerce-arg self) swipeWithEvent: (coerce-arg event)))
(define (nsview-tablet-point self event)
  (tell #:type _void (coerce-arg self) tabletPoint: (coerce-arg event)))
(define (nsview-tablet-proximity self event)
  (tell #:type _void (coerce-arg self) tabletProximity: (coerce-arg event)))
(define (nsview-touches-began-with-event self event)
  (tell #:type _void (coerce-arg self) touchesBeganWithEvent: (coerce-arg event)))
(define (nsview-touches-cancelled-with-event self event)
  (tell #:type _void (coerce-arg self) touchesCancelledWithEvent: (coerce-arg event)))
(define (nsview-touches-ended-with-event self event)
  (tell #:type _void (coerce-arg self) touchesEndedWithEvent: (coerce-arg event)))
(define (nsview-touches-moved-with-event self event)
  (tell #:type _void (coerce-arg self) touchesMovedWithEvent: (coerce-arg event)))
(define (nsview-translate-origin-to-point self translation)
  (_msg-12 (coerce-arg self) (sel_registerName "translateOriginToPoint:") translation))
(define (nsview-translate-rects-needing-display-in-rect-by self clip-rect delta)
  (_msg-23 (coerce-arg self) (sel_registerName "translateRectsNeedingDisplayInRect:by:") clip-rect delta))
(define (nsview-transpose self sender)
  (tell #:type _void (coerce-arg self) transpose: (coerce-arg sender)))
(define (nsview-transpose-words self sender)
  (tell #:type _void (coerce-arg self) transposeWords: (coerce-arg sender)))
(define (nsview-try-to-perform-with self action object)
  (_msg-45 (coerce-arg self) (sel_registerName "tryToPerform:with:") (sel_registerName action) (coerce-arg object)))
(define (nsview-update-dragging-items-for-drag self sender)
  (tell #:type _void (coerce-arg self) updateDraggingItemsForDrag: (coerce-arg sender)))
(define (nsview-update-layer self)
  (tell #:type _void (coerce-arg self) updateLayer))
(define (nsview-uppercase-word self sender)
  (tell #:type _void (coerce-arg self) uppercaseWord: (coerce-arg sender)))
(define (nsview-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (tell (coerce-arg self) validRequestorForSendType: (coerce-arg send-type) returnType: (coerce-arg return-type))))
(define (nsview-view-did-change-backing-properties self)
  (tell #:type _void (coerce-arg self) viewDidChangeBackingProperties))
(define (nsview-view-did-change-effective-appearance self)
  (tell #:type _void (coerce-arg self) viewDidChangeEffectiveAppearance))
(define (nsview-view-did-end-live-resize self)
  (tell #:type _void (coerce-arg self) viewDidEndLiveResize))
(define (nsview-view-did-hide self)
  (tell #:type _void (coerce-arg self) viewDidHide))
(define (nsview-view-did-move-to-superview self)
  (tell #:type _void (coerce-arg self) viewDidMoveToSuperview))
(define (nsview-view-did-move-to-window self)
  (tell #:type _void (coerce-arg self) viewDidMoveToWindow))
(define (nsview-view-did-unhide self)
  (tell #:type _void (coerce-arg self) viewDidUnhide))
(define (nsview-view-will-draw self)
  (tell #:type _void (coerce-arg self) viewWillDraw))
(define (nsview-view-will-move-to-superview self new-superview)
  (tell #:type _void (coerce-arg self) viewWillMoveToSuperview: (coerce-arg new-superview)))
(define (nsview-view-will-move-to-window self new-window)
  (tell #:type _void (coerce-arg self) viewWillMoveToWindow: (coerce-arg new-window)))
(define (nsview-view-will-start-live-resize self)
  (tell #:type _void (coerce-arg self) viewWillStartLiveResize))
(define (nsview-view-with-tag self tag)
  (wrap-objc-object
   (_msg-39 (coerce-arg self) (sel_registerName "viewWithTag:") tag)
   ))
(define (nsview-wants-forwarded-scroll-events-for-axis self axis)
  (_msg-38 (coerce-arg self) (sel_registerName "wantsForwardedScrollEventsForAxis:") axis))
(define (nsview-wants-periodic-dragging-updates self)
  (_msg-3 (coerce-arg self) (sel_registerName "wantsPeriodicDraggingUpdates")))
(define (nsview-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (_msg-38 (coerce-arg self) (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:") axis))
(define (nsview-will-open-menu-with-event self menu event)
  (tell #:type _void (coerce-arg self) willOpenMenu: (coerce-arg menu) withEvent: (coerce-arg event)))
(define (nsview-will-remove-subview self subview)
  (tell #:type _void (coerce-arg self) willRemoveSubview: (coerce-arg subview)))
(define (nsview-yank self sender)
  (tell #:type _void (coerce-arg self) yank: (coerce-arg sender)))

;; --- Class methods ---
(define (nsview-default-animation-for-key key)
  (wrap-objc-object
   (tell NSView defaultAnimationForKey: (coerce-arg key))))
(define (nsview-is-compatible-with-responsive-scrolling)
  (_msg-3 NSView (sel_registerName "isCompatibleWithResponsiveScrolling")))
