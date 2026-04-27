#lang racket/base
;; Generated binding for NSTextField (AppKit)
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
(define (weakstorage? v) (objc-instance-of? v "WeakStorage"))
(provide NSTextField)
(provide/contract
  [make-nstextfield-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nstextfield-init-with-frame (c-> any/c any/c)]
  [nstextfield-accepts-first-responder (c-> objc-object? boolean?)]
  [nstextfield-accepts-touch-events (c-> objc-object? boolean?)]
  [nstextfield-set-accepts-touch-events! (c-> objc-object? boolean? void?)]
  [nstextfield-action (c-> objc-object? cpointer?)]
  [nstextfield-set-action! (c-> objc-object? string? void?)]
  [nstextfield-additional-safe-area-insets (c-> objc-object? any/c)]
  [nstextfield-set-additional-safe-area-insets! (c-> objc-object? any/c void?)]
  [nstextfield-alignment (c-> objc-object? exact-nonnegative-integer?)]
  [nstextfield-set-alignment! (c-> objc-object? exact-nonnegative-integer? void?)]
  [nstextfield-alignment-rect-insets (c-> objc-object? any/c)]
  [nstextfield-allowed-touch-types (c-> objc-object? exact-nonnegative-integer?)]
  [nstextfield-set-allowed-touch-types! (c-> objc-object? exact-nonnegative-integer? void?)]
  [nstextfield-allows-character-picker-touch-bar-item (c-> objc-object? boolean?)]
  [nstextfield-set-allows-character-picker-touch-bar-item! (c-> objc-object? boolean? void?)]
  [nstextfield-allows-default-tightening-for-truncation (c-> objc-object? boolean?)]
  [nstextfield-set-allows-default-tightening-for-truncation! (c-> objc-object? boolean? void?)]
  [nstextfield-allows-editing-text-attributes (c-> objc-object? boolean?)]
  [nstextfield-set-allows-editing-text-attributes! (c-> objc-object? boolean? void?)]
  [nstextfield-allows-expansion-tool-tips (c-> objc-object? boolean?)]
  [nstextfield-set-allows-expansion-tool-tips! (c-> objc-object? boolean? void?)]
  [nstextfield-allows-vibrancy (c-> objc-object? boolean?)]
  [nstextfield-allows-writing-tools (c-> objc-object? boolean?)]
  [nstextfield-set-allows-writing-tools! (c-> objc-object? boolean? void?)]
  [nstextfield-allows-writing-tools-affordance (c-> objc-object? boolean?)]
  [nstextfield-set-allows-writing-tools-affordance! (c-> objc-object? boolean? void?)]
  [nstextfield-alpha-value (c-> objc-object? real?)]
  [nstextfield-set-alpha-value! (c-> objc-object? real? void?)]
  [nstextfield-attributed-string-value (c-> objc-object? (or/c nsattributedstring? objc-nil?))]
  [nstextfield-set-attributed-string-value! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-automatic-text-completion-enabled (c-> objc-object? boolean?)]
  [nstextfield-set-automatic-text-completion-enabled! (c-> objc-object? boolean? void?)]
  [nstextfield-autoresizes-subviews (c-> objc-object? boolean?)]
  [nstextfield-set-autoresizes-subviews! (c-> objc-object? boolean? void?)]
  [nstextfield-autoresizing-mask (c-> objc-object? exact-nonnegative-integer?)]
  [nstextfield-set-autoresizing-mask! (c-> objc-object? exact-nonnegative-integer? void?)]
  [nstextfield-background-color (c-> objc-object? (or/c nscolor? objc-nil?))]
  [nstextfield-set-background-color! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-background-filters (c-> objc-object? any/c)]
  [nstextfield-set-background-filters! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-base-writing-direction (c-> objc-object? exact-nonnegative-integer?)]
  [nstextfield-set-base-writing-direction! (c-> objc-object? exact-nonnegative-integer? void?)]
  [nstextfield-baseline-offset-from-bottom (c-> objc-object? real?)]
  [nstextfield-bezel-style (c-> objc-object? exact-nonnegative-integer?)]
  [nstextfield-set-bezel-style! (c-> objc-object? exact-nonnegative-integer? void?)]
  [nstextfield-bezeled (c-> objc-object? boolean?)]
  [nstextfield-set-bezeled! (c-> objc-object? boolean? void?)]
  [nstextfield-bordered (c-> objc-object? boolean?)]
  [nstextfield-set-bordered! (c-> objc-object? boolean? void?)]
  [nstextfield-bottom-anchor (c-> objc-object? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstextfield-bounds (c-> objc-object? any/c)]
  [nstextfield-set-bounds! (c-> objc-object? any/c void?)]
  [nstextfield-bounds-rotation (c-> objc-object? real?)]
  [nstextfield-set-bounds-rotation! (c-> objc-object? real? void?)]
  [nstextfield-can-become-key-view (c-> objc-object? boolean?)]
  [nstextfield-can-draw (c-> objc-object? boolean?)]
  [nstextfield-can-draw-concurrently (c-> objc-object? boolean?)]
  [nstextfield-set-can-draw-concurrently! (c-> objc-object? boolean? void?)]
  [nstextfield-can-draw-subviews-into-layer (c-> objc-object? boolean?)]
  [nstextfield-set-can-draw-subviews-into-layer! (c-> objc-object? boolean? void?)]
  [nstextfield-candidate-list-touch-bar-item (c-> objc-object? (or/c nscandidatelisttouchbaritem? objc-nil?))]
  [nstextfield-cell (c-> objc-object? any/c)]
  [nstextfield-set-cell! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-cell-class (c-> cpointer?)]
  [nstextfield-set-cell-class! (c-> cpointer? void?)]
  [nstextfield-center-x-anchor (c-> objc-object? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstextfield-center-y-anchor (c-> objc-object? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstextfield-clips-to-bounds (c-> objc-object? boolean?)]
  [nstextfield-set-clips-to-bounds! (c-> objc-object? boolean? void?)]
  [nstextfield-compatible-with-responsive-scrolling (c-> boolean?)]
  [nstextfield-compositing-filter (c-> objc-object? (or/c cifilter? objc-nil?))]
  [nstextfield-set-compositing-filter! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-constraints (c-> objc-object? any/c)]
  [nstextfield-content-filters (c-> objc-object? any/c)]
  [nstextfield-set-content-filters! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-continuous (c-> objc-object? boolean?)]
  [nstextfield-set-continuous! (c-> objc-object? boolean? void?)]
  [nstextfield-control-size (c-> objc-object? exact-nonnegative-integer?)]
  [nstextfield-set-control-size! (c-> objc-object? exact-nonnegative-integer? void?)]
  [nstextfield-default-focus-ring-type (c-> exact-nonnegative-integer?)]
  [nstextfield-default-menu (c-> (or/c nsmenu? objc-nil?))]
  [nstextfield-delegate (c-> objc-object? any/c)]
  [nstextfield-set-delegate! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-double-value (c-> objc-object? real?)]
  [nstextfield-set-double-value! (c-> objc-object? real? void?)]
  [nstextfield-drawing-find-indicator (c-> objc-object? boolean?)]
  [nstextfield-draws-background (c-> objc-object? boolean?)]
  [nstextfield-set-draws-background! (c-> objc-object? boolean? void?)]
  [nstextfield-editable (c-> objc-object? boolean?)]
  [nstextfield-set-editable! (c-> objc-object? boolean? void?)]
  [nstextfield-enabled (c-> objc-object? boolean?)]
  [nstextfield-set-enabled! (c-> objc-object? boolean? void?)]
  [nstextfield-enclosing-menu-item (c-> objc-object? (or/c nsmenuitem? objc-nil?))]
  [nstextfield-enclosing-scroll-view (c-> objc-object? (or/c nsscrollview? objc-nil?))]
  [nstextfield-first-baseline-anchor (c-> objc-object? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstextfield-first-baseline-offset-from-top (c-> objc-object? real?)]
  [nstextfield-fitting-size (c-> objc-object? any/c)]
  [nstextfield-flipped (c-> objc-object? boolean?)]
  [nstextfield-float-value (c-> objc-object? real?)]
  [nstextfield-set-float-value! (c-> objc-object? real? void?)]
  [nstextfield-focus-ring-mask-bounds (c-> objc-object? any/c)]
  [nstextfield-focus-ring-type (c-> objc-object? exact-nonnegative-integer?)]
  [nstextfield-set-focus-ring-type! (c-> objc-object? exact-nonnegative-integer? void?)]
  [nstextfield-focus-view (c-> (or/c nsview? objc-nil?))]
  [nstextfield-font (c-> objc-object? (or/c nsfont? objc-nil?))]
  [nstextfield-set-font! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-formatter (c-> objc-object? any/c)]
  [nstextfield-set-formatter! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-frame (c-> objc-object? any/c)]
  [nstextfield-set-frame! (c-> objc-object? any/c void?)]
  [nstextfield-frame-center-rotation (c-> objc-object? real?)]
  [nstextfield-set-frame-center-rotation! (c-> objc-object? real? void?)]
  [nstextfield-frame-rotation (c-> objc-object? real?)]
  [nstextfield-set-frame-rotation! (c-> objc-object? real? void?)]
  [nstextfield-gesture-recognizers (c-> objc-object? any/c)]
  [nstextfield-set-gesture-recognizers! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-has-ambiguous-layout (c-> objc-object? boolean?)]
  [nstextfield-height-adjust-limit (c-> objc-object? real?)]
  [nstextfield-height-anchor (c-> objc-object? (or/c nslayoutdimension? objc-nil?))]
  [nstextfield-hidden (c-> objc-object? boolean?)]
  [nstextfield-set-hidden! (c-> objc-object? boolean? void?)]
  [nstextfield-hidden-or-has-hidden-ancestor (c-> objc-object? boolean?)]
  [nstextfield-highlighted (c-> objc-object? boolean?)]
  [nstextfield-set-highlighted! (c-> objc-object? boolean? void?)]
  [nstextfield-horizontal-content-size-constraint-active (c-> objc-object? boolean?)]
  [nstextfield-set-horizontal-content-size-constraint-active! (c-> objc-object? boolean? void?)]
  [nstextfield-ignores-multi-click (c-> objc-object? boolean?)]
  [nstextfield-set-ignores-multi-click! (c-> objc-object? boolean? void?)]
  [nstextfield-imports-graphics (c-> objc-object? boolean?)]
  [nstextfield-set-imports-graphics! (c-> objc-object? boolean? void?)]
  [nstextfield-in-full-screen-mode (c-> objc-object? boolean?)]
  [nstextfield-in-live-resize (c-> objc-object? boolean?)]
  [nstextfield-input-context (c-> objc-object? (or/c nstextinputcontext? objc-nil?))]
  [nstextfield-int-value (c-> objc-object? exact-integer?)]
  [nstextfield-set-int-value! (c-> objc-object? exact-integer? void?)]
  [nstextfield-integer-value (c-> objc-object? exact-integer?)]
  [nstextfield-set-integer-value! (c-> objc-object? exact-integer? void?)]
  [nstextfield-intrinsic-content-size (c-> objc-object? any/c)]
  [nstextfield-last-baseline-anchor (c-> objc-object? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstextfield-last-baseline-offset-from-bottom (c-> objc-object? real?)]
  [nstextfield-layer (c-> objc-object? (or/c calayer? objc-nil?))]
  [nstextfield-set-layer! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-layer-contents-placement (c-> objc-object? exact-nonnegative-integer?)]
  [nstextfield-set-layer-contents-placement! (c-> objc-object? exact-nonnegative-integer? void?)]
  [nstextfield-layer-contents-redraw-policy (c-> objc-object? exact-nonnegative-integer?)]
  [nstextfield-set-layer-contents-redraw-policy! (c-> objc-object? exact-nonnegative-integer? void?)]
  [nstextfield-layer-uses-core-image-filters (c-> objc-object? boolean?)]
  [nstextfield-set-layer-uses-core-image-filters! (c-> objc-object? boolean? void?)]
  [nstextfield-layout-guides (c-> objc-object? any/c)]
  [nstextfield-layout-margins-guide (c-> objc-object? (or/c nslayoutguide? objc-nil?))]
  [nstextfield-leading-anchor (c-> objc-object? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstextfield-left-anchor (c-> objc-object? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstextfield-line-break-mode (c-> objc-object? exact-nonnegative-integer?)]
  [nstextfield-set-line-break-mode! (c-> objc-object? exact-nonnegative-integer? void?)]
  [nstextfield-line-break-strategy (c-> objc-object? exact-nonnegative-integer?)]
  [nstextfield-set-line-break-strategy! (c-> objc-object? exact-nonnegative-integer? void?)]
  [nstextfield-maximum-number-of-lines (c-> objc-object? exact-integer?)]
  [nstextfield-set-maximum-number-of-lines! (c-> objc-object? exact-integer? void?)]
  [nstextfield-menu (c-> objc-object? (or/c nsmenu? objc-nil?))]
  [nstextfield-set-menu! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-mouse-down-can-move-window (c-> objc-object? boolean?)]
  [nstextfield-needs-display (c-> objc-object? boolean?)]
  [nstextfield-set-needs-display! (c-> objc-object? boolean? void?)]
  [nstextfield-needs-layout (c-> objc-object? boolean?)]
  [nstextfield-set-needs-layout! (c-> objc-object? boolean? void?)]
  [nstextfield-needs-panel-to-become-key (c-> objc-object? boolean?)]
  [nstextfield-needs-update-constraints (c-> objc-object? boolean?)]
  [nstextfield-set-needs-update-constraints! (c-> objc-object? boolean? void?)]
  [nstextfield-next-key-view (c-> objc-object? (or/c nsview? objc-nil?))]
  [nstextfield-set-next-key-view! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-next-responder (c-> objc-object? (or/c nsresponder? objc-nil?))]
  [nstextfield-set-next-responder! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-next-valid-key-view (c-> objc-object? (or/c nsview? objc-nil?))]
  [nstextfield-object-value (c-> objc-object? any/c)]
  [nstextfield-set-object-value! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-opaque (c-> objc-object? boolean?)]
  [nstextfield-opaque-ancestor (c-> objc-object? (or/c nsview? objc-nil?))]
  [nstextfield-page-footer (c-> objc-object? (or/c nsattributedstring? objc-nil?))]
  [nstextfield-page-header (c-> objc-object? (or/c nsattributedstring? objc-nil?))]
  [nstextfield-placeholder-attributed-string (c-> objc-object? (or/c nsattributedstring? objc-nil?))]
  [nstextfield-set-placeholder-attributed-string! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-placeholder-attributed-strings (c-> objc-object? any/c)]
  [nstextfield-set-placeholder-attributed-strings! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-placeholder-string (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-set-placeholder-string! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-placeholder-strings (c-> objc-object? any/c)]
  [nstextfield-set-placeholder-strings! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-posts-bounds-changed-notifications (c-> objc-object? boolean?)]
  [nstextfield-set-posts-bounds-changed-notifications! (c-> objc-object? boolean? void?)]
  [nstextfield-posts-frame-changed-notifications (c-> objc-object? boolean?)]
  [nstextfield-set-posts-frame-changed-notifications! (c-> objc-object? boolean? void?)]
  [nstextfield-preferred-max-layout-width (c-> objc-object? real?)]
  [nstextfield-set-preferred-max-layout-width! (c-> objc-object? real? void?)]
  [nstextfield-prefers-compact-control-size-metrics (c-> objc-object? boolean?)]
  [nstextfield-set-prefers-compact-control-size-metrics! (c-> objc-object? boolean? void?)]
  [nstextfield-prepared-content-rect (c-> objc-object? any/c)]
  [nstextfield-set-prepared-content-rect! (c-> objc-object? any/c void?)]
  [nstextfield-preserves-content-during-live-resize (c-> objc-object? boolean?)]
  [nstextfield-pressure-configuration (c-> objc-object? (or/c nspressureconfiguration? objc-nil?))]
  [nstextfield-set-pressure-configuration! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-previous-key-view (c-> objc-object? (or/c nsview? objc-nil?))]
  [nstextfield-previous-valid-key-view (c-> objc-object? (or/c nsview? objc-nil?))]
  [nstextfield-print-job-title (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-rect-preserved-during-live-resize (c-> objc-object? any/c)]
  [nstextfield-refuses-first-responder (c-> objc-object? boolean?)]
  [nstextfield-set-refuses-first-responder! (c-> objc-object? boolean? void?)]
  [nstextfield-registered-dragged-types (c-> objc-object? any/c)]
  [nstextfield-requires-constraint-based-layout (c-> boolean?)]
  [nstextfield-resolves-natural-alignment-with-base-writing-direction (c-> objc-object? boolean?)]
  [nstextfield-set-resolves-natural-alignment-with-base-writing-direction! (c-> objc-object? boolean? void?)]
  [nstextfield-restorable-state-key-paths (c-> any/c)]
  [nstextfield-right-anchor (c-> objc-object? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstextfield-rotated-from-base (c-> objc-object? boolean?)]
  [nstextfield-rotated-or-scaled-from-base (c-> objc-object? boolean?)]
  [nstextfield-safe-area-insets (c-> objc-object? any/c)]
  [nstextfield-safe-area-layout-guide (c-> objc-object? (or/c nslayoutguide? objc-nil?))]
  [nstextfield-safe-area-rect (c-> objc-object? any/c)]
  [nstextfield-selectable (c-> objc-object? boolean?)]
  [nstextfield-set-selectable! (c-> objc-object? boolean? void?)]
  [nstextfield-shadow (c-> objc-object? (or/c nsshadow? objc-nil?))]
  [nstextfield-set-shadow! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-string-value (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-set-string-value! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-subviews (c-> objc-object? any/c)]
  [nstextfield-set-subviews! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-suggestions-delegate (c-> objc-object? (or/c weakstorage? objc-nil?))]
  [nstextfield-set-suggestions-delegate! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-superview (c-> objc-object? (or/c nsview? objc-nil?))]
  [nstextfield-tag (c-> objc-object? exact-integer?)]
  [nstextfield-set-tag! (c-> objc-object? exact-integer? void?)]
  [nstextfield-target (c-> objc-object? any/c)]
  [nstextfield-set-target! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-text-color (c-> objc-object? (or/c nscolor? objc-nil?))]
  [nstextfield-set-text-color! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-tool-tip (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-set-tool-tip! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-top-anchor (c-> objc-object? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstextfield-touch-bar (c-> objc-object? (or/c nstouchbar? objc-nil?))]
  [nstextfield-set-touch-bar! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-tracking-areas (c-> objc-object? any/c)]
  [nstextfield-trailing-anchor (c-> objc-object? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstextfield-translates-autoresizing-mask-into-constraints (c-> objc-object? boolean?)]
  [nstextfield-set-translates-autoresizing-mask-into-constraints! (c-> objc-object? boolean? void?)]
  [nstextfield-undo-manager (c-> objc-object? (or/c nsundomanager? objc-nil?))]
  [nstextfield-user-activity (c-> objc-object? (or/c nsuseractivity? objc-nil?))]
  [nstextfield-set-user-activity! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-user-interface-layout-direction (c-> objc-object? exact-nonnegative-integer?)]
  [nstextfield-set-user-interface-layout-direction! (c-> objc-object? exact-nonnegative-integer? void?)]
  [nstextfield-uses-single-line-mode (c-> objc-object? boolean?)]
  [nstextfield-set-uses-single-line-mode! (c-> objc-object? boolean? void?)]
  [nstextfield-vertical-content-size-constraint-active (c-> objc-object? boolean?)]
  [nstextfield-set-vertical-content-size-constraint-active! (c-> objc-object? boolean? void?)]
  [nstextfield-visible-rect (c-> objc-object? any/c)]
  [nstextfield-wants-best-resolution-open-gl-surface (c-> objc-object? boolean?)]
  [nstextfield-set-wants-best-resolution-open-gl-surface! (c-> objc-object? boolean? void?)]
  [nstextfield-wants-default-clipping (c-> objc-object? boolean?)]
  [nstextfield-wants-extended-dynamic-range-open-gl-surface (c-> objc-object? boolean?)]
  [nstextfield-set-wants-extended-dynamic-range-open-gl-surface! (c-> objc-object? boolean? void?)]
  [nstextfield-wants-layer (c-> objc-object? boolean?)]
  [nstextfield-set-wants-layer! (c-> objc-object? boolean? void?)]
  [nstextfield-wants-resting-touches (c-> objc-object? boolean?)]
  [nstextfield-set-wants-resting-touches! (c-> objc-object? boolean? void?)]
  [nstextfield-wants-update-layer (c-> objc-object? boolean?)]
  [nstextfield-width-adjust-limit (c-> objc-object? real?)]
  [nstextfield-width-anchor (c-> objc-object? (or/c nslayoutdimension? objc-nil?))]
  [nstextfield-window (c-> objc-object? (or/c nswindow? objc-nil?))]
  [nstextfield-writing-tools-coordinator (c-> objc-object? (or/c nswritingtoolscoordinator? objc-nil?))]
  [nstextfield-set-writing-tools-coordinator! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-accepts-first-mouse (c-> objc-object? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-accessibility-activation-point (c-> objc-object? any/c)]
  [nstextfield-accessibility-allowed-values (c-> objc-object? any/c)]
  [nstextfield-accessibility-application-focused-ui-element (c-> objc-object? any/c)]
  [nstextfield-accessibility-attributed-string-for-range (c-> objc-object? any/c (or/c nsattributedstring? objc-nil?))]
  [nstextfield-accessibility-attributed-user-input-labels (c-> objc-object? any/c)]
  [nstextfield-accessibility-cancel-button (c-> objc-object? any/c)]
  [nstextfield-accessibility-cell-for-column-row (c-> objc-object? exact-integer? exact-integer? any/c)]
  [nstextfield-accessibility-children (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-children-in-navigation-order (c-> objc-object? any/c)]
  [nstextfield-accessibility-clear-button (c-> objc-object? any/c)]
  [nstextfield-accessibility-close-button (c-> objc-object? any/c)]
  [nstextfield-accessibility-column-count (c-> objc-object? exact-integer?)]
  [nstextfield-accessibility-column-header-ui-elements (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-column-index-range (c-> objc-object? any/c)]
  [nstextfield-accessibility-column-titles (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-columns (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-contents (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-critical-value (c-> objc-object? any/c)]
  [nstextfield-accessibility-custom-actions (c-> objc-object? any/c)]
  [nstextfield-accessibility-custom-rotors (c-> objc-object? any/c)]
  [nstextfield-accessibility-decrement-button (c-> objc-object? any/c)]
  [nstextfield-accessibility-default-button (c-> objc-object? any/c)]
  [nstextfield-accessibility-disclosed-by-row (c-> objc-object? any/c)]
  [nstextfield-accessibility-disclosed-rows (c-> objc-object? any/c)]
  [nstextfield-accessibility-disclosure-level (c-> objc-object? exact-integer?)]
  [nstextfield-accessibility-document (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-extras-menu-bar (c-> objc-object? any/c)]
  [nstextfield-accessibility-filename (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-focused-window (c-> objc-object? any/c)]
  [nstextfield-accessibility-frame (c-> objc-object? any/c)]
  [nstextfield-accessibility-frame-for-range (c-> objc-object? any/c any/c)]
  [nstextfield-accessibility-full-screen-button (c-> objc-object? any/c)]
  [nstextfield-accessibility-grow-area (c-> objc-object? any/c)]
  [nstextfield-accessibility-handles (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-header (c-> objc-object? any/c)]
  [nstextfield-accessibility-help (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-horizontal-scroll-bar (c-> objc-object? any/c)]
  [nstextfield-accessibility-horizontal-unit-description (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-horizontal-units (c-> objc-object? exact-nonnegative-integer?)]
  [nstextfield-accessibility-identifier (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-increment-button (c-> objc-object? any/c)]
  [nstextfield-accessibility-index (c-> objc-object? exact-integer?)]
  [nstextfield-accessibility-insertion-point-line-number (c-> objc-object? exact-integer?)]
  [nstextfield-accessibility-label (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-label-ui-elements (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-label-value (c-> objc-object? real?)]
  [nstextfield-accessibility-layout-point-for-screen-point (c-> objc-object? any/c any/c)]
  [nstextfield-accessibility-layout-size-for-screen-size (c-> objc-object? any/c any/c)]
  [nstextfield-accessibility-line-for-index (c-> objc-object? exact-integer? exact-integer?)]
  [nstextfield-accessibility-linked-ui-elements (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-main-window (c-> objc-object? any/c)]
  [nstextfield-accessibility-marker-group-ui-element (c-> objc-object? any/c)]
  [nstextfield-accessibility-marker-type-description (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-marker-ui-elements (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-marker-values (c-> objc-object? any/c)]
  [nstextfield-accessibility-max-value (c-> objc-object? any/c)]
  [nstextfield-accessibility-menu-bar (c-> objc-object? any/c)]
  [nstextfield-accessibility-min-value (c-> objc-object? any/c)]
  [nstextfield-accessibility-minimize-button (c-> objc-object? any/c)]
  [nstextfield-accessibility-next-contents (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-number-of-characters (c-> objc-object? exact-integer?)]
  [nstextfield-accessibility-orientation (c-> objc-object? exact-nonnegative-integer?)]
  [nstextfield-accessibility-overflow-button (c-> objc-object? any/c)]
  [nstextfield-accessibility-parent (c-> objc-object? any/c)]
  [nstextfield-accessibility-perform-cancel (c-> objc-object? boolean?)]
  [nstextfield-accessibility-perform-confirm (c-> objc-object? boolean?)]
  [nstextfield-accessibility-perform-decrement (c-> objc-object? boolean?)]
  [nstextfield-accessibility-perform-delete (c-> objc-object? boolean?)]
  [nstextfield-accessibility-perform-increment (c-> objc-object? boolean?)]
  [nstextfield-accessibility-perform-pick (c-> objc-object? boolean?)]
  [nstextfield-accessibility-perform-press (c-> objc-object? boolean?)]
  [nstextfield-accessibility-perform-raise (c-> objc-object? boolean?)]
  [nstextfield-accessibility-perform-show-alternate-ui (c-> objc-object? boolean?)]
  [nstextfield-accessibility-perform-show-default-ui (c-> objc-object? boolean?)]
  [nstextfield-accessibility-perform-show-menu (c-> objc-object? boolean?)]
  [nstextfield-accessibility-placeholder-value (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-previous-contents (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-proxy (c-> objc-object? any/c)]
  [nstextfield-accessibility-rtf-for-range (c-> objc-object? any/c (or/c nsdata? objc-nil?))]
  [nstextfield-accessibility-range-for-index (c-> objc-object? exact-integer? any/c)]
  [nstextfield-accessibility-range-for-line (c-> objc-object? exact-integer? any/c)]
  [nstextfield-accessibility-range-for-position (c-> objc-object? any/c any/c)]
  [nstextfield-accessibility-role (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-role-description (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-row-count (c-> objc-object? exact-integer?)]
  [nstextfield-accessibility-row-header-ui-elements (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-row-index-range (c-> objc-object? any/c)]
  [nstextfield-accessibility-rows (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-ruler-marker-type (c-> objc-object? exact-nonnegative-integer?)]
  [nstextfield-accessibility-screen-point-for-layout-point (c-> objc-object? any/c any/c)]
  [nstextfield-accessibility-screen-size-for-layout-size (c-> objc-object? any/c any/c)]
  [nstextfield-accessibility-search-button (c-> objc-object? any/c)]
  [nstextfield-accessibility-search-menu (c-> objc-object? any/c)]
  [nstextfield-accessibility-selected-cells (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-selected-children (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-selected-columns (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-selected-rows (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-selected-text (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-selected-text-range (c-> objc-object? any/c)]
  [nstextfield-accessibility-selected-text-ranges (c-> objc-object? any/c)]
  [nstextfield-accessibility-serves-as-title-for-ui-elements (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-shared-character-range (c-> objc-object? any/c)]
  [nstextfield-accessibility-shared-focus-elements (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-shared-text-ui-elements (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-shown-menu (c-> objc-object? any/c)]
  [nstextfield-accessibility-sort-direction (c-> objc-object? exact-nonnegative-integer?)]
  [nstextfield-accessibility-splitters (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-string-for-range (c-> objc-object? any/c (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-style-range-for-index (c-> objc-object? exact-integer? any/c)]
  [nstextfield-accessibility-subrole (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-tabs (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-title (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-title-ui-element (c-> objc-object? any/c)]
  [nstextfield-accessibility-toolbar-button (c-> objc-object? any/c)]
  [nstextfield-accessibility-top-level-ui-element (c-> objc-object? any/c)]
  [nstextfield-accessibility-url (c-> objc-object? (or/c nsurl? objc-nil?))]
  [nstextfield-accessibility-unit-description (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-units (c-> objc-object? exact-nonnegative-integer?)]
  [nstextfield-accessibility-user-input-labels (c-> objc-object? any/c)]
  [nstextfield-accessibility-value (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-value-description (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-vertical-scroll-bar (c-> objc-object? any/c)]
  [nstextfield-accessibility-vertical-unit-description (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-accessibility-vertical-units (c-> objc-object? exact-nonnegative-integer?)]
  [nstextfield-accessibility-visible-cells (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-visible-character-range (c-> objc-object? any/c)]
  [nstextfield-accessibility-visible-children (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-visible-columns (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-visible-rows (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-warning-value (c-> objc-object? any/c)]
  [nstextfield-accessibility-window (c-> objc-object? any/c)]
  [nstextfield-accessibility-windows (c-> objc-object? (or/c nsarray? objc-nil?))]
  [nstextfield-accessibility-zoom-button (c-> objc-object? any/c)]
  [nstextfield-add-subview! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-add-subview-positioned-relative-to! (c-> objc-object? (or/c string? objc-object? #f) exact-nonnegative-integer? (or/c string? objc-object? #f) void?)]
  [nstextfield-add-tool-tip-rect-owner-user-data! (c-> objc-object? any/c (or/c string? objc-object? #f) (or/c cpointer? #f) exact-integer?)]
  [nstextfield-adjust-scroll (c-> objc-object? any/c any/c)]
  [nstextfield-ancestor-shared-with-view (c-> objc-object? (or/c string? objc-object? #f) (or/c nsview? objc-nil?))]
  [nstextfield-animation-for-key (c-> objc-object? (or/c string? objc-object? #f) any/c)]
  [nstextfield-animations (c-> objc-object? any/c)]
  [nstextfield-animator (c-> objc-object? any/c)]
  [nstextfield-appearance (c-> objc-object? (or/c nsappearance? objc-nil?))]
  [nstextfield-autoscroll (c-> objc-object? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-backing-aligned-rect-options (c-> objc-object? any/c exact-nonnegative-integer? any/c)]
  [nstextfield-become-first-responder (c-> objc-object? boolean?)]
  [nstextfield-begin-gesture-with-event! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-bitmap-image-rep-for-caching-display-in-rect (c-> objc-object? any/c (or/c nsbitmapimagerep? objc-nil?))]
  [nstextfield-cache-display-in-rect-to-bitmap-image-rep (c-> objc-object? any/c (or/c string? objc-object? #f) void?)]
  [nstextfield-cancel-operation (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-capitalize-word (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-center-scan-rect! (c-> objc-object? any/c any/c)]
  [nstextfield-center-selection-in-visible-area! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-change-case-of-letter (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-change-mode-with-event (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-complete (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-conclude-drag-operation (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-content-type (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-context-menu-key-down (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-convert-point-from-view (c-> objc-object? any/c (or/c string? objc-object? #f) any/c)]
  [nstextfield-convert-point-to-view (c-> objc-object? any/c (or/c string? objc-object? #f) any/c)]
  [nstextfield-convert-point-from-backing (c-> objc-object? any/c any/c)]
  [nstextfield-convert-point-from-layer (c-> objc-object? any/c any/c)]
  [nstextfield-convert-point-to-backing (c-> objc-object? any/c any/c)]
  [nstextfield-convert-point-to-layer (c-> objc-object? any/c any/c)]
  [nstextfield-convert-rect-from-view (c-> objc-object? any/c (or/c string? objc-object? #f) any/c)]
  [nstextfield-convert-rect-to-view (c-> objc-object? any/c (or/c string? objc-object? #f) any/c)]
  [nstextfield-convert-rect-from-backing (c-> objc-object? any/c any/c)]
  [nstextfield-convert-rect-from-layer (c-> objc-object? any/c any/c)]
  [nstextfield-convert-rect-to-backing (c-> objc-object? any/c any/c)]
  [nstextfield-convert-rect-to-layer (c-> objc-object? any/c any/c)]
  [nstextfield-convert-size-from-view (c-> objc-object? any/c (or/c string? objc-object? #f) any/c)]
  [nstextfield-convert-size-to-view (c-> objc-object? any/c (or/c string? objc-object? #f) any/c)]
  [nstextfield-convert-size-from-backing (c-> objc-object? any/c any/c)]
  [nstextfield-convert-size-from-layer (c-> objc-object? any/c any/c)]
  [nstextfield-convert-size-to-backing (c-> objc-object? any/c any/c)]
  [nstextfield-convert-size-to-layer (c-> objc-object? any/c any/c)]
  [nstextfield-cursor-update (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-backward (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-backward-by-decomposing-previous-character (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-forward (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-to-beginning-of-line (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-to-beginning-of-paragraph (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-to-end-of-line (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-to-end-of-paragraph (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-to-mark (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-word-backward (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-delete-word-forward (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-did-add-subview (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-did-close-menu-with-event (c-> objc-object? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstextfield-display! (c-> objc-object? void?)]
  [nstextfield-display-if-needed! (c-> objc-object? void?)]
  [nstextfield-display-if-needed-ignoring-opacity! (c-> objc-object? void?)]
  [nstextfield-display-if-needed-in-rect! (c-> objc-object? any/c void?)]
  [nstextfield-display-if-needed-in-rect-ignoring-opacity! (c-> objc-object? any/c void?)]
  [nstextfield-display-rect! (c-> objc-object? any/c void?)]
  [nstextfield-display-rect-ignoring-opacity! (c-> objc-object? any/c void?)]
  [nstextfield-display-rect-ignoring-opacity-in-context! (c-> objc-object? any/c (or/c string? objc-object? #f) void?)]
  [nstextfield-do-command-by-selector (c-> objc-object? string? void?)]
  [nstextfield-dragging-ended (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-dragging-entered (c-> objc-object? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nstextfield-dragging-exited (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-dragging-updated (c-> objc-object? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nstextfield-draw-rect (c-> objc-object? any/c void?)]
  [nstextfield-draw-with-expansion-frame-in-view (c-> objc-object? any/c (or/c string? objc-object? #f) void?)]
  [nstextfield-effective-appearance (c-> objc-object? (or/c nsappearance? objc-nil?))]
  [nstextfield-encode-with-coder (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-end-gesture-with-event! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-expansion-frame-with-frame (c-> objc-object? any/c any/c)]
  [nstextfield-flags-changed (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-flush-buffered-key-events (c-> objc-object? void?)]
  [nstextfield-get-rects-being-drawn-count (c-> objc-object? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nstextfield-get-rects-exposed-during-live-resize-count (c-> objc-object? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nstextfield-help-requested (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-hit-test (c-> objc-object? any/c (or/c nsview? objc-nil?))]
  [nstextfield-identifier (c-> objc-object? (or/c nsstring? objc-nil?))]
  [nstextfield-indent (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-backtab! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-container-break! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-double-quote-ignoring-substitution! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-line-break! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-newline! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-newline-ignoring-field-editor! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-paragraph-separator! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-single-quote-ignoring-substitution! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-tab! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-tab-ignoring-field-editor! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-insert-text! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-interpret-key-events (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-is-accessibility-alternate-ui-visible (c-> objc-object? boolean?)]
  [nstextfield-is-accessibility-disclosed (c-> objc-object? boolean?)]
  [nstextfield-is-accessibility-edited (c-> objc-object? boolean?)]
  [nstextfield-is-accessibility-element (c-> objc-object? boolean?)]
  [nstextfield-is-accessibility-enabled (c-> objc-object? boolean?)]
  [nstextfield-is-accessibility-expanded (c-> objc-object? boolean?)]
  [nstextfield-is-accessibility-focused (c-> objc-object? boolean?)]
  [nstextfield-is-accessibility-frontmost (c-> objc-object? boolean?)]
  [nstextfield-is-accessibility-hidden (c-> objc-object? boolean?)]
  [nstextfield-is-accessibility-main (c-> objc-object? boolean?)]
  [nstextfield-is-accessibility-minimized (c-> objc-object? boolean?)]
  [nstextfield-is-accessibility-modal (c-> objc-object? boolean?)]
  [nstextfield-is-accessibility-ordered-by-row (c-> objc-object? boolean?)]
  [nstextfield-is-accessibility-protected-content (c-> objc-object? boolean?)]
  [nstextfield-is-accessibility-required (c-> objc-object? boolean?)]
  [nstextfield-is-accessibility-selected (c-> objc-object? boolean?)]
  [nstextfield-is-accessibility-selector-allowed (c-> objc-object? string? boolean?)]
  [nstextfield-is-bezeled (c-> objc-object? boolean?)]
  [nstextfield-is-bordered (c-> objc-object? boolean?)]
  [nstextfield-is-continuous (c-> objc-object? boolean?)]
  [nstextfield-is-descendant-of (c-> objc-object? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-is-editable (c-> objc-object? boolean?)]
  [nstextfield-is-enabled (c-> objc-object? boolean?)]
  [nstextfield-is-flipped (c-> objc-object? boolean?)]
  [nstextfield-is-hidden (c-> objc-object? boolean?)]
  [nstextfield-is-hidden-or-has-hidden-ancestor (c-> objc-object? boolean?)]
  [nstextfield-is-highlighted (c-> objc-object? boolean?)]
  [nstextfield-is-opaque (c-> objc-object? boolean?)]
  [nstextfield-is-rotated-from-base (c-> objc-object? boolean?)]
  [nstextfield-is-rotated-or-scaled-from-base (c-> objc-object? boolean?)]
  [nstextfield-is-selectable (c-> objc-object? boolean?)]
  [nstextfield-key-down (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-key-up (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-layout (c-> objc-object? void?)]
  [nstextfield-layout-subtree-if-needed (c-> objc-object? void?)]
  [nstextfield-lowercase-word (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-magnify-with-event (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-make-backing-layer (c-> objc-object? (or/c calayer? objc-nil?))]
  [nstextfield-make-base-writing-direction-left-to-right (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-make-base-writing-direction-natural (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-make-base-writing-direction-right-to-left (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-make-text-writing-direction-left-to-right (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-make-text-writing-direction-natural (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-make-text-writing-direction-right-to-left (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-menu-for-event (c-> objc-object? (or/c string? objc-object? #f) (or/c nsmenu? objc-nil?))]
  [nstextfield-mouse-in-rect (c-> objc-object? any/c any/c boolean?)]
  [nstextfield-mouse-cancelled (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-mouse-down (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-mouse-dragged (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-mouse-entered (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-mouse-exited (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-mouse-moved (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-mouse-up (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-backward! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-backward-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-down! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-down-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-forward! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-forward-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-left! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-left-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-paragraph-backward-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-paragraph-forward-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-right! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-right-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-beginning-of-document! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-beginning-of-document-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-beginning-of-line! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-beginning-of-line-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-beginning-of-paragraph! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-beginning-of-paragraph-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-end-of-document! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-end-of-document-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-end-of-line! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-end-of-line-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-end-of-paragraph! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-end-of-paragraph-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-left-end-of-line! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-left-end-of-line-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-right-end-of-line! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-to-right-end-of-line-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-up! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-up-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-word-backward! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-word-backward-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-word-forward! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-word-forward-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-word-left! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-word-left-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-word-right! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-move-word-right-and-modify-selection! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-needs-to-draw-rect (c-> objc-object? any/c boolean?)]
  [nstextfield-no-responder-for (c-> objc-object? string? void?)]
  [nstextfield-other-mouse-down (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-other-mouse-dragged (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-other-mouse-up (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-page-down (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-page-down-and-modify-selection (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-page-up (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-page-up-and-modify-selection (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-perform-click! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-perform-drag-operation! (c-> objc-object? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-perform-key-equivalent! (c-> objc-object? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-prepare-content-in-rect (c-> objc-object? any/c void?)]
  [nstextfield-prepare-for-drag-operation (c-> objc-object? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-prepare-for-reuse (c-> objc-object? void?)]
  [nstextfield-pressure-change-with-event (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-quick-look-preview-items (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-quick-look-with-event (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-rect-for-smart-magnification-at-point-in-rect (c-> objc-object? any/c any/c any/c)]
  [nstextfield-remove-all-tool-tips! (c-> objc-object? void?)]
  [nstextfield-remove-from-superview! (c-> objc-object? void?)]
  [nstextfield-remove-from-superview-without-needing-display! (c-> objc-object? void?)]
  [nstextfield-remove-tool-tip! (c-> objc-object? exact-integer? void?)]
  [nstextfield-replace-subview-with! (c-> objc-object? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstextfield-resign-first-responder (c-> objc-object? boolean?)]
  [nstextfield-resize-subviews-with-old-size (c-> objc-object? any/c void?)]
  [nstextfield-resize-with-old-superview-size (c-> objc-object? any/c void?)]
  [nstextfield-restore-user-activity-state (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-right-mouse-down (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-right-mouse-dragged (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-right-mouse-up (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-rotate-by-angle (c-> objc-object? real? void?)]
  [nstextfield-rotate-with-event (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-scale-unit-square-to-size (c-> objc-object? any/c void?)]
  [nstextfield-scroll-line-down (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-scroll-line-up (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-scroll-page-down (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-scroll-page-up (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-scroll-point (c-> objc-object? any/c void?)]
  [nstextfield-scroll-rect-to-visible (c-> objc-object? any/c boolean?)]
  [nstextfield-scroll-to-beginning-of-document (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-scroll-to-end-of-document (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-scroll-wheel (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-select-all (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-select-line (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-select-paragraph (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-select-text (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-select-to-mark (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-select-word (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-send-action-to (c-> objc-object? string? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-send-action-on (c-> objc-object? exact-nonnegative-integer? exact-integer?)]
  [nstextfield-set-accessibility-activation-point! (c-> objc-object? any/c void?)]
  [nstextfield-set-accessibility-allowed-values! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-alternate-ui-visible! (c-> objc-object? boolean? void?)]
  [nstextfield-set-accessibility-application-focused-ui-element! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-attributed-user-input-labels! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-cancel-button! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-children! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-children-in-navigation-order! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-clear-button! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-close-button! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-column-count! (c-> objc-object? exact-integer? void?)]
  [nstextfield-set-accessibility-column-header-ui-elements! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-column-index-range! (c-> objc-object? any/c void?)]
  [nstextfield-set-accessibility-column-titles! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-columns! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-contents! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-critical-value! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-custom-actions! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-custom-rotors! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-decrement-button! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-default-button! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-disclosed! (c-> objc-object? boolean? void?)]
  [nstextfield-set-accessibility-disclosed-by-row! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-disclosed-rows! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-disclosure-level! (c-> objc-object? exact-integer? void?)]
  [nstextfield-set-accessibility-document! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-edited! (c-> objc-object? boolean? void?)]
  [nstextfield-set-accessibility-element! (c-> objc-object? boolean? void?)]
  [nstextfield-set-accessibility-enabled! (c-> objc-object? boolean? void?)]
  [nstextfield-set-accessibility-expanded! (c-> objc-object? boolean? void?)]
  [nstextfield-set-accessibility-extras-menu-bar! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-filename! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-focused! (c-> objc-object? boolean? void?)]
  [nstextfield-set-accessibility-focused-window! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-frame! (c-> objc-object? any/c void?)]
  [nstextfield-set-accessibility-frontmost! (c-> objc-object? boolean? void?)]
  [nstextfield-set-accessibility-full-screen-button! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-grow-area! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-handles! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-header! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-help! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-hidden! (c-> objc-object? boolean? void?)]
  [nstextfield-set-accessibility-horizontal-scroll-bar! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-horizontal-unit-description! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-horizontal-units! (c-> objc-object? exact-nonnegative-integer? void?)]
  [nstextfield-set-accessibility-identifier! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-increment-button! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-index! (c-> objc-object? exact-integer? void?)]
  [nstextfield-set-accessibility-insertion-point-line-number! (c-> objc-object? exact-integer? void?)]
  [nstextfield-set-accessibility-label! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-label-ui-elements! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-label-value! (c-> objc-object? real? void?)]
  [nstextfield-set-accessibility-linked-ui-elements! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-main! (c-> objc-object? boolean? void?)]
  [nstextfield-set-accessibility-main-window! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-marker-group-ui-element! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-marker-type-description! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-marker-ui-elements! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-marker-values! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-max-value! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-menu-bar! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-min-value! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-minimize-button! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-minimized! (c-> objc-object? boolean? void?)]
  [nstextfield-set-accessibility-modal! (c-> objc-object? boolean? void?)]
  [nstextfield-set-accessibility-next-contents! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-number-of-characters! (c-> objc-object? exact-integer? void?)]
  [nstextfield-set-accessibility-ordered-by-row! (c-> objc-object? boolean? void?)]
  [nstextfield-set-accessibility-orientation! (c-> objc-object? exact-nonnegative-integer? void?)]
  [nstextfield-set-accessibility-overflow-button! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-parent! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-placeholder-value! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-previous-contents! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-protected-content! (c-> objc-object? boolean? void?)]
  [nstextfield-set-accessibility-proxy! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-required! (c-> objc-object? boolean? void?)]
  [nstextfield-set-accessibility-role! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-role-description! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-row-count! (c-> objc-object? exact-integer? void?)]
  [nstextfield-set-accessibility-row-header-ui-elements! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-row-index-range! (c-> objc-object? any/c void?)]
  [nstextfield-set-accessibility-rows! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-ruler-marker-type! (c-> objc-object? exact-nonnegative-integer? void?)]
  [nstextfield-set-accessibility-search-button! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-search-menu! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-selected! (c-> objc-object? boolean? void?)]
  [nstextfield-set-accessibility-selected-cells! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-selected-children! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-selected-columns! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-selected-rows! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-selected-text! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-selected-text-range! (c-> objc-object? any/c void?)]
  [nstextfield-set-accessibility-selected-text-ranges! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-serves-as-title-for-ui-elements! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-shared-character-range! (c-> objc-object? any/c void?)]
  [nstextfield-set-accessibility-shared-focus-elements! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-shared-text-ui-elements! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-shown-menu! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-sort-direction! (c-> objc-object? exact-nonnegative-integer? void?)]
  [nstextfield-set-accessibility-splitters! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-subrole! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-tabs! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-title! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-title-ui-element! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-toolbar-button! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-top-level-ui-element! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-url! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-unit-description! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-units! (c-> objc-object? exact-nonnegative-integer? void?)]
  [nstextfield-set-accessibility-user-input-labels! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-value! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-value-description! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-vertical-scroll-bar! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-vertical-unit-description! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-vertical-units! (c-> objc-object? exact-nonnegative-integer? void?)]
  [nstextfield-set-accessibility-visible-cells! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-visible-character-range! (c-> objc-object? any/c void?)]
  [nstextfield-set-accessibility-visible-children! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-visible-columns! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-visible-rows! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-warning-value! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-window! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-windows! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-accessibility-zoom-button! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-animations! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-appearance! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-bounds-origin! (c-> objc-object? any/c void?)]
  [nstextfield-set-bounds-size! (c-> objc-object? any/c void?)]
  [nstextfield-set-content-type! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-frame-origin! (c-> objc-object? any/c void?)]
  [nstextfield-set-frame-size! (c-> objc-object? any/c void?)]
  [nstextfield-set-identifier! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-mark! (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-set-needs-display-in-rect! (c-> objc-object? any/c void?)]
  [nstextfield-should-be-treated-as-ink-event (c-> objc-object? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-should-delay-window-ordering-for-event (c-> objc-object? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-show-context-help (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-show-context-menu-for-selection (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-size-that-fits (c-> objc-object? any/c any/c)]
  [nstextfield-size-to-fit (c-> objc-object? void?)]
  [nstextfield-smart-magnify-with-event (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-sort-subviews-using-function-context (c-> objc-object? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nstextfield-supplemental-target-for-action-sender (c-> objc-object? string? (or/c string? objc-object? #f) any/c)]
  [nstextfield-swap-with-mark (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-swipe-with-event (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-tablet-point (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-tablet-proximity (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-take-double-value-from (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-take-float-value-from (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-take-int-value-from (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-take-integer-value-from (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-take-object-value-from (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-take-string-value-from (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-text-did-begin-editing (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-text-did-change (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-text-did-end-editing (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-text-should-begin-editing (c-> objc-object? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-text-should-end-editing (c-> objc-object? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-touches-began-with-event (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-touches-cancelled-with-event (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-touches-ended-with-event (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-touches-moved-with-event (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-translate-origin-to-point (c-> objc-object? any/c void?)]
  [nstextfield-translate-rects-needing-display-in-rect-by (c-> objc-object? any/c any/c void?)]
  [nstextfield-transpose (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-transpose-words (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-try-to-perform-with (c-> objc-object? string? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-update-dragging-items-for-drag (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-update-layer (c-> objc-object? void?)]
  [nstextfield-uppercase-word (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-valid-requestor-for-send-type-return-type (c-> objc-object? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nstextfield-validate-user-interface-item (c-> objc-object? (or/c string? objc-object? #f) boolean?)]
  [nstextfield-view-did-change-backing-properties (c-> objc-object? void?)]
  [nstextfield-view-did-change-effective-appearance (c-> objc-object? void?)]
  [nstextfield-view-did-end-live-resize (c-> objc-object? void?)]
  [nstextfield-view-did-hide (c-> objc-object? void?)]
  [nstextfield-view-did-move-to-superview (c-> objc-object? void?)]
  [nstextfield-view-did-move-to-window (c-> objc-object? void?)]
  [nstextfield-view-did-unhide (c-> objc-object? void?)]
  [nstextfield-view-will-draw (c-> objc-object? void?)]
  [nstextfield-view-will-move-to-superview (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-view-will-move-to-window (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-view-will-start-live-resize (c-> objc-object? void?)]
  [nstextfield-view-with-tag (c-> objc-object? exact-integer? any/c)]
  [nstextfield-wants-forwarded-scroll-events-for-axis (c-> objc-object? exact-nonnegative-integer? boolean?)]
  [nstextfield-wants-periodic-dragging-updates (c-> objc-object? boolean?)]
  [nstextfield-wants-scroll-events-for-swipe-tracking-on-axis (c-> objc-object? exact-nonnegative-integer? boolean?)]
  [nstextfield-will-open-menu-with-event (c-> objc-object? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstextfield-will-remove-subview (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-yank (c-> objc-object? (or/c string? objc-object? #f) void?)]
  [nstextfield-default-animation-for-key (c-> (or/c string? objc-object? #f) any/c)]
  [nstextfield-is-compatible-with-responsive-scrolling (c-> boolean?)]
  )

;; --- Class reference ---
(import-class NSTextField)

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
(define (make-nstextfield-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSTextField alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nstextfield-init-with-frame frame-rect)
  (wrap-objc-object
   (_msg-23 (tell NSTextField alloc)
       (sel_registerName "initWithFrame:")
       frame-rect)
   #:retained #t))


;; --- Properties ---
(define (nstextfield-accepts-first-responder self)
  (tell #:type _bool (coerce-arg self) acceptsFirstResponder))
(define (nstextfield-accepts-touch-events self)
  (tell #:type _bool (coerce-arg self) acceptsTouchEvents))
(define (nstextfield-set-accepts-touch-events! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setAcceptsTouchEvents:") value))
(define (nstextfield-action self)
  (tell #:type _pointer (coerce-arg self) action))
(define (nstextfield-set-action! self value)
  (_msg-47 (coerce-arg self) (sel_registerName "setAction:") (sel_registerName value)))
(define (nstextfield-additional-safe-area-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) additionalSafeAreaInsets))
(define (nstextfield-set-additional-safe-area-insets! self value)
  (_msg-10 (coerce-arg self) (sel_registerName "setAdditionalSafeAreaInsets:") value))
(define (nstextfield-alignment self)
  (tell #:type _int64 (coerce-arg self) alignment))
(define (nstextfield-set-alignment! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setAlignment:") value))
(define (nstextfield-alignment-rect-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) alignmentRectInsets))
(define (nstextfield-allowed-touch-types self)
  (tell #:type _uint64 (coerce-arg self) allowedTouchTypes))
(define (nstextfield-set-allowed-touch-types! self value)
  (_msg-52 (coerce-arg self) (sel_registerName "setAllowedTouchTypes:") value))
(define (nstextfield-allows-character-picker-touch-bar-item self)
  (tell #:type _bool (coerce-arg self) allowsCharacterPickerTouchBarItem))
(define (nstextfield-set-allows-character-picker-touch-bar-item! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setAllowsCharacterPickerTouchBarItem:") value))
(define (nstextfield-allows-default-tightening-for-truncation self)
  (tell #:type _bool (coerce-arg self) allowsDefaultTighteningForTruncation))
(define (nstextfield-set-allows-default-tightening-for-truncation! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setAllowsDefaultTighteningForTruncation:") value))
(define (nstextfield-allows-editing-text-attributes self)
  (tell #:type _bool (coerce-arg self) allowsEditingTextAttributes))
(define (nstextfield-set-allows-editing-text-attributes! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setAllowsEditingTextAttributes:") value))
(define (nstextfield-allows-expansion-tool-tips self)
  (tell #:type _bool (coerce-arg self) allowsExpansionToolTips))
(define (nstextfield-set-allows-expansion-tool-tips! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setAllowsExpansionToolTips:") value))
(define (nstextfield-allows-vibrancy self)
  (tell #:type _bool (coerce-arg self) allowsVibrancy))
(define (nstextfield-allows-writing-tools self)
  (tell #:type _bool (coerce-arg self) allowsWritingTools))
(define (nstextfield-set-allows-writing-tools! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setAllowsWritingTools:") value))
(define (nstextfield-allows-writing-tools-affordance self)
  (tell #:type _bool (coerce-arg self) allowsWritingToolsAffordance))
(define (nstextfield-set-allows-writing-tools-affordance! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setAllowsWritingToolsAffordance:") value))
(define (nstextfield-alpha-value self)
  (tell #:type _double (coerce-arg self) alphaValue))
(define (nstextfield-set-alpha-value! self value)
  (_msg-34 (coerce-arg self) (sel_registerName "setAlphaValue:") value))
(define (nstextfield-attributed-string-value self)
  (wrap-objc-object
   (tell (coerce-arg self) attributedStringValue)))
(define (nstextfield-set-attributed-string-value! self value)
  (tell #:type _void (coerce-arg self) setAttributedStringValue: (coerce-arg value)))
(define (nstextfield-automatic-text-completion-enabled self)
  (tell #:type _bool (coerce-arg self) automaticTextCompletionEnabled))
(define (nstextfield-set-automatic-text-completion-enabled! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setAutomaticTextCompletionEnabled:") value))
(define (nstextfield-autoresizes-subviews self)
  (tell #:type _bool (coerce-arg self) autoresizesSubviews))
(define (nstextfield-set-autoresizes-subviews! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setAutoresizesSubviews:") value))
(define (nstextfield-autoresizing-mask self)
  (tell #:type _uint64 (coerce-arg self) autoresizingMask))
(define (nstextfield-set-autoresizing-mask! self value)
  (_msg-52 (coerce-arg self) (sel_registerName "setAutoresizingMask:") value))
(define (nstextfield-background-color self)
  (wrap-objc-object
   (tell (coerce-arg self) backgroundColor)))
(define (nstextfield-set-background-color! self value)
  (tell #:type _void (coerce-arg self) setBackgroundColor: (coerce-arg value)))
(define (nstextfield-background-filters self)
  (wrap-objc-object
   (tell (coerce-arg self) backgroundFilters)))
(define (nstextfield-set-background-filters! self value)
  (tell #:type _void (coerce-arg self) setBackgroundFilters: (coerce-arg value)))
(define (nstextfield-base-writing-direction self)
  (tell #:type _int64 (coerce-arg self) baseWritingDirection))
(define (nstextfield-set-base-writing-direction! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setBaseWritingDirection:") value))
(define (nstextfield-baseline-offset-from-bottom self)
  (tell #:type _double (coerce-arg self) baselineOffsetFromBottom))
(define (nstextfield-bezel-style self)
  (tell #:type _uint64 (coerce-arg self) bezelStyle))
(define (nstextfield-set-bezel-style! self value)
  (_msg-52 (coerce-arg self) (sel_registerName "setBezelStyle:") value))
(define (nstextfield-bezeled self)
  (tell #:type _bool (coerce-arg self) bezeled))
(define (nstextfield-set-bezeled! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setBezeled:") value))
(define (nstextfield-bordered self)
  (tell #:type _bool (coerce-arg self) bordered))
(define (nstextfield-set-bordered! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setBordered:") value))
(define (nstextfield-bottom-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) bottomAnchor)))
(define (nstextfield-bounds self)
  (tell #:type _NSRect (coerce-arg self) bounds))
(define (nstextfield-set-bounds! self value)
  (_msg-24 (coerce-arg self) (sel_registerName "setBounds:") value))
(define (nstextfield-bounds-rotation self)
  (tell #:type _double (coerce-arg self) boundsRotation))
(define (nstextfield-set-bounds-rotation! self value)
  (_msg-34 (coerce-arg self) (sel_registerName "setBoundsRotation:") value))
(define (nstextfield-can-become-key-view self)
  (tell #:type _bool (coerce-arg self) canBecomeKeyView))
(define (nstextfield-can-draw self)
  (tell #:type _bool (coerce-arg self) canDraw))
(define (nstextfield-can-draw-concurrently self)
  (tell #:type _bool (coerce-arg self) canDrawConcurrently))
(define (nstextfield-set-can-draw-concurrently! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setCanDrawConcurrently:") value))
(define (nstextfield-can-draw-subviews-into-layer self)
  (tell #:type _bool (coerce-arg self) canDrawSubviewsIntoLayer))
(define (nstextfield-set-can-draw-subviews-into-layer! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setCanDrawSubviewsIntoLayer:") value))
(define (nstextfield-candidate-list-touch-bar-item self)
  (wrap-objc-object
   (tell (coerce-arg self) candidateListTouchBarItem)))
(define (nstextfield-cell self)
  (wrap-objc-object
   (tell (coerce-arg self) cell)))
(define (nstextfield-set-cell! self value)
  (tell #:type _void (coerce-arg self) setCell: (coerce-arg value)))
(define (nstextfield-cell-class)
  (tell #:type _pointer NSTextField cellClass))
(define (nstextfield-set-cell-class! value)
  (_msg-47 NSTextField (sel_registerName "setCellClass:") value))
(define (nstextfield-center-x-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) centerXAnchor)))
(define (nstextfield-center-y-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) centerYAnchor)))
(define (nstextfield-clips-to-bounds self)
  (tell #:type _bool (coerce-arg self) clipsToBounds))
(define (nstextfield-set-clips-to-bounds! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setClipsToBounds:") value))
(define (nstextfield-compatible-with-responsive-scrolling)
  (tell #:type _bool NSTextField compatibleWithResponsiveScrolling))
(define (nstextfield-compositing-filter self)
  (wrap-objc-object
   (tell (coerce-arg self) compositingFilter)))
(define (nstextfield-set-compositing-filter! self value)
  (tell #:type _void (coerce-arg self) setCompositingFilter: (coerce-arg value)))
(define (nstextfield-constraints self)
  (wrap-objc-object
   (tell (coerce-arg self) constraints)))
(define (nstextfield-content-filters self)
  (wrap-objc-object
   (tell (coerce-arg self) contentFilters)))
(define (nstextfield-set-content-filters! self value)
  (tell #:type _void (coerce-arg self) setContentFilters: (coerce-arg value)))
(define (nstextfield-continuous self)
  (tell #:type _bool (coerce-arg self) continuous))
(define (nstextfield-set-continuous! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setContinuous:") value))
(define (nstextfield-control-size self)
  (tell #:type _uint64 (coerce-arg self) controlSize))
(define (nstextfield-set-control-size! self value)
  (_msg-52 (coerce-arg self) (sel_registerName "setControlSize:") value))
(define (nstextfield-default-focus-ring-type)
  (tell #:type _uint64 NSTextField defaultFocusRingType))
(define (nstextfield-default-menu)
  (wrap-objc-object
   (tell NSTextField defaultMenu)))
(define (nstextfield-delegate self)
  (wrap-objc-object
   (tell (coerce-arg self) delegate)))
(define (nstextfield-set-delegate! self value)
  (tell #:type _void (coerce-arg self) setDelegate: (coerce-arg value)))
(define (nstextfield-double-value self)
  (tell #:type _double (coerce-arg self) doubleValue))
(define (nstextfield-set-double-value! self value)
  (_msg-34 (coerce-arg self) (sel_registerName "setDoubleValue:") value))
(define (nstextfield-drawing-find-indicator self)
  (tell #:type _bool (coerce-arg self) drawingFindIndicator))
(define (nstextfield-draws-background self)
  (tell #:type _bool (coerce-arg self) drawsBackground))
(define (nstextfield-set-draws-background! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setDrawsBackground:") value))
(define (nstextfield-editable self)
  (tell #:type _bool (coerce-arg self) editable))
(define (nstextfield-set-editable! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setEditable:") value))
(define (nstextfield-enabled self)
  (tell #:type _bool (coerce-arg self) enabled))
(define (nstextfield-set-enabled! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setEnabled:") value))
(define (nstextfield-enclosing-menu-item self)
  (wrap-objc-object
   (tell (coerce-arg self) enclosingMenuItem)))
(define (nstextfield-enclosing-scroll-view self)
  (wrap-objc-object
   (tell (coerce-arg self) enclosingScrollView)))
(define (nstextfield-first-baseline-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) firstBaselineAnchor)))
(define (nstextfield-first-baseline-offset-from-top self)
  (tell #:type _double (coerce-arg self) firstBaselineOffsetFromTop))
(define (nstextfield-fitting-size self)
  (tell #:type _NSSize (coerce-arg self) fittingSize))
(define (nstextfield-flipped self)
  (tell #:type _bool (coerce-arg self) flipped))
(define (nstextfield-float-value self)
  (tell #:type _float (coerce-arg self) floatValue))
(define (nstextfield-set-float-value! self value)
  (_msg-35 (coerce-arg self) (sel_registerName "setFloatValue:") value))
(define (nstextfield-focus-ring-mask-bounds self)
  (tell #:type _NSRect (coerce-arg self) focusRingMaskBounds))
(define (nstextfield-focus-ring-type self)
  (tell #:type _uint64 (coerce-arg self) focusRingType))
(define (nstextfield-set-focus-ring-type! self value)
  (_msg-52 (coerce-arg self) (sel_registerName "setFocusRingType:") value))
(define (nstextfield-focus-view)
  (wrap-objc-object
   (tell NSTextField focusView)))
(define (nstextfield-font self)
  (wrap-objc-object
   (tell (coerce-arg self) font)))
(define (nstextfield-set-font! self value)
  (tell #:type _void (coerce-arg self) setFont: (coerce-arg value)))
(define (nstextfield-formatter self)
  (wrap-objc-object
   (tell (coerce-arg self) formatter)))
(define (nstextfield-set-formatter! self value)
  (tell #:type _void (coerce-arg self) setFormatter: (coerce-arg value)))
(define (nstextfield-frame self)
  (tell #:type _NSRect (coerce-arg self) frame))
(define (nstextfield-set-frame! self value)
  (_msg-24 (coerce-arg self) (sel_registerName "setFrame:") value))
(define (nstextfield-frame-center-rotation self)
  (tell #:type _double (coerce-arg self) frameCenterRotation))
(define (nstextfield-set-frame-center-rotation! self value)
  (_msg-34 (coerce-arg self) (sel_registerName "setFrameCenterRotation:") value))
(define (nstextfield-frame-rotation self)
  (tell #:type _double (coerce-arg self) frameRotation))
(define (nstextfield-set-frame-rotation! self value)
  (_msg-34 (coerce-arg self) (sel_registerName "setFrameRotation:") value))
(define (nstextfield-gesture-recognizers self)
  (wrap-objc-object
   (tell (coerce-arg self) gestureRecognizers)))
(define (nstextfield-set-gesture-recognizers! self value)
  (tell #:type _void (coerce-arg self) setGestureRecognizers: (coerce-arg value)))
(define (nstextfield-has-ambiguous-layout self)
  (tell #:type _bool (coerce-arg self) hasAmbiguousLayout))
(define (nstextfield-height-adjust-limit self)
  (tell #:type _double (coerce-arg self) heightAdjustLimit))
(define (nstextfield-height-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) heightAnchor)))
(define (nstextfield-hidden self)
  (tell #:type _bool (coerce-arg self) hidden))
(define (nstextfield-set-hidden! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setHidden:") value))
(define (nstextfield-hidden-or-has-hidden-ancestor self)
  (tell #:type _bool (coerce-arg self) hiddenOrHasHiddenAncestor))
(define (nstextfield-highlighted self)
  (tell #:type _bool (coerce-arg self) highlighted))
(define (nstextfield-set-highlighted! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setHighlighted:") value))
(define (nstextfield-horizontal-content-size-constraint-active self)
  (tell #:type _bool (coerce-arg self) horizontalContentSizeConstraintActive))
(define (nstextfield-set-horizontal-content-size-constraint-active! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setHorizontalContentSizeConstraintActive:") value))
(define (nstextfield-ignores-multi-click self)
  (tell #:type _bool (coerce-arg self) ignoresMultiClick))
(define (nstextfield-set-ignores-multi-click! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setIgnoresMultiClick:") value))
(define (nstextfield-imports-graphics self)
  (tell #:type _bool (coerce-arg self) importsGraphics))
(define (nstextfield-set-imports-graphics! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setImportsGraphics:") value))
(define (nstextfield-in-full-screen-mode self)
  (tell #:type _bool (coerce-arg self) inFullScreenMode))
(define (nstextfield-in-live-resize self)
  (tell #:type _bool (coerce-arg self) inLiveResize))
(define (nstextfield-input-context self)
  (wrap-objc-object
   (tell (coerce-arg self) inputContext)))
(define (nstextfield-int-value self)
  (tell #:type _int32 (coerce-arg self) intValue))
(define (nstextfield-set-int-value! self value)
  (_msg-39 (coerce-arg self) (sel_registerName "setIntValue:") value))
(define (nstextfield-integer-value self)
  (tell #:type _int64 (coerce-arg self) integerValue))
(define (nstextfield-set-integer-value! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setIntegerValue:") value))
(define (nstextfield-intrinsic-content-size self)
  (tell #:type _NSSize (coerce-arg self) intrinsicContentSize))
(define (nstextfield-last-baseline-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) lastBaselineAnchor)))
(define (nstextfield-last-baseline-offset-from-bottom self)
  (tell #:type _double (coerce-arg self) lastBaselineOffsetFromBottom))
(define (nstextfield-layer self)
  (wrap-objc-object
   (tell (coerce-arg self) layer)))
(define (nstextfield-set-layer! self value)
  (tell #:type _void (coerce-arg self) setLayer: (coerce-arg value)))
(define (nstextfield-layer-contents-placement self)
  (tell #:type _int64 (coerce-arg self) layerContentsPlacement))
(define (nstextfield-set-layer-contents-placement! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setLayerContentsPlacement:") value))
(define (nstextfield-layer-contents-redraw-policy self)
  (tell #:type _int64 (coerce-arg self) layerContentsRedrawPolicy))
(define (nstextfield-set-layer-contents-redraw-policy! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setLayerContentsRedrawPolicy:") value))
(define (nstextfield-layer-uses-core-image-filters self)
  (tell #:type _bool (coerce-arg self) layerUsesCoreImageFilters))
(define (nstextfield-set-layer-uses-core-image-filters! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setLayerUsesCoreImageFilters:") value))
(define (nstextfield-layout-guides self)
  (wrap-objc-object
   (tell (coerce-arg self) layoutGuides)))
(define (nstextfield-layout-margins-guide self)
  (wrap-objc-object
   (tell (coerce-arg self) layoutMarginsGuide)))
(define (nstextfield-leading-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) leadingAnchor)))
(define (nstextfield-left-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) leftAnchor)))
(define (nstextfield-line-break-mode self)
  (tell #:type _uint64 (coerce-arg self) lineBreakMode))
(define (nstextfield-set-line-break-mode! self value)
  (_msg-52 (coerce-arg self) (sel_registerName "setLineBreakMode:") value))
(define (nstextfield-line-break-strategy self)
  (tell #:type _uint64 (coerce-arg self) lineBreakStrategy))
(define (nstextfield-set-line-break-strategy! self value)
  (_msg-52 (coerce-arg self) (sel_registerName "setLineBreakStrategy:") value))
(define (nstextfield-maximum-number-of-lines self)
  (tell #:type _int64 (coerce-arg self) maximumNumberOfLines))
(define (nstextfield-set-maximum-number-of-lines! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setMaximumNumberOfLines:") value))
(define (nstextfield-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) menu)))
(define (nstextfield-set-menu! self value)
  (tell #:type _void (coerce-arg self) setMenu: (coerce-arg value)))
(define (nstextfield-mouse-down-can-move-window self)
  (tell #:type _bool (coerce-arg self) mouseDownCanMoveWindow))
(define (nstextfield-needs-display self)
  (tell #:type _bool (coerce-arg self) needsDisplay))
(define (nstextfield-set-needs-display! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setNeedsDisplay:") value))
(define (nstextfield-needs-layout self)
  (tell #:type _bool (coerce-arg self) needsLayout))
(define (nstextfield-set-needs-layout! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setNeedsLayout:") value))
(define (nstextfield-needs-panel-to-become-key self)
  (tell #:type _bool (coerce-arg self) needsPanelToBecomeKey))
(define (nstextfield-needs-update-constraints self)
  (tell #:type _bool (coerce-arg self) needsUpdateConstraints))
(define (nstextfield-set-needs-update-constraints! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setNeedsUpdateConstraints:") value))
(define (nstextfield-next-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) nextKeyView)))
(define (nstextfield-set-next-key-view! self value)
  (tell #:type _void (coerce-arg self) setNextKeyView: (coerce-arg value)))
(define (nstextfield-next-responder self)
  (wrap-objc-object
   (tell (coerce-arg self) nextResponder)))
(define (nstextfield-set-next-responder! self value)
  (tell #:type _void (coerce-arg self) setNextResponder: (coerce-arg value)))
(define (nstextfield-next-valid-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) nextValidKeyView)))
(define (nstextfield-object-value self)
  (wrap-objc-object
   (tell (coerce-arg self) objectValue)))
(define (nstextfield-set-object-value! self value)
  (tell #:type _void (coerce-arg self) setObjectValue: (coerce-arg value)))
(define (nstextfield-opaque self)
  (tell #:type _bool (coerce-arg self) opaque))
(define (nstextfield-opaque-ancestor self)
  (wrap-objc-object
   (tell (coerce-arg self) opaqueAncestor)))
(define (nstextfield-page-footer self)
  (wrap-objc-object
   (tell (coerce-arg self) pageFooter)))
(define (nstextfield-page-header self)
  (wrap-objc-object
   (tell (coerce-arg self) pageHeader)))
(define (nstextfield-placeholder-attributed-string self)
  (wrap-objc-object
   (tell (coerce-arg self) placeholderAttributedString)))
(define (nstextfield-set-placeholder-attributed-string! self value)
  (tell #:type _void (coerce-arg self) setPlaceholderAttributedString: (coerce-arg value)))
(define (nstextfield-placeholder-attributed-strings self)
  (wrap-objc-object
   (tell (coerce-arg self) placeholderAttributedStrings)))
(define (nstextfield-set-placeholder-attributed-strings! self value)
  (tell #:type _void (coerce-arg self) setPlaceholderAttributedStrings: (coerce-arg value)))
(define (nstextfield-placeholder-string self)
  (wrap-objc-object
   (tell (coerce-arg self) placeholderString)))
(define (nstextfield-set-placeholder-string! self value)
  (tell #:type _void (coerce-arg self) setPlaceholderString: (coerce-arg value)))
(define (nstextfield-placeholder-strings self)
  (wrap-objc-object
   (tell (coerce-arg self) placeholderStrings)))
(define (nstextfield-set-placeholder-strings! self value)
  (tell #:type _void (coerce-arg self) setPlaceholderStrings: (coerce-arg value)))
(define (nstextfield-posts-bounds-changed-notifications self)
  (tell #:type _bool (coerce-arg self) postsBoundsChangedNotifications))
(define (nstextfield-set-posts-bounds-changed-notifications! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setPostsBoundsChangedNotifications:") value))
(define (nstextfield-posts-frame-changed-notifications self)
  (tell #:type _bool (coerce-arg self) postsFrameChangedNotifications))
(define (nstextfield-set-posts-frame-changed-notifications! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setPostsFrameChangedNotifications:") value))
(define (nstextfield-preferred-max-layout-width self)
  (tell #:type _double (coerce-arg self) preferredMaxLayoutWidth))
(define (nstextfield-set-preferred-max-layout-width! self value)
  (_msg-34 (coerce-arg self) (sel_registerName "setPreferredMaxLayoutWidth:") value))
(define (nstextfield-prefers-compact-control-size-metrics self)
  (tell #:type _bool (coerce-arg self) prefersCompactControlSizeMetrics))
(define (nstextfield-set-prefers-compact-control-size-metrics! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setPrefersCompactControlSizeMetrics:") value))
(define (nstextfield-prepared-content-rect self)
  (tell #:type _NSRect (coerce-arg self) preparedContentRect))
(define (nstextfield-set-prepared-content-rect! self value)
  (_msg-24 (coerce-arg self) (sel_registerName "setPreparedContentRect:") value))
(define (nstextfield-preserves-content-during-live-resize self)
  (tell #:type _bool (coerce-arg self) preservesContentDuringLiveResize))
(define (nstextfield-pressure-configuration self)
  (wrap-objc-object
   (tell (coerce-arg self) pressureConfiguration)))
(define (nstextfield-set-pressure-configuration! self value)
  (tell #:type _void (coerce-arg self) setPressureConfiguration: (coerce-arg value)))
(define (nstextfield-previous-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) previousKeyView)))
(define (nstextfield-previous-valid-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) previousValidKeyView)))
(define (nstextfield-print-job-title self)
  (wrap-objc-object
   (tell (coerce-arg self) printJobTitle)))
(define (nstextfield-rect-preserved-during-live-resize self)
  (tell #:type _NSRect (coerce-arg self) rectPreservedDuringLiveResize))
(define (nstextfield-refuses-first-responder self)
  (tell #:type _bool (coerce-arg self) refusesFirstResponder))
(define (nstextfield-set-refuses-first-responder! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setRefusesFirstResponder:") value))
(define (nstextfield-registered-dragged-types self)
  (wrap-objc-object
   (tell (coerce-arg self) registeredDraggedTypes)))
(define (nstextfield-requires-constraint-based-layout)
  (tell #:type _bool NSTextField requiresConstraintBasedLayout))
(define (nstextfield-resolves-natural-alignment-with-base-writing-direction self)
  (tell #:type _bool (coerce-arg self) resolvesNaturalAlignmentWithBaseWritingDirection))
(define (nstextfield-set-resolves-natural-alignment-with-base-writing-direction! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setResolvesNaturalAlignmentWithBaseWritingDirection:") value))
(define (nstextfield-restorable-state-key-paths)
  (wrap-objc-object
   (tell NSTextField restorableStateKeyPaths)))
(define (nstextfield-right-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) rightAnchor)))
(define (nstextfield-rotated-from-base self)
  (tell #:type _bool (coerce-arg self) rotatedFromBase))
(define (nstextfield-rotated-or-scaled-from-base self)
  (tell #:type _bool (coerce-arg self) rotatedOrScaledFromBase))
(define (nstextfield-safe-area-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) safeAreaInsets))
(define (nstextfield-safe-area-layout-guide self)
  (wrap-objc-object
   (tell (coerce-arg self) safeAreaLayoutGuide)))
(define (nstextfield-safe-area-rect self)
  (tell #:type _NSRect (coerce-arg self) safeAreaRect))
(define (nstextfield-selectable self)
  (tell #:type _bool (coerce-arg self) selectable))
(define (nstextfield-set-selectable! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setSelectable:") value))
(define (nstextfield-shadow self)
  (wrap-objc-object
   (tell (coerce-arg self) shadow)))
(define (nstextfield-set-shadow! self value)
  (tell #:type _void (coerce-arg self) setShadow: (coerce-arg value)))
(define (nstextfield-string-value self)
  (wrap-objc-object
   (tell (coerce-arg self) stringValue)))
(define (nstextfield-set-string-value! self value)
  (tell #:type _void (coerce-arg self) setStringValue: (coerce-arg value)))
(define (nstextfield-subviews self)
  (wrap-objc-object
   (tell (coerce-arg self) subviews)))
(define (nstextfield-set-subviews! self value)
  (tell #:type _void (coerce-arg self) setSubviews: (coerce-arg value)))
(define (nstextfield-suggestions-delegate self)
  (wrap-objc-object
   (tell (coerce-arg self) suggestionsDelegate)))
(define (nstextfield-set-suggestions-delegate! self value)
  (tell #:type _void (coerce-arg self) setSuggestionsDelegate: (coerce-arg value)))
(define (nstextfield-superview self)
  (wrap-objc-object
   (tell (coerce-arg self) superview)))
(define (nstextfield-tag self)
  (tell #:type _int64 (coerce-arg self) tag))
(define (nstextfield-set-tag! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setTag:") value))
(define (nstextfield-target self)
  (wrap-objc-object
   (tell (coerce-arg self) target)))
(define (nstextfield-set-target! self value)
  (tell #:type _void (coerce-arg self) setTarget: (coerce-arg value)))
(define (nstextfield-text-color self)
  (wrap-objc-object
   (tell (coerce-arg self) textColor)))
(define (nstextfield-set-text-color! self value)
  (tell #:type _void (coerce-arg self) setTextColor: (coerce-arg value)))
(define (nstextfield-tool-tip self)
  (wrap-objc-object
   (tell (coerce-arg self) toolTip)))
(define (nstextfield-set-tool-tip! self value)
  (tell #:type _void (coerce-arg self) setToolTip: (coerce-arg value)))
(define (nstextfield-top-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) topAnchor)))
(define (nstextfield-touch-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) touchBar)))
(define (nstextfield-set-touch-bar! self value)
  (tell #:type _void (coerce-arg self) setTouchBar: (coerce-arg value)))
(define (nstextfield-tracking-areas self)
  (wrap-objc-object
   (tell (coerce-arg self) trackingAreas)))
(define (nstextfield-trailing-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) trailingAnchor)))
(define (nstextfield-translates-autoresizing-mask-into-constraints self)
  (tell #:type _bool (coerce-arg self) translatesAutoresizingMaskIntoConstraints))
(define (nstextfield-set-translates-autoresizing-mask-into-constraints! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setTranslatesAutoresizingMaskIntoConstraints:") value))
(define (nstextfield-undo-manager self)
  (wrap-objc-object
   (tell (coerce-arg self) undoManager)))
(define (nstextfield-user-activity self)
  (wrap-objc-object
   (tell (coerce-arg self) userActivity)))
(define (nstextfield-set-user-activity! self value)
  (tell #:type _void (coerce-arg self) setUserActivity: (coerce-arg value)))
(define (nstextfield-user-interface-layout-direction self)
  (tell #:type _int64 (coerce-arg self) userInterfaceLayoutDirection))
(define (nstextfield-set-user-interface-layout-direction! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setUserInterfaceLayoutDirection:") value))
(define (nstextfield-uses-single-line-mode self)
  (tell #:type _bool (coerce-arg self) usesSingleLineMode))
(define (nstextfield-set-uses-single-line-mode! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setUsesSingleLineMode:") value))
(define (nstextfield-vertical-content-size-constraint-active self)
  (tell #:type _bool (coerce-arg self) verticalContentSizeConstraintActive))
(define (nstextfield-set-vertical-content-size-constraint-active! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setVerticalContentSizeConstraintActive:") value))
(define (nstextfield-visible-rect self)
  (tell #:type _NSRect (coerce-arg self) visibleRect))
(define (nstextfield-wants-best-resolution-open-gl-surface self)
  (tell #:type _bool (coerce-arg self) wantsBestResolutionOpenGLSurface))
(define (nstextfield-set-wants-best-resolution-open-gl-surface! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setWantsBestResolutionOpenGLSurface:") value))
(define (nstextfield-wants-default-clipping self)
  (tell #:type _bool (coerce-arg self) wantsDefaultClipping))
(define (nstextfield-wants-extended-dynamic-range-open-gl-surface self)
  (tell #:type _bool (coerce-arg self) wantsExtendedDynamicRangeOpenGLSurface))
(define (nstextfield-set-wants-extended-dynamic-range-open-gl-surface! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setWantsExtendedDynamicRangeOpenGLSurface:") value))
(define (nstextfield-wants-layer self)
  (tell #:type _bool (coerce-arg self) wantsLayer))
(define (nstextfield-set-wants-layer! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setWantsLayer:") value))
(define (nstextfield-wants-resting-touches self)
  (tell #:type _bool (coerce-arg self) wantsRestingTouches))
(define (nstextfield-set-wants-resting-touches! self value)
  (_msg-33 (coerce-arg self) (sel_registerName "setWantsRestingTouches:") value))
(define (nstextfield-wants-update-layer self)
  (tell #:type _bool (coerce-arg self) wantsUpdateLayer))
(define (nstextfield-width-adjust-limit self)
  (tell #:type _double (coerce-arg self) widthAdjustLimit))
(define (nstextfield-width-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) widthAnchor)))
(define (nstextfield-window self)
  (wrap-objc-object
   (tell (coerce-arg self) window)))
(define (nstextfield-writing-tools-coordinator self)
  (wrap-objc-object
   (tell (coerce-arg self) writingToolsCoordinator)))
(define (nstextfield-set-writing-tools-coordinator! self value)
  (tell #:type _void (coerce-arg self) setWritingToolsCoordinator: (coerce-arg value)))

;; --- Instance methods ---
(define (nstextfield-accepts-first-mouse self event)
  (_msg-36 (coerce-arg self) (sel_registerName "acceptsFirstMouse:") (coerce-arg event)))
(define (nstextfield-accessibility-activation-point self)
  (_msg-0 (coerce-arg self) (sel_registerName "accessibilityActivationPoint")))
(define (nstextfield-accessibility-allowed-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAllowedValues)))
(define (nstextfield-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityApplicationFocusedUIElement)))
(define (nstextfield-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (_msg-19 (coerce-arg self) (sel_registerName "accessibilityAttributedStringForRange:") range)
   ))
(define (nstextfield-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAttributedUserInputLabels)))
(define (nstextfield-accessibility-cancel-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCancelButton)))
(define (nstextfield-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (_msg-45 (coerce-arg self) (sel_registerName "accessibilityCellForColumn:row:") column row)
   ))
(define (nstextfield-accessibility-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildren)))
(define (nstextfield-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildrenInNavigationOrder)))
(define (nstextfield-accessibility-clear-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityClearButton)))
(define (nstextfield-accessibility-close-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCloseButton)))
(define (nstextfield-accessibility-column-count self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityColumnCount")))
(define (nstextfield-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnHeaderUIElements)))
(define (nstextfield-accessibility-column-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityColumnIndexRange")))
(define (nstextfield-accessibility-column-titles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnTitles)))
(define (nstextfield-accessibility-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumns)))
(define (nstextfield-accessibility-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityContents)))
(define (nstextfield-accessibility-critical-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCriticalValue)))
(define (nstextfield-accessibility-custom-actions self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomActions)))
(define (nstextfield-accessibility-custom-rotors self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomRotors)))
(define (nstextfield-accessibility-decrement-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDecrementButton)))
(define (nstextfield-accessibility-default-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDefaultButton)))
(define (nstextfield-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedByRow)))
(define (nstextfield-accessibility-disclosed-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedRows)))
(define (nstextfield-accessibility-disclosure-level self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityDisclosureLevel")))
(define (nstextfield-accessibility-document self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDocument)))
(define (nstextfield-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityExtrasMenuBar)))
(define (nstextfield-accessibility-filename self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFilename)))
(define (nstextfield-accessibility-focused-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFocusedWindow)))
(define (nstextfield-accessibility-frame self)
  (_msg-2 (coerce-arg self) (sel_registerName "accessibilityFrame")))
(define (nstextfield-accessibility-frame-for-range self range)
  (_msg-18 (coerce-arg self) (sel_registerName "accessibilityFrameForRange:") range))
(define (nstextfield-accessibility-full-screen-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFullScreenButton)))
(define (nstextfield-accessibility-grow-area self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityGrowArea)))
(define (nstextfield-accessibility-handles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHandles)))
(define (nstextfield-accessibility-header self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHeader)))
(define (nstextfield-accessibility-help self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHelp)))
(define (nstextfield-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalScrollBar)))
(define (nstextfield-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalUnitDescription)))
(define (nstextfield-accessibility-horizontal-units self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityHorizontalUnits")))
(define (nstextfield-accessibility-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIdentifier)))
(define (nstextfield-accessibility-increment-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIncrementButton)))
(define (nstextfield-accessibility-index self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityIndex")))
(define (nstextfield-accessibility-insertion-point-line-number self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityInsertionPointLineNumber")))
(define (nstextfield-accessibility-label self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabel)))
(define (nstextfield-accessibility-label-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabelUIElements)))
(define (nstextfield-accessibility-label-value self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityLabelValue")))
(define (nstextfield-accessibility-layout-point-for-screen-point self point)
  (_msg-11 (coerce-arg self) (sel_registerName "accessibilityLayoutPointForScreenPoint:") point))
(define (nstextfield-accessibility-layout-size-for-screen-size self size)
  (_msg-30 (coerce-arg self) (sel_registerName "accessibilityLayoutSizeForScreenSize:") size))
(define (nstextfield-accessibility-line-for-index self index)
  (_msg-43 (coerce-arg self) (sel_registerName "accessibilityLineForIndex:") index))
(define (nstextfield-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLinkedUIElements)))
(define (nstextfield-accessibility-main-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMainWindow)))
(define (nstextfield-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerGroupUIElement)))
(define (nstextfield-accessibility-marker-type-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerTypeDescription)))
(define (nstextfield-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerUIElements)))
(define (nstextfield-accessibility-marker-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerValues)))
(define (nstextfield-accessibility-max-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMaxValue)))
(define (nstextfield-accessibility-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMenuBar)))
(define (nstextfield-accessibility-min-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinValue)))
(define (nstextfield-accessibility-minimize-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinimizeButton)))
(define (nstextfield-accessibility-next-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityNextContents)))
(define (nstextfield-accessibility-number-of-characters self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityNumberOfCharacters")))
(define (nstextfield-accessibility-orientation self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityOrientation")))
(define (nstextfield-accessibility-overflow-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityOverflowButton)))
(define (nstextfield-accessibility-parent self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityParent)))
(define (nstextfield-accessibility-perform-cancel self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformCancel")))
(define (nstextfield-accessibility-perform-confirm self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformConfirm")))
(define (nstextfield-accessibility-perform-decrement self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformDecrement")))
(define (nstextfield-accessibility-perform-delete self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformDelete")))
(define (nstextfield-accessibility-perform-increment self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformIncrement")))
(define (nstextfield-accessibility-perform-pick self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformPick")))
(define (nstextfield-accessibility-perform-press self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformPress")))
(define (nstextfield-accessibility-perform-raise self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformRaise")))
(define (nstextfield-accessibility-perform-show-alternate-ui self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowAlternateUI")))
(define (nstextfield-accessibility-perform-show-default-ui self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowDefaultUI")))
(define (nstextfield-accessibility-perform-show-menu self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowMenu")))
(define (nstextfield-accessibility-placeholder-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPlaceholderValue)))
(define (nstextfield-accessibility-previous-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPreviousContents)))
(define (nstextfield-accessibility-proxy self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityProxy)))
(define (nstextfield-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (_msg-19 (coerce-arg self) (sel_registerName "accessibilityRTFForRange:") range)
   ))
(define (nstextfield-accessibility-range-for-index self index)
  (_msg-40 (coerce-arg self) (sel_registerName "accessibilityRangeForIndex:") index))
(define (nstextfield-accessibility-range-for-line self line-number)
  (_msg-40 (coerce-arg self) (sel_registerName "accessibilityRangeForLine:") line-number))
(define (nstextfield-accessibility-range-for-position self point)
  (_msg-12 (coerce-arg self) (sel_registerName "accessibilityRangeForPosition:") point))
(define (nstextfield-accessibility-role self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRole)))
(define (nstextfield-accessibility-role-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRoleDescription)))
(define (nstextfield-accessibility-row-count self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityRowCount")))
(define (nstextfield-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRowHeaderUIElements)))
(define (nstextfield-accessibility-row-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityRowIndexRange")))
(define (nstextfield-accessibility-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRows)))
(define (nstextfield-accessibility-ruler-marker-type self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityRulerMarkerType")))
(define (nstextfield-accessibility-screen-point-for-layout-point self point)
  (_msg-11 (coerce-arg self) (sel_registerName "accessibilityScreenPointForLayoutPoint:") point))
(define (nstextfield-accessibility-screen-size-for-layout-size self size)
  (_msg-30 (coerce-arg self) (sel_registerName "accessibilityScreenSizeForLayoutSize:") size))
(define (nstextfield-accessibility-search-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchButton)))
(define (nstextfield-accessibility-search-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchMenu)))
(define (nstextfield-accessibility-selected-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedCells)))
(define (nstextfield-accessibility-selected-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedChildren)))
(define (nstextfield-accessibility-selected-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedColumns)))
(define (nstextfield-accessibility-selected-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedRows)))
(define (nstextfield-accessibility-selected-text self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedText)))
(define (nstextfield-accessibility-selected-text-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySelectedTextRange")))
(define (nstextfield-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedTextRanges)))
(define (nstextfield-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityServesAsTitleForUIElements)))
(define (nstextfield-accessibility-shared-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySharedCharacterRange")))
(define (nstextfield-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedFocusElements)))
(define (nstextfield-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedTextUIElements)))
(define (nstextfield-accessibility-shown-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityShownMenu)))
(define (nstextfield-accessibility-sort-direction self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilitySortDirection")))
(define (nstextfield-accessibility-splitters self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySplitters)))
(define (nstextfield-accessibility-string-for-range self range)
  (wrap-objc-object
   (_msg-19 (coerce-arg self) (sel_registerName "accessibilityStringForRange:") range)
   ))
(define (nstextfield-accessibility-style-range-for-index self index)
  (_msg-40 (coerce-arg self) (sel_registerName "accessibilityStyleRangeForIndex:") index))
(define (nstextfield-accessibility-subrole self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySubrole)))
(define (nstextfield-accessibility-tabs self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTabs)))
(define (nstextfield-accessibility-title self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitle)))
(define (nstextfield-accessibility-title-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitleUIElement)))
(define (nstextfield-accessibility-toolbar-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityToolbarButton)))
(define (nstextfield-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTopLevelUIElement)))
(define (nstextfield-accessibility-url self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityURL)))
(define (nstextfield-accessibility-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUnitDescription)))
(define (nstextfield-accessibility-units self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityUnits")))
(define (nstextfield-accessibility-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUserInputLabels)))
(define (nstextfield-accessibility-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValue)))
(define (nstextfield-accessibility-value-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValueDescription)))
(define (nstextfield-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalScrollBar)))
(define (nstextfield-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalUnitDescription)))
(define (nstextfield-accessibility-vertical-units self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityVerticalUnits")))
(define (nstextfield-accessibility-visible-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleCells)))
(define (nstextfield-accessibility-visible-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityVisibleCharacterRange")))
(define (nstextfield-accessibility-visible-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleChildren)))
(define (nstextfield-accessibility-visible-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleColumns)))
(define (nstextfield-accessibility-visible-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleRows)))
(define (nstextfield-accessibility-warning-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWarningValue)))
(define (nstextfield-accessibility-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindow)))
(define (nstextfield-accessibility-windows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindows)))
(define (nstextfield-accessibility-zoom-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityZoomButton)))
(define (nstextfield-add-subview! self view)
  (tell #:type _void (coerce-arg self) addSubview: (coerce-arg view)))
(define (nstextfield-add-subview-positioned-relative-to! self view place other-view)
  (_msg-38 (coerce-arg self) (sel_registerName "addSubview:positioned:relativeTo:") (coerce-arg view) place (coerce-arg other-view)))
(define (nstextfield-add-tool-tip-rect-owner-user-data! self rect owner data)
  (_msg-28 (coerce-arg self) (sel_registerName "addToolTipRect:owner:userData:") rect (coerce-arg owner) data))
(define (nstextfield-adjust-scroll self new-visible)
  (_msg-21 (coerce-arg self) (sel_registerName "adjustScroll:") new-visible))
(define (nstextfield-ancestor-shared-with-view self view)
  (wrap-objc-object
   (tell (coerce-arg self) ancestorSharedWithView: (coerce-arg view))))
(define (nstextfield-animation-for-key self key)
  (wrap-objc-object
   (tell (coerce-arg self) animationForKey: (coerce-arg key))))
(define (nstextfield-animations self)
  (wrap-objc-object
   (tell (coerce-arg self) animations)))
(define (nstextfield-animator self)
  (wrap-objc-object
   (tell (coerce-arg self) animator)))
(define (nstextfield-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) appearance)))
(define (nstextfield-autoscroll self event)
  (_msg-36 (coerce-arg self) (sel_registerName "autoscroll:") (coerce-arg event)))
(define (nstextfield-backing-aligned-rect-options self rect options)
  (_msg-29 (coerce-arg self) (sel_registerName "backingAlignedRect:options:") rect options))
(define (nstextfield-become-first-responder self)
  (_msg-3 (coerce-arg self) (sel_registerName "becomeFirstResponder")))
(define (nstextfield-begin-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) beginGestureWithEvent: (coerce-arg event)))
(define (nstextfield-bitmap-image-rep-for-caching-display-in-rect self rect)
  (wrap-objc-object
   (_msg-23 (coerce-arg self) (sel_registerName "bitmapImageRepForCachingDisplayInRect:") rect)
   ))
(define (nstextfield-cache-display-in-rect-to-bitmap-image-rep self rect bitmap-image-rep)
  (_msg-27 (coerce-arg self) (sel_registerName "cacheDisplayInRect:toBitmapImageRep:") rect (coerce-arg bitmap-image-rep)))
(define (nstextfield-cancel-operation self sender)
  (tell #:type _void (coerce-arg self) cancelOperation: (coerce-arg sender)))
(define (nstextfield-capitalize-word self sender)
  (tell #:type _void (coerce-arg self) capitalizeWord: (coerce-arg sender)))
(define (nstextfield-center-scan-rect! self rect)
  (_msg-21 (coerce-arg self) (sel_registerName "centerScanRect:") rect))
(define (nstextfield-center-selection-in-visible-area! self sender)
  (tell #:type _void (coerce-arg self) centerSelectionInVisibleArea: (coerce-arg sender)))
(define (nstextfield-change-case-of-letter self sender)
  (tell #:type _void (coerce-arg self) changeCaseOfLetter: (coerce-arg sender)))
(define (nstextfield-change-mode-with-event self event)
  (tell #:type _void (coerce-arg self) changeModeWithEvent: (coerce-arg event)))
(define (nstextfield-complete self sender)
  (tell #:type _void (coerce-arg self) complete: (coerce-arg sender)))
(define (nstextfield-conclude-drag-operation self sender)
  (tell #:type _void (coerce-arg self) concludeDragOperation: (coerce-arg sender)))
(define (nstextfield-content-type self)
  (wrap-objc-object
   (tell (coerce-arg self) contentType)))
(define (nstextfield-context-menu-key-down self event)
  (tell #:type _void (coerce-arg self) contextMenuKeyDown: (coerce-arg event)))
(define (nstextfield-convert-point-from-view self point view)
  (_msg-17 (coerce-arg self) (sel_registerName "convertPoint:fromView:") point (coerce-arg view)))
(define (nstextfield-convert-point-to-view self point view)
  (_msg-17 (coerce-arg self) (sel_registerName "convertPoint:toView:") point (coerce-arg view)))
(define (nstextfield-convert-point-from-backing self point)
  (_msg-11 (coerce-arg self) (sel_registerName "convertPointFromBacking:") point))
(define (nstextfield-convert-point-from-layer self point)
  (_msg-11 (coerce-arg self) (sel_registerName "convertPointFromLayer:") point))
(define (nstextfield-convert-point-to-backing self point)
  (_msg-11 (coerce-arg self) (sel_registerName "convertPointToBacking:") point))
(define (nstextfield-convert-point-to-layer self point)
  (_msg-11 (coerce-arg self) (sel_registerName "convertPointToLayer:") point))
(define (nstextfield-convert-rect-from-view self rect view)
  (_msg-26 (coerce-arg self) (sel_registerName "convertRect:fromView:") rect (coerce-arg view)))
(define (nstextfield-convert-rect-to-view self rect view)
  (_msg-26 (coerce-arg self) (sel_registerName "convertRect:toView:") rect (coerce-arg view)))
(define (nstextfield-convert-rect-from-backing self rect)
  (_msg-21 (coerce-arg self) (sel_registerName "convertRectFromBacking:") rect))
(define (nstextfield-convert-rect-from-layer self rect)
  (_msg-21 (coerce-arg self) (sel_registerName "convertRectFromLayer:") rect))
(define (nstextfield-convert-rect-to-backing self rect)
  (_msg-21 (coerce-arg self) (sel_registerName "convertRectToBacking:") rect))
(define (nstextfield-convert-rect-to-layer self rect)
  (_msg-21 (coerce-arg self) (sel_registerName "convertRectToLayer:") rect))
(define (nstextfield-convert-size-from-view self size view)
  (_msg-32 (coerce-arg self) (sel_registerName "convertSize:fromView:") size (coerce-arg view)))
(define (nstextfield-convert-size-to-view self size view)
  (_msg-32 (coerce-arg self) (sel_registerName "convertSize:toView:") size (coerce-arg view)))
(define (nstextfield-convert-size-from-backing self size)
  (_msg-30 (coerce-arg self) (sel_registerName "convertSizeFromBacking:") size))
(define (nstextfield-convert-size-from-layer self size)
  (_msg-30 (coerce-arg self) (sel_registerName "convertSizeFromLayer:") size))
(define (nstextfield-convert-size-to-backing self size)
  (_msg-30 (coerce-arg self) (sel_registerName "convertSizeToBacking:") size))
(define (nstextfield-convert-size-to-layer self size)
  (_msg-30 (coerce-arg self) (sel_registerName "convertSizeToLayer:") size))
(define (nstextfield-cursor-update self event)
  (tell #:type _void (coerce-arg self) cursorUpdate: (coerce-arg event)))
(define (nstextfield-delete-backward self sender)
  (tell #:type _void (coerce-arg self) deleteBackward: (coerce-arg sender)))
(define (nstextfield-delete-backward-by-decomposing-previous-character self sender)
  (tell #:type _void (coerce-arg self) deleteBackwardByDecomposingPreviousCharacter: (coerce-arg sender)))
(define (nstextfield-delete-forward self sender)
  (tell #:type _void (coerce-arg self) deleteForward: (coerce-arg sender)))
(define (nstextfield-delete-to-beginning-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfLine: (coerce-arg sender)))
(define (nstextfield-delete-to-beginning-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfParagraph: (coerce-arg sender)))
(define (nstextfield-delete-to-end-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfLine: (coerce-arg sender)))
(define (nstextfield-delete-to-end-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfParagraph: (coerce-arg sender)))
(define (nstextfield-delete-to-mark self sender)
  (tell #:type _void (coerce-arg self) deleteToMark: (coerce-arg sender)))
(define (nstextfield-delete-word-backward self sender)
  (tell #:type _void (coerce-arg self) deleteWordBackward: (coerce-arg sender)))
(define (nstextfield-delete-word-forward self sender)
  (tell #:type _void (coerce-arg self) deleteWordForward: (coerce-arg sender)))
(define (nstextfield-did-add-subview self subview)
  (tell #:type _void (coerce-arg self) didAddSubview: (coerce-arg subview)))
(define (nstextfield-did-close-menu-with-event self menu event)
  (tell #:type _void (coerce-arg self) didCloseMenu: (coerce-arg menu) withEvent: (coerce-arg event)))
(define (nstextfield-display! self)
  (tell #:type _void (coerce-arg self) display))
(define (nstextfield-display-if-needed! self)
  (tell #:type _void (coerce-arg self) displayIfNeeded))
(define (nstextfield-display-if-needed-ignoring-opacity! self)
  (tell #:type _void (coerce-arg self) displayIfNeededIgnoringOpacity))
(define (nstextfield-display-if-needed-in-rect! self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "displayIfNeededInRect:") rect))
(define (nstextfield-display-if-needed-in-rect-ignoring-opacity! self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "displayIfNeededInRectIgnoringOpacity:") rect))
(define (nstextfield-display-rect! self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "displayRect:") rect))
(define (nstextfield-display-rect-ignoring-opacity! self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "displayRectIgnoringOpacity:") rect))
(define (nstextfield-display-rect-ignoring-opacity-in-context! self rect context)
  (_msg-27 (coerce-arg self) (sel_registerName "displayRectIgnoringOpacity:inContext:") rect (coerce-arg context)))
(define (nstextfield-do-command-by-selector self selector)
  (_msg-47 (coerce-arg self) (sel_registerName "doCommandBySelector:") (sel_registerName selector)))
(define (nstextfield-dragging-ended self sender)
  (tell #:type _void (coerce-arg self) draggingEnded: (coerce-arg sender)))
(define (nstextfield-dragging-entered self sender)
  (_msg-37 (coerce-arg self) (sel_registerName "draggingEntered:") (coerce-arg sender)))
(define (nstextfield-dragging-exited self sender)
  (tell #:type _void (coerce-arg self) draggingExited: (coerce-arg sender)))
(define (nstextfield-dragging-updated self sender)
  (_msg-37 (coerce-arg self) (sel_registerName "draggingUpdated:") (coerce-arg sender)))
(define (nstextfield-draw-rect self dirty-rect)
  (_msg-24 (coerce-arg self) (sel_registerName "drawRect:") dirty-rect))
(define (nstextfield-draw-with-expansion-frame-in-view self content-frame view)
  (_msg-27 (coerce-arg self) (sel_registerName "drawWithExpansionFrame:inView:") content-frame (coerce-arg view)))
(define (nstextfield-effective-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) effectiveAppearance)))
(define (nstextfield-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nstextfield-end-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) endGestureWithEvent: (coerce-arg event)))
(define (nstextfield-expansion-frame-with-frame self content-frame)
  (_msg-21 (coerce-arg self) (sel_registerName "expansionFrameWithFrame:") content-frame))
(define (nstextfield-flags-changed self event)
  (tell #:type _void (coerce-arg self) flagsChanged: (coerce-arg event)))
(define (nstextfield-flush-buffered-key-events self)
  (tell #:type _void (coerce-arg self) flushBufferedKeyEvents))
(define (nstextfield-get-rects-being-drawn-count self rects count)
  (_msg-50 (coerce-arg self) (sel_registerName "getRectsBeingDrawn:count:") rects count))
(define (nstextfield-get-rects-exposed-during-live-resize-count self exposed-rects count)
  (_msg-50 (coerce-arg self) (sel_registerName "getRectsExposedDuringLiveResize:count:") exposed-rects count))
(define (nstextfield-help-requested self event-ptr)
  (tell #:type _void (coerce-arg self) helpRequested: (coerce-arg event-ptr)))
(define (nstextfield-hit-test self point)
  (wrap-objc-object
   (_msg-13 (coerce-arg self) (sel_registerName "hitTest:") point)
   ))
(define (nstextfield-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) identifier)))
(define (nstextfield-indent self sender)
  (tell #:type _void (coerce-arg self) indent: (coerce-arg sender)))
(define (nstextfield-insert-backtab! self sender)
  (tell #:type _void (coerce-arg self) insertBacktab: (coerce-arg sender)))
(define (nstextfield-insert-container-break! self sender)
  (tell #:type _void (coerce-arg self) insertContainerBreak: (coerce-arg sender)))
(define (nstextfield-insert-double-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertDoubleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nstextfield-insert-line-break! self sender)
  (tell #:type _void (coerce-arg self) insertLineBreak: (coerce-arg sender)))
(define (nstextfield-insert-newline! self sender)
  (tell #:type _void (coerce-arg self) insertNewline: (coerce-arg sender)))
(define (nstextfield-insert-newline-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertNewlineIgnoringFieldEditor: (coerce-arg sender)))
(define (nstextfield-insert-paragraph-separator! self sender)
  (tell #:type _void (coerce-arg self) insertParagraphSeparator: (coerce-arg sender)))
(define (nstextfield-insert-single-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertSingleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nstextfield-insert-tab! self sender)
  (tell #:type _void (coerce-arg self) insertTab: (coerce-arg sender)))
(define (nstextfield-insert-tab-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertTabIgnoringFieldEditor: (coerce-arg sender)))
(define (nstextfield-insert-text! self insert-string)
  (tell #:type _void (coerce-arg self) insertText: (coerce-arg insert-string)))
(define (nstextfield-interpret-key-events self event-array)
  (tell #:type _void (coerce-arg self) interpretKeyEvents: (coerce-arg event-array)))
(define (nstextfield-is-accessibility-alternate-ui-visible self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityAlternateUIVisible")))
(define (nstextfield-is-accessibility-disclosed self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityDisclosed")))
(define (nstextfield-is-accessibility-edited self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityEdited")))
(define (nstextfield-is-accessibility-element self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityElement")))
(define (nstextfield-is-accessibility-enabled self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityEnabled")))
(define (nstextfield-is-accessibility-expanded self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityExpanded")))
(define (nstextfield-is-accessibility-focused self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityFocused")))
(define (nstextfield-is-accessibility-frontmost self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityFrontmost")))
(define (nstextfield-is-accessibility-hidden self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityHidden")))
(define (nstextfield-is-accessibility-main self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityMain")))
(define (nstextfield-is-accessibility-minimized self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityMinimized")))
(define (nstextfield-is-accessibility-modal self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityModal")))
(define (nstextfield-is-accessibility-ordered-by-row self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityOrderedByRow")))
(define (nstextfield-is-accessibility-protected-content self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityProtectedContent")))
(define (nstextfield-is-accessibility-required self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityRequired")))
(define (nstextfield-is-accessibility-selected self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilitySelected")))
(define (nstextfield-is-accessibility-selector-allowed self selector)
  (_msg-46 (coerce-arg self) (sel_registerName "isAccessibilitySelectorAllowed:") (sel_registerName selector)))
(define (nstextfield-is-bezeled self)
  (_msg-3 (coerce-arg self) (sel_registerName "isBezeled")))
(define (nstextfield-is-bordered self)
  (_msg-3 (coerce-arg self) (sel_registerName "isBordered")))
(define (nstextfield-is-continuous self)
  (_msg-3 (coerce-arg self) (sel_registerName "isContinuous")))
(define (nstextfield-is-descendant-of self view)
  (_msg-36 (coerce-arg self) (sel_registerName "isDescendantOf:") (coerce-arg view)))
(define (nstextfield-is-editable self)
  (_msg-3 (coerce-arg self) (sel_registerName "isEditable")))
(define (nstextfield-is-enabled self)
  (_msg-3 (coerce-arg self) (sel_registerName "isEnabled")))
(define (nstextfield-is-flipped self)
  (_msg-3 (coerce-arg self) (sel_registerName "isFlipped")))
(define (nstextfield-is-hidden self)
  (_msg-3 (coerce-arg self) (sel_registerName "isHidden")))
(define (nstextfield-is-hidden-or-has-hidden-ancestor self)
  (_msg-3 (coerce-arg self) (sel_registerName "isHiddenOrHasHiddenAncestor")))
(define (nstextfield-is-highlighted self)
  (_msg-3 (coerce-arg self) (sel_registerName "isHighlighted")))
(define (nstextfield-is-opaque self)
  (_msg-3 (coerce-arg self) (sel_registerName "isOpaque")))
(define (nstextfield-is-rotated-from-base self)
  (_msg-3 (coerce-arg self) (sel_registerName "isRotatedFromBase")))
(define (nstextfield-is-rotated-or-scaled-from-base self)
  (_msg-3 (coerce-arg self) (sel_registerName "isRotatedOrScaledFromBase")))
(define (nstextfield-is-selectable self)
  (_msg-3 (coerce-arg self) (sel_registerName "isSelectable")))
(define (nstextfield-key-down self event)
  (tell #:type _void (coerce-arg self) keyDown: (coerce-arg event)))
(define (nstextfield-key-up self event)
  (tell #:type _void (coerce-arg self) keyUp: (coerce-arg event)))
(define (nstextfield-layout self)
  (tell #:type _void (coerce-arg self) layout))
(define (nstextfield-layout-subtree-if-needed self)
  (tell #:type _void (coerce-arg self) layoutSubtreeIfNeeded))
(define (nstextfield-lowercase-word self sender)
  (tell #:type _void (coerce-arg self) lowercaseWord: (coerce-arg sender)))
(define (nstextfield-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) magnifyWithEvent: (coerce-arg event)))
(define (nstextfield-make-backing-layer self)
  (wrap-objc-object
   (tell (coerce-arg self) makeBackingLayer)))
(define (nstextfield-make-base-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nstextfield-make-base-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionNatural: (coerce-arg sender)))
(define (nstextfield-make-base-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nstextfield-make-text-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nstextfield-make-text-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionNatural: (coerce-arg sender)))
(define (nstextfield-make-text-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nstextfield-menu-for-event self event)
  (wrap-objc-object
   (tell (coerce-arg self) menuForEvent: (coerce-arg event))))
(define (nstextfield-mouse-in-rect self point rect)
  (_msg-16 (coerce-arg self) (sel_registerName "mouse:inRect:") point rect))
(define (nstextfield-mouse-cancelled self event)
  (tell #:type _void (coerce-arg self) mouseCancelled: (coerce-arg event)))
(define (nstextfield-mouse-down self event)
  (tell #:type _void (coerce-arg self) mouseDown: (coerce-arg event)))
(define (nstextfield-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) mouseDragged: (coerce-arg event)))
(define (nstextfield-mouse-entered self event)
  (tell #:type _void (coerce-arg self) mouseEntered: (coerce-arg event)))
(define (nstextfield-mouse-exited self event)
  (tell #:type _void (coerce-arg self) mouseExited: (coerce-arg event)))
(define (nstextfield-mouse-moved self event)
  (tell #:type _void (coerce-arg self) mouseMoved: (coerce-arg event)))
(define (nstextfield-mouse-up self event)
  (tell #:type _void (coerce-arg self) mouseUp: (coerce-arg event)))
(define (nstextfield-move-backward! self sender)
  (tell #:type _void (coerce-arg self) moveBackward: (coerce-arg sender)))
(define (nstextfield-move-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveBackwardAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-down! self sender)
  (tell #:type _void (coerce-arg self) moveDown: (coerce-arg sender)))
(define (nstextfield-move-down-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveDownAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-forward! self sender)
  (tell #:type _void (coerce-arg self) moveForward: (coerce-arg sender)))
(define (nstextfield-move-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveForwardAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-left! self sender)
  (tell #:type _void (coerce-arg self) moveLeft: (coerce-arg sender)))
(define (nstextfield-move-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveLeftAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-paragraph-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphBackwardAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-paragraph-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphForwardAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-right! self sender)
  (tell #:type _void (coerce-arg self) moveRight: (coerce-arg sender)))
(define (nstextfield-move-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveRightAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-to-beginning-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocument: (coerce-arg sender)))
(define (nstextfield-move-to-beginning-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-to-beginning-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLine: (coerce-arg sender)))
(define (nstextfield-move-to-beginning-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLineAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-to-beginning-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraph: (coerce-arg sender)))
(define (nstextfield-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-to-end-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocument: (coerce-arg sender)))
(define (nstextfield-move-to-end-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-to-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLine: (coerce-arg sender)))
(define (nstextfield-move-to-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-to-end-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraph: (coerce-arg sender)))
(define (nstextfield-move-to-end-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-to-left-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLine: (coerce-arg sender)))
(define (nstextfield-move-to-left-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-to-right-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLine: (coerce-arg sender)))
(define (nstextfield-move-to-right-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-up! self sender)
  (tell #:type _void (coerce-arg self) moveUp: (coerce-arg sender)))
(define (nstextfield-move-up-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveUpAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-word-backward! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackward: (coerce-arg sender)))
(define (nstextfield-move-word-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackwardAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-word-forward! self sender)
  (tell #:type _void (coerce-arg self) moveWordForward: (coerce-arg sender)))
(define (nstextfield-move-word-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordForwardAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-word-left! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeft: (coerce-arg sender)))
(define (nstextfield-move-word-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeftAndModifySelection: (coerce-arg sender)))
(define (nstextfield-move-word-right! self sender)
  (tell #:type _void (coerce-arg self) moveWordRight: (coerce-arg sender)))
(define (nstextfield-move-word-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordRightAndModifySelection: (coerce-arg sender)))
(define (nstextfield-needs-to-draw-rect self rect)
  (_msg-22 (coerce-arg self) (sel_registerName "needsToDrawRect:") rect))
(define (nstextfield-no-responder-for self event-selector)
  (_msg-47 (coerce-arg self) (sel_registerName "noResponderFor:") (sel_registerName event-selector)))
(define (nstextfield-other-mouse-down self event)
  (tell #:type _void (coerce-arg self) otherMouseDown: (coerce-arg event)))
(define (nstextfield-other-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) otherMouseDragged: (coerce-arg event)))
(define (nstextfield-other-mouse-up self event)
  (tell #:type _void (coerce-arg self) otherMouseUp: (coerce-arg event)))
(define (nstextfield-page-down self sender)
  (tell #:type _void (coerce-arg self) pageDown: (coerce-arg sender)))
(define (nstextfield-page-down-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageDownAndModifySelection: (coerce-arg sender)))
(define (nstextfield-page-up self sender)
  (tell #:type _void (coerce-arg self) pageUp: (coerce-arg sender)))
(define (nstextfield-page-up-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageUpAndModifySelection: (coerce-arg sender)))
(define (nstextfield-perform-click! self sender)
  (tell #:type _void (coerce-arg self) performClick: (coerce-arg sender)))
(define (nstextfield-perform-drag-operation! self sender)
  (_msg-36 (coerce-arg self) (sel_registerName "performDragOperation:") (coerce-arg sender)))
(define (nstextfield-perform-key-equivalent! self event)
  (_msg-36 (coerce-arg self) (sel_registerName "performKeyEquivalent:") (coerce-arg event)))
(define (nstextfield-prepare-content-in-rect self rect)
  (_msg-24 (coerce-arg self) (sel_registerName "prepareContentInRect:") rect))
(define (nstextfield-prepare-for-drag-operation self sender)
  (_msg-36 (coerce-arg self) (sel_registerName "prepareForDragOperation:") (coerce-arg sender)))
(define (nstextfield-prepare-for-reuse self)
  (tell #:type _void (coerce-arg self) prepareForReuse))
(define (nstextfield-pressure-change-with-event self event)
  (tell #:type _void (coerce-arg self) pressureChangeWithEvent: (coerce-arg event)))
(define (nstextfield-quick-look-preview-items self sender)
  (tell #:type _void (coerce-arg self) quickLookPreviewItems: (coerce-arg sender)))
(define (nstextfield-quick-look-with-event self event)
  (tell #:type _void (coerce-arg self) quickLookWithEvent: (coerce-arg event)))
(define (nstextfield-rect-for-smart-magnification-at-point-in-rect self location visible-rect)
  (_msg-15 (coerce-arg self) (sel_registerName "rectForSmartMagnificationAtPoint:inRect:") location visible-rect))
(define (nstextfield-remove-all-tool-tips! self)
  (tell #:type _void (coerce-arg self) removeAllToolTips))
(define (nstextfield-remove-from-superview! self)
  (tell #:type _void (coerce-arg self) removeFromSuperview))
(define (nstextfield-remove-from-superview-without-needing-display! self)
  (tell #:type _void (coerce-arg self) removeFromSuperviewWithoutNeedingDisplay))
(define (nstextfield-remove-tool-tip! self tag)
  (_msg-44 (coerce-arg self) (sel_registerName "removeToolTip:") tag))
(define (nstextfield-replace-subview-with! self old-view new-view)
  (tell #:type _void (coerce-arg self) replaceSubview: (coerce-arg old-view) with: (coerce-arg new-view)))
(define (nstextfield-resign-first-responder self)
  (_msg-3 (coerce-arg self) (sel_registerName "resignFirstResponder")))
(define (nstextfield-resize-subviews-with-old-size self old-size)
  (_msg-31 (coerce-arg self) (sel_registerName "resizeSubviewsWithOldSize:") old-size))
(define (nstextfield-resize-with-old-superview-size self old-size)
  (_msg-31 (coerce-arg self) (sel_registerName "resizeWithOldSuperviewSize:") old-size))
(define (nstextfield-restore-user-activity-state self user-activity)
  (tell #:type _void (coerce-arg self) restoreUserActivityState: (coerce-arg user-activity)))
(define (nstextfield-right-mouse-down self event)
  (tell #:type _void (coerce-arg self) rightMouseDown: (coerce-arg event)))
(define (nstextfield-right-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) rightMouseDragged: (coerce-arg event)))
(define (nstextfield-right-mouse-up self event)
  (tell #:type _void (coerce-arg self) rightMouseUp: (coerce-arg event)))
(define (nstextfield-rotate-by-angle self angle)
  (_msg-34 (coerce-arg self) (sel_registerName "rotateByAngle:") angle))
(define (nstextfield-rotate-with-event self event)
  (tell #:type _void (coerce-arg self) rotateWithEvent: (coerce-arg event)))
(define (nstextfield-scale-unit-square-to-size self new-unit-size)
  (_msg-31 (coerce-arg self) (sel_registerName "scaleUnitSquareToSize:") new-unit-size))
(define (nstextfield-scroll-line-down self sender)
  (tell #:type _void (coerce-arg self) scrollLineDown: (coerce-arg sender)))
(define (nstextfield-scroll-line-up self sender)
  (tell #:type _void (coerce-arg self) scrollLineUp: (coerce-arg sender)))
(define (nstextfield-scroll-page-down self sender)
  (tell #:type _void (coerce-arg self) scrollPageDown: (coerce-arg sender)))
(define (nstextfield-scroll-page-up self sender)
  (tell #:type _void (coerce-arg self) scrollPageUp: (coerce-arg sender)))
(define (nstextfield-scroll-point self point)
  (_msg-14 (coerce-arg self) (sel_registerName "scrollPoint:") point))
(define (nstextfield-scroll-rect-to-visible self rect)
  (_msg-22 (coerce-arg self) (sel_registerName "scrollRectToVisible:") rect))
(define (nstextfield-scroll-to-beginning-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToBeginningOfDocument: (coerce-arg sender)))
(define (nstextfield-scroll-to-end-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToEndOfDocument: (coerce-arg sender)))
(define (nstextfield-scroll-wheel self event)
  (tell #:type _void (coerce-arg self) scrollWheel: (coerce-arg event)))
(define (nstextfield-select-all self sender)
  (tell #:type _void (coerce-arg self) selectAll: (coerce-arg sender)))
(define (nstextfield-select-line self sender)
  (tell #:type _void (coerce-arg self) selectLine: (coerce-arg sender)))
(define (nstextfield-select-paragraph self sender)
  (tell #:type _void (coerce-arg self) selectParagraph: (coerce-arg sender)))
(define (nstextfield-select-text self sender)
  (tell #:type _void (coerce-arg self) selectText: (coerce-arg sender)))
(define (nstextfield-select-to-mark self sender)
  (tell #:type _void (coerce-arg self) selectToMark: (coerce-arg sender)))
(define (nstextfield-select-word self sender)
  (tell #:type _void (coerce-arg self) selectWord: (coerce-arg sender)))
(define (nstextfield-send-action-to self action target)
  (_msg-48 (coerce-arg self) (sel_registerName "sendAction:to:") (sel_registerName action) (coerce-arg target)))
(define (nstextfield-send-action-on self mask)
  (_msg-51 (coerce-arg self) (sel_registerName "sendActionOn:") mask))
(define (nstextfield-set-accessibility-activation-point! self accessibility-activation-point)
  (_msg-14 (coerce-arg self) (sel_registerName "setAccessibilityActivationPoint:") accessibility-activation-point))
(define (nstextfield-set-accessibility-allowed-values! self accessibility-allowed-values)
  (tell #:type _void (coerce-arg self) setAccessibilityAllowedValues: (coerce-arg accessibility-allowed-values)))
(define (nstextfield-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityAlternateUIVisible:") accessibility-alternate-ui-visible))
(define (nstextfield-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityApplicationFocusedUIElement: (coerce-arg accessibility-application-focused-ui-element)))
(define (nstextfield-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityAttributedUserInputLabels: (coerce-arg accessibility-attributed-user-input-labels)))
(define (nstextfield-set-accessibility-cancel-button! self accessibility-cancel-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCancelButton: (coerce-arg accessibility-cancel-button)))
(define (nstextfield-set-accessibility-children! self accessibility-children)
  (tell #:type _void (coerce-arg self) setAccessibilityChildren: (coerce-arg accessibility-children)))
(define (nstextfield-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (tell #:type _void (coerce-arg self) setAccessibilityChildrenInNavigationOrder: (coerce-arg accessibility-children-in-navigation-order)))
(define (nstextfield-set-accessibility-clear-button! self accessibility-clear-button)
  (tell #:type _void (coerce-arg self) setAccessibilityClearButton: (coerce-arg accessibility-clear-button)))
(define (nstextfield-set-accessibility-close-button! self accessibility-close-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCloseButton: (coerce-arg accessibility-close-button)))
(define (nstextfield-set-accessibility-column-count! self accessibility-column-count)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityColumnCount:") accessibility-column-count))
(define (nstextfield-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnHeaderUIElements: (coerce-arg accessibility-column-header-ui-elements)))
(define (nstextfield-set-accessibility-column-index-range! self accessibility-column-index-range)
  (_msg-20 (coerce-arg self) (sel_registerName "setAccessibilityColumnIndexRange:") accessibility-column-index-range))
(define (nstextfield-set-accessibility-column-titles! self accessibility-column-titles)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnTitles: (coerce-arg accessibility-column-titles)))
(define (nstextfield-set-accessibility-columns! self accessibility-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityColumns: (coerce-arg accessibility-columns)))
(define (nstextfield-set-accessibility-contents! self accessibility-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityContents: (coerce-arg accessibility-contents)))
(define (nstextfield-set-accessibility-critical-value! self accessibility-critical-value)
  (tell #:type _void (coerce-arg self) setAccessibilityCriticalValue: (coerce-arg accessibility-critical-value)))
(define (nstextfield-set-accessibility-custom-actions! self accessibility-custom-actions)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomActions: (coerce-arg accessibility-custom-actions)))
(define (nstextfield-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomRotors: (coerce-arg accessibility-custom-rotors)))
(define (nstextfield-set-accessibility-decrement-button! self accessibility-decrement-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDecrementButton: (coerce-arg accessibility-decrement-button)))
(define (nstextfield-set-accessibility-default-button! self accessibility-default-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDefaultButton: (coerce-arg accessibility-default-button)))
(define (nstextfield-set-accessibility-disclosed! self accessibility-disclosed)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityDisclosed:") accessibility-disclosed))
(define (nstextfield-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedByRow: (coerce-arg accessibility-disclosed-by-row)))
(define (nstextfield-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedRows: (coerce-arg accessibility-disclosed-rows)))
(define (nstextfield-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityDisclosureLevel:") accessibility-disclosure-level))
(define (nstextfield-set-accessibility-document! self accessibility-document)
  (tell #:type _void (coerce-arg self) setAccessibilityDocument: (coerce-arg accessibility-document)))
(define (nstextfield-set-accessibility-edited! self accessibility-edited)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityEdited:") accessibility-edited))
(define (nstextfield-set-accessibility-element! self accessibility-element)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityElement:") accessibility-element))
(define (nstextfield-set-accessibility-enabled! self accessibility-enabled)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityEnabled:") accessibility-enabled))
(define (nstextfield-set-accessibility-expanded! self accessibility-expanded)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityExpanded:") accessibility-expanded))
(define (nstextfield-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityExtrasMenuBar: (coerce-arg accessibility-extras-menu-bar)))
(define (nstextfield-set-accessibility-filename! self accessibility-filename)
  (tell #:type _void (coerce-arg self) setAccessibilityFilename: (coerce-arg accessibility-filename)))
(define (nstextfield-set-accessibility-focused! self accessibility-focused)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityFocused:") accessibility-focused))
(define (nstextfield-set-accessibility-focused-window! self accessibility-focused-window)
  (tell #:type _void (coerce-arg self) setAccessibilityFocusedWindow: (coerce-arg accessibility-focused-window)))
(define (nstextfield-set-accessibility-frame! self accessibility-frame)
  (_msg-24 (coerce-arg self) (sel_registerName "setAccessibilityFrame:") accessibility-frame))
(define (nstextfield-set-accessibility-frontmost! self accessibility-frontmost)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityFrontmost:") accessibility-frontmost))
(define (nstextfield-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (tell #:type _void (coerce-arg self) setAccessibilityFullScreenButton: (coerce-arg accessibility-full-screen-button)))
(define (nstextfield-set-accessibility-grow-area! self accessibility-grow-area)
  (tell #:type _void (coerce-arg self) setAccessibilityGrowArea: (coerce-arg accessibility-grow-area)))
(define (nstextfield-set-accessibility-handles! self accessibility-handles)
  (tell #:type _void (coerce-arg self) setAccessibilityHandles: (coerce-arg accessibility-handles)))
(define (nstextfield-set-accessibility-header! self accessibility-header)
  (tell #:type _void (coerce-arg self) setAccessibilityHeader: (coerce-arg accessibility-header)))
(define (nstextfield-set-accessibility-help! self accessibility-help)
  (tell #:type _void (coerce-arg self) setAccessibilityHelp: (coerce-arg accessibility-help)))
(define (nstextfield-set-accessibility-hidden! self accessibility-hidden)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityHidden:") accessibility-hidden))
(define (nstextfield-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalScrollBar: (coerce-arg accessibility-horizontal-scroll-bar)))
(define (nstextfield-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalUnitDescription: (coerce-arg accessibility-horizontal-unit-description)))
(define (nstextfield-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityHorizontalUnits:") accessibility-horizontal-units))
(define (nstextfield-set-accessibility-identifier! self accessibility-identifier)
  (tell #:type _void (coerce-arg self) setAccessibilityIdentifier: (coerce-arg accessibility-identifier)))
(define (nstextfield-set-accessibility-increment-button! self accessibility-increment-button)
  (tell #:type _void (coerce-arg self) setAccessibilityIncrementButton: (coerce-arg accessibility-increment-button)))
(define (nstextfield-set-accessibility-index! self accessibility-index)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityIndex:") accessibility-index))
(define (nstextfield-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityInsertionPointLineNumber:") accessibility-insertion-point-line-number))
(define (nstextfield-set-accessibility-label! self accessibility-label)
  (tell #:type _void (coerce-arg self) setAccessibilityLabel: (coerce-arg accessibility-label)))
(define (nstextfield-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLabelUIElements: (coerce-arg accessibility-label-ui-elements)))
(define (nstextfield-set-accessibility-label-value! self accessibility-label-value)
  (_msg-35 (coerce-arg self) (sel_registerName "setAccessibilityLabelValue:") accessibility-label-value))
(define (nstextfield-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLinkedUIElements: (coerce-arg accessibility-linked-ui-elements)))
(define (nstextfield-set-accessibility-main! self accessibility-main)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityMain:") accessibility-main))
(define (nstextfield-set-accessibility-main-window! self accessibility-main-window)
  (tell #:type _void (coerce-arg self) setAccessibilityMainWindow: (coerce-arg accessibility-main-window)))
(define (nstextfield-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerGroupUIElement: (coerce-arg accessibility-marker-group-ui-element)))
(define (nstextfield-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerTypeDescription: (coerce-arg accessibility-marker-type-description)))
(define (nstextfield-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerUIElements: (coerce-arg accessibility-marker-ui-elements)))
(define (nstextfield-set-accessibility-marker-values! self accessibility-marker-values)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerValues: (coerce-arg accessibility-marker-values)))
(define (nstextfield-set-accessibility-max-value! self accessibility-max-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMaxValue: (coerce-arg accessibility-max-value)))
(define (nstextfield-set-accessibility-menu-bar! self accessibility-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityMenuBar: (coerce-arg accessibility-menu-bar)))
(define (nstextfield-set-accessibility-min-value! self accessibility-min-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMinValue: (coerce-arg accessibility-min-value)))
(define (nstextfield-set-accessibility-minimize-button! self accessibility-minimize-button)
  (tell #:type _void (coerce-arg self) setAccessibilityMinimizeButton: (coerce-arg accessibility-minimize-button)))
(define (nstextfield-set-accessibility-minimized! self accessibility-minimized)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityMinimized:") accessibility-minimized))
(define (nstextfield-set-accessibility-modal! self accessibility-modal)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityModal:") accessibility-modal))
(define (nstextfield-set-accessibility-next-contents! self accessibility-next-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityNextContents: (coerce-arg accessibility-next-contents)))
(define (nstextfield-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityNumberOfCharacters:") accessibility-number-of-characters))
(define (nstextfield-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityOrderedByRow:") accessibility-ordered-by-row))
(define (nstextfield-set-accessibility-orientation! self accessibility-orientation)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityOrientation:") accessibility-orientation))
(define (nstextfield-set-accessibility-overflow-button! self accessibility-overflow-button)
  (tell #:type _void (coerce-arg self) setAccessibilityOverflowButton: (coerce-arg accessibility-overflow-button)))
(define (nstextfield-set-accessibility-parent! self accessibility-parent)
  (tell #:type _void (coerce-arg self) setAccessibilityParent: (coerce-arg accessibility-parent)))
(define (nstextfield-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (tell #:type _void (coerce-arg self) setAccessibilityPlaceholderValue: (coerce-arg accessibility-placeholder-value)))
(define (nstextfield-set-accessibility-previous-contents! self accessibility-previous-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityPreviousContents: (coerce-arg accessibility-previous-contents)))
(define (nstextfield-set-accessibility-protected-content! self accessibility-protected-content)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityProtectedContent:") accessibility-protected-content))
(define (nstextfield-set-accessibility-proxy! self accessibility-proxy)
  (tell #:type _void (coerce-arg self) setAccessibilityProxy: (coerce-arg accessibility-proxy)))
(define (nstextfield-set-accessibility-required! self accessibility-required)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilityRequired:") accessibility-required))
(define (nstextfield-set-accessibility-role! self accessibility-role)
  (tell #:type _void (coerce-arg self) setAccessibilityRole: (coerce-arg accessibility-role)))
(define (nstextfield-set-accessibility-role-description! self accessibility-role-description)
  (tell #:type _void (coerce-arg self) setAccessibilityRoleDescription: (coerce-arg accessibility-role-description)))
(define (nstextfield-set-accessibility-row-count! self accessibility-row-count)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityRowCount:") accessibility-row-count))
(define (nstextfield-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityRowHeaderUIElements: (coerce-arg accessibility-row-header-ui-elements)))
(define (nstextfield-set-accessibility-row-index-range! self accessibility-row-index-range)
  (_msg-20 (coerce-arg self) (sel_registerName "setAccessibilityRowIndexRange:") accessibility-row-index-range))
(define (nstextfield-set-accessibility-rows! self accessibility-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityRows: (coerce-arg accessibility-rows)))
(define (nstextfield-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityRulerMarkerType:") accessibility-ruler-marker-type))
(define (nstextfield-set-accessibility-search-button! self accessibility-search-button)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchButton: (coerce-arg accessibility-search-button)))
(define (nstextfield-set-accessibility-search-menu! self accessibility-search-menu)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchMenu: (coerce-arg accessibility-search-menu)))
(define (nstextfield-set-accessibility-selected! self accessibility-selected)
  (_msg-33 (coerce-arg self) (sel_registerName "setAccessibilitySelected:") accessibility-selected))
(define (nstextfield-set-accessibility-selected-cells! self accessibility-selected-cells)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedCells: (coerce-arg accessibility-selected-cells)))
(define (nstextfield-set-accessibility-selected-children! self accessibility-selected-children)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedChildren: (coerce-arg accessibility-selected-children)))
(define (nstextfield-set-accessibility-selected-columns! self accessibility-selected-columns)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedColumns: (coerce-arg accessibility-selected-columns)))
(define (nstextfield-set-accessibility-selected-rows! self accessibility-selected-rows)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedRows: (coerce-arg accessibility-selected-rows)))
(define (nstextfield-set-accessibility-selected-text! self accessibility-selected-text)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedText: (coerce-arg accessibility-selected-text)))
(define (nstextfield-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (_msg-20 (coerce-arg self) (sel_registerName "setAccessibilitySelectedTextRange:") accessibility-selected-text-range))
(define (nstextfield-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedTextRanges: (coerce-arg accessibility-selected-text-ranges)))
(define (nstextfield-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityServesAsTitleForUIElements: (coerce-arg accessibility-serves-as-title-for-ui-elements)))
(define (nstextfield-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (_msg-20 (coerce-arg self) (sel_registerName "setAccessibilitySharedCharacterRange:") accessibility-shared-character-range))
(define (nstextfield-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedFocusElements: (coerce-arg accessibility-shared-focus-elements)))
(define (nstextfield-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedTextUIElements: (coerce-arg accessibility-shared-text-ui-elements)))
(define (nstextfield-set-accessibility-shown-menu! self accessibility-shown-menu)
  (tell #:type _void (coerce-arg self) setAccessibilityShownMenu: (coerce-arg accessibility-shown-menu)))
(define (nstextfield-set-accessibility-sort-direction! self accessibility-sort-direction)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilitySortDirection:") accessibility-sort-direction))
(define (nstextfield-set-accessibility-splitters! self accessibility-splitters)
  (tell #:type _void (coerce-arg self) setAccessibilitySplitters: (coerce-arg accessibility-splitters)))
(define (nstextfield-set-accessibility-subrole! self accessibility-subrole)
  (tell #:type _void (coerce-arg self) setAccessibilitySubrole: (coerce-arg accessibility-subrole)))
(define (nstextfield-set-accessibility-tabs! self accessibility-tabs)
  (tell #:type _void (coerce-arg self) setAccessibilityTabs: (coerce-arg accessibility-tabs)))
(define (nstextfield-set-accessibility-title! self accessibility-title)
  (tell #:type _void (coerce-arg self) setAccessibilityTitle: (coerce-arg accessibility-title)))
(define (nstextfield-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTitleUIElement: (coerce-arg accessibility-title-ui-element)))
(define (nstextfield-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (tell #:type _void (coerce-arg self) setAccessibilityToolbarButton: (coerce-arg accessibility-toolbar-button)))
(define (nstextfield-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTopLevelUIElement: (coerce-arg accessibility-top-level-ui-element)))
(define (nstextfield-set-accessibility-url! self accessibility-url)
  (tell #:type _void (coerce-arg self) setAccessibilityURL: (coerce-arg accessibility-url)))
(define (nstextfield-set-accessibility-unit-description! self accessibility-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityUnitDescription: (coerce-arg accessibility-unit-description)))
(define (nstextfield-set-accessibility-units! self accessibility-units)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityUnits:") accessibility-units))
(define (nstextfield-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityUserInputLabels: (coerce-arg accessibility-user-input-labels)))
(define (nstextfield-set-accessibility-value! self accessibility-value)
  (tell #:type _void (coerce-arg self) setAccessibilityValue: (coerce-arg accessibility-value)))
(define (nstextfield-set-accessibility-value-description! self accessibility-value-description)
  (tell #:type _void (coerce-arg self) setAccessibilityValueDescription: (coerce-arg accessibility-value-description)))
(define (nstextfield-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalScrollBar: (coerce-arg accessibility-vertical-scroll-bar)))
(define (nstextfield-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalUnitDescription: (coerce-arg accessibility-vertical-unit-description)))
(define (nstextfield-set-accessibility-vertical-units! self accessibility-vertical-units)
  (_msg-44 (coerce-arg self) (sel_registerName "setAccessibilityVerticalUnits:") accessibility-vertical-units))
(define (nstextfield-set-accessibility-visible-cells! self accessibility-visible-cells)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleCells: (coerce-arg accessibility-visible-cells)))
(define (nstextfield-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (_msg-20 (coerce-arg self) (sel_registerName "setAccessibilityVisibleCharacterRange:") accessibility-visible-character-range))
(define (nstextfield-set-accessibility-visible-children! self accessibility-visible-children)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleChildren: (coerce-arg accessibility-visible-children)))
(define (nstextfield-set-accessibility-visible-columns! self accessibility-visible-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleColumns: (coerce-arg accessibility-visible-columns)))
(define (nstextfield-set-accessibility-visible-rows! self accessibility-visible-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleRows: (coerce-arg accessibility-visible-rows)))
(define (nstextfield-set-accessibility-warning-value! self accessibility-warning-value)
  (tell #:type _void (coerce-arg self) setAccessibilityWarningValue: (coerce-arg accessibility-warning-value)))
(define (nstextfield-set-accessibility-window! self accessibility-window)
  (tell #:type _void (coerce-arg self) setAccessibilityWindow: (coerce-arg accessibility-window)))
(define (nstextfield-set-accessibility-windows! self accessibility-windows)
  (tell #:type _void (coerce-arg self) setAccessibilityWindows: (coerce-arg accessibility-windows)))
(define (nstextfield-set-accessibility-zoom-button! self accessibility-zoom-button)
  (tell #:type _void (coerce-arg self) setAccessibilityZoomButton: (coerce-arg accessibility-zoom-button)))
(define (nstextfield-set-animations! self animations)
  (tell #:type _void (coerce-arg self) setAnimations: (coerce-arg animations)))
(define (nstextfield-set-appearance! self appearance)
  (tell #:type _void (coerce-arg self) setAppearance: (coerce-arg appearance)))
(define (nstextfield-set-bounds-origin! self new-origin)
  (_msg-14 (coerce-arg self) (sel_registerName "setBoundsOrigin:") new-origin))
(define (nstextfield-set-bounds-size! self new-size)
  (_msg-31 (coerce-arg self) (sel_registerName "setBoundsSize:") new-size))
(define (nstextfield-set-content-type! self content-type)
  (tell #:type _void (coerce-arg self) setContentType: (coerce-arg content-type)))
(define (nstextfield-set-frame-origin! self new-origin)
  (_msg-14 (coerce-arg self) (sel_registerName "setFrameOrigin:") new-origin))
(define (nstextfield-set-frame-size! self new-size)
  (_msg-31 (coerce-arg self) (sel_registerName "setFrameSize:") new-size))
(define (nstextfield-set-identifier! self identifier)
  (tell #:type _void (coerce-arg self) setIdentifier: (coerce-arg identifier)))
(define (nstextfield-set-mark! self sender)
  (tell #:type _void (coerce-arg self) setMark: (coerce-arg sender)))
(define (nstextfield-set-needs-display-in-rect! self invalid-rect)
  (_msg-24 (coerce-arg self) (sel_registerName "setNeedsDisplayInRect:") invalid-rect))
(define (nstextfield-should-be-treated-as-ink-event self event)
  (_msg-36 (coerce-arg self) (sel_registerName "shouldBeTreatedAsInkEvent:") (coerce-arg event)))
(define (nstextfield-should-delay-window-ordering-for-event self event)
  (_msg-36 (coerce-arg self) (sel_registerName "shouldDelayWindowOrderingForEvent:") (coerce-arg event)))
(define (nstextfield-show-context-help self sender)
  (tell #:type _void (coerce-arg self) showContextHelp: (coerce-arg sender)))
(define (nstextfield-show-context-menu-for-selection self sender)
  (tell #:type _void (coerce-arg self) showContextMenuForSelection: (coerce-arg sender)))
(define (nstextfield-size-that-fits self size)
  (_msg-30 (coerce-arg self) (sel_registerName "sizeThatFits:") size))
(define (nstextfield-size-to-fit self)
  (tell #:type _void (coerce-arg self) sizeToFit))
(define (nstextfield-smart-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) smartMagnifyWithEvent: (coerce-arg event)))
(define (nstextfield-sort-subviews-using-function-context self compare context)
  (_msg-50 (coerce-arg self) (sel_registerName "sortSubviewsUsingFunction:context:") compare context))
(define (nstextfield-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (_msg-49 (coerce-arg self) (sel_registerName "supplementalTargetForAction:sender:") (sel_registerName action) (coerce-arg sender))
   ))
(define (nstextfield-swap-with-mark self sender)
  (tell #:type _void (coerce-arg self) swapWithMark: (coerce-arg sender)))
(define (nstextfield-swipe-with-event self event)
  (tell #:type _void (coerce-arg self) swipeWithEvent: (coerce-arg event)))
(define (nstextfield-tablet-point self event)
  (tell #:type _void (coerce-arg self) tabletPoint: (coerce-arg event)))
(define (nstextfield-tablet-proximity self event)
  (tell #:type _void (coerce-arg self) tabletProximity: (coerce-arg event)))
(define (nstextfield-take-double-value-from self sender)
  (tell #:type _void (coerce-arg self) takeDoubleValueFrom: (coerce-arg sender)))
(define (nstextfield-take-float-value-from self sender)
  (tell #:type _void (coerce-arg self) takeFloatValueFrom: (coerce-arg sender)))
(define (nstextfield-take-int-value-from self sender)
  (tell #:type _void (coerce-arg self) takeIntValueFrom: (coerce-arg sender)))
(define (nstextfield-take-integer-value-from self sender)
  (tell #:type _void (coerce-arg self) takeIntegerValueFrom: (coerce-arg sender)))
(define (nstextfield-take-object-value-from self sender)
  (tell #:type _void (coerce-arg self) takeObjectValueFrom: (coerce-arg sender)))
(define (nstextfield-take-string-value-from self sender)
  (tell #:type _void (coerce-arg self) takeStringValueFrom: (coerce-arg sender)))
(define (nstextfield-text-did-begin-editing self notification)
  (tell #:type _void (coerce-arg self) textDidBeginEditing: (coerce-arg notification)))
(define (nstextfield-text-did-change self notification)
  (tell #:type _void (coerce-arg self) textDidChange: (coerce-arg notification)))
(define (nstextfield-text-did-end-editing self notification)
  (tell #:type _void (coerce-arg self) textDidEndEditing: (coerce-arg notification)))
(define (nstextfield-text-should-begin-editing self text-object)
  (_msg-36 (coerce-arg self) (sel_registerName "textShouldBeginEditing:") (coerce-arg text-object)))
(define (nstextfield-text-should-end-editing self text-object)
  (_msg-36 (coerce-arg self) (sel_registerName "textShouldEndEditing:") (coerce-arg text-object)))
(define (nstextfield-touches-began-with-event self event)
  (tell #:type _void (coerce-arg self) touchesBeganWithEvent: (coerce-arg event)))
(define (nstextfield-touches-cancelled-with-event self event)
  (tell #:type _void (coerce-arg self) touchesCancelledWithEvent: (coerce-arg event)))
(define (nstextfield-touches-ended-with-event self event)
  (tell #:type _void (coerce-arg self) touchesEndedWithEvent: (coerce-arg event)))
(define (nstextfield-touches-moved-with-event self event)
  (tell #:type _void (coerce-arg self) touchesMovedWithEvent: (coerce-arg event)))
(define (nstextfield-translate-origin-to-point self translation)
  (_msg-14 (coerce-arg self) (sel_registerName "translateOriginToPoint:") translation))
(define (nstextfield-translate-rects-needing-display-in-rect-by self clip-rect delta)
  (_msg-25 (coerce-arg self) (sel_registerName "translateRectsNeedingDisplayInRect:by:") clip-rect delta))
(define (nstextfield-transpose self sender)
  (tell #:type _void (coerce-arg self) transpose: (coerce-arg sender)))
(define (nstextfield-transpose-words self sender)
  (tell #:type _void (coerce-arg self) transposeWords: (coerce-arg sender)))
(define (nstextfield-try-to-perform-with self action object)
  (_msg-48 (coerce-arg self) (sel_registerName "tryToPerform:with:") (sel_registerName action) (coerce-arg object)))
(define (nstextfield-update-dragging-items-for-drag self sender)
  (tell #:type _void (coerce-arg self) updateDraggingItemsForDrag: (coerce-arg sender)))
(define (nstextfield-update-layer self)
  (tell #:type _void (coerce-arg self) updateLayer))
(define (nstextfield-uppercase-word self sender)
  (tell #:type _void (coerce-arg self) uppercaseWord: (coerce-arg sender)))
(define (nstextfield-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (tell (coerce-arg self) validRequestorForSendType: (coerce-arg send-type) returnType: (coerce-arg return-type))))
(define (nstextfield-validate-user-interface-item self item)
  (_msg-36 (coerce-arg self) (sel_registerName "validateUserInterfaceItem:") (coerce-arg item)))
(define (nstextfield-view-did-change-backing-properties self)
  (tell #:type _void (coerce-arg self) viewDidChangeBackingProperties))
(define (nstextfield-view-did-change-effective-appearance self)
  (tell #:type _void (coerce-arg self) viewDidChangeEffectiveAppearance))
(define (nstextfield-view-did-end-live-resize self)
  (tell #:type _void (coerce-arg self) viewDidEndLiveResize))
(define (nstextfield-view-did-hide self)
  (tell #:type _void (coerce-arg self) viewDidHide))
(define (nstextfield-view-did-move-to-superview self)
  (tell #:type _void (coerce-arg self) viewDidMoveToSuperview))
(define (nstextfield-view-did-move-to-window self)
  (tell #:type _void (coerce-arg self) viewDidMoveToWindow))
(define (nstextfield-view-did-unhide self)
  (tell #:type _void (coerce-arg self) viewDidUnhide))
(define (nstextfield-view-will-draw self)
  (tell #:type _void (coerce-arg self) viewWillDraw))
(define (nstextfield-view-will-move-to-superview self new-superview)
  (tell #:type _void (coerce-arg self) viewWillMoveToSuperview: (coerce-arg new-superview)))
(define (nstextfield-view-will-move-to-window self new-window)
  (tell #:type _void (coerce-arg self) viewWillMoveToWindow: (coerce-arg new-window)))
(define (nstextfield-view-will-start-live-resize self)
  (tell #:type _void (coerce-arg self) viewWillStartLiveResize))
(define (nstextfield-view-with-tag self tag)
  (wrap-objc-object
   (_msg-42 (coerce-arg self) (sel_registerName "viewWithTag:") tag)
   ))
(define (nstextfield-wants-forwarded-scroll-events-for-axis self axis)
  (_msg-41 (coerce-arg self) (sel_registerName "wantsForwardedScrollEventsForAxis:") axis))
(define (nstextfield-wants-periodic-dragging-updates self)
  (_msg-3 (coerce-arg self) (sel_registerName "wantsPeriodicDraggingUpdates")))
(define (nstextfield-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (_msg-41 (coerce-arg self) (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:") axis))
(define (nstextfield-will-open-menu-with-event self menu event)
  (tell #:type _void (coerce-arg self) willOpenMenu: (coerce-arg menu) withEvent: (coerce-arg event)))
(define (nstextfield-will-remove-subview self subview)
  (tell #:type _void (coerce-arg self) willRemoveSubview: (coerce-arg subview)))
(define (nstextfield-yank self sender)
  (tell #:type _void (coerce-arg self) yank: (coerce-arg sender)))

;; --- Class methods ---
(define (nstextfield-default-animation-for-key key)
  (wrap-objc-object
   (tell NSTextField defaultAnimationForKey: (coerce-arg key))))
(define (nstextfield-is-compatible-with-responsive-scrolling)
  (_msg-3 NSTextField (sel_registerName "isCompatibleWithResponsiveScrolling")))
