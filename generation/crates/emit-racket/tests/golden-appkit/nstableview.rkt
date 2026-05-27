#lang racket/base
;; Generated binding for NSTableView (AppKit)
;; Do not edit — regenerate from enriched IR

(require ffi/unsafe
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
(define (nsfont? v) (objc-instance-of? v "NSFont"))
(define (nsimage? v) (objc-instance-of? v "NSImage"))
(define (nsindexset? v) (objc-instance-of? v "NSIndexSet"))
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
(define (nssharingservicepicker? v) (objc-instance-of? v "NSSharingServicePicker"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (nstablecolumn? v) (objc-instance-of? v "NSTableColumn"))
(define (nstableheaderview? v) (objc-instance-of? v "NSTableHeaderView"))
(define (nstableview? v) (objc-instance-of? v "NSTableView"))
(define (nstextinputcontext? v) (objc-instance-of? v "NSTextInputContext"))
(define (nstouchbar? v) (objc-instance-of? v "NSTouchBar"))
(define (nsurl? v) (objc-instance-of? v "NSURL"))
(define (nsundomanager? v) (objc-instance-of? v "NSUndoManager"))
(define (nsuseractivity? v) (objc-instance-of? v "NSUserActivity"))
(define (nsview? v) (objc-instance-of? v "NSView"))
(define (nswindow? v) (objc-instance-of? v "NSWindow"))
(define (nswritingtoolscoordinator? v) (objc-instance-of? v "NSWritingToolsCoordinator"))
(provide NSTableView)
(provide/contract
  [make-nstableview-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nstableview-init-with-frame (c-> any/c any/c)]
  [nstableview-accepts-first-responder (c-> nstableview? boolean?)]
  [nstableview-accepts-touch-events (c-> nstableview? boolean?)]
  [nstableview-set-accepts-touch-events! (c-> nstableview? boolean? void?)]
  [nstableview-action (c-> nstableview? cpointer?)]
  [nstableview-set-action! (c-> nstableview? string? void?)]
  [nstableview-additional-safe-area-insets (c-> nstableview? any/c)]
  [nstableview-set-additional-safe-area-insets! (c-> nstableview? any/c void?)]
  [nstableview-alignment (c-> nstableview? exact-integer?)]
  [nstableview-set-alignment! (c-> nstableview? exact-integer? void?)]
  [nstableview-alignment-rect-insets (c-> nstableview? any/c)]
  [nstableview-allowed-touch-types (c-> nstableview? exact-nonnegative-integer?)]
  [nstableview-set-allowed-touch-types! (c-> nstableview? exact-nonnegative-integer? void?)]
  [nstableview-allows-column-reordering (c-> nstableview? boolean?)]
  [nstableview-set-allows-column-reordering! (c-> nstableview? boolean? void?)]
  [nstableview-allows-column-resizing (c-> nstableview? boolean?)]
  [nstableview-set-allows-column-resizing! (c-> nstableview? boolean? void?)]
  [nstableview-allows-column-selection (c-> nstableview? boolean?)]
  [nstableview-set-allows-column-selection! (c-> nstableview? boolean? void?)]
  [nstableview-allows-empty-selection (c-> nstableview? boolean?)]
  [nstableview-set-allows-empty-selection! (c-> nstableview? boolean? void?)]
  [nstableview-allows-expansion-tool-tips (c-> nstableview? boolean?)]
  [nstableview-set-allows-expansion-tool-tips! (c-> nstableview? boolean? void?)]
  [nstableview-allows-multiple-selection (c-> nstableview? boolean?)]
  [nstableview-set-allows-multiple-selection! (c-> nstableview? boolean? void?)]
  [nstableview-allows-type-select (c-> nstableview? boolean?)]
  [nstableview-set-allows-type-select! (c-> nstableview? boolean? void?)]
  [nstableview-allows-vibrancy (c-> nstableview? boolean?)]
  [nstableview-alpha-value (c-> nstableview? real?)]
  [nstableview-set-alpha-value! (c-> nstableview? real? void?)]
  [nstableview-attributed-string-value (c-> nstableview? (or/c nsattributedstring? objc-nil?))]
  [nstableview-set-attributed-string-value! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-autoresizes-subviews (c-> nstableview? boolean?)]
  [nstableview-set-autoresizes-subviews! (c-> nstableview? boolean? void?)]
  [nstableview-autoresizing-mask (c-> nstableview? exact-nonnegative-integer?)]
  [nstableview-set-autoresizing-mask! (c-> nstableview? exact-nonnegative-integer? void?)]
  [nstableview-autosave-name (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-set-autosave-name! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-autosave-table-columns (c-> nstableview? boolean?)]
  [nstableview-set-autosave-table-columns! (c-> nstableview? boolean? void?)]
  [nstableview-background-color (c-> nstableview? (or/c nscolor? objc-nil?))]
  [nstableview-set-background-color! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-background-filters (c-> nstableview? any/c)]
  [nstableview-set-background-filters! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-base-writing-direction (c-> nstableview? exact-integer?)]
  [nstableview-set-base-writing-direction! (c-> nstableview? exact-integer? void?)]
  [nstableview-baseline-offset-from-bottom (c-> nstableview? real?)]
  [nstableview-bottom-anchor (c-> nstableview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstableview-bounds (c-> nstableview? any/c)]
  [nstableview-set-bounds! (c-> nstableview? any/c void?)]
  [nstableview-bounds-rotation (c-> nstableview? real?)]
  [nstableview-set-bounds-rotation! (c-> nstableview? real? void?)]
  [nstableview-can-become-key-view (c-> nstableview? boolean?)]
  [nstableview-can-draw (c-> nstableview? boolean?)]
  [nstableview-can-draw-concurrently (c-> nstableview? boolean?)]
  [nstableview-set-can-draw-concurrently! (c-> nstableview? boolean? void?)]
  [nstableview-can-draw-subviews-into-layer (c-> nstableview? boolean?)]
  [nstableview-set-can-draw-subviews-into-layer! (c-> nstableview? boolean? void?)]
  [nstableview-candidate-list-touch-bar-item (c-> nstableview? (or/c nscandidatelisttouchbaritem? objc-nil?))]
  [nstableview-cell (c-> nstableview? any/c)]
  [nstableview-set-cell! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-cell-class (c-> cpointer?)]
  [nstableview-set-cell-class! (c-> cpointer? void?)]
  [nstableview-center-x-anchor (c-> nstableview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstableview-center-y-anchor (c-> nstableview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstableview-clicked-column (c-> nstableview? exact-integer?)]
  [nstableview-clicked-row (c-> nstableview? exact-integer?)]
  [nstableview-clips-to-bounds (c-> nstableview? boolean?)]
  [nstableview-set-clips-to-bounds! (c-> nstableview? boolean? void?)]
  [nstableview-column-autoresizing-style (c-> nstableview? exact-nonnegative-integer?)]
  [nstableview-set-column-autoresizing-style! (c-> nstableview? exact-nonnegative-integer? void?)]
  [nstableview-compatible-with-responsive-scrolling (c-> boolean?)]
  [nstableview-compositing-filter (c-> nstableview? (or/c cifilter? objc-nil?))]
  [nstableview-set-compositing-filter! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-constraints (c-> nstableview? any/c)]
  [nstableview-content-filters (c-> nstableview? any/c)]
  [nstableview-set-content-filters! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-continuous (c-> nstableview? boolean?)]
  [nstableview-set-continuous! (c-> nstableview? boolean? void?)]
  [nstableview-control-size (c-> nstableview? exact-nonnegative-integer?)]
  [nstableview-set-control-size! (c-> nstableview? exact-nonnegative-integer? void?)]
  [nstableview-corner-view (c-> nstableview? (or/c nsview? objc-nil?))]
  [nstableview-set-corner-view! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-data-source (c-> nstableview? any/c)]
  [nstableview-set-data-source! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-default-focus-ring-type (c-> exact-nonnegative-integer?)]
  [nstableview-default-menu (c-> (or/c nsmenu? objc-nil?))]
  [nstableview-delegate (c-> nstableview? any/c)]
  [nstableview-set-delegate! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-double-action (c-> nstableview? cpointer?)]
  [nstableview-set-double-action! (c-> nstableview? string? void?)]
  [nstableview-double-value (c-> nstableview? real?)]
  [nstableview-set-double-value! (c-> nstableview? real? void?)]
  [nstableview-dragging-destination-feedback-style (c-> nstableview? exact-integer?)]
  [nstableview-set-dragging-destination-feedback-style! (c-> nstableview? exact-integer? void?)]
  [nstableview-drawing-find-indicator (c-> nstableview? boolean?)]
  [nstableview-edited-column (c-> nstableview? exact-integer?)]
  [nstableview-edited-row (c-> nstableview? exact-integer?)]
  [nstableview-effective-row-size-style (c-> nstableview? exact-integer?)]
  [nstableview-effective-style (c-> nstableview? exact-integer?)]
  [nstableview-enabled (c-> nstableview? boolean?)]
  [nstableview-set-enabled! (c-> nstableview? boolean? void?)]
  [nstableview-enclosing-menu-item (c-> nstableview? (or/c nsmenuitem? objc-nil?))]
  [nstableview-enclosing-scroll-view (c-> nstableview? (or/c nsscrollview? objc-nil?))]
  [nstableview-first-baseline-anchor (c-> nstableview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstableview-first-baseline-offset-from-top (c-> nstableview? real?)]
  [nstableview-fitting-size (c-> nstableview? any/c)]
  [nstableview-flipped (c-> nstableview? boolean?)]
  [nstableview-float-value (c-> nstableview? real?)]
  [nstableview-set-float-value! (c-> nstableview? real? void?)]
  [nstableview-floats-group-rows (c-> nstableview? boolean?)]
  [nstableview-set-floats-group-rows! (c-> nstableview? boolean? void?)]
  [nstableview-focus-ring-mask-bounds (c-> nstableview? any/c)]
  [nstableview-focus-ring-type (c-> nstableview? exact-nonnegative-integer?)]
  [nstableview-set-focus-ring-type! (c-> nstableview? exact-nonnegative-integer? void?)]
  [nstableview-focus-view (c-> (or/c nsview? objc-nil?))]
  [nstableview-font (c-> nstableview? (or/c nsfont? objc-nil?))]
  [nstableview-set-font! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-formatter (c-> nstableview? any/c)]
  [nstableview-set-formatter! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-frame (c-> nstableview? any/c)]
  [nstableview-set-frame! (c-> nstableview? any/c void?)]
  [nstableview-frame-center-rotation (c-> nstableview? real?)]
  [nstableview-set-frame-center-rotation! (c-> nstableview? real? void?)]
  [nstableview-frame-rotation (c-> nstableview? real?)]
  [nstableview-set-frame-rotation! (c-> nstableview? real? void?)]
  [nstableview-gesture-recognizers (c-> nstableview? any/c)]
  [nstableview-set-gesture-recognizers! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-grid-color (c-> nstableview? (or/c nscolor? objc-nil?))]
  [nstableview-set-grid-color! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-grid-style-mask (c-> nstableview? exact-nonnegative-integer?)]
  [nstableview-set-grid-style-mask! (c-> nstableview? exact-nonnegative-integer? void?)]
  [nstableview-has-ambiguous-layout (c-> nstableview? boolean?)]
  [nstableview-header-view (c-> nstableview? (or/c nstableheaderview? objc-nil?))]
  [nstableview-set-header-view! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-height-adjust-limit (c-> nstableview? real?)]
  [nstableview-height-anchor (c-> nstableview? (or/c nslayoutdimension? objc-nil?))]
  [nstableview-hidden (c-> nstableview? boolean?)]
  [nstableview-set-hidden! (c-> nstableview? boolean? void?)]
  [nstableview-hidden-or-has-hidden-ancestor (c-> nstableview? boolean?)]
  [nstableview-hidden-row-indexes (c-> nstableview? (or/c nsindexset? objc-nil?))]
  [nstableview-highlighted (c-> nstableview? boolean?)]
  [nstableview-set-highlighted! (c-> nstableview? boolean? void?)]
  [nstableview-highlighted-table-column (c-> nstableview? (or/c nstablecolumn? objc-nil?))]
  [nstableview-set-highlighted-table-column! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-horizontal-content-size-constraint-active (c-> nstableview? boolean?)]
  [nstableview-set-horizontal-content-size-constraint-active! (c-> nstableview? boolean? void?)]
  [nstableview-ignores-multi-click (c-> nstableview? boolean?)]
  [nstableview-set-ignores-multi-click! (c-> nstableview? boolean? void?)]
  [nstableview-in-full-screen-mode (c-> nstableview? boolean?)]
  [nstableview-in-live-resize (c-> nstableview? boolean?)]
  [nstableview-input-context (c-> nstableview? (or/c nstextinputcontext? objc-nil?))]
  [nstableview-int-value (c-> nstableview? exact-integer?)]
  [nstableview-set-int-value! (c-> nstableview? exact-integer? void?)]
  [nstableview-integer-value (c-> nstableview? exact-integer?)]
  [nstableview-set-integer-value! (c-> nstableview? exact-integer? void?)]
  [nstableview-intercell-spacing (c-> nstableview? any/c)]
  [nstableview-set-intercell-spacing! (c-> nstableview? any/c void?)]
  [nstableview-intrinsic-content-size (c-> nstableview? any/c)]
  [nstableview-last-baseline-anchor (c-> nstableview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstableview-last-baseline-offset-from-bottom (c-> nstableview? real?)]
  [nstableview-layer (c-> nstableview? (or/c calayer? objc-nil?))]
  [nstableview-set-layer! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-layer-contents-placement (c-> nstableview? exact-integer?)]
  [nstableview-set-layer-contents-placement! (c-> nstableview? exact-integer? void?)]
  [nstableview-layer-contents-redraw-policy (c-> nstableview? exact-integer?)]
  [nstableview-set-layer-contents-redraw-policy! (c-> nstableview? exact-integer? void?)]
  [nstableview-layer-uses-core-image-filters (c-> nstableview? boolean?)]
  [nstableview-set-layer-uses-core-image-filters! (c-> nstableview? boolean? void?)]
  [nstableview-layout-guides (c-> nstableview? any/c)]
  [nstableview-layout-margins-guide (c-> nstableview? (or/c nslayoutguide? objc-nil?))]
  [nstableview-leading-anchor (c-> nstableview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstableview-left-anchor (c-> nstableview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstableview-line-break-mode (c-> nstableview? exact-nonnegative-integer?)]
  [nstableview-set-line-break-mode! (c-> nstableview? exact-nonnegative-integer? void?)]
  [nstableview-menu (c-> nstableview? (or/c nsmenu? objc-nil?))]
  [nstableview-set-menu! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-mouse-down-can-move-window (c-> nstableview? boolean?)]
  [nstableview-needs-display (c-> nstableview? boolean?)]
  [nstableview-set-needs-display! (c-> nstableview? boolean? void?)]
  [nstableview-needs-layout (c-> nstableview? boolean?)]
  [nstableview-set-needs-layout! (c-> nstableview? boolean? void?)]
  [nstableview-needs-panel-to-become-key (c-> nstableview? boolean?)]
  [nstableview-needs-update-constraints (c-> nstableview? boolean?)]
  [nstableview-set-needs-update-constraints! (c-> nstableview? boolean? void?)]
  [nstableview-next-key-view (c-> nstableview? (or/c nsview? objc-nil?))]
  [nstableview-set-next-key-view! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-next-responder (c-> nstableview? (or/c nsresponder? objc-nil?))]
  [nstableview-set-next-responder! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-next-valid-key-view (c-> nstableview? (or/c nsview? objc-nil?))]
  [nstableview-number-of-columns (c-> nstableview? exact-integer?)]
  [nstableview-number-of-rows (c-> nstableview? exact-integer?)]
  [nstableview-number-of-selected-columns (c-> nstableview? exact-integer?)]
  [nstableview-number-of-selected-rows (c-> nstableview? exact-integer?)]
  [nstableview-object-value (c-> nstableview? any/c)]
  [nstableview-set-object-value! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-opaque (c-> nstableview? boolean?)]
  [nstableview-opaque-ancestor (c-> nstableview? (or/c nsview? objc-nil?))]
  [nstableview-page-footer (c-> nstableview? (or/c nsattributedstring? objc-nil?))]
  [nstableview-page-header (c-> nstableview? (or/c nsattributedstring? objc-nil?))]
  [nstableview-posts-bounds-changed-notifications (c-> nstableview? boolean?)]
  [nstableview-set-posts-bounds-changed-notifications! (c-> nstableview? boolean? void?)]
  [nstableview-posts-frame-changed-notifications (c-> nstableview? boolean?)]
  [nstableview-set-posts-frame-changed-notifications! (c-> nstableview? boolean? void?)]
  [nstableview-prefers-compact-control-size-metrics (c-> nstableview? boolean?)]
  [nstableview-set-prefers-compact-control-size-metrics! (c-> nstableview? boolean? void?)]
  [nstableview-prepared-content-rect (c-> nstableview? any/c)]
  [nstableview-set-prepared-content-rect! (c-> nstableview? any/c void?)]
  [nstableview-preserves-content-during-live-resize (c-> nstableview? boolean?)]
  [nstableview-pressure-configuration (c-> nstableview? (or/c nspressureconfiguration? objc-nil?))]
  [nstableview-set-pressure-configuration! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-previous-key-view (c-> nstableview? (or/c nsview? objc-nil?))]
  [nstableview-previous-valid-key-view (c-> nstableview? (or/c nsview? objc-nil?))]
  [nstableview-print-job-title (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-rect-preserved-during-live-resize (c-> nstableview? any/c)]
  [nstableview-refuses-first-responder (c-> nstableview? boolean?)]
  [nstableview-set-refuses-first-responder! (c-> nstableview? boolean? void?)]
  [nstableview-registered-dragged-types (c-> nstableview? any/c)]
  [nstableview-registered-nibs-by-identifier (c-> nstableview? any/c)]
  [nstableview-requires-constraint-based-layout (c-> boolean?)]
  [nstableview-restorable-state-key-paths (c-> any/c)]
  [nstableview-right-anchor (c-> nstableview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstableview-rotated-from-base (c-> nstableview? boolean?)]
  [nstableview-rotated-or-scaled-from-base (c-> nstableview? boolean?)]
  [nstableview-row-actions-visible (c-> nstableview? boolean?)]
  [nstableview-set-row-actions-visible! (c-> nstableview? boolean? void?)]
  [nstableview-row-height (c-> nstableview? real?)]
  [nstableview-set-row-height! (c-> nstableview? real? void?)]
  [nstableview-row-size-style (c-> nstableview? exact-integer?)]
  [nstableview-set-row-size-style! (c-> nstableview? exact-integer? void?)]
  [nstableview-safe-area-insets (c-> nstableview? any/c)]
  [nstableview-safe-area-layout-guide (c-> nstableview? (or/c nslayoutguide? objc-nil?))]
  [nstableview-safe-area-rect (c-> nstableview? any/c)]
  [nstableview-selected-column (c-> nstableview? exact-integer?)]
  [nstableview-selected-column-indexes (c-> nstableview? (or/c nsindexset? objc-nil?))]
  [nstableview-selected-row (c-> nstableview? exact-integer?)]
  [nstableview-selected-row-indexes (c-> nstableview? (or/c nsindexset? objc-nil?))]
  [nstableview-selection-highlight-style (c-> nstableview? exact-integer?)]
  [nstableview-set-selection-highlight-style! (c-> nstableview? exact-integer? void?)]
  [nstableview-shadow (c-> nstableview? (or/c nsshadow? objc-nil?))]
  [nstableview-set-shadow! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-sort-descriptors (c-> nstableview? any/c)]
  [nstableview-set-sort-descriptors! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-string-value (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-set-string-value! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-style (c-> nstableview? exact-integer?)]
  [nstableview-set-style! (c-> nstableview? exact-integer? void?)]
  [nstableview-subviews (c-> nstableview? any/c)]
  [nstableview-set-subviews! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-superview (c-> nstableview? (or/c nsview? objc-nil?))]
  [nstableview-table-columns (c-> nstableview? any/c)]
  [nstableview-tag (c-> nstableview? exact-integer?)]
  [nstableview-set-tag! (c-> nstableview? exact-integer? void?)]
  [nstableview-target (c-> nstableview? any/c)]
  [nstableview-set-target! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-tool-tip (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-set-tool-tip! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-top-anchor (c-> nstableview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstableview-touch-bar (c-> nstableview? (or/c nstouchbar? objc-nil?))]
  [nstableview-set-touch-bar! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-tracking-areas (c-> nstableview? any/c)]
  [nstableview-trailing-anchor (c-> nstableview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstableview-translates-autoresizing-mask-into-constraints (c-> nstableview? boolean?)]
  [nstableview-set-translates-autoresizing-mask-into-constraints! (c-> nstableview? boolean? void?)]
  [nstableview-undo-manager (c-> nstableview? (or/c nsundomanager? objc-nil?))]
  [nstableview-user-activity (c-> nstableview? (or/c nsuseractivity? objc-nil?))]
  [nstableview-set-user-activity! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-user-interface-layout-direction (c-> nstableview? exact-integer?)]
  [nstableview-set-user-interface-layout-direction! (c-> nstableview? exact-integer? void?)]
  [nstableview-uses-alternating-row-background-colors (c-> nstableview? boolean?)]
  [nstableview-set-uses-alternating-row-background-colors! (c-> nstableview? boolean? void?)]
  [nstableview-uses-automatic-row-heights (c-> nstableview? boolean?)]
  [nstableview-set-uses-automatic-row-heights! (c-> nstableview? boolean? void?)]
  [nstableview-uses-single-line-mode (c-> nstableview? boolean?)]
  [nstableview-set-uses-single-line-mode! (c-> nstableview? boolean? void?)]
  [nstableview-uses-static-contents (c-> nstableview? boolean?)]
  [nstableview-set-uses-static-contents! (c-> nstableview? boolean? void?)]
  [nstableview-vertical-content-size-constraint-active (c-> nstableview? boolean?)]
  [nstableview-set-vertical-content-size-constraint-active! (c-> nstableview? boolean? void?)]
  [nstableview-vertical-motion-can-begin-drag (c-> nstableview? boolean?)]
  [nstableview-set-vertical-motion-can-begin-drag! (c-> nstableview? boolean? void?)]
  [nstableview-visible-rect (c-> nstableview? any/c)]
  [nstableview-wants-best-resolution-open-gl-surface (c-> nstableview? boolean?)]
  [nstableview-set-wants-best-resolution-open-gl-surface! (c-> nstableview? boolean? void?)]
  [nstableview-wants-default-clipping (c-> nstableview? boolean?)]
  [nstableview-wants-extended-dynamic-range-open-gl-surface (c-> nstableview? boolean?)]
  [nstableview-set-wants-extended-dynamic-range-open-gl-surface! (c-> nstableview? boolean? void?)]
  [nstableview-wants-layer (c-> nstableview? boolean?)]
  [nstableview-set-wants-layer! (c-> nstableview? boolean? void?)]
  [nstableview-wants-resting-touches (c-> nstableview? boolean?)]
  [nstableview-set-wants-resting-touches! (c-> nstableview? boolean? void?)]
  [nstableview-wants-update-layer (c-> nstableview? boolean?)]
  [nstableview-width-adjust-limit (c-> nstableview? real?)]
  [nstableview-width-anchor (c-> nstableview? (or/c nslayoutdimension? objc-nil?))]
  [nstableview-window (c-> nstableview? (or/c nswindow? objc-nil?))]
  [nstableview-writing-tools-coordinator (c-> nstableview? (or/c nswritingtoolscoordinator? objc-nil?))]
  [nstableview-set-writing-tools-coordinator! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-accepts-first-mouse (c-> nstableview? (or/c string? objc-object? #f) boolean?)]
  [nstableview-accessibility-activation-point (c-> nstableview? any/c)]
  [nstableview-accessibility-allowed-values (c-> nstableview? any/c)]
  [nstableview-accessibility-application-focused-ui-element (c-> nstableview? any/c)]
  [nstableview-accessibility-attributed-string-for-range (c-> nstableview? any/c (or/c nsattributedstring? objc-nil?))]
  [nstableview-accessibility-attributed-user-input-labels (c-> nstableview? any/c)]
  [nstableview-accessibility-cancel-button (c-> nstableview? any/c)]
  [nstableview-accessibility-cell-for-column-row (c-> nstableview? exact-integer? exact-integer? any/c)]
  [nstableview-accessibility-children (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-children-in-navigation-order (c-> nstableview? any/c)]
  [nstableview-accessibility-clear-button (c-> nstableview? any/c)]
  [nstableview-accessibility-close-button (c-> nstableview? any/c)]
  [nstableview-accessibility-column-count (c-> nstableview? exact-integer?)]
  [nstableview-accessibility-column-header-ui-elements (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-column-index-range (c-> nstableview? any/c)]
  [nstableview-accessibility-column-titles (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-columns (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-contents (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-critical-value (c-> nstableview? any/c)]
  [nstableview-accessibility-custom-actions (c-> nstableview? any/c)]
  [nstableview-accessibility-custom-rotors (c-> nstableview? any/c)]
  [nstableview-accessibility-decrement-button (c-> nstableview? any/c)]
  [nstableview-accessibility-default-button (c-> nstableview? any/c)]
  [nstableview-accessibility-disclosed-by-row (c-> nstableview? any/c)]
  [nstableview-accessibility-disclosed-rows (c-> nstableview? any/c)]
  [nstableview-accessibility-disclosure-level (c-> nstableview? exact-integer?)]
  [nstableview-accessibility-document (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-accessibility-extras-menu-bar (c-> nstableview? any/c)]
  [nstableview-accessibility-filename (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-accessibility-focused-window (c-> nstableview? any/c)]
  [nstableview-accessibility-frame (c-> nstableview? any/c)]
  [nstableview-accessibility-frame-for-range (c-> nstableview? any/c any/c)]
  [nstableview-accessibility-full-screen-button (c-> nstableview? any/c)]
  [nstableview-accessibility-grow-area (c-> nstableview? any/c)]
  [nstableview-accessibility-handles (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-header (c-> nstableview? any/c)]
  [nstableview-accessibility-help (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-accessibility-horizontal-scroll-bar (c-> nstableview? any/c)]
  [nstableview-accessibility-horizontal-unit-description (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-accessibility-horizontal-units (c-> nstableview? exact-integer?)]
  [nstableview-accessibility-identifier (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-accessibility-increment-button (c-> nstableview? any/c)]
  [nstableview-accessibility-index (c-> nstableview? exact-integer?)]
  [nstableview-accessibility-insertion-point-line-number (c-> nstableview? exact-integer?)]
  [nstableview-accessibility-label (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-accessibility-label-ui-elements (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-label-value (c-> nstableview? real?)]
  [nstableview-accessibility-layout-point-for-screen-point (c-> nstableview? any/c any/c)]
  [nstableview-accessibility-layout-size-for-screen-size (c-> nstableview? any/c any/c)]
  [nstableview-accessibility-line-for-index (c-> nstableview? exact-integer? exact-integer?)]
  [nstableview-accessibility-linked-ui-elements (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-main-window (c-> nstableview? any/c)]
  [nstableview-accessibility-marker-group-ui-element (c-> nstableview? any/c)]
  [nstableview-accessibility-marker-type-description (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-accessibility-marker-ui-elements (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-marker-values (c-> nstableview? any/c)]
  [nstableview-accessibility-max-value (c-> nstableview? any/c)]
  [nstableview-accessibility-menu-bar (c-> nstableview? any/c)]
  [nstableview-accessibility-min-value (c-> nstableview? any/c)]
  [nstableview-accessibility-minimize-button (c-> nstableview? any/c)]
  [nstableview-accessibility-next-contents (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-number-of-characters (c-> nstableview? exact-integer?)]
  [nstableview-accessibility-orientation (c-> nstableview? exact-integer?)]
  [nstableview-accessibility-overflow-button (c-> nstableview? any/c)]
  [nstableview-accessibility-parent (c-> nstableview? any/c)]
  [nstableview-accessibility-perform-cancel (c-> nstableview? boolean?)]
  [nstableview-accessibility-perform-confirm (c-> nstableview? boolean?)]
  [nstableview-accessibility-perform-decrement (c-> nstableview? boolean?)]
  [nstableview-accessibility-perform-delete (c-> nstableview? boolean?)]
  [nstableview-accessibility-perform-increment (c-> nstableview? boolean?)]
  [nstableview-accessibility-perform-pick (c-> nstableview? boolean?)]
  [nstableview-accessibility-perform-press (c-> nstableview? boolean?)]
  [nstableview-accessibility-perform-raise (c-> nstableview? boolean?)]
  [nstableview-accessibility-perform-show-alternate-ui (c-> nstableview? boolean?)]
  [nstableview-accessibility-perform-show-default-ui (c-> nstableview? boolean?)]
  [nstableview-accessibility-perform-show-menu (c-> nstableview? boolean?)]
  [nstableview-accessibility-placeholder-value (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-accessibility-previous-contents (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-proxy (c-> nstableview? any/c)]
  [nstableview-accessibility-rtf-for-range (c-> nstableview? any/c (or/c nsdata? objc-nil?))]
  [nstableview-accessibility-range-for-index (c-> nstableview? exact-integer? any/c)]
  [nstableview-accessibility-range-for-line (c-> nstableview? exact-integer? any/c)]
  [nstableview-accessibility-range-for-position (c-> nstableview? any/c any/c)]
  [nstableview-accessibility-role (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-accessibility-role-description (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-accessibility-row-count (c-> nstableview? exact-integer?)]
  [nstableview-accessibility-row-header-ui-elements (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-row-index-range (c-> nstableview? any/c)]
  [nstableview-accessibility-rows (c-> nstableview? any/c)]
  [nstableview-accessibility-ruler-marker-type (c-> nstableview? exact-integer?)]
  [nstableview-accessibility-screen-point-for-layout-point (c-> nstableview? any/c any/c)]
  [nstableview-accessibility-screen-size-for-layout-size (c-> nstableview? any/c any/c)]
  [nstableview-accessibility-search-button (c-> nstableview? any/c)]
  [nstableview-accessibility-search-menu (c-> nstableview? any/c)]
  [nstableview-accessibility-selected-cells (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-selected-children (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-selected-columns (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-selected-rows (c-> nstableview? any/c)]
  [nstableview-accessibility-selected-text (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-accessibility-selected-text-range (c-> nstableview? any/c)]
  [nstableview-accessibility-selected-text-ranges (c-> nstableview? any/c)]
  [nstableview-accessibility-serves-as-title-for-ui-elements (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-shared-character-range (c-> nstableview? any/c)]
  [nstableview-accessibility-shared-focus-elements (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-shared-text-ui-elements (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-shown-menu (c-> nstableview? any/c)]
  [nstableview-accessibility-sort-direction (c-> nstableview? exact-integer?)]
  [nstableview-accessibility-splitters (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-string-for-range (c-> nstableview? any/c (or/c nsstring? objc-nil?))]
  [nstableview-accessibility-style-range-for-index (c-> nstableview? exact-integer? any/c)]
  [nstableview-accessibility-subrole (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-accessibility-tabs (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-title (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-accessibility-title-ui-element (c-> nstableview? any/c)]
  [nstableview-accessibility-toolbar-button (c-> nstableview? any/c)]
  [nstableview-accessibility-top-level-ui-element (c-> nstableview? any/c)]
  [nstableview-accessibility-url (c-> nstableview? (or/c nsurl? objc-nil?))]
  [nstableview-accessibility-unit-description (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-accessibility-units (c-> nstableview? exact-integer?)]
  [nstableview-accessibility-user-input-labels (c-> nstableview? any/c)]
  [nstableview-accessibility-value (c-> nstableview? any/c)]
  [nstableview-accessibility-value-description (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-accessibility-vertical-scroll-bar (c-> nstableview? any/c)]
  [nstableview-accessibility-vertical-unit-description (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-accessibility-vertical-units (c-> nstableview? exact-integer?)]
  [nstableview-accessibility-visible-cells (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-visible-character-range (c-> nstableview? any/c)]
  [nstableview-accessibility-visible-children (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-visible-columns (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-visible-rows (c-> nstableview? any/c)]
  [nstableview-accessibility-warning-value (c-> nstableview? any/c)]
  [nstableview-accessibility-window (c-> nstableview? any/c)]
  [nstableview-accessibility-windows (c-> nstableview? (or/c nsarray? objc-nil?))]
  [nstableview-accessibility-zoom-button (c-> nstableview? any/c)]
  [nstableview-add-subview! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-add-subview-positioned-relative-to! (c-> nstableview? (or/c string? objc-object? #f) exact-integer? (or/c string? objc-object? #f) void?)]
  [nstableview-add-table-column! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-add-tool-tip-rect-owner-user-data! (c-> nstableview? any/c (or/c string? objc-object? #f) (or/c cpointer? #f) exact-integer?)]
  [nstableview-adjust-scroll (c-> nstableview? any/c any/c)]
  [nstableview-ancestor-shared-with-view (c-> nstableview? (or/c string? objc-object? #f) (or/c nsview? objc-nil?))]
  [nstableview-animation-for-key (c-> nstableview? (or/c string? objc-object? #f) any/c)]
  [nstableview-animations (c-> nstableview? any/c)]
  [nstableview-animator (c-> nstableview? any/c)]
  [nstableview-appearance (c-> nstableview? (or/c nsappearance? objc-nil?))]
  [nstableview-autoscroll (c-> nstableview? (or/c string? objc-object? #f) boolean?)]
  [nstableview-backing-aligned-rect-options (c-> nstableview? any/c exact-nonnegative-integer? any/c)]
  [nstableview-become-first-responder (c-> nstableview? boolean?)]
  [nstableview-begin-gesture-with-event! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-begin-updates! (c-> nstableview? void?)]
  [nstableview-bitmap-image-rep-for-caching-display-in-rect (c-> nstableview? any/c (or/c nsbitmapimagerep? objc-nil?))]
  [nstableview-cache-display-in-rect-to-bitmap-image-rep (c-> nstableview? any/c (or/c string? objc-object? #f) void?)]
  [nstableview-can-drag-rows-with-indexes-at-point (c-> nstableview? (or/c string? objc-object? #f) any/c boolean?)]
  [nstableview-cancel-operation (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-capitalize-word (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-center-scan-rect! (c-> nstableview? any/c any/c)]
  [nstableview-center-selection-in-visible-area! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-change-case-of-letter (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-change-mode-with-event (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-column-at-point (c-> nstableview? any/c exact-integer?)]
  [nstableview-column-for-view (c-> nstableview? (or/c string? objc-object? #f) exact-integer?)]
  [nstableview-column-indexes-in-rect (c-> nstableview? any/c (or/c nsindexset? objc-nil?))]
  [nstableview-column-with-identifier (c-> nstableview? (or/c string? objc-object? #f) exact-integer?)]
  [nstableview-complete (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-conclude-drag-operation (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-context-menu-key-down (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-convert-point-from-view (c-> nstableview? any/c (or/c string? objc-object? #f) any/c)]
  [nstableview-convert-point-to-view (c-> nstableview? any/c (or/c string? objc-object? #f) any/c)]
  [nstableview-convert-point-from-backing (c-> nstableview? any/c any/c)]
  [nstableview-convert-point-from-layer (c-> nstableview? any/c any/c)]
  [nstableview-convert-point-to-backing (c-> nstableview? any/c any/c)]
  [nstableview-convert-point-to-layer (c-> nstableview? any/c any/c)]
  [nstableview-convert-rect-from-view (c-> nstableview? any/c (or/c string? objc-object? #f) any/c)]
  [nstableview-convert-rect-to-view (c-> nstableview? any/c (or/c string? objc-object? #f) any/c)]
  [nstableview-convert-rect-from-backing (c-> nstableview? any/c any/c)]
  [nstableview-convert-rect-from-layer (c-> nstableview? any/c any/c)]
  [nstableview-convert-rect-to-backing (c-> nstableview? any/c any/c)]
  [nstableview-convert-rect-to-layer (c-> nstableview? any/c any/c)]
  [nstableview-convert-size-from-view (c-> nstableview? any/c (or/c string? objc-object? #f) any/c)]
  [nstableview-convert-size-to-view (c-> nstableview? any/c (or/c string? objc-object? #f) any/c)]
  [nstableview-convert-size-from-backing (c-> nstableview? any/c any/c)]
  [nstableview-convert-size-from-layer (c-> nstableview? any/c any/c)]
  [nstableview-convert-size-to-backing (c-> nstableview? any/c any/c)]
  [nstableview-convert-size-to-layer (c-> nstableview? any/c any/c)]
  [nstableview-cursor-update (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-delete-backward (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-delete-backward-by-decomposing-previous-character (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-delete-forward (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-delete-to-beginning-of-line (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-delete-to-beginning-of-paragraph (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-delete-to-end-of-line (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-delete-to-end-of-paragraph (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-delete-to-mark (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-delete-word-backward (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-delete-word-forward (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-deselect-all (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-deselect-column (c-> nstableview? exact-integer? void?)]
  [nstableview-deselect-row (c-> nstableview? exact-integer? void?)]
  [nstableview-did-add-row-view-for-row (c-> nstableview? (or/c string? objc-object? #f) exact-integer? void?)]
  [nstableview-did-add-subview (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-did-close-menu-with-event (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstableview-did-remove-row-view-for-row (c-> nstableview? (or/c string? objc-object? #f) exact-integer? void?)]
  [nstableview-display! (c-> nstableview? void?)]
  [nstableview-display-if-needed! (c-> nstableview? void?)]
  [nstableview-display-if-needed-ignoring-opacity! (c-> nstableview? void?)]
  [nstableview-display-if-needed-in-rect! (c-> nstableview? any/c void?)]
  [nstableview-display-if-needed-in-rect-ignoring-opacity! (c-> nstableview? any/c void?)]
  [nstableview-display-rect! (c-> nstableview? any/c void?)]
  [nstableview-display-rect-ignoring-opacity! (c-> nstableview? any/c void?)]
  [nstableview-display-rect-ignoring-opacity-in-context! (c-> nstableview? any/c (or/c string? objc-object? #f) void?)]
  [nstableview-do-command-by-selector (c-> nstableview? string? void?)]
  [nstableview-drag-image-for-rows-with-indexes-table-columns-event-offset (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c cpointer? #f) (or/c nsimage? objc-nil?))]
  [nstableview-dragging-ended (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-dragging-entered (c-> nstableview? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nstableview-dragging-exited (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-dragging-session-ended-at-point-operation (c-> nstableview? (or/c string? objc-object? #f) any/c exact-nonnegative-integer? void?)]
  [nstableview-dragging-session-moved-to-point (c-> nstableview? (or/c string? objc-object? #f) any/c void?)]
  [nstableview-dragging-session-source-operation-mask-for-dragging-context (c-> nstableview? (or/c string? objc-object? #f) exact-integer? exact-nonnegative-integer?)]
  [nstableview-dragging-session-will-begin-at-point (c-> nstableview? (or/c string? objc-object? #f) any/c void?)]
  [nstableview-dragging-updated (c-> nstableview? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nstableview-draw-background-in-clip-rect (c-> nstableview? any/c void?)]
  [nstableview-draw-grid-in-clip-rect (c-> nstableview? any/c void?)]
  [nstableview-draw-rect (c-> nstableview? any/c void?)]
  [nstableview-draw-row-clip-rect (c-> nstableview? exact-integer? any/c void?)]
  [nstableview-draw-with-expansion-frame-in-view (c-> nstableview? any/c (or/c string? objc-object? #f) void?)]
  [nstableview-edit-column-row-with-event-select (c-> nstableview? exact-integer? exact-integer? (or/c string? objc-object? #f) boolean? void?)]
  [nstableview-effective-appearance (c-> nstableview? (or/c nsappearance? objc-nil?))]
  [nstableview-encode-with-coder (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-end-gesture-with-event! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-end-updates! (c-> nstableview? void?)]
  [nstableview-enumerate-available-row-views-using-block (c-> nstableview? (or/c procedure? #f) void?)]
  [nstableview-expansion-frame-with-frame (c-> nstableview? any/c any/c)]
  [nstableview-flags-changed (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-flush-buffered-key-events (c-> nstableview? void?)]
  [nstableview-frame-of-cell-at-column-row (c-> nstableview? exact-integer? exact-integer? any/c)]
  [nstableview-get-rects-being-drawn-count (c-> nstableview? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nstableview-get-rects-exposed-during-live-resize-count (c-> nstableview? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nstableview-help-requested (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-hide-rows-at-indexes-with-animation (c-> nstableview? (or/c string? objc-object? #f) exact-nonnegative-integer? void?)]
  [nstableview-highlight-selection-in-clip-rect (c-> nstableview? any/c void?)]
  [nstableview-hit-test (c-> nstableview? any/c (or/c nsview? objc-nil?))]
  [nstableview-identifier (c-> nstableview? (or/c nsstring? objc-nil?))]
  [nstableview-ignore-modifier-keys-for-dragging-session (c-> nstableview? (or/c string? objc-object? #f) boolean?)]
  [nstableview-indent (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-indicator-image-in-table-column (c-> nstableview? (or/c string? objc-object? #f) (or/c nsimage? objc-nil?))]
  [nstableview-insert-backtab! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-insert-container-break! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-insert-double-quote-ignoring-substitution! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-insert-line-break! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-insert-newline! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-insert-newline-ignoring-field-editor! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-insert-paragraph-separator! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-insert-rows-at-indexes-with-animation! (c-> nstableview? (or/c string? objc-object? #f) exact-nonnegative-integer? void?)]
  [nstableview-insert-single-quote-ignoring-substitution! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-insert-tab! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-insert-tab-ignoring-field-editor! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-insert-text! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-interpret-key-events (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-is-accessibility-alternate-ui-visible (c-> nstableview? boolean?)]
  [nstableview-is-accessibility-disclosed (c-> nstableview? boolean?)]
  [nstableview-is-accessibility-edited (c-> nstableview? boolean?)]
  [nstableview-is-accessibility-element (c-> nstableview? boolean?)]
  [nstableview-is-accessibility-enabled (c-> nstableview? boolean?)]
  [nstableview-is-accessibility-expanded (c-> nstableview? boolean?)]
  [nstableview-is-accessibility-focused (c-> nstableview? boolean?)]
  [nstableview-is-accessibility-frontmost (c-> nstableview? boolean?)]
  [nstableview-is-accessibility-hidden (c-> nstableview? boolean?)]
  [nstableview-is-accessibility-main (c-> nstableview? boolean?)]
  [nstableview-is-accessibility-minimized (c-> nstableview? boolean?)]
  [nstableview-is-accessibility-modal (c-> nstableview? boolean?)]
  [nstableview-is-accessibility-ordered-by-row (c-> nstableview? boolean?)]
  [nstableview-is-accessibility-protected-content (c-> nstableview? boolean?)]
  [nstableview-is-accessibility-required (c-> nstableview? boolean?)]
  [nstableview-is-accessibility-selected (c-> nstableview? boolean?)]
  [nstableview-is-accessibility-selector-allowed (c-> nstableview? string? boolean?)]
  [nstableview-is-column-selected (c-> nstableview? exact-integer? boolean?)]
  [nstableview-is-continuous (c-> nstableview? boolean?)]
  [nstableview-is-descendant-of (c-> nstableview? (or/c string? objc-object? #f) boolean?)]
  [nstableview-is-enabled (c-> nstableview? boolean?)]
  [nstableview-is-flipped (c-> nstableview? boolean?)]
  [nstableview-is-hidden (c-> nstableview? boolean?)]
  [nstableview-is-hidden-or-has-hidden-ancestor (c-> nstableview? boolean?)]
  [nstableview-is-highlighted (c-> nstableview? boolean?)]
  [nstableview-is-opaque (c-> nstableview? boolean?)]
  [nstableview-is-rotated-from-base (c-> nstableview? boolean?)]
  [nstableview-is-rotated-or-scaled-from-base (c-> nstableview? boolean?)]
  [nstableview-is-row-selected (c-> nstableview? exact-integer? boolean?)]
  [nstableview-key-down (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-key-up (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-layout (c-> nstableview? void?)]
  [nstableview-layout-subtree-if-needed (c-> nstableview? void?)]
  [nstableview-lowercase-word (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-magnify-with-event (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-make-backing-layer (c-> nstableview? (or/c calayer? objc-nil?))]
  [nstableview-make-base-writing-direction-left-to-right (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-make-base-writing-direction-natural (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-make-base-writing-direction-right-to-left (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-make-text-writing-direction-left-to-right (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-make-text-writing-direction-natural (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-make-text-writing-direction-right-to-left (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-make-view-with-identifier-owner (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nstableview-menu-for-event (c-> nstableview? (or/c string? objc-object? #f) (or/c nsmenu? objc-nil?))]
  [nstableview-mouse-in-rect (c-> nstableview? any/c any/c boolean?)]
  [nstableview-mouse-cancelled (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-mouse-down (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-mouse-dragged (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-mouse-entered (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-mouse-exited (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-mouse-moved (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-mouse-up (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-backward! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-backward-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-column-to-column! (c-> nstableview? exact-integer? exact-integer? void?)]
  [nstableview-move-down! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-down-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-forward! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-forward-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-left! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-left-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-paragraph-backward-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-paragraph-forward-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-right! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-right-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-row-at-index-to-index! (c-> nstableview? exact-integer? exact-integer? void?)]
  [nstableview-move-to-beginning-of-document! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-to-beginning-of-document-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-to-beginning-of-line! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-to-beginning-of-line-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-to-beginning-of-paragraph! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-to-beginning-of-paragraph-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-to-end-of-document! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-to-end-of-document-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-to-end-of-line! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-to-end-of-line-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-to-end-of-paragraph! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-to-end-of-paragraph-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-to-left-end-of-line! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-to-left-end-of-line-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-to-right-end-of-line! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-to-right-end-of-line-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-up! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-up-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-word-backward! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-word-backward-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-word-forward! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-word-forward-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-word-left! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-word-left-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-word-right! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-move-word-right-and-modify-selection! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-needs-to-draw-rect (c-> nstableview? any/c boolean?)]
  [nstableview-no-responder-for (c-> nstableview? string? void?)]
  [nstableview-note-height-of-rows-with-indexes-changed (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-note-number-of-rows-changed (c-> nstableview? void?)]
  [nstableview-other-mouse-down (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-other-mouse-dragged (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-other-mouse-up (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-page-down (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-page-down-and-modify-selection (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-page-up (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-page-up-and-modify-selection (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-perform-click! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-perform-drag-operation! (c-> nstableview? (or/c string? objc-object? #f) boolean?)]
  [nstableview-perform-key-equivalent! (c-> nstableview? (or/c string? objc-object? #f) boolean?)]
  [nstableview-prepare-content-in-rect (c-> nstableview? any/c void?)]
  [nstableview-prepare-for-drag-operation (c-> nstableview? (or/c string? objc-object? #f) boolean?)]
  [nstableview-prepare-for-reuse (c-> nstableview? void?)]
  [nstableview-pressure-change-with-event (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-quick-look-preview-items (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-quick-look-with-event (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-rect-for-smart-magnification-at-point-in-rect (c-> nstableview? any/c any/c any/c)]
  [nstableview-rect-of-column (c-> nstableview? exact-integer? any/c)]
  [nstableview-rect-of-row (c-> nstableview? exact-integer? any/c)]
  [nstableview-register-nib-for-identifier (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstableview-reload-data (c-> nstableview? void?)]
  [nstableview-reload-data-for-row-indexes-column-indexes (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstableview-remove-all-tool-tips! (c-> nstableview? void?)]
  [nstableview-remove-from-superview! (c-> nstableview? void?)]
  [nstableview-remove-from-superview-without-needing-display! (c-> nstableview? void?)]
  [nstableview-remove-rows-at-indexes-with-animation! (c-> nstableview? (or/c string? objc-object? #f) exact-nonnegative-integer? void?)]
  [nstableview-remove-table-column! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-remove-tool-tip! (c-> nstableview? exact-integer? void?)]
  [nstableview-replace-subview-with! (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstableview-resign-first-responder (c-> nstableview? boolean?)]
  [nstableview-resize-subviews-with-old-size (c-> nstableview? any/c void?)]
  [nstableview-resize-with-old-superview-size (c-> nstableview? any/c void?)]
  [nstableview-restore-user-activity-state (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-right-mouse-down (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-right-mouse-dragged (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-right-mouse-up (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-rotate-by-angle (c-> nstableview? real? void?)]
  [nstableview-rotate-with-event (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-row-at-point (c-> nstableview? any/c exact-integer?)]
  [nstableview-row-for-view (c-> nstableview? (or/c string? objc-object? #f) exact-integer?)]
  [nstableview-row-view-at-row-make-if-necessary (c-> nstableview? exact-integer? boolean? any/c)]
  [nstableview-rows-in-rect (c-> nstableview? any/c any/c)]
  [nstableview-scale-unit-square-to-size (c-> nstableview? any/c void?)]
  [nstableview-scroll-column-to-visible (c-> nstableview? exact-integer? void?)]
  [nstableview-scroll-line-down (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-scroll-line-up (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-scroll-page-down (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-scroll-page-up (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-scroll-point (c-> nstableview? any/c void?)]
  [nstableview-scroll-rect-to-visible (c-> nstableview? any/c boolean?)]
  [nstableview-scroll-row-to-visible (c-> nstableview? exact-integer? void?)]
  [nstableview-scroll-to-beginning-of-document (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-scroll-to-end-of-document (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-scroll-wheel (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-select-all (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-select-column-indexes-by-extending-selection (c-> nstableview? (or/c string? objc-object? #f) boolean? void?)]
  [nstableview-select-line (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-select-paragraph (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-select-row-indexes-by-extending-selection (c-> nstableview? (or/c string? objc-object? #f) boolean? void?)]
  [nstableview-select-to-mark (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-select-word (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-send-action-to (c-> nstableview? string? (or/c string? objc-object? #f) boolean?)]
  [nstableview-send-action-on (c-> nstableview? exact-nonnegative-integer? exact-integer?)]
  [nstableview-set-accessibility-activation-point! (c-> nstableview? any/c void?)]
  [nstableview-set-accessibility-allowed-values! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-alternate-ui-visible! (c-> nstableview? boolean? void?)]
  [nstableview-set-accessibility-application-focused-ui-element! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-attributed-user-input-labels! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-cancel-button! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-children! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-children-in-navigation-order! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-clear-button! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-close-button! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-column-count! (c-> nstableview? exact-integer? void?)]
  [nstableview-set-accessibility-column-header-ui-elements! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-column-index-range! (c-> nstableview? any/c void?)]
  [nstableview-set-accessibility-column-titles! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-columns! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-contents! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-critical-value! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-custom-actions! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-custom-rotors! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-decrement-button! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-default-button! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-disclosed! (c-> nstableview? boolean? void?)]
  [nstableview-set-accessibility-disclosed-by-row! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-disclosed-rows! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-disclosure-level! (c-> nstableview? exact-integer? void?)]
  [nstableview-set-accessibility-document! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-edited! (c-> nstableview? boolean? void?)]
  [nstableview-set-accessibility-element! (c-> nstableview? boolean? void?)]
  [nstableview-set-accessibility-enabled! (c-> nstableview? boolean? void?)]
  [nstableview-set-accessibility-expanded! (c-> nstableview? boolean? void?)]
  [nstableview-set-accessibility-extras-menu-bar! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-filename! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-focused! (c-> nstableview? boolean? void?)]
  [nstableview-set-accessibility-focused-window! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-frame! (c-> nstableview? any/c void?)]
  [nstableview-set-accessibility-frontmost! (c-> nstableview? boolean? void?)]
  [nstableview-set-accessibility-full-screen-button! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-grow-area! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-handles! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-header! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-help! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-hidden! (c-> nstableview? boolean? void?)]
  [nstableview-set-accessibility-horizontal-scroll-bar! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-horizontal-unit-description! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-horizontal-units! (c-> nstableview? exact-integer? void?)]
  [nstableview-set-accessibility-identifier! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-increment-button! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-index! (c-> nstableview? exact-integer? void?)]
  [nstableview-set-accessibility-insertion-point-line-number! (c-> nstableview? exact-integer? void?)]
  [nstableview-set-accessibility-label! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-label-ui-elements! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-label-value! (c-> nstableview? real? void?)]
  [nstableview-set-accessibility-linked-ui-elements! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-main! (c-> nstableview? boolean? void?)]
  [nstableview-set-accessibility-main-window! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-marker-group-ui-element! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-marker-type-description! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-marker-ui-elements! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-marker-values! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-max-value! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-menu-bar! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-min-value! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-minimize-button! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-minimized! (c-> nstableview? boolean? void?)]
  [nstableview-set-accessibility-modal! (c-> nstableview? boolean? void?)]
  [nstableview-set-accessibility-next-contents! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-number-of-characters! (c-> nstableview? exact-integer? void?)]
  [nstableview-set-accessibility-ordered-by-row! (c-> nstableview? boolean? void?)]
  [nstableview-set-accessibility-orientation! (c-> nstableview? exact-integer? void?)]
  [nstableview-set-accessibility-overflow-button! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-parent! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-placeholder-value! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-previous-contents! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-protected-content! (c-> nstableview? boolean? void?)]
  [nstableview-set-accessibility-proxy! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-required! (c-> nstableview? boolean? void?)]
  [nstableview-set-accessibility-role! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-role-description! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-row-count! (c-> nstableview? exact-integer? void?)]
  [nstableview-set-accessibility-row-header-ui-elements! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-row-index-range! (c-> nstableview? any/c void?)]
  [nstableview-set-accessibility-rows! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-ruler-marker-type! (c-> nstableview? exact-integer? void?)]
  [nstableview-set-accessibility-search-button! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-search-menu! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-selected! (c-> nstableview? boolean? void?)]
  [nstableview-set-accessibility-selected-cells! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-selected-children! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-selected-columns! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-selected-rows! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-selected-text! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-selected-text-range! (c-> nstableview? any/c void?)]
  [nstableview-set-accessibility-selected-text-ranges! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-serves-as-title-for-ui-elements! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-shared-character-range! (c-> nstableview? any/c void?)]
  [nstableview-set-accessibility-shared-focus-elements! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-shared-text-ui-elements! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-shown-menu! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-sort-direction! (c-> nstableview? exact-integer? void?)]
  [nstableview-set-accessibility-splitters! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-subrole! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-tabs! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-title! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-title-ui-element! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-toolbar-button! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-top-level-ui-element! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-url! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-unit-description! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-units! (c-> nstableview? exact-integer? void?)]
  [nstableview-set-accessibility-user-input-labels! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-value! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-value-description! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-vertical-scroll-bar! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-vertical-unit-description! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-vertical-units! (c-> nstableview? exact-integer? void?)]
  [nstableview-set-accessibility-visible-cells! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-visible-character-range! (c-> nstableview? any/c void?)]
  [nstableview-set-accessibility-visible-children! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-visible-columns! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-visible-rows! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-warning-value! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-window! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-windows! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-accessibility-zoom-button! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-animations! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-appearance! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-bounds-origin! (c-> nstableview? any/c void?)]
  [nstableview-set-bounds-size! (c-> nstableview? any/c void?)]
  [nstableview-set-dragging-source-operation-mask-for-local! (c-> nstableview? exact-nonnegative-integer? boolean? void?)]
  [nstableview-set-drop-row-drop-operation! (c-> nstableview? exact-integer? exact-nonnegative-integer? void?)]
  [nstableview-set-frame-origin! (c-> nstableview? any/c void?)]
  [nstableview-set-frame-size! (c-> nstableview? any/c void?)]
  [nstableview-set-identifier! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-indicator-image-in-table-column! (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstableview-set-mark! (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-set-needs-display-in-rect! (c-> nstableview? any/c void?)]
  [nstableview-should-be-treated-as-ink-event (c-> nstableview? (or/c string? objc-object? #f) boolean?)]
  [nstableview-should-delay-window-ordering-for-event (c-> nstableview? (or/c string? objc-object? #f) boolean?)]
  [nstableview-show-context-help (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-show-context-menu-for-selection (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-size-last-column-to-fit (c-> nstableview? void?)]
  [nstableview-size-that-fits (c-> nstableview? any/c any/c)]
  [nstableview-size-to-fit (c-> nstableview? void?)]
  [nstableview-smart-magnify-with-event (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-sort-subviews-using-function-context (c-> nstableview? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nstableview-supplemental-target-for-action-sender (c-> nstableview? string? (or/c string? objc-object? #f) any/c)]
  [nstableview-swap-with-mark (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-swipe-with-event (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-table-column-with-identifier (c-> nstableview? (or/c string? objc-object? #f) (or/c nstablecolumn? objc-nil?))]
  [nstableview-tablet-point (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-tablet-proximity (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-take-double-value-from (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-take-float-value-from (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-take-int-value-from (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-take-integer-value-from (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-take-object-value-from (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-take-string-value-from (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-text-did-begin-editing (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-text-did-change (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-text-did-end-editing (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-text-should-begin-editing (c-> nstableview? (or/c string? objc-object? #f) boolean?)]
  [nstableview-text-should-end-editing (c-> nstableview? (or/c string? objc-object? #f) boolean?)]
  [nstableview-text-view-url-for-contents-of-text-attachment-at-index (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c nsurl? objc-nil?))]
  [nstableview-text-view-candidates-for-selected-range (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c any/c)]
  [nstableview-text-view-candidates-for-selected-range (c-> nstableview? (or/c string? objc-object? #f) any/c (or/c nsarray? objc-nil?))]
  [nstableview-text-view-clicked-on-cell-in-rect-at-index (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c exact-nonnegative-integer? void?)]
  [nstableview-text-view-clicked-on-link-at-index (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer? boolean?)]
  [nstableview-text-view-completions-for-partial-word-range-index-of-selected-item (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c (or/c cpointer? #f) any/c)]
  [nstableview-text-view-did-check-text-in-range-types-options-results-orthography-word-count (c-> nstableview? (or/c string? objc-object? #f) any/c exact-nonnegative-integer? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-integer? any/c)]
  [nstableview-text-view-do-command-by-selector (c-> nstableview? (or/c string? objc-object? #f) string? boolean?)]
  [nstableview-text-view-double-clicked-on-cell-in-rect-at-index (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c exact-nonnegative-integer? void?)]
  [nstableview-text-view-dragged-cell-in-rect-event-at-index (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c (or/c string? objc-object? #f) exact-nonnegative-integer? void?)]
  [nstableview-text-view-menu-for-event-at-index (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c nsmenu? objc-nil?))]
  [nstableview-text-view-should-change-text-in-range-replacement-string (c-> nstableview? (or/c string? objc-object? #f) any/c (or/c string? objc-object? #f) boolean?)]
  [nstableview-text-view-should-change-text-in-ranges-replacement-strings (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nstableview-text-view-should-change-typing-attributes-to-attributes (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nstableview-text-view-should-select-candidate-at-index (c-> nstableview? (or/c string? objc-object? #f) exact-nonnegative-integer? boolean?)]
  [nstableview-text-view-should-set-spelling-state-range (c-> nstableview? (or/c string? objc-object? #f) exact-integer? any/c exact-integer?)]
  [nstableview-text-view-should-update-touch-bar-item-identifiers (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nstableview-text-view-will-change-selection-from-character-range-to-character-range (c-> nstableview? (or/c string? objc-object? #f) any/c any/c any/c)]
  [nstableview-text-view-will-change-selection-from-character-ranges-to-character-ranges (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nstableview-text-view-will-check-text-in-range-options-types (c-> nstableview? (or/c string? objc-object? #f) any/c (or/c string? objc-object? #f) (or/c cpointer? #f) any/c)]
  [nstableview-text-view-will-display-tool-tip-for-character-at-index (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c nsstring? objc-nil?))]
  [nstableview-text-view-will-show-sharing-service-picker-for-items (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c nssharingservicepicker? objc-nil?))]
  [nstableview-text-view-writable-pasteboard-types-for-cell-at-index (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer? any/c)]
  [nstableview-text-view-write-cell-at-index-to-pasteboard-type (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nstableview-text-view-writing-tools-ignored-ranges-in-enclosing-range (c-> nstableview? (or/c string? objc-object? #f) any/c any/c)]
  [nstableview-text-view-did-change-selection (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-text-view-did-change-typing-attributes (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-text-view-writing-tools-did-end (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-text-view-writing-tools-will-begin (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-tile (c-> nstableview? void?)]
  [nstableview-touches-began-with-event (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-touches-cancelled-with-event (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-touches-ended-with-event (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-touches-moved-with-event (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-translate-origin-to-point (c-> nstableview? any/c void?)]
  [nstableview-translate-rects-needing-display-in-rect-by (c-> nstableview? any/c any/c void?)]
  [nstableview-transpose (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-transpose-words (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-try-to-perform-with (c-> nstableview? string? (or/c string? objc-object? #f) boolean?)]
  [nstableview-undo-manager-for-text-view (c-> nstableview? (or/c string? objc-object? #f) (or/c nsundomanager? objc-nil?))]
  [nstableview-unhide-rows-at-indexes-with-animation (c-> nstableview? (or/c string? objc-object? #f) exact-nonnegative-integer? void?)]
  [nstableview-update-dragging-items-for-drag (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-update-layer (c-> nstableview? void?)]
  [nstableview-uppercase-word (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-valid-requestor-for-send-type-return-type (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nstableview-validate-user-interface-item (c-> nstableview? (or/c string? objc-object? #f) boolean?)]
  [nstableview-view-at-column-row-make-if-necessary (c-> nstableview? exact-integer? exact-integer? boolean? any/c)]
  [nstableview-view-did-change-backing-properties (c-> nstableview? void?)]
  [nstableview-view-did-change-effective-appearance (c-> nstableview? void?)]
  [nstableview-view-did-end-live-resize (c-> nstableview? void?)]
  [nstableview-view-did-hide (c-> nstableview? void?)]
  [nstableview-view-did-move-to-superview (c-> nstableview? void?)]
  [nstableview-view-did-move-to-window (c-> nstableview? void?)]
  [nstableview-view-did-unhide (c-> nstableview? void?)]
  [nstableview-view-will-draw (c-> nstableview? void?)]
  [nstableview-view-will-move-to-superview (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-view-will-move-to-window (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-view-will-start-live-resize (c-> nstableview? void?)]
  [nstableview-view-with-tag (c-> nstableview? exact-integer? any/c)]
  [nstableview-wants-forwarded-scroll-events-for-axis (c-> nstableview? exact-integer? boolean?)]
  [nstableview-wants-periodic-dragging-updates (c-> nstableview? boolean?)]
  [nstableview-wants-scroll-events-for-swipe-tracking-on-axis (c-> nstableview? exact-integer? boolean?)]
  [nstableview-will-open-menu-with-event (c-> nstableview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstableview-will-remove-subview (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-yank (c-> nstableview? (or/c string? objc-object? #f) void?)]
  [nstableview-default-animation-for-key (c-> (or/c string? objc-object? #f) any/c)]
  [nstableview-is-compatible-with-responsive-scrolling (c-> boolean?)]
  )

;; --- Class reference ---
(import-class NSTableView)

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer -> _NSPoint)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _NSPoint)))
(define _msg-1  ; (_fun _pointer _pointer -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _NSRange)))
(define _msg-2  ; (_fun _pointer _pointer -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _NSRect)))
(define _msg-3  ; (_fun _pointer _pointer -> _NSSize)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _NSSize)))
(define _msg-4  ; (_fun _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _bool)))
(define _msg-5  ; (_fun _pointer _pointer -> _double)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _double)))
(define _msg-6  ; (_fun _pointer _pointer -> _float)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _float)))
(define _msg-7  ; (_fun _pointer _pointer -> _int32)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _int32)))
(define _msg-8  ; (_fun _pointer _pointer -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _int64)))
(define _msg-9  ; (_fun _pointer _pointer -> _pointer)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _pointer)))
(define _msg-10  ; (_fun _pointer _pointer -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _uint64)))
(define _msg-11  ; (_fun _pointer _pointer _NSEdgeInsets -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSEdgeInsets -> _void)))
(define _msg-12  ; (_fun _pointer _pointer _NSPoint -> _NSPoint)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _NSPoint)))
(define _msg-13  ; (_fun _pointer _pointer _NSPoint -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _NSRange)))
(define _msg-14  ; (_fun _pointer _pointer _NSPoint -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _id)))
(define _msg-15  ; (_fun _pointer _pointer _NSPoint -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _int64)))
(define _msg-16  ; (_fun _pointer _pointer _NSPoint -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _void)))
(define _msg-17  ; (_fun _pointer _pointer _NSPoint _NSRect -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint _NSRect -> _NSRect)))
(define _msg-18  ; (_fun _pointer _pointer _NSPoint _NSRect -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint _NSRect -> _bool)))
(define _msg-19  ; (_fun _pointer _pointer _NSPoint _id -> _NSPoint)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint _id -> _NSPoint)))
(define _msg-20  ; (_fun _pointer _pointer _NSRange -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _NSRect)))
(define _msg-21  ; (_fun _pointer _pointer _NSRange -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _id)))
(define _msg-22  ; (_fun _pointer _pointer _NSRange -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _void)))
(define _msg-23  ; (_fun _pointer _pointer _NSRect -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _NSRange)))
(define _msg-24  ; (_fun _pointer _pointer _NSRect -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _NSRect)))
(define _msg-25  ; (_fun _pointer _pointer _NSRect -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _bool)))
(define _msg-26  ; (_fun _pointer _pointer _NSRect -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _id)))
(define _msg-27  ; (_fun _pointer _pointer _NSRect -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _void)))
(define _msg-28  ; (_fun _pointer _pointer _NSRect _NSSize -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _NSSize -> _void)))
(define _msg-29  ; (_fun _pointer _pointer _NSRect _id -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id -> _NSRect)))
(define _msg-30  ; (_fun _pointer _pointer _NSRect _id -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id -> _void)))
(define _msg-31  ; (_fun _pointer _pointer _NSRect _id _pointer -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id _pointer -> _int64)))
(define _msg-32  ; (_fun _pointer _pointer _NSRect _uint64 -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _uint64 -> _NSRect)))
(define _msg-33  ; (_fun _pointer _pointer _NSSize -> _NSSize)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize -> _NSSize)))
(define _msg-34  ; (_fun _pointer _pointer _NSSize -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize -> _void)))
(define _msg-35  ; (_fun _pointer _pointer _NSSize _id -> _NSSize)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize _id -> _NSSize)))
(define _msg-36  ; (_fun _pointer _pointer _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _bool -> _void)))
(define _msg-37  ; (_fun _pointer _pointer _double -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double -> _void)))
(define _msg-38  ; (_fun _pointer _pointer _float -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _float -> _void)))
(define _msg-39  ; (_fun _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _bool)))
(define _msg-40  ; (_fun _pointer _pointer _id -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _int64)))
(define _msg-41  ; (_fun _pointer _pointer _id -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _uint64)))
(define _msg-42  ; (_fun _pointer _pointer _id _NSPoint -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _NSPoint -> _bool)))
(define _msg-43  ; (_fun _pointer _pointer _id _NSPoint -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _NSPoint -> _void)))
(define _msg-44  ; (_fun _pointer _pointer _id _NSPoint _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _NSPoint _uint64 -> _void)))
(define _msg-45  ; (_fun _pointer _pointer _id _NSRange -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _NSRange -> _id)))
(define _msg-46  ; (_fun _pointer _pointer _id _NSRange _NSRange -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _NSRange _NSRange -> _NSRange)))
(define _msg-47  ; (_fun _pointer _pointer _id _NSRange _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _NSRange _id -> _bool)))
(define _msg-48  ; (_fun _pointer _pointer _id _NSRange _id _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _NSRange _id _pointer -> _id)))
(define _msg-49  ; (_fun _pointer _pointer _id _NSRange _uint64 _id _id _id _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _NSRange _uint64 _id _id _id _int64 -> _id)))
(define _msg-50  ; (_fun _pointer _pointer _id _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _bool -> _void)))
(define _msg-51  ; (_fun _pointer _pointer _id _id _NSRange -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _NSRange -> _id)))
(define _msg-52  ; (_fun _pointer _pointer _id _id _NSRange _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _NSRange _pointer -> _id)))
(define _msg-53  ; (_fun _pointer _pointer _id _id _NSRect _id _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _NSRect _id _uint64 -> _void)))
(define _msg-54  ; (_fun _pointer _pointer _id _id _NSRect _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _NSRect _uint64 -> _void)))
(define _msg-55  ; (_fun _pointer _pointer _id _id _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _id -> _bool)))
(define _msg-56  ; (_fun _pointer _pointer _id _id _id _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _id _pointer -> _id)))
(define _msg-57  ; (_fun _pointer _pointer _id _id _id _uint64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _id _uint64 -> _id)))
(define _msg-58  ; (_fun _pointer _pointer _id _id _uint64 -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _uint64 -> _bool)))
(define _msg-59  ; (_fun _pointer _pointer _id _id _uint64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _uint64 -> _id)))
(define _msg-60  ; (_fun _pointer _pointer _id _id _uint64 _id _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _uint64 _id _id -> _bool)))
(define _msg-61  ; (_fun _pointer _pointer _id _int64 -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _int64 -> _uint64)))
(define _msg-62  ; (_fun _pointer _pointer _id _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _int64 -> _void)))
(define _msg-63  ; (_fun _pointer _pointer _id _int64 _NSRange -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _int64 _NSRange -> _int64)))
(define _msg-64  ; (_fun _pointer _pointer _id _int64 _id -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _int64 _id -> _void)))
(define _msg-65  ; (_fun _pointer _pointer _id _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer -> _bool)))
(define _msg-66  ; (_fun _pointer _pointer _id _uint64 -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _uint64 -> _bool)))
(define _msg-67  ; (_fun _pointer _pointer _id _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _uint64 -> _void)))
(define _msg-68  ; (_fun _pointer _pointer _int32 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int32 -> _void)))
(define _msg-69  ; (_fun _pointer _pointer _int64 -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _NSRange)))
(define _msg-70  ; (_fun _pointer _pointer _int64 -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _NSRect)))
(define _msg-71  ; (_fun _pointer _pointer _int64 -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _bool)))
(define _msg-72  ; (_fun _pointer _pointer _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _id)))
(define _msg-73  ; (_fun _pointer _pointer _int64 -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _int64)))
(define _msg-74  ; (_fun _pointer _pointer _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _void)))
(define _msg-75  ; (_fun _pointer _pointer _int64 _NSRect -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _NSRect -> _void)))
(define _msg-76  ; (_fun _pointer _pointer _int64 _bool -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _bool -> _id)))
(define _msg-77  ; (_fun _pointer _pointer _int64 _int64 -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _int64 -> _NSRect)))
(define _msg-78  ; (_fun _pointer _pointer _int64 _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _int64 -> _id)))
(define _msg-79  ; (_fun _pointer _pointer _int64 _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _int64 -> _void)))
(define _msg-80  ; (_fun _pointer _pointer _int64 _int64 _bool -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _int64 _bool -> _id)))
(define _msg-81  ; (_fun _pointer _pointer _int64 _int64 _id _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _int64 _id _bool -> _void)))
(define _msg-82  ; (_fun _pointer _pointer _int64 _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _uint64 -> _void)))
(define _msg-83  ; (_fun _pointer _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _bool)))
(define _msg-84  ; (_fun _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _void)))
(define _msg-85  ; (_fun _pointer _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _bool)))
(define _msg-86  ; (_fun _pointer _pointer _pointer _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _id)))
(define _msg-87  ; (_fun _pointer _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _pointer -> _void)))
(define _msg-88  ; (_fun _pointer _pointer _uint64 -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _int64)))
(define _msg-89  ; (_fun _pointer _pointer _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _void)))
(define _msg-90  ; (_fun _pointer _pointer _uint64 _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 _bool -> _void)))

;; --- Constructors ---
(define (make-nstableview-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSTableView alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nstableview-init-with-frame frame-rect)
  (wrap-objc-object
   (_msg-26 (tell NSTableView alloc)
       (sel_registerName "initWithFrame:")
       frame-rect)
   #:retained #t))


;; --- Properties ---
(define (nstableview-accepts-first-responder self)
  (tell #:type _bool (coerce-arg self) acceptsFirstResponder))
(define (nstableview-accepts-touch-events self)
  (tell #:type _bool (coerce-arg self) acceptsTouchEvents))
(define (nstableview-set-accepts-touch-events! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setAcceptsTouchEvents:") value))
(define (nstableview-action self)
  (tell #:type _pointer (coerce-arg self) action))
(define (nstableview-set-action! self value)
  (_msg-84 (coerce-arg self) (sel_registerName "setAction:") (sel_registerName value)))
(define (nstableview-additional-safe-area-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) additionalSafeAreaInsets))
(define (nstableview-set-additional-safe-area-insets! self value)
  (_msg-11 (coerce-arg self) (sel_registerName "setAdditionalSafeAreaInsets:") value))
(define (nstableview-alignment self)
  (tell #:type _int64 (coerce-arg self) alignment))
(define (nstableview-set-alignment! self value)
  (_msg-74 (coerce-arg self) (sel_registerName "setAlignment:") value))
(define (nstableview-alignment-rect-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) alignmentRectInsets))
(define (nstableview-allowed-touch-types self)
  (tell #:type _uint64 (coerce-arg self) allowedTouchTypes))
(define (nstableview-set-allowed-touch-types! self value)
  (_msg-89 (coerce-arg self) (sel_registerName "setAllowedTouchTypes:") value))
(define (nstableview-allows-column-reordering self)
  (tell #:type _bool (coerce-arg self) allowsColumnReordering))
(define (nstableview-set-allows-column-reordering! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setAllowsColumnReordering:") value))
(define (nstableview-allows-column-resizing self)
  (tell #:type _bool (coerce-arg self) allowsColumnResizing))
(define (nstableview-set-allows-column-resizing! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setAllowsColumnResizing:") value))
(define (nstableview-allows-column-selection self)
  (tell #:type _bool (coerce-arg self) allowsColumnSelection))
(define (nstableview-set-allows-column-selection! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setAllowsColumnSelection:") value))
(define (nstableview-allows-empty-selection self)
  (tell #:type _bool (coerce-arg self) allowsEmptySelection))
(define (nstableview-set-allows-empty-selection! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setAllowsEmptySelection:") value))
(define (nstableview-allows-expansion-tool-tips self)
  (tell #:type _bool (coerce-arg self) allowsExpansionToolTips))
(define (nstableview-set-allows-expansion-tool-tips! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setAllowsExpansionToolTips:") value))
(define (nstableview-allows-multiple-selection self)
  (tell #:type _bool (coerce-arg self) allowsMultipleSelection))
(define (nstableview-set-allows-multiple-selection! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setAllowsMultipleSelection:") value))
(define (nstableview-allows-type-select self)
  (tell #:type _bool (coerce-arg self) allowsTypeSelect))
(define (nstableview-set-allows-type-select! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setAllowsTypeSelect:") value))
(define (nstableview-allows-vibrancy self)
  (tell #:type _bool (coerce-arg self) allowsVibrancy))
(define (nstableview-alpha-value self)
  (tell #:type _double (coerce-arg self) alphaValue))
(define (nstableview-set-alpha-value! self value)
  (_msg-37 (coerce-arg self) (sel_registerName "setAlphaValue:") value))
(define (nstableview-attributed-string-value self)
  (wrap-objc-object
   (tell (coerce-arg self) attributedStringValue)))
(define (nstableview-set-attributed-string-value! self value)
  (tell #:type _void (coerce-arg self) setAttributedStringValue: (coerce-arg value)))
(define (nstableview-autoresizes-subviews self)
  (tell #:type _bool (coerce-arg self) autoresizesSubviews))
(define (nstableview-set-autoresizes-subviews! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setAutoresizesSubviews:") value))
(define (nstableview-autoresizing-mask self)
  (tell #:type _uint64 (coerce-arg self) autoresizingMask))
(define (nstableview-set-autoresizing-mask! self value)
  (_msg-89 (coerce-arg self) (sel_registerName "setAutoresizingMask:") value))
(define (nstableview-autosave-name self)
  (wrap-objc-object
   (tell (coerce-arg self) autosaveName)))
(define (nstableview-set-autosave-name! self value)
  (tell #:type _void (coerce-arg self) setAutosaveName: (coerce-arg value)))
(define (nstableview-autosave-table-columns self)
  (tell #:type _bool (coerce-arg self) autosaveTableColumns))
(define (nstableview-set-autosave-table-columns! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setAutosaveTableColumns:") value))
(define (nstableview-background-color self)
  (wrap-objc-object
   (tell (coerce-arg self) backgroundColor)))
(define (nstableview-set-background-color! self value)
  (tell #:type _void (coerce-arg self) setBackgroundColor: (coerce-arg value)))
(define (nstableview-background-filters self)
  (wrap-objc-object
   (tell (coerce-arg self) backgroundFilters)))
(define (nstableview-set-background-filters! self value)
  (tell #:type _void (coerce-arg self) setBackgroundFilters: (coerce-arg value)))
(define (nstableview-base-writing-direction self)
  (tell #:type _int64 (coerce-arg self) baseWritingDirection))
(define (nstableview-set-base-writing-direction! self value)
  (_msg-74 (coerce-arg self) (sel_registerName "setBaseWritingDirection:") value))
(define (nstableview-baseline-offset-from-bottom self)
  (tell #:type _double (coerce-arg self) baselineOffsetFromBottom))
(define (nstableview-bottom-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) bottomAnchor)))
(define (nstableview-bounds self)
  (tell #:type _NSRect (coerce-arg self) bounds))
(define (nstableview-set-bounds! self value)
  (_msg-27 (coerce-arg self) (sel_registerName "setBounds:") value))
(define (nstableview-bounds-rotation self)
  (tell #:type _double (coerce-arg self) boundsRotation))
(define (nstableview-set-bounds-rotation! self value)
  (_msg-37 (coerce-arg self) (sel_registerName "setBoundsRotation:") value))
(define (nstableview-can-become-key-view self)
  (tell #:type _bool (coerce-arg self) canBecomeKeyView))
(define (nstableview-can-draw self)
  (tell #:type _bool (coerce-arg self) canDraw))
(define (nstableview-can-draw-concurrently self)
  (tell #:type _bool (coerce-arg self) canDrawConcurrently))
(define (nstableview-set-can-draw-concurrently! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setCanDrawConcurrently:") value))
(define (nstableview-can-draw-subviews-into-layer self)
  (tell #:type _bool (coerce-arg self) canDrawSubviewsIntoLayer))
(define (nstableview-set-can-draw-subviews-into-layer! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setCanDrawSubviewsIntoLayer:") value))
(define (nstableview-candidate-list-touch-bar-item self)
  (wrap-objc-object
   (tell (coerce-arg self) candidateListTouchBarItem)))
(define (nstableview-cell self)
  (wrap-objc-object
   (tell (coerce-arg self) cell)))
(define (nstableview-set-cell! self value)
  (tell #:type _void (coerce-arg self) setCell: (coerce-arg value)))
(define (nstableview-cell-class)
  (tell #:type _pointer NSTableView cellClass))
(define (nstableview-set-cell-class! value)
  (_msg-84 NSTableView (sel_registerName "setCellClass:") value))
(define (nstableview-center-x-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) centerXAnchor)))
(define (nstableview-center-y-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) centerYAnchor)))
(define (nstableview-clicked-column self)
  (tell #:type _int64 (coerce-arg self) clickedColumn))
(define (nstableview-clicked-row self)
  (tell #:type _int64 (coerce-arg self) clickedRow))
(define (nstableview-clips-to-bounds self)
  (tell #:type _bool (coerce-arg self) clipsToBounds))
(define (nstableview-set-clips-to-bounds! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setClipsToBounds:") value))
(define (nstableview-column-autoresizing-style self)
  (tell #:type _uint64 (coerce-arg self) columnAutoresizingStyle))
(define (nstableview-set-column-autoresizing-style! self value)
  (_msg-89 (coerce-arg self) (sel_registerName "setColumnAutoresizingStyle:") value))
(define (nstableview-compatible-with-responsive-scrolling)
  (tell #:type _bool NSTableView compatibleWithResponsiveScrolling))
(define (nstableview-compositing-filter self)
  (wrap-objc-object
   (tell (coerce-arg self) compositingFilter)))
(define (nstableview-set-compositing-filter! self value)
  (tell #:type _void (coerce-arg self) setCompositingFilter: (coerce-arg value)))
(define (nstableview-constraints self)
  (wrap-objc-object
   (tell (coerce-arg self) constraints)))
(define (nstableview-content-filters self)
  (wrap-objc-object
   (tell (coerce-arg self) contentFilters)))
(define (nstableview-set-content-filters! self value)
  (tell #:type _void (coerce-arg self) setContentFilters: (coerce-arg value)))
(define (nstableview-continuous self)
  (tell #:type _bool (coerce-arg self) continuous))
(define (nstableview-set-continuous! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setContinuous:") value))
(define (nstableview-control-size self)
  (tell #:type _uint64 (coerce-arg self) controlSize))
(define (nstableview-set-control-size! self value)
  (_msg-89 (coerce-arg self) (sel_registerName "setControlSize:") value))
(define (nstableview-corner-view self)
  (wrap-objc-object
   (tell (coerce-arg self) cornerView)))
(define (nstableview-set-corner-view! self value)
  (tell #:type _void (coerce-arg self) setCornerView: (coerce-arg value)))
(define (nstableview-data-source self)
  (wrap-objc-object
   (tell (coerce-arg self) dataSource)))
(define (nstableview-set-data-source! self value)
  (tell #:type _void (coerce-arg self) setDataSource: (coerce-arg value)))
(define (nstableview-default-focus-ring-type)
  (tell #:type _uint64 NSTableView defaultFocusRingType))
(define (nstableview-default-menu)
  (wrap-objc-object
   (tell NSTableView defaultMenu)))
(define (nstableview-delegate self)
  (wrap-objc-object
   (tell (coerce-arg self) delegate)))
(define (nstableview-set-delegate! self value)
  (tell #:type _void (coerce-arg self) setDelegate: (coerce-arg value)))
(define (nstableview-double-action self)
  (tell #:type _pointer (coerce-arg self) doubleAction))
(define (nstableview-set-double-action! self value)
  (_msg-84 (coerce-arg self) (sel_registerName "setDoubleAction:") (sel_registerName value)))
(define (nstableview-double-value self)
  (tell #:type _double (coerce-arg self) doubleValue))
(define (nstableview-set-double-value! self value)
  (_msg-37 (coerce-arg self) (sel_registerName "setDoubleValue:") value))
(define (nstableview-dragging-destination-feedback-style self)
  (tell #:type _int64 (coerce-arg self) draggingDestinationFeedbackStyle))
(define (nstableview-set-dragging-destination-feedback-style! self value)
  (_msg-74 (coerce-arg self) (sel_registerName "setDraggingDestinationFeedbackStyle:") value))
(define (nstableview-drawing-find-indicator self)
  (tell #:type _bool (coerce-arg self) drawingFindIndicator))
(define (nstableview-edited-column self)
  (tell #:type _int64 (coerce-arg self) editedColumn))
(define (nstableview-edited-row self)
  (tell #:type _int64 (coerce-arg self) editedRow))
(define (nstableview-effective-row-size-style self)
  (tell #:type _int64 (coerce-arg self) effectiveRowSizeStyle))
(define (nstableview-effective-style self)
  (tell #:type _int64 (coerce-arg self) effectiveStyle))
(define (nstableview-enabled self)
  (tell #:type _bool (coerce-arg self) enabled))
(define (nstableview-set-enabled! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setEnabled:") value))
(define (nstableview-enclosing-menu-item self)
  (wrap-objc-object
   (tell (coerce-arg self) enclosingMenuItem)))
(define (nstableview-enclosing-scroll-view self)
  (wrap-objc-object
   (tell (coerce-arg self) enclosingScrollView)))
(define (nstableview-first-baseline-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) firstBaselineAnchor)))
(define (nstableview-first-baseline-offset-from-top self)
  (tell #:type _double (coerce-arg self) firstBaselineOffsetFromTop))
(define (nstableview-fitting-size self)
  (tell #:type _NSSize (coerce-arg self) fittingSize))
(define (nstableview-flipped self)
  (tell #:type _bool (coerce-arg self) flipped))
(define (nstableview-float-value self)
  (tell #:type _float (coerce-arg self) floatValue))
(define (nstableview-set-float-value! self value)
  (_msg-38 (coerce-arg self) (sel_registerName "setFloatValue:") value))
(define (nstableview-floats-group-rows self)
  (tell #:type _bool (coerce-arg self) floatsGroupRows))
(define (nstableview-set-floats-group-rows! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setFloatsGroupRows:") value))
(define (nstableview-focus-ring-mask-bounds self)
  (tell #:type _NSRect (coerce-arg self) focusRingMaskBounds))
(define (nstableview-focus-ring-type self)
  (tell #:type _uint64 (coerce-arg self) focusRingType))
(define (nstableview-set-focus-ring-type! self value)
  (_msg-89 (coerce-arg self) (sel_registerName "setFocusRingType:") value))
(define (nstableview-focus-view)
  (wrap-objc-object
   (tell NSTableView focusView)))
(define (nstableview-font self)
  (wrap-objc-object
   (tell (coerce-arg self) font)))
(define (nstableview-set-font! self value)
  (tell #:type _void (coerce-arg self) setFont: (coerce-arg value)))
(define (nstableview-formatter self)
  (wrap-objc-object
   (tell (coerce-arg self) formatter)))
(define (nstableview-set-formatter! self value)
  (tell #:type _void (coerce-arg self) setFormatter: (coerce-arg value)))
(define (nstableview-frame self)
  (tell #:type _NSRect (coerce-arg self) frame))
(define (nstableview-set-frame! self value)
  (_msg-27 (coerce-arg self) (sel_registerName "setFrame:") value))
(define (nstableview-frame-center-rotation self)
  (tell #:type _double (coerce-arg self) frameCenterRotation))
(define (nstableview-set-frame-center-rotation! self value)
  (_msg-37 (coerce-arg self) (sel_registerName "setFrameCenterRotation:") value))
(define (nstableview-frame-rotation self)
  (tell #:type _double (coerce-arg self) frameRotation))
(define (nstableview-set-frame-rotation! self value)
  (_msg-37 (coerce-arg self) (sel_registerName "setFrameRotation:") value))
(define (nstableview-gesture-recognizers self)
  (wrap-objc-object
   (tell (coerce-arg self) gestureRecognizers)))
(define (nstableview-set-gesture-recognizers! self value)
  (tell #:type _void (coerce-arg self) setGestureRecognizers: (coerce-arg value)))
(define (nstableview-grid-color self)
  (wrap-objc-object
   (tell (coerce-arg self) gridColor)))
(define (nstableview-set-grid-color! self value)
  (tell #:type _void (coerce-arg self) setGridColor: (coerce-arg value)))
(define (nstableview-grid-style-mask self)
  (tell #:type _uint64 (coerce-arg self) gridStyleMask))
(define (nstableview-set-grid-style-mask! self value)
  (_msg-89 (coerce-arg self) (sel_registerName "setGridStyleMask:") value))
(define (nstableview-has-ambiguous-layout self)
  (tell #:type _bool (coerce-arg self) hasAmbiguousLayout))
(define (nstableview-header-view self)
  (wrap-objc-object
   (tell (coerce-arg self) headerView)))
(define (nstableview-set-header-view! self value)
  (tell #:type _void (coerce-arg self) setHeaderView: (coerce-arg value)))
(define (nstableview-height-adjust-limit self)
  (tell #:type _double (coerce-arg self) heightAdjustLimit))
(define (nstableview-height-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) heightAnchor)))
(define (nstableview-hidden self)
  (tell #:type _bool (coerce-arg self) hidden))
(define (nstableview-set-hidden! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setHidden:") value))
(define (nstableview-hidden-or-has-hidden-ancestor self)
  (tell #:type _bool (coerce-arg self) hiddenOrHasHiddenAncestor))
(define (nstableview-hidden-row-indexes self)
  (wrap-objc-object
   (tell (coerce-arg self) hiddenRowIndexes)))
(define (nstableview-highlighted self)
  (tell #:type _bool (coerce-arg self) highlighted))
(define (nstableview-set-highlighted! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setHighlighted:") value))
(define (nstableview-highlighted-table-column self)
  (wrap-objc-object
   (tell (coerce-arg self) highlightedTableColumn)))
(define (nstableview-set-highlighted-table-column! self value)
  (tell #:type _void (coerce-arg self) setHighlightedTableColumn: (coerce-arg value)))
(define (nstableview-horizontal-content-size-constraint-active self)
  (tell #:type _bool (coerce-arg self) horizontalContentSizeConstraintActive))
(define (nstableview-set-horizontal-content-size-constraint-active! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setHorizontalContentSizeConstraintActive:") value))
(define (nstableview-ignores-multi-click self)
  (tell #:type _bool (coerce-arg self) ignoresMultiClick))
(define (nstableview-set-ignores-multi-click! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setIgnoresMultiClick:") value))
(define (nstableview-in-full-screen-mode self)
  (tell #:type _bool (coerce-arg self) inFullScreenMode))
(define (nstableview-in-live-resize self)
  (tell #:type _bool (coerce-arg self) inLiveResize))
(define (nstableview-input-context self)
  (wrap-objc-object
   (tell (coerce-arg self) inputContext)))
(define (nstableview-int-value self)
  (tell #:type _int32 (coerce-arg self) intValue))
(define (nstableview-set-int-value! self value)
  (_msg-68 (coerce-arg self) (sel_registerName "setIntValue:") value))
(define (nstableview-integer-value self)
  (tell #:type _int64 (coerce-arg self) integerValue))
(define (nstableview-set-integer-value! self value)
  (_msg-74 (coerce-arg self) (sel_registerName "setIntegerValue:") value))
(define (nstableview-intercell-spacing self)
  (tell #:type _NSSize (coerce-arg self) intercellSpacing))
(define (nstableview-set-intercell-spacing! self value)
  (_msg-34 (coerce-arg self) (sel_registerName "setIntercellSpacing:") value))
(define (nstableview-intrinsic-content-size self)
  (tell #:type _NSSize (coerce-arg self) intrinsicContentSize))
(define (nstableview-last-baseline-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) lastBaselineAnchor)))
(define (nstableview-last-baseline-offset-from-bottom self)
  (tell #:type _double (coerce-arg self) lastBaselineOffsetFromBottom))
(define (nstableview-layer self)
  (wrap-objc-object
   (tell (coerce-arg self) layer)))
(define (nstableview-set-layer! self value)
  (tell #:type _void (coerce-arg self) setLayer: (coerce-arg value)))
(define (nstableview-layer-contents-placement self)
  (tell #:type _int64 (coerce-arg self) layerContentsPlacement))
(define (nstableview-set-layer-contents-placement! self value)
  (_msg-74 (coerce-arg self) (sel_registerName "setLayerContentsPlacement:") value))
(define (nstableview-layer-contents-redraw-policy self)
  (tell #:type _int64 (coerce-arg self) layerContentsRedrawPolicy))
(define (nstableview-set-layer-contents-redraw-policy! self value)
  (_msg-74 (coerce-arg self) (sel_registerName "setLayerContentsRedrawPolicy:") value))
(define (nstableview-layer-uses-core-image-filters self)
  (tell #:type _bool (coerce-arg self) layerUsesCoreImageFilters))
(define (nstableview-set-layer-uses-core-image-filters! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setLayerUsesCoreImageFilters:") value))
(define (nstableview-layout-guides self)
  (wrap-objc-object
   (tell (coerce-arg self) layoutGuides)))
(define (nstableview-layout-margins-guide self)
  (wrap-objc-object
   (tell (coerce-arg self) layoutMarginsGuide)))
(define (nstableview-leading-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) leadingAnchor)))
(define (nstableview-left-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) leftAnchor)))
(define (nstableview-line-break-mode self)
  (tell #:type _uint64 (coerce-arg self) lineBreakMode))
(define (nstableview-set-line-break-mode! self value)
  (_msg-89 (coerce-arg self) (sel_registerName "setLineBreakMode:") value))
(define (nstableview-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) menu)))
(define (nstableview-set-menu! self value)
  (tell #:type _void (coerce-arg self) setMenu: (coerce-arg value)))
(define (nstableview-mouse-down-can-move-window self)
  (tell #:type _bool (coerce-arg self) mouseDownCanMoveWindow))
(define (nstableview-needs-display self)
  (tell #:type _bool (coerce-arg self) needsDisplay))
(define (nstableview-set-needs-display! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setNeedsDisplay:") value))
(define (nstableview-needs-layout self)
  (tell #:type _bool (coerce-arg self) needsLayout))
(define (nstableview-set-needs-layout! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setNeedsLayout:") value))
(define (nstableview-needs-panel-to-become-key self)
  (tell #:type _bool (coerce-arg self) needsPanelToBecomeKey))
(define (nstableview-needs-update-constraints self)
  (tell #:type _bool (coerce-arg self) needsUpdateConstraints))
(define (nstableview-set-needs-update-constraints! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setNeedsUpdateConstraints:") value))
(define (nstableview-next-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) nextKeyView)))
(define (nstableview-set-next-key-view! self value)
  (tell #:type _void (coerce-arg self) setNextKeyView: (coerce-arg value)))
(define (nstableview-next-responder self)
  (wrap-objc-object
   (tell (coerce-arg self) nextResponder)))
(define (nstableview-set-next-responder! self value)
  (tell #:type _void (coerce-arg self) setNextResponder: (coerce-arg value)))
(define (nstableview-next-valid-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) nextValidKeyView)))
(define (nstableview-number-of-columns self)
  (tell #:type _int64 (coerce-arg self) numberOfColumns))
(define (nstableview-number-of-rows self)
  (tell #:type _int64 (coerce-arg self) numberOfRows))
(define (nstableview-number-of-selected-columns self)
  (tell #:type _int64 (coerce-arg self) numberOfSelectedColumns))
(define (nstableview-number-of-selected-rows self)
  (tell #:type _int64 (coerce-arg self) numberOfSelectedRows))
(define (nstableview-object-value self)
  (wrap-objc-object
   (tell (coerce-arg self) objectValue)))
(define (nstableview-set-object-value! self value)
  (tell #:type _void (coerce-arg self) setObjectValue: (coerce-arg value)))
(define (nstableview-opaque self)
  (tell #:type _bool (coerce-arg self) opaque))
(define (nstableview-opaque-ancestor self)
  (wrap-objc-object
   (tell (coerce-arg self) opaqueAncestor)))
(define (nstableview-page-footer self)
  (wrap-objc-object
   (tell (coerce-arg self) pageFooter)))
(define (nstableview-page-header self)
  (wrap-objc-object
   (tell (coerce-arg self) pageHeader)))
(define (nstableview-posts-bounds-changed-notifications self)
  (tell #:type _bool (coerce-arg self) postsBoundsChangedNotifications))
(define (nstableview-set-posts-bounds-changed-notifications! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setPostsBoundsChangedNotifications:") value))
(define (nstableview-posts-frame-changed-notifications self)
  (tell #:type _bool (coerce-arg self) postsFrameChangedNotifications))
(define (nstableview-set-posts-frame-changed-notifications! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setPostsFrameChangedNotifications:") value))
(define (nstableview-prefers-compact-control-size-metrics self)
  (tell #:type _bool (coerce-arg self) prefersCompactControlSizeMetrics))
(define (nstableview-set-prefers-compact-control-size-metrics! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setPrefersCompactControlSizeMetrics:") value))
(define (nstableview-prepared-content-rect self)
  (tell #:type _NSRect (coerce-arg self) preparedContentRect))
(define (nstableview-set-prepared-content-rect! self value)
  (_msg-27 (coerce-arg self) (sel_registerName "setPreparedContentRect:") value))
(define (nstableview-preserves-content-during-live-resize self)
  (tell #:type _bool (coerce-arg self) preservesContentDuringLiveResize))
(define (nstableview-pressure-configuration self)
  (wrap-objc-object
   (tell (coerce-arg self) pressureConfiguration)))
(define (nstableview-set-pressure-configuration! self value)
  (tell #:type _void (coerce-arg self) setPressureConfiguration: (coerce-arg value)))
(define (nstableview-previous-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) previousKeyView)))
(define (nstableview-previous-valid-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) previousValidKeyView)))
(define (nstableview-print-job-title self)
  (wrap-objc-object
   (tell (coerce-arg self) printJobTitle)))
(define (nstableview-rect-preserved-during-live-resize self)
  (tell #:type _NSRect (coerce-arg self) rectPreservedDuringLiveResize))
(define (nstableview-refuses-first-responder self)
  (tell #:type _bool (coerce-arg self) refusesFirstResponder))
(define (nstableview-set-refuses-first-responder! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setRefusesFirstResponder:") value))
(define (nstableview-registered-dragged-types self)
  (wrap-objc-object
   (tell (coerce-arg self) registeredDraggedTypes)))
(define (nstableview-registered-nibs-by-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) registeredNibsByIdentifier)))
(define (nstableview-requires-constraint-based-layout)
  (tell #:type _bool NSTableView requiresConstraintBasedLayout))
(define (nstableview-restorable-state-key-paths)
  (wrap-objc-object
   (tell NSTableView restorableStateKeyPaths)))
(define (nstableview-right-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) rightAnchor)))
(define (nstableview-rotated-from-base self)
  (tell #:type _bool (coerce-arg self) rotatedFromBase))
(define (nstableview-rotated-or-scaled-from-base self)
  (tell #:type _bool (coerce-arg self) rotatedOrScaledFromBase))
(define (nstableview-row-actions-visible self)
  (tell #:type _bool (coerce-arg self) rowActionsVisible))
(define (nstableview-set-row-actions-visible! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setRowActionsVisible:") value))
(define (nstableview-row-height self)
  (tell #:type _double (coerce-arg self) rowHeight))
(define (nstableview-set-row-height! self value)
  (_msg-37 (coerce-arg self) (sel_registerName "setRowHeight:") value))
(define (nstableview-row-size-style self)
  (tell #:type _int64 (coerce-arg self) rowSizeStyle))
(define (nstableview-set-row-size-style! self value)
  (_msg-74 (coerce-arg self) (sel_registerName "setRowSizeStyle:") value))
(define (nstableview-safe-area-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) safeAreaInsets))
(define (nstableview-safe-area-layout-guide self)
  (wrap-objc-object
   (tell (coerce-arg self) safeAreaLayoutGuide)))
(define (nstableview-safe-area-rect self)
  (tell #:type _NSRect (coerce-arg self) safeAreaRect))
(define (nstableview-selected-column self)
  (tell #:type _int64 (coerce-arg self) selectedColumn))
(define (nstableview-selected-column-indexes self)
  (wrap-objc-object
   (tell (coerce-arg self) selectedColumnIndexes)))
(define (nstableview-selected-row self)
  (tell #:type _int64 (coerce-arg self) selectedRow))
(define (nstableview-selected-row-indexes self)
  (wrap-objc-object
   (tell (coerce-arg self) selectedRowIndexes)))
(define (nstableview-selection-highlight-style self)
  (tell #:type _int64 (coerce-arg self) selectionHighlightStyle))
(define (nstableview-set-selection-highlight-style! self value)
  (_msg-74 (coerce-arg self) (sel_registerName "setSelectionHighlightStyle:") value))
(define (nstableview-shadow self)
  (wrap-objc-object
   (tell (coerce-arg self) shadow)))
(define (nstableview-set-shadow! self value)
  (tell #:type _void (coerce-arg self) setShadow: (coerce-arg value)))
(define (nstableview-sort-descriptors self)
  (wrap-objc-object
   (tell (coerce-arg self) sortDescriptors)))
(define (nstableview-set-sort-descriptors! self value)
  (tell #:type _void (coerce-arg self) setSortDescriptors: (coerce-arg value)))
(define (nstableview-string-value self)
  (wrap-objc-object
   (tell (coerce-arg self) stringValue)))
(define (nstableview-set-string-value! self value)
  (tell #:type _void (coerce-arg self) setStringValue: (coerce-arg value)))
(define (nstableview-style self)
  (tell #:type _int64 (coerce-arg self) style))
(define (nstableview-set-style! self value)
  (_msg-74 (coerce-arg self) (sel_registerName "setStyle:") value))
(define (nstableview-subviews self)
  (wrap-objc-object
   (tell (coerce-arg self) subviews)))
(define (nstableview-set-subviews! self value)
  (tell #:type _void (coerce-arg self) setSubviews: (coerce-arg value)))
(define (nstableview-superview self)
  (wrap-objc-object
   (tell (coerce-arg self) superview)))
(define (nstableview-table-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) tableColumns)))
(define (nstableview-tag self)
  (tell #:type _int64 (coerce-arg self) tag))
(define (nstableview-set-tag! self value)
  (_msg-74 (coerce-arg self) (sel_registerName "setTag:") value))
(define (nstableview-target self)
  (wrap-objc-object
   (tell (coerce-arg self) target)))
(define (nstableview-set-target! self value)
  (tell #:type _void (coerce-arg self) setTarget: (coerce-arg value)))
(define (nstableview-tool-tip self)
  (wrap-objc-object
   (tell (coerce-arg self) toolTip)))
(define (nstableview-set-tool-tip! self value)
  (tell #:type _void (coerce-arg self) setToolTip: (coerce-arg value)))
(define (nstableview-top-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) topAnchor)))
(define (nstableview-touch-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) touchBar)))
(define (nstableview-set-touch-bar! self value)
  (tell #:type _void (coerce-arg self) setTouchBar: (coerce-arg value)))
(define (nstableview-tracking-areas self)
  (wrap-objc-object
   (tell (coerce-arg self) trackingAreas)))
(define (nstableview-trailing-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) trailingAnchor)))
(define (nstableview-translates-autoresizing-mask-into-constraints self)
  (tell #:type _bool (coerce-arg self) translatesAutoresizingMaskIntoConstraints))
(define (nstableview-set-translates-autoresizing-mask-into-constraints! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setTranslatesAutoresizingMaskIntoConstraints:") value))
(define (nstableview-undo-manager self)
  (wrap-objc-object
   (tell (coerce-arg self) undoManager)))
(define (nstableview-user-activity self)
  (wrap-objc-object
   (tell (coerce-arg self) userActivity)))
(define (nstableview-set-user-activity! self value)
  (tell #:type _void (coerce-arg self) setUserActivity: (coerce-arg value)))
(define (nstableview-user-interface-layout-direction self)
  (tell #:type _int64 (coerce-arg self) userInterfaceLayoutDirection))
(define (nstableview-set-user-interface-layout-direction! self value)
  (_msg-74 (coerce-arg self) (sel_registerName "setUserInterfaceLayoutDirection:") value))
(define (nstableview-uses-alternating-row-background-colors self)
  (tell #:type _bool (coerce-arg self) usesAlternatingRowBackgroundColors))
(define (nstableview-set-uses-alternating-row-background-colors! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setUsesAlternatingRowBackgroundColors:") value))
(define (nstableview-uses-automatic-row-heights self)
  (tell #:type _bool (coerce-arg self) usesAutomaticRowHeights))
(define (nstableview-set-uses-automatic-row-heights! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setUsesAutomaticRowHeights:") value))
(define (nstableview-uses-single-line-mode self)
  (tell #:type _bool (coerce-arg self) usesSingleLineMode))
(define (nstableview-set-uses-single-line-mode! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setUsesSingleLineMode:") value))
(define (nstableview-uses-static-contents self)
  (tell #:type _bool (coerce-arg self) usesStaticContents))
(define (nstableview-set-uses-static-contents! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setUsesStaticContents:") value))
(define (nstableview-vertical-content-size-constraint-active self)
  (tell #:type _bool (coerce-arg self) verticalContentSizeConstraintActive))
(define (nstableview-set-vertical-content-size-constraint-active! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setVerticalContentSizeConstraintActive:") value))
(define (nstableview-vertical-motion-can-begin-drag self)
  (tell #:type _bool (coerce-arg self) verticalMotionCanBeginDrag))
(define (nstableview-set-vertical-motion-can-begin-drag! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setVerticalMotionCanBeginDrag:") value))
(define (nstableview-visible-rect self)
  (tell #:type _NSRect (coerce-arg self) visibleRect))
(define (nstableview-wants-best-resolution-open-gl-surface self)
  (tell #:type _bool (coerce-arg self) wantsBestResolutionOpenGLSurface))
(define (nstableview-set-wants-best-resolution-open-gl-surface! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setWantsBestResolutionOpenGLSurface:") value))
(define (nstableview-wants-default-clipping self)
  (tell #:type _bool (coerce-arg self) wantsDefaultClipping))
(define (nstableview-wants-extended-dynamic-range-open-gl-surface self)
  (tell #:type _bool (coerce-arg self) wantsExtendedDynamicRangeOpenGLSurface))
(define (nstableview-set-wants-extended-dynamic-range-open-gl-surface! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setWantsExtendedDynamicRangeOpenGLSurface:") value))
(define (nstableview-wants-layer self)
  (tell #:type _bool (coerce-arg self) wantsLayer))
(define (nstableview-set-wants-layer! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setWantsLayer:") value))
(define (nstableview-wants-resting-touches self)
  (tell #:type _bool (coerce-arg self) wantsRestingTouches))
(define (nstableview-set-wants-resting-touches! self value)
  (_msg-36 (coerce-arg self) (sel_registerName "setWantsRestingTouches:") value))
(define (nstableview-wants-update-layer self)
  (tell #:type _bool (coerce-arg self) wantsUpdateLayer))
(define (nstableview-width-adjust-limit self)
  (tell #:type _double (coerce-arg self) widthAdjustLimit))
(define (nstableview-width-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) widthAnchor)))
(define (nstableview-window self)
  (wrap-objc-object
   (tell (coerce-arg self) window)))
(define (nstableview-writing-tools-coordinator self)
  (wrap-objc-object
   (tell (coerce-arg self) writingToolsCoordinator)))
(define (nstableview-set-writing-tools-coordinator! self value)
  (tell #:type _void (coerce-arg self) setWritingToolsCoordinator: (coerce-arg value)))

;; --- Instance methods ---
(define (nstableview-accepts-first-mouse self event)
  (_msg-39 (coerce-arg self) (sel_registerName "acceptsFirstMouse:") (coerce-arg event)))
(define (nstableview-accessibility-activation-point self)
  (_msg-0 (coerce-arg self) (sel_registerName "accessibilityActivationPoint")))
(define (nstableview-accessibility-allowed-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAllowedValues)))
(define (nstableview-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityApplicationFocusedUIElement)))
(define (nstableview-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (_msg-21 (coerce-arg self) (sel_registerName "accessibilityAttributedStringForRange:") range)
   ))
(define (nstableview-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAttributedUserInputLabels)))
(define (nstableview-accessibility-cancel-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCancelButton)))
(define (nstableview-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (_msg-78 (coerce-arg self) (sel_registerName "accessibilityCellForColumn:row:") column row)
   ))
(define (nstableview-accessibility-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildren)))
(define (nstableview-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildrenInNavigationOrder)))
(define (nstableview-accessibility-clear-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityClearButton)))
(define (nstableview-accessibility-close-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCloseButton)))
(define (nstableview-accessibility-column-count self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityColumnCount")))
(define (nstableview-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnHeaderUIElements)))
(define (nstableview-accessibility-column-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityColumnIndexRange")))
(define (nstableview-accessibility-column-titles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnTitles)))
(define (nstableview-accessibility-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumns)))
(define (nstableview-accessibility-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityContents)))
(define (nstableview-accessibility-critical-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCriticalValue)))
(define (nstableview-accessibility-custom-actions self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomActions)))
(define (nstableview-accessibility-custom-rotors self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomRotors)))
(define (nstableview-accessibility-decrement-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDecrementButton)))
(define (nstableview-accessibility-default-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDefaultButton)))
(define (nstableview-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedByRow)))
(define (nstableview-accessibility-disclosed-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedRows)))
(define (nstableview-accessibility-disclosure-level self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityDisclosureLevel")))
(define (nstableview-accessibility-document self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDocument)))
(define (nstableview-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityExtrasMenuBar)))
(define (nstableview-accessibility-filename self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFilename)))
(define (nstableview-accessibility-focused-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFocusedWindow)))
(define (nstableview-accessibility-frame self)
  (_msg-2 (coerce-arg self) (sel_registerName "accessibilityFrame")))
(define (nstableview-accessibility-frame-for-range self range)
  (_msg-20 (coerce-arg self) (sel_registerName "accessibilityFrameForRange:") range))
(define (nstableview-accessibility-full-screen-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFullScreenButton)))
(define (nstableview-accessibility-grow-area self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityGrowArea)))
(define (nstableview-accessibility-handles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHandles)))
(define (nstableview-accessibility-header self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHeader)))
(define (nstableview-accessibility-help self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHelp)))
(define (nstableview-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalScrollBar)))
(define (nstableview-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalUnitDescription)))
(define (nstableview-accessibility-horizontal-units self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityHorizontalUnits")))
(define (nstableview-accessibility-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIdentifier)))
(define (nstableview-accessibility-increment-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIncrementButton)))
(define (nstableview-accessibility-index self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityIndex")))
(define (nstableview-accessibility-insertion-point-line-number self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityInsertionPointLineNumber")))
(define (nstableview-accessibility-label self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabel)))
(define (nstableview-accessibility-label-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabelUIElements)))
(define (nstableview-accessibility-label-value self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityLabelValue")))
(define (nstableview-accessibility-layout-point-for-screen-point self point)
  (_msg-12 (coerce-arg self) (sel_registerName "accessibilityLayoutPointForScreenPoint:") point))
(define (nstableview-accessibility-layout-size-for-screen-size self size)
  (_msg-33 (coerce-arg self) (sel_registerName "accessibilityLayoutSizeForScreenSize:") size))
(define (nstableview-accessibility-line-for-index self index)
  (_msg-73 (coerce-arg self) (sel_registerName "accessibilityLineForIndex:") index))
(define (nstableview-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLinkedUIElements)))
(define (nstableview-accessibility-main-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMainWindow)))
(define (nstableview-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerGroupUIElement)))
(define (nstableview-accessibility-marker-type-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerTypeDescription)))
(define (nstableview-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerUIElements)))
(define (nstableview-accessibility-marker-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerValues)))
(define (nstableview-accessibility-max-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMaxValue)))
(define (nstableview-accessibility-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMenuBar)))
(define (nstableview-accessibility-min-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinValue)))
(define (nstableview-accessibility-minimize-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinimizeButton)))
(define (nstableview-accessibility-next-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityNextContents)))
(define (nstableview-accessibility-number-of-characters self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityNumberOfCharacters")))
(define (nstableview-accessibility-orientation self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityOrientation")))
(define (nstableview-accessibility-overflow-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityOverflowButton)))
(define (nstableview-accessibility-parent self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityParent)))
(define (nstableview-accessibility-perform-cancel self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformCancel")))
(define (nstableview-accessibility-perform-confirm self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformConfirm")))
(define (nstableview-accessibility-perform-decrement self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformDecrement")))
(define (nstableview-accessibility-perform-delete self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformDelete")))
(define (nstableview-accessibility-perform-increment self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformIncrement")))
(define (nstableview-accessibility-perform-pick self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformPick")))
(define (nstableview-accessibility-perform-press self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformPress")))
(define (nstableview-accessibility-perform-raise self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformRaise")))
(define (nstableview-accessibility-perform-show-alternate-ui self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformShowAlternateUI")))
(define (nstableview-accessibility-perform-show-default-ui self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformShowDefaultUI")))
(define (nstableview-accessibility-perform-show-menu self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformShowMenu")))
(define (nstableview-accessibility-placeholder-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPlaceholderValue)))
(define (nstableview-accessibility-previous-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPreviousContents)))
(define (nstableview-accessibility-proxy self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityProxy)))
(define (nstableview-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (_msg-21 (coerce-arg self) (sel_registerName "accessibilityRTFForRange:") range)
   ))
(define (nstableview-accessibility-range-for-index self index)
  (_msg-69 (coerce-arg self) (sel_registerName "accessibilityRangeForIndex:") index))
(define (nstableview-accessibility-range-for-line self line)
  (_msg-69 (coerce-arg self) (sel_registerName "accessibilityRangeForLine:") line))
(define (nstableview-accessibility-range-for-position self point)
  (_msg-13 (coerce-arg self) (sel_registerName "accessibilityRangeForPosition:") point))
(define (nstableview-accessibility-role self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRole)))
(define (nstableview-accessibility-role-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRoleDescription)))
(define (nstableview-accessibility-row-count self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityRowCount")))
(define (nstableview-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRowHeaderUIElements)))
(define (nstableview-accessibility-row-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityRowIndexRange")))
(define (nstableview-accessibility-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRows)))
(define (nstableview-accessibility-ruler-marker-type self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityRulerMarkerType")))
(define (nstableview-accessibility-screen-point-for-layout-point self point)
  (_msg-12 (coerce-arg self) (sel_registerName "accessibilityScreenPointForLayoutPoint:") point))
(define (nstableview-accessibility-screen-size-for-layout-size self size)
  (_msg-33 (coerce-arg self) (sel_registerName "accessibilityScreenSizeForLayoutSize:") size))
(define (nstableview-accessibility-search-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchButton)))
(define (nstableview-accessibility-search-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchMenu)))
(define (nstableview-accessibility-selected-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedCells)))
(define (nstableview-accessibility-selected-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedChildren)))
(define (nstableview-accessibility-selected-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedColumns)))
(define (nstableview-accessibility-selected-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedRows)))
(define (nstableview-accessibility-selected-text self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedText)))
(define (nstableview-accessibility-selected-text-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySelectedTextRange")))
(define (nstableview-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedTextRanges)))
(define (nstableview-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityServesAsTitleForUIElements)))
(define (nstableview-accessibility-shared-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySharedCharacterRange")))
(define (nstableview-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedFocusElements)))
(define (nstableview-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedTextUIElements)))
(define (nstableview-accessibility-shown-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityShownMenu)))
(define (nstableview-accessibility-sort-direction self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilitySortDirection")))
(define (nstableview-accessibility-splitters self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySplitters)))
(define (nstableview-accessibility-string-for-range self range)
  (wrap-objc-object
   (_msg-21 (coerce-arg self) (sel_registerName "accessibilityStringForRange:") range)
   ))
(define (nstableview-accessibility-style-range-for-index self index)
  (_msg-69 (coerce-arg self) (sel_registerName "accessibilityStyleRangeForIndex:") index))
(define (nstableview-accessibility-subrole self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySubrole)))
(define (nstableview-accessibility-tabs self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTabs)))
(define (nstableview-accessibility-title self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitle)))
(define (nstableview-accessibility-title-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitleUIElement)))
(define (nstableview-accessibility-toolbar-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityToolbarButton)))
(define (nstableview-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTopLevelUIElement)))
(define (nstableview-accessibility-url self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityURL)))
(define (nstableview-accessibility-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUnitDescription)))
(define (nstableview-accessibility-units self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityUnits")))
(define (nstableview-accessibility-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUserInputLabels)))
(define (nstableview-accessibility-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValue)))
(define (nstableview-accessibility-value-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValueDescription)))
(define (nstableview-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalScrollBar)))
(define (nstableview-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalUnitDescription)))
(define (nstableview-accessibility-vertical-units self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityVerticalUnits")))
(define (nstableview-accessibility-visible-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleCells)))
(define (nstableview-accessibility-visible-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityVisibleCharacterRange")))
(define (nstableview-accessibility-visible-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleChildren)))
(define (nstableview-accessibility-visible-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleColumns)))
(define (nstableview-accessibility-visible-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleRows)))
(define (nstableview-accessibility-warning-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWarningValue)))
(define (nstableview-accessibility-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindow)))
(define (nstableview-accessibility-windows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindows)))
(define (nstableview-accessibility-zoom-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityZoomButton)))
(define (nstableview-add-subview! self view)
  (tell #:type _void (coerce-arg self) addSubview: (coerce-arg view)))
(define (nstableview-add-subview-positioned-relative-to! self view place other-view)
  (_msg-64 (coerce-arg self) (sel_registerName "addSubview:positioned:relativeTo:") (coerce-arg view) place (coerce-arg other-view)))
(define (nstableview-add-table-column! self table-column)
  (tell #:type _void (coerce-arg self) addTableColumn: (coerce-arg table-column)))
(define (nstableview-add-tool-tip-rect-owner-user-data! self rect owner data)
  (_msg-31 (coerce-arg self) (sel_registerName "addToolTipRect:owner:userData:") rect (coerce-arg owner) data))
(define (nstableview-adjust-scroll self new-visible)
  (_msg-24 (coerce-arg self) (sel_registerName "adjustScroll:") new-visible))
(define (nstableview-ancestor-shared-with-view self view)
  (wrap-objc-object
   (tell (coerce-arg self) ancestorSharedWithView: (coerce-arg view))))
(define (nstableview-animation-for-key self key)
  (wrap-objc-object
   (tell (coerce-arg self) animationForKey: (coerce-arg key))))
(define (nstableview-animations self)
  (wrap-objc-object
   (tell (coerce-arg self) animations)))
(define (nstableview-animator self)
  (wrap-objc-object
   (tell (coerce-arg self) animator)))
(define (nstableview-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) appearance)))
(define (nstableview-autoscroll self event)
  (_msg-39 (coerce-arg self) (sel_registerName "autoscroll:") (coerce-arg event)))
(define (nstableview-backing-aligned-rect-options self rect options)
  (_msg-32 (coerce-arg self) (sel_registerName "backingAlignedRect:options:") rect options))
(define (nstableview-become-first-responder self)
  (_msg-4 (coerce-arg self) (sel_registerName "becomeFirstResponder")))
(define (nstableview-begin-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) beginGestureWithEvent: (coerce-arg event)))
(define (nstableview-begin-updates! self)
  (tell #:type _void (coerce-arg self) beginUpdates))
(define (nstableview-bitmap-image-rep-for-caching-display-in-rect self rect)
  (wrap-objc-object
   (_msg-26 (coerce-arg self) (sel_registerName "bitmapImageRepForCachingDisplayInRect:") rect)
   ))
(define (nstableview-cache-display-in-rect-to-bitmap-image-rep self rect bitmap-image-rep)
  (_msg-30 (coerce-arg self) (sel_registerName "cacheDisplayInRect:toBitmapImageRep:") rect (coerce-arg bitmap-image-rep)))
(define (nstableview-can-drag-rows-with-indexes-at-point self row-indexes mouse-down-point)
  (_msg-42 (coerce-arg self) (sel_registerName "canDragRowsWithIndexes:atPoint:") (coerce-arg row-indexes) mouse-down-point))
(define (nstableview-cancel-operation self sender)
  (tell #:type _void (coerce-arg self) cancelOperation: (coerce-arg sender)))
(define (nstableview-capitalize-word self sender)
  (tell #:type _void (coerce-arg self) capitalizeWord: (coerce-arg sender)))
(define (nstableview-center-scan-rect! self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "centerScanRect:") rect))
(define (nstableview-center-selection-in-visible-area! self sender)
  (tell #:type _void (coerce-arg self) centerSelectionInVisibleArea: (coerce-arg sender)))
(define (nstableview-change-case-of-letter self sender)
  (tell #:type _void (coerce-arg self) changeCaseOfLetter: (coerce-arg sender)))
(define (nstableview-change-mode-with-event self event)
  (tell #:type _void (coerce-arg self) changeModeWithEvent: (coerce-arg event)))
(define (nstableview-column-at-point self point)
  (_msg-15 (coerce-arg self) (sel_registerName "columnAtPoint:") point))
(define (nstableview-column-for-view self view)
  (_msg-40 (coerce-arg self) (sel_registerName "columnForView:") (coerce-arg view)))
(define (nstableview-column-indexes-in-rect self rect)
  (wrap-objc-object
   (_msg-26 (coerce-arg self) (sel_registerName "columnIndexesInRect:") rect)
   ))
(define (nstableview-column-with-identifier self identifier)
  (_msg-40 (coerce-arg self) (sel_registerName "columnWithIdentifier:") (coerce-arg identifier)))
(define (nstableview-complete self sender)
  (tell #:type _void (coerce-arg self) complete: (coerce-arg sender)))
(define (nstableview-conclude-drag-operation self sender)
  (tell #:type _void (coerce-arg self) concludeDragOperation: (coerce-arg sender)))
(define (nstableview-context-menu-key-down self event)
  (tell #:type _void (coerce-arg self) contextMenuKeyDown: (coerce-arg event)))
(define (nstableview-convert-point-from-view self point view)
  (_msg-19 (coerce-arg self) (sel_registerName "convertPoint:fromView:") point (coerce-arg view)))
(define (nstableview-convert-point-to-view self point view)
  (_msg-19 (coerce-arg self) (sel_registerName "convertPoint:toView:") point (coerce-arg view)))
(define (nstableview-convert-point-from-backing self point)
  (_msg-12 (coerce-arg self) (sel_registerName "convertPointFromBacking:") point))
(define (nstableview-convert-point-from-layer self point)
  (_msg-12 (coerce-arg self) (sel_registerName "convertPointFromLayer:") point))
(define (nstableview-convert-point-to-backing self point)
  (_msg-12 (coerce-arg self) (sel_registerName "convertPointToBacking:") point))
(define (nstableview-convert-point-to-layer self point)
  (_msg-12 (coerce-arg self) (sel_registerName "convertPointToLayer:") point))
(define (nstableview-convert-rect-from-view self rect view)
  (_msg-29 (coerce-arg self) (sel_registerName "convertRect:fromView:") rect (coerce-arg view)))
(define (nstableview-convert-rect-to-view self rect view)
  (_msg-29 (coerce-arg self) (sel_registerName "convertRect:toView:") rect (coerce-arg view)))
(define (nstableview-convert-rect-from-backing self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "convertRectFromBacking:") rect))
(define (nstableview-convert-rect-from-layer self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "convertRectFromLayer:") rect))
(define (nstableview-convert-rect-to-backing self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "convertRectToBacking:") rect))
(define (nstableview-convert-rect-to-layer self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "convertRectToLayer:") rect))
(define (nstableview-convert-size-from-view self size view)
  (_msg-35 (coerce-arg self) (sel_registerName "convertSize:fromView:") size (coerce-arg view)))
(define (nstableview-convert-size-to-view self size view)
  (_msg-35 (coerce-arg self) (sel_registerName "convertSize:toView:") size (coerce-arg view)))
(define (nstableview-convert-size-from-backing self size)
  (_msg-33 (coerce-arg self) (sel_registerName "convertSizeFromBacking:") size))
(define (nstableview-convert-size-from-layer self size)
  (_msg-33 (coerce-arg self) (sel_registerName "convertSizeFromLayer:") size))
(define (nstableview-convert-size-to-backing self size)
  (_msg-33 (coerce-arg self) (sel_registerName "convertSizeToBacking:") size))
(define (nstableview-convert-size-to-layer self size)
  (_msg-33 (coerce-arg self) (sel_registerName "convertSizeToLayer:") size))
(define (nstableview-cursor-update self event)
  (tell #:type _void (coerce-arg self) cursorUpdate: (coerce-arg event)))
(define (nstableview-delete-backward self sender)
  (tell #:type _void (coerce-arg self) deleteBackward: (coerce-arg sender)))
(define (nstableview-delete-backward-by-decomposing-previous-character self sender)
  (tell #:type _void (coerce-arg self) deleteBackwardByDecomposingPreviousCharacter: (coerce-arg sender)))
(define (nstableview-delete-forward self sender)
  (tell #:type _void (coerce-arg self) deleteForward: (coerce-arg sender)))
(define (nstableview-delete-to-beginning-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfLine: (coerce-arg sender)))
(define (nstableview-delete-to-beginning-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfParagraph: (coerce-arg sender)))
(define (nstableview-delete-to-end-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfLine: (coerce-arg sender)))
(define (nstableview-delete-to-end-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfParagraph: (coerce-arg sender)))
(define (nstableview-delete-to-mark self sender)
  (tell #:type _void (coerce-arg self) deleteToMark: (coerce-arg sender)))
(define (nstableview-delete-word-backward self sender)
  (tell #:type _void (coerce-arg self) deleteWordBackward: (coerce-arg sender)))
(define (nstableview-delete-word-forward self sender)
  (tell #:type _void (coerce-arg self) deleteWordForward: (coerce-arg sender)))
(define (nstableview-deselect-all self sender)
  (tell #:type _void (coerce-arg self) deselectAll: (coerce-arg sender)))
(define (nstableview-deselect-column self column)
  (_msg-74 (coerce-arg self) (sel_registerName "deselectColumn:") column))
(define (nstableview-deselect-row self row)
  (_msg-74 (coerce-arg self) (sel_registerName "deselectRow:") row))
(define (nstableview-did-add-row-view-for-row self row-view row)
  (_msg-62 (coerce-arg self) (sel_registerName "didAddRowView:forRow:") (coerce-arg row-view) row))
(define (nstableview-did-add-subview self subview)
  (tell #:type _void (coerce-arg self) didAddSubview: (coerce-arg subview)))
(define (nstableview-did-close-menu-with-event self menu event)
  (tell #:type _void (coerce-arg self) didCloseMenu: (coerce-arg menu) withEvent: (coerce-arg event)))
(define (nstableview-did-remove-row-view-for-row self row-view row)
  (_msg-62 (coerce-arg self) (sel_registerName "didRemoveRowView:forRow:") (coerce-arg row-view) row))
(define (nstableview-display! self)
  (tell #:type _void (coerce-arg self) display))
(define (nstableview-display-if-needed! self)
  (tell #:type _void (coerce-arg self) displayIfNeeded))
(define (nstableview-display-if-needed-ignoring-opacity! self)
  (tell #:type _void (coerce-arg self) displayIfNeededIgnoringOpacity))
(define (nstableview-display-if-needed-in-rect! self rect)
  (_msg-27 (coerce-arg self) (sel_registerName "displayIfNeededInRect:") rect))
(define (nstableview-display-if-needed-in-rect-ignoring-opacity! self rect)
  (_msg-27 (coerce-arg self) (sel_registerName "displayIfNeededInRectIgnoringOpacity:") rect))
(define (nstableview-display-rect! self rect)
  (_msg-27 (coerce-arg self) (sel_registerName "displayRect:") rect))
(define (nstableview-display-rect-ignoring-opacity! self rect)
  (_msg-27 (coerce-arg self) (sel_registerName "displayRectIgnoringOpacity:") rect))
(define (nstableview-display-rect-ignoring-opacity-in-context! self rect context)
  (_msg-30 (coerce-arg self) (sel_registerName "displayRectIgnoringOpacity:inContext:") rect (coerce-arg context)))
(define (nstableview-do-command-by-selector self selector)
  (_msg-84 (coerce-arg self) (sel_registerName "doCommandBySelector:") (sel_registerName selector)))
(define (nstableview-drag-image-for-rows-with-indexes-table-columns-event-offset self drag-rows table-columns drag-event drag-image-offset)
  (wrap-objc-object
   (_msg-56 (coerce-arg self) (sel_registerName "dragImageForRowsWithIndexes:tableColumns:event:offset:") (coerce-arg drag-rows) (coerce-arg table-columns) (coerce-arg drag-event) drag-image-offset)
   ))
(define (nstableview-dragging-ended self sender)
  (tell #:type _void (coerce-arg self) draggingEnded: (coerce-arg sender)))
(define (nstableview-dragging-entered self sender)
  (_msg-41 (coerce-arg self) (sel_registerName "draggingEntered:") (coerce-arg sender)))
(define (nstableview-dragging-exited self sender)
  (tell #:type _void (coerce-arg self) draggingExited: (coerce-arg sender)))
(define (nstableview-dragging-session-ended-at-point-operation self session screen-point operation)
  (_msg-44 (coerce-arg self) (sel_registerName "draggingSession:endedAtPoint:operation:") (coerce-arg session) screen-point operation))
(define (nstableview-dragging-session-moved-to-point self session screen-point)
  (_msg-43 (coerce-arg self) (sel_registerName "draggingSession:movedToPoint:") (coerce-arg session) screen-point))
(define (nstableview-dragging-session-source-operation-mask-for-dragging-context self session context)
  (_msg-61 (coerce-arg self) (sel_registerName "draggingSession:sourceOperationMaskForDraggingContext:") (coerce-arg session) context))
(define (nstableview-dragging-session-will-begin-at-point self session screen-point)
  (_msg-43 (coerce-arg self) (sel_registerName "draggingSession:willBeginAtPoint:") (coerce-arg session) screen-point))
(define (nstableview-dragging-updated self sender)
  (_msg-41 (coerce-arg self) (sel_registerName "draggingUpdated:") (coerce-arg sender)))
(define (nstableview-draw-background-in-clip-rect self clip-rect)
  (_msg-27 (coerce-arg self) (sel_registerName "drawBackgroundInClipRect:") clip-rect))
(define (nstableview-draw-grid-in-clip-rect self clip-rect)
  (_msg-27 (coerce-arg self) (sel_registerName "drawGridInClipRect:") clip-rect))
(define (nstableview-draw-rect self dirty-rect)
  (_msg-27 (coerce-arg self) (sel_registerName "drawRect:") dirty-rect))
(define (nstableview-draw-row-clip-rect self row clip-rect)
  (_msg-75 (coerce-arg self) (sel_registerName "drawRow:clipRect:") row clip-rect))
(define (nstableview-draw-with-expansion-frame-in-view self content-frame view)
  (_msg-30 (coerce-arg self) (sel_registerName "drawWithExpansionFrame:inView:") content-frame (coerce-arg view)))
(define (nstableview-edit-column-row-with-event-select self column row event select)
  (_msg-81 (coerce-arg self) (sel_registerName "editColumn:row:withEvent:select:") column row (coerce-arg event) select))
(define (nstableview-effective-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) effectiveAppearance)))
(define (nstableview-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nstableview-end-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) endGestureWithEvent: (coerce-arg event)))
(define (nstableview-end-updates! self)
  (tell #:type _void (coerce-arg self) endUpdates))
;; block param 0: synchronous (caller frees)
(define (nstableview-enumerate-available-row-views-using-block self handler)
  (define-values (_blk0 _blk0-id)
    (make-objc-block handler (list _id _int64) _void))
  (_msg-84 (coerce-arg self) (sel_registerName "enumerateAvailableRowViewsUsingBlock:") _blk0))
(define (nstableview-expansion-frame-with-frame self content-frame)
  (_msg-24 (coerce-arg self) (sel_registerName "expansionFrameWithFrame:") content-frame))
(define (nstableview-flags-changed self event)
  (tell #:type _void (coerce-arg self) flagsChanged: (coerce-arg event)))
(define (nstableview-flush-buffered-key-events self)
  (tell #:type _void (coerce-arg self) flushBufferedKeyEvents))
(define (nstableview-frame-of-cell-at-column-row self column row)
  (_msg-77 (coerce-arg self) (sel_registerName "frameOfCellAtColumn:row:") column row))
(define (nstableview-get-rects-being-drawn-count self rects count)
  (_msg-87 (coerce-arg self) (sel_registerName "getRectsBeingDrawn:count:") rects count))
(define (nstableview-get-rects-exposed-during-live-resize-count self exposed-rects count)
  (_msg-87 (coerce-arg self) (sel_registerName "getRectsExposedDuringLiveResize:count:") exposed-rects count))
(define (nstableview-help-requested self event-ptr)
  (tell #:type _void (coerce-arg self) helpRequested: (coerce-arg event-ptr)))
(define (nstableview-hide-rows-at-indexes-with-animation self indexes row-animation)
  (_msg-67 (coerce-arg self) (sel_registerName "hideRowsAtIndexes:withAnimation:") (coerce-arg indexes) row-animation))
(define (nstableview-highlight-selection-in-clip-rect self clip-rect)
  (_msg-27 (coerce-arg self) (sel_registerName "highlightSelectionInClipRect:") clip-rect))
(define (nstableview-hit-test self point)
  (wrap-objc-object
   (_msg-14 (coerce-arg self) (sel_registerName "hitTest:") point)
   ))
(define (nstableview-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) identifier)))
(define (nstableview-ignore-modifier-keys-for-dragging-session self session)
  (_msg-39 (coerce-arg self) (sel_registerName "ignoreModifierKeysForDraggingSession:") (coerce-arg session)))
(define (nstableview-indent self sender)
  (tell #:type _void (coerce-arg self) indent: (coerce-arg sender)))
(define (nstableview-indicator-image-in-table-column self table-column)
  (wrap-objc-object
   (tell (coerce-arg self) indicatorImageInTableColumn: (coerce-arg table-column))))
(define (nstableview-insert-backtab! self sender)
  (tell #:type _void (coerce-arg self) insertBacktab: (coerce-arg sender)))
(define (nstableview-insert-container-break! self sender)
  (tell #:type _void (coerce-arg self) insertContainerBreak: (coerce-arg sender)))
(define (nstableview-insert-double-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertDoubleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nstableview-insert-line-break! self sender)
  (tell #:type _void (coerce-arg self) insertLineBreak: (coerce-arg sender)))
(define (nstableview-insert-newline! self sender)
  (tell #:type _void (coerce-arg self) insertNewline: (coerce-arg sender)))
(define (nstableview-insert-newline-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertNewlineIgnoringFieldEditor: (coerce-arg sender)))
(define (nstableview-insert-paragraph-separator! self sender)
  (tell #:type _void (coerce-arg self) insertParagraphSeparator: (coerce-arg sender)))
(define (nstableview-insert-rows-at-indexes-with-animation! self indexes animation-options)
  (_msg-67 (coerce-arg self) (sel_registerName "insertRowsAtIndexes:withAnimation:") (coerce-arg indexes) animation-options))
(define (nstableview-insert-single-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertSingleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nstableview-insert-tab! self sender)
  (tell #:type _void (coerce-arg self) insertTab: (coerce-arg sender)))
(define (nstableview-insert-tab-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertTabIgnoringFieldEditor: (coerce-arg sender)))
(define (nstableview-insert-text! self insert-string)
  (tell #:type _void (coerce-arg self) insertText: (coerce-arg insert-string)))
(define (nstableview-interpret-key-events self event-array)
  (tell #:type _void (coerce-arg self) interpretKeyEvents: (coerce-arg event-array)))
(define (nstableview-is-accessibility-alternate-ui-visible self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityAlternateUIVisible")))
(define (nstableview-is-accessibility-disclosed self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityDisclosed")))
(define (nstableview-is-accessibility-edited self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityEdited")))
(define (nstableview-is-accessibility-element self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityElement")))
(define (nstableview-is-accessibility-enabled self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityEnabled")))
(define (nstableview-is-accessibility-expanded self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityExpanded")))
(define (nstableview-is-accessibility-focused self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityFocused")))
(define (nstableview-is-accessibility-frontmost self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityFrontmost")))
(define (nstableview-is-accessibility-hidden self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityHidden")))
(define (nstableview-is-accessibility-main self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityMain")))
(define (nstableview-is-accessibility-minimized self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityMinimized")))
(define (nstableview-is-accessibility-modal self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityModal")))
(define (nstableview-is-accessibility-ordered-by-row self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityOrderedByRow")))
(define (nstableview-is-accessibility-protected-content self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityProtectedContent")))
(define (nstableview-is-accessibility-required self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityRequired")))
(define (nstableview-is-accessibility-selected self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilitySelected")))
(define (nstableview-is-accessibility-selector-allowed self selector)
  (_msg-83 (coerce-arg self) (sel_registerName "isAccessibilitySelectorAllowed:") (sel_registerName selector)))
(define (nstableview-is-column-selected self column)
  (_msg-71 (coerce-arg self) (sel_registerName "isColumnSelected:") column))
(define (nstableview-is-continuous self)
  (_msg-4 (coerce-arg self) (sel_registerName "isContinuous")))
(define (nstableview-is-descendant-of self view)
  (_msg-39 (coerce-arg self) (sel_registerName "isDescendantOf:") (coerce-arg view)))
(define (nstableview-is-enabled self)
  (_msg-4 (coerce-arg self) (sel_registerName "isEnabled")))
(define (nstableview-is-flipped self)
  (_msg-4 (coerce-arg self) (sel_registerName "isFlipped")))
(define (nstableview-is-hidden self)
  (_msg-4 (coerce-arg self) (sel_registerName "isHidden")))
(define (nstableview-is-hidden-or-has-hidden-ancestor self)
  (_msg-4 (coerce-arg self) (sel_registerName "isHiddenOrHasHiddenAncestor")))
(define (nstableview-is-highlighted self)
  (_msg-4 (coerce-arg self) (sel_registerName "isHighlighted")))
(define (nstableview-is-opaque self)
  (_msg-4 (coerce-arg self) (sel_registerName "isOpaque")))
(define (nstableview-is-rotated-from-base self)
  (_msg-4 (coerce-arg self) (sel_registerName "isRotatedFromBase")))
(define (nstableview-is-rotated-or-scaled-from-base self)
  (_msg-4 (coerce-arg self) (sel_registerName "isRotatedOrScaledFromBase")))
(define (nstableview-is-row-selected self row)
  (_msg-71 (coerce-arg self) (sel_registerName "isRowSelected:") row))
(define (nstableview-key-down self event)
  (tell #:type _void (coerce-arg self) keyDown: (coerce-arg event)))
(define (nstableview-key-up self event)
  (tell #:type _void (coerce-arg self) keyUp: (coerce-arg event)))
(define (nstableview-layout self)
  (tell #:type _void (coerce-arg self) layout))
(define (nstableview-layout-subtree-if-needed self)
  (tell #:type _void (coerce-arg self) layoutSubtreeIfNeeded))
(define (nstableview-lowercase-word self sender)
  (tell #:type _void (coerce-arg self) lowercaseWord: (coerce-arg sender)))
(define (nstableview-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) magnifyWithEvent: (coerce-arg event)))
(define (nstableview-make-backing-layer self)
  (wrap-objc-object
   (tell (coerce-arg self) makeBackingLayer)))
(define (nstableview-make-base-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nstableview-make-base-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionNatural: (coerce-arg sender)))
(define (nstableview-make-base-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nstableview-make-text-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nstableview-make-text-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionNatural: (coerce-arg sender)))
(define (nstableview-make-text-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nstableview-make-view-with-identifier-owner self identifier owner)
  (wrap-objc-object
   (tell (coerce-arg self) makeViewWithIdentifier: (coerce-arg identifier) owner: (coerce-arg owner))))
(define (nstableview-menu-for-event self event)
  (wrap-objc-object
   (tell (coerce-arg self) menuForEvent: (coerce-arg event))))
(define (nstableview-mouse-in-rect self point rect)
  (_msg-18 (coerce-arg self) (sel_registerName "mouse:inRect:") point rect))
(define (nstableview-mouse-cancelled self event)
  (tell #:type _void (coerce-arg self) mouseCancelled: (coerce-arg event)))
(define (nstableview-mouse-down self event)
  (tell #:type _void (coerce-arg self) mouseDown: (coerce-arg event)))
(define (nstableview-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) mouseDragged: (coerce-arg event)))
(define (nstableview-mouse-entered self event)
  (tell #:type _void (coerce-arg self) mouseEntered: (coerce-arg event)))
(define (nstableview-mouse-exited self event)
  (tell #:type _void (coerce-arg self) mouseExited: (coerce-arg event)))
(define (nstableview-mouse-moved self event)
  (tell #:type _void (coerce-arg self) mouseMoved: (coerce-arg event)))
(define (nstableview-mouse-up self event)
  (tell #:type _void (coerce-arg self) mouseUp: (coerce-arg event)))
(define (nstableview-move-backward! self sender)
  (tell #:type _void (coerce-arg self) moveBackward: (coerce-arg sender)))
(define (nstableview-move-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveBackwardAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-column-to-column! self old-index new-index)
  (_msg-79 (coerce-arg self) (sel_registerName "moveColumn:toColumn:") old-index new-index))
(define (nstableview-move-down! self sender)
  (tell #:type _void (coerce-arg self) moveDown: (coerce-arg sender)))
(define (nstableview-move-down-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveDownAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-forward! self sender)
  (tell #:type _void (coerce-arg self) moveForward: (coerce-arg sender)))
(define (nstableview-move-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveForwardAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-left! self sender)
  (tell #:type _void (coerce-arg self) moveLeft: (coerce-arg sender)))
(define (nstableview-move-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveLeftAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-paragraph-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphBackwardAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-paragraph-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphForwardAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-right! self sender)
  (tell #:type _void (coerce-arg self) moveRight: (coerce-arg sender)))
(define (nstableview-move-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveRightAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-row-at-index-to-index! self old-index new-index)
  (_msg-79 (coerce-arg self) (sel_registerName "moveRowAtIndex:toIndex:") old-index new-index))
(define (nstableview-move-to-beginning-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocument: (coerce-arg sender)))
(define (nstableview-move-to-beginning-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-to-beginning-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLine: (coerce-arg sender)))
(define (nstableview-move-to-beginning-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLineAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-to-beginning-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraph: (coerce-arg sender)))
(define (nstableview-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-to-end-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocument: (coerce-arg sender)))
(define (nstableview-move-to-end-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-to-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLine: (coerce-arg sender)))
(define (nstableview-move-to-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-to-end-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraph: (coerce-arg sender)))
(define (nstableview-move-to-end-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-to-left-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLine: (coerce-arg sender)))
(define (nstableview-move-to-left-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-to-right-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLine: (coerce-arg sender)))
(define (nstableview-move-to-right-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-up! self sender)
  (tell #:type _void (coerce-arg self) moveUp: (coerce-arg sender)))
(define (nstableview-move-up-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveUpAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-word-backward! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackward: (coerce-arg sender)))
(define (nstableview-move-word-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackwardAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-word-forward! self sender)
  (tell #:type _void (coerce-arg self) moveWordForward: (coerce-arg sender)))
(define (nstableview-move-word-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordForwardAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-word-left! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeft: (coerce-arg sender)))
(define (nstableview-move-word-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeftAndModifySelection: (coerce-arg sender)))
(define (nstableview-move-word-right! self sender)
  (tell #:type _void (coerce-arg self) moveWordRight: (coerce-arg sender)))
(define (nstableview-move-word-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordRightAndModifySelection: (coerce-arg sender)))
(define (nstableview-needs-to-draw-rect self rect)
  (_msg-25 (coerce-arg self) (sel_registerName "needsToDrawRect:") rect))
(define (nstableview-no-responder-for self event-selector)
  (_msg-84 (coerce-arg self) (sel_registerName "noResponderFor:") (sel_registerName event-selector)))
(define (nstableview-note-height-of-rows-with-indexes-changed self index-set)
  (tell #:type _void (coerce-arg self) noteHeightOfRowsWithIndexesChanged: (coerce-arg index-set)))
(define (nstableview-note-number-of-rows-changed self)
  (tell #:type _void (coerce-arg self) noteNumberOfRowsChanged))
(define (nstableview-other-mouse-down self event)
  (tell #:type _void (coerce-arg self) otherMouseDown: (coerce-arg event)))
(define (nstableview-other-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) otherMouseDragged: (coerce-arg event)))
(define (nstableview-other-mouse-up self event)
  (tell #:type _void (coerce-arg self) otherMouseUp: (coerce-arg event)))
(define (nstableview-page-down self sender)
  (tell #:type _void (coerce-arg self) pageDown: (coerce-arg sender)))
(define (nstableview-page-down-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageDownAndModifySelection: (coerce-arg sender)))
(define (nstableview-page-up self sender)
  (tell #:type _void (coerce-arg self) pageUp: (coerce-arg sender)))
(define (nstableview-page-up-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageUpAndModifySelection: (coerce-arg sender)))
(define (nstableview-perform-click! self sender)
  (tell #:type _void (coerce-arg self) performClick: (coerce-arg sender)))
(define (nstableview-perform-drag-operation! self sender)
  (_msg-39 (coerce-arg self) (sel_registerName "performDragOperation:") (coerce-arg sender)))
(define (nstableview-perform-key-equivalent! self event)
  (_msg-39 (coerce-arg self) (sel_registerName "performKeyEquivalent:") (coerce-arg event)))
(define (nstableview-prepare-content-in-rect self rect)
  (_msg-27 (coerce-arg self) (sel_registerName "prepareContentInRect:") rect))
(define (nstableview-prepare-for-drag-operation self sender)
  (_msg-39 (coerce-arg self) (sel_registerName "prepareForDragOperation:") (coerce-arg sender)))
(define (nstableview-prepare-for-reuse self)
  (tell #:type _void (coerce-arg self) prepareForReuse))
(define (nstableview-pressure-change-with-event self event)
  (tell #:type _void (coerce-arg self) pressureChangeWithEvent: (coerce-arg event)))
(define (nstableview-quick-look-preview-items self sender)
  (tell #:type _void (coerce-arg self) quickLookPreviewItems: (coerce-arg sender)))
(define (nstableview-quick-look-with-event self event)
  (tell #:type _void (coerce-arg self) quickLookWithEvent: (coerce-arg event)))
(define (nstableview-rect-for-smart-magnification-at-point-in-rect self location visible-rect)
  (_msg-17 (coerce-arg self) (sel_registerName "rectForSmartMagnificationAtPoint:inRect:") location visible-rect))
(define (nstableview-rect-of-column self column)
  (_msg-70 (coerce-arg self) (sel_registerName "rectOfColumn:") column))
(define (nstableview-rect-of-row self row)
  (_msg-70 (coerce-arg self) (sel_registerName "rectOfRow:") row))
(define (nstableview-register-nib-for-identifier self nib identifier)
  (tell #:type _void (coerce-arg self) registerNib: (coerce-arg nib) forIdentifier: (coerce-arg identifier)))
(define (nstableview-reload-data self)
  (tell #:type _void (coerce-arg self) reloadData))
(define (nstableview-reload-data-for-row-indexes-column-indexes self row-indexes column-indexes)
  (tell #:type _void (coerce-arg self) reloadDataForRowIndexes: (coerce-arg row-indexes) columnIndexes: (coerce-arg column-indexes)))
(define (nstableview-remove-all-tool-tips! self)
  (tell #:type _void (coerce-arg self) removeAllToolTips))
(define (nstableview-remove-from-superview! self)
  (tell #:type _void (coerce-arg self) removeFromSuperview))
(define (nstableview-remove-from-superview-without-needing-display! self)
  (tell #:type _void (coerce-arg self) removeFromSuperviewWithoutNeedingDisplay))
(define (nstableview-remove-rows-at-indexes-with-animation! self indexes animation-options)
  (_msg-67 (coerce-arg self) (sel_registerName "removeRowsAtIndexes:withAnimation:") (coerce-arg indexes) animation-options))
(define (nstableview-remove-table-column! self table-column)
  (tell #:type _void (coerce-arg self) removeTableColumn: (coerce-arg table-column)))
(define (nstableview-remove-tool-tip! self tag)
  (_msg-74 (coerce-arg self) (sel_registerName "removeToolTip:") tag))
(define (nstableview-replace-subview-with! self old-view new-view)
  (tell #:type _void (coerce-arg self) replaceSubview: (coerce-arg old-view) with: (coerce-arg new-view)))
(define (nstableview-resign-first-responder self)
  (_msg-4 (coerce-arg self) (sel_registerName "resignFirstResponder")))
(define (nstableview-resize-subviews-with-old-size self old-size)
  (_msg-34 (coerce-arg self) (sel_registerName "resizeSubviewsWithOldSize:") old-size))
(define (nstableview-resize-with-old-superview-size self old-size)
  (_msg-34 (coerce-arg self) (sel_registerName "resizeWithOldSuperviewSize:") old-size))
(define (nstableview-restore-user-activity-state self user-activity)
  (tell #:type _void (coerce-arg self) restoreUserActivityState: (coerce-arg user-activity)))
(define (nstableview-right-mouse-down self event)
  (tell #:type _void (coerce-arg self) rightMouseDown: (coerce-arg event)))
(define (nstableview-right-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) rightMouseDragged: (coerce-arg event)))
(define (nstableview-right-mouse-up self event)
  (tell #:type _void (coerce-arg self) rightMouseUp: (coerce-arg event)))
(define (nstableview-rotate-by-angle self angle)
  (_msg-37 (coerce-arg self) (sel_registerName "rotateByAngle:") angle))
(define (nstableview-rotate-with-event self event)
  (tell #:type _void (coerce-arg self) rotateWithEvent: (coerce-arg event)))
(define (nstableview-row-at-point self point)
  (_msg-15 (coerce-arg self) (sel_registerName "rowAtPoint:") point))
(define (nstableview-row-for-view self view)
  (_msg-40 (coerce-arg self) (sel_registerName "rowForView:") (coerce-arg view)))
(define (nstableview-row-view-at-row-make-if-necessary self row make-if-necessary)
  (wrap-objc-object
   (_msg-76 (coerce-arg self) (sel_registerName "rowViewAtRow:makeIfNecessary:") row make-if-necessary)
   ))
(define (nstableview-rows-in-rect self rect)
  (_msg-23 (coerce-arg self) (sel_registerName "rowsInRect:") rect))
(define (nstableview-scale-unit-square-to-size self new-unit-size)
  (_msg-34 (coerce-arg self) (sel_registerName "scaleUnitSquareToSize:") new-unit-size))
(define (nstableview-scroll-column-to-visible self column)
  (_msg-74 (coerce-arg self) (sel_registerName "scrollColumnToVisible:") column))
(define (nstableview-scroll-line-down self sender)
  (tell #:type _void (coerce-arg self) scrollLineDown: (coerce-arg sender)))
(define (nstableview-scroll-line-up self sender)
  (tell #:type _void (coerce-arg self) scrollLineUp: (coerce-arg sender)))
(define (nstableview-scroll-page-down self sender)
  (tell #:type _void (coerce-arg self) scrollPageDown: (coerce-arg sender)))
(define (nstableview-scroll-page-up self sender)
  (tell #:type _void (coerce-arg self) scrollPageUp: (coerce-arg sender)))
(define (nstableview-scroll-point self point)
  (_msg-16 (coerce-arg self) (sel_registerName "scrollPoint:") point))
(define (nstableview-scroll-rect-to-visible self rect)
  (_msg-25 (coerce-arg self) (sel_registerName "scrollRectToVisible:") rect))
(define (nstableview-scroll-row-to-visible self row)
  (_msg-74 (coerce-arg self) (sel_registerName "scrollRowToVisible:") row))
(define (nstableview-scroll-to-beginning-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToBeginningOfDocument: (coerce-arg sender)))
(define (nstableview-scroll-to-end-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToEndOfDocument: (coerce-arg sender)))
(define (nstableview-scroll-wheel self event)
  (tell #:type _void (coerce-arg self) scrollWheel: (coerce-arg event)))
(define (nstableview-select-all self sender)
  (tell #:type _void (coerce-arg self) selectAll: (coerce-arg sender)))
(define (nstableview-select-column-indexes-by-extending-selection self indexes extend)
  (_msg-50 (coerce-arg self) (sel_registerName "selectColumnIndexes:byExtendingSelection:") (coerce-arg indexes) extend))
(define (nstableview-select-line self sender)
  (tell #:type _void (coerce-arg self) selectLine: (coerce-arg sender)))
(define (nstableview-select-paragraph self sender)
  (tell #:type _void (coerce-arg self) selectParagraph: (coerce-arg sender)))
(define (nstableview-select-row-indexes-by-extending-selection self indexes extend)
  (_msg-50 (coerce-arg self) (sel_registerName "selectRowIndexes:byExtendingSelection:") (coerce-arg indexes) extend))
(define (nstableview-select-to-mark self sender)
  (tell #:type _void (coerce-arg self) selectToMark: (coerce-arg sender)))
(define (nstableview-select-word self sender)
  (tell #:type _void (coerce-arg self) selectWord: (coerce-arg sender)))
(define (nstableview-send-action-to self action target)
  (_msg-85 (coerce-arg self) (sel_registerName "sendAction:to:") (sel_registerName action) (coerce-arg target)))
(define (nstableview-send-action-on self mask)
  (_msg-88 (coerce-arg self) (sel_registerName "sendActionOn:") mask))
(define (nstableview-set-accessibility-activation-point! self accessibility-activation-point)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityActivationPoint:") accessibility-activation-point))
(define (nstableview-set-accessibility-allowed-values! self accessibility-allowed-values)
  (tell #:type _void (coerce-arg self) setAccessibilityAllowedValues: (coerce-arg accessibility-allowed-values)))
(define (nstableview-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (_msg-36 (coerce-arg self) (sel_registerName "setAccessibilityAlternateUIVisible:") accessibility-alternate-ui-visible))
(define (nstableview-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityApplicationFocusedUIElement: (coerce-arg accessibility-application-focused-ui-element)))
(define (nstableview-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityAttributedUserInputLabels: (coerce-arg accessibility-attributed-user-input-labels)))
(define (nstableview-set-accessibility-cancel-button! self accessibility-cancel-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCancelButton: (coerce-arg accessibility-cancel-button)))
(define (nstableview-set-accessibility-children! self accessibility-children)
  (tell #:type _void (coerce-arg self) setAccessibilityChildren: (coerce-arg accessibility-children)))
(define (nstableview-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (tell #:type _void (coerce-arg self) setAccessibilityChildrenInNavigationOrder: (coerce-arg accessibility-children-in-navigation-order)))
(define (nstableview-set-accessibility-clear-button! self accessibility-clear-button)
  (tell #:type _void (coerce-arg self) setAccessibilityClearButton: (coerce-arg accessibility-clear-button)))
(define (nstableview-set-accessibility-close-button! self accessibility-close-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCloseButton: (coerce-arg accessibility-close-button)))
(define (nstableview-set-accessibility-column-count! self accessibility-column-count)
  (_msg-74 (coerce-arg self) (sel_registerName "setAccessibilityColumnCount:") accessibility-column-count))
(define (nstableview-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnHeaderUIElements: (coerce-arg accessibility-column-header-ui-elements)))
(define (nstableview-set-accessibility-column-index-range! self accessibility-column-index-range)
  (_msg-22 (coerce-arg self) (sel_registerName "setAccessibilityColumnIndexRange:") accessibility-column-index-range))
(define (nstableview-set-accessibility-column-titles! self accessibility-column-titles)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnTitles: (coerce-arg accessibility-column-titles)))
(define (nstableview-set-accessibility-columns! self accessibility-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityColumns: (coerce-arg accessibility-columns)))
(define (nstableview-set-accessibility-contents! self accessibility-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityContents: (coerce-arg accessibility-contents)))
(define (nstableview-set-accessibility-critical-value! self accessibility-critical-value)
  (tell #:type _void (coerce-arg self) setAccessibilityCriticalValue: (coerce-arg accessibility-critical-value)))
(define (nstableview-set-accessibility-custom-actions! self accessibility-custom-actions)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomActions: (coerce-arg accessibility-custom-actions)))
(define (nstableview-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomRotors: (coerce-arg accessibility-custom-rotors)))
(define (nstableview-set-accessibility-decrement-button! self accessibility-decrement-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDecrementButton: (coerce-arg accessibility-decrement-button)))
(define (nstableview-set-accessibility-default-button! self accessibility-default-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDefaultButton: (coerce-arg accessibility-default-button)))
(define (nstableview-set-accessibility-disclosed! self accessibility-disclosed)
  (_msg-36 (coerce-arg self) (sel_registerName "setAccessibilityDisclosed:") accessibility-disclosed))
(define (nstableview-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedByRow: (coerce-arg accessibility-disclosed-by-row)))
(define (nstableview-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedRows: (coerce-arg accessibility-disclosed-rows)))
(define (nstableview-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (_msg-74 (coerce-arg self) (sel_registerName "setAccessibilityDisclosureLevel:") accessibility-disclosure-level))
(define (nstableview-set-accessibility-document! self accessibility-document)
  (tell #:type _void (coerce-arg self) setAccessibilityDocument: (coerce-arg accessibility-document)))
(define (nstableview-set-accessibility-edited! self accessibility-edited)
  (_msg-36 (coerce-arg self) (sel_registerName "setAccessibilityEdited:") accessibility-edited))
(define (nstableview-set-accessibility-element! self accessibility-element)
  (_msg-36 (coerce-arg self) (sel_registerName "setAccessibilityElement:") accessibility-element))
(define (nstableview-set-accessibility-enabled! self accessibility-enabled)
  (_msg-36 (coerce-arg self) (sel_registerName "setAccessibilityEnabled:") accessibility-enabled))
(define (nstableview-set-accessibility-expanded! self accessibility-expanded)
  (_msg-36 (coerce-arg self) (sel_registerName "setAccessibilityExpanded:") accessibility-expanded))
(define (nstableview-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityExtrasMenuBar: (coerce-arg accessibility-extras-menu-bar)))
(define (nstableview-set-accessibility-filename! self accessibility-filename)
  (tell #:type _void (coerce-arg self) setAccessibilityFilename: (coerce-arg accessibility-filename)))
(define (nstableview-set-accessibility-focused! self accessibility-focused)
  (_msg-36 (coerce-arg self) (sel_registerName "setAccessibilityFocused:") accessibility-focused))
(define (nstableview-set-accessibility-focused-window! self accessibility-focused-window)
  (tell #:type _void (coerce-arg self) setAccessibilityFocusedWindow: (coerce-arg accessibility-focused-window)))
(define (nstableview-set-accessibility-frame! self accessibility-frame)
  (_msg-27 (coerce-arg self) (sel_registerName "setAccessibilityFrame:") accessibility-frame))
(define (nstableview-set-accessibility-frontmost! self accessibility-frontmost)
  (_msg-36 (coerce-arg self) (sel_registerName "setAccessibilityFrontmost:") accessibility-frontmost))
(define (nstableview-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (tell #:type _void (coerce-arg self) setAccessibilityFullScreenButton: (coerce-arg accessibility-full-screen-button)))
(define (nstableview-set-accessibility-grow-area! self accessibility-grow-area)
  (tell #:type _void (coerce-arg self) setAccessibilityGrowArea: (coerce-arg accessibility-grow-area)))
(define (nstableview-set-accessibility-handles! self accessibility-handles)
  (tell #:type _void (coerce-arg self) setAccessibilityHandles: (coerce-arg accessibility-handles)))
(define (nstableview-set-accessibility-header! self accessibility-header)
  (tell #:type _void (coerce-arg self) setAccessibilityHeader: (coerce-arg accessibility-header)))
(define (nstableview-set-accessibility-help! self accessibility-help)
  (tell #:type _void (coerce-arg self) setAccessibilityHelp: (coerce-arg accessibility-help)))
(define (nstableview-set-accessibility-hidden! self accessibility-hidden)
  (_msg-36 (coerce-arg self) (sel_registerName "setAccessibilityHidden:") accessibility-hidden))
(define (nstableview-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalScrollBar: (coerce-arg accessibility-horizontal-scroll-bar)))
(define (nstableview-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalUnitDescription: (coerce-arg accessibility-horizontal-unit-description)))
(define (nstableview-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (_msg-74 (coerce-arg self) (sel_registerName "setAccessibilityHorizontalUnits:") accessibility-horizontal-units))
(define (nstableview-set-accessibility-identifier! self accessibility-identifier)
  (tell #:type _void (coerce-arg self) setAccessibilityIdentifier: (coerce-arg accessibility-identifier)))
(define (nstableview-set-accessibility-increment-button! self accessibility-increment-button)
  (tell #:type _void (coerce-arg self) setAccessibilityIncrementButton: (coerce-arg accessibility-increment-button)))
(define (nstableview-set-accessibility-index! self accessibility-index)
  (_msg-74 (coerce-arg self) (sel_registerName "setAccessibilityIndex:") accessibility-index))
(define (nstableview-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (_msg-74 (coerce-arg self) (sel_registerName "setAccessibilityInsertionPointLineNumber:") accessibility-insertion-point-line-number))
(define (nstableview-set-accessibility-label! self accessibility-label)
  (tell #:type _void (coerce-arg self) setAccessibilityLabel: (coerce-arg accessibility-label)))
(define (nstableview-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLabelUIElements: (coerce-arg accessibility-label-ui-elements)))
(define (nstableview-set-accessibility-label-value! self accessibility-label-value)
  (_msg-38 (coerce-arg self) (sel_registerName "setAccessibilityLabelValue:") accessibility-label-value))
(define (nstableview-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLinkedUIElements: (coerce-arg accessibility-linked-ui-elements)))
(define (nstableview-set-accessibility-main! self accessibility-main)
  (_msg-36 (coerce-arg self) (sel_registerName "setAccessibilityMain:") accessibility-main))
(define (nstableview-set-accessibility-main-window! self accessibility-main-window)
  (tell #:type _void (coerce-arg self) setAccessibilityMainWindow: (coerce-arg accessibility-main-window)))
(define (nstableview-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerGroupUIElement: (coerce-arg accessibility-marker-group-ui-element)))
(define (nstableview-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerTypeDescription: (coerce-arg accessibility-marker-type-description)))
(define (nstableview-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerUIElements: (coerce-arg accessibility-marker-ui-elements)))
(define (nstableview-set-accessibility-marker-values! self accessibility-marker-values)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerValues: (coerce-arg accessibility-marker-values)))
(define (nstableview-set-accessibility-max-value! self accessibility-max-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMaxValue: (coerce-arg accessibility-max-value)))
(define (nstableview-set-accessibility-menu-bar! self accessibility-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityMenuBar: (coerce-arg accessibility-menu-bar)))
(define (nstableview-set-accessibility-min-value! self accessibility-min-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMinValue: (coerce-arg accessibility-min-value)))
(define (nstableview-set-accessibility-minimize-button! self accessibility-minimize-button)
  (tell #:type _void (coerce-arg self) setAccessibilityMinimizeButton: (coerce-arg accessibility-minimize-button)))
(define (nstableview-set-accessibility-minimized! self accessibility-minimized)
  (_msg-36 (coerce-arg self) (sel_registerName "setAccessibilityMinimized:") accessibility-minimized))
(define (nstableview-set-accessibility-modal! self accessibility-modal)
  (_msg-36 (coerce-arg self) (sel_registerName "setAccessibilityModal:") accessibility-modal))
(define (nstableview-set-accessibility-next-contents! self accessibility-next-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityNextContents: (coerce-arg accessibility-next-contents)))
(define (nstableview-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (_msg-74 (coerce-arg self) (sel_registerName "setAccessibilityNumberOfCharacters:") accessibility-number-of-characters))
(define (nstableview-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (_msg-36 (coerce-arg self) (sel_registerName "setAccessibilityOrderedByRow:") accessibility-ordered-by-row))
(define (nstableview-set-accessibility-orientation! self accessibility-orientation)
  (_msg-74 (coerce-arg self) (sel_registerName "setAccessibilityOrientation:") accessibility-orientation))
(define (nstableview-set-accessibility-overflow-button! self accessibility-overflow-button)
  (tell #:type _void (coerce-arg self) setAccessibilityOverflowButton: (coerce-arg accessibility-overflow-button)))
(define (nstableview-set-accessibility-parent! self accessibility-parent)
  (tell #:type _void (coerce-arg self) setAccessibilityParent: (coerce-arg accessibility-parent)))
(define (nstableview-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (tell #:type _void (coerce-arg self) setAccessibilityPlaceholderValue: (coerce-arg accessibility-placeholder-value)))
(define (nstableview-set-accessibility-previous-contents! self accessibility-previous-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityPreviousContents: (coerce-arg accessibility-previous-contents)))
(define (nstableview-set-accessibility-protected-content! self accessibility-protected-content)
  (_msg-36 (coerce-arg self) (sel_registerName "setAccessibilityProtectedContent:") accessibility-protected-content))
(define (nstableview-set-accessibility-proxy! self accessibility-proxy)
  (tell #:type _void (coerce-arg self) setAccessibilityProxy: (coerce-arg accessibility-proxy)))
(define (nstableview-set-accessibility-required! self accessibility-required)
  (_msg-36 (coerce-arg self) (sel_registerName "setAccessibilityRequired:") accessibility-required))
(define (nstableview-set-accessibility-role! self accessibility-role)
  (tell #:type _void (coerce-arg self) setAccessibilityRole: (coerce-arg accessibility-role)))
(define (nstableview-set-accessibility-role-description! self accessibility-role-description)
  (tell #:type _void (coerce-arg self) setAccessibilityRoleDescription: (coerce-arg accessibility-role-description)))
(define (nstableview-set-accessibility-row-count! self accessibility-row-count)
  (_msg-74 (coerce-arg self) (sel_registerName "setAccessibilityRowCount:") accessibility-row-count))
(define (nstableview-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityRowHeaderUIElements: (coerce-arg accessibility-row-header-ui-elements)))
(define (nstableview-set-accessibility-row-index-range! self accessibility-row-index-range)
  (_msg-22 (coerce-arg self) (sel_registerName "setAccessibilityRowIndexRange:") accessibility-row-index-range))
(define (nstableview-set-accessibility-rows! self accessibility-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityRows: (coerce-arg accessibility-rows)))
(define (nstableview-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (_msg-74 (coerce-arg self) (sel_registerName "setAccessibilityRulerMarkerType:") accessibility-ruler-marker-type))
(define (nstableview-set-accessibility-search-button! self accessibility-search-button)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchButton: (coerce-arg accessibility-search-button)))
(define (nstableview-set-accessibility-search-menu! self accessibility-search-menu)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchMenu: (coerce-arg accessibility-search-menu)))
(define (nstableview-set-accessibility-selected! self accessibility-selected)
  (_msg-36 (coerce-arg self) (sel_registerName "setAccessibilitySelected:") accessibility-selected))
(define (nstableview-set-accessibility-selected-cells! self accessibility-selected-cells)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedCells: (coerce-arg accessibility-selected-cells)))
(define (nstableview-set-accessibility-selected-children! self accessibility-selected-children)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedChildren: (coerce-arg accessibility-selected-children)))
(define (nstableview-set-accessibility-selected-columns! self accessibility-selected-columns)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedColumns: (coerce-arg accessibility-selected-columns)))
(define (nstableview-set-accessibility-selected-rows! self selected-rows)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedRows: (coerce-arg selected-rows)))
(define (nstableview-set-accessibility-selected-text! self accessibility-selected-text)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedText: (coerce-arg accessibility-selected-text)))
(define (nstableview-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (_msg-22 (coerce-arg self) (sel_registerName "setAccessibilitySelectedTextRange:") accessibility-selected-text-range))
(define (nstableview-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedTextRanges: (coerce-arg accessibility-selected-text-ranges)))
(define (nstableview-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityServesAsTitleForUIElements: (coerce-arg accessibility-serves-as-title-for-ui-elements)))
(define (nstableview-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (_msg-22 (coerce-arg self) (sel_registerName "setAccessibilitySharedCharacterRange:") accessibility-shared-character-range))
(define (nstableview-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedFocusElements: (coerce-arg accessibility-shared-focus-elements)))
(define (nstableview-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedTextUIElements: (coerce-arg accessibility-shared-text-ui-elements)))
(define (nstableview-set-accessibility-shown-menu! self accessibility-shown-menu)
  (tell #:type _void (coerce-arg self) setAccessibilityShownMenu: (coerce-arg accessibility-shown-menu)))
(define (nstableview-set-accessibility-sort-direction! self accessibility-sort-direction)
  (_msg-74 (coerce-arg self) (sel_registerName "setAccessibilitySortDirection:") accessibility-sort-direction))
(define (nstableview-set-accessibility-splitters! self accessibility-splitters)
  (tell #:type _void (coerce-arg self) setAccessibilitySplitters: (coerce-arg accessibility-splitters)))
(define (nstableview-set-accessibility-subrole! self accessibility-subrole)
  (tell #:type _void (coerce-arg self) setAccessibilitySubrole: (coerce-arg accessibility-subrole)))
(define (nstableview-set-accessibility-tabs! self accessibility-tabs)
  (tell #:type _void (coerce-arg self) setAccessibilityTabs: (coerce-arg accessibility-tabs)))
(define (nstableview-set-accessibility-title! self accessibility-title)
  (tell #:type _void (coerce-arg self) setAccessibilityTitle: (coerce-arg accessibility-title)))
(define (nstableview-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTitleUIElement: (coerce-arg accessibility-title-ui-element)))
(define (nstableview-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (tell #:type _void (coerce-arg self) setAccessibilityToolbarButton: (coerce-arg accessibility-toolbar-button)))
(define (nstableview-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTopLevelUIElement: (coerce-arg accessibility-top-level-ui-element)))
(define (nstableview-set-accessibility-url! self accessibility-url)
  (tell #:type _void (coerce-arg self) setAccessibilityURL: (coerce-arg accessibility-url)))
(define (nstableview-set-accessibility-unit-description! self accessibility-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityUnitDescription: (coerce-arg accessibility-unit-description)))
(define (nstableview-set-accessibility-units! self accessibility-units)
  (_msg-74 (coerce-arg self) (sel_registerName "setAccessibilityUnits:") accessibility-units))
(define (nstableview-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityUserInputLabels: (coerce-arg accessibility-user-input-labels)))
(define (nstableview-set-accessibility-value! self accessibility-value)
  (tell #:type _void (coerce-arg self) setAccessibilityValue: (coerce-arg accessibility-value)))
(define (nstableview-set-accessibility-value-description! self accessibility-value-description)
  (tell #:type _void (coerce-arg self) setAccessibilityValueDescription: (coerce-arg accessibility-value-description)))
(define (nstableview-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalScrollBar: (coerce-arg accessibility-vertical-scroll-bar)))
(define (nstableview-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalUnitDescription: (coerce-arg accessibility-vertical-unit-description)))
(define (nstableview-set-accessibility-vertical-units! self accessibility-vertical-units)
  (_msg-74 (coerce-arg self) (sel_registerName "setAccessibilityVerticalUnits:") accessibility-vertical-units))
(define (nstableview-set-accessibility-visible-cells! self accessibility-visible-cells)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleCells: (coerce-arg accessibility-visible-cells)))
(define (nstableview-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (_msg-22 (coerce-arg self) (sel_registerName "setAccessibilityVisibleCharacterRange:") accessibility-visible-character-range))
(define (nstableview-set-accessibility-visible-children! self accessibility-visible-children)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleChildren: (coerce-arg accessibility-visible-children)))
(define (nstableview-set-accessibility-visible-columns! self accessibility-visible-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleColumns: (coerce-arg accessibility-visible-columns)))
(define (nstableview-set-accessibility-visible-rows! self accessibility-visible-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleRows: (coerce-arg accessibility-visible-rows)))
(define (nstableview-set-accessibility-warning-value! self accessibility-warning-value)
  (tell #:type _void (coerce-arg self) setAccessibilityWarningValue: (coerce-arg accessibility-warning-value)))
(define (nstableview-set-accessibility-window! self accessibility-window)
  (tell #:type _void (coerce-arg self) setAccessibilityWindow: (coerce-arg accessibility-window)))
(define (nstableview-set-accessibility-windows! self accessibility-windows)
  (tell #:type _void (coerce-arg self) setAccessibilityWindows: (coerce-arg accessibility-windows)))
(define (nstableview-set-accessibility-zoom-button! self accessibility-zoom-button)
  (tell #:type _void (coerce-arg self) setAccessibilityZoomButton: (coerce-arg accessibility-zoom-button)))
(define (nstableview-set-animations! self animations)
  (tell #:type _void (coerce-arg self) setAnimations: (coerce-arg animations)))
(define (nstableview-set-appearance! self appearance)
  (tell #:type _void (coerce-arg self) setAppearance: (coerce-arg appearance)))
(define (nstableview-set-bounds-origin! self new-origin)
  (_msg-16 (coerce-arg self) (sel_registerName "setBoundsOrigin:") new-origin))
(define (nstableview-set-bounds-size! self new-size)
  (_msg-34 (coerce-arg self) (sel_registerName "setBoundsSize:") new-size))
(define (nstableview-set-dragging-source-operation-mask-for-local! self mask is-local)
  (_msg-90 (coerce-arg self) (sel_registerName "setDraggingSourceOperationMask:forLocal:") mask is-local))
(define (nstableview-set-drop-row-drop-operation! self row drop-operation)
  (_msg-82 (coerce-arg self) (sel_registerName "setDropRow:dropOperation:") row drop-operation))
(define (nstableview-set-frame-origin! self new-origin)
  (_msg-16 (coerce-arg self) (sel_registerName "setFrameOrigin:") new-origin))
(define (nstableview-set-frame-size! self new-size)
  (_msg-34 (coerce-arg self) (sel_registerName "setFrameSize:") new-size))
(define (nstableview-set-identifier! self identifier)
  (tell #:type _void (coerce-arg self) setIdentifier: (coerce-arg identifier)))
(define (nstableview-set-indicator-image-in-table-column! self image table-column)
  (tell #:type _void (coerce-arg self) setIndicatorImage: (coerce-arg image) inTableColumn: (coerce-arg table-column)))
(define (nstableview-set-mark! self sender)
  (tell #:type _void (coerce-arg self) setMark: (coerce-arg sender)))
(define (nstableview-set-needs-display-in-rect! self invalid-rect)
  (_msg-27 (coerce-arg self) (sel_registerName "setNeedsDisplayInRect:") invalid-rect))
(define (nstableview-should-be-treated-as-ink-event self event)
  (_msg-39 (coerce-arg self) (sel_registerName "shouldBeTreatedAsInkEvent:") (coerce-arg event)))
(define (nstableview-should-delay-window-ordering-for-event self event)
  (_msg-39 (coerce-arg self) (sel_registerName "shouldDelayWindowOrderingForEvent:") (coerce-arg event)))
(define (nstableview-show-context-help self sender)
  (tell #:type _void (coerce-arg self) showContextHelp: (coerce-arg sender)))
(define (nstableview-show-context-menu-for-selection self sender)
  (tell #:type _void (coerce-arg self) showContextMenuForSelection: (coerce-arg sender)))
(define (nstableview-size-last-column-to-fit self)
  (tell #:type _void (coerce-arg self) sizeLastColumnToFit))
(define (nstableview-size-that-fits self size)
  (_msg-33 (coerce-arg self) (sel_registerName "sizeThatFits:") size))
(define (nstableview-size-to-fit self)
  (tell #:type _void (coerce-arg self) sizeToFit))
(define (nstableview-smart-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) smartMagnifyWithEvent: (coerce-arg event)))
(define (nstableview-sort-subviews-using-function-context self compare context)
  (_msg-87 (coerce-arg self) (sel_registerName "sortSubviewsUsingFunction:context:") compare context))
(define (nstableview-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (_msg-86 (coerce-arg self) (sel_registerName "supplementalTargetForAction:sender:") (sel_registerName action) (coerce-arg sender))
   ))
(define (nstableview-swap-with-mark self sender)
  (tell #:type _void (coerce-arg self) swapWithMark: (coerce-arg sender)))
(define (nstableview-swipe-with-event self event)
  (tell #:type _void (coerce-arg self) swipeWithEvent: (coerce-arg event)))
(define (nstableview-table-column-with-identifier self identifier)
  (wrap-objc-object
   (tell (coerce-arg self) tableColumnWithIdentifier: (coerce-arg identifier))))
(define (nstableview-tablet-point self event)
  (tell #:type _void (coerce-arg self) tabletPoint: (coerce-arg event)))
(define (nstableview-tablet-proximity self event)
  (tell #:type _void (coerce-arg self) tabletProximity: (coerce-arg event)))
(define (nstableview-take-double-value-from self sender)
  (tell #:type _void (coerce-arg self) takeDoubleValueFrom: (coerce-arg sender)))
(define (nstableview-take-float-value-from self sender)
  (tell #:type _void (coerce-arg self) takeFloatValueFrom: (coerce-arg sender)))
(define (nstableview-take-int-value-from self sender)
  (tell #:type _void (coerce-arg self) takeIntValueFrom: (coerce-arg sender)))
(define (nstableview-take-integer-value-from self sender)
  (tell #:type _void (coerce-arg self) takeIntegerValueFrom: (coerce-arg sender)))
(define (nstableview-take-object-value-from self sender)
  (tell #:type _void (coerce-arg self) takeObjectValueFrom: (coerce-arg sender)))
(define (nstableview-take-string-value-from self sender)
  (tell #:type _void (coerce-arg self) takeStringValueFrom: (coerce-arg sender)))
(define (nstableview-text-did-begin-editing self notification)
  (tell #:type _void (coerce-arg self) textDidBeginEditing: (coerce-arg notification)))
(define (nstableview-text-did-change self notification)
  (tell #:type _void (coerce-arg self) textDidChange: (coerce-arg notification)))
(define (nstableview-text-did-end-editing self notification)
  (tell #:type _void (coerce-arg self) textDidEndEditing: (coerce-arg notification)))
(define (nstableview-text-should-begin-editing self text-object)
  (_msg-39 (coerce-arg self) (sel_registerName "textShouldBeginEditing:") (coerce-arg text-object)))
(define (nstableview-text-should-end-editing self text-object)
  (_msg-39 (coerce-arg self) (sel_registerName "textShouldEndEditing:") (coerce-arg text-object)))
(define (nstableview-text-view-url-for-contents-of-text-attachment-at-index self text-view text-attachment char-index)
  (wrap-objc-object
   (_msg-59 (coerce-arg self) (sel_registerName "textView:URLForContentsOfTextAttachment:atIndex:") (coerce-arg text-view) (coerce-arg text-attachment) char-index)
   ))
(define (nstableview-text-view-candidates-for-selected-range self text-view candidates selected-range)
  (wrap-objc-object
   (_msg-51 (coerce-arg self) (sel_registerName "textView:candidates:forSelectedRange:") (coerce-arg text-view) (coerce-arg candidates) selected-range)
   ))
(define (nstableview-text-view-candidates-for-selected-range self text-view selected-range)
  (wrap-objc-object
   (_msg-45 (coerce-arg self) (sel_registerName "textView:candidatesForSelectedRange:") (coerce-arg text-view) selected-range)
   ))
(define (nstableview-text-view-clicked-on-cell-in-rect-at-index self text-view cell cell-frame char-index)
  (_msg-54 (coerce-arg self) (sel_registerName "textView:clickedOnCell:inRect:atIndex:") (coerce-arg text-view) (coerce-arg cell) cell-frame char-index))
(define (nstableview-text-view-clicked-on-link-at-index self text-view link char-index)
  (_msg-58 (coerce-arg self) (sel_registerName "textView:clickedOnLink:atIndex:") (coerce-arg text-view) (coerce-arg link) char-index))
(define (nstableview-text-view-completions-for-partial-word-range-index-of-selected-item self text-view words char-range index)
  (wrap-objc-object
   (_msg-52 (coerce-arg self) (sel_registerName "textView:completions:forPartialWordRange:indexOfSelectedItem:") (coerce-arg text-view) (coerce-arg words) char-range index)
   ))
(define (nstableview-text-view-did-check-text-in-range-types-options-results-orthography-word-count self view range checking-types options results orthography word-count)
  (wrap-objc-object
   (_msg-49 (coerce-arg self) (sel_registerName "textView:didCheckTextInRange:types:options:results:orthography:wordCount:") (coerce-arg view) range checking-types (coerce-arg options) (coerce-arg results) (coerce-arg orthography) word-count)
   ))
(define (nstableview-text-view-do-command-by-selector self text-view command-selector)
  (_msg-65 (coerce-arg self) (sel_registerName "textView:doCommandBySelector:") (coerce-arg text-view) (sel_registerName command-selector)))
(define (nstableview-text-view-double-clicked-on-cell-in-rect-at-index self text-view cell cell-frame char-index)
  (_msg-54 (coerce-arg self) (sel_registerName "textView:doubleClickedOnCell:inRect:atIndex:") (coerce-arg text-view) (coerce-arg cell) cell-frame char-index))
(define (nstableview-text-view-dragged-cell-in-rect-event-at-index self view cell rect event char-index)
  (_msg-53 (coerce-arg self) (sel_registerName "textView:draggedCell:inRect:event:atIndex:") (coerce-arg view) (coerce-arg cell) rect (coerce-arg event) char-index))
(define (nstableview-text-view-menu-for-event-at-index self view menu event char-index)
  (wrap-objc-object
   (_msg-57 (coerce-arg self) (sel_registerName "textView:menu:forEvent:atIndex:") (coerce-arg view) (coerce-arg menu) (coerce-arg event) char-index)
   ))
(define (nstableview-text-view-should-change-text-in-range-replacement-string self text-view affected-char-range replacement-string)
  (_msg-47 (coerce-arg self) (sel_registerName "textView:shouldChangeTextInRange:replacementString:") (coerce-arg text-view) affected-char-range (coerce-arg replacement-string)))
(define (nstableview-text-view-should-change-text-in-ranges-replacement-strings self text-view affected-ranges replacement-strings)
  (_msg-55 (coerce-arg self) (sel_registerName "textView:shouldChangeTextInRanges:replacementStrings:") (coerce-arg text-view) (coerce-arg affected-ranges) (coerce-arg replacement-strings)))
(define (nstableview-text-view-should-change-typing-attributes-to-attributes self text-view old-typing-attributes new-typing-attributes)
  (wrap-objc-object
   (tell (coerce-arg self) textView: (coerce-arg text-view) shouldChangeTypingAttributes: (coerce-arg old-typing-attributes) toAttributes: (coerce-arg new-typing-attributes))))
(define (nstableview-text-view-should-select-candidate-at-index self text-view index)
  (_msg-66 (coerce-arg self) (sel_registerName "textView:shouldSelectCandidateAtIndex:") (coerce-arg text-view) index))
(define (nstableview-text-view-should-set-spelling-state-range self text-view value affected-char-range)
  (_msg-63 (coerce-arg self) (sel_registerName "textView:shouldSetSpellingState:range:") (coerce-arg text-view) value affected-char-range))
(define (nstableview-text-view-should-update-touch-bar-item-identifiers self text-view identifiers)
  (wrap-objc-object
   (tell (coerce-arg self) textView: (coerce-arg text-view) shouldUpdateTouchBarItemIdentifiers: (coerce-arg identifiers))))
(define (nstableview-text-view-will-change-selection-from-character-range-to-character-range self text-view old-selected-char-range new-selected-char-range)
  (_msg-46 (coerce-arg self) (sel_registerName "textView:willChangeSelectionFromCharacterRange:toCharacterRange:") (coerce-arg text-view) old-selected-char-range new-selected-char-range))
(define (nstableview-text-view-will-change-selection-from-character-ranges-to-character-ranges self text-view old-selected-char-ranges new-selected-char-ranges)
  (wrap-objc-object
   (tell (coerce-arg self) textView: (coerce-arg text-view) willChangeSelectionFromCharacterRanges: (coerce-arg old-selected-char-ranges) toCharacterRanges: (coerce-arg new-selected-char-ranges))))
(define (nstableview-text-view-will-check-text-in-range-options-types self view range options checking-types)
  (wrap-objc-object
   (_msg-48 (coerce-arg self) (sel_registerName "textView:willCheckTextInRange:options:types:") (coerce-arg view) range (coerce-arg options) checking-types)
   ))
(define (nstableview-text-view-will-display-tool-tip-for-character-at-index self text-view tooltip character-index)
  (wrap-objc-object
   (_msg-59 (coerce-arg self) (sel_registerName "textView:willDisplayToolTip:forCharacterAtIndex:") (coerce-arg text-view) (coerce-arg tooltip) character-index)
   ))
(define (nstableview-text-view-will-show-sharing-service-picker-for-items self text-view service-picker items)
  (wrap-objc-object
   (tell (coerce-arg self) textView: (coerce-arg text-view) willShowSharingServicePicker: (coerce-arg service-picker) forItems: (coerce-arg items))))
(define (nstableview-text-view-writable-pasteboard-types-for-cell-at-index self view cell char-index)
  (wrap-objc-object
   (_msg-59 (coerce-arg self) (sel_registerName "textView:writablePasteboardTypesForCell:atIndex:") (coerce-arg view) (coerce-arg cell) char-index)
   ))
(define (nstableview-text-view-write-cell-at-index-to-pasteboard-type self view cell char-index pboard type)
  (_msg-60 (coerce-arg self) (sel_registerName "textView:writeCell:atIndex:toPasteboard:type:") (coerce-arg view) (coerce-arg cell) char-index (coerce-arg pboard) (coerce-arg type)))
(define (nstableview-text-view-writing-tools-ignored-ranges-in-enclosing-range self text-view enclosing-range)
  (wrap-objc-object
   (_msg-45 (coerce-arg self) (sel_registerName "textView:writingToolsIgnoredRangesInEnclosingRange:") (coerce-arg text-view) enclosing-range)
   ))
(define (nstableview-text-view-did-change-selection self notification)
  (tell #:type _void (coerce-arg self) textViewDidChangeSelection: (coerce-arg notification)))
(define (nstableview-text-view-did-change-typing-attributes self notification)
  (tell #:type _void (coerce-arg self) textViewDidChangeTypingAttributes: (coerce-arg notification)))
(define (nstableview-text-view-writing-tools-did-end self text-view)
  (tell #:type _void (coerce-arg self) textViewWritingToolsDidEnd: (coerce-arg text-view)))
(define (nstableview-text-view-writing-tools-will-begin self text-view)
  (tell #:type _void (coerce-arg self) textViewWritingToolsWillBegin: (coerce-arg text-view)))
(define (nstableview-tile self)
  (tell #:type _void (coerce-arg self) tile))
(define (nstableview-touches-began-with-event self event)
  (tell #:type _void (coerce-arg self) touchesBeganWithEvent: (coerce-arg event)))
(define (nstableview-touches-cancelled-with-event self event)
  (tell #:type _void (coerce-arg self) touchesCancelledWithEvent: (coerce-arg event)))
(define (nstableview-touches-ended-with-event self event)
  (tell #:type _void (coerce-arg self) touchesEndedWithEvent: (coerce-arg event)))
(define (nstableview-touches-moved-with-event self event)
  (tell #:type _void (coerce-arg self) touchesMovedWithEvent: (coerce-arg event)))
(define (nstableview-translate-origin-to-point self translation)
  (_msg-16 (coerce-arg self) (sel_registerName "translateOriginToPoint:") translation))
(define (nstableview-translate-rects-needing-display-in-rect-by self clip-rect delta)
  (_msg-28 (coerce-arg self) (sel_registerName "translateRectsNeedingDisplayInRect:by:") clip-rect delta))
(define (nstableview-transpose self sender)
  (tell #:type _void (coerce-arg self) transpose: (coerce-arg sender)))
(define (nstableview-transpose-words self sender)
  (tell #:type _void (coerce-arg self) transposeWords: (coerce-arg sender)))
(define (nstableview-try-to-perform-with self action object)
  (_msg-85 (coerce-arg self) (sel_registerName "tryToPerform:with:") (sel_registerName action) (coerce-arg object)))
(define (nstableview-undo-manager-for-text-view self view)
  (wrap-objc-object
   (tell (coerce-arg self) undoManagerForTextView: (coerce-arg view))))
(define (nstableview-unhide-rows-at-indexes-with-animation self indexes row-animation)
  (_msg-67 (coerce-arg self) (sel_registerName "unhideRowsAtIndexes:withAnimation:") (coerce-arg indexes) row-animation))
(define (nstableview-update-dragging-items-for-drag self sender)
  (tell #:type _void (coerce-arg self) updateDraggingItemsForDrag: (coerce-arg sender)))
(define (nstableview-update-layer self)
  (tell #:type _void (coerce-arg self) updateLayer))
(define (nstableview-uppercase-word self sender)
  (tell #:type _void (coerce-arg self) uppercaseWord: (coerce-arg sender)))
(define (nstableview-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (tell (coerce-arg self) validRequestorForSendType: (coerce-arg send-type) returnType: (coerce-arg return-type))))
(define (nstableview-validate-user-interface-item self item)
  (_msg-39 (coerce-arg self) (sel_registerName "validateUserInterfaceItem:") (coerce-arg item)))
(define (nstableview-view-at-column-row-make-if-necessary self column row make-if-necessary)
  (wrap-objc-object
   (_msg-80 (coerce-arg self) (sel_registerName "viewAtColumn:row:makeIfNecessary:") column row make-if-necessary)
   ))
(define (nstableview-view-did-change-backing-properties self)
  (tell #:type _void (coerce-arg self) viewDidChangeBackingProperties))
(define (nstableview-view-did-change-effective-appearance self)
  (tell #:type _void (coerce-arg self) viewDidChangeEffectiveAppearance))
(define (nstableview-view-did-end-live-resize self)
  (tell #:type _void (coerce-arg self) viewDidEndLiveResize))
(define (nstableview-view-did-hide self)
  (tell #:type _void (coerce-arg self) viewDidHide))
(define (nstableview-view-did-move-to-superview self)
  (tell #:type _void (coerce-arg self) viewDidMoveToSuperview))
(define (nstableview-view-did-move-to-window self)
  (tell #:type _void (coerce-arg self) viewDidMoveToWindow))
(define (nstableview-view-did-unhide self)
  (tell #:type _void (coerce-arg self) viewDidUnhide))
(define (nstableview-view-will-draw self)
  (tell #:type _void (coerce-arg self) viewWillDraw))
(define (nstableview-view-will-move-to-superview self new-superview)
  (tell #:type _void (coerce-arg self) viewWillMoveToSuperview: (coerce-arg new-superview)))
(define (nstableview-view-will-move-to-window self new-window)
  (tell #:type _void (coerce-arg self) viewWillMoveToWindow: (coerce-arg new-window)))
(define (nstableview-view-will-start-live-resize self)
  (tell #:type _void (coerce-arg self) viewWillStartLiveResize))
(define (nstableview-view-with-tag self tag)
  (wrap-objc-object
   (_msg-72 (coerce-arg self) (sel_registerName "viewWithTag:") tag)
   ))
(define (nstableview-wants-forwarded-scroll-events-for-axis self axis)
  (_msg-71 (coerce-arg self) (sel_registerName "wantsForwardedScrollEventsForAxis:") axis))
(define (nstableview-wants-periodic-dragging-updates self)
  (_msg-4 (coerce-arg self) (sel_registerName "wantsPeriodicDraggingUpdates")))
(define (nstableview-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (_msg-71 (coerce-arg self) (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:") axis))
(define (nstableview-will-open-menu-with-event self menu event)
  (tell #:type _void (coerce-arg self) willOpenMenu: (coerce-arg menu) withEvent: (coerce-arg event)))
(define (nstableview-will-remove-subview self subview)
  (tell #:type _void (coerce-arg self) willRemoveSubview: (coerce-arg subview)))
(define (nstableview-yank self sender)
  (tell #:type _void (coerce-arg self) yank: (coerce-arg sender)))

;; --- Class methods ---
(define (nstableview-default-animation-for-key key)
  (wrap-objc-object
   (tell NSTableView defaultAnimationForKey: (coerce-arg key))))
(define (nstableview-is-compatible-with-responsive-scrolling)
  (_msg-4 NSTableView (sel_registerName "isCompatibleWithResponsiveScrolling")))
