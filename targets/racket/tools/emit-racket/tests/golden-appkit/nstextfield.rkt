#lang racket/base
;; Generated binding for NSTextField (AppKit)
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
(define (nscolor? v) (objc-instance-of? v "NSColor"))
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
(define (nstextfield? v) (objc-instance-of? v "NSTextField"))
(define (nstextinputcontext? v) (objc-instance-of? v "NSTextInputContext"))
(define (nstouchbar? v) (objc-instance-of? v "NSTouchBar"))
(define (nsurl? v) (objc-instance-of? v "NSURL"))
(define (nsundomanager? v) (objc-instance-of? v "NSUndoManager"))
(define (nsuseractivity? v) (objc-instance-of? v "NSUserActivity"))
(define (nsview? v) (objc-instance-of? v "NSView"))
(define (nswindow? v) (objc-instance-of? v "NSWindow"))
(define (nswritingtoolscoordinator? v) (objc-instance-of? v "NSWritingToolsCoordinator"))
(define (weakstorage? v) (objc-instance-of? v "WeakStorage"))
(provide NSTextField)
(provide/contract
  [make-nstextfield-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nstextfield-init-with-frame (c-> any/c any/c)]
  [nstextfield-accepts-first-responder (c-> nstextfield? boolean?)]
  [nstextfield-accepts-touch-events (c-> nstextfield? boolean?)]
  [nstextfield-set-accepts-touch-events! (c-> nstextfield? boolean? void?)]
  [nstextfield-action (c-> nstextfield? cpointer?)]
  [nstextfield-set-action! (c-> nstextfield? string? void?)]
  [nstextfield-additional-safe-area-insets (c-> nstextfield? any/c)]
  [nstextfield-set-additional-safe-area-insets! (c-> nstextfield? any/c void?)]
  [nstextfield-alignment (c-> nstextfield? exact-integer?)]
  [nstextfield-set-alignment! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-alignment-rect-insets (c-> nstextfield? any/c)]
  [nstextfield-allowed-touch-types (c-> nstextfield? exact-nonnegative-integer?)]
  [nstextfield-set-allowed-touch-types! (c-> nstextfield? exact-nonnegative-integer? void?)]
  [nstextfield-allows-character-picker-touch-bar-item (c-> nstextfield? boolean?)]
  [nstextfield-set-allows-character-picker-touch-bar-item! (c-> nstextfield? boolean? void?)]
  [nstextfield-allows-default-tightening-for-truncation (c-> nstextfield? boolean?)]
  [nstextfield-set-allows-default-tightening-for-truncation! (c-> nstextfield? boolean? void?)]
  [nstextfield-allows-editing-text-attributes (c-> nstextfield? boolean?)]
  [nstextfield-set-allows-editing-text-attributes! (c-> nstextfield? boolean? void?)]
  [nstextfield-allows-expansion-tool-tips (c-> nstextfield? boolean?)]
  [nstextfield-set-allows-expansion-tool-tips! (c-> nstextfield? boolean? void?)]
  [nstextfield-allows-vibrancy (c-> nstextfield? boolean?)]
  [nstextfield-allows-writing-tools (c-> nstextfield? boolean?)]
  [nstextfield-set-allows-writing-tools! (c-> nstextfield? boolean? void?)]
  [nstextfield-allows-writing-tools-affordance (c-> nstextfield? boolean?)]
  [nstextfield-set-allows-writing-tools-affordance! (c-> nstextfield? boolean? void?)]
  [nstextfield-alpha-value (c-> nstextfield? real?)]
  [nstextfield-set-alpha-value! (c-> nstextfield? real? void?)]
  [nstextfield-attributed-string-value (c-> nstextfield? (or/c nsattributedstring? objc-nil?))]
  [nstextfield-set-attributed-string-value! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-automatic-text-completion-enabled (c-> nstextfield? boolean?)]
  [nstextfield-set-automatic-text-completion-enabled! (c-> nstextfield? boolean? void?)]
  [nstextfield-autoresizes-subviews (c-> nstextfield? boolean?)]
  [nstextfield-set-autoresizes-subviews! (c-> nstextfield? boolean? void?)]
  [nstextfield-autoresizing-mask (c-> nstextfield? exact-nonnegative-integer?)]
  [nstextfield-set-autoresizing-mask! (c-> nstextfield? exact-nonnegative-integer? void?)]
  [nstextfield-background-color (c-> nstextfield? (or/c nscolor? objc-nil?))]
  [nstextfield-set-background-color! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-background-filters (c-> nstextfield? any/c)]
  [nstextfield-set-background-filters! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-base-writing-direction (c-> nstextfield? exact-integer?)]
  [nstextfield-set-base-writing-direction! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-baseline-offset-from-bottom (c-> nstextfield? real?)]
  [nstextfield-bezel-style (c-> nstextfield? exact-nonnegative-integer?)]
  [nstextfield-set-bezel-style! (c-> nstextfield? exact-nonnegative-integer? void?)]
  [nstextfield-bezeled (c-> nstextfield? boolean?)]
  [nstextfield-set-bezeled! (c-> nstextfield? boolean? void?)]
  [nstextfield-bordered (c-> nstextfield? boolean?)]
  [nstextfield-set-bordered! (c-> nstextfield? boolean? void?)]
  [nstextfield-bottom-anchor (c-> nstextfield? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstextfield-bounds (c-> nstextfield? any/c)]
  [nstextfield-set-bounds! (c-> nstextfield? any/c void?)]
  [nstextfield-bounds-rotation (c-> nstextfield? real?)]
  [nstextfield-set-bounds-rotation! (c-> nstextfield? real? void?)]
  [nstextfield-can-become-key-view (c-> nstextfield? boolean?)]
  [nstextfield-can-draw (c-> nstextfield? boolean?)]
  [nstextfield-can-draw-concurrently (c-> nstextfield? boolean?)]
  [nstextfield-set-can-draw-concurrently! (c-> nstextfield? boolean? void?)]
  [nstextfield-can-draw-subviews-into-layer (c-> nstextfield? boolean?)]
  [nstextfield-set-can-draw-subviews-into-layer! (c-> nstextfield? boolean? void?)]
  [nstextfield-candidate-list-touch-bar-item (c-> nstextfield? (or/c nscandidatelisttouchbaritem? objc-nil?))]
  [nstextfield-cell (c-> nstextfield? any/c)]
  [nstextfield-set-cell! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-cell-class (c-> cpointer?)]
  [nstextfield-set-cell-class! (c-> cpointer? void?)]
  [nstextfield-center-x-anchor (c-> nstextfield? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstextfield-center-y-anchor (c-> nstextfield? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstextfield-clips-to-bounds (c-> nstextfield? boolean?)]
  [nstextfield-set-clips-to-bounds! (c-> nstextfield? boolean? void?)]
  [nstextfield-compatible-with-responsive-scrolling (c-> boolean?)]
  [nstextfield-compositing-filter (c-> nstextfield? (or/c cifilter? objc-nil?))]
  [nstextfield-set-compositing-filter! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-constraints (c-> nstextfield? any/c)]
  [nstextfield-content-filters (c-> nstextfield? any/c)]
  [nstextfield-set-content-filters! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-continuous (c-> nstextfield? boolean?)]
  [nstextfield-set-continuous! (c-> nstextfield? boolean? void?)]
  [nstextfield-control-size (c-> nstextfield? exact-nonnegative-integer?)]
  [nstextfield-set-control-size! (c-> nstextfield? exact-nonnegative-integer? void?)]
  [nstextfield-default-focus-ring-type (c-> exact-nonnegative-integer?)]
  [nstextfield-default-menu (c-> (or/c nsmenu? objc-nil?))]
  [nstextfield-delegate (c-> nstextfield? any/c)]
  [nstextfield-set-delegate! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-double-value (c-> nstextfield? real?)]
  [nstextfield-set-double-value! (c-> nstextfield? real? void?)]
  [nstextfield-drawing-find-indicator (c-> nstextfield? boolean?)]
  [nstextfield-draws-background (c-> nstextfield? boolean?)]
  [nstextfield-set-draws-background! (c-> nstextfield? boolean? void?)]
  [nstextfield-editable (c-> nstextfield? boolean?)]
  [nstextfield-set-editable! (c-> nstextfield? boolean? void?)]
  [nstextfield-enabled (c-> nstextfield? boolean?)]
  [nstextfield-set-enabled! (c-> nstextfield? boolean? void?)]
  [nstextfield-enclosing-menu-item (c-> nstextfield? (or/c nsmenuitem? objc-nil?))]
  [nstextfield-enclosing-scroll-view (c-> nstextfield? (or/c nsscrollview? objc-nil?))]
  [nstextfield-first-baseline-anchor (c-> nstextfield? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstextfield-first-baseline-offset-from-top (c-> nstextfield? real?)]
  [nstextfield-fitting-size (c-> nstextfield? any/c)]
  [nstextfield-flipped (c-> nstextfield? boolean?)]
  [nstextfield-float-value (c-> nstextfield? real?)]
  [nstextfield-set-float-value! (c-> nstextfield? real? void?)]
  [nstextfield-focus-ring-mask-bounds (c-> nstextfield? any/c)]
  [nstextfield-focus-ring-type (c-> nstextfield? exact-nonnegative-integer?)]
  [nstextfield-set-focus-ring-type! (c-> nstextfield? exact-nonnegative-integer? void?)]
  [nstextfield-focus-view (c-> (or/c nsview? objc-nil?))]
  [nstextfield-font (c-> nstextfield? (or/c nsfont? objc-nil?))]
  [nstextfield-set-font! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-formatter (c-> nstextfield? any/c)]
  [nstextfield-set-formatter! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-frame (c-> nstextfield? any/c)]
  [nstextfield-set-frame! (c-> nstextfield? any/c void?)]
  [nstextfield-frame-center-rotation (c-> nstextfield? real?)]
  [nstextfield-set-frame-center-rotation! (c-> nstextfield? real? void?)]
  [nstextfield-frame-rotation (c-> nstextfield? real?)]
  [nstextfield-set-frame-rotation! (c-> nstextfield? real? void?)]
  [nstextfield-gesture-recognizers (c-> nstextfield? any/c)]
  [nstextfield-set-gesture-recognizers! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-has-ambiguous-layout (c-> nstextfield? boolean?)]
  [nstextfield-height-adjust-limit (c-> nstextfield? real?)]
  [nstextfield-height-anchor (c-> nstextfield? (or/c nslayoutdimension? objc-nil?))]
  [nstextfield-hidden (c-> nstextfield? boolean?)]
  [nstextfield-set-hidden! (c-> nstextfield? boolean? void?)]
  [nstextfield-hidden-or-has-hidden-ancestor (c-> nstextfield? boolean?)]
  [nstextfield-highlighted (c-> nstextfield? boolean?)]
  [nstextfield-set-highlighted! (c-> nstextfield? boolean? void?)]
  [nstextfield-horizontal-content-size-constraint-active (c-> nstextfield? boolean?)]
  [nstextfield-set-horizontal-content-size-constraint-active! (c-> nstextfield? boolean? void?)]
  [nstextfield-ignores-multi-click (c-> nstextfield? boolean?)]
  [nstextfield-set-ignores-multi-click! (c-> nstextfield? boolean? void?)]
  [nstextfield-imports-graphics (c-> nstextfield? boolean?)]
  [nstextfield-set-imports-graphics! (c-> nstextfield? boolean? void?)]
  [nstextfield-in-full-screen-mode (c-> nstextfield? boolean?)]
  [nstextfield-in-live-resize (c-> nstextfield? boolean?)]
  [nstextfield-input-context (c-> nstextfield? (or/c nstextinputcontext? objc-nil?))]
  [nstextfield-int-value (c-> nstextfield? exact-integer?)]
  [nstextfield-set-int-value! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-integer-value (c-> nstextfield? exact-integer?)]
  [nstextfield-set-integer-value! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-intrinsic-content-size (c-> nstextfield? any/c)]
  [nstextfield-last-baseline-anchor (c-> nstextfield? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstextfield-last-baseline-offset-from-bottom (c-> nstextfield? real?)]
  [nstextfield-layer (c-> nstextfield? (or/c calayer? objc-nil?))]
  [nstextfield-set-layer! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-layer-contents-placement (c-> nstextfield? exact-integer?)]
  [nstextfield-set-layer-contents-placement! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-layer-contents-redraw-policy (c-> nstextfield? exact-integer?)]
  [nstextfield-set-layer-contents-redraw-policy! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-layer-uses-core-image-filters (c-> nstextfield? boolean?)]
  [nstextfield-set-layer-uses-core-image-filters! (c-> nstextfield? boolean? void?)]
  [nstextfield-layout-guides (c-> nstextfield? any/c)]
  [nstextfield-layout-margins-guide (c-> nstextfield? (or/c nslayoutguide? objc-nil?))]
  [nstextfield-leading-anchor (c-> nstextfield? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstextfield-left-anchor (c-> nstextfield? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstextfield-line-break-mode (c-> nstextfield? exact-nonnegative-integer?)]
  [nstextfield-set-line-break-mode! (c-> nstextfield? exact-nonnegative-integer? void?)]
  [nstextfield-line-break-strategy (c-> nstextfield? exact-nonnegative-integer?)]
  [nstextfield-set-line-break-strategy! (c-> nstextfield? exact-nonnegative-integer? void?)]
  [nstextfield-maximum-number-of-lines (c-> nstextfield? exact-integer?)]
  [nstextfield-set-maximum-number-of-lines! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-menu (c-> nstextfield? (or/c nsmenu? objc-nil?))]
  [nstextfield-set-menu! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-mouse-down-can-move-window (c-> nstextfield? boolean?)]
  [nstextfield-needs-display (c-> nstextfield? boolean?)]
  [nstextfield-set-needs-display! (c-> nstextfield? boolean? void?)]
  [nstextfield-needs-layout (c-> nstextfield? boolean?)]
  [nstextfield-set-needs-layout! (c-> nstextfield? boolean? void?)]
  [nstextfield-needs-panel-to-become-key (c-> nstextfield? boolean?)]
  [nstextfield-needs-update-constraints (c-> nstextfield? boolean?)]
  [nstextfield-set-needs-update-constraints! (c-> nstextfield? boolean? void?)]
  [nstextfield-next-key-view (c-> nstextfield? (or/c nsview? objc-nil?))]
  [nstextfield-set-next-key-view! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-next-responder (c-> nstextfield? (or/c nsresponder? objc-nil?))]
  [nstextfield-set-next-responder! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-next-valid-key-view (c-> nstextfield? (or/c nsview? objc-nil?))]
  [nstextfield-object-value (c-> nstextfield? any/c)]
  [nstextfield-set-object-value! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-opaque (c-> nstextfield? boolean?)]
  [nstextfield-opaque-ancestor (c-> nstextfield? (or/c nsview? objc-nil?))]
  [nstextfield-page-footer (c-> nstextfield? (or/c nsattributedstring? objc-nil?))]
  [nstextfield-page-header (c-> nstextfield? (or/c nsattributedstring? objc-nil?))]
  [nstextfield-placeholder-attributed-string (c-> nstextfield? (or/c nsattributedstring? objc-nil?))]
  [nstextfield-set-placeholder-attributed-string! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-placeholder-attributed-strings (c-> nstextfield? any/c)]
  [nstextfield-set-placeholder-attributed-strings! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-placeholder-string (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-set-placeholder-string! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-placeholder-strings (c-> nstextfield? any/c)]
  [nstextfield-set-placeholder-strings! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-posts-bounds-changed-notifications (c-> nstextfield? boolean?)]
  [nstextfield-set-posts-bounds-changed-notifications! (c-> nstextfield? boolean? void?)]
  [nstextfield-posts-frame-changed-notifications (c-> nstextfield? boolean?)]
  [nstextfield-set-posts-frame-changed-notifications! (c-> nstextfield? boolean? void?)]
  [nstextfield-preferred-max-layout-width (c-> nstextfield? real?)]
  [nstextfield-set-preferred-max-layout-width! (c-> nstextfield? real? void?)]
  [nstextfield-prefers-compact-control-size-metrics (c-> nstextfield? boolean?)]
  [nstextfield-set-prefers-compact-control-size-metrics! (c-> nstextfield? boolean? void?)]
  [nstextfield-prepared-content-rect (c-> nstextfield? any/c)]
  [nstextfield-set-prepared-content-rect! (c-> nstextfield? any/c void?)]
  [nstextfield-preserves-content-during-live-resize (c-> nstextfield? boolean?)]
  [nstextfield-pressure-configuration (c-> nstextfield? (or/c nspressureconfiguration? objc-nil?))]
  [nstextfield-set-pressure-configuration! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-previous-key-view (c-> nstextfield? (or/c nsview? objc-nil?))]
  [nstextfield-previous-valid-key-view (c-> nstextfield? (or/c nsview? objc-nil?))]
  [nstextfield-print-job-title (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-rect-preserved-during-live-resize (c-> nstextfield? any/c)]
  [nstextfield-refuses-first-responder (c-> nstextfield? boolean?)]
  [nstextfield-set-refuses-first-responder! (c-> nstextfield? boolean? void?)]
  [nstextfield-registered-dragged-types (c-> nstextfield? any/c)]
  [nstextfield-requires-constraint-based-layout (c-> boolean?)]
  [nstextfield-resolves-natural-alignment-with-base-writing-direction (c-> nstextfield? boolean?)]
  [nstextfield-set-resolves-natural-alignment-with-base-writing-direction! (c-> nstextfield? boolean? void?)]
  [nstextfield-restorable-state-key-paths (c-> any/c)]
  [nstextfield-right-anchor (c-> nstextfield? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstextfield-rotated-from-base (c-> nstextfield? boolean?)]
  [nstextfield-rotated-or-scaled-from-base (c-> nstextfield? boolean?)]
  [nstextfield-safe-area-insets (c-> nstextfield? any/c)]
  [nstextfield-safe-area-layout-guide (c-> nstextfield? (or/c nslayoutguide? objc-nil?))]
  [nstextfield-safe-area-rect (c-> nstextfield? any/c)]
  [nstextfield-selectable (c-> nstextfield? boolean?)]
  [nstextfield-set-selectable! (c-> nstextfield? boolean? void?)]
  [nstextfield-shadow (c-> nstextfield? (or/c nsshadow? objc-nil?))]
  [nstextfield-set-shadow! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-string-value (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-set-string-value! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-subviews (c-> nstextfield? any/c)]
  [nstextfield-set-subviews! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-suggestions-delegate (c-> nstextfield? (or/c weakstorage? objc-nil?))]
  [nstextfield-set-suggestions-delegate! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-superview (c-> nstextfield? (or/c nsview? objc-nil?))]
  [nstextfield-tag (c-> nstextfield? exact-integer?)]
  [nstextfield-set-tag! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-target (c-> nstextfield? any/c)]
  [nstextfield-set-target! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-text-color (c-> nstextfield? (or/c nscolor? objc-nil?))]
  [nstextfield-set-text-color! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-tool-tip (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-set-tool-tip! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-top-anchor (c-> nstextfield? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstextfield-touch-bar (c-> nstextfield? (or/c nstouchbar? objc-nil?))]
  [nstextfield-set-touch-bar! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-tracking-areas (c-> nstextfield? any/c)]
  [nstextfield-trailing-anchor (c-> nstextfield? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstextfield-translates-autoresizing-mask-into-constraints (c-> nstextfield? boolean?)]
  [nstextfield-set-translates-autoresizing-mask-into-constraints! (c-> nstextfield? boolean? void?)]
  [nstextfield-undo-manager (c-> nstextfield? (or/c nsundomanager? objc-nil?))]
  [nstextfield-user-activity (c-> nstextfield? (or/c nsuseractivity? objc-nil?))]
  [nstextfield-set-user-activity! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-user-interface-layout-direction (c-> nstextfield? exact-integer?)]
  [nstextfield-set-user-interface-layout-direction! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-uses-single-line-mode (c-> nstextfield? boolean?)]
  [nstextfield-set-uses-single-line-mode! (c-> nstextfield? boolean? void?)]
  [nstextfield-vertical-content-size-constraint-active (c-> nstextfield? boolean?)]
  [nstextfield-set-vertical-content-size-constraint-active! (c-> nstextfield? boolean? void?)]
  [nstextfield-visible-rect (c-> nstextfield? any/c)]
  [nstextfield-wants-best-resolution-open-gl-surface (c-> nstextfield? boolean?)]
  [nstextfield-set-wants-best-resolution-open-gl-surface! (c-> nstextfield? boolean? void?)]
  [nstextfield-wants-default-clipping (c-> nstextfield? boolean?)]
  [nstextfield-wants-extended-dynamic-range-open-gl-surface (c-> nstextfield? boolean?)]
  [nstextfield-set-wants-extended-dynamic-range-open-gl-surface! (c-> nstextfield? boolean? void?)]
  [nstextfield-wants-layer (c-> nstextfield? boolean?)]
  [nstextfield-set-wants-layer! (c-> nstextfield? boolean? void?)]
  [nstextfield-wants-resting-touches (c-> nstextfield? boolean?)]
  [nstextfield-set-wants-resting-touches! (c-> nstextfield? boolean? void?)]
  [nstextfield-wants-update-layer (c-> nstextfield? boolean?)]
  [nstextfield-width-adjust-limit (c-> nstextfield? real?)]
  [nstextfield-width-anchor (c-> nstextfield? (or/c nslayoutdimension? objc-nil?))]
  [nstextfield-window (c-> nstextfield? (or/c nswindow? objc-nil?))]
  [nstextfield-writing-tools-coordinator (c-> nstextfield? (or/c nswritingtoolscoordinator? objc-nil?))]
  [nstextfield-set-writing-tools-coordinator! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-accepts-first-mouse (c-> nstextfield? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-accessibility-activation-point (c-> nstextfield? any/c)]
  [nstextfield-accessibility-allowed-values (c-> nstextfield? any/c)]
  [nstextfield-accessibility-application-focused-ui-element (c-> nstextfield? any/c)]
  [nstextfield-accessibility-attributed-string-for-range (c-> nstextfield? any/c (or/c nsattributedstring? objc-nil?))]
  [nstextfield-accessibility-attributed-user-input-labels (c-> nstextfield? any/c)]
  [nstextfield-accessibility-cancel-button (c-> nstextfield? any/c)]
  [nstextfield-accessibility-cell-for-column-row (c-> nstextfield? exact-integer? exact-integer? any/c)]
  [nstextfield-accessibility-children (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-children-in-navigation-order (c-> nstextfield? any/c)]
  [nstextfield-accessibility-clear-button (c-> nstextfield? any/c)]
  [nstextfield-accessibility-close-button (c-> nstextfield? any/c)]
  [nstextfield-accessibility-column-count (c-> nstextfield? exact-integer?)]
  [nstextfield-accessibility-column-header-ui-elements (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-column-index-range (c-> nstextfield? any/c)]
  [nstextfield-accessibility-column-titles (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-columns (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-contents (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-critical-value (c-> nstextfield? any/c)]
  [nstextfield-accessibility-custom-actions (c-> nstextfield? any/c)]
  [nstextfield-accessibility-custom-rotors (c-> nstextfield? any/c)]
  [nstextfield-accessibility-decrement-button (c-> nstextfield? any/c)]
  [nstextfield-accessibility-default-button (c-> nstextfield? any/c)]
  [nstextfield-accessibility-disclosed-by-row (c-> nstextfield? any/c)]
  [nstextfield-accessibility-disclosed-rows (c-> nstextfield? any/c)]
  [nstextfield-accessibility-disclosure-level (c-> nstextfield? exact-integer?)]
  [nstextfield-accessibility-document (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-extras-menu-bar (c-> nstextfield? any/c)]
  [nstextfield-accessibility-filename (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-focused-window (c-> nstextfield? any/c)]
  [nstextfield-accessibility-frame (c-> nstextfield? any/c)]
  [nstextfield-accessibility-frame-for-range (c-> nstextfield? any/c any/c)]
  [nstextfield-accessibility-full-screen-button (c-> nstextfield? any/c)]
  [nstextfield-accessibility-grow-area (c-> nstextfield? any/c)]
  [nstextfield-accessibility-handles (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-header (c-> nstextfield? any/c)]
  [nstextfield-accessibility-help (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-horizontal-scroll-bar (c-> nstextfield? any/c)]
  [nstextfield-accessibility-horizontal-unit-description (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-horizontal-units (c-> nstextfield? exact-integer?)]
  [nstextfield-accessibility-identifier (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-increment-button (c-> nstextfield? any/c)]
  [nstextfield-accessibility-index (c-> nstextfield? exact-integer?)]
  [nstextfield-accessibility-insertion-point-line-number (c-> nstextfield? exact-integer?)]
  [nstextfield-accessibility-label (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-label-ui-elements (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-label-value (c-> nstextfield? real?)]
  [nstextfield-accessibility-layout-point-for-screen-point (c-> nstextfield? any/c any/c)]
  [nstextfield-accessibility-layout-size-for-screen-size (c-> nstextfield? any/c any/c)]
  [nstextfield-accessibility-line-for-index (c-> nstextfield? exact-integer? exact-integer?)]
  [nstextfield-accessibility-linked-ui-elements (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-main-window (c-> nstextfield? any/c)]
  [nstextfield-accessibility-marker-group-ui-element (c-> nstextfield? any/c)]
  [nstextfield-accessibility-marker-type-description (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-marker-ui-elements (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-marker-values (c-> nstextfield? any/c)]
  [nstextfield-accessibility-max-value (c-> nstextfield? any/c)]
  [nstextfield-accessibility-menu-bar (c-> nstextfield? any/c)]
  [nstextfield-accessibility-min-value (c-> nstextfield? any/c)]
  [nstextfield-accessibility-minimize-button (c-> nstextfield? any/c)]
  [nstextfield-accessibility-next-contents (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-number-of-characters (c-> nstextfield? exact-integer?)]
  [nstextfield-accessibility-orientation (c-> nstextfield? exact-integer?)]
  [nstextfield-accessibility-overflow-button (c-> nstextfield? any/c)]
  [nstextfield-accessibility-parent (c-> nstextfield? any/c)]
  [nstextfield-accessibility-perform-cancel (c-> nstextfield? boolean?)]
  [nstextfield-accessibility-perform-confirm (c-> nstextfield? boolean?)]
  [nstextfield-accessibility-perform-decrement (c-> nstextfield? boolean?)]
  [nstextfield-accessibility-perform-delete (c-> nstextfield? boolean?)]
  [nstextfield-accessibility-perform-increment (c-> nstextfield? boolean?)]
  [nstextfield-accessibility-perform-pick (c-> nstextfield? boolean?)]
  [nstextfield-accessibility-perform-press (c-> nstextfield? boolean?)]
  [nstextfield-accessibility-perform-raise (c-> nstextfield? boolean?)]
  [nstextfield-accessibility-perform-show-alternate-ui (c-> nstextfield? boolean?)]
  [nstextfield-accessibility-perform-show-default-ui (c-> nstextfield? boolean?)]
  [nstextfield-accessibility-perform-show-menu (c-> nstextfield? boolean?)]
  [nstextfield-accessibility-placeholder-value (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-previous-contents (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-proxy (c-> nstextfield? any/c)]
  [nstextfield-accessibility-rtf-for-range (c-> nstextfield? any/c (or/c nsdata? objc-nil?))]
  [nstextfield-accessibility-range-for-index (c-> nstextfield? exact-integer? any/c)]
  [nstextfield-accessibility-range-for-line (c-> nstextfield? exact-integer? any/c)]
  [nstextfield-accessibility-range-for-position (c-> nstextfield? any/c any/c)]
  [nstextfield-accessibility-role (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-role-description (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-row-count (c-> nstextfield? exact-integer?)]
  [nstextfield-accessibility-row-header-ui-elements (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-row-index-range (c-> nstextfield? any/c)]
  [nstextfield-accessibility-rows (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-ruler-marker-type (c-> nstextfield? exact-integer?)]
  [nstextfield-accessibility-screen-point-for-layout-point (c-> nstextfield? any/c any/c)]
  [nstextfield-accessibility-screen-size-for-layout-size (c-> nstextfield? any/c any/c)]
  [nstextfield-accessibility-search-button (c-> nstextfield? any/c)]
  [nstextfield-accessibility-search-menu (c-> nstextfield? any/c)]
  [nstextfield-accessibility-selected-cells (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-selected-children (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-selected-columns (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-selected-rows (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-selected-text (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-selected-text-range (c-> nstextfield? any/c)]
  [nstextfield-accessibility-selected-text-ranges (c-> nstextfield? any/c)]
  [nstextfield-accessibility-serves-as-title-for-ui-elements (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-shared-character-range (c-> nstextfield? any/c)]
  [nstextfield-accessibility-shared-focus-elements (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-shared-text-ui-elements (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-shown-menu (c-> nstextfield? any/c)]
  [nstextfield-accessibility-sort-direction (c-> nstextfield? exact-integer?)]
  [nstextfield-accessibility-splitters (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-string-for-range (c-> nstextfield? any/c (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-style-range-for-index (c-> nstextfield? exact-integer? any/c)]
  [nstextfield-accessibility-subrole (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-tabs (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-title (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-title-ui-element (c-> nstextfield? any/c)]
  [nstextfield-accessibility-toolbar-button (c-> nstextfield? any/c)]
  [nstextfield-accessibility-top-level-ui-element (c-> nstextfield? any/c)]
  [nstextfield-accessibility-url (c-> nstextfield? (or/c nsurl? objc-nil?))]
  [nstextfield-accessibility-unit-description (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-units (c-> nstextfield? exact-integer?)]
  [nstextfield-accessibility-user-input-labels (c-> nstextfield? any/c)]
  [nstextfield-accessibility-value (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-value-description (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-vertical-scroll-bar (c-> nstextfield? any/c)]
  [nstextfield-accessibility-vertical-unit-description (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-vertical-units (c-> nstextfield? exact-integer?)]
  [nstextfield-accessibility-visible-cells (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-visible-character-range (c-> nstextfield? any/c)]
  [nstextfield-accessibility-visible-children (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-visible-columns (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-visible-rows (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-warning-value (c-> nstextfield? any/c)]
  [nstextfield-accessibility-window (c-> nstextfield? any/c)]
  [nstextfield-accessibility-windows (c-> nstextfield? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-zoom-button (c-> nstextfield? any/c)]
  [nstextfield-add-subview! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-add-subview-positioned-relative-to! (c-> nstextfield? (or/c string? objc-object? #f) exact-integer? (or/c string? objc-object? #f) void?)]
  [nstextfield-add-tool-tip-rect-owner-user-data! (c-> nstextfield? any/c (or/c string? objc-object? #f) (or/c cpointer? #f) exact-integer?)]
  [nstextfield-adjust-scroll (c-> nstextfield? any/c any/c)]
  [nstextfield-ancestor-shared-with-view (c-> nstextfield? (or/c string? objc-object? #f) (or/c nsview? objc-nil?))]
  [nstextfield-animation-for-key (c-> nstextfield? (or/c string? objc-object? #f) any/c)]
  [nstextfield-animations (c-> nstextfield? any/c)]
  [nstextfield-animator (c-> nstextfield? any/c)]
  [nstextfield-appearance (c-> nstextfield? (or/c nsappearance? objc-nil?))]
  [nstextfield-autoscroll (c-> nstextfield? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-backing-aligned-rect-options (c-> nstextfield? any/c exact-nonnegative-integer? any/c)]
  [nstextfield-become-first-responder (c-> nstextfield? boolean?)]
  [nstextfield-begin-gesture-with-event! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-bitmap-image-rep-for-caching-display-in-rect (c-> nstextfield? any/c (or/c nsbitmapimagerep? objc-nil?))]
  [nstextfield-cache-display-in-rect-to-bitmap-image-rep (c-> nstextfield? any/c (or/c string? objc-object? #f) void?)]
  [nstextfield-cancel-operation (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-capitalize-word (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-center-scan-rect! (c-> nstextfield? any/c any/c)]
  [nstextfield-center-selection-in-visible-area! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-change-case-of-letter (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-change-mode-with-event (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-complete (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-conclude-drag-operation (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-content-type (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-context-menu-key-down (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-convert-point-from-view (c-> nstextfield? any/c (or/c string? objc-object? #f) any/c)]
  [nstextfield-convert-point-to-view (c-> nstextfield? any/c (or/c string? objc-object? #f) any/c)]
  [nstextfield-convert-point-from-backing (c-> nstextfield? any/c any/c)]
  [nstextfield-convert-point-from-layer (c-> nstextfield? any/c any/c)]
  [nstextfield-convert-point-to-backing (c-> nstextfield? any/c any/c)]
  [nstextfield-convert-point-to-layer (c-> nstextfield? any/c any/c)]
  [nstextfield-convert-rect-from-view (c-> nstextfield? any/c (or/c string? objc-object? #f) any/c)]
  [nstextfield-convert-rect-to-view (c-> nstextfield? any/c (or/c string? objc-object? #f) any/c)]
  [nstextfield-convert-rect-from-backing (c-> nstextfield? any/c any/c)]
  [nstextfield-convert-rect-from-layer (c-> nstextfield? any/c any/c)]
  [nstextfield-convert-rect-to-backing (c-> nstextfield? any/c any/c)]
  [nstextfield-convert-rect-to-layer (c-> nstextfield? any/c any/c)]
  [nstextfield-convert-size-from-view (c-> nstextfield? any/c (or/c string? objc-object? #f) any/c)]
  [nstextfield-convert-size-to-view (c-> nstextfield? any/c (or/c string? objc-object? #f) any/c)]
  [nstextfield-convert-size-from-backing (c-> nstextfield? any/c any/c)]
  [nstextfield-convert-size-from-layer (c-> nstextfield? any/c any/c)]
  [nstextfield-convert-size-to-backing (c-> nstextfield? any/c any/c)]
  [nstextfield-convert-size-to-layer (c-> nstextfield? any/c any/c)]
  [nstextfield-cursor-update (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-backward (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-backward-by-decomposing-previous-character (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-forward (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-to-beginning-of-line (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-to-beginning-of-paragraph (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-to-end-of-line (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-to-end-of-paragraph (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-to-mark (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-word-backward (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-word-forward (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-did-add-subview (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-did-close-menu-with-event (c-> nstextfield? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstextfield-display! (c-> nstextfield? void?)]
  [nstextfield-display-if-needed! (c-> nstextfield? void?)]
  [nstextfield-display-if-needed-ignoring-opacity! (c-> nstextfield? void?)]
  [nstextfield-display-if-needed-in-rect! (c-> nstextfield? any/c void?)]
  [nstextfield-display-if-needed-in-rect-ignoring-opacity! (c-> nstextfield? any/c void?)]
  [nstextfield-display-rect! (c-> nstextfield? any/c void?)]
  [nstextfield-display-rect-ignoring-opacity! (c-> nstextfield? any/c void?)]
  [nstextfield-display-rect-ignoring-opacity-in-context! (c-> nstextfield? any/c (or/c string? objc-object? #f) void?)]
  [nstextfield-do-command-by-selector (c-> nstextfield? string? void?)]
  [nstextfield-dragging-ended (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-dragging-entered (c-> nstextfield? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nstextfield-dragging-exited (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-dragging-updated (c-> nstextfield? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nstextfield-draw-rect (c-> nstextfield? any/c void?)]
  [nstextfield-draw-with-expansion-frame-in-view (c-> nstextfield? any/c (or/c string? objc-object? #f) void?)]
  [nstextfield-effective-appearance (c-> nstextfield? (or/c nsappearance? objc-nil?))]
  [nstextfield-encode-with-coder (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-end-gesture-with-event! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-expansion-frame-with-frame (c-> nstextfield? any/c any/c)]
  [nstextfield-flags-changed (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-flush-buffered-key-events (c-> nstextfield? void?)]
  [nstextfield-get-rects-being-drawn-count (c-> nstextfield? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nstextfield-get-rects-exposed-during-live-resize-count (c-> nstextfield? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nstextfield-help-requested (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-hit-test (c-> nstextfield? any/c (or/c nsview? objc-nil?))]
  [nstextfield-identifier (c-> nstextfield? (or/c nsstring? objc-nil?))]
  [nstextfield-indent (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-backtab! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-container-break! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-double-quote-ignoring-substitution! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-line-break! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-newline! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-newline-ignoring-field-editor! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-paragraph-separator! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-single-quote-ignoring-substitution! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-tab! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-tab-ignoring-field-editor! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-text! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-interpret-key-events (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-is-accessibility-alternate-ui-visible (c-> nstextfield? boolean?)]
  [nstextfield-is-accessibility-disclosed (c-> nstextfield? boolean?)]
  [nstextfield-is-accessibility-edited (c-> nstextfield? boolean?)]
  [nstextfield-is-accessibility-element (c-> nstextfield? boolean?)]
  [nstextfield-is-accessibility-enabled (c-> nstextfield? boolean?)]
  [nstextfield-is-accessibility-expanded (c-> nstextfield? boolean?)]
  [nstextfield-is-accessibility-focused (c-> nstextfield? boolean?)]
  [nstextfield-is-accessibility-frontmost (c-> nstextfield? boolean?)]
  [nstextfield-is-accessibility-hidden (c-> nstextfield? boolean?)]
  [nstextfield-is-accessibility-main (c-> nstextfield? boolean?)]
  [nstextfield-is-accessibility-minimized (c-> nstextfield? boolean?)]
  [nstextfield-is-accessibility-modal (c-> nstextfield? boolean?)]
  [nstextfield-is-accessibility-ordered-by-row (c-> nstextfield? boolean?)]
  [nstextfield-is-accessibility-protected-content (c-> nstextfield? boolean?)]
  [nstextfield-is-accessibility-required (c-> nstextfield? boolean?)]
  [nstextfield-is-accessibility-selected (c-> nstextfield? boolean?)]
  [nstextfield-is-accessibility-selector-allowed (c-> nstextfield? string? boolean?)]
  [nstextfield-is-bezeled (c-> nstextfield? boolean?)]
  [nstextfield-is-bordered (c-> nstextfield? boolean?)]
  [nstextfield-is-continuous (c-> nstextfield? boolean?)]
  [nstextfield-is-descendant-of (c-> nstextfield? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-is-editable (c-> nstextfield? boolean?)]
  [nstextfield-is-enabled (c-> nstextfield? boolean?)]
  [nstextfield-is-flipped (c-> nstextfield? boolean?)]
  [nstextfield-is-hidden (c-> nstextfield? boolean?)]
  [nstextfield-is-hidden-or-has-hidden-ancestor (c-> nstextfield? boolean?)]
  [nstextfield-is-highlighted (c-> nstextfield? boolean?)]
  [nstextfield-is-opaque (c-> nstextfield? boolean?)]
  [nstextfield-is-rotated-from-base (c-> nstextfield? boolean?)]
  [nstextfield-is-rotated-or-scaled-from-base (c-> nstextfield? boolean?)]
  [nstextfield-is-selectable (c-> nstextfield? boolean?)]
  [nstextfield-key-down (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-key-up (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-layout (c-> nstextfield? void?)]
  [nstextfield-layout-subtree-if-needed (c-> nstextfield? void?)]
  [nstextfield-lowercase-word (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-magnify-with-event (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-make-backing-layer (c-> nstextfield? (or/c calayer? objc-nil?))]
  [nstextfield-make-base-writing-direction-left-to-right (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-make-base-writing-direction-natural (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-make-base-writing-direction-right-to-left (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-make-text-writing-direction-left-to-right (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-make-text-writing-direction-natural (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-make-text-writing-direction-right-to-left (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-menu-for-event (c-> nstextfield? (or/c string? objc-object? #f) (or/c nsmenu? objc-nil?))]
  [nstextfield-mouse-in-rect (c-> nstextfield? any/c any/c boolean?)]
  [nstextfield-mouse-cancelled (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-mouse-down (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-mouse-dragged (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-mouse-entered (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-mouse-exited (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-mouse-moved (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-mouse-up (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-backward! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-backward-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-down! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-down-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-forward! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-forward-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-left! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-left-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-paragraph-backward-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-paragraph-forward-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-right! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-right-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-beginning-of-document! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-beginning-of-document-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-beginning-of-line! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-beginning-of-line-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-beginning-of-paragraph! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-beginning-of-paragraph-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-end-of-document! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-end-of-document-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-end-of-line! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-end-of-line-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-end-of-paragraph! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-end-of-paragraph-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-left-end-of-line! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-left-end-of-line-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-right-end-of-line! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-right-end-of-line-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-up! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-up-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-word-backward! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-word-backward-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-word-forward! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-word-forward-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-word-left! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-word-left-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-word-right! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-word-right-and-modify-selection! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-needs-to-draw-rect (c-> nstextfield? any/c boolean?)]
  [nstextfield-no-responder-for (c-> nstextfield? string? void?)]
  [nstextfield-other-mouse-down (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-other-mouse-dragged (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-other-mouse-up (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-page-down (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-page-down-and-modify-selection (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-page-up (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-page-up-and-modify-selection (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-perform-click! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-perform-drag-operation! (c-> nstextfield? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-perform-key-equivalent! (c-> nstextfield? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-prepare-content-in-rect (c-> nstextfield? any/c void?)]
  [nstextfield-prepare-for-drag-operation (c-> nstextfield? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-prepare-for-reuse (c-> nstextfield? void?)]
  [nstextfield-pressure-change-with-event (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-quick-look-preview-items (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-quick-look-with-event (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-rect-for-smart-magnification-at-point-in-rect (c-> nstextfield? any/c any/c any/c)]
  [nstextfield-remove-all-tool-tips! (c-> nstextfield? void?)]
  [nstextfield-remove-from-superview! (c-> nstextfield? void?)]
  [nstextfield-remove-from-superview-without-needing-display! (c-> nstextfield? void?)]
  [nstextfield-remove-tool-tip! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-replace-subview-with! (c-> nstextfield? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstextfield-resign-first-responder (c-> nstextfield? boolean?)]
  [nstextfield-resize-subviews-with-old-size (c-> nstextfield? any/c void?)]
  [nstextfield-resize-with-old-superview-size (c-> nstextfield? any/c void?)]
  [nstextfield-restore-user-activity-state (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-right-mouse-down (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-right-mouse-dragged (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-right-mouse-up (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-rotate-by-angle (c-> nstextfield? real? void?)]
  [nstextfield-rotate-with-event (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-scale-unit-square-to-size (c-> nstextfield? any/c void?)]
  [nstextfield-scroll-line-down (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-scroll-line-up (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-scroll-page-down (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-scroll-page-up (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-scroll-point (c-> nstextfield? any/c void?)]
  [nstextfield-scroll-rect-to-visible (c-> nstextfield? any/c boolean?)]
  [nstextfield-scroll-to-beginning-of-document (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-scroll-to-end-of-document (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-scroll-wheel (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-select-all (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-select-line (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-select-paragraph (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-select-text (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-select-to-mark (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-select-word (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-send-action-to (c-> nstextfield? string? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-send-action-on (c-> nstextfield? exact-nonnegative-integer? exact-integer?)]
  [nstextfield-set-accessibility-activation-point! (c-> nstextfield? any/c void?)]
  [nstextfield-set-accessibility-allowed-values! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-alternate-ui-visible! (c-> nstextfield? boolean? void?)]
  [nstextfield-set-accessibility-application-focused-ui-element! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-attributed-user-input-labels! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-cancel-button! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-children! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-children-in-navigation-order! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-clear-button! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-close-button! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-column-count! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-set-accessibility-column-header-ui-elements! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-column-index-range! (c-> nstextfield? any/c void?)]
  [nstextfield-set-accessibility-column-titles! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-columns! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-contents! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-critical-value! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-custom-actions! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-custom-rotors! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-decrement-button! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-default-button! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-disclosed! (c-> nstextfield? boolean? void?)]
  [nstextfield-set-accessibility-disclosed-by-row! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-disclosed-rows! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-disclosure-level! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-set-accessibility-document! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-edited! (c-> nstextfield? boolean? void?)]
  [nstextfield-set-accessibility-element! (c-> nstextfield? boolean? void?)]
  [nstextfield-set-accessibility-enabled! (c-> nstextfield? boolean? void?)]
  [nstextfield-set-accessibility-expanded! (c-> nstextfield? boolean? void?)]
  [nstextfield-set-accessibility-extras-menu-bar! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-filename! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-focused! (c-> nstextfield? boolean? void?)]
  [nstextfield-set-accessibility-focused-window! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-frame! (c-> nstextfield? any/c void?)]
  [nstextfield-set-accessibility-frontmost! (c-> nstextfield? boolean? void?)]
  [nstextfield-set-accessibility-full-screen-button! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-grow-area! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-handles! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-header! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-help! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-hidden! (c-> nstextfield? boolean? void?)]
  [nstextfield-set-accessibility-horizontal-scroll-bar! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-horizontal-unit-description! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-horizontal-units! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-set-accessibility-identifier! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-increment-button! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-index! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-set-accessibility-insertion-point-line-number! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-set-accessibility-label! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-label-ui-elements! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-label-value! (c-> nstextfield? real? void?)]
  [nstextfield-set-accessibility-linked-ui-elements! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-main! (c-> nstextfield? boolean? void?)]
  [nstextfield-set-accessibility-main-window! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-marker-group-ui-element! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-marker-type-description! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-marker-ui-elements! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-marker-values! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-max-value! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-menu-bar! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-min-value! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-minimize-button! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-minimized! (c-> nstextfield? boolean? void?)]
  [nstextfield-set-accessibility-modal! (c-> nstextfield? boolean? void?)]
  [nstextfield-set-accessibility-next-contents! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-number-of-characters! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-set-accessibility-ordered-by-row! (c-> nstextfield? boolean? void?)]
  [nstextfield-set-accessibility-orientation! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-set-accessibility-overflow-button! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-parent! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-placeholder-value! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-previous-contents! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-protected-content! (c-> nstextfield? boolean? void?)]
  [nstextfield-set-accessibility-proxy! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-required! (c-> nstextfield? boolean? void?)]
  [nstextfield-set-accessibility-role! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-role-description! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-row-count! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-set-accessibility-row-header-ui-elements! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-row-index-range! (c-> nstextfield? any/c void?)]
  [nstextfield-set-accessibility-rows! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-ruler-marker-type! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-set-accessibility-search-button! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-search-menu! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-selected! (c-> nstextfield? boolean? void?)]
  [nstextfield-set-accessibility-selected-cells! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-selected-children! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-selected-columns! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-selected-rows! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-selected-text! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-selected-text-range! (c-> nstextfield? any/c void?)]
  [nstextfield-set-accessibility-selected-text-ranges! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-serves-as-title-for-ui-elements! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-shared-character-range! (c-> nstextfield? any/c void?)]
  [nstextfield-set-accessibility-shared-focus-elements! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-shared-text-ui-elements! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-shown-menu! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-sort-direction! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-set-accessibility-splitters! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-subrole! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-tabs! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-title! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-title-ui-element! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-toolbar-button! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-top-level-ui-element! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-url! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-unit-description! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-units! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-set-accessibility-user-input-labels! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-value! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-value-description! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-vertical-scroll-bar! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-vertical-unit-description! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-vertical-units! (c-> nstextfield? exact-integer? void?)]
  [nstextfield-set-accessibility-visible-cells! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-visible-character-range! (c-> nstextfield? any/c void?)]
  [nstextfield-set-accessibility-visible-children! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-visible-columns! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-visible-rows! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-warning-value! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-window! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-windows! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-zoom-button! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-animations! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-appearance! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-bounds-origin! (c-> nstextfield? any/c void?)]
  [nstextfield-set-bounds-size! (c-> nstextfield? any/c void?)]
  [nstextfield-set-content-type! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-frame-origin! (c-> nstextfield? any/c void?)]
  [nstextfield-set-frame-size! (c-> nstextfield? any/c void?)]
  [nstextfield-set-identifier! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-mark! (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-needs-display-in-rect! (c-> nstextfield? any/c void?)]
  [nstextfield-should-be-treated-as-ink-event (c-> nstextfield? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-should-delay-window-ordering-for-event (c-> nstextfield? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-show-context-help (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-show-context-menu-for-selection (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-size-that-fits (c-> nstextfield? any/c any/c)]
  [nstextfield-size-to-fit (c-> nstextfield? void?)]
  [nstextfield-smart-magnify-with-event (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-sort-subviews-using-function-context (c-> nstextfield? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nstextfield-supplemental-target-for-action-sender (c-> nstextfield? string? (or/c string? objc-object? #f) any/c)]
  [nstextfield-swap-with-mark (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-swipe-with-event (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-tablet-point (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-tablet-proximity (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-take-double-value-from (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-take-float-value-from (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-take-int-value-from (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-take-integer-value-from (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-take-object-value-from (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-take-string-value-from (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-text-did-begin-editing (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-text-did-change (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-text-did-end-editing (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-text-should-begin-editing (c-> nstextfield? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-text-should-end-editing (c-> nstextfield? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-touches-began-with-event (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-touches-cancelled-with-event (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-touches-ended-with-event (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-touches-moved-with-event (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-translate-origin-to-point (c-> nstextfield? any/c void?)]
  [nstextfield-translate-rects-needing-display-in-rect-by (c-> nstextfield? any/c any/c void?)]
  [nstextfield-transpose (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-transpose-words (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-try-to-perform-with (c-> nstextfield? string? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-update-dragging-items-for-drag (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-update-layer (c-> nstextfield? void?)]
  [nstextfield-uppercase-word (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-valid-requestor-for-send-type-return-type (c-> nstextfield? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nstextfield-validate-user-interface-item (c-> nstextfield? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-view-did-change-backing-properties (c-> nstextfield? void?)]
  [nstextfield-view-did-change-effective-appearance (c-> nstextfield? void?)]
  [nstextfield-view-did-end-live-resize (c-> nstextfield? void?)]
  [nstextfield-view-did-hide (c-> nstextfield? void?)]
  [nstextfield-view-did-move-to-superview (c-> nstextfield? void?)]
  [nstextfield-view-did-move-to-window (c-> nstextfield? void?)]
  [nstextfield-view-did-unhide (c-> nstextfield? void?)]
  [nstextfield-view-will-draw (c-> nstextfield? void?)]
  [nstextfield-view-will-move-to-superview (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-view-will-move-to-window (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-view-will-start-live-resize (c-> nstextfield? void?)]
  [nstextfield-view-with-tag (c-> nstextfield? exact-integer? any/c)]
  [nstextfield-wants-forwarded-scroll-events-for-axis (c-> nstextfield? exact-integer? boolean?)]
  [nstextfield-wants-periodic-dragging-updates (c-> nstextfield? boolean?)]
  [nstextfield-wants-scroll-events-for-swipe-tracking-on-axis (c-> nstextfield? exact-integer? boolean?)]
  [nstextfield-will-open-menu-with-event (c-> nstextfield? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstextfield-will-remove-subview (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-yank (c-> nstextfield? (or/c string? objc-object? #f) void?)]
  [nstextfield-default-animation-for-key (c-> (or/c string? objc-object? #f) any/c)]
  [nstextfield-is-compatible-with-responsive-scrolling (c-> boolean?)]
  )

;; --- Class reference ---
(import-class NSTextField)

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
(define (make-nstextfield-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSTextField alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nstextfield-init-with-frame frame-rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (tell NSTextField alloc)) (id->ffi2-ptr (sel_registerName "initWithFrame:")) (id->ffi2-ptr frame-rect)))
   #:retained #t))


;; --- Properties ---
(define (nstextfield-accepts-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsFirstResponder"))))
(define (nstextfield-accepts-touch-events self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsTouchEvents"))))
(define (nstextfield-set-accepts-touch-events! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAcceptsTouchEvents:")) value))
(define (nstextfield-action self)
  (ptr_t->cpointer (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "action")))))
(define (nstextfield-set-action! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAction:")) (id->ffi2-ptr (sel_registerName value))))
(define (nstextfield-additional-safe-area-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "additionalSafeAreaInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nstextfield-set-additional-safe-area-insets! self value)
  (aw_racket_msg_E_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAdditionalSafeAreaInsets:")) (id->ffi2-ptr value)))
(define (nstextfield-alignment self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignment"))))
(define (nstextfield-set-alignment! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlignment:")) value))
(define (nstextfield-alignment-rect-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignmentRectInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nstextfield-allowed-touch-types self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowedTouchTypes"))))
(define (nstextfield-set-allowed-touch-types! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowedTouchTypes:")) value))
(define (nstextfield-allows-character-picker-touch-bar-item self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsCharacterPickerTouchBarItem"))))
(define (nstextfield-set-allows-character-picker-touch-bar-item! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsCharacterPickerTouchBarItem:")) value))
(define (nstextfield-allows-default-tightening-for-truncation self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsDefaultTighteningForTruncation"))))
(define (nstextfield-set-allows-default-tightening-for-truncation! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsDefaultTighteningForTruncation:")) value))
(define (nstextfield-allows-editing-text-attributes self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsEditingTextAttributes"))))
(define (nstextfield-set-allows-editing-text-attributes! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsEditingTextAttributes:")) value))
(define (nstextfield-allows-expansion-tool-tips self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsExpansionToolTips"))))
(define (nstextfield-set-allows-expansion-tool-tips! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsExpansionToolTips:")) value))
(define (nstextfield-allows-vibrancy self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsVibrancy"))))
(define (nstextfield-allows-writing-tools self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsWritingTools"))))
(define (nstextfield-set-allows-writing-tools! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsWritingTools:")) value))
(define (nstextfield-allows-writing-tools-affordance self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsWritingToolsAffordance"))))
(define (nstextfield-set-allows-writing-tools-affordance! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsWritingToolsAffordance:")) value))
(define (nstextfield-alpha-value self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alphaValue"))))
(define (nstextfield-set-alpha-value! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlphaValue:")) value))
(define (nstextfield-attributed-string-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "attributedStringValue"))))))
(define (nstextfield-set-attributed-string-value! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAttributedStringValue:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-automatic-text-completion-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "automaticTextCompletionEnabled"))))
(define (nstextfield-set-automatic-text-completion-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutomaticTextCompletionEnabled:")) value))
(define (nstextfield-autoresizes-subviews self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoresizesSubviews"))))
(define (nstextfield-set-autoresizes-subviews! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutoresizesSubviews:")) value))
(define (nstextfield-autoresizing-mask self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoresizingMask"))))
(define (nstextfield-set-autoresizing-mask! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutoresizingMask:")) value))
(define (nstextfield-background-color self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backgroundColor"))))))
(define (nstextfield-set-background-color! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBackgroundColor:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-background-filters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backgroundFilters"))))))
(define (nstextfield-set-background-filters! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBackgroundFilters:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-base-writing-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "baseWritingDirection"))))
(define (nstextfield-set-base-writing-direction! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBaseWritingDirection:")) value))
(define (nstextfield-baseline-offset-from-bottom self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "baselineOffsetFromBottom"))))
(define (nstextfield-bezel-style self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bezelStyle"))))
(define (nstextfield-set-bezel-style! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBezelStyle:")) value))
(define (nstextfield-bezeled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bezeled"))))
(define (nstextfield-set-bezeled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBezeled:")) value))
(define (nstextfield-bordered self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bordered"))))
(define (nstextfield-set-bordered! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBordered:")) value))
(define (nstextfield-bottom-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bottomAnchor"))))))
(define (nstextfield-bounds self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bounds")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-set-bounds! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBounds:")) (id->ffi2-ptr value)))
(define (nstextfield-bounds-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "boundsRotation"))))
(define (nstextfield-set-bounds-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsRotation:")) value))
(define (nstextfield-can-become-key-view self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canBecomeKeyView"))))
(define (nstextfield-can-draw self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDraw"))))
(define (nstextfield-can-draw-concurrently self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDrawConcurrently"))))
(define (nstextfield-set-can-draw-concurrently! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCanDrawConcurrently:")) value))
(define (nstextfield-can-draw-subviews-into-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDrawSubviewsIntoLayer"))))
(define (nstextfield-set-can-draw-subviews-into-layer! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCanDrawSubviewsIntoLayer:")) value))
(define (nstextfield-candidate-list-touch-bar-item self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "candidateListTouchBarItem"))))))
(define (nstextfield-cell self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cell"))))))
(define (nstextfield-set-cell! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCell:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-cell-class)
  (ptr_t->cpointer (aw_racket_msg_0_P (id->ffi2-ptr NSTextField) (id->ffi2-ptr (sel_registerName "cellClass")))))
(define (nstextfield-set-cell-class! value)
  (aw_racket_msg_P_v (id->ffi2-ptr NSTextField) (id->ffi2-ptr (sel_registerName "setCellClass:")) (id->ffi2-ptr value)))
(define (nstextfield-center-x-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerXAnchor"))))))
(define (nstextfield-center-y-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerYAnchor"))))))
(define (nstextfield-clips-to-bounds self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "clipsToBounds"))))
(define (nstextfield-set-clips-to-bounds! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setClipsToBounds:")) value))
(define (nstextfield-compatible-with-responsive-scrolling)
  (aw_racket_msg_0_b (id->ffi2-ptr NSTextField) (id->ffi2-ptr (sel_registerName "compatibleWithResponsiveScrolling"))))
(define (nstextfield-compositing-filter self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "compositingFilter"))))))
(define (nstextfield-set-compositing-filter! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCompositingFilter:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-constraints self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "constraints"))))))
(define (nstextfield-content-filters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentFilters"))))))
(define (nstextfield-set-content-filters! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentFilters:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-continuous self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "continuous"))))
(define (nstextfield-set-continuous! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContinuous:")) value))
(define (nstextfield-control-size self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "controlSize"))))
(define (nstextfield-set-control-size! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setControlSize:")) value))
(define (nstextfield-default-focus-ring-type)
  (aw_racket_msg_0_Q (id->ffi2-ptr NSTextField) (id->ffi2-ptr (sel_registerName "defaultFocusRingType"))))
(define (nstextfield-default-menu)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSTextField) (id->ffi2-ptr (sel_registerName "defaultMenu"))))))
(define (nstextfield-delegate self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "delegate"))))))
(define (nstextfield-set-delegate! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDelegate:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-double-value self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "doubleValue"))))
(define (nstextfield-set-double-value! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDoubleValue:")) value))
(define (nstextfield-drawing-find-indicator self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawingFindIndicator"))))
(define (nstextfield-draws-background self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawsBackground"))))
(define (nstextfield-set-draws-background! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDrawsBackground:")) value))
(define (nstextfield-editable self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "editable"))))
(define (nstextfield-set-editable! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setEditable:")) value))
(define (nstextfield-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enabled"))))
(define (nstextfield-set-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setEnabled:")) value))
(define (nstextfield-enclosing-menu-item self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enclosingMenuItem"))))))
(define (nstextfield-enclosing-scroll-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enclosingScrollView"))))))
(define (nstextfield-first-baseline-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstBaselineAnchor"))))))
(define (nstextfield-first-baseline-offset-from-top self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstBaselineOffsetFromTop"))))
(define (nstextfield-fitting-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fittingSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextfield-flipped self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flipped"))))
(define (nstextfield-float-value self)
  (aw_racket_msg_0_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "floatValue"))))
(define (nstextfield-set-float-value! self value)
  (aw_racket_msg_f_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFloatValue:")) value))
(define (nstextfield-focus-ring-mask-bounds self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "focusRingMaskBounds")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-focus-ring-type self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "focusRingType"))))
(define (nstextfield-set-focus-ring-type! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFocusRingType:")) value))
(define (nstextfield-focus-view)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSTextField) (id->ffi2-ptr (sel_registerName "focusView"))))))
(define (nstextfield-font self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "font"))))))
(define (nstextfield-set-font! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFont:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-formatter self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "formatter"))))))
(define (nstextfield-set-formatter! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFormatter:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-set-frame! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrame:")) (id->ffi2-ptr value)))
(define (nstextfield-frame-center-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameCenterRotation"))))
(define (nstextfield-set-frame-center-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameCenterRotation:")) value))
(define (nstextfield-frame-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameRotation"))))
(define (nstextfield-set-frame-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameRotation:")) value))
(define (nstextfield-gesture-recognizers self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "gestureRecognizers"))))))
(define (nstextfield-set-gesture-recognizers! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setGestureRecognizers:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-has-ambiguous-layout self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasAmbiguousLayout"))))
(define (nstextfield-height-adjust-limit self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "heightAdjustLimit"))))
(define (nstextfield-height-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "heightAnchor"))))))
(define (nstextfield-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hidden"))))
(define (nstextfield-set-hidden! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHidden:")) value))
(define (nstextfield-hidden-or-has-hidden-ancestor self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hiddenOrHasHiddenAncestor"))))
(define (nstextfield-highlighted self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "highlighted"))))
(define (nstextfield-set-highlighted! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHighlighted:")) value))
(define (nstextfield-horizontal-content-size-constraint-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "horizontalContentSizeConstraintActive"))))
(define (nstextfield-set-horizontal-content-size-constraint-active! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHorizontalContentSizeConstraintActive:")) value))
(define (nstextfield-ignores-multi-click self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "ignoresMultiClick"))))
(define (nstextfield-set-ignores-multi-click! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIgnoresMultiClick:")) value))
(define (nstextfield-imports-graphics self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "importsGraphics"))))
(define (nstextfield-set-imports-graphics! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setImportsGraphics:")) value))
(define (nstextfield-in-full-screen-mode self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inFullScreenMode"))))
(define (nstextfield-in-live-resize self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inLiveResize"))))
(define (nstextfield-input-context self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inputContext"))))))
(define (nstextfield-int-value self)
  (aw_racket_msg_0_i (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "intValue"))))
(define (nstextfield-set-int-value! self value)
  (aw_racket_msg_i_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIntValue:")) value))
(define (nstextfield-integer-value self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "integerValue"))))
(define (nstextfield-set-integer-value! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIntegerValue:")) value))
(define (nstextfield-intrinsic-content-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "intrinsicContentSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextfield-last-baseline-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastBaselineAnchor"))))))
(define (nstextfield-last-baseline-offset-from-bottom self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastBaselineOffsetFromBottom"))))
(define (nstextfield-layer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layer"))))))
(define (nstextfield-set-layer! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayer:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-layer-contents-placement self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerContentsPlacement"))))
(define (nstextfield-set-layer-contents-placement! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerContentsPlacement:")) value))
(define (nstextfield-layer-contents-redraw-policy self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerContentsRedrawPolicy"))))
(define (nstextfield-set-layer-contents-redraw-policy! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerContentsRedrawPolicy:")) value))
(define (nstextfield-layer-uses-core-image-filters self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerUsesCoreImageFilters"))))
(define (nstextfield-set-layer-uses-core-image-filters! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerUsesCoreImageFilters:")) value))
(define (nstextfield-layout-guides self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutGuides"))))))
(define (nstextfield-layout-margins-guide self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutMarginsGuide"))))))
(define (nstextfield-leading-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "leadingAnchor"))))))
(define (nstextfield-left-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "leftAnchor"))))))
(define (nstextfield-line-break-mode self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lineBreakMode"))))
(define (nstextfield-set-line-break-mode! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLineBreakMode:")) value))
(define (nstextfield-line-break-strategy self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lineBreakStrategy"))))
(define (nstextfield-set-line-break-strategy! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLineBreakStrategy:")) value))
(define (nstextfield-maximum-number-of-lines self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "maximumNumberOfLines"))))
(define (nstextfield-set-maximum-number-of-lines! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMaximumNumberOfLines:")) value))
(define (nstextfield-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menu"))))))
(define (nstextfield-set-menu! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMenu:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-mouse-down-can-move-window self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDownCanMoveWindow"))))
(define (nstextfield-needs-display self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsDisplay"))))
(define (nstextfield-set-needs-display! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsDisplay:")) value))
(define (nstextfield-needs-layout self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsLayout"))))
(define (nstextfield-set-needs-layout! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsLayout:")) value))
(define (nstextfield-needs-panel-to-become-key self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsPanelToBecomeKey"))))
(define (nstextfield-needs-update-constraints self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsUpdateConstraints"))))
(define (nstextfield-set-needs-update-constraints! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsUpdateConstraints:")) value))
(define (nstextfield-next-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextKeyView"))))))
(define (nstextfield-set-next-key-view! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextKeyView:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-next-responder self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextResponder"))))))
(define (nstextfield-set-next-responder! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextResponder:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-next-valid-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextValidKeyView"))))))
(define (nstextfield-object-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "objectValue"))))))
(define (nstextfield-set-object-value! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setObjectValue:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-opaque self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "opaque"))))
(define (nstextfield-opaque-ancestor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "opaqueAncestor"))))))
(define (nstextfield-page-footer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageFooter"))))))
(define (nstextfield-page-header self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageHeader"))))))
(define (nstextfield-placeholder-attributed-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "placeholderAttributedString"))))))
(define (nstextfield-set-placeholder-attributed-string! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPlaceholderAttributedString:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-placeholder-attributed-strings self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "placeholderAttributedStrings"))))))
(define (nstextfield-set-placeholder-attributed-strings! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPlaceholderAttributedStrings:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-placeholder-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "placeholderString"))))))
(define (nstextfield-set-placeholder-string! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPlaceholderString:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-placeholder-strings self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "placeholderStrings"))))))
(define (nstextfield-set-placeholder-strings! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPlaceholderStrings:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-posts-bounds-changed-notifications self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "postsBoundsChangedNotifications"))))
(define (nstextfield-set-posts-bounds-changed-notifications! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPostsBoundsChangedNotifications:")) value))
(define (nstextfield-posts-frame-changed-notifications self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "postsFrameChangedNotifications"))))
(define (nstextfield-set-posts-frame-changed-notifications! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPostsFrameChangedNotifications:")) value))
(define (nstextfield-preferred-max-layout-width self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preferredMaxLayoutWidth"))))
(define (nstextfield-set-preferred-max-layout-width! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPreferredMaxLayoutWidth:")) value))
(define (nstextfield-prefers-compact-control-size-metrics self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prefersCompactControlSizeMetrics"))))
(define (nstextfield-set-prefers-compact-control-size-metrics! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPrefersCompactControlSizeMetrics:")) value))
(define (nstextfield-prepared-content-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preparedContentRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-set-prepared-content-rect! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPreparedContentRect:")) (id->ffi2-ptr value)))
(define (nstextfield-preserves-content-during-live-resize self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preservesContentDuringLiveResize"))))
(define (nstextfield-pressure-configuration self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pressureConfiguration"))))))
(define (nstextfield-set-pressure-configuration! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPressureConfiguration:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-previous-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "previousKeyView"))))))
(define (nstextfield-previous-valid-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "previousValidKeyView"))))))
(define (nstextfield-print-job-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "printJobTitle"))))))
(define (nstextfield-rect-preserved-during-live-resize self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectPreservedDuringLiveResize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-refuses-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "refusesFirstResponder"))))
(define (nstextfield-set-refuses-first-responder! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setRefusesFirstResponder:")) value))
(define (nstextfield-registered-dragged-types self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "registeredDraggedTypes"))))))
(define (nstextfield-requires-constraint-based-layout)
  (aw_racket_msg_0_b (id->ffi2-ptr NSTextField) (id->ffi2-ptr (sel_registerName "requiresConstraintBasedLayout"))))
(define (nstextfield-resolves-natural-alignment-with-base-writing-direction self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resolvesNaturalAlignmentWithBaseWritingDirection"))))
(define (nstextfield-set-resolves-natural-alignment-with-base-writing-direction! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setResolvesNaturalAlignmentWithBaseWritingDirection:")) value))
(define (nstextfield-restorable-state-key-paths)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSTextField) (id->ffi2-ptr (sel_registerName "restorableStateKeyPaths"))))))
(define (nstextfield-right-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightAnchor"))))))
(define (nstextfield-rotated-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotatedFromBase"))))
(define (nstextfield-rotated-or-scaled-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotatedOrScaledFromBase"))))
(define (nstextfield-safe-area-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nstextfield-safe-area-layout-guide self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaLayoutGuide"))))))
(define (nstextfield-safe-area-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-selectable self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectable"))))
(define (nstextfield-set-selectable! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSelectable:")) value))
(define (nstextfield-shadow self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shadow"))))))
(define (nstextfield-set-shadow! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShadow:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-string-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringValue"))))))
(define (nstextfield-set-string-value! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setStringValue:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-subviews self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "subviews"))))))
(define (nstextfield-set-subviews! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSubviews:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-suggestions-delegate self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "suggestionsDelegate"))))))
(define (nstextfield-set-suggestions-delegate! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSuggestionsDelegate:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-superview self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "superview"))))))
(define (nstextfield-tag self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tag"))))
(define (nstextfield-set-tag! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTag:")) value))
(define (nstextfield-target self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "target"))))))
(define (nstextfield-set-target! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTarget:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-text-color self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textColor"))))))
(define (nstextfield-set-text-color! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTextColor:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-tool-tip self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "toolTip"))))))
(define (nstextfield-set-tool-tip! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setToolTip:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-top-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "topAnchor"))))))
(define (nstextfield-touch-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchBar"))))))
(define (nstextfield-set-touch-bar! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTouchBar:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-tracking-areas self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "trackingAreas"))))))
(define (nstextfield-trailing-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "trailingAnchor"))))))
(define (nstextfield-translates-autoresizing-mask-into-constraints self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translatesAutoresizingMaskIntoConstraints"))))
(define (nstextfield-set-translates-autoresizing-mask-into-constraints! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTranslatesAutoresizingMaskIntoConstraints:")) value))
(define (nstextfield-undo-manager self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "undoManager"))))))
(define (nstextfield-user-activity self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userActivity"))))))
(define (nstextfield-set-user-activity! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserActivity:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextfield-user-interface-layout-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userInterfaceLayoutDirection"))))
(define (nstextfield-set-user-interface-layout-direction! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserInterfaceLayoutDirection:")) value))
(define (nstextfield-uses-single-line-mode self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "usesSingleLineMode"))))
(define (nstextfield-set-uses-single-line-mode! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUsesSingleLineMode:")) value))
(define (nstextfield-vertical-content-size-constraint-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "verticalContentSizeConstraintActive"))))
(define (nstextfield-set-vertical-content-size-constraint-active! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setVerticalContentSizeConstraintActive:")) value))
(define (nstextfield-visible-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "visibleRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-wants-best-resolution-open-gl-surface self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsBestResolutionOpenGLSurface"))))
(define (nstextfield-set-wants-best-resolution-open-gl-surface! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsBestResolutionOpenGLSurface:")) value))
(define (nstextfield-wants-default-clipping self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsDefaultClipping"))))
(define (nstextfield-wants-extended-dynamic-range-open-gl-surface self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsExtendedDynamicRangeOpenGLSurface"))))
(define (nstextfield-set-wants-extended-dynamic-range-open-gl-surface! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsExtendedDynamicRangeOpenGLSurface:")) value))
(define (nstextfield-wants-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsLayer"))))
(define (nstextfield-set-wants-layer! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsLayer:")) value))
(define (nstextfield-wants-resting-touches self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsRestingTouches"))))
(define (nstextfield-set-wants-resting-touches! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsRestingTouches:")) value))
(define (nstextfield-wants-update-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsUpdateLayer"))))
(define (nstextfield-width-adjust-limit self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "widthAdjustLimit"))))
(define (nstextfield-width-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "widthAnchor"))))))
(define (nstextfield-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "window"))))))
(define (nstextfield-writing-tools-coordinator self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writingToolsCoordinator"))))))
(define (nstextfield-set-writing-tools-coordinator! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWritingToolsCoordinator:")) (id->ffi2-ptr (coerce-arg value))))

;; --- Instance methods ---
(define (nstextfield-accepts-first-mouse self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsFirstMouse:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-accessibility-activation-point self)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_0_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityActivationPoint")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextfield-accessibility-allowed-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAllowedValues"))))
   ))
(define (nstextfield-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityApplicationFocusedUIElement"))))
   ))
(define (nstextfield-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nstextfield-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedUserInputLabels"))))
   ))
(define (nstextfield-accessibility-cancel-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCancelButton"))))
   ))
(define (nstextfield-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_qq_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCellForColumn:row:")) column row))
   ))
(define (nstextfield-accessibility-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildren"))))
   ))
(define (nstextfield-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildrenInNavigationOrder"))))
   ))
(define (nstextfield-accessibility-clear-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityClearButton"))))
   ))
(define (nstextfield-accessibility-close-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCloseButton"))))
   ))
(define (nstextfield-accessibility-column-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnCount"))))
(define (nstextfield-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnHeaderUIElements"))))
   ))
(define (nstextfield-accessibility-column-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextfield-accessibility-column-titles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnTitles"))))
   ))
(define (nstextfield-accessibility-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumns"))))
   ))
(define (nstextfield-accessibility-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityContents"))))
   ))
(define (nstextfield-accessibility-critical-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCriticalValue"))))
   ))
(define (nstextfield-accessibility-custom-actions self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomActions"))))
   ))
(define (nstextfield-accessibility-custom-rotors self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomRotors"))))
   ))
(define (nstextfield-accessibility-decrement-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDecrementButton"))))
   ))
(define (nstextfield-accessibility-default-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDefaultButton"))))
   ))
(define (nstextfield-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedByRow"))))
   ))
(define (nstextfield-accessibility-disclosed-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedRows"))))
   ))
(define (nstextfield-accessibility-disclosure-level self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosureLevel"))))
(define (nstextfield-accessibility-document self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDocument"))))
   ))
(define (nstextfield-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityExtrasMenuBar"))))
   ))
(define (nstextfield-accessibility-filename self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFilename"))))
   ))
(define (nstextfield-accessibility-focused-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFocusedWindow"))))
   ))
(define (nstextfield-accessibility-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-accessibility-frame-for-range self range)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_G_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrameForRange:")) (id->ffi2-ptr range) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-accessibility-full-screen-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFullScreenButton"))))
   ))
(define (nstextfield-accessibility-grow-area self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityGrowArea"))))
   ))
(define (nstextfield-accessibility-handles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHandles"))))
   ))
(define (nstextfield-accessibility-header self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHeader"))))
   ))
(define (nstextfield-accessibility-help self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHelp"))))
   ))
(define (nstextfield-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalScrollBar"))))
   ))
(define (nstextfield-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnitDescription"))))
   ))
(define (nstextfield-accessibility-horizontal-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnits"))))
(define (nstextfield-accessibility-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIdentifier"))))
   ))
(define (nstextfield-accessibility-increment-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIncrementButton"))))
   ))
(define (nstextfield-accessibility-index self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIndex"))))
(define (nstextfield-accessibility-insertion-point-line-number self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityInsertionPointLineNumber"))))
(define (nstextfield-accessibility-label self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabel"))))
   ))
(define (nstextfield-accessibility-label-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelUIElements"))))
   ))
(define (nstextfield-accessibility-label-value self)
  (aw_racket_msg_0_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelValue"))))
(define (nstextfield-accessibility-layout-point-for-screen-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutPointForScreenPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextfield-accessibility-layout-size-for-screen-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutSizeForScreenSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextfield-accessibility-line-for-index self index)
  (aw_racket_msg_q_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLineForIndex:")) index))
(define (nstextfield-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLinkedUIElements"))))
   ))
(define (nstextfield-accessibility-main-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMainWindow"))))
   ))
(define (nstextfield-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerGroupUIElement"))))
   ))
(define (nstextfield-accessibility-marker-type-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerTypeDescription"))))
   ))
(define (nstextfield-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerUIElements"))))
   ))
(define (nstextfield-accessibility-marker-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerValues"))))
   ))
(define (nstextfield-accessibility-max-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMaxValue"))))
   ))
(define (nstextfield-accessibility-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMenuBar"))))
   ))
(define (nstextfield-accessibility-min-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinValue"))))
   ))
(define (nstextfield-accessibility-minimize-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinimizeButton"))))
   ))
(define (nstextfield-accessibility-next-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNextContents"))))
   ))
(define (nstextfield-accessibility-number-of-characters self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNumberOfCharacters"))))
(define (nstextfield-accessibility-orientation self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOrientation"))))
(define (nstextfield-accessibility-overflow-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOverflowButton"))))
   ))
(define (nstextfield-accessibility-parent self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityParent"))))
   ))
(define (nstextfield-accessibility-perform-cancel self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformCancel"))))
(define (nstextfield-accessibility-perform-confirm self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformConfirm"))))
(define (nstextfield-accessibility-perform-decrement self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDecrement"))))
(define (nstextfield-accessibility-perform-delete self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDelete"))))
(define (nstextfield-accessibility-perform-increment self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformIncrement"))))
(define (nstextfield-accessibility-perform-pick self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPick"))))
(define (nstextfield-accessibility-perform-press self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPress"))))
(define (nstextfield-accessibility-perform-raise self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformRaise"))))
(define (nstextfield-accessibility-perform-show-alternate-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowAlternateUI"))))
(define (nstextfield-accessibility-perform-show-default-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowDefaultUI"))))
(define (nstextfield-accessibility-perform-show-menu self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowMenu"))))
(define (nstextfield-accessibility-placeholder-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPlaceholderValue"))))
   ))
(define (nstextfield-accessibility-previous-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPreviousContents"))))
   ))
(define (nstextfield-accessibility-proxy self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityProxy"))))
   ))
(define (nstextfield-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRTFForRange:")) (id->ffi2-ptr range)))
   ))
(define (nstextfield-accessibility-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextfield-accessibility-range-for-line self line-number)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForLine:")) line-number (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextfield-accessibility-range-for-position self point)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_O_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForPosition:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextfield-accessibility-role self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRole"))))
   ))
(define (nstextfield-accessibility-role-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRoleDescription"))))
   ))
(define (nstextfield-accessibility-row-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowCount"))))
(define (nstextfield-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowHeaderUIElements"))))
   ))
(define (nstextfield-accessibility-row-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextfield-accessibility-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRows"))))
   ))
(define (nstextfield-accessibility-ruler-marker-type self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRulerMarkerType"))))
(define (nstextfield-accessibility-screen-point-for-layout-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenPointForLayoutPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextfield-accessibility-screen-size-for-layout-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenSizeForLayoutSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextfield-accessibility-search-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchButton"))))
   ))
(define (nstextfield-accessibility-search-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchMenu"))))
   ))
(define (nstextfield-accessibility-selected-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedCells"))))
   ))
(define (nstextfield-accessibility-selected-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedChildren"))))
   ))
(define (nstextfield-accessibility-selected-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedColumns"))))
   ))
(define (nstextfield-accessibility-selected-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedRows"))))
   ))
(define (nstextfield-accessibility-selected-text self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedText"))))
   ))
(define (nstextfield-accessibility-selected-text-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextfield-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRanges"))))
   ))
(define (nstextfield-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityServesAsTitleForUIElements"))))
   ))
(define (nstextfield-accessibility-shared-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextfield-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedFocusElements"))))
   ))
(define (nstextfield-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedTextUIElements"))))
   ))
(define (nstextfield-accessibility-shown-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityShownMenu"))))
   ))
(define (nstextfield-accessibility-sort-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySortDirection"))))
(define (nstextfield-accessibility-splitters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySplitters"))))
   ))
(define (nstextfield-accessibility-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nstextfield-accessibility-style-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStyleRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextfield-accessibility-subrole self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySubrole"))))
   ))
(define (nstextfield-accessibility-tabs self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTabs"))))
   ))
(define (nstextfield-accessibility-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitle"))))
   ))
(define (nstextfield-accessibility-title-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitleUIElement"))))
   ))
(define (nstextfield-accessibility-toolbar-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityToolbarButton"))))
   ))
(define (nstextfield-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTopLevelUIElement"))))
   ))
(define (nstextfield-accessibility-url self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityURL"))))
   ))
(define (nstextfield-accessibility-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnitDescription"))))
   ))
(define (nstextfield-accessibility-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnits"))))
(define (nstextfield-accessibility-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUserInputLabels"))))
   ))
(define (nstextfield-accessibility-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValue"))))
   ))
(define (nstextfield-accessibility-value-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValueDescription"))))
   ))
(define (nstextfield-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalScrollBar"))))
   ))
(define (nstextfield-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnitDescription"))))
   ))
(define (nstextfield-accessibility-vertical-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnits"))))
(define (nstextfield-accessibility-visible-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCells"))))
   ))
(define (nstextfield-accessibility-visible-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextfield-accessibility-visible-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleChildren"))))
   ))
(define (nstextfield-accessibility-visible-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleColumns"))))
   ))
(define (nstextfield-accessibility-visible-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleRows"))))
   ))
(define (nstextfield-accessibility-warning-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWarningValue"))))
   ))
(define (nstextfield-accessibility-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindow"))))
   ))
(define (nstextfield-accessibility-windows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindows"))))
   ))
(define (nstextfield-accessibility-zoom-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityZoomButton"))))
   ))
(define (nstextfield-add-subview! self view)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addSubview:")) (id->ffi2-ptr (coerce-arg view))))
(define (nstextfield-add-subview-positioned-relative-to! self view place other-view)
  (aw_racket_msg_PqP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addSubview:positioned:relativeTo:")) (id->ffi2-ptr (coerce-arg view)) place (id->ffi2-ptr (coerce-arg other-view))))
(define (nstextfield-add-tool-tip-rect-owner-user-data! self rect owner data)
  (aw_racket_msg_RPP_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addToolTipRect:owner:userData:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg owner)) (id->ffi2-ptr data)))
(define (nstextfield-adjust-scroll self new-visible)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "adjustScroll:")) (id->ffi2-ptr new-visible) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-ancestor-shared-with-view self view)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "ancestorSharedWithView:")) (id->ffi2-ptr (coerce-arg view))))
   ))
(define (nstextfield-animation-for-key self key)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animationForKey:")) (id->ffi2-ptr (coerce-arg key))))
   ))
(define (nstextfield-animations self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animations"))))
   ))
(define (nstextfield-animator self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animator"))))
   ))
(define (nstextfield-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "appearance"))))
   ))
(define (nstextfield-autoscroll self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoscroll:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-backing-aligned-rect-options self rect options)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RQ_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backingAlignedRect:options:")) (id->ffi2-ptr rect) options (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-become-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "becomeFirstResponder"))))
(define (nstextfield-begin-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-bitmap-image-rep-for-caching-display-in-rect self rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bitmapImageRepForCachingDisplayInRect:")) (id->ffi2-ptr rect)))
   ))
(define (nstextfield-cache-display-in-rect-to-bitmap-image-rep self rect bitmap-image-rep)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cacheDisplayInRect:toBitmapImageRep:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg bitmap-image-rep))))
(define (nstextfield-cancel-operation self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cancelOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-capitalize-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "capitalizeWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-center-scan-rect! self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerScanRect:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-center-selection-in-visible-area! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerSelectionInVisibleArea:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-change-case-of-letter self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeCaseOfLetter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-change-mode-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeModeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-complete self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "complete:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-conclude-drag-operation self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "concludeDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-content-type self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentType"))))
   ))
(define (nstextfield-context-menu-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contextMenuKeyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-convert-point-from-view self point view)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_OP_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPoint:fromView:")) (id->ffi2-ptr point) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextfield-convert-point-to-view self point view)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_OP_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPoint:toView:")) (id->ffi2-ptr point) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextfield-convert-point-from-backing self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointFromBacking:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextfield-convert-point-from-layer self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointFromLayer:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextfield-convert-point-to-backing self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointToBacking:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextfield-convert-point-to-layer self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointToLayer:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextfield-convert-rect-from-view self rect view)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RP_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRect:fromView:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-convert-rect-to-view self rect view)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RP_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRect:toView:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-convert-rect-from-backing self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectFromBacking:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-convert-rect-from-layer self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectFromLayer:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-convert-rect-to-backing self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectToBacking:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-convert-rect-to-layer self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectToLayer:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-convert-size-from-view self size view)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_ZP_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSize:fromView:")) (id->ffi2-ptr size) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextfield-convert-size-to-view self size view)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_ZP_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSize:toView:")) (id->ffi2-ptr size) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextfield-convert-size-from-backing self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeFromBacking:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextfield-convert-size-from-layer self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeFromLayer:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextfield-convert-size-to-backing self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeToBacking:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextfield-convert-size-to-layer self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeToLayer:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextfield-cursor-update self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cursorUpdate:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-delete-backward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-delete-backward-by-decomposing-previous-character self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteBackwardByDecomposingPreviousCharacter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-delete-forward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-delete-to-beginning-of-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToBeginningOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-delete-to-beginning-of-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToBeginningOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-delete-to-end-of-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-delete-to-end-of-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToEndOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-delete-to-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-delete-word-backward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteWordBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-delete-word-forward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteWordForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-did-add-subview self subview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "didAddSubview:")) (id->ffi2-ptr (coerce-arg subview))))
(define (nstextfield-did-close-menu-with-event self menu event)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "didCloseMenu:withEvent:")) (id->ffi2-ptr (coerce-arg menu)) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-display! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "display"))))
(define (nstextfield-display-if-needed! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeeded"))))
(define (nstextfield-display-if-needed-ignoring-opacity! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededIgnoringOpacity"))))
(define (nstextfield-display-if-needed-in-rect! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededInRect:")) (id->ffi2-ptr rect)))
(define (nstextfield-display-if-needed-in-rect-ignoring-opacity! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededInRectIgnoringOpacity:")) (id->ffi2-ptr rect)))
(define (nstextfield-display-rect! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRect:")) (id->ffi2-ptr rect)))
(define (nstextfield-display-rect-ignoring-opacity! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRectIgnoringOpacity:")) (id->ffi2-ptr rect)))
(define (nstextfield-display-rect-ignoring-opacity-in-context! self rect context)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRectIgnoringOpacity:inContext:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg context))))
(define (nstextfield-do-command-by-selector self selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "doCommandBySelector:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nstextfield-dragging-ended self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingEnded:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-dragging-entered self sender)
  (aw_racket_msg_P_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingEntered:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-dragging-exited self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingExited:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-dragging-updated self sender)
  (aw_racket_msg_P_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingUpdated:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-draw-rect self dirty-rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawRect:")) (id->ffi2-ptr dirty-rect)))
(define (nstextfield-draw-with-expansion-frame-in-view self content-frame view)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawWithExpansionFrame:inView:")) (id->ffi2-ptr content-frame) (id->ffi2-ptr (coerce-arg view))))
(define (nstextfield-effective-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "effectiveAppearance"))))
   ))
(define (nstextfield-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nstextfield-end-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-expansion-frame-with-frame self content-frame)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "expansionFrameWithFrame:")) (id->ffi2-ptr content-frame) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-flags-changed self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flagsChanged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-flush-buffered-key-events self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flushBufferedKeyEvents"))))
(define (nstextfield-get-rects-being-drawn-count self rects count)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getRectsBeingDrawn:count:")) (id->ffi2-ptr rects) (id->ffi2-ptr count)))
(define (nstextfield-get-rects-exposed-during-live-resize-count self exposed-rects count)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getRectsExposedDuringLiveResize:count:")) (id->ffi2-ptr exposed-rects) (id->ffi2-ptr count)))
(define (nstextfield-help-requested self event-ptr)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "helpRequested:")) (id->ffi2-ptr (coerce-arg event-ptr))))
(define (nstextfield-hit-test self point)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_O_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hitTest:")) (id->ffi2-ptr point)))
   ))
(define (nstextfield-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "identifier"))))
   ))
(define (nstextfield-indent self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indent:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-insert-backtab! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertBacktab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-insert-container-break! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertContainerBreak:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-insert-double-quote-ignoring-substitution! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertDoubleQuoteIgnoringSubstitution:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-insert-line-break! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertLineBreak:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-insert-newline! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertNewline:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-insert-newline-ignoring-field-editor! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertNewlineIgnoringFieldEditor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-insert-paragraph-separator! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertParagraphSeparator:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-insert-single-quote-ignoring-substitution! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertSingleQuoteIgnoringSubstitution:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-insert-tab! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-insert-tab-ignoring-field-editor! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTabIgnoringFieldEditor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-insert-text! self insert-string)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertText:")) (id->ffi2-ptr (coerce-arg insert-string))))
(define (nstextfield-interpret-key-events self event-array)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "interpretKeyEvents:")) (id->ffi2-ptr (coerce-arg event-array))))
(define (nstextfield-is-accessibility-alternate-ui-visible self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityAlternateUIVisible"))))
(define (nstextfield-is-accessibility-disclosed self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityDisclosed"))))
(define (nstextfield-is-accessibility-edited self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEdited"))))
(define (nstextfield-is-accessibility-element self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityElement"))))
(define (nstextfield-is-accessibility-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEnabled"))))
(define (nstextfield-is-accessibility-expanded self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityExpanded"))))
(define (nstextfield-is-accessibility-focused self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFocused"))))
(define (nstextfield-is-accessibility-frontmost self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFrontmost"))))
(define (nstextfield-is-accessibility-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityHidden"))))
(define (nstextfield-is-accessibility-main self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMain"))))
(define (nstextfield-is-accessibility-minimized self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMinimized"))))
(define (nstextfield-is-accessibility-modal self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityModal"))))
(define (nstextfield-is-accessibility-ordered-by-row self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityOrderedByRow"))))
(define (nstextfield-is-accessibility-protected-content self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityProtectedContent"))))
(define (nstextfield-is-accessibility-required self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityRequired"))))
(define (nstextfield-is-accessibility-selected self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelected"))))
(define (nstextfield-is-accessibility-selector-allowed self selector)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelectorAllowed:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nstextfield-is-bezeled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isBezeled"))))
(define (nstextfield-is-bordered self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isBordered"))))
(define (nstextfield-is-continuous self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isContinuous"))))
(define (nstextfield-is-descendant-of self view)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isDescendantOf:")) (id->ffi2-ptr (coerce-arg view))))
(define (nstextfield-is-editable self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isEditable"))))
(define (nstextfield-is-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isEnabled"))))
(define (nstextfield-is-flipped self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isFlipped"))))
(define (nstextfield-is-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHidden"))))
(define (nstextfield-is-hidden-or-has-hidden-ancestor self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHiddenOrHasHiddenAncestor"))))
(define (nstextfield-is-highlighted self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHighlighted"))))
(define (nstextfield-is-opaque self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isOpaque"))))
(define (nstextfield-is-rotated-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRotatedFromBase"))))
(define (nstextfield-is-rotated-or-scaled-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRotatedOrScaledFromBase"))))
(define (nstextfield-is-selectable self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isSelectable"))))
(define (nstextfield-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-key-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-layout self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layout"))))
(define (nstextfield-layout-subtree-if-needed self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutSubtreeIfNeeded"))))
(define (nstextfield-lowercase-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lowercaseWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "magnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-make-backing-layer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBackingLayer"))))
   ))
(define (nstextfield-make-base-writing-direction-left-to-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionLeftToRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-make-base-writing-direction-natural self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionNatural:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-make-base-writing-direction-right-to-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionRightToLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-make-text-writing-direction-left-to-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionLeftToRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-make-text-writing-direction-natural self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionNatural:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-make-text-writing-direction-right-to-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionRightToLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-menu-for-event self event)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menuForEvent:")) (id->ffi2-ptr (coerce-arg event))))
   ))
(define (nstextfield-mouse-in-rect self point rect)
  (aw_racket_msg_OR_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouse:inRect:")) (id->ffi2-ptr point) (id->ffi2-ptr rect)))
(define (nstextfield-mouse-cancelled self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseCancelled:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-mouse-entered self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseEntered:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-mouse-exited self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseExited:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-mouse-moved self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseMoved:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-move-backward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-down! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-down-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveDownAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-forward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-left! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-left-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveLeftAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-paragraph-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveParagraphBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-paragraph-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveParagraphForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-right! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-right-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRightAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-to-beginning-of-document! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-to-beginning-of-document-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfDocumentAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-to-beginning-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-to-beginning-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-to-beginning-of-paragraph! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfParagraphAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-to-end-of-document! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-to-end-of-document-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfDocumentAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-to-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-to-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-to-end-of-paragraph! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-to-end-of-paragraph-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfParagraphAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-to-left-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToLeftEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-to-left-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToLeftEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-to-right-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToRightEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-to-right-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToRightEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-up! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-up-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveUpAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-word-backward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-word-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-word-forward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-word-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-word-left! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-word-left-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordLeftAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-word-right! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-move-word-right-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordRightAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-needs-to-draw-rect self rect)
  (aw_racket_msg_R_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsToDrawRect:")) (id->ffi2-ptr rect)))
(define (nstextfield-no-responder-for self event-selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "noResponderFor:")) (id->ffi2-ptr (sel_registerName event-selector))))
(define (nstextfield-other-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-other-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-other-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-page-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-page-down-and-modify-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageDownAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-page-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-page-up-and-modify-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageUpAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-perform-click! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performClick:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-perform-drag-operation! self sender)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-perform-key-equivalent! self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performKeyEquivalent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-prepare-content-in-rect self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareContentInRect:")) (id->ffi2-ptr rect)))
(define (nstextfield-prepare-for-drag-operation self sender)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareForDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-prepare-for-reuse self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareForReuse"))))
(define (nstextfield-pressure-change-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pressureChangeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-quick-look-preview-items self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookPreviewItems:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-quick-look-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-rect-for-smart-magnification-at-point-in-rect self location visible-rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_OR_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectForSmartMagnificationAtPoint:inRect:")) (id->ffi2-ptr location) (id->ffi2-ptr visible-rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextfield-remove-all-tool-tips! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeAllToolTips"))))
(define (nstextfield-remove-from-superview! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeFromSuperview"))))
(define (nstextfield-remove-from-superview-without-needing-display! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeFromSuperviewWithoutNeedingDisplay"))))
(define (nstextfield-remove-tool-tip! self tag)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeToolTip:")) tag))
(define (nstextfield-replace-subview-with! self old-view new-view)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "replaceSubview:with:")) (id->ffi2-ptr (coerce-arg old-view)) (id->ffi2-ptr (coerce-arg new-view))))
(define (nstextfield-resign-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resignFirstResponder"))))
(define (nstextfield-resize-subviews-with-old-size self old-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resizeSubviewsWithOldSize:")) (id->ffi2-ptr old-size)))
(define (nstextfield-resize-with-old-superview-size self old-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resizeWithOldSuperviewSize:")) (id->ffi2-ptr old-size)))
(define (nstextfield-restore-user-activity-state self user-activity)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "restoreUserActivityState:")) (id->ffi2-ptr (coerce-arg user-activity))))
(define (nstextfield-right-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-right-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-right-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-rotate-by-angle self angle)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotateByAngle:")) angle))
(define (nstextfield-rotate-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotateWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-scale-unit-square-to-size self new-unit-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scaleUnitSquareToSize:")) (id->ffi2-ptr new-unit-size)))
(define (nstextfield-scroll-line-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollLineDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-scroll-line-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollLineUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-scroll-page-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPageDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-scroll-page-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPageUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-scroll-point self point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPoint:")) (id->ffi2-ptr point)))
(define (nstextfield-scroll-rect-to-visible self rect)
  (aw_racket_msg_R_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollRectToVisible:")) (id->ffi2-ptr rect)))
(define (nstextfield-scroll-to-beginning-of-document self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollToBeginningOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-scroll-to-end-of-document self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollToEndOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-scroll-wheel self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollWheel:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-select-all self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectAll:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-select-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-select-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-select-text self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectText:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-select-to-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectToMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-select-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-send-action-to self action target)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sendAction:to:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg target))))
(define (nstextfield-send-action-on self mask)
  (aw_racket_msg_Q_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sendActionOn:")) mask))
(define (nstextfield-set-accessibility-activation-point! self accessibility-activation-point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityActivationPoint:")) (id->ffi2-ptr accessibility-activation-point)))
(define (nstextfield-set-accessibility-allowed-values! self accessibility-allowed-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAllowedValues:")) (id->ffi2-ptr (coerce-arg accessibility-allowed-values))))
(define (nstextfield-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAlternateUIVisible:")) accessibility-alternate-ui-visible))
(define (nstextfield-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityApplicationFocusedUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-application-focused-ui-element))))
(define (nstextfield-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAttributedUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-attributed-user-input-labels))))
(define (nstextfield-set-accessibility-cancel-button! self accessibility-cancel-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCancelButton:")) (id->ffi2-ptr (coerce-arg accessibility-cancel-button))))
(define (nstextfield-set-accessibility-children! self accessibility-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildren:")) (id->ffi2-ptr (coerce-arg accessibility-children))))
(define (nstextfield-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildrenInNavigationOrder:")) (id->ffi2-ptr (coerce-arg accessibility-children-in-navigation-order))))
(define (nstextfield-set-accessibility-clear-button! self accessibility-clear-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityClearButton:")) (id->ffi2-ptr (coerce-arg accessibility-clear-button))))
(define (nstextfield-set-accessibility-close-button! self accessibility-close-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCloseButton:")) (id->ffi2-ptr (coerce-arg accessibility-close-button))))
(define (nstextfield-set-accessibility-column-count! self accessibility-column-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnCount:")) accessibility-column-count))
(define (nstextfield-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-column-header-ui-elements))))
(define (nstextfield-set-accessibility-column-index-range! self accessibility-column-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnIndexRange:")) (id->ffi2-ptr accessibility-column-index-range)))
(define (nstextfield-set-accessibility-column-titles! self accessibility-column-titles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnTitles:")) (id->ffi2-ptr (coerce-arg accessibility-column-titles))))
(define (nstextfield-set-accessibility-columns! self accessibility-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumns:")) (id->ffi2-ptr (coerce-arg accessibility-columns))))
(define (nstextfield-set-accessibility-contents! self accessibility-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityContents:")) (id->ffi2-ptr (coerce-arg accessibility-contents))))
(define (nstextfield-set-accessibility-critical-value! self accessibility-critical-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCriticalValue:")) (id->ffi2-ptr (coerce-arg accessibility-critical-value))))
(define (nstextfield-set-accessibility-custom-actions! self accessibility-custom-actions)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomActions:")) (id->ffi2-ptr (coerce-arg accessibility-custom-actions))))
(define (nstextfield-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomRotors:")) (id->ffi2-ptr (coerce-arg accessibility-custom-rotors))))
(define (nstextfield-set-accessibility-decrement-button! self accessibility-decrement-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDecrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-decrement-button))))
(define (nstextfield-set-accessibility-default-button! self accessibility-default-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDefaultButton:")) (id->ffi2-ptr (coerce-arg accessibility-default-button))))
(define (nstextfield-set-accessibility-disclosed! self accessibility-disclosed)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosed:")) accessibility-disclosed))
(define (nstextfield-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedByRow:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-by-row))))
(define (nstextfield-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedRows:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-rows))))
(define (nstextfield-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosureLevel:")) accessibility-disclosure-level))
(define (nstextfield-set-accessibility-document! self accessibility-document)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDocument:")) (id->ffi2-ptr (coerce-arg accessibility-document))))
(define (nstextfield-set-accessibility-edited! self accessibility-edited)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEdited:")) accessibility-edited))
(define (nstextfield-set-accessibility-element! self accessibility-element)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityElement:")) accessibility-element))
(define (nstextfield-set-accessibility-enabled! self accessibility-enabled)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEnabled:")) accessibility-enabled))
(define (nstextfield-set-accessibility-expanded! self accessibility-expanded)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExpanded:")) accessibility-expanded))
(define (nstextfield-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExtrasMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-extras-menu-bar))))
(define (nstextfield-set-accessibility-filename! self accessibility-filename)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFilename:")) (id->ffi2-ptr (coerce-arg accessibility-filename))))
(define (nstextfield-set-accessibility-focused! self accessibility-focused)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocused:")) accessibility-focused))
(define (nstextfield-set-accessibility-focused-window! self accessibility-focused-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocusedWindow:")) (id->ffi2-ptr (coerce-arg accessibility-focused-window))))
(define (nstextfield-set-accessibility-frame! self accessibility-frame)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrame:")) (id->ffi2-ptr accessibility-frame)))
(define (nstextfield-set-accessibility-frontmost! self accessibility-frontmost)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrontmost:")) accessibility-frontmost))
(define (nstextfield-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFullScreenButton:")) (id->ffi2-ptr (coerce-arg accessibility-full-screen-button))))
(define (nstextfield-set-accessibility-grow-area! self accessibility-grow-area)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityGrowArea:")) (id->ffi2-ptr (coerce-arg accessibility-grow-area))))
(define (nstextfield-set-accessibility-handles! self accessibility-handles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHandles:")) (id->ffi2-ptr (coerce-arg accessibility-handles))))
(define (nstextfield-set-accessibility-header! self accessibility-header)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHeader:")) (id->ffi2-ptr (coerce-arg accessibility-header))))
(define (nstextfield-set-accessibility-help! self accessibility-help)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHelp:")) (id->ffi2-ptr (coerce-arg accessibility-help))))
(define (nstextfield-set-accessibility-hidden! self accessibility-hidden)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHidden:")) accessibility-hidden))
(define (nstextfield-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-scroll-bar))))
(define (nstextfield-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-unit-description))))
(define (nstextfield-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnits:")) accessibility-horizontal-units))
(define (nstextfield-set-accessibility-identifier! self accessibility-identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIdentifier:")) (id->ffi2-ptr (coerce-arg accessibility-identifier))))
(define (nstextfield-set-accessibility-increment-button! self accessibility-increment-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIncrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-increment-button))))
(define (nstextfield-set-accessibility-index! self accessibility-index)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIndex:")) accessibility-index))
(define (nstextfield-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityInsertionPointLineNumber:")) accessibility-insertion-point-line-number))
(define (nstextfield-set-accessibility-label! self accessibility-label)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabel:")) (id->ffi2-ptr (coerce-arg accessibility-label))))
(define (nstextfield-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-label-ui-elements))))
(define (nstextfield-set-accessibility-label-value! self accessibility-label-value)
  (aw_racket_msg_f_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelValue:")) accessibility-label-value))
(define (nstextfield-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLinkedUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-linked-ui-elements))))
(define (nstextfield-set-accessibility-main! self accessibility-main)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMain:")) accessibility-main))
(define (nstextfield-set-accessibility-main-window! self accessibility-main-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMainWindow:")) (id->ffi2-ptr (coerce-arg accessibility-main-window))))
(define (nstextfield-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerGroupUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-marker-group-ui-element))))
(define (nstextfield-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerTypeDescription:")) (id->ffi2-ptr (coerce-arg accessibility-marker-type-description))))
(define (nstextfield-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-marker-ui-elements))))
(define (nstextfield-set-accessibility-marker-values! self accessibility-marker-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerValues:")) (id->ffi2-ptr (coerce-arg accessibility-marker-values))))
(define (nstextfield-set-accessibility-max-value! self accessibility-max-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMaxValue:")) (id->ffi2-ptr (coerce-arg accessibility-max-value))))
(define (nstextfield-set-accessibility-menu-bar! self accessibility-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-menu-bar))))
(define (nstextfield-set-accessibility-min-value! self accessibility-min-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinValue:")) (id->ffi2-ptr (coerce-arg accessibility-min-value))))
(define (nstextfield-set-accessibility-minimize-button! self accessibility-minimize-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimizeButton:")) (id->ffi2-ptr (coerce-arg accessibility-minimize-button))))
(define (nstextfield-set-accessibility-minimized! self accessibility-minimized)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimized:")) accessibility-minimized))
(define (nstextfield-set-accessibility-modal! self accessibility-modal)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityModal:")) accessibility-modal))
(define (nstextfield-set-accessibility-next-contents! self accessibility-next-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNextContents:")) (id->ffi2-ptr (coerce-arg accessibility-next-contents))))
(define (nstextfield-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNumberOfCharacters:")) accessibility-number-of-characters))
(define (nstextfield-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrderedByRow:")) accessibility-ordered-by-row))
(define (nstextfield-set-accessibility-orientation! self accessibility-orientation)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrientation:")) accessibility-orientation))
(define (nstextfield-set-accessibility-overflow-button! self accessibility-overflow-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOverflowButton:")) (id->ffi2-ptr (coerce-arg accessibility-overflow-button))))
(define (nstextfield-set-accessibility-parent! self accessibility-parent)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityParent:")) (id->ffi2-ptr (coerce-arg accessibility-parent))))
(define (nstextfield-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPlaceholderValue:")) (id->ffi2-ptr (coerce-arg accessibility-placeholder-value))))
(define (nstextfield-set-accessibility-previous-contents! self accessibility-previous-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPreviousContents:")) (id->ffi2-ptr (coerce-arg accessibility-previous-contents))))
(define (nstextfield-set-accessibility-protected-content! self accessibility-protected-content)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProtectedContent:")) accessibility-protected-content))
(define (nstextfield-set-accessibility-proxy! self accessibility-proxy)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProxy:")) (id->ffi2-ptr (coerce-arg accessibility-proxy))))
(define (nstextfield-set-accessibility-required! self accessibility-required)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRequired:")) accessibility-required))
(define (nstextfield-set-accessibility-role! self accessibility-role)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRole:")) (id->ffi2-ptr (coerce-arg accessibility-role))))
(define (nstextfield-set-accessibility-role-description! self accessibility-role-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRoleDescription:")) (id->ffi2-ptr (coerce-arg accessibility-role-description))))
(define (nstextfield-set-accessibility-row-count! self accessibility-row-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowCount:")) accessibility-row-count))
(define (nstextfield-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-row-header-ui-elements))))
(define (nstextfield-set-accessibility-row-index-range! self accessibility-row-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowIndexRange:")) (id->ffi2-ptr accessibility-row-index-range)))
(define (nstextfield-set-accessibility-rows! self accessibility-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRows:")) (id->ffi2-ptr (coerce-arg accessibility-rows))))
(define (nstextfield-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRulerMarkerType:")) accessibility-ruler-marker-type))
(define (nstextfield-set-accessibility-search-button! self accessibility-search-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchButton:")) (id->ffi2-ptr (coerce-arg accessibility-search-button))))
(define (nstextfield-set-accessibility-search-menu! self accessibility-search-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchMenu:")) (id->ffi2-ptr (coerce-arg accessibility-search-menu))))
(define (nstextfield-set-accessibility-selected! self accessibility-selected)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelected:")) accessibility-selected))
(define (nstextfield-set-accessibility-selected-cells! self accessibility-selected-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedCells:")) (id->ffi2-ptr (coerce-arg accessibility-selected-cells))))
(define (nstextfield-set-accessibility-selected-children! self accessibility-selected-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedChildren:")) (id->ffi2-ptr (coerce-arg accessibility-selected-children))))
(define (nstextfield-set-accessibility-selected-columns! self accessibility-selected-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedColumns:")) (id->ffi2-ptr (coerce-arg accessibility-selected-columns))))
(define (nstextfield-set-accessibility-selected-rows! self accessibility-selected-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedRows:")) (id->ffi2-ptr (coerce-arg accessibility-selected-rows))))
(define (nstextfield-set-accessibility-selected-text! self accessibility-selected-text)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedText:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text))))
(define (nstextfield-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRange:")) (id->ffi2-ptr accessibility-selected-text-range)))
(define (nstextfield-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRanges:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text-ranges))))
(define (nstextfield-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityServesAsTitleForUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-serves-as-title-for-ui-elements))))
(define (nstextfield-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedCharacterRange:")) (id->ffi2-ptr accessibility-shared-character-range)))
(define (nstextfield-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedFocusElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-focus-elements))))
(define (nstextfield-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedTextUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-text-ui-elements))))
(define (nstextfield-set-accessibility-shown-menu! self accessibility-shown-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityShownMenu:")) (id->ffi2-ptr (coerce-arg accessibility-shown-menu))))
(define (nstextfield-set-accessibility-sort-direction! self accessibility-sort-direction)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySortDirection:")) accessibility-sort-direction))
(define (nstextfield-set-accessibility-splitters! self accessibility-splitters)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySplitters:")) (id->ffi2-ptr (coerce-arg accessibility-splitters))))
(define (nstextfield-set-accessibility-subrole! self accessibility-subrole)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySubrole:")) (id->ffi2-ptr (coerce-arg accessibility-subrole))))
(define (nstextfield-set-accessibility-tabs! self accessibility-tabs)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTabs:")) (id->ffi2-ptr (coerce-arg accessibility-tabs))))
(define (nstextfield-set-accessibility-title! self accessibility-title)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitle:")) (id->ffi2-ptr (coerce-arg accessibility-title))))
(define (nstextfield-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitleUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-title-ui-element))))
(define (nstextfield-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityToolbarButton:")) (id->ffi2-ptr (coerce-arg accessibility-toolbar-button))))
(define (nstextfield-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTopLevelUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-top-level-ui-element))))
(define (nstextfield-set-accessibility-url! self accessibility-url)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityURL:")) (id->ffi2-ptr (coerce-arg accessibility-url))))
(define (nstextfield-set-accessibility-unit-description! self accessibility-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-unit-description))))
(define (nstextfield-set-accessibility-units! self accessibility-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnits:")) accessibility-units))
(define (nstextfield-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-user-input-labels))))
(define (nstextfield-set-accessibility-value! self accessibility-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValue:")) (id->ffi2-ptr (coerce-arg accessibility-value))))
(define (nstextfield-set-accessibility-value-description! self accessibility-value-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValueDescription:")) (id->ffi2-ptr (coerce-arg accessibility-value-description))))
(define (nstextfield-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-scroll-bar))))
(define (nstextfield-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-unit-description))))
(define (nstextfield-set-accessibility-vertical-units! self accessibility-vertical-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnits:")) accessibility-vertical-units))
(define (nstextfield-set-accessibility-visible-cells! self accessibility-visible-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCells:")) (id->ffi2-ptr (coerce-arg accessibility-visible-cells))))
(define (nstextfield-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCharacterRange:")) (id->ffi2-ptr accessibility-visible-character-range)))
(define (nstextfield-set-accessibility-visible-children! self accessibility-visible-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleChildren:")) (id->ffi2-ptr (coerce-arg accessibility-visible-children))))
(define (nstextfield-set-accessibility-visible-columns! self accessibility-visible-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleColumns:")) (id->ffi2-ptr (coerce-arg accessibility-visible-columns))))
(define (nstextfield-set-accessibility-visible-rows! self accessibility-visible-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleRows:")) (id->ffi2-ptr (coerce-arg accessibility-visible-rows))))
(define (nstextfield-set-accessibility-warning-value! self accessibility-warning-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWarningValue:")) (id->ffi2-ptr (coerce-arg accessibility-warning-value))))
(define (nstextfield-set-accessibility-window! self accessibility-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindow:")) (id->ffi2-ptr (coerce-arg accessibility-window))))
(define (nstextfield-set-accessibility-windows! self accessibility-windows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindows:")) (id->ffi2-ptr (coerce-arg accessibility-windows))))
(define (nstextfield-set-accessibility-zoom-button! self accessibility-zoom-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityZoomButton:")) (id->ffi2-ptr (coerce-arg accessibility-zoom-button))))
(define (nstextfield-set-animations! self animations)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAnimations:")) (id->ffi2-ptr (coerce-arg animations))))
(define (nstextfield-set-appearance! self appearance)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAppearance:")) (id->ffi2-ptr (coerce-arg appearance))))
(define (nstextfield-set-bounds-origin! self new-origin)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsOrigin:")) (id->ffi2-ptr new-origin)))
(define (nstextfield-set-bounds-size! self new-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsSize:")) (id->ffi2-ptr new-size)))
(define (nstextfield-set-content-type! self content-type)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentType:")) (id->ffi2-ptr (coerce-arg content-type))))
(define (nstextfield-set-frame-origin! self new-origin)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameOrigin:")) (id->ffi2-ptr new-origin)))
(define (nstextfield-set-frame-size! self new-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameSize:")) (id->ffi2-ptr new-size)))
(define (nstextfield-set-identifier! self identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIdentifier:")) (id->ffi2-ptr (coerce-arg identifier))))
(define (nstextfield-set-mark! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-set-needs-display-in-rect! self invalid-rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsDisplayInRect:")) (id->ffi2-ptr invalid-rect)))
(define (nstextfield-should-be-treated-as-ink-event self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldBeTreatedAsInkEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-should-delay-window-ordering-for-event self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldDelayWindowOrderingForEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-show-context-help self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextHelp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-show-context-menu-for-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextMenuForSelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-size-that-fits self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sizeThatFits:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextfield-size-to-fit self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sizeToFit"))))
(define (nstextfield-smart-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "smartMagnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-sort-subviews-using-function-context self compare context)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sortSubviewsUsingFunction:context:")) (id->ffi2-ptr compare) (id->ffi2-ptr context)))
(define (nstextfield-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "supplementalTargetForAction:sender:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg sender))))
   ))
(define (nstextfield-swap-with-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swapWithMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-swipe-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swipeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-tablet-point self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletPoint:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-tablet-proximity self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletProximity:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-take-double-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeDoubleValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-take-float-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeFloatValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-take-int-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeIntValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-take-integer-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeIntegerValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-take-object-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeObjectValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-take-string-value-from self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "takeStringValueFrom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-text-did-begin-editing self notification)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textDidBeginEditing:")) (id->ffi2-ptr (coerce-arg notification))))
(define (nstextfield-text-did-change self notification)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textDidChange:")) (id->ffi2-ptr (coerce-arg notification))))
(define (nstextfield-text-did-end-editing self notification)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textDidEndEditing:")) (id->ffi2-ptr (coerce-arg notification))))
(define (nstextfield-text-should-begin-editing self text-object)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textShouldBeginEditing:")) (id->ffi2-ptr (coerce-arg text-object))))
(define (nstextfield-text-should-end-editing self text-object)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textShouldEndEditing:")) (id->ffi2-ptr (coerce-arg text-object))))
(define (nstextfield-touches-began-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesBeganWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-touches-cancelled-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesCancelledWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-touches-ended-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesEndedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-touches-moved-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesMovedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-translate-origin-to-point self translation)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translateOriginToPoint:")) (id->ffi2-ptr translation)))
(define (nstextfield-translate-rects-needing-display-in-rect-by self clip-rect delta)
  (aw_racket_msg_RZ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translateRectsNeedingDisplayInRect:by:")) (id->ffi2-ptr clip-rect) (id->ffi2-ptr delta)))
(define (nstextfield-transpose self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transpose:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-transpose-words self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transposeWords:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-try-to-perform-with self action object)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tryToPerform:with:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg object))))
(define (nstextfield-update-dragging-items-for-drag self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateDraggingItemsForDrag:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-update-layer self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateLayer"))))
(define (nstextfield-uppercase-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "uppercaseWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextfield-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validRequestorForSendType:returnType:")) (id->ffi2-ptr (coerce-arg send-type)) (id->ffi2-ptr (coerce-arg return-type))))
   ))
(define (nstextfield-validate-user-interface-item self item)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validateUserInterfaceItem:")) (id->ffi2-ptr (coerce-arg item))))
(define (nstextfield-view-did-change-backing-properties self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidChangeBackingProperties"))))
(define (nstextfield-view-did-change-effective-appearance self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidChangeEffectiveAppearance"))))
(define (nstextfield-view-did-end-live-resize self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidEndLiveResize"))))
(define (nstextfield-view-did-hide self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidHide"))))
(define (nstextfield-view-did-move-to-superview self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidMoveToSuperview"))))
(define (nstextfield-view-did-move-to-window self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidMoveToWindow"))))
(define (nstextfield-view-did-unhide self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidUnhide"))))
(define (nstextfield-view-will-draw self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillDraw"))))
(define (nstextfield-view-will-move-to-superview self new-superview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillMoveToSuperview:")) (id->ffi2-ptr (coerce-arg new-superview))))
(define (nstextfield-view-will-move-to-window self new-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillMoveToWindow:")) (id->ffi2-ptr (coerce-arg new-window))))
(define (nstextfield-view-will-start-live-resize self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillStartLiveResize"))))
(define (nstextfield-view-with-tag self tag)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWithTag:")) tag))
   ))
(define (nstextfield-wants-forwarded-scroll-events-for-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsForwardedScrollEventsForAxis:")) axis))
(define (nstextfield-wants-periodic-dragging-updates self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsPeriodicDraggingUpdates"))))
(define (nstextfield-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:")) axis))
(define (nstextfield-will-open-menu-with-event self menu event)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "willOpenMenu:withEvent:")) (id->ffi2-ptr (coerce-arg menu)) (id->ffi2-ptr (coerce-arg event))))
(define (nstextfield-will-remove-subview self subview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "willRemoveSubview:")) (id->ffi2-ptr (coerce-arg subview))))
(define (nstextfield-yank self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "yank:")) (id->ffi2-ptr (coerce-arg sender))))

;; --- Class methods ---
(define (nstextfield-default-animation-for-key key)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSTextField) (id->ffi2-ptr (sel_registerName "defaultAnimationForKey:")) (id->ffi2-ptr (coerce-arg key))))
   ))
(define (nstextfield-is-compatible-with-responsive-scrolling)
  (aw_racket_msg_0_b (id->ffi2-ptr NSTextField) (id->ffi2-ptr (sel_registerName "isCompatibleWithResponsiveScrolling"))))
