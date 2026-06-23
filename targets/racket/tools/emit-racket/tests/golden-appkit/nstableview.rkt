#lang racket/base
;; Generated binding for NSTableView (AppKit)
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
(define (calayer? v) (objc-instance-of? v "CALayer"))
(define (cifilter? v) (objc-instance-of? v "CIFilter"))
(define (nsappearance? v) (objc-instance-of? v "NSAppearance"))
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsattributedstring? v) (objc-instance-of? v "NSAttributedString"))
(define (nsbitmapimagerep? v) (objc-instance-of? v "NSBitmapImageRep"))
(define (nscandidatelisttouchbaritem? v) (objc-instance-of? v "NSCandidateListTouchBarItem"))
(define (nscolor? v) (objc-instance-of? v "NSColor"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
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
(define-aw-msg aw_racket_msg_P_q (-> ptr_t ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_P_Q (-> ptr_t ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_b (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PPP_b (-> ptr_t ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PPPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PPPQ_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_PPQ_P (-> ptr_t ptr_t ptr_t ptr_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_PPQ_b (-> ptr_t ptr_t ptr_t ptr_t uint64_t bool_t))
(define-aw-msg aw_racket_msg_PPQPP_b (-> ptr_t ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PPRPQ_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t uint64_t void_t))
(define-aw-msg aw_racket_msg_PPRQ_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t uint64_t void_t))
(define-aw-msg aw_racket_msg_PPG_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PPGP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_Pb_v (-> ptr_t ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_Pq_Q (-> ptr_t ptr_t ptr_t int64_t uint64_t))
(define-aw-msg aw_racket_msg_Pq_v (-> ptr_t ptr_t ptr_t int64_t void_t))
(define-aw-msg aw_racket_msg_PqP_v (-> ptr_t ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PqG_q (-> ptr_t ptr_t ptr_t int64_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_PQ_b (-> ptr_t ptr_t ptr_t uint64_t bool_t))
(define-aw-msg aw_racket_msg_PQ_v (-> ptr_t ptr_t ptr_t uint64_t void_t))
(define-aw-msg aw_racket_msg_PO_b (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PO_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_POQ_v (-> ptr_t ptr_t ptr_t ptr_t uint64_t void_t))
(define-aw-msg aw_racket_msg_PG_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PGP_b (-> ptr_t ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PGPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PGQPPPq_P (-> ptr_t ptr_t ptr_t ptr_t uint64_t ptr_t ptr_t ptr_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_PGG_G (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_b_v (-> ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_i_v (-> ptr_t ptr_t int32_t void_t))
(define-aw-msg aw_racket_msg_q_P (-> ptr_t ptr_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_q_b (-> ptr_t ptr_t int64_t bool_t))
(define-aw-msg aw_racket_msg_q_q (-> ptr_t ptr_t int64_t int64_t))
(define-aw-msg aw_racket_msg_q_R (-> ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_q_G (-> ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_q_v (-> ptr_t ptr_t int64_t void_t))
(define-aw-msg aw_racket_msg_qb_P (-> ptr_t ptr_t int64_t bool_t ptr_t))
(define-aw-msg aw_racket_msg_qq_P (-> ptr_t ptr_t int64_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_qq_R (-> ptr_t ptr_t int64_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_qq_v (-> ptr_t ptr_t int64_t int64_t void_t))
(define-aw-msg aw_racket_msg_qqPb_v (-> ptr_t ptr_t int64_t int64_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_qqb_P (-> ptr_t ptr_t int64_t int64_t bool_t ptr_t))
(define-aw-msg aw_racket_msg_qQ_v (-> ptr_t ptr_t int64_t uint64_t void_t))
(define-aw-msg aw_racket_msg_qR_v (-> ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_Q_q (-> ptr_t ptr_t uint64_t int64_t))
(define-aw-msg aw_racket_msg_Q_v (-> ptr_t ptr_t uint64_t void_t))
(define-aw-msg aw_racket_msg_Qb_v (-> ptr_t ptr_t uint64_t bool_t void_t))
(define-aw-msg aw_racket_msg_f_v (-> ptr_t ptr_t float_t void_t))
(define-aw-msg aw_racket_msg_d_v (-> ptr_t ptr_t double_t void_t))
(define-aw-msg aw_racket_msg_R_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_R_b (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_R_R (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_R_G (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_R_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RP_R (-> ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RPP_q (-> ptr_t ptr_t ptr_t ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_RQ_R (-> ptr_t ptr_t ptr_t uint64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RZ_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_O_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_O_q (-> ptr_t ptr_t ptr_t int64_t))
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
(define (make-nstableview-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSTableView alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nstableview-init-with-frame frame-rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (tell NSTableView alloc)) (id->ffi2-ptr (sel_registerName "initWithFrame:")) (id->ffi2-ptr frame-rect)))
   #:retained #t))


;; --- Properties ---
(define (nstableview-accepts-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsFirstResponder"))))
(define (nstableview-accepts-touch-events self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsTouchEvents"))))
(define (nstableview-set-accepts-touch-events! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAcceptsTouchEvents:")) value))
(define (nstableview-action self)
  (ptr_t->cpointer (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "action")))))
(define (nstableview-set-action! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAction:")) (id->ffi2-ptr (sel_registerName value))))
(define (nstableview-additional-safe-area-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "additionalSafeAreaInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nstableview-set-additional-safe-area-insets! self value)
  (aw_racket_msg_E_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAdditionalSafeAreaInsets:")) (id->ffi2-ptr value)))
(define (nstableview-alignment self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignment"))))
(define (nstableview-set-alignment! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlignment:")) value))
(define (nstableview-alignment-rect-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignmentRectInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nstableview-allowed-touch-types self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowedTouchTypes"))))
(define (nstableview-set-allowed-touch-types! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowedTouchTypes:")) value))
(define (nstableview-allows-column-reordering self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsColumnReordering"))))
(define (nstableview-set-allows-column-reordering! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsColumnReordering:")) value))
(define (nstableview-allows-column-resizing self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsColumnResizing"))))
(define (nstableview-set-allows-column-resizing! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsColumnResizing:")) value))
(define (nstableview-allows-column-selection self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsColumnSelection"))))
(define (nstableview-set-allows-column-selection! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsColumnSelection:")) value))
(define (nstableview-allows-empty-selection self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsEmptySelection"))))
(define (nstableview-set-allows-empty-selection! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsEmptySelection:")) value))
(define (nstableview-allows-expansion-tool-tips self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsExpansionToolTips"))))
(define (nstableview-set-allows-expansion-tool-tips! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsExpansionToolTips:")) value))
(define (nstableview-allows-multiple-selection self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsMultipleSelection"))))
(define (nstableview-set-allows-multiple-selection! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsMultipleSelection:")) value))
(define (nstableview-allows-type-select self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsTypeSelect"))))
(define (nstableview-set-allows-type-select! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsTypeSelect:")) value))
(define (nstableview-allows-vibrancy self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsVibrancy"))))
(define (nstableview-alpha-value self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alphaValue"))))
(define (nstableview-set-alpha-value! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlphaValue:")) value))
(define (nstableview-attributed-string-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "attributedStringValue"))))))
(define (nstableview-set-attributed-string-value! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAttributedStringValue:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-autoresizes-subviews self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoresizesSubviews"))))
(define (nstableview-set-autoresizes-subviews! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutoresizesSubviews:")) value))
(define (nstableview-autoresizing-mask self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoresizingMask"))))
(define (nstableview-set-autoresizing-mask! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutoresizingMask:")) value))
(define (nstableview-autosave-name self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autosaveName"))))))
(define (nstableview-set-autosave-name! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutosaveName:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-autosave-table-columns self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autosaveTableColumns"))))
(define (nstableview-set-autosave-table-columns! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutosaveTableColumns:")) value))
(define (nstableview-background-color self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backgroundColor"))))))
(define (nstableview-set-background-color! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBackgroundColor:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-background-filters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backgroundFilters"))))))
(define (nstableview-set-background-filters! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBackgroundFilters:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-base-writing-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "baseWritingDirection"))))
(define (nstableview-set-base-writing-direction! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBaseWritingDirection:")) value))
(define (nstableview-baseline-offset-from-bottom self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "baselineOffsetFromBottom"))))
(define (nstableview-bottom-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bottomAnchor"))))))
(define (nstableview-bounds self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bounds")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-set-bounds! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBounds:")) (id->ffi2-ptr value)))
(define (nstableview-bounds-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "boundsRotation"))))
(define (nstableview-set-bounds-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsRotation:")) value))
(define (nstableview-can-become-key-view self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canBecomeKeyView"))))
(define (nstableview-can-draw self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDraw"))))
(define (nstableview-can-draw-concurrently self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDrawConcurrently"))))
(define (nstableview-set-can-draw-concurrently! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCanDrawConcurrently:")) value))
(define (nstableview-can-draw-subviews-into-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDrawSubviewsIntoLayer"))))
(define (nstableview-set-can-draw-subviews-into-layer! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCanDrawSubviewsIntoLayer:")) value))
(define (nstableview-candidate-list-touch-bar-item self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "candidateListTouchBarItem"))))))
(define (nstableview-cell self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cell"))))))
(define (nstableview-set-cell! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCell:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-cell-class)
  (ptr_t->cpointer (aw_racket_msg_0_P (id->ffi2-ptr NSTableView) (id->ffi2-ptr (sel_registerName "cellClass")))))
(define (nstableview-set-cell-class! value)
  (aw_racket_msg_P_v (id->ffi2-ptr NSTableView) (id->ffi2-ptr (sel_registerName "setCellClass:")) (id->ffi2-ptr value)))
(define (nstableview-center-x-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerXAnchor"))))))
(define (nstableview-center-y-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerYAnchor"))))))
(define (nstableview-clicked-column self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "clickedColumn"))))
(define (nstableview-clicked-row self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "clickedRow"))))
(define (nstableview-clips-to-bounds self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "clipsToBounds"))))
(define (nstableview-set-clips-to-bounds! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setClipsToBounds:")) value))
(define (nstableview-column-autoresizing-style self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "columnAutoresizingStyle"))))
(define (nstableview-set-column-autoresizing-style! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setColumnAutoresizingStyle:")) value))
(define (nstableview-compatible-with-responsive-scrolling)
  (aw_racket_msg_0_b (id->ffi2-ptr NSTableView) (id->ffi2-ptr (sel_registerName "compatibleWithResponsiveScrolling"))))
(define (nstableview-compositing-filter self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "compositingFilter"))))))
(define (nstableview-set-compositing-filter! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCompositingFilter:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-constraints self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "constraints"))))))
(define (nstableview-content-filters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentFilters"))))))
(define (nstableview-set-content-filters! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentFilters:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-continuous self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "continuous"))))
(define (nstableview-set-continuous! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContinuous:")) value))
(define (nstableview-control-size self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "controlSize"))))
(define (nstableview-set-control-size! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setControlSize:")) value))
(define (nstableview-corner-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cornerView"))))))
(define (nstableview-set-corner-view! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCornerView:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-data-source self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dataSource"))))))
(define (nstableview-set-data-source! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDataSource:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-default-focus-ring-type)
  (aw_racket_msg_0_Q (id->ffi2-ptr NSTableView) (id->ffi2-ptr (sel_registerName "defaultFocusRingType"))))
(define (nstableview-default-menu)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSTableView) (id->ffi2-ptr (sel_registerName "defaultMenu"))))))
(define (nstableview-delegate self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "delegate"))))))
(define (nstableview-set-delegate! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDelegate:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-double-action self)
  (ptr_t->cpointer (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "doubleAction")))))
(define (nstableview-set-double-action! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDoubleAction:")) (id->ffi2-ptr (sel_registerName value))))
(define (nstableview-double-value self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "doubleValue"))))
(define (nstableview-set-double-value! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDoubleValue:")) value))
(define (nstableview-dragging-destination-feedback-style self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingDestinationFeedbackStyle"))))
(define (nstableview-set-dragging-destination-feedback-style! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDraggingDestinationFeedbackStyle:")) value))
(define (nstableview-drawing-find-indicator self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawingFindIndicator"))))
(define (nstableview-edited-column self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "editedColumn"))))
(define (nstableview-edited-row self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "editedRow"))))
(define (nstableview-effective-row-size-style self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "effectiveRowSizeStyle"))))
(define (nstableview-effective-style self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "effectiveStyle"))))
(define (nstableview-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enabled"))))
(define (nstableview-set-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setEnabled:")) value))
(define (nstableview-enclosing-menu-item self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enclosingMenuItem"))))))
(define (nstableview-enclosing-scroll-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enclosingScrollView"))))))
(define (nstableview-first-baseline-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstBaselineAnchor"))))))
(define (nstableview-first-baseline-offset-from-top self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstBaselineOffsetFromTop"))))
(define (nstableview-fitting-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fittingSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstableview-flipped self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flipped"))))
(define (nstableview-float-value self)
  (aw_racket_msg_0_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "floatValue"))))
(define (nstableview-set-float-value! self value)
  (aw_racket_msg_f_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFloatValue:")) value))
(define (nstableview-floats-group-rows self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "floatsGroupRows"))))
(define (nstableview-set-floats-group-rows! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFloatsGroupRows:")) value))
(define (nstableview-focus-ring-mask-bounds self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "focusRingMaskBounds")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-focus-ring-type self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "focusRingType"))))
(define (nstableview-set-focus-ring-type! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFocusRingType:")) value))
(define (nstableview-focus-view)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSTableView) (id->ffi2-ptr (sel_registerName "focusView"))))))
(define (nstableview-font self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "font"))))))
(define (nstableview-set-font! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFont:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-formatter self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "formatter"))))))
(define (nstableview-set-formatter! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFormatter:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-set-frame! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrame:")) (id->ffi2-ptr value)))
(define (nstableview-frame-center-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameCenterRotation"))))
(define (nstableview-set-frame-center-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameCenterRotation:")) value))
(define (nstableview-frame-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameRotation"))))
(define (nstableview-set-frame-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameRotation:")) value))
(define (nstableview-gesture-recognizers self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "gestureRecognizers"))))))
(define (nstableview-set-gesture-recognizers! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setGestureRecognizers:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-grid-color self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "gridColor"))))))
(define (nstableview-set-grid-color! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setGridColor:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-grid-style-mask self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "gridStyleMask"))))
(define (nstableview-set-grid-style-mask! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setGridStyleMask:")) value))
(define (nstableview-has-ambiguous-layout self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasAmbiguousLayout"))))
(define (nstableview-header-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "headerView"))))))
(define (nstableview-set-header-view! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHeaderView:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-height-adjust-limit self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "heightAdjustLimit"))))
(define (nstableview-height-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "heightAnchor"))))))
(define (nstableview-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hidden"))))
(define (nstableview-set-hidden! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHidden:")) value))
(define (nstableview-hidden-or-has-hidden-ancestor self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hiddenOrHasHiddenAncestor"))))
(define (nstableview-hidden-row-indexes self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hiddenRowIndexes"))))))
(define (nstableview-highlighted self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "highlighted"))))
(define (nstableview-set-highlighted! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHighlighted:")) value))
(define (nstableview-highlighted-table-column self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "highlightedTableColumn"))))))
(define (nstableview-set-highlighted-table-column! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHighlightedTableColumn:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-horizontal-content-size-constraint-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "horizontalContentSizeConstraintActive"))))
(define (nstableview-set-horizontal-content-size-constraint-active! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHorizontalContentSizeConstraintActive:")) value))
(define (nstableview-ignores-multi-click self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "ignoresMultiClick"))))
(define (nstableview-set-ignores-multi-click! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIgnoresMultiClick:")) value))
(define (nstableview-in-full-screen-mode self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inFullScreenMode"))))
(define (nstableview-in-live-resize self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inLiveResize"))))
(define (nstableview-input-context self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inputContext"))))))
(define (nstableview-int-value self)
  (aw_racket_msg_0_i (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "intValue"))))
(define (nstableview-set-int-value! self value)
  (aw_racket_msg_i_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIntValue:")) value))
(define (nstableview-integer-value self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "integerValue"))))
(define (nstableview-set-integer-value! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIntegerValue:")) value))
(define (nstableview-intercell-spacing self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "intercellSpacing")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstableview-set-intercell-spacing! self value)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIntercellSpacing:")) (id->ffi2-ptr value)))
(define (nstableview-intrinsic-content-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "intrinsicContentSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstableview-last-baseline-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastBaselineAnchor"))))))
(define (nstableview-last-baseline-offset-from-bottom self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastBaselineOffsetFromBottom"))))
(define (nstableview-layer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layer"))))))
(define (nstableview-set-layer! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayer:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-layer-contents-placement self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerContentsPlacement"))))
(define (nstableview-set-layer-contents-placement! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerContentsPlacement:")) value))
(define (nstableview-layer-contents-redraw-policy self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerContentsRedrawPolicy"))))
(define (nstableview-set-layer-contents-redraw-policy! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerContentsRedrawPolicy:")) value))
(define (nstableview-layer-uses-core-image-filters self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerUsesCoreImageFilters"))))
(define (nstableview-set-layer-uses-core-image-filters! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerUsesCoreImageFilters:")) value))
(define (nstableview-layout-guides self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutGuides"))))))
(define (nstableview-layout-margins-guide self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutMarginsGuide"))))))
(define (nstableview-leading-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "leadingAnchor"))))))
(define (nstableview-left-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "leftAnchor"))))))
(define (nstableview-line-break-mode self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lineBreakMode"))))
(define (nstableview-set-line-break-mode! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLineBreakMode:")) value))
(define (nstableview-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menu"))))))
(define (nstableview-set-menu! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMenu:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-mouse-down-can-move-window self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDownCanMoveWindow"))))
(define (nstableview-needs-display self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsDisplay"))))
(define (nstableview-set-needs-display! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsDisplay:")) value))
(define (nstableview-needs-layout self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsLayout"))))
(define (nstableview-set-needs-layout! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsLayout:")) value))
(define (nstableview-needs-panel-to-become-key self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsPanelToBecomeKey"))))
(define (nstableview-needs-update-constraints self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsUpdateConstraints"))))
(define (nstableview-set-needs-update-constraints! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsUpdateConstraints:")) value))
(define (nstableview-next-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextKeyView"))))))
(define (nstableview-set-next-key-view! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextKeyView:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-next-responder self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextResponder"))))))
(define (nstableview-set-next-responder! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextResponder:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-next-valid-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextValidKeyView"))))))
(define (nstableview-number-of-columns self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "numberOfColumns"))))
(define (nstableview-number-of-rows self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "numberOfRows"))))
(define (nstableview-number-of-selected-columns self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "numberOfSelectedColumns"))))
(define (nstableview-number-of-selected-rows self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "numberOfSelectedRows"))))
(define (nstableview-object-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "objectValue"))))))
(define (nstableview-set-object-value! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setObjectValue:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-opaque self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "opaque"))))
(define (nstableview-opaque-ancestor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "opaqueAncestor"))))))
(define (nstableview-page-footer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageFooter"))))))
(define (nstableview-page-header self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageHeader"))))))
(define (nstableview-posts-bounds-changed-notifications self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "postsBoundsChangedNotifications"))))
(define (nstableview-set-posts-bounds-changed-notifications! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPostsBoundsChangedNotifications:")) value))
(define (nstableview-posts-frame-changed-notifications self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "postsFrameChangedNotifications"))))
(define (nstableview-set-posts-frame-changed-notifications! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPostsFrameChangedNotifications:")) value))
(define (nstableview-prefers-compact-control-size-metrics self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prefersCompactControlSizeMetrics"))))
(define (nstableview-set-prefers-compact-control-size-metrics! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPrefersCompactControlSizeMetrics:")) value))
(define (nstableview-prepared-content-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preparedContentRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-set-prepared-content-rect! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPreparedContentRect:")) (id->ffi2-ptr value)))
(define (nstableview-preserves-content-during-live-resize self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preservesContentDuringLiveResize"))))
(define (nstableview-pressure-configuration self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pressureConfiguration"))))))
(define (nstableview-set-pressure-configuration! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPressureConfiguration:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-previous-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "previousKeyView"))))))
(define (nstableview-previous-valid-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "previousValidKeyView"))))))
(define (nstableview-print-job-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "printJobTitle"))))))
(define (nstableview-rect-preserved-during-live-resize self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectPreservedDuringLiveResize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-refuses-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "refusesFirstResponder"))))
(define (nstableview-set-refuses-first-responder! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setRefusesFirstResponder:")) value))
(define (nstableview-registered-dragged-types self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "registeredDraggedTypes"))))))
(define (nstableview-registered-nibs-by-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "registeredNibsByIdentifier"))))))
(define (nstableview-requires-constraint-based-layout)
  (aw_racket_msg_0_b (id->ffi2-ptr NSTableView) (id->ffi2-ptr (sel_registerName "requiresConstraintBasedLayout"))))
(define (nstableview-restorable-state-key-paths)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSTableView) (id->ffi2-ptr (sel_registerName "restorableStateKeyPaths"))))))
(define (nstableview-right-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightAnchor"))))))
(define (nstableview-rotated-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotatedFromBase"))))
(define (nstableview-rotated-or-scaled-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotatedOrScaledFromBase"))))
(define (nstableview-row-actions-visible self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rowActionsVisible"))))
(define (nstableview-set-row-actions-visible! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setRowActionsVisible:")) value))
(define (nstableview-row-height self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rowHeight"))))
(define (nstableview-set-row-height! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setRowHeight:")) value))
(define (nstableview-row-size-style self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rowSizeStyle"))))
(define (nstableview-set-row-size-style! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setRowSizeStyle:")) value))
(define (nstableview-safe-area-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nstableview-safe-area-layout-guide self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaLayoutGuide"))))))
(define (nstableview-safe-area-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-selected-column self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectedColumn"))))
(define (nstableview-selected-column-indexes self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectedColumnIndexes"))))))
(define (nstableview-selected-row self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectedRow"))))
(define (nstableview-selected-row-indexes self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectedRowIndexes"))))))
(define (nstableview-selection-highlight-style self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectionHighlightStyle"))))
(define (nstableview-set-selection-highlight-style! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSelectionHighlightStyle:")) value))
(define (nstableview-shadow self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shadow"))))))
(define (nstableview-set-shadow! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShadow:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-sort-descriptors self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sortDescriptors"))))))
(define (nstableview-set-sort-descriptors! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSortDescriptors:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-string-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringValue"))))))
(define (nstableview-set-string-value! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setStringValue:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-style self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "style"))))
(define (nstableview-set-style! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setStyle:")) value))
(define (nstableview-subviews self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "subviews"))))))
(define (nstableview-set-subviews! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSubviews:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-superview self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "superview"))))))
(define (nstableview-table-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tableColumns"))))))
(define (nstableview-tag self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tag"))))
(define (nstableview-set-tag! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTag:")) value))
(define (nstableview-target self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "target"))))))
(define (nstableview-set-target! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTarget:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-tool-tip self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "toolTip"))))))
(define (nstableview-set-tool-tip! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setToolTip:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-top-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "topAnchor"))))))
(define (nstableview-touch-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchBar"))))))
(define (nstableview-set-touch-bar! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTouchBar:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-tracking-areas self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "trackingAreas"))))))
(define (nstableview-trailing-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "trailingAnchor"))))))
(define (nstableview-translates-autoresizing-mask-into-constraints self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translatesAutoresizingMaskIntoConstraints"))))
(define (nstableview-set-translates-autoresizing-mask-into-constraints! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTranslatesAutoresizingMaskIntoConstraints:")) value))
(define (nstableview-undo-manager self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "undoManager"))))))
(define (nstableview-user-activity self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userActivity"))))))
(define (nstableview-set-user-activity! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserActivity:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstableview-user-interface-layout-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userInterfaceLayoutDirection"))))
(define (nstableview-set-user-interface-layout-direction! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserInterfaceLayoutDirection:")) value))
(define (nstableview-uses-alternating-row-background-colors self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "usesAlternatingRowBackgroundColors"))))
(define (nstableview-set-uses-alternating-row-background-colors! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUsesAlternatingRowBackgroundColors:")) value))
(define (nstableview-uses-automatic-row-heights self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "usesAutomaticRowHeights"))))
(define (nstableview-set-uses-automatic-row-heights! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUsesAutomaticRowHeights:")) value))
(define (nstableview-uses-single-line-mode self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "usesSingleLineMode"))))
(define (nstableview-set-uses-single-line-mode! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUsesSingleLineMode:")) value))
(define (nstableview-uses-static-contents self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "usesStaticContents"))))
(define (nstableview-set-uses-static-contents! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUsesStaticContents:")) value))
(define (nstableview-vertical-content-size-constraint-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "verticalContentSizeConstraintActive"))))
(define (nstableview-set-vertical-content-size-constraint-active! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setVerticalContentSizeConstraintActive:")) value))
(define (nstableview-vertical-motion-can-begin-drag self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "verticalMotionCanBeginDrag"))))
(define (nstableview-set-vertical-motion-can-begin-drag! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setVerticalMotionCanBeginDrag:")) value))
(define (nstableview-visible-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "visibleRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-wants-best-resolution-open-gl-surface self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsBestResolutionOpenGLSurface"))))
(define (nstableview-set-wants-best-resolution-open-gl-surface! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsBestResolutionOpenGLSurface:")) value))
(define (nstableview-wants-default-clipping self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsDefaultClipping"))))
(define (nstableview-wants-extended-dynamic-range-open-gl-surface self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsExtendedDynamicRangeOpenGLSurface"))))
(define (nstableview-set-wants-extended-dynamic-range-open-gl-surface! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsExtendedDynamicRangeOpenGLSurface:")) value))
(define (nstableview-wants-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsLayer"))))
(define (nstableview-set-wants-layer! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsLayer:")) value))
(define (nstableview-wants-resting-touches self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsRestingTouches"))))
(define (nstableview-set-wants-resting-touches! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsRestingTouches:")) value))
(define (nstableview-wants-update-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsUpdateLayer"))))
(define (nstableview-width-adjust-limit self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "widthAdjustLimit"))))
(define (nstableview-width-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "widthAnchor"))))))
(define (nstableview-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "window"))))))
(define (nstableview-writing-tools-coordinator self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writingToolsCoordinator"))))))
(define (nstableview-set-writing-tools-coordinator! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWritingToolsCoordinator:")) (id->ffi2-ptr (coerce-arg value))))

;; --- Instance methods ---
(define (nstableview-accepts-first-mouse self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsFirstMouse:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-accessibility-activation-point self)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_0_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityActivationPoint")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstableview-accessibility-allowed-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAllowedValues"))))
   ))
(define (nstableview-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityApplicationFocusedUIElement"))))
   ))
(define (nstableview-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nstableview-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedUserInputLabels"))))
   ))
(define (nstableview-accessibility-cancel-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCancelButton"))))
   ))
(define (nstableview-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_qq_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCellForColumn:row:")) column row))
   ))
(define (nstableview-accessibility-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildren"))))
   ))
(define (nstableview-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildrenInNavigationOrder"))))
   ))
(define (nstableview-accessibility-clear-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityClearButton"))))
   ))
(define (nstableview-accessibility-close-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCloseButton"))))
   ))
(define (nstableview-accessibility-column-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnCount"))))
(define (nstableview-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnHeaderUIElements"))))
   ))
(define (nstableview-accessibility-column-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstableview-accessibility-column-titles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnTitles"))))
   ))
(define (nstableview-accessibility-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumns"))))
   ))
(define (nstableview-accessibility-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityContents"))))
   ))
(define (nstableview-accessibility-critical-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCriticalValue"))))
   ))
(define (nstableview-accessibility-custom-actions self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomActions"))))
   ))
(define (nstableview-accessibility-custom-rotors self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomRotors"))))
   ))
(define (nstableview-accessibility-decrement-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDecrementButton"))))
   ))
(define (nstableview-accessibility-default-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDefaultButton"))))
   ))
(define (nstableview-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedByRow"))))
   ))
(define (nstableview-accessibility-disclosed-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedRows"))))
   ))
(define (nstableview-accessibility-disclosure-level self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosureLevel"))))
(define (nstableview-accessibility-document self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDocument"))))
   ))
(define (nstableview-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityExtrasMenuBar"))))
   ))
(define (nstableview-accessibility-filename self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFilename"))))
   ))
(define (nstableview-accessibility-focused-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFocusedWindow"))))
   ))
(define (nstableview-accessibility-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-accessibility-frame-for-range self range)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_G_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrameForRange:")) (id->ffi2-ptr range) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-accessibility-full-screen-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFullScreenButton"))))
   ))
(define (nstableview-accessibility-grow-area self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityGrowArea"))))
   ))
(define (nstableview-accessibility-handles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHandles"))))
   ))
(define (nstableview-accessibility-header self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHeader"))))
   ))
(define (nstableview-accessibility-help self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHelp"))))
   ))
(define (nstableview-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalScrollBar"))))
   ))
(define (nstableview-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnitDescription"))))
   ))
(define (nstableview-accessibility-horizontal-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnits"))))
(define (nstableview-accessibility-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIdentifier"))))
   ))
(define (nstableview-accessibility-increment-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIncrementButton"))))
   ))
(define (nstableview-accessibility-index self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIndex"))))
(define (nstableview-accessibility-insertion-point-line-number self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityInsertionPointLineNumber"))))
(define (nstableview-accessibility-label self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabel"))))
   ))
(define (nstableview-accessibility-label-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelUIElements"))))
   ))
(define (nstableview-accessibility-label-value self)
  (aw_racket_msg_0_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelValue"))))
(define (nstableview-accessibility-layout-point-for-screen-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutPointForScreenPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstableview-accessibility-layout-size-for-screen-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutSizeForScreenSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstableview-accessibility-line-for-index self index)
  (aw_racket_msg_q_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLineForIndex:")) index))
(define (nstableview-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLinkedUIElements"))))
   ))
(define (nstableview-accessibility-main-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMainWindow"))))
   ))
(define (nstableview-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerGroupUIElement"))))
   ))
(define (nstableview-accessibility-marker-type-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerTypeDescription"))))
   ))
(define (nstableview-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerUIElements"))))
   ))
(define (nstableview-accessibility-marker-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerValues"))))
   ))
(define (nstableview-accessibility-max-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMaxValue"))))
   ))
(define (nstableview-accessibility-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMenuBar"))))
   ))
(define (nstableview-accessibility-min-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinValue"))))
   ))
(define (nstableview-accessibility-minimize-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinimizeButton"))))
   ))
(define (nstableview-accessibility-next-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNextContents"))))
   ))
(define (nstableview-accessibility-number-of-characters self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNumberOfCharacters"))))
(define (nstableview-accessibility-orientation self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOrientation"))))
(define (nstableview-accessibility-overflow-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOverflowButton"))))
   ))
(define (nstableview-accessibility-parent self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityParent"))))
   ))
(define (nstableview-accessibility-perform-cancel self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformCancel"))))
(define (nstableview-accessibility-perform-confirm self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformConfirm"))))
(define (nstableview-accessibility-perform-decrement self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDecrement"))))
(define (nstableview-accessibility-perform-delete self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDelete"))))
(define (nstableview-accessibility-perform-increment self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformIncrement"))))
(define (nstableview-accessibility-perform-pick self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPick"))))
(define (nstableview-accessibility-perform-press self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPress"))))
(define (nstableview-accessibility-perform-raise self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformRaise"))))
(define (nstableview-accessibility-perform-show-alternate-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowAlternateUI"))))
(define (nstableview-accessibility-perform-show-default-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowDefaultUI"))))
(define (nstableview-accessibility-perform-show-menu self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowMenu"))))
(define (nstableview-accessibility-placeholder-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPlaceholderValue"))))
   ))
(define (nstableview-accessibility-previous-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPreviousContents"))))
   ))
(define (nstableview-accessibility-proxy self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityProxy"))))
   ))
(define (nstableview-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRTFForRange:")) (id->ffi2-ptr range)))
   ))
(define (nstableview-accessibility-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstableview-accessibility-range-for-line self line)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForLine:")) line (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstableview-accessibility-range-for-position self point)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_O_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForPosition:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstableview-accessibility-role self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRole"))))
   ))
(define (nstableview-accessibility-role-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRoleDescription"))))
   ))
(define (nstableview-accessibility-row-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowCount"))))
(define (nstableview-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowHeaderUIElements"))))
   ))
(define (nstableview-accessibility-row-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstableview-accessibility-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRows"))))
   ))
(define (nstableview-accessibility-ruler-marker-type self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRulerMarkerType"))))
(define (nstableview-accessibility-screen-point-for-layout-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenPointForLayoutPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstableview-accessibility-screen-size-for-layout-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenSizeForLayoutSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstableview-accessibility-search-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchButton"))))
   ))
(define (nstableview-accessibility-search-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchMenu"))))
   ))
(define (nstableview-accessibility-selected-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedCells"))))
   ))
(define (nstableview-accessibility-selected-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedChildren"))))
   ))
(define (nstableview-accessibility-selected-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedColumns"))))
   ))
(define (nstableview-accessibility-selected-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedRows"))))
   ))
(define (nstableview-accessibility-selected-text self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedText"))))
   ))
(define (nstableview-accessibility-selected-text-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstableview-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRanges"))))
   ))
(define (nstableview-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityServesAsTitleForUIElements"))))
   ))
(define (nstableview-accessibility-shared-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstableview-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedFocusElements"))))
   ))
(define (nstableview-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedTextUIElements"))))
   ))
(define (nstableview-accessibility-shown-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityShownMenu"))))
   ))
(define (nstableview-accessibility-sort-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySortDirection"))))
(define (nstableview-accessibility-splitters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySplitters"))))
   ))
(define (nstableview-accessibility-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nstableview-accessibility-style-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStyleRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstableview-accessibility-subrole self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySubrole"))))
   ))
(define (nstableview-accessibility-tabs self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTabs"))))
   ))
(define (nstableview-accessibility-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitle"))))
   ))
(define (nstableview-accessibility-title-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitleUIElement"))))
   ))
(define (nstableview-accessibility-toolbar-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityToolbarButton"))))
   ))
(define (nstableview-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTopLevelUIElement"))))
   ))
(define (nstableview-accessibility-url self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityURL"))))
   ))
(define (nstableview-accessibility-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnitDescription"))))
   ))
(define (nstableview-accessibility-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnits"))))
(define (nstableview-accessibility-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUserInputLabels"))))
   ))
(define (nstableview-accessibility-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValue"))))
   ))
(define (nstableview-accessibility-value-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValueDescription"))))
   ))
(define (nstableview-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalScrollBar"))))
   ))
(define (nstableview-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnitDescription"))))
   ))
(define (nstableview-accessibility-vertical-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnits"))))
(define (nstableview-accessibility-visible-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCells"))))
   ))
(define (nstableview-accessibility-visible-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstableview-accessibility-visible-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleChildren"))))
   ))
(define (nstableview-accessibility-visible-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleColumns"))))
   ))
(define (nstableview-accessibility-visible-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleRows"))))
   ))
(define (nstableview-accessibility-warning-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWarningValue"))))
   ))
(define (nstableview-accessibility-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindow"))))
   ))
(define (nstableview-accessibility-windows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindows"))))
   ))
(define (nstableview-accessibility-zoom-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityZoomButton"))))
   ))
(define (nstableview-add-subview! self view)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addSubview:")) (id->ffi2-ptr (coerce-arg view))))
(define (nstableview-add-subview-positioned-relative-to! self view place other-view)
  (aw_racket_msg_PqP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addSubview:positioned:relativeTo:")) (id->ffi2-ptr (coerce-arg view)) place (id->ffi2-ptr (coerce-arg other-view))))
(define (nstableview-add-table-column! self table-column)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addTableColumn:")) (id->ffi2-ptr (coerce-arg table-column))))
(define (nstableview-add-tool-tip-rect-owner-user-data! self rect owner data)
  (aw_racket_msg_RPP_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addToolTipRect:owner:userData:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg owner)) (id->ffi2-ptr data)))
(define (nstableview-adjust-scroll self new-visible)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "adjustScroll:")) (id->ffi2-ptr new-visible) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-ancestor-shared-with-view self view)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "ancestorSharedWithView:")) (id->ffi2-ptr (coerce-arg view))))
   ))
(define (nstableview-animation-for-key self key)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animationForKey:")) (id->ffi2-ptr (coerce-arg key))))
   ))
(define (nstableview-animations self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animations"))))
   ))
(define (nstableview-animator self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animator"))))
   ))
(define (nstableview-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "appearance"))))
   ))
(define (nstableview-autoscroll self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoscroll:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-backing-aligned-rect-options self rect options)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RQ_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backingAlignedRect:options:")) (id->ffi2-ptr rect) options (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-become-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "becomeFirstResponder"))))
(define (nstableview-begin-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-begin-updates! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginUpdates"))))
(define (nstableview-bitmap-image-rep-for-caching-display-in-rect self rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bitmapImageRepForCachingDisplayInRect:")) (id->ffi2-ptr rect)))
   ))
(define (nstableview-cache-display-in-rect-to-bitmap-image-rep self rect bitmap-image-rep)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cacheDisplayInRect:toBitmapImageRep:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg bitmap-image-rep))))
(define (nstableview-can-drag-rows-with-indexes-at-point self row-indexes mouse-down-point)
  (aw_racket_msg_PO_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDragRowsWithIndexes:atPoint:")) (id->ffi2-ptr (coerce-arg row-indexes)) (id->ffi2-ptr mouse-down-point)))
(define (nstableview-cancel-operation self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cancelOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-capitalize-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "capitalizeWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-center-scan-rect! self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerScanRect:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-center-selection-in-visible-area! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerSelectionInVisibleArea:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-change-case-of-letter self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeCaseOfLetter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-change-mode-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeModeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-column-at-point self point)
  (aw_racket_msg_O_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "columnAtPoint:")) (id->ffi2-ptr point)))
(define (nstableview-column-for-view self view)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "columnForView:")) (id->ffi2-ptr (coerce-arg view))))
(define (nstableview-column-indexes-in-rect self rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "columnIndexesInRect:")) (id->ffi2-ptr rect)))
   ))
(define (nstableview-column-with-identifier self identifier)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "columnWithIdentifier:")) (id->ffi2-ptr (coerce-arg identifier))))
(define (nstableview-complete self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "complete:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-conclude-drag-operation self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "concludeDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-context-menu-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contextMenuKeyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-convert-point-from-view self point view)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_OP_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPoint:fromView:")) (id->ffi2-ptr point) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstableview-convert-point-to-view self point view)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_OP_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPoint:toView:")) (id->ffi2-ptr point) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstableview-convert-point-from-backing self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointFromBacking:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstableview-convert-point-from-layer self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointFromLayer:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstableview-convert-point-to-backing self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointToBacking:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstableview-convert-point-to-layer self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointToLayer:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstableview-convert-rect-from-view self rect view)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RP_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRect:fromView:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-convert-rect-to-view self rect view)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RP_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRect:toView:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-convert-rect-from-backing self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectFromBacking:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-convert-rect-from-layer self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectFromLayer:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-convert-rect-to-backing self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectToBacking:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-convert-rect-to-layer self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectToLayer:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-convert-size-from-view self size view)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_ZP_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSize:fromView:")) (id->ffi2-ptr size) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstableview-convert-size-to-view self size view)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_ZP_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSize:toView:")) (id->ffi2-ptr size) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstableview-convert-size-from-backing self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeFromBacking:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstableview-convert-size-from-layer self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeFromLayer:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstableview-convert-size-to-backing self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeToBacking:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstableview-convert-size-to-layer self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeToLayer:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstableview-cursor-update self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cursorUpdate:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-delete-backward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-delete-backward-by-decomposing-previous-character self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteBackwardByDecomposingPreviousCharacter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-delete-forward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-delete-to-beginning-of-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToBeginningOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-delete-to-beginning-of-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToBeginningOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-delete-to-end-of-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-delete-to-end-of-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToEndOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-delete-to-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-delete-word-backward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteWordBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-delete-word-forward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteWordForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-deselect-all self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deselectAll:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-deselect-column self column)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deselectColumn:")) column))
(define (nstableview-deselect-row self row)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deselectRow:")) row))
(define (nstableview-did-add-row-view-for-row self row-view row)
  (aw_racket_msg_Pq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "didAddRowView:forRow:")) (id->ffi2-ptr (coerce-arg row-view)) row))
(define (nstableview-did-add-subview self subview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "didAddSubview:")) (id->ffi2-ptr (coerce-arg subview))))
(define (nstableview-did-close-menu-with-event self menu event)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "didCloseMenu:withEvent:")) (id->ffi2-ptr (coerce-arg menu)) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-did-remove-row-view-for-row self row-view row)
  (aw_racket_msg_Pq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "didRemoveRowView:forRow:")) (id->ffi2-ptr (coerce-arg row-view)) row))
(define (nstableview-display! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "display"))))
(define (nstableview-display-if-needed! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeeded"))))
(define (nstableview-display-if-needed-ignoring-opacity! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededIgnoringOpacity"))))
(define (nstableview-display-if-needed-in-rect! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededInRect:")) (id->ffi2-ptr rect)))
(define (nstableview-display-if-needed-in-rect-ignoring-opacity! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededInRectIgnoringOpacity:")) (id->ffi2-ptr rect)))
(define (nstableview-display-rect! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRect:")) (id->ffi2-ptr rect)))
(define (nstableview-display-rect-ignoring-opacity! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRectIgnoringOpacity:")) (id->ffi2-ptr rect)))
(define (nstableview-display-rect-ignoring-opacity-in-context! self rect context)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRectIgnoringOpacity:inContext:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg context))))
(define (nstableview-do-command-by-selector self selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "doCommandBySelector:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nstableview-drag-image-for-rows-with-indexes-table-columns-event-offset self drag-rows table-columns drag-event drag-image-offset)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPPP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dragImageForRowsWithIndexes:tableColumns:event:offset:")) (id->ffi2-ptr (coerce-arg drag-rows)) (id->ffi2-ptr (coerce-arg table-columns)) (id->ffi2-ptr (coerce-arg drag-event)) (id->ffi2-ptr drag-image-offset)))
   ))
(define (nstableview-dragging-ended self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingEnded:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-dragging-entered self sender)
  (aw_racket_msg_P_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingEntered:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-dragging-exited self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingExited:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-dragging-session-ended-at-point-operation self session screen-point operation)
  (aw_racket_msg_POQ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingSession:endedAtPoint:operation:")) (id->ffi2-ptr (coerce-arg session)) (id->ffi2-ptr screen-point) operation))
(define (nstableview-dragging-session-moved-to-point self session screen-point)
  (aw_racket_msg_PO_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingSession:movedToPoint:")) (id->ffi2-ptr (coerce-arg session)) (id->ffi2-ptr screen-point)))
(define (nstableview-dragging-session-source-operation-mask-for-dragging-context self session context)
  (aw_racket_msg_Pq_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingSession:sourceOperationMaskForDraggingContext:")) (id->ffi2-ptr (coerce-arg session)) context))
(define (nstableview-dragging-session-will-begin-at-point self session screen-point)
  (aw_racket_msg_PO_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingSession:willBeginAtPoint:")) (id->ffi2-ptr (coerce-arg session)) (id->ffi2-ptr screen-point)))
(define (nstableview-dragging-updated self sender)
  (aw_racket_msg_P_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingUpdated:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-draw-background-in-clip-rect self clip-rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawBackgroundInClipRect:")) (id->ffi2-ptr clip-rect)))
(define (nstableview-draw-grid-in-clip-rect self clip-rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawGridInClipRect:")) (id->ffi2-ptr clip-rect)))
(define (nstableview-draw-rect self dirty-rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawRect:")) (id->ffi2-ptr dirty-rect)))
(define (nstableview-draw-row-clip-rect self row clip-rect)
  (aw_racket_msg_qR_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawRow:clipRect:")) row (id->ffi2-ptr clip-rect)))
(define (nstableview-draw-with-expansion-frame-in-view self content-frame view)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawWithExpansionFrame:inView:")) (id->ffi2-ptr content-frame) (id->ffi2-ptr (coerce-arg view))))
(define (nstableview-edit-column-row-with-event-select self column row event select)
  (aw_racket_msg_qqPb_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "editColumn:row:withEvent:select:")) column row (id->ffi2-ptr (coerce-arg event)) select))
(define (nstableview-effective-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "effectiveAppearance"))))
   ))
(define (nstableview-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nstableview-end-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-end-updates! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endUpdates"))))
;; block param 0: synchronous (caller frees)
(define (nstableview-enumerate-available-row-views-using-block self handler)
  (define-values (_blk0 _blk0-id)
    (make-objc-block handler (list _id _int64) _void))
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enumerateAvailableRowViewsUsingBlock:")) (id->ffi2-ptr _blk0)))
(define (nstableview-expansion-frame-with-frame self content-frame)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "expansionFrameWithFrame:")) (id->ffi2-ptr content-frame) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-flags-changed self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flagsChanged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-flush-buffered-key-events self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flushBufferedKeyEvents"))))
(define (nstableview-frame-of-cell-at-column-row self column row)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_qq_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameOfCellAtColumn:row:")) column row (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-get-rects-being-drawn-count self rects count)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getRectsBeingDrawn:count:")) (id->ffi2-ptr rects) (id->ffi2-ptr count)))
(define (nstableview-get-rects-exposed-during-live-resize-count self exposed-rects count)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getRectsExposedDuringLiveResize:count:")) (id->ffi2-ptr exposed-rects) (id->ffi2-ptr count)))
(define (nstableview-help-requested self event-ptr)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "helpRequested:")) (id->ffi2-ptr (coerce-arg event-ptr))))
(define (nstableview-hide-rows-at-indexes-with-animation self indexes row-animation)
  (aw_racket_msg_PQ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hideRowsAtIndexes:withAnimation:")) (id->ffi2-ptr (coerce-arg indexes)) row-animation))
(define (nstableview-highlight-selection-in-clip-rect self clip-rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "highlightSelectionInClipRect:")) (id->ffi2-ptr clip-rect)))
(define (nstableview-hit-test self point)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_O_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hitTest:")) (id->ffi2-ptr point)))
   ))
(define (nstableview-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "identifier"))))
   ))
(define (nstableview-ignore-modifier-keys-for-dragging-session self session)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "ignoreModifierKeysForDraggingSession:")) (id->ffi2-ptr (coerce-arg session))))
(define (nstableview-indent self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indent:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-indicator-image-in-table-column self table-column)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indicatorImageInTableColumn:")) (id->ffi2-ptr (coerce-arg table-column))))
   ))
(define (nstableview-insert-backtab! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertBacktab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-insert-container-break! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertContainerBreak:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-insert-double-quote-ignoring-substitution! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertDoubleQuoteIgnoringSubstitution:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-insert-line-break! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertLineBreak:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-insert-newline! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertNewline:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-insert-newline-ignoring-field-editor! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertNewlineIgnoringFieldEditor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-insert-paragraph-separator! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertParagraphSeparator:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-insert-rows-at-indexes-with-animation! self indexes animation-options)
  (aw_racket_msg_PQ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertRowsAtIndexes:withAnimation:")) (id->ffi2-ptr (coerce-arg indexes)) animation-options))
(define (nstableview-insert-single-quote-ignoring-substitution! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertSingleQuoteIgnoringSubstitution:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-insert-tab! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-insert-tab-ignoring-field-editor! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTabIgnoringFieldEditor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-insert-text! self insert-string)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertText:")) (id->ffi2-ptr (coerce-arg insert-string))))
(define (nstableview-interpret-key-events self event-array)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "interpretKeyEvents:")) (id->ffi2-ptr (coerce-arg event-array))))
(define (nstableview-is-accessibility-alternate-ui-visible self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityAlternateUIVisible"))))
(define (nstableview-is-accessibility-disclosed self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityDisclosed"))))
(define (nstableview-is-accessibility-edited self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEdited"))))
(define (nstableview-is-accessibility-element self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityElement"))))
(define (nstableview-is-accessibility-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEnabled"))))
(define (nstableview-is-accessibility-expanded self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityExpanded"))))
(define (nstableview-is-accessibility-focused self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFocused"))))
(define (nstableview-is-accessibility-frontmost self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFrontmost"))))
(define (nstableview-is-accessibility-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityHidden"))))
(define (nstableview-is-accessibility-main self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMain"))))
(define (nstableview-is-accessibility-minimized self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMinimized"))))
(define (nstableview-is-accessibility-modal self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityModal"))))
(define (nstableview-is-accessibility-ordered-by-row self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityOrderedByRow"))))
(define (nstableview-is-accessibility-protected-content self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityProtectedContent"))))
(define (nstableview-is-accessibility-required self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityRequired"))))
(define (nstableview-is-accessibility-selected self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelected"))))
(define (nstableview-is-accessibility-selector-allowed self selector)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelectorAllowed:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nstableview-is-column-selected self column)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isColumnSelected:")) column))
(define (nstableview-is-continuous self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isContinuous"))))
(define (nstableview-is-descendant-of self view)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isDescendantOf:")) (id->ffi2-ptr (coerce-arg view))))
(define (nstableview-is-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isEnabled"))))
(define (nstableview-is-flipped self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isFlipped"))))
(define (nstableview-is-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHidden"))))
(define (nstableview-is-hidden-or-has-hidden-ancestor self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHiddenOrHasHiddenAncestor"))))
(define (nstableview-is-highlighted self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHighlighted"))))
(define (nstableview-is-opaque self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isOpaque"))))
(define (nstableview-is-rotated-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRotatedFromBase"))))
(define (nstableview-is-rotated-or-scaled-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRotatedOrScaledFromBase"))))
(define (nstableview-is-row-selected self row)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRowSelected:")) row))
(define (nstableview-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-key-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-layout self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layout"))))
(define (nstableview-layout-subtree-if-needed self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutSubtreeIfNeeded"))))
(define (nstableview-lowercase-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lowercaseWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "magnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-make-backing-layer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBackingLayer"))))
   ))
(define (nstableview-make-base-writing-direction-left-to-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionLeftToRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-make-base-writing-direction-natural self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionNatural:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-make-base-writing-direction-right-to-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionRightToLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-make-text-writing-direction-left-to-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionLeftToRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-make-text-writing-direction-natural self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionNatural:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-make-text-writing-direction-right-to-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionRightToLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-make-view-with-identifier-owner self identifier owner)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeViewWithIdentifier:owner:")) (id->ffi2-ptr (coerce-arg identifier)) (id->ffi2-ptr (coerce-arg owner))))
   ))
(define (nstableview-menu-for-event self event)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menuForEvent:")) (id->ffi2-ptr (coerce-arg event))))
   ))
(define (nstableview-mouse-in-rect self point rect)
  (aw_racket_msg_OR_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouse:inRect:")) (id->ffi2-ptr point) (id->ffi2-ptr rect)))
(define (nstableview-mouse-cancelled self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseCancelled:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-mouse-entered self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseEntered:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-mouse-exited self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseExited:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-mouse-moved self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseMoved:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-move-backward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-column-to-column! self old-index new-index)
  (aw_racket_msg_qq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveColumn:toColumn:")) old-index new-index))
(define (nstableview-move-down! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-down-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveDownAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-forward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-left! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-left-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveLeftAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-paragraph-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveParagraphBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-paragraph-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveParagraphForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-right! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-right-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRightAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-row-at-index-to-index! self old-index new-index)
  (aw_racket_msg_qq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRowAtIndex:toIndex:")) old-index new-index))
(define (nstableview-move-to-beginning-of-document! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-to-beginning-of-document-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfDocumentAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-to-beginning-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-to-beginning-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-to-beginning-of-paragraph! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfParagraphAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-to-end-of-document! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-to-end-of-document-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfDocumentAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-to-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-to-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-to-end-of-paragraph! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-to-end-of-paragraph-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfParagraphAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-to-left-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToLeftEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-to-left-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToLeftEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-to-right-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToRightEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-to-right-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToRightEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-up! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-up-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveUpAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-word-backward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-word-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-word-forward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-word-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-word-left! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-word-left-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordLeftAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-word-right! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-move-word-right-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordRightAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-needs-to-draw-rect self rect)
  (aw_racket_msg_R_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsToDrawRect:")) (id->ffi2-ptr rect)))
(define (nstableview-no-responder-for self event-selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "noResponderFor:")) (id->ffi2-ptr (sel_registerName event-selector))))
(define (nstableview-note-height-of-rows-with-indexes-changed self index-set)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "noteHeightOfRowsWithIndexesChanged:")) (id->ffi2-ptr (coerce-arg index-set))))
(define (nstableview-note-number-of-rows-changed self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "noteNumberOfRowsChanged"))))
(define (nstableview-other-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-other-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-other-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-page-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-page-down-and-modify-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageDownAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-page-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-page-up-and-modify-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageUpAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-perform-click! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performClick:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-perform-drag-operation! self sender)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-perform-key-equivalent! self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performKeyEquivalent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-prepare-content-in-rect self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareContentInRect:")) (id->ffi2-ptr rect)))
(define (nstableview-prepare-for-drag-operation self sender)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareForDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-prepare-for-reuse self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareForReuse"))))
(define (nstableview-pressure-change-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pressureChangeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-quick-look-preview-items self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookPreviewItems:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-quick-look-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-rect-for-smart-magnification-at-point-in-rect self location visible-rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_OR_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectForSmartMagnificationAtPoint:inRect:")) (id->ffi2-ptr location) (id->ffi2-ptr visible-rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-rect-of-column self column)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_q_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectOfColumn:")) column (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-rect-of-row self row)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_q_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectOfRow:")) row (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstableview-register-nib-for-identifier self nib identifier)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "registerNib:forIdentifier:")) (id->ffi2-ptr (coerce-arg nib)) (id->ffi2-ptr (coerce-arg identifier))))
(define (nstableview-reload-data self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "reloadData"))))
(define (nstableview-reload-data-for-row-indexes-column-indexes self row-indexes column-indexes)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "reloadDataForRowIndexes:columnIndexes:")) (id->ffi2-ptr (coerce-arg row-indexes)) (id->ffi2-ptr (coerce-arg column-indexes))))
(define (nstableview-remove-all-tool-tips! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeAllToolTips"))))
(define (nstableview-remove-from-superview! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeFromSuperview"))))
(define (nstableview-remove-from-superview-without-needing-display! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeFromSuperviewWithoutNeedingDisplay"))))
(define (nstableview-remove-rows-at-indexes-with-animation! self indexes animation-options)
  (aw_racket_msg_PQ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeRowsAtIndexes:withAnimation:")) (id->ffi2-ptr (coerce-arg indexes)) animation-options))
(define (nstableview-remove-table-column! self table-column)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeTableColumn:")) (id->ffi2-ptr (coerce-arg table-column))))
(define (nstableview-remove-tool-tip! self tag)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeToolTip:")) tag))
(define (nstableview-replace-subview-with! self old-view new-view)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "replaceSubview:with:")) (id->ffi2-ptr (coerce-arg old-view)) (id->ffi2-ptr (coerce-arg new-view))))
(define (nstableview-resign-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resignFirstResponder"))))
(define (nstableview-resize-subviews-with-old-size self old-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resizeSubviewsWithOldSize:")) (id->ffi2-ptr old-size)))
(define (nstableview-resize-with-old-superview-size self old-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resizeWithOldSuperviewSize:")) (id->ffi2-ptr old-size)))
(define (nstableview-restore-user-activity-state self user-activity)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "restoreUserActivityState:")) (id->ffi2-ptr (coerce-arg user-activity))))
(define (nstableview-right-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-right-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-right-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-rotate-by-angle self angle)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotateByAngle:")) angle))
(define (nstableview-rotate-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotateWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-row-at-point self point)
  (aw_racket_msg_O_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rowAtPoint:")) (id->ffi2-ptr point)))
(define (nstableview-row-for-view self view)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rowForView:")) (id->ffi2-ptr (coerce-arg view))))
(define (nstableview-row-view-at-row-make-if-necessary self row make-if-necessary)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_qb_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rowViewAtRow:makeIfNecessary:")) row make-if-necessary))
   ))
(define (nstableview-rows-in-rect self rect)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_R_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rowsInRect:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstableview-scale-unit-square-to-size self new-unit-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scaleUnitSquareToSize:")) (id->ffi2-ptr new-unit-size)))
(define (nstableview-scroll-column-to-visible self column)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollColumnToVisible:")) column))
(define (nstableview-scroll-line-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollLineDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-scroll-line-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollLineUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-scroll-page-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPageDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-scroll-page-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPageUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-scroll-point self point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPoint:")) (id->ffi2-ptr point)))
(define (nstableview-scroll-rect-to-visible self rect)
  (aw_racket_msg_R_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollRectToVisible:")) (id->ffi2-ptr rect)))
(define (nstableview-scroll-row-to-visible self row)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollRowToVisible:")) row))
(define (nstableview-scroll-to-beginning-of-document self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollToBeginningOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-scroll-to-end-of-document self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollToEndOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-scroll-wheel self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollWheel:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-select-all self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectAll:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-select-column-indexes-by-extending-selection self indexes extend)
  (aw_racket_msg_Pb_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectColumnIndexes:byExtendingSelection:")) (id->ffi2-ptr (coerce-arg indexes)) extend))
(define (nstableview-select-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-select-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-select-row-indexes-by-extending-selection self indexes extend)
  (aw_racket_msg_Pb_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectRowIndexes:byExtendingSelection:")) (id->ffi2-ptr (coerce-arg indexes)) extend))
(define (nstableview-select-to-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectToMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-select-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-send-action-to self action target)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sendAction:to:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg target))))
(define (nstableview-send-action-on self mask)
  (aw_racket_msg_Q_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sendActionOn:")) mask))
(define (nstableview-set-accessibility-activation-point! self accessibility-activation-point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityActivationPoint:")) (id->ffi2-ptr accessibility-activation-point)))
(define (nstableview-set-accessibility-allowed-values! self accessibility-allowed-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAllowedValues:")) (id->ffi2-ptr (coerce-arg accessibility-allowed-values))))
(define (nstableview-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAlternateUIVisible:")) accessibility-alternate-ui-visible))
(define (nstableview-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityApplicationFocusedUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-application-focused-ui-element))))
(define (nstableview-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAttributedUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-attributed-user-input-labels))))
(define (nstableview-set-accessibility-cancel-button! self accessibility-cancel-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCancelButton:")) (id->ffi2-ptr (coerce-arg accessibility-cancel-button))))
(define (nstableview-set-accessibility-children! self accessibility-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildren:")) (id->ffi2-ptr (coerce-arg accessibility-children))))
(define (nstableview-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildrenInNavigationOrder:")) (id->ffi2-ptr (coerce-arg accessibility-children-in-navigation-order))))
(define (nstableview-set-accessibility-clear-button! self accessibility-clear-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityClearButton:")) (id->ffi2-ptr (coerce-arg accessibility-clear-button))))
(define (nstableview-set-accessibility-close-button! self accessibility-close-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCloseButton:")) (id->ffi2-ptr (coerce-arg accessibility-close-button))))
(define (nstableview-set-accessibility-column-count! self accessibility-column-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnCount:")) accessibility-column-count))
(define (nstableview-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-column-header-ui-elements))))
(define (nstableview-set-accessibility-column-index-range! self accessibility-column-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnIndexRange:")) (id->ffi2-ptr accessibility-column-index-range)))
(define (nstableview-set-accessibility-column-titles! self accessibility-column-titles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnTitles:")) (id->ffi2-ptr (coerce-arg accessibility-column-titles))))
(define (nstableview-set-accessibility-columns! self accessibility-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumns:")) (id->ffi2-ptr (coerce-arg accessibility-columns))))
(define (nstableview-set-accessibility-contents! self accessibility-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityContents:")) (id->ffi2-ptr (coerce-arg accessibility-contents))))
(define (nstableview-set-accessibility-critical-value! self accessibility-critical-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCriticalValue:")) (id->ffi2-ptr (coerce-arg accessibility-critical-value))))
(define (nstableview-set-accessibility-custom-actions! self accessibility-custom-actions)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomActions:")) (id->ffi2-ptr (coerce-arg accessibility-custom-actions))))
(define (nstableview-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomRotors:")) (id->ffi2-ptr (coerce-arg accessibility-custom-rotors))))
(define (nstableview-set-accessibility-decrement-button! self accessibility-decrement-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDecrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-decrement-button))))
(define (nstableview-set-accessibility-default-button! self accessibility-default-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDefaultButton:")) (id->ffi2-ptr (coerce-arg accessibility-default-button))))
(define (nstableview-set-accessibility-disclosed! self accessibility-disclosed)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosed:")) accessibility-disclosed))
(define (nstableview-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedByRow:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-by-row))))
(define (nstableview-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedRows:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-rows))))
(define (nstableview-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosureLevel:")) accessibility-disclosure-level))
(define (nstableview-set-accessibility-document! self accessibility-document)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDocument:")) (id->ffi2-ptr (coerce-arg accessibility-document))))
(define (nstableview-set-accessibility-edited! self accessibility-edited)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEdited:")) accessibility-edited))
(define (nstableview-set-accessibility-element! self accessibility-element)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityElement:")) accessibility-element))
(define (nstableview-set-accessibility-enabled! self accessibility-enabled)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEnabled:")) accessibility-enabled))
(define (nstableview-set-accessibility-expanded! self accessibility-expanded)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExpanded:")) accessibility-expanded))
(define (nstableview-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExtrasMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-extras-menu-bar))))
(define (nstableview-set-accessibility-filename! self accessibility-filename)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFilename:")) (id->ffi2-ptr (coerce-arg accessibility-filename))))
(define (nstableview-set-accessibility-focused! self accessibility-focused)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocused:")) accessibility-focused))
(define (nstableview-set-accessibility-focused-window! self accessibility-focused-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocusedWindow:")) (id->ffi2-ptr (coerce-arg accessibility-focused-window))))
(define (nstableview-set-accessibility-frame! self accessibility-frame)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrame:")) (id->ffi2-ptr accessibility-frame)))
(define (nstableview-set-accessibility-frontmost! self accessibility-frontmost)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrontmost:")) accessibility-frontmost))
(define (nstableview-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFullScreenButton:")) (id->ffi2-ptr (coerce-arg accessibility-full-screen-button))))
(define (nstableview-set-accessibility-grow-area! self accessibility-grow-area)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityGrowArea:")) (id->ffi2-ptr (coerce-arg accessibility-grow-area))))
(define (nstableview-set-accessibility-handles! self accessibility-handles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHandles:")) (id->ffi2-ptr (coerce-arg accessibility-handles))))
(define (nstableview-set-accessibility-header! self accessibility-header)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHeader:")) (id->ffi2-ptr (coerce-arg accessibility-header))))
(define (nstableview-set-accessibility-help! self accessibility-help)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHelp:")) (id->ffi2-ptr (coerce-arg accessibility-help))))
(define (nstableview-set-accessibility-hidden! self accessibility-hidden)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHidden:")) accessibility-hidden))
(define (nstableview-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-scroll-bar))))
(define (nstableview-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-unit-description))))
(define (nstableview-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnits:")) accessibility-horizontal-units))
(define (nstableview-set-accessibility-identifier! self accessibility-identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIdentifier:")) (id->ffi2-ptr (coerce-arg accessibility-identifier))))
(define (nstableview-set-accessibility-increment-button! self accessibility-increment-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIncrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-increment-button))))
(define (nstableview-set-accessibility-index! self accessibility-index)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIndex:")) accessibility-index))
(define (nstableview-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityInsertionPointLineNumber:")) accessibility-insertion-point-line-number))
(define (nstableview-set-accessibility-label! self accessibility-label)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabel:")) (id->ffi2-ptr (coerce-arg accessibility-label))))
(define (nstableview-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-label-ui-elements))))
(define (nstableview-set-accessibility-label-value! self accessibility-label-value)
  (aw_racket_msg_f_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelValue:")) accessibility-label-value))
(define (nstableview-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLinkedUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-linked-ui-elements))))
(define (nstableview-set-accessibility-main! self accessibility-main)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMain:")) accessibility-main))
(define (nstableview-set-accessibility-main-window! self accessibility-main-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMainWindow:")) (id->ffi2-ptr (coerce-arg accessibility-main-window))))
(define (nstableview-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerGroupUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-marker-group-ui-element))))
(define (nstableview-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerTypeDescription:")) (id->ffi2-ptr (coerce-arg accessibility-marker-type-description))))
(define (nstableview-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-marker-ui-elements))))
(define (nstableview-set-accessibility-marker-values! self accessibility-marker-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerValues:")) (id->ffi2-ptr (coerce-arg accessibility-marker-values))))
(define (nstableview-set-accessibility-max-value! self accessibility-max-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMaxValue:")) (id->ffi2-ptr (coerce-arg accessibility-max-value))))
(define (nstableview-set-accessibility-menu-bar! self accessibility-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-menu-bar))))
(define (nstableview-set-accessibility-min-value! self accessibility-min-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinValue:")) (id->ffi2-ptr (coerce-arg accessibility-min-value))))
(define (nstableview-set-accessibility-minimize-button! self accessibility-minimize-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimizeButton:")) (id->ffi2-ptr (coerce-arg accessibility-minimize-button))))
(define (nstableview-set-accessibility-minimized! self accessibility-minimized)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimized:")) accessibility-minimized))
(define (nstableview-set-accessibility-modal! self accessibility-modal)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityModal:")) accessibility-modal))
(define (nstableview-set-accessibility-next-contents! self accessibility-next-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNextContents:")) (id->ffi2-ptr (coerce-arg accessibility-next-contents))))
(define (nstableview-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNumberOfCharacters:")) accessibility-number-of-characters))
(define (nstableview-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrderedByRow:")) accessibility-ordered-by-row))
(define (nstableview-set-accessibility-orientation! self accessibility-orientation)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrientation:")) accessibility-orientation))
(define (nstableview-set-accessibility-overflow-button! self accessibility-overflow-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOverflowButton:")) (id->ffi2-ptr (coerce-arg accessibility-overflow-button))))
(define (nstableview-set-accessibility-parent! self accessibility-parent)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityParent:")) (id->ffi2-ptr (coerce-arg accessibility-parent))))
(define (nstableview-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPlaceholderValue:")) (id->ffi2-ptr (coerce-arg accessibility-placeholder-value))))
(define (nstableview-set-accessibility-previous-contents! self accessibility-previous-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPreviousContents:")) (id->ffi2-ptr (coerce-arg accessibility-previous-contents))))
(define (nstableview-set-accessibility-protected-content! self accessibility-protected-content)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProtectedContent:")) accessibility-protected-content))
(define (nstableview-set-accessibility-proxy! self accessibility-proxy)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProxy:")) (id->ffi2-ptr (coerce-arg accessibility-proxy))))
(define (nstableview-set-accessibility-required! self accessibility-required)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRequired:")) accessibility-required))
(define (nstableview-set-accessibility-role! self accessibility-role)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRole:")) (id->ffi2-ptr (coerce-arg accessibility-role))))
(define (nstableview-set-accessibility-role-description! self accessibility-role-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRoleDescription:")) (id->ffi2-ptr (coerce-arg accessibility-role-description))))
(define (nstableview-set-accessibility-row-count! self accessibility-row-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowCount:")) accessibility-row-count))
(define (nstableview-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-row-header-ui-elements))))
(define (nstableview-set-accessibility-row-index-range! self accessibility-row-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowIndexRange:")) (id->ffi2-ptr accessibility-row-index-range)))
(define (nstableview-set-accessibility-rows! self accessibility-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRows:")) (id->ffi2-ptr (coerce-arg accessibility-rows))))
(define (nstableview-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRulerMarkerType:")) accessibility-ruler-marker-type))
(define (nstableview-set-accessibility-search-button! self accessibility-search-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchButton:")) (id->ffi2-ptr (coerce-arg accessibility-search-button))))
(define (nstableview-set-accessibility-search-menu! self accessibility-search-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchMenu:")) (id->ffi2-ptr (coerce-arg accessibility-search-menu))))
(define (nstableview-set-accessibility-selected! self accessibility-selected)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelected:")) accessibility-selected))
(define (nstableview-set-accessibility-selected-cells! self accessibility-selected-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedCells:")) (id->ffi2-ptr (coerce-arg accessibility-selected-cells))))
(define (nstableview-set-accessibility-selected-children! self accessibility-selected-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedChildren:")) (id->ffi2-ptr (coerce-arg accessibility-selected-children))))
(define (nstableview-set-accessibility-selected-columns! self accessibility-selected-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedColumns:")) (id->ffi2-ptr (coerce-arg accessibility-selected-columns))))
(define (nstableview-set-accessibility-selected-rows! self selected-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedRows:")) (id->ffi2-ptr (coerce-arg selected-rows))))
(define (nstableview-set-accessibility-selected-text! self accessibility-selected-text)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedText:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text))))
(define (nstableview-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRange:")) (id->ffi2-ptr accessibility-selected-text-range)))
(define (nstableview-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRanges:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text-ranges))))
(define (nstableview-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityServesAsTitleForUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-serves-as-title-for-ui-elements))))
(define (nstableview-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedCharacterRange:")) (id->ffi2-ptr accessibility-shared-character-range)))
(define (nstableview-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedFocusElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-focus-elements))))
(define (nstableview-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedTextUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-text-ui-elements))))
(define (nstableview-set-accessibility-shown-menu! self accessibility-shown-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityShownMenu:")) (id->ffi2-ptr (coerce-arg accessibility-shown-menu))))
(define (nstableview-set-accessibility-sort-direction! self accessibility-sort-direction)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySortDirection:")) accessibility-sort-direction))
(define (nstableview-set-accessibility-splitters! self accessibility-splitters)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySplitters:")) (id->ffi2-ptr (coerce-arg accessibility-splitters))))
(define (nstableview-set-accessibility-subrole! self accessibility-subrole)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySubrole:")) (id->ffi2-ptr (coerce-arg accessibility-subrole))))
(define (nstableview-set-accessibility-tabs! self accessibility-tabs)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTabs:")) (id->ffi2-ptr (coerce-arg accessibility-tabs))))
(define (nstableview-set-accessibility-title! self accessibility-title)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitle:")) (id->ffi2-ptr (coerce-arg accessibility-title))))
(define (nstableview-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitleUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-title-ui-element))))
(define (nstableview-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityToolbarButton:")) (id->ffi2-ptr (coerce-arg accessibility-toolbar-button))))
(define (nstableview-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTopLevelUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-top-level-ui-element))))
(define (nstableview-set-accessibility-url! self accessibility-url)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityURL:")) (id->ffi2-ptr (coerce-arg accessibility-url))))
(define (nstableview-set-accessibility-unit-description! self accessibility-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-unit-description))))
(define (nstableview-set-accessibility-units! self accessibility-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnits:")) accessibility-units))
(define (nstableview-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-user-input-labels))))
(define (nstableview-set-accessibility-value! self accessibility-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValue:")) (id->ffi2-ptr (coerce-arg accessibility-value))))
(define (nstableview-set-accessibility-value-description! self accessibility-value-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValueDescription:")) (id->ffi2-ptr (coerce-arg accessibility-value-description))))
(define (nstableview-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-scroll-bar))))
(define (nstableview-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-unit-description))))
(define (nstableview-set-accessibility-vertical-units! self accessibility-vertical-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnits:")) accessibility-vertical-units))
(define (nstableview-set-accessibility-visible-cells! self accessibility-visible-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCells:")) (id->ffi2-ptr (coerce-arg accessibility-visible-cells))))
(define (nstableview-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCharacterRange:")) (id->ffi2-ptr accessibility-visible-character-range)))
(define (nstableview-set-accessibility-visible-children! self accessibility-visible-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleChildren:")) (id->ffi2-ptr (coerce-arg accessibility-visible-children))))
(define (nstableview-set-accessibility-visible-columns! self accessibility-visible-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleColumns:")) (id->ffi2-ptr (coerce-arg accessibility-visible-columns))))
(define (nstableview-set-accessibility-visible-rows! self accessibility-visible-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleRows:")) (id->ffi2-ptr (coerce-arg accessibility-visible-rows))))
(define (nstableview-set-accessibility-warning-value! self accessibility-warning-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWarningValue:")) (id->ffi2-ptr (coerce-arg accessibility-warning-value))))
(define (nstableview-set-accessibility-window! self accessibility-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindow:")) (id->ffi2-ptr (coerce-arg accessibility-window))))
(define (nstableview-set-accessibility-windows! self accessibility-windows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindows:")) (id->ffi2-ptr (coerce-arg accessibility-windows))))
(define (nstableview-set-accessibility-zoom-button! self accessibility-zoom-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityZoomButton:")) (id->ffi2-ptr (coerce-arg accessibility-zoom-button))))
(define (nstableview-set-animations! self animations)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAnimations:")) (id->ffi2-ptr (coerce-arg animations))))
(define (nstableview-set-appearance! self appearance)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAppearance:")) (id->ffi2-ptr (coerce-arg appearance))))
(define (nstableview-set-bounds-origin! self new-origin)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsOrigin:")) (id->ffi2-ptr new-origin)))
(define (nstableview-set-bounds-size! self new-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsSize:")) (id->ffi2-ptr new-size)))
(define (nstableview-set-dragging-source-operation-mask-for-local! self mask is-local)
  (aw_racket_msg_Qb_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDraggingSourceOperationMask:forLocal:")) mask is-local))
(define (nstableview-set-drop-row-drop-operation! self row drop-operation)
  (aw_racket_msg_qQ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDropRow:dropOperation:")) row drop-operation))
(define (nstableview-set-frame-origin! self new-origin)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameOrigin:")) (id->ffi2-ptr new-origin)))
(define (nstableview-set-frame-size! self new-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameSize:")) (id->ffi2-ptr new-size)))
(define (nstableview-set-identifier! self identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIdentifier:")) (id->ffi2-ptr (coerce-arg identifier))))
(define (nstableview-set-indicator-image-in-table-column! self image table-column)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIndicatorImage:inTableColumn:")) (id->ffi2-ptr (coerce-arg image)) (id->ffi2-ptr (coerce-arg table-column))))
(define (nstableview-set-mark! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-set-needs-display-in-rect! self invalid-rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsDisplayInRect:")) (id->ffi2-ptr invalid-rect)))
(define (nstableview-should-be-treated-as-ink-event self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldBeTreatedAsInkEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-should-delay-window-ordering-for-event self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldDelayWindowOrderingForEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-show-context-help self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextHelp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-show-context-menu-for-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextMenuForSelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-size-last-column-to-fit self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sizeLastColumnToFit"))))
(define (nstableview-size-that-fits self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sizeThatFits:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstableview-size-to-fit self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sizeToFit"))))
(define (nstableview-smart-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "smartMagnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-sort-subviews-using-function-context self compare context)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sortSubviewsUsingFunction:context:")) (id->ffi2-ptr compare) (id->ffi2-ptr context)))
(define (nstableview-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "supplementalTargetForAction:sender:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg sender))))
   ))
(define (nstableview-swap-with-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swapWithMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-swipe-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swipeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-table-column-with-identifier self identifier)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tableColumnWithIdentifier:")) (id->ffi2-ptr (coerce-arg identifier))))
   ))
(define (nstableview-tablet-point self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletPoint:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-tablet-proximity self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletProximity:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-take-double-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeDoubleValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-take-float-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeFloatValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-take-int-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeIntValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-take-integer-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeIntegerValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-take-object-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeObjectValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-take-string-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeStringValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-text-did-begin-editing self notification)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textDidBeginEditing:")) (id->ffi2-ptr (coerce-arg notification))))
(define (nstableview-text-did-change self notification)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textDidChange:")) (id->ffi2-ptr (coerce-arg notification))))
(define (nstableview-text-did-end-editing self notification)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textDidEndEditing:")) (id->ffi2-ptr (coerce-arg notification))))
(define (nstableview-text-should-begin-editing self text-object)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textShouldBeginEditing:")) (id->ffi2-ptr (coerce-arg text-object))))
(define (nstableview-text-should-end-editing self text-object)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textShouldEndEditing:")) (id->ffi2-ptr (coerce-arg text-object))))
(define (nstableview-text-view-url-for-contents-of-text-attachment-at-index self text-view text-attachment char-index)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPQ_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:URLForContentsOfTextAttachment:atIndex:")) (id->ffi2-ptr (coerce-arg text-view)) (id->ffi2-ptr (coerce-arg text-attachment)) char-index))
   ))
(define (nstableview-text-view-candidates-for-selected-range self text-view candidates selected-range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPG_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:candidates:forSelectedRange:")) (id->ffi2-ptr (coerce-arg text-view)) (id->ffi2-ptr (coerce-arg candidates)) (id->ffi2-ptr selected-range)))
   ))
(define (nstableview-text-view-candidates-for-selected-range self text-view selected-range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PG_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:candidatesForSelectedRange:")) (id->ffi2-ptr (coerce-arg text-view)) (id->ffi2-ptr selected-range)))
   ))
(define (nstableview-text-view-clicked-on-cell-in-rect-at-index self text-view cell cell-frame char-index)
  (aw_racket_msg_PPRQ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:clickedOnCell:inRect:atIndex:")) (id->ffi2-ptr (coerce-arg text-view)) (id->ffi2-ptr (coerce-arg cell)) (id->ffi2-ptr cell-frame) char-index))
(define (nstableview-text-view-clicked-on-link-at-index self text-view link char-index)
  (aw_racket_msg_PPQ_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:clickedOnLink:atIndex:")) (id->ffi2-ptr (coerce-arg text-view)) (id->ffi2-ptr (coerce-arg link)) char-index))
(define (nstableview-text-view-completions-for-partial-word-range-index-of-selected-item self text-view words char-range index)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPGP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:completions:forPartialWordRange:indexOfSelectedItem:")) (id->ffi2-ptr (coerce-arg text-view)) (id->ffi2-ptr (coerce-arg words)) (id->ffi2-ptr char-range) (id->ffi2-ptr index)))
   ))
(define (nstableview-text-view-did-check-text-in-range-types-options-results-orthography-word-count self view range checking-types options results orthography word-count)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PGQPPPq_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:didCheckTextInRange:types:options:results:orthography:wordCount:")) (id->ffi2-ptr (coerce-arg view)) (id->ffi2-ptr range) checking-types (id->ffi2-ptr (coerce-arg options)) (id->ffi2-ptr (coerce-arg results)) (id->ffi2-ptr (coerce-arg orthography)) word-count))
   ))
(define (nstableview-text-view-do-command-by-selector self text-view command-selector)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:doCommandBySelector:")) (id->ffi2-ptr (coerce-arg text-view)) (id->ffi2-ptr (sel_registerName command-selector))))
(define (nstableview-text-view-double-clicked-on-cell-in-rect-at-index self text-view cell cell-frame char-index)
  (aw_racket_msg_PPRQ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:doubleClickedOnCell:inRect:atIndex:")) (id->ffi2-ptr (coerce-arg text-view)) (id->ffi2-ptr (coerce-arg cell)) (id->ffi2-ptr cell-frame) char-index))
(define (nstableview-text-view-dragged-cell-in-rect-event-at-index self view cell rect event char-index)
  (aw_racket_msg_PPRPQ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:draggedCell:inRect:event:atIndex:")) (id->ffi2-ptr (coerce-arg view)) (id->ffi2-ptr (coerce-arg cell)) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg event)) char-index))
(define (nstableview-text-view-menu-for-event-at-index self view menu event char-index)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPPQ_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:menu:forEvent:atIndex:")) (id->ffi2-ptr (coerce-arg view)) (id->ffi2-ptr (coerce-arg menu)) (id->ffi2-ptr (coerce-arg event)) char-index))
   ))
(define (nstableview-text-view-should-change-text-in-range-replacement-string self text-view affected-char-range replacement-string)
  (aw_racket_msg_PGP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:shouldChangeTextInRange:replacementString:")) (id->ffi2-ptr (coerce-arg text-view)) (id->ffi2-ptr affected-char-range) (id->ffi2-ptr (coerce-arg replacement-string))))
(define (nstableview-text-view-should-change-text-in-ranges-replacement-strings self text-view affected-ranges replacement-strings)
  (aw_racket_msg_PPP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:shouldChangeTextInRanges:replacementStrings:")) (id->ffi2-ptr (coerce-arg text-view)) (id->ffi2-ptr (coerce-arg affected-ranges)) (id->ffi2-ptr (coerce-arg replacement-strings))))
(define (nstableview-text-view-should-change-typing-attributes-to-attributes self text-view old-typing-attributes new-typing-attributes)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:shouldChangeTypingAttributes:toAttributes:")) (id->ffi2-ptr (coerce-arg text-view)) (id->ffi2-ptr (coerce-arg old-typing-attributes)) (id->ffi2-ptr (coerce-arg new-typing-attributes))))
   ))
(define (nstableview-text-view-should-select-candidate-at-index self text-view index)
  (aw_racket_msg_PQ_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:shouldSelectCandidateAtIndex:")) (id->ffi2-ptr (coerce-arg text-view)) index))
(define (nstableview-text-view-should-set-spelling-state-range self text-view value affected-char-range)
  (aw_racket_msg_PqG_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:shouldSetSpellingState:range:")) (id->ffi2-ptr (coerce-arg text-view)) value (id->ffi2-ptr affected-char-range)))
(define (nstableview-text-view-should-update-touch-bar-item-identifiers self text-view identifiers)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:shouldUpdateTouchBarItemIdentifiers:")) (id->ffi2-ptr (coerce-arg text-view)) (id->ffi2-ptr (coerce-arg identifiers))))
   ))
(define (nstableview-text-view-will-change-selection-from-character-range-to-character-range self text-view old-selected-char-range new-selected-char-range)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_PGG_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:willChangeSelectionFromCharacterRange:toCharacterRange:")) (id->ffi2-ptr (coerce-arg text-view)) (id->ffi2-ptr old-selected-char-range) (id->ffi2-ptr new-selected-char-range) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstableview-text-view-will-change-selection-from-character-ranges-to-character-ranges self text-view old-selected-char-ranges new-selected-char-ranges)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:willChangeSelectionFromCharacterRanges:toCharacterRanges:")) (id->ffi2-ptr (coerce-arg text-view)) (id->ffi2-ptr (coerce-arg old-selected-char-ranges)) (id->ffi2-ptr (coerce-arg new-selected-char-ranges))))
   ))
(define (nstableview-text-view-will-check-text-in-range-options-types self view range options checking-types)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PGPP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:willCheckTextInRange:options:types:")) (id->ffi2-ptr (coerce-arg view)) (id->ffi2-ptr range) (id->ffi2-ptr (coerce-arg options)) (id->ffi2-ptr checking-types)))
   ))
(define (nstableview-text-view-will-display-tool-tip-for-character-at-index self text-view tooltip character-index)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPQ_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:willDisplayToolTip:forCharacterAtIndex:")) (id->ffi2-ptr (coerce-arg text-view)) (id->ffi2-ptr (coerce-arg tooltip)) character-index))
   ))
(define (nstableview-text-view-will-show-sharing-service-picker-for-items self text-view service-picker items)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:willShowSharingServicePicker:forItems:")) (id->ffi2-ptr (coerce-arg text-view)) (id->ffi2-ptr (coerce-arg service-picker)) (id->ffi2-ptr (coerce-arg items))))
   ))
(define (nstableview-text-view-writable-pasteboard-types-for-cell-at-index self view cell char-index)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPQ_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:writablePasteboardTypesForCell:atIndex:")) (id->ffi2-ptr (coerce-arg view)) (id->ffi2-ptr (coerce-arg cell)) char-index))
   ))
(define (nstableview-text-view-write-cell-at-index-to-pasteboard-type self view cell char-index pboard type)
  (aw_racket_msg_PPQPP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:writeCell:atIndex:toPasteboard:type:")) (id->ffi2-ptr (coerce-arg view)) (id->ffi2-ptr (coerce-arg cell)) char-index (id->ffi2-ptr (coerce-arg pboard)) (id->ffi2-ptr (coerce-arg type))))
(define (nstableview-text-view-writing-tools-ignored-ranges-in-enclosing-range self text-view enclosing-range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PG_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textView:writingToolsIgnoredRangesInEnclosingRange:")) (id->ffi2-ptr (coerce-arg text-view)) (id->ffi2-ptr enclosing-range)))
   ))
(define (nstableview-text-view-did-change-selection self notification)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textViewDidChangeSelection:")) (id->ffi2-ptr (coerce-arg notification))))
(define (nstableview-text-view-did-change-typing-attributes self notification)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textViewDidChangeTypingAttributes:")) (id->ffi2-ptr (coerce-arg notification))))
(define (nstableview-text-view-writing-tools-did-end self text-view)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textViewWritingToolsDidEnd:")) (id->ffi2-ptr (coerce-arg text-view))))
(define (nstableview-text-view-writing-tools-will-begin self text-view)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textViewWritingToolsWillBegin:")) (id->ffi2-ptr (coerce-arg text-view))))
(define (nstableview-tile self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tile"))))
(define (nstableview-touches-began-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesBeganWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-touches-cancelled-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesCancelledWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-touches-ended-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesEndedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-touches-moved-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesMovedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-translate-origin-to-point self translation)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translateOriginToPoint:")) (id->ffi2-ptr translation)))
(define (nstableview-translate-rects-needing-display-in-rect-by self clip-rect delta)
  (aw_racket_msg_RZ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translateRectsNeedingDisplayInRect:by:")) (id->ffi2-ptr clip-rect) (id->ffi2-ptr delta)))
(define (nstableview-transpose self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transpose:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-transpose-words self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transposeWords:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-try-to-perform-with self action object)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tryToPerform:with:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg object))))
(define (nstableview-undo-manager-for-text-view self view)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "undoManagerForTextView:")) (id->ffi2-ptr (coerce-arg view))))
   ))
(define (nstableview-unhide-rows-at-indexes-with-animation self indexes row-animation)
  (aw_racket_msg_PQ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "unhideRowsAtIndexes:withAnimation:")) (id->ffi2-ptr (coerce-arg indexes)) row-animation))
(define (nstableview-update-dragging-items-for-drag self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateDraggingItemsForDrag:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-update-layer self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateLayer"))))
(define (nstableview-uppercase-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "uppercaseWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstableview-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validRequestorForSendType:returnType:")) (id->ffi2-ptr (coerce-arg send-type)) (id->ffi2-ptr (coerce-arg return-type))))
   ))
(define (nstableview-validate-user-interface-item self item)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validateUserInterfaceItem:")) (id->ffi2-ptr (coerce-arg item))))
(define (nstableview-view-at-column-row-make-if-necessary self column row make-if-necessary)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_qqb_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewAtColumn:row:makeIfNecessary:")) column row make-if-necessary))
   ))
(define (nstableview-view-did-change-backing-properties self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidChangeBackingProperties"))))
(define (nstableview-view-did-change-effective-appearance self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidChangeEffectiveAppearance"))))
(define (nstableview-view-did-end-live-resize self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidEndLiveResize"))))
(define (nstableview-view-did-hide self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidHide"))))
(define (nstableview-view-did-move-to-superview self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidMoveToSuperview"))))
(define (nstableview-view-did-move-to-window self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidMoveToWindow"))))
(define (nstableview-view-did-unhide self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidUnhide"))))
(define (nstableview-view-will-draw self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillDraw"))))
(define (nstableview-view-will-move-to-superview self new-superview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillMoveToSuperview:")) (id->ffi2-ptr (coerce-arg new-superview))))
(define (nstableview-view-will-move-to-window self new-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillMoveToWindow:")) (id->ffi2-ptr (coerce-arg new-window))))
(define (nstableview-view-will-start-live-resize self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillStartLiveResize"))))
(define (nstableview-view-with-tag self tag)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWithTag:")) tag))
   ))
(define (nstableview-wants-forwarded-scroll-events-for-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsForwardedScrollEventsForAxis:")) axis))
(define (nstableview-wants-periodic-dragging-updates self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsPeriodicDraggingUpdates"))))
(define (nstableview-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:")) axis))
(define (nstableview-will-open-menu-with-event self menu event)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "willOpenMenu:withEvent:")) (id->ffi2-ptr (coerce-arg menu)) (id->ffi2-ptr (coerce-arg event))))
(define (nstableview-will-remove-subview self subview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "willRemoveSubview:")) (id->ffi2-ptr (coerce-arg subview))))
(define (nstableview-yank self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "yank:")) (id->ffi2-ptr (coerce-arg sender))))

;; --- Class methods ---
(define (nstableview-default-animation-for-key key)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSTableView) (id->ffi2-ptr (sel_registerName "defaultAnimationForKey:")) (id->ffi2-ptr (coerce-arg key))))
   ))
(define (nstableview-is-compatible-with-responsive-scrolling)
  (aw_racket_msg_0_b (id->ffi2-ptr NSTableView) (id->ffi2-ptr (sel_registerName "isCompatibleWithResponsiveScrolling"))))
