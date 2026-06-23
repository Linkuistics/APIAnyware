#lang racket/base
;; Generated binding for NSTextView (AppKit)
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
(define (nslayoutmanager? v) (objc-instance-of? v "NSLayoutManager"))
(define (nslayoutxaxisanchor? v) (objc-instance-of? v "NSLayoutXAxisAnchor"))
(define (nslayoutyaxisanchor? v) (objc-instance-of? v "NSLayoutYAxisAnchor"))
(define (nsmenu? v) (objc-instance-of? v "NSMenu"))
(define (nsmenuitem? v) (objc-instance-of? v "NSMenuItem"))
(define (nsparagraphstyle? v) (objc-instance-of? v "NSParagraphStyle"))
(define (nspressureconfiguration? v) (objc-instance-of? v "NSPressureConfiguration"))
(define (nsresponder? v) (objc-instance-of? v "NSResponder"))
(define (nsscrollview? v) (objc-instance-of? v "NSScrollView"))
(define (nsshadow? v) (objc-instance-of? v "NSShadow"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (nstextcontainer? v) (objc-instance-of? v "NSTextContainer"))
(define (nstextcontentstorage? v) (objc-instance-of? v "NSTextContentStorage"))
(define (nstextinputcontext? v) (objc-instance-of? v "NSTextInputContext"))
(define (nstextlayoutmanager? v) (objc-instance-of? v "NSTextLayoutManager"))
(define (nstextstorage? v) (objc-instance-of? v "NSTextStorage"))
(define (nstextview? v) (objc-instance-of? v "NSTextView"))
(define (nstouchbar? v) (objc-instance-of? v "NSTouchBar"))
(define (nsurl? v) (objc-instance-of? v "NSURL"))
(define (nsundomanager? v) (objc-instance-of? v "NSUndoManager"))
(define (nsuseractivity? v) (objc-instance-of? v "NSUserActivity"))
(define (nsview? v) (objc-instance-of? v "NSView"))
(define (nswindow? v) (objc-instance-of? v "NSWindow"))
(define (nswritingtoolscoordinator? v) (objc-instance-of? v "NSWritingToolsCoordinator"))
(provide NSTextView)
(provide/contract
  [make-nstextview-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nstextview-init-with-frame (c-> any/c any/c)]
  [make-nstextview-init-with-frame-text-container (c-> any/c (or/c string? objc-object? #f) any/c)]
  [nstextview-acceptable-drag-types (c-> nstextview? any/c)]
  [nstextview-accepts-first-responder (c-> nstextview? boolean?)]
  [nstextview-accepts-glyph-info (c-> nstextview? boolean?)]
  [nstextview-set-accepts-glyph-info! (c-> nstextview? boolean? void?)]
  [nstextview-accepts-touch-events (c-> nstextview? boolean?)]
  [nstextview-set-accepts-touch-events! (c-> nstextview? boolean? void?)]
  [nstextview-additional-safe-area-insets (c-> nstextview? any/c)]
  [nstextview-set-additional-safe-area-insets! (c-> nstextview? any/c void?)]
  [nstextview-alignment (c-> nstextview? exact-integer?)]
  [nstextview-set-alignment! (c-> nstextview? exact-integer? void?)]
  [nstextview-alignment-rect-insets (c-> nstextview? any/c)]
  [nstextview-allowed-input-source-locales (c-> nstextview? any/c)]
  [nstextview-set-allowed-input-source-locales! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-allowed-touch-types (c-> nstextview? exact-nonnegative-integer?)]
  [nstextview-set-allowed-touch-types! (c-> nstextview? exact-nonnegative-integer? void?)]
  [nstextview-allowed-writing-tools-result-options (c-> nstextview? exact-nonnegative-integer?)]
  [nstextview-set-allowed-writing-tools-result-options! (c-> nstextview? exact-nonnegative-integer? void?)]
  [nstextview-allows-character-picker-touch-bar-item (c-> nstextview? boolean?)]
  [nstextview-set-allows-character-picker-touch-bar-item! (c-> nstextview? boolean? void?)]
  [nstextview-allows-document-background-color-change (c-> nstextview? boolean?)]
  [nstextview-set-allows-document-background-color-change! (c-> nstextview? boolean? void?)]
  [nstextview-allows-image-editing (c-> nstextview? boolean?)]
  [nstextview-set-allows-image-editing! (c-> nstextview? boolean? void?)]
  [nstextview-allows-undo (c-> nstextview? boolean?)]
  [nstextview-set-allows-undo! (c-> nstextview? boolean? void?)]
  [nstextview-allows-vibrancy (c-> nstextview? boolean?)]
  [nstextview-alpha-value (c-> nstextview? real?)]
  [nstextview-set-alpha-value! (c-> nstextview? real? void?)]
  [nstextview-automatic-dash-substitution-enabled (c-> nstextview? boolean?)]
  [nstextview-set-automatic-dash-substitution-enabled! (c-> nstextview? boolean? void?)]
  [nstextview-automatic-data-detection-enabled (c-> nstextview? boolean?)]
  [nstextview-set-automatic-data-detection-enabled! (c-> nstextview? boolean? void?)]
  [nstextview-automatic-link-detection-enabled (c-> nstextview? boolean?)]
  [nstextview-set-automatic-link-detection-enabled! (c-> nstextview? boolean? void?)]
  [nstextview-automatic-quote-substitution-enabled (c-> nstextview? boolean?)]
  [nstextview-set-automatic-quote-substitution-enabled! (c-> nstextview? boolean? void?)]
  [nstextview-automatic-spelling-correction-enabled (c-> nstextview? boolean?)]
  [nstextview-set-automatic-spelling-correction-enabled! (c-> nstextview? boolean? void?)]
  [nstextview-automatic-text-completion-enabled (c-> nstextview? boolean?)]
  [nstextview-set-automatic-text-completion-enabled! (c-> nstextview? boolean? void?)]
  [nstextview-automatic-text-replacement-enabled (c-> nstextview? boolean?)]
  [nstextview-set-automatic-text-replacement-enabled! (c-> nstextview? boolean? void?)]
  [nstextview-autoresizes-subviews (c-> nstextview? boolean?)]
  [nstextview-set-autoresizes-subviews! (c-> nstextview? boolean? void?)]
  [nstextview-autoresizing-mask (c-> nstextview? exact-nonnegative-integer?)]
  [nstextview-set-autoresizing-mask! (c-> nstextview? exact-nonnegative-integer? void?)]
  [nstextview-background-color (c-> nstextview? (or/c nscolor? objc-nil?))]
  [nstextview-set-background-color! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-background-filters (c-> nstextview? any/c)]
  [nstextview-set-background-filters! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-base-writing-direction (c-> nstextview? exact-integer?)]
  [nstextview-set-base-writing-direction! (c-> nstextview? exact-integer? void?)]
  [nstextview-baseline-offset-from-bottom (c-> nstextview? real?)]
  [nstextview-bottom-anchor (c-> nstextview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstextview-bounds (c-> nstextview? any/c)]
  [nstextview-set-bounds! (c-> nstextview? any/c void?)]
  [nstextview-bounds-rotation (c-> nstextview? real?)]
  [nstextview-set-bounds-rotation! (c-> nstextview? real? void?)]
  [nstextview-can-become-key-view (c-> nstextview? boolean?)]
  [nstextview-can-draw (c-> nstextview? boolean?)]
  [nstextview-can-draw-concurrently (c-> nstextview? boolean?)]
  [nstextview-set-can-draw-concurrently! (c-> nstextview? boolean? void?)]
  [nstextview-can-draw-subviews-into-layer (c-> nstextview? boolean?)]
  [nstextview-set-can-draw-subviews-into-layer! (c-> nstextview? boolean? void?)]
  [nstextview-candidate-list-touch-bar-item (c-> nstextview? (or/c nscandidatelisttouchbaritem? objc-nil?))]
  [nstextview-center-x-anchor (c-> nstextview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstextview-center-y-anchor (c-> nstextview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstextview-clips-to-bounds (c-> nstextview? boolean?)]
  [nstextview-set-clips-to-bounds! (c-> nstextview? boolean? void?)]
  [nstextview-coalescing-undo (c-> nstextview? boolean?)]
  [nstextview-compatible-with-responsive-scrolling (c-> boolean?)]
  [nstextview-compositing-filter (c-> nstextview? (or/c cifilter? objc-nil?))]
  [nstextview-set-compositing-filter! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-constraints (c-> nstextview? any/c)]
  [nstextview-content-filters (c-> nstextview? any/c)]
  [nstextview-set-content-filters! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-continuous-spell-checking-enabled (c-> nstextview? boolean?)]
  [nstextview-set-continuous-spell-checking-enabled! (c-> nstextview? boolean? void?)]
  [nstextview-default-focus-ring-type (c-> exact-nonnegative-integer?)]
  [nstextview-default-menu (c-> (or/c nsmenu? objc-nil?))]
  [nstextview-default-paragraph-style (c-> nstextview? (or/c nsparagraphstyle? objc-nil?))]
  [nstextview-set-default-paragraph-style! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-delegate (c-> nstextview? any/c)]
  [nstextview-set-delegate! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-displays-link-tool-tips (c-> nstextview? boolean?)]
  [nstextview-set-displays-link-tool-tips! (c-> nstextview? boolean? void?)]
  [nstextview-drawing-find-indicator (c-> nstextview? boolean?)]
  [nstextview-draws-background (c-> nstextview? boolean?)]
  [nstextview-set-draws-background! (c-> nstextview? boolean? void?)]
  [nstextview-editable (c-> nstextview? boolean?)]
  [nstextview-set-editable! (c-> nstextview? boolean? void?)]
  [nstextview-enabled-text-checking-types (c-> nstextview? exact-nonnegative-integer?)]
  [nstextview-set-enabled-text-checking-types! (c-> nstextview? exact-nonnegative-integer? void?)]
  [nstextview-enclosing-menu-item (c-> nstextview? (or/c nsmenuitem? objc-nil?))]
  [nstextview-enclosing-scroll-view (c-> nstextview? (or/c nsscrollview? objc-nil?))]
  [nstextview-field-editor (c-> nstextview? boolean?)]
  [nstextview-set-field-editor! (c-> nstextview? boolean? void?)]
  [nstextview-first-baseline-anchor (c-> nstextview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstextview-first-baseline-offset-from-top (c-> nstextview? real?)]
  [nstextview-fitting-size (c-> nstextview? any/c)]
  [nstextview-flipped (c-> nstextview? boolean?)]
  [nstextview-focus-ring-mask-bounds (c-> nstextview? any/c)]
  [nstextview-focus-ring-type (c-> nstextview? exact-nonnegative-integer?)]
  [nstextview-set-focus-ring-type! (c-> nstextview? exact-nonnegative-integer? void?)]
  [nstextview-focus-view (c-> (or/c nsview? objc-nil?))]
  [nstextview-font (c-> nstextview? (or/c nsfont? objc-nil?))]
  [nstextview-set-font! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-frame (c-> nstextview? any/c)]
  [nstextview-set-frame! (c-> nstextview? any/c void?)]
  [nstextview-frame-center-rotation (c-> nstextview? real?)]
  [nstextview-set-frame-center-rotation! (c-> nstextview? real? void?)]
  [nstextview-frame-rotation (c-> nstextview? real?)]
  [nstextview-set-frame-rotation! (c-> nstextview? real? void?)]
  [nstextview-gesture-recognizers (c-> nstextview? any/c)]
  [nstextview-set-gesture-recognizers! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-grammar-checking-enabled (c-> nstextview? boolean?)]
  [nstextview-set-grammar-checking-enabled! (c-> nstextview? boolean? void?)]
  [nstextview-has-ambiguous-layout (c-> nstextview? boolean?)]
  [nstextview-height-adjust-limit (c-> nstextview? real?)]
  [nstextview-height-anchor (c-> nstextview? (or/c nslayoutdimension? objc-nil?))]
  [nstextview-hidden (c-> nstextview? boolean?)]
  [nstextview-set-hidden! (c-> nstextview? boolean? void?)]
  [nstextview-hidden-or-has-hidden-ancestor (c-> nstextview? boolean?)]
  [nstextview-horizontal-content-size-constraint-active (c-> nstextview? boolean?)]
  [nstextview-set-horizontal-content-size-constraint-active! (c-> nstextview? boolean? void?)]
  [nstextview-horizontally-resizable (c-> nstextview? boolean?)]
  [nstextview-set-horizontally-resizable! (c-> nstextview? boolean? void?)]
  [nstextview-imports-graphics (c-> nstextview? boolean?)]
  [nstextview-set-imports-graphics! (c-> nstextview? boolean? void?)]
  [nstextview-in-full-screen-mode (c-> nstextview? boolean?)]
  [nstextview-in-live-resize (c-> nstextview? boolean?)]
  [nstextview-incremental-searching-enabled (c-> nstextview? boolean?)]
  [nstextview-set-incremental-searching-enabled! (c-> nstextview? boolean? void?)]
  [nstextview-inline-prediction-type (c-> nstextview? exact-integer?)]
  [nstextview-set-inline-prediction-type! (c-> nstextview? exact-integer? void?)]
  [nstextview-input-context (c-> nstextview? (or/c nstextinputcontext? objc-nil?))]
  [nstextview-insertion-point-color (c-> nstextview? (or/c nscolor? objc-nil?))]
  [nstextview-set-insertion-point-color! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-intrinsic-content-size (c-> nstextview? any/c)]
  [nstextview-last-baseline-anchor (c-> nstextview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstextview-last-baseline-offset-from-bottom (c-> nstextview? real?)]
  [nstextview-layer (c-> nstextview? (or/c calayer? objc-nil?))]
  [nstextview-set-layer! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-layer-contents-placement (c-> nstextview? exact-integer?)]
  [nstextview-set-layer-contents-placement! (c-> nstextview? exact-integer? void?)]
  [nstextview-layer-contents-redraw-policy (c-> nstextview? exact-integer?)]
  [nstextview-set-layer-contents-redraw-policy! (c-> nstextview? exact-integer? void?)]
  [nstextview-layer-uses-core-image-filters (c-> nstextview? boolean?)]
  [nstextview-set-layer-uses-core-image-filters! (c-> nstextview? boolean? void?)]
  [nstextview-layout-guides (c-> nstextview? any/c)]
  [nstextview-layout-manager (c-> nstextview? (or/c nslayoutmanager? objc-nil?))]
  [nstextview-layout-margins-guide (c-> nstextview? (or/c nslayoutguide? objc-nil?))]
  [nstextview-leading-anchor (c-> nstextview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstextview-left-anchor (c-> nstextview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstextview-link-text-attributes (c-> nstextview? any/c)]
  [nstextview-set-link-text-attributes! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-marked-text-attributes (c-> nstextview? any/c)]
  [nstextview-set-marked-text-attributes! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-math-expression-completion-type (c-> nstextview? exact-integer?)]
  [nstextview-set-math-expression-completion-type! (c-> nstextview? exact-integer? void?)]
  [nstextview-max-size (c-> nstextview? any/c)]
  [nstextview-set-max-size! (c-> nstextview? any/c void?)]
  [nstextview-menu (c-> nstextview? (or/c nsmenu? objc-nil?))]
  [nstextview-set-menu! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-min-size (c-> nstextview? any/c)]
  [nstextview-set-min-size! (c-> nstextview? any/c void?)]
  [nstextview-mouse-down-can-move-window (c-> nstextview? boolean?)]
  [nstextview-needs-display (c-> nstextview? boolean?)]
  [nstextview-set-needs-display! (c-> nstextview? boolean? void?)]
  [nstextview-needs-layout (c-> nstextview? boolean?)]
  [nstextview-set-needs-layout! (c-> nstextview? boolean? void?)]
  [nstextview-needs-panel-to-become-key (c-> nstextview? boolean?)]
  [nstextview-needs-update-constraints (c-> nstextview? boolean?)]
  [nstextview-set-needs-update-constraints! (c-> nstextview? boolean? void?)]
  [nstextview-next-key-view (c-> nstextview? (or/c nsview? objc-nil?))]
  [nstextview-set-next-key-view! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-next-responder (c-> nstextview? (or/c nsresponder? objc-nil?))]
  [nstextview-set-next-responder! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-next-valid-key-view (c-> nstextview? (or/c nsview? objc-nil?))]
  [nstextview-opaque (c-> nstextview? boolean?)]
  [nstextview-opaque-ancestor (c-> nstextview? (or/c nsview? objc-nil?))]
  [nstextview-page-footer (c-> nstextview? (or/c nsattributedstring? objc-nil?))]
  [nstextview-page-header (c-> nstextview? (or/c nsattributedstring? objc-nil?))]
  [nstextview-posts-bounds-changed-notifications (c-> nstextview? boolean?)]
  [nstextview-set-posts-bounds-changed-notifications! (c-> nstextview? boolean? void?)]
  [nstextview-posts-frame-changed-notifications (c-> nstextview? boolean?)]
  [nstextview-set-posts-frame-changed-notifications! (c-> nstextview? boolean? void?)]
  [nstextview-prefers-compact-control-size-metrics (c-> nstextview? boolean?)]
  [nstextview-set-prefers-compact-control-size-metrics! (c-> nstextview? boolean? void?)]
  [nstextview-prepared-content-rect (c-> nstextview? any/c)]
  [nstextview-set-prepared-content-rect! (c-> nstextview? any/c void?)]
  [nstextview-preserves-content-during-live-resize (c-> nstextview? boolean?)]
  [nstextview-pressure-configuration (c-> nstextview? (or/c nspressureconfiguration? objc-nil?))]
  [nstextview-set-pressure-configuration! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-previous-key-view (c-> nstextview? (or/c nsview? objc-nil?))]
  [nstextview-previous-valid-key-view (c-> nstextview? (or/c nsview? objc-nil?))]
  [nstextview-print-job-title (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-range-for-user-character-attribute-change (c-> nstextview? any/c)]
  [nstextview-range-for-user-completion (c-> nstextview? any/c)]
  [nstextview-range-for-user-paragraph-attribute-change (c-> nstextview? any/c)]
  [nstextview-range-for-user-text-change (c-> nstextview? any/c)]
  [nstextview-ranges-for-user-character-attribute-change (c-> nstextview? any/c)]
  [nstextview-ranges-for-user-paragraph-attribute-change (c-> nstextview? any/c)]
  [nstextview-ranges-for-user-text-change (c-> nstextview? any/c)]
  [nstextview-readable-pasteboard-types (c-> nstextview? any/c)]
  [nstextview-rect-preserved-during-live-resize (c-> nstextview? any/c)]
  [nstextview-registered-dragged-types (c-> nstextview? any/c)]
  [nstextview-requires-constraint-based-layout (c-> boolean?)]
  [nstextview-restorable-state-key-paths (c-> any/c)]
  [nstextview-rich-text (c-> nstextview? boolean?)]
  [nstextview-set-rich-text! (c-> nstextview? boolean? void?)]
  [nstextview-right-anchor (c-> nstextview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstextview-rotated-from-base (c-> nstextview? boolean?)]
  [nstextview-rotated-or-scaled-from-base (c-> nstextview? boolean?)]
  [nstextview-ruler-visible (c-> nstextview? boolean?)]
  [nstextview-set-ruler-visible! (c-> nstextview? boolean? void?)]
  [nstextview-safe-area-insets (c-> nstextview? any/c)]
  [nstextview-safe-area-layout-guide (c-> nstextview? (or/c nslayoutguide? objc-nil?))]
  [nstextview-safe-area-rect (c-> nstextview? any/c)]
  [nstextview-selectable (c-> nstextview? boolean?)]
  [nstextview-set-selectable! (c-> nstextview? boolean? void?)]
  [nstextview-selected-range (c-> nstextview? any/c)]
  [nstextview-set-selected-range! (c-> nstextview? any/c void?)]
  [nstextview-selected-ranges (c-> nstextview? any/c)]
  [nstextview-set-selected-ranges! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-selected-text-attributes (c-> nstextview? any/c)]
  [nstextview-set-selected-text-attributes! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-selection-affinity (c-> nstextview? exact-nonnegative-integer?)]
  [nstextview-selection-granularity (c-> nstextview? exact-nonnegative-integer?)]
  [nstextview-set-selection-granularity! (c-> nstextview? exact-nonnegative-integer? void?)]
  [nstextview-shadow (c-> nstextview? (or/c nsshadow? objc-nil?))]
  [nstextview-set-shadow! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-should-draw-insertion-point (c-> nstextview? boolean?)]
  [nstextview-smart-insert-delete-enabled (c-> nstextview? boolean?)]
  [nstextview-set-smart-insert-delete-enabled! (c-> nstextview? boolean? void?)]
  [nstextview-spell-checker-document-tag (c-> nstextview? exact-integer?)]
  [nstextview-string (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-set-string! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-strongly-references-text-storage (c-> boolean?)]
  [nstextview-subviews (c-> nstextview? any/c)]
  [nstextview-set-subviews! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-superview (c-> nstextview? (or/c nsview? objc-nil?))]
  [nstextview-tag (c-> nstextview? exact-integer?)]
  [nstextview-text-color (c-> nstextview? (or/c nscolor? objc-nil?))]
  [nstextview-set-text-color! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-text-container (c-> nstextview? (or/c nstextcontainer? objc-nil?))]
  [nstextview-set-text-container! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-text-container-inset (c-> nstextview? any/c)]
  [nstextview-set-text-container-inset! (c-> nstextview? any/c void?)]
  [nstextview-text-container-origin (c-> nstextview? any/c)]
  [nstextview-text-content-storage (c-> nstextview? (or/c nstextcontentstorage? objc-nil?))]
  [nstextview-text-highlight-attributes (c-> nstextview? any/c)]
  [nstextview-set-text-highlight-attributes! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-text-layout-manager (c-> nstextview? (or/c nstextlayoutmanager? objc-nil?))]
  [nstextview-text-storage (c-> nstextview? (or/c nstextstorage? objc-nil?))]
  [nstextview-tool-tip (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-set-tool-tip! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-top-anchor (c-> nstextview? (or/c nslayoutyaxisanchor? objc-nil?))]
  [nstextview-touch-bar (c-> nstextview? (or/c nstouchbar? objc-nil?))]
  [nstextview-set-touch-bar! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-tracking-areas (c-> nstextview? any/c)]
  [nstextview-trailing-anchor (c-> nstextview? (or/c nslayoutxaxisanchor? objc-nil?))]
  [nstextview-translates-autoresizing-mask-into-constraints (c-> nstextview? boolean?)]
  [nstextview-set-translates-autoresizing-mask-into-constraints! (c-> nstextview? boolean? void?)]
  [nstextview-typing-attributes (c-> nstextview? any/c)]
  [nstextview-set-typing-attributes! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-undo-manager (c-> nstextview? (or/c nsundomanager? objc-nil?))]
  [nstextview-user-activity (c-> nstextview? (or/c nsuseractivity? objc-nil?))]
  [nstextview-set-user-activity! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-user-interface-layout-direction (c-> nstextview? exact-integer?)]
  [nstextview-set-user-interface-layout-direction! (c-> nstextview? exact-integer? void?)]
  [nstextview-uses-adaptive-color-mapping-for-dark-appearance (c-> nstextview? boolean?)]
  [nstextview-set-uses-adaptive-color-mapping-for-dark-appearance! (c-> nstextview? boolean? void?)]
  [nstextview-uses-find-bar (c-> nstextview? boolean?)]
  [nstextview-set-uses-find-bar! (c-> nstextview? boolean? void?)]
  [nstextview-uses-find-panel (c-> nstextview? boolean?)]
  [nstextview-set-uses-find-panel! (c-> nstextview? boolean? void?)]
  [nstextview-uses-font-panel (c-> nstextview? boolean?)]
  [nstextview-set-uses-font-panel! (c-> nstextview? boolean? void?)]
  [nstextview-uses-inspector-bar (c-> nstextview? boolean?)]
  [nstextview-set-uses-inspector-bar! (c-> nstextview? boolean? void?)]
  [nstextview-uses-rollover-button-for-selection (c-> nstextview? boolean?)]
  [nstextview-set-uses-rollover-button-for-selection! (c-> nstextview? boolean? void?)]
  [nstextview-uses-ruler (c-> nstextview? boolean?)]
  [nstextview-set-uses-ruler! (c-> nstextview? boolean? void?)]
  [nstextview-vertical-content-size-constraint-active (c-> nstextview? boolean?)]
  [nstextview-set-vertical-content-size-constraint-active! (c-> nstextview? boolean? void?)]
  [nstextview-vertically-resizable (c-> nstextview? boolean?)]
  [nstextview-set-vertically-resizable! (c-> nstextview? boolean? void?)]
  [nstextview-visible-rect (c-> nstextview? any/c)]
  [nstextview-wants-best-resolution-open-gl-surface (c-> nstextview? boolean?)]
  [nstextview-set-wants-best-resolution-open-gl-surface! (c-> nstextview? boolean? void?)]
  [nstextview-wants-default-clipping (c-> nstextview? boolean?)]
  [nstextview-wants-extended-dynamic-range-open-gl-surface (c-> nstextview? boolean?)]
  [nstextview-set-wants-extended-dynamic-range-open-gl-surface! (c-> nstextview? boolean? void?)]
  [nstextview-wants-layer (c-> nstextview? boolean?)]
  [nstextview-set-wants-layer! (c-> nstextview? boolean? void?)]
  [nstextview-wants-resting-touches (c-> nstextview? boolean?)]
  [nstextview-set-wants-resting-touches! (c-> nstextview? boolean? void?)]
  [nstextview-wants-update-layer (c-> nstextview? boolean?)]
  [nstextview-width-adjust-limit (c-> nstextview? real?)]
  [nstextview-width-anchor (c-> nstextview? (or/c nslayoutdimension? objc-nil?))]
  [nstextview-window (c-> nstextview? (or/c nswindow? objc-nil?))]
  [nstextview-writable-pasteboard-types (c-> nstextview? any/c)]
  [nstextview-writing-tools-active (c-> nstextview? boolean?)]
  [nstextview-writing-tools-behavior (c-> nstextview? exact-integer?)]
  [nstextview-set-writing-tools-behavior! (c-> nstextview? exact-integer? void?)]
  [nstextview-writing-tools-coordinator (c-> nstextview? (or/c nswritingtoolscoordinator? objc-nil?))]
  [nstextview-set-writing-tools-coordinator! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-rtfd-from-range (c-> nstextview? any/c (or/c nsdata? objc-nil?))]
  [nstextview-rtf-from-range (c-> nstextview? any/c (or/c nsdata? objc-nil?))]
  [nstextview-accepts-first-mouse (c-> nstextview? (or/c string? objc-object? #f) boolean?)]
  [nstextview-accessibility-activation-point (c-> nstextview? any/c)]
  [nstextview-accessibility-allowed-values (c-> nstextview? any/c)]
  [nstextview-accessibility-application-focused-ui-element (c-> nstextview? any/c)]
  [nstextview-accessibility-attributed-string-for-range (c-> nstextview? any/c (or/c nsattributedstring? objc-nil?))]
  [nstextview-accessibility-attributed-user-input-labels (c-> nstextview? any/c)]
  [nstextview-accessibility-cancel-button (c-> nstextview? any/c)]
  [nstextview-accessibility-cell-for-column-row (c-> nstextview? exact-integer? exact-integer? any/c)]
  [nstextview-accessibility-children (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-children-in-navigation-order (c-> nstextview? any/c)]
  [nstextview-accessibility-clear-button (c-> nstextview? any/c)]
  [nstextview-accessibility-close-button (c-> nstextview? any/c)]
  [nstextview-accessibility-column-count (c-> nstextview? exact-integer?)]
  [nstextview-accessibility-column-header-ui-elements (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-column-index-range (c-> nstextview? any/c)]
  [nstextview-accessibility-column-titles (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-columns (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-contents (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-critical-value (c-> nstextview? any/c)]
  [nstextview-accessibility-custom-actions (c-> nstextview? any/c)]
  [nstextview-accessibility-custom-rotors (c-> nstextview? any/c)]
  [nstextview-accessibility-decrement-button (c-> nstextview? any/c)]
  [nstextview-accessibility-default-button (c-> nstextview? any/c)]
  [nstextview-accessibility-disclosed-by-row (c-> nstextview? any/c)]
  [nstextview-accessibility-disclosed-rows (c-> nstextview? any/c)]
  [nstextview-accessibility-disclosure-level (c-> nstextview? exact-integer?)]
  [nstextview-accessibility-document (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-accessibility-extras-menu-bar (c-> nstextview? any/c)]
  [nstextview-accessibility-filename (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-accessibility-focused-window (c-> nstextview? any/c)]
  [nstextview-accessibility-frame (c-> nstextview? any/c)]
  [nstextview-accessibility-frame-for-range (c-> nstextview? any/c any/c)]
  [nstextview-accessibility-full-screen-button (c-> nstextview? any/c)]
  [nstextview-accessibility-grow-area (c-> nstextview? any/c)]
  [nstextview-accessibility-handles (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-header (c-> nstextview? any/c)]
  [nstextview-accessibility-help (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-accessibility-horizontal-scroll-bar (c-> nstextview? any/c)]
  [nstextview-accessibility-horizontal-unit-description (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-accessibility-horizontal-units (c-> nstextview? exact-integer?)]
  [nstextview-accessibility-identifier (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-accessibility-increment-button (c-> nstextview? any/c)]
  [nstextview-accessibility-index (c-> nstextview? exact-integer?)]
  [nstextview-accessibility-insertion-point-line-number (c-> nstextview? exact-integer?)]
  [nstextview-accessibility-label (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-accessibility-label-ui-elements (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-label-value (c-> nstextview? real?)]
  [nstextview-accessibility-layout-point-for-screen-point (c-> nstextview? any/c any/c)]
  [nstextview-accessibility-layout-size-for-screen-size (c-> nstextview? any/c any/c)]
  [nstextview-accessibility-line-for-index (c-> nstextview? exact-integer? exact-integer?)]
  [nstextview-accessibility-linked-ui-elements (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-main-window (c-> nstextview? any/c)]
  [nstextview-accessibility-marker-group-ui-element (c-> nstextview? any/c)]
  [nstextview-accessibility-marker-type-description (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-accessibility-marker-ui-elements (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-marker-values (c-> nstextview? any/c)]
  [nstextview-accessibility-max-value (c-> nstextview? any/c)]
  [nstextview-accessibility-menu-bar (c-> nstextview? any/c)]
  [nstextview-accessibility-min-value (c-> nstextview? any/c)]
  [nstextview-accessibility-minimize-button (c-> nstextview? any/c)]
  [nstextview-accessibility-next-contents (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-number-of-characters (c-> nstextview? exact-integer?)]
  [nstextview-accessibility-orientation (c-> nstextview? exact-integer?)]
  [nstextview-accessibility-overflow-button (c-> nstextview? any/c)]
  [nstextview-accessibility-parent (c-> nstextview? any/c)]
  [nstextview-accessibility-perform-cancel (c-> nstextview? boolean?)]
  [nstextview-accessibility-perform-confirm (c-> nstextview? boolean?)]
  [nstextview-accessibility-perform-decrement (c-> nstextview? boolean?)]
  [nstextview-accessibility-perform-delete (c-> nstextview? boolean?)]
  [nstextview-accessibility-perform-increment (c-> nstextview? boolean?)]
  [nstextview-accessibility-perform-pick (c-> nstextview? boolean?)]
  [nstextview-accessibility-perform-press (c-> nstextview? boolean?)]
  [nstextview-accessibility-perform-raise (c-> nstextview? boolean?)]
  [nstextview-accessibility-perform-show-alternate-ui (c-> nstextview? boolean?)]
  [nstextview-accessibility-perform-show-default-ui (c-> nstextview? boolean?)]
  [nstextview-accessibility-perform-show-menu (c-> nstextview? boolean?)]
  [nstextview-accessibility-placeholder-value (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-accessibility-previous-contents (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-proxy (c-> nstextview? any/c)]
  [nstextview-accessibility-rtf-for-range (c-> nstextview? any/c (or/c nsdata? objc-nil?))]
  [nstextview-accessibility-range-for-index (c-> nstextview? exact-integer? any/c)]
  [nstextview-accessibility-range-for-line (c-> nstextview? exact-integer? any/c)]
  [nstextview-accessibility-range-for-position (c-> nstextview? any/c any/c)]
  [nstextview-accessibility-role (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-accessibility-role-description (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-accessibility-row-count (c-> nstextview? exact-integer?)]
  [nstextview-accessibility-row-header-ui-elements (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-row-index-range (c-> nstextview? any/c)]
  [nstextview-accessibility-rows (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-ruler-marker-type (c-> nstextview? exact-integer?)]
  [nstextview-accessibility-screen-point-for-layout-point (c-> nstextview? any/c any/c)]
  [nstextview-accessibility-screen-size-for-layout-size (c-> nstextview? any/c any/c)]
  [nstextview-accessibility-search-button (c-> nstextview? any/c)]
  [nstextview-accessibility-search-menu (c-> nstextview? any/c)]
  [nstextview-accessibility-selected-cells (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-selected-children (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-selected-columns (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-selected-rows (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-selected-text (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-accessibility-selected-text-range (c-> nstextview? any/c)]
  [nstextview-accessibility-selected-text-ranges (c-> nstextview? any/c)]
  [nstextview-accessibility-serves-as-title-for-ui-elements (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-shared-character-range (c-> nstextview? any/c)]
  [nstextview-accessibility-shared-focus-elements (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-shared-text-ui-elements (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-shown-menu (c-> nstextview? any/c)]
  [nstextview-accessibility-sort-direction (c-> nstextview? exact-integer?)]
  [nstextview-accessibility-splitters (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-string-for-range (c-> nstextview? any/c (or/c nsstring? objc-nil?))]
  [nstextview-accessibility-style-range-for-index (c-> nstextview? exact-integer? any/c)]
  [nstextview-accessibility-subrole (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-accessibility-tabs (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-title (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-accessibility-title-ui-element (c-> nstextview? any/c)]
  [nstextview-accessibility-toolbar-button (c-> nstextview? any/c)]
  [nstextview-accessibility-top-level-ui-element (c-> nstextview? any/c)]
  [nstextview-accessibility-url (c-> nstextview? (or/c nsurl? objc-nil?))]
  [nstextview-accessibility-unit-description (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-accessibility-units (c-> nstextview? exact-integer?)]
  [nstextview-accessibility-user-input-labels (c-> nstextview? any/c)]
  [nstextview-accessibility-value (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-accessibility-value-description (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-accessibility-vertical-scroll-bar (c-> nstextview? any/c)]
  [nstextview-accessibility-vertical-unit-description (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-accessibility-vertical-units (c-> nstextview? exact-integer?)]
  [nstextview-accessibility-visible-cells (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-visible-character-range (c-> nstextview? any/c)]
  [nstextview-accessibility-visible-children (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-visible-columns (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-visible-rows (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-warning-value (c-> nstextview? any/c)]
  [nstextview-accessibility-window (c-> nstextview? any/c)]
  [nstextview-accessibility-windows (c-> nstextview? (or/c nsarray? objc-nil?))]
  [nstextview-accessibility-zoom-button (c-> nstextview? any/c)]
  [nstextview-add-subview! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-add-subview-positioned-relative-to! (c-> nstextview? (or/c string? objc-object? #f) exact-integer? (or/c string? objc-object? #f) void?)]
  [nstextview-add-tool-tip-rect-owner-user-data! (c-> nstextview? any/c (or/c string? objc-object? #f) (or/c cpointer? #f) exact-integer?)]
  [nstextview-adjust-scroll (c-> nstextview? any/c any/c)]
  [nstextview-align-center (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-align-justified (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-align-left (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-align-right (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-ancestor-shared-with-view (c-> nstextview? (or/c string? objc-object? #f) (or/c nsview? objc-nil?))]
  [nstextview-animation-for-key (c-> nstextview? (or/c string? objc-object? #f) any/c)]
  [nstextview-animations (c-> nstextview? any/c)]
  [nstextview-animator (c-> nstextview? any/c)]
  [nstextview-appearance (c-> nstextview? (or/c nsappearance? objc-nil?))]
  [nstextview-attributed-string (c-> nstextview? (or/c nsattributedstring? objc-nil?))]
  [nstextview-attributed-substring-for-proposed-range-actual-range (c-> nstextview? any/c (or/c cpointer? #f) (or/c nsattributedstring? objc-nil?))]
  [nstextview-autoscroll (c-> nstextview? (or/c string? objc-object? #f) boolean?)]
  [nstextview-backing-aligned-rect-options (c-> nstextview? any/c exact-nonnegative-integer? any/c)]
  [nstextview-baseline-delta-for-character-at-index (c-> nstextview? exact-nonnegative-integer? real?)]
  [nstextview-become-first-responder (c-> nstextview? boolean?)]
  [nstextview-begin-gesture-with-event! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-bitmap-image-rep-for-caching-display-in-rect (c-> nstextview? any/c (or/c nsbitmapimagerep? objc-nil?))]
  [nstextview-cache-display-in-rect-to-bitmap-image-rep (c-> nstextview? any/c (or/c string? objc-object? #f) void?)]
  [nstextview-cancel-operation (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-capitalize-word (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-center-scan-rect! (c-> nstextview? any/c any/c)]
  [nstextview-center-selection-in-visible-area! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-change-attributes (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-change-case-of-letter (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-change-color (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-change-document-background-color (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-change-font (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-change-layout-orientation (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-change-mode-with-event (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-change-spelling (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-character-index-for-insertion-at-point (c-> nstextview? any/c exact-nonnegative-integer?)]
  [nstextview-character-index-for-point (c-> nstextview? any/c exact-nonnegative-integer?)]
  [nstextview-check-spelling (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-clicked-on-link-at-index (c-> nstextview? (or/c string? objc-object? #f) exact-nonnegative-integer? void?)]
  [nstextview-complete (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-conclude-drag-operation (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-content-type (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-context-menu-key-down (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-convert-point-from-view (c-> nstextview? any/c (or/c string? objc-object? #f) any/c)]
  [nstextview-convert-point-to-view (c-> nstextview? any/c (or/c string? objc-object? #f) any/c)]
  [nstextview-convert-point-from-backing (c-> nstextview? any/c any/c)]
  [nstextview-convert-point-from-layer (c-> nstextview? any/c any/c)]
  [nstextview-convert-point-to-backing (c-> nstextview? any/c any/c)]
  [nstextview-convert-point-to-layer (c-> nstextview? any/c any/c)]
  [nstextview-convert-rect-from-view (c-> nstextview? any/c (or/c string? objc-object? #f) any/c)]
  [nstextview-convert-rect-to-view (c-> nstextview? any/c (or/c string? objc-object? #f) any/c)]
  [nstextview-convert-rect-from-backing (c-> nstextview? any/c any/c)]
  [nstextview-convert-rect-from-layer (c-> nstextview? any/c any/c)]
  [nstextview-convert-rect-to-backing (c-> nstextview? any/c any/c)]
  [nstextview-convert-rect-to-layer (c-> nstextview? any/c any/c)]
  [nstextview-convert-size-from-view (c-> nstextview? any/c (or/c string? objc-object? #f) any/c)]
  [nstextview-convert-size-to-view (c-> nstextview? any/c (or/c string? objc-object? #f) any/c)]
  [nstextview-convert-size-from-backing (c-> nstextview? any/c any/c)]
  [nstextview-convert-size-from-layer (c-> nstextview? any/c any/c)]
  [nstextview-convert-size-to-backing (c-> nstextview? any/c any/c)]
  [nstextview-convert-size-to-layer (c-> nstextview? any/c any/c)]
  [nstextview-copy (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-copy-font (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-copy-ruler (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-cursor-update (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-cut (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-delete (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-delete-backward (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-delete-backward-by-decomposing-previous-character (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-delete-forward (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-delete-to-beginning-of-line (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-delete-to-beginning-of-paragraph (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-delete-to-end-of-line (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-delete-to-end-of-paragraph (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-delete-to-mark (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-delete-word-backward (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-delete-word-forward (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-did-add-subview (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-did-close-menu-with-event (c-> nstextview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstextview-display! (c-> nstextview? void?)]
  [nstextview-display-if-needed! (c-> nstextview? void?)]
  [nstextview-display-if-needed-ignoring-opacity! (c-> nstextview? void?)]
  [nstextview-display-if-needed-in-rect! (c-> nstextview? any/c void?)]
  [nstextview-display-if-needed-in-rect-ignoring-opacity! (c-> nstextview? any/c void?)]
  [nstextview-display-rect! (c-> nstextview? any/c void?)]
  [nstextview-display-rect-ignoring-opacity! (c-> nstextview? any/c void?)]
  [nstextview-display-rect-ignoring-opacity-in-context! (c-> nstextview? any/c (or/c string? objc-object? #f) void?)]
  [nstextview-do-command-by-selector (c-> nstextview? string? void?)]
  [nstextview-document-visible-rect (c-> nstextview? any/c)]
  [nstextview-dragging-ended (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-dragging-entered (c-> nstextview? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nstextview-dragging-exited (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-dragging-session-ended-at-point-operation (c-> nstextview? (or/c string? objc-object? #f) any/c exact-nonnegative-integer? void?)]
  [nstextview-dragging-session-moved-to-point (c-> nstextview? (or/c string? objc-object? #f) any/c void?)]
  [nstextview-dragging-session-source-operation-mask-for-dragging-context (c-> nstextview? (or/c string? objc-object? #f) exact-integer? exact-nonnegative-integer?)]
  [nstextview-dragging-session-will-begin-at-point (c-> nstextview? (or/c string? objc-object? #f) any/c void?)]
  [nstextview-dragging-updated (c-> nstextview? (or/c string? objc-object? #f) exact-nonnegative-integer?)]
  [nstextview-draw-insertion-point-in-rect-color-turned-on (c-> nstextview? any/c (or/c string? objc-object? #f) boolean? void?)]
  [nstextview-draw-rect (c-> nstextview? any/c void?)]
  [nstextview-draw-view-background-in-rect (c-> nstextview? any/c void?)]
  [nstextview-draws-vertically-for-character-at-index (c-> nstextview? exact-nonnegative-integer? boolean?)]
  [nstextview-effective-appearance (c-> nstextview? (or/c nsappearance? objc-nil?))]
  [nstextview-encode-with-coder (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-end-gesture-with-event! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-first-rect-for-character-range-actual-range (c-> nstextview? any/c (or/c cpointer? #f) any/c)]
  [nstextview-flags-changed (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-flush-buffered-key-events (c-> nstextview? void?)]
  [nstextview-fraction-of-distance-through-glyph-for-point (c-> nstextview? any/c real?)]
  [nstextview-get-rects-being-drawn-count (c-> nstextview? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nstextview-get-rects-exposed-during-live-resize-count (c-> nstextview? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nstextview-has-marked-text (c-> nstextview? boolean?)]
  [nstextview-help-requested (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-hit-test (c-> nstextview? any/c (or/c nsview? objc-nil?))]
  [nstextview-identifier (c-> nstextview? (or/c nsstring? objc-nil?))]
  [nstextview-ignore-modifier-keys-for-dragging-session (c-> nstextview? (or/c string? objc-object? #f) boolean?)]
  [nstextview-ignore-spelling (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-indent (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-init-using-text-layout-manager (c-> nstextview? boolean? any/c)]
  [nstextview-insert-adaptive-image-glyph-replacement-range! (c-> nstextview? (or/c string? objc-object? #f) any/c void?)]
  [nstextview-insert-backtab! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-insert-container-break! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-insert-double-quote-ignoring-substitution! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-insert-line-break! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-insert-newline! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-insert-newline-ignoring-field-editor! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-insert-paragraph-separator! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-insert-single-quote-ignoring-substitution! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-insert-tab! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-insert-tab-ignoring-field-editor! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-insert-text-replacement-range! (c-> nstextview? (or/c string? objc-object? #f) any/c void?)]
  [nstextview-interpret-key-events (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-invalidate-text-container-origin (c-> nstextview? void?)]
  [nstextview-is-accessibility-alternate-ui-visible (c-> nstextview? boolean?)]
  [nstextview-is-accessibility-disclosed (c-> nstextview? boolean?)]
  [nstextview-is-accessibility-edited (c-> nstextview? boolean?)]
  [nstextview-is-accessibility-element (c-> nstextview? boolean?)]
  [nstextview-is-accessibility-enabled (c-> nstextview? boolean?)]
  [nstextview-is-accessibility-expanded (c-> nstextview? boolean?)]
  [nstextview-is-accessibility-focused (c-> nstextview? boolean?)]
  [nstextview-is-accessibility-frontmost (c-> nstextview? boolean?)]
  [nstextview-is-accessibility-hidden (c-> nstextview? boolean?)]
  [nstextview-is-accessibility-main (c-> nstextview? boolean?)]
  [nstextview-is-accessibility-minimized (c-> nstextview? boolean?)]
  [nstextview-is-accessibility-modal (c-> nstextview? boolean?)]
  [nstextview-is-accessibility-ordered-by-row (c-> nstextview? boolean?)]
  [nstextview-is-accessibility-protected-content (c-> nstextview? boolean?)]
  [nstextview-is-accessibility-required (c-> nstextview? boolean?)]
  [nstextview-is-accessibility-selected (c-> nstextview? boolean?)]
  [nstextview-is-accessibility-selector-allowed (c-> nstextview? string? boolean?)]
  [nstextview-is-descendant-of (c-> nstextview? (or/c string? objc-object? #f) boolean?)]
  [nstextview-is-editable (c-> nstextview? boolean?)]
  [nstextview-is-field-editor (c-> nstextview? boolean?)]
  [nstextview-is-flipped (c-> nstextview? boolean?)]
  [nstextview-is-hidden (c-> nstextview? boolean?)]
  [nstextview-is-hidden-or-has-hidden-ancestor (c-> nstextview? boolean?)]
  [nstextview-is-horizontally-resizable (c-> nstextview? boolean?)]
  [nstextview-is-opaque (c-> nstextview? boolean?)]
  [nstextview-is-rich-text (c-> nstextview? boolean?)]
  [nstextview-is-rotated-from-base (c-> nstextview? boolean?)]
  [nstextview-is-rotated-or-scaled-from-base (c-> nstextview? boolean?)]
  [nstextview-is-ruler-visible (c-> nstextview? boolean?)]
  [nstextview-is-selectable (c-> nstextview? boolean?)]
  [nstextview-is-vertically-resizable (c-> nstextview? boolean?)]
  [nstextview-key-down (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-key-up (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-layout (c-> nstextview? void?)]
  [nstextview-layout-orientation (c-> nstextview? exact-integer?)]
  [nstextview-layout-subtree-if-needed (c-> nstextview? void?)]
  [nstextview-loosen-kerning (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-lower-baseline (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-lowercase-word (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-magnify-with-event (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-make-backing-layer (c-> nstextview? (or/c calayer? objc-nil?))]
  [nstextview-make-base-writing-direction-left-to-right (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-make-base-writing-direction-natural (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-make-base-writing-direction-right-to-left (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-make-text-writing-direction-left-to-right (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-make-text-writing-direction-natural (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-make-text-writing-direction-right-to-left (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-marked-range (c-> nstextview? any/c)]
  [nstextview-menu-for-event (c-> nstextview? (or/c string? objc-object? #f) (or/c nsmenu? objc-nil?))]
  [nstextview-mouse-in-rect (c-> nstextview? any/c any/c boolean?)]
  [nstextview-mouse-cancelled (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-mouse-down (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-mouse-dragged (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-mouse-entered (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-mouse-exited (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-mouse-moved (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-mouse-up (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-backward! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-backward-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-down! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-down-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-forward! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-forward-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-left! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-left-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-paragraph-backward-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-paragraph-forward-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-right! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-right-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-to-beginning-of-document! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-to-beginning-of-document-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-to-beginning-of-line! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-to-beginning-of-line-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-to-beginning-of-paragraph! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-to-beginning-of-paragraph-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-to-end-of-document! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-to-end-of-document-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-to-end-of-line! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-to-end-of-line-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-to-end-of-paragraph! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-to-end-of-paragraph-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-to-left-end-of-line! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-to-left-end-of-line-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-to-right-end-of-line! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-to-right-end-of-line-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-up! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-up-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-word-backward! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-word-backward-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-word-forward! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-word-forward-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-word-left! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-word-left-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-word-right! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-move-word-right-and-modify-selection! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-needs-to-draw-rect (c-> nstextview? any/c boolean?)]
  [nstextview-no-responder-for (c-> nstextview? string? void?)]
  [nstextview-order-front-link-panel! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-order-front-list-panel! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-order-front-spacing-panel! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-order-front-table-panel! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-other-mouse-down (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-other-mouse-dragged (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-other-mouse-up (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-outline (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-page-down (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-page-down-and-modify-selection (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-page-up (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-page-up-and-modify-selection (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-paste (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-paste-font (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-paste-ruler (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-perform-drag-operation! (c-> nstextview? (or/c string? objc-object? #f) boolean?)]
  [nstextview-perform-find-panel-action! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-perform-key-equivalent! (c-> nstextview? (or/c string? objc-object? #f) boolean?)]
  [nstextview-perform-validated-replacement-in-range-with-attributed-string! (c-> nstextview? any/c (or/c string? objc-object? #f) boolean?)]
  [nstextview-preferred-text-accessory-placement (c-> nstextview? exact-integer?)]
  [nstextview-prepare-content-in-rect (c-> nstextview? any/c void?)]
  [nstextview-prepare-for-drag-operation (c-> nstextview? (or/c string? objc-object? #f) boolean?)]
  [nstextview-prepare-for-reuse (c-> nstextview? void?)]
  [nstextview-pressure-change-with-event (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-quick-look-preview-items (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-quick-look-with-event (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-raise-baseline (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-read-rtfd-from-file (c-> nstextview? (or/c string? objc-object? #f) boolean?)]
  [nstextview-rect-for-smart-magnification-at-point-in-rect (c-> nstextview? any/c any/c any/c)]
  [nstextview-remove-all-tool-tips! (c-> nstextview? void?)]
  [nstextview-remove-from-superview! (c-> nstextview? void?)]
  [nstextview-remove-from-superview-without-needing-display! (c-> nstextview? void?)]
  [nstextview-remove-tool-tip! (c-> nstextview? exact-integer? void?)]
  [nstextview-replace-characters-in-range-with-rtf! (c-> nstextview? any/c (or/c string? objc-object? #f) void?)]
  [nstextview-replace-characters-in-range-with-rtfd! (c-> nstextview? any/c (or/c string? objc-object? #f) void?)]
  [nstextview-replace-characters-in-range-with-string! (c-> nstextview? any/c (or/c string? objc-object? #f) void?)]
  [nstextview-replace-subview-with! (c-> nstextview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstextview-replace-text-container! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-resign-first-responder (c-> nstextview? boolean?)]
  [nstextview-resize-subviews-with-old-size (c-> nstextview? any/c void?)]
  [nstextview-resize-with-old-superview-size (c-> nstextview? any/c void?)]
  [nstextview-restore-user-activity-state (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-right-mouse-down (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-right-mouse-dragged (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-right-mouse-up (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-rotate-by-angle (c-> nstextview? real? void?)]
  [nstextview-rotate-with-event (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-ruler-view-did-add-marker (c-> nstextview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstextview-ruler-view-did-move-marker (c-> nstextview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstextview-ruler-view-did-remove-marker (c-> nstextview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstextview-ruler-view-handle-mouse-down (c-> nstextview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstextview-ruler-view-should-add-marker (c-> nstextview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nstextview-ruler-view-should-move-marker (c-> nstextview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nstextview-ruler-view-should-remove-marker (c-> nstextview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nstextview-ruler-view-will-add-marker-at-location (c-> nstextview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) real? real?)]
  [nstextview-ruler-view-will-move-marker-to-location (c-> nstextview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) real? real?)]
  [nstextview-scale-unit-square-to-size (c-> nstextview? any/c void?)]
  [nstextview-scroll-line-down (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-scroll-line-up (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-scroll-page-down (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-scroll-page-up (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-scroll-point (c-> nstextview? any/c void?)]
  [nstextview-scroll-range-to-visible (c-> nstextview? any/c void?)]
  [nstextview-scroll-rect-to-visible (c-> nstextview? any/c boolean?)]
  [nstextview-scroll-to-beginning-of-document (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-scroll-to-end-of-document (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-scroll-wheel (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-select-all (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-select-line (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-select-paragraph (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-select-to-mark (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-select-word (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-selection-range-for-proposed-range-granularity (c-> nstextview? any/c exact-nonnegative-integer? any/c)]
  [nstextview-set-accessibility-activation-point! (c-> nstextview? any/c void?)]
  [nstextview-set-accessibility-allowed-values! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-alternate-ui-visible! (c-> nstextview? boolean? void?)]
  [nstextview-set-accessibility-application-focused-ui-element! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-attributed-user-input-labels! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-cancel-button! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-children! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-children-in-navigation-order! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-clear-button! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-close-button! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-column-count! (c-> nstextview? exact-integer? void?)]
  [nstextview-set-accessibility-column-header-ui-elements! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-column-index-range! (c-> nstextview? any/c void?)]
  [nstextview-set-accessibility-column-titles! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-columns! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-contents! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-critical-value! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-custom-actions! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-custom-rotors! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-decrement-button! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-default-button! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-disclosed! (c-> nstextview? boolean? void?)]
  [nstextview-set-accessibility-disclosed-by-row! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-disclosed-rows! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-disclosure-level! (c-> nstextview? exact-integer? void?)]
  [nstextview-set-accessibility-document! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-edited! (c-> nstextview? boolean? void?)]
  [nstextview-set-accessibility-element! (c-> nstextview? boolean? void?)]
  [nstextview-set-accessibility-enabled! (c-> nstextview? boolean? void?)]
  [nstextview-set-accessibility-expanded! (c-> nstextview? boolean? void?)]
  [nstextview-set-accessibility-extras-menu-bar! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-filename! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-focused! (c-> nstextview? boolean? void?)]
  [nstextview-set-accessibility-focused-window! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-frame! (c-> nstextview? any/c void?)]
  [nstextview-set-accessibility-frontmost! (c-> nstextview? boolean? void?)]
  [nstextview-set-accessibility-full-screen-button! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-grow-area! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-handles! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-header! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-help! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-hidden! (c-> nstextview? boolean? void?)]
  [nstextview-set-accessibility-horizontal-scroll-bar! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-horizontal-unit-description! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-horizontal-units! (c-> nstextview? exact-integer? void?)]
  [nstextview-set-accessibility-identifier! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-increment-button! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-index! (c-> nstextview? exact-integer? void?)]
  [nstextview-set-accessibility-insertion-point-line-number! (c-> nstextview? exact-integer? void?)]
  [nstextview-set-accessibility-label! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-label-ui-elements! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-label-value! (c-> nstextview? real? void?)]
  [nstextview-set-accessibility-linked-ui-elements! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-main! (c-> nstextview? boolean? void?)]
  [nstextview-set-accessibility-main-window! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-marker-group-ui-element! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-marker-type-description! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-marker-ui-elements! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-marker-values! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-max-value! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-menu-bar! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-min-value! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-minimize-button! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-minimized! (c-> nstextview? boolean? void?)]
  [nstextview-set-accessibility-modal! (c-> nstextview? boolean? void?)]
  [nstextview-set-accessibility-next-contents! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-number-of-characters! (c-> nstextview? exact-integer? void?)]
  [nstextview-set-accessibility-ordered-by-row! (c-> nstextview? boolean? void?)]
  [nstextview-set-accessibility-orientation! (c-> nstextview? exact-integer? void?)]
  [nstextview-set-accessibility-overflow-button! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-parent! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-placeholder-value! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-previous-contents! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-protected-content! (c-> nstextview? boolean? void?)]
  [nstextview-set-accessibility-proxy! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-required! (c-> nstextview? boolean? void?)]
  [nstextview-set-accessibility-role! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-role-description! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-row-count! (c-> nstextview? exact-integer? void?)]
  [nstextview-set-accessibility-row-header-ui-elements! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-row-index-range! (c-> nstextview? any/c void?)]
  [nstextview-set-accessibility-rows! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-ruler-marker-type! (c-> nstextview? exact-integer? void?)]
  [nstextview-set-accessibility-search-button! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-search-menu! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-selected! (c-> nstextview? boolean? void?)]
  [nstextview-set-accessibility-selected-cells! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-selected-children! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-selected-columns! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-selected-rows! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-selected-text! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-selected-text-range! (c-> nstextview? any/c void?)]
  [nstextview-set-accessibility-selected-text-ranges! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-serves-as-title-for-ui-elements! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-shared-character-range! (c-> nstextview? any/c void?)]
  [nstextview-set-accessibility-shared-focus-elements! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-shared-text-ui-elements! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-shown-menu! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-sort-direction! (c-> nstextview? exact-integer? void?)]
  [nstextview-set-accessibility-splitters! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-subrole! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-tabs! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-title! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-title-ui-element! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-toolbar-button! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-top-level-ui-element! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-url! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-unit-description! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-units! (c-> nstextview? exact-integer? void?)]
  [nstextview-set-accessibility-user-input-labels! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-value! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-value-description! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-vertical-scroll-bar! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-vertical-unit-description! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-vertical-units! (c-> nstextview? exact-integer? void?)]
  [nstextview-set-accessibility-visible-cells! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-visible-character-range! (c-> nstextview? any/c void?)]
  [nstextview-set-accessibility-visible-children! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-visible-columns! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-visible-rows! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-warning-value! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-window! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-windows! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-accessibility-zoom-button! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-alignment-range! (c-> nstextview? exact-integer? any/c void?)]
  [nstextview-set-animations! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-appearance! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-base-writing-direction-range! (c-> nstextview? exact-integer? any/c void?)]
  [nstextview-set-bounds-origin! (c-> nstextview? any/c void?)]
  [nstextview-set-bounds-size! (c-> nstextview? any/c void?)]
  [nstextview-set-constrained-frame-size! (c-> nstextview? any/c void?)]
  [nstextview-set-content-type! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-font-range! (c-> nstextview? (or/c string? objc-object? #f) any/c void?)]
  [nstextview-set-frame-origin! (c-> nstextview? any/c void?)]
  [nstextview-set-frame-size! (c-> nstextview? any/c void?)]
  [nstextview-set-identifier! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-layout-orientation! (c-> nstextview? exact-integer? void?)]
  [nstextview-set-mark! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-set-marked-text-selected-range-replacement-range! (c-> nstextview? (or/c string? objc-object? #f) any/c any/c void?)]
  [nstextview-set-needs-display-in-rect! (c-> nstextview? any/c void?)]
  [nstextview-set-needs-display-in-rect-avoid-additional-layout! (c-> nstextview? any/c boolean? void?)]
  [nstextview-set-text-color-range! (c-> nstextview? (or/c string? objc-object? #f) any/c void?)]
  [nstextview-should-be-treated-as-ink-event (c-> nstextview? (or/c string? objc-object? #f) boolean?)]
  [nstextview-should-delay-window-ordering-for-event (c-> nstextview? (or/c string? objc-object? #f) boolean?)]
  [nstextview-show-context-help (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-show-context-menu-for-selection (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-show-guess-panel (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-size-to-fit (c-> nstextview? void?)]
  [nstextview-smart-magnify-with-event (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-sort-subviews-using-function-context (c-> nstextview? (or/c cpointer? #f) (or/c cpointer? #f) void?)]
  [nstextview-start-speaking (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-stop-speaking (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-subscript (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-superscript (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-supplemental-target-for-action-sender (c-> nstextview? string? (or/c string? objc-object? #f) any/c)]
  [nstextview-supports-adaptive-image-glyph (c-> nstextview? boolean?)]
  [nstextview-swap-with-mark (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-swipe-with-event (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-tablet-point (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-tablet-proximity (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-tighten-kerning (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-toggle-ruler! (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-touches-began-with-event (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-touches-cancelled-with-event (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-touches-ended-with-event (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-touches-moved-with-event (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-translate-origin-to-point (c-> nstextview? any/c void?)]
  [nstextview-translate-rects-needing-display-in-rect-by (c-> nstextview? any/c any/c void?)]
  [nstextview-transpose (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-transpose-words (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-try-to-perform-with (c-> nstextview? string? (or/c string? objc-object? #f) boolean?)]
  [nstextview-turn-off-kerning (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-turn-off-ligatures (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-underline (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-union-rect-in-visible-selected-range (c-> nstextview? any/c)]
  [nstextview-unmark-text (c-> nstextview? void?)]
  [nstextview-unscript (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-update-drag-type-registration (c-> nstextview? void?)]
  [nstextview-update-dragging-items-for-drag (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-update-font-panel (c-> nstextview? void?)]
  [nstextview-update-layer (c-> nstextview? void?)]
  [nstextview-update-ruler (c-> nstextview? void?)]
  [nstextview-uppercase-word (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-use-all-ligatures (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-use-standard-kerning (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-use-standard-ligatures (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-valid-attributes-for-marked-text (c-> nstextview? any/c)]
  [nstextview-valid-requestor-for-send-type-return-type (c-> nstextview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nstextview-validate-menu-item (c-> nstextview? (or/c string? objc-object? #f) boolean?)]
  [nstextview-validate-user-interface-item (c-> nstextview? (or/c string? objc-object? #f) boolean?)]
  [nstextview-view-did-change-backing-properties (c-> nstextview? void?)]
  [nstextview-view-did-change-effective-appearance (c-> nstextview? void?)]
  [nstextview-view-did-end-live-resize (c-> nstextview? void?)]
  [nstextview-view-did-hide (c-> nstextview? void?)]
  [nstextview-view-did-move-to-superview (c-> nstextview? void?)]
  [nstextview-view-did-move-to-window (c-> nstextview? void?)]
  [nstextview-view-did-unhide (c-> nstextview? void?)]
  [nstextview-view-will-draw (c-> nstextview? void?)]
  [nstextview-view-will-move-to-superview (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-view-will-move-to-window (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-view-will-start-live-resize (c-> nstextview? void?)]
  [nstextview-view-with-tag (c-> nstextview? exact-integer? any/c)]
  [nstextview-wants-forwarded-scroll-events-for-axis (c-> nstextview? exact-integer? boolean?)]
  [nstextview-wants-periodic-dragging-updates (c-> nstextview? boolean?)]
  [nstextview-wants-scroll-events-for-swipe-tracking-on-axis (c-> nstextview? exact-integer? boolean?)]
  [nstextview-will-open-menu-with-event (c-> nstextview? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nstextview-will-remove-subview (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-window-level (c-> nstextview? exact-integer?)]
  [nstextview-write-rtfd-to-file-atomically (c-> nstextview? (or/c string? objc-object? #f) boolean? boolean?)]
  [nstextview-yank (c-> nstextview? (or/c string? objc-object? #f) void?)]
  [nstextview-default-animation-for-key (c-> (or/c string? objc-object? #f) any/c)]
  [nstextview-is-compatible-with-responsive-scrolling (c-> boolean?)]
  [nstextview-text-view-using-text-layout-manager (c-> boolean? any/c)]
  )

;; --- Class reference ---
(import-class NSTextView)

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
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_b (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPd_d (-> ptr_t ptr_t ptr_t ptr_t double_t double_t))
(define-aw-msg aw_racket_msg_Pb_b (-> ptr_t ptr_t ptr_t bool_t bool_t))
(define-aw-msg aw_racket_msg_Pq_Q (-> ptr_t ptr_t ptr_t int64_t uint64_t))
(define-aw-msg aw_racket_msg_PqP_v (-> ptr_t ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PQ_v (-> ptr_t ptr_t ptr_t uint64_t void_t))
(define-aw-msg aw_racket_msg_PO_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_POQ_v (-> ptr_t ptr_t ptr_t ptr_t uint64_t void_t))
(define-aw-msg aw_racket_msg_PG_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PGG_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_b_P (-> ptr_t ptr_t bool_t ptr_t))
(define-aw-msg aw_racket_msg_b_v (-> ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_q_P (-> ptr_t ptr_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_q_b (-> ptr_t ptr_t int64_t bool_t))
(define-aw-msg aw_racket_msg_q_q (-> ptr_t ptr_t int64_t int64_t))
(define-aw-msg aw_racket_msg_q_G (-> ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_q_v (-> ptr_t ptr_t int64_t void_t))
(define-aw-msg aw_racket_msg_qq_P (-> ptr_t ptr_t int64_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_qG_v (-> ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_Q_b (-> ptr_t ptr_t uint64_t bool_t))
(define-aw-msg aw_racket_msg_Q_d (-> ptr_t ptr_t uint64_t double_t))
(define-aw-msg aw_racket_msg_Q_v (-> ptr_t ptr_t uint64_t void_t))
(define-aw-msg aw_racket_msg_f_v (-> ptr_t ptr_t float_t void_t))
(define-aw-msg aw_racket_msg_d_v (-> ptr_t ptr_t double_t void_t))
(define-aw-msg aw_racket_msg_R_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_R_b (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_R_R (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_R_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_RP_R (-> ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RPP_q (-> ptr_t ptr_t ptr_t ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_RPb_v (-> ptr_t ptr_t ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_Rb_v (-> ptr_t ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_RQ_R (-> ptr_t ptr_t ptr_t uint64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RZ_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_O_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_O_Q (-> ptr_t ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_O_d (-> ptr_t ptr_t ptr_t double_t))
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
(define-aw-msg aw_racket_msg_GP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_GP_b (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_GP_R (-> ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_GP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_GQ_G (-> ptr_t ptr_t ptr_t uint64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_E_v (-> ptr_t ptr_t ptr_t void_t))

;; --- Constructors ---
(define (make-nstextview-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSTextView alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nstextview-init-with-frame frame-rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (tell NSTextView alloc)) (id->ffi2-ptr (sel_registerName "initWithFrame:")) (id->ffi2-ptr frame-rect)))
   #:retained #t))

(define (make-nstextview-init-with-frame-text-container frame-rect container)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_RP_P (id->ffi2-ptr (tell NSTextView alloc)) (id->ffi2-ptr (sel_registerName "initWithFrame:textContainer:")) (id->ffi2-ptr frame-rect) (id->ffi2-ptr (coerce-arg container))))
   #:retained #t))


;; --- Properties ---
(define (nstextview-acceptable-drag-types self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptableDragTypes"))))))
(define (nstextview-accepts-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsFirstResponder"))))
(define (nstextview-accepts-glyph-info self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsGlyphInfo"))))
(define (nstextview-set-accepts-glyph-info! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAcceptsGlyphInfo:")) value))
(define (nstextview-accepts-touch-events self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsTouchEvents"))))
(define (nstextview-set-accepts-touch-events! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAcceptsTouchEvents:")) value))
(define (nstextview-additional-safe-area-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "additionalSafeAreaInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nstextview-set-additional-safe-area-insets! self value)
  (aw_racket_msg_E_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAdditionalSafeAreaInsets:")) (id->ffi2-ptr value)))
(define (nstextview-alignment self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignment"))))
(define (nstextview-set-alignment! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlignment:")) value))
(define (nstextview-alignment-rect-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignmentRectInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nstextview-allowed-input-source-locales self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowedInputSourceLocales"))))))
(define (nstextview-set-allowed-input-source-locales! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowedInputSourceLocales:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-allowed-touch-types self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowedTouchTypes"))))
(define (nstextview-set-allowed-touch-types! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowedTouchTypes:")) value))
(define (nstextview-allowed-writing-tools-result-options self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowedWritingToolsResultOptions"))))
(define (nstextview-set-allowed-writing-tools-result-options! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowedWritingToolsResultOptions:")) value))
(define (nstextview-allows-character-picker-touch-bar-item self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsCharacterPickerTouchBarItem"))))
(define (nstextview-set-allows-character-picker-touch-bar-item! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsCharacterPickerTouchBarItem:")) value))
(define (nstextview-allows-document-background-color-change self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsDocumentBackgroundColorChange"))))
(define (nstextview-set-allows-document-background-color-change! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsDocumentBackgroundColorChange:")) value))
(define (nstextview-allows-image-editing self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsImageEditing"))))
(define (nstextview-set-allows-image-editing! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsImageEditing:")) value))
(define (nstextview-allows-undo self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsUndo"))))
(define (nstextview-set-allows-undo! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsUndo:")) value))
(define (nstextview-allows-vibrancy self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsVibrancy"))))
(define (nstextview-alpha-value self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alphaValue"))))
(define (nstextview-set-alpha-value! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlphaValue:")) value))
(define (nstextview-automatic-dash-substitution-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "automaticDashSubstitutionEnabled"))))
(define (nstextview-set-automatic-dash-substitution-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutomaticDashSubstitutionEnabled:")) value))
(define (nstextview-automatic-data-detection-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "automaticDataDetectionEnabled"))))
(define (nstextview-set-automatic-data-detection-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutomaticDataDetectionEnabled:")) value))
(define (nstextview-automatic-link-detection-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "automaticLinkDetectionEnabled"))))
(define (nstextview-set-automatic-link-detection-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutomaticLinkDetectionEnabled:")) value))
(define (nstextview-automatic-quote-substitution-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "automaticQuoteSubstitutionEnabled"))))
(define (nstextview-set-automatic-quote-substitution-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutomaticQuoteSubstitutionEnabled:")) value))
(define (nstextview-automatic-spelling-correction-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "automaticSpellingCorrectionEnabled"))))
(define (nstextview-set-automatic-spelling-correction-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutomaticSpellingCorrectionEnabled:")) value))
(define (nstextview-automatic-text-completion-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "automaticTextCompletionEnabled"))))
(define (nstextview-set-automatic-text-completion-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutomaticTextCompletionEnabled:")) value))
(define (nstextview-automatic-text-replacement-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "automaticTextReplacementEnabled"))))
(define (nstextview-set-automatic-text-replacement-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutomaticTextReplacementEnabled:")) value))
(define (nstextview-autoresizes-subviews self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoresizesSubviews"))))
(define (nstextview-set-autoresizes-subviews! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutoresizesSubviews:")) value))
(define (nstextview-autoresizing-mask self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoresizingMask"))))
(define (nstextview-set-autoresizing-mask! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutoresizingMask:")) value))
(define (nstextview-background-color self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backgroundColor"))))))
(define (nstextview-set-background-color! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBackgroundColor:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-background-filters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backgroundFilters"))))))
(define (nstextview-set-background-filters! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBackgroundFilters:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-base-writing-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "baseWritingDirection"))))
(define (nstextview-set-base-writing-direction! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBaseWritingDirection:")) value))
(define (nstextview-baseline-offset-from-bottom self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "baselineOffsetFromBottom"))))
(define (nstextview-bottom-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bottomAnchor"))))))
(define (nstextview-bounds self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bounds")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-set-bounds! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBounds:")) (id->ffi2-ptr value)))
(define (nstextview-bounds-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "boundsRotation"))))
(define (nstextview-set-bounds-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsRotation:")) value))
(define (nstextview-can-become-key-view self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canBecomeKeyView"))))
(define (nstextview-can-draw self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDraw"))))
(define (nstextview-can-draw-concurrently self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDrawConcurrently"))))
(define (nstextview-set-can-draw-concurrently! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCanDrawConcurrently:")) value))
(define (nstextview-can-draw-subviews-into-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canDrawSubviewsIntoLayer"))))
(define (nstextview-set-can-draw-subviews-into-layer! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCanDrawSubviewsIntoLayer:")) value))
(define (nstextview-candidate-list-touch-bar-item self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "candidateListTouchBarItem"))))))
(define (nstextview-center-x-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerXAnchor"))))))
(define (nstextview-center-y-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerYAnchor"))))))
(define (nstextview-clips-to-bounds self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "clipsToBounds"))))
(define (nstextview-set-clips-to-bounds! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setClipsToBounds:")) value))
(define (nstextview-coalescing-undo self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "coalescingUndo"))))
(define (nstextview-compatible-with-responsive-scrolling)
  (aw_racket_msg_0_b (id->ffi2-ptr NSTextView) (id->ffi2-ptr (sel_registerName "compatibleWithResponsiveScrolling"))))
(define (nstextview-compositing-filter self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "compositingFilter"))))))
(define (nstextview-set-compositing-filter! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCompositingFilter:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-constraints self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "constraints"))))))
(define (nstextview-content-filters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentFilters"))))))
(define (nstextview-set-content-filters! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentFilters:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-continuous-spell-checking-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "continuousSpellCheckingEnabled"))))
(define (nstextview-set-continuous-spell-checking-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContinuousSpellCheckingEnabled:")) value))
(define (nstextview-default-focus-ring-type)
  (aw_racket_msg_0_Q (id->ffi2-ptr NSTextView) (id->ffi2-ptr (sel_registerName "defaultFocusRingType"))))
(define (nstextview-default-menu)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSTextView) (id->ffi2-ptr (sel_registerName "defaultMenu"))))))
(define (nstextview-default-paragraph-style self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "defaultParagraphStyle"))))))
(define (nstextview-set-default-paragraph-style! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDefaultParagraphStyle:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-delegate self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "delegate"))))))
(define (nstextview-set-delegate! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDelegate:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-displays-link-tool-tips self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displaysLinkToolTips"))))
(define (nstextview-set-displays-link-tool-tips! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDisplaysLinkToolTips:")) value))
(define (nstextview-drawing-find-indicator self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawingFindIndicator"))))
(define (nstextview-draws-background self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawsBackground"))))
(define (nstextview-set-draws-background! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDrawsBackground:")) value))
(define (nstextview-editable self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "editable"))))
(define (nstextview-set-editable! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setEditable:")) value))
(define (nstextview-enabled-text-checking-types self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enabledTextCheckingTypes"))))
(define (nstextview-set-enabled-text-checking-types! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setEnabledTextCheckingTypes:")) value))
(define (nstextview-enclosing-menu-item self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enclosingMenuItem"))))))
(define (nstextview-enclosing-scroll-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enclosingScrollView"))))))
(define (nstextview-field-editor self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fieldEditor"))))
(define (nstextview-set-field-editor! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFieldEditor:")) value))
(define (nstextview-first-baseline-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstBaselineAnchor"))))))
(define (nstextview-first-baseline-offset-from-top self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstBaselineOffsetFromTop"))))
(define (nstextview-fitting-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fittingSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextview-flipped self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flipped"))))
(define (nstextview-focus-ring-mask-bounds self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "focusRingMaskBounds")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-focus-ring-type self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "focusRingType"))))
(define (nstextview-set-focus-ring-type! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFocusRingType:")) value))
(define (nstextview-focus-view)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSTextView) (id->ffi2-ptr (sel_registerName "focusView"))))))
(define (nstextview-font self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "font"))))))
(define (nstextview-set-font! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFont:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-set-frame! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrame:")) (id->ffi2-ptr value)))
(define (nstextview-frame-center-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameCenterRotation"))))
(define (nstextview-set-frame-center-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameCenterRotation:")) value))
(define (nstextview-frame-rotation self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameRotation"))))
(define (nstextview-set-frame-rotation! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameRotation:")) value))
(define (nstextview-gesture-recognizers self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "gestureRecognizers"))))))
(define (nstextview-set-gesture-recognizers! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setGestureRecognizers:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-grammar-checking-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "grammarCheckingEnabled"))))
(define (nstextview-set-grammar-checking-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setGrammarCheckingEnabled:")) value))
(define (nstextview-has-ambiguous-layout self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasAmbiguousLayout"))))
(define (nstextview-height-adjust-limit self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "heightAdjustLimit"))))
(define (nstextview-height-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "heightAnchor"))))))
(define (nstextview-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hidden"))))
(define (nstextview-set-hidden! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHidden:")) value))
(define (nstextview-hidden-or-has-hidden-ancestor self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hiddenOrHasHiddenAncestor"))))
(define (nstextview-horizontal-content-size-constraint-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "horizontalContentSizeConstraintActive"))))
(define (nstextview-set-horizontal-content-size-constraint-active! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHorizontalContentSizeConstraintActive:")) value))
(define (nstextview-horizontally-resizable self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "horizontallyResizable"))))
(define (nstextview-set-horizontally-resizable! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHorizontallyResizable:")) value))
(define (nstextview-imports-graphics self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "importsGraphics"))))
(define (nstextview-set-imports-graphics! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setImportsGraphics:")) value))
(define (nstextview-in-full-screen-mode self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inFullScreenMode"))))
(define (nstextview-in-live-resize self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inLiveResize"))))
(define (nstextview-incremental-searching-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "incrementalSearchingEnabled"))))
(define (nstextview-set-incremental-searching-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIncrementalSearchingEnabled:")) value))
(define (nstextview-inline-prediction-type self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inlinePredictionType"))))
(define (nstextview-set-inline-prediction-type! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setInlinePredictionType:")) value))
(define (nstextview-input-context self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inputContext"))))))
(define (nstextview-insertion-point-color self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertionPointColor"))))))
(define (nstextview-set-insertion-point-color! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setInsertionPointColor:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-intrinsic-content-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "intrinsicContentSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextview-last-baseline-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastBaselineAnchor"))))))
(define (nstextview-last-baseline-offset-from-bottom self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lastBaselineOffsetFromBottom"))))
(define (nstextview-layer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layer"))))))
(define (nstextview-set-layer! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayer:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-layer-contents-placement self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerContentsPlacement"))))
(define (nstextview-set-layer-contents-placement! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerContentsPlacement:")) value))
(define (nstextview-layer-contents-redraw-policy self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerContentsRedrawPolicy"))))
(define (nstextview-set-layer-contents-redraw-policy! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerContentsRedrawPolicy:")) value))
(define (nstextview-layer-uses-core-image-filters self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layerUsesCoreImageFilters"))))
(define (nstextview-set-layer-uses-core-image-filters! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayerUsesCoreImageFilters:")) value))
(define (nstextview-layout-guides self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutGuides"))))))
(define (nstextview-layout-manager self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutManager"))))))
(define (nstextview-layout-margins-guide self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutMarginsGuide"))))))
(define (nstextview-leading-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "leadingAnchor"))))))
(define (nstextview-left-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "leftAnchor"))))))
(define (nstextview-link-text-attributes self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "linkTextAttributes"))))))
(define (nstextview-set-link-text-attributes! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLinkTextAttributes:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-marked-text-attributes self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "markedTextAttributes"))))))
(define (nstextview-set-marked-text-attributes! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMarkedTextAttributes:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-math-expression-completion-type self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mathExpressionCompletionType"))))
(define (nstextview-set-math-expression-completion-type! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMathExpressionCompletionType:")) value))
(define (nstextview-max-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "maxSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextview-set-max-size! self value)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMaxSize:")) (id->ffi2-ptr value)))
(define (nstextview-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menu"))))))
(define (nstextview-set-menu! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMenu:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-min-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "minSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextview-set-min-size! self value)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMinSize:")) (id->ffi2-ptr value)))
(define (nstextview-mouse-down-can-move-window self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDownCanMoveWindow"))))
(define (nstextview-needs-display self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsDisplay"))))
(define (nstextview-set-needs-display! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsDisplay:")) value))
(define (nstextview-needs-layout self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsLayout"))))
(define (nstextview-set-needs-layout! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsLayout:")) value))
(define (nstextview-needs-panel-to-become-key self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsPanelToBecomeKey"))))
(define (nstextview-needs-update-constraints self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsUpdateConstraints"))))
(define (nstextview-set-needs-update-constraints! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsUpdateConstraints:")) value))
(define (nstextview-next-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextKeyView"))))))
(define (nstextview-set-next-key-view! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextKeyView:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-next-responder self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextResponder"))))))
(define (nstextview-set-next-responder! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextResponder:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-next-valid-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextValidKeyView"))))))
(define (nstextview-opaque self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "opaque"))))
(define (nstextview-opaque-ancestor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "opaqueAncestor"))))))
(define (nstextview-page-footer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageFooter"))))))
(define (nstextview-page-header self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageHeader"))))))
(define (nstextview-posts-bounds-changed-notifications self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "postsBoundsChangedNotifications"))))
(define (nstextview-set-posts-bounds-changed-notifications! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPostsBoundsChangedNotifications:")) value))
(define (nstextview-posts-frame-changed-notifications self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "postsFrameChangedNotifications"))))
(define (nstextview-set-posts-frame-changed-notifications! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPostsFrameChangedNotifications:")) value))
(define (nstextview-prefers-compact-control-size-metrics self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prefersCompactControlSizeMetrics"))))
(define (nstextview-set-prefers-compact-control-size-metrics! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPrefersCompactControlSizeMetrics:")) value))
(define (nstextview-prepared-content-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preparedContentRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-set-prepared-content-rect! self value)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPreparedContentRect:")) (id->ffi2-ptr value)))
(define (nstextview-preserves-content-during-live-resize self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preservesContentDuringLiveResize"))))
(define (nstextview-pressure-configuration self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pressureConfiguration"))))))
(define (nstextview-set-pressure-configuration! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPressureConfiguration:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-previous-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "previousKeyView"))))))
(define (nstextview-previous-valid-key-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "previousValidKeyView"))))))
(define (nstextview-print-job-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "printJobTitle"))))))
(define (nstextview-range-for-user-character-attribute-change self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rangeForUserCharacterAttributeChange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextview-range-for-user-completion self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rangeForUserCompletion")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextview-range-for-user-paragraph-attribute-change self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rangeForUserParagraphAttributeChange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextview-range-for-user-text-change self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rangeForUserTextChange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextview-ranges-for-user-character-attribute-change self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rangesForUserCharacterAttributeChange"))))))
(define (nstextview-ranges-for-user-paragraph-attribute-change self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rangesForUserParagraphAttributeChange"))))))
(define (nstextview-ranges-for-user-text-change self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rangesForUserTextChange"))))))
(define (nstextview-readable-pasteboard-types self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "readablePasteboardTypes"))))))
(define (nstextview-rect-preserved-during-live-resize self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectPreservedDuringLiveResize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-registered-dragged-types self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "registeredDraggedTypes"))))))
(define (nstextview-requires-constraint-based-layout)
  (aw_racket_msg_0_b (id->ffi2-ptr NSTextView) (id->ffi2-ptr (sel_registerName "requiresConstraintBasedLayout"))))
(define (nstextview-restorable-state-key-paths)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSTextView) (id->ffi2-ptr (sel_registerName "restorableStateKeyPaths"))))))
(define (nstextview-rich-text self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "richText"))))
(define (nstextview-set-rich-text! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setRichText:")) value))
(define (nstextview-right-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightAnchor"))))))
(define (nstextview-rotated-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotatedFromBase"))))
(define (nstextview-rotated-or-scaled-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotatedOrScaledFromBase"))))
(define (nstextview-ruler-visible self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerVisible"))))
(define (nstextview-set-ruler-visible! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setRulerVisible:")) value))
(define (nstextview-safe-area-insets self)
  (let ([buf (malloc _NSEdgeInsets)])
    (aw_racket_msg_0_E (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaInsets")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSEdgeInsets)))
(define (nstextview-safe-area-layout-guide self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaLayoutGuide"))))))
(define (nstextview-safe-area-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "safeAreaRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-selectable self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectable"))))
(define (nstextview-set-selectable! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSelectable:")) value))
(define (nstextview-selected-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectedRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextview-set-selected-range! self value)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSelectedRange:")) (id->ffi2-ptr value)))
(define (nstextview-selected-ranges self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectedRanges"))))))
(define (nstextview-set-selected-ranges! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSelectedRanges:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-selected-text-attributes self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectedTextAttributes"))))))
(define (nstextview-set-selected-text-attributes! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSelectedTextAttributes:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-selection-affinity self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectionAffinity"))))
(define (nstextview-selection-granularity self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectionGranularity"))))
(define (nstextview-set-selection-granularity! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSelectionGranularity:")) value))
(define (nstextview-shadow self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shadow"))))))
(define (nstextview-set-shadow! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShadow:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-should-draw-insertion-point self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldDrawInsertionPoint"))))
(define (nstextview-smart-insert-delete-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "smartInsertDeleteEnabled"))))
(define (nstextview-set-smart-insert-delete-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSmartInsertDeleteEnabled:")) value))
(define (nstextview-spell-checker-document-tag self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "spellCheckerDocumentTag"))))
(define (nstextview-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "string"))))))
(define (nstextview-set-string! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setString:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-strongly-references-text-storage)
  (aw_racket_msg_0_b (id->ffi2-ptr NSTextView) (id->ffi2-ptr (sel_registerName "stronglyReferencesTextStorage"))))
(define (nstextview-subviews self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "subviews"))))))
(define (nstextview-set-subviews! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSubviews:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-superview self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "superview"))))))
(define (nstextview-tag self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tag"))))
(define (nstextview-text-color self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textColor"))))))
(define (nstextview-set-text-color! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTextColor:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-text-container self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textContainer"))))))
(define (nstextview-set-text-container! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTextContainer:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-text-container-inset self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textContainerInset")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextview-set-text-container-inset! self value)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTextContainerInset:")) (id->ffi2-ptr value)))
(define (nstextview-text-container-origin self)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_0_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textContainerOrigin")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextview-text-content-storage self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textContentStorage"))))))
(define (nstextview-text-highlight-attributes self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textHighlightAttributes"))))))
(define (nstextview-set-text-highlight-attributes! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTextHighlightAttributes:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-text-layout-manager self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textLayoutManager"))))))
(define (nstextview-text-storage self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "textStorage"))))))
(define (nstextview-tool-tip self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "toolTip"))))))
(define (nstextview-set-tool-tip! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setToolTip:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-top-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "topAnchor"))))))
(define (nstextview-touch-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchBar"))))))
(define (nstextview-set-touch-bar! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTouchBar:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-tracking-areas self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "trackingAreas"))))))
(define (nstextview-trailing-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "trailingAnchor"))))))
(define (nstextview-translates-autoresizing-mask-into-constraints self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translatesAutoresizingMaskIntoConstraints"))))
(define (nstextview-set-translates-autoresizing-mask-into-constraints! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTranslatesAutoresizingMaskIntoConstraints:")) value))
(define (nstextview-typing-attributes self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "typingAttributes"))))))
(define (nstextview-set-typing-attributes! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTypingAttributes:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-undo-manager self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "undoManager"))))))
(define (nstextview-user-activity self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userActivity"))))))
(define (nstextview-set-user-activity! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserActivity:")) (id->ffi2-ptr (coerce-arg value))))
(define (nstextview-user-interface-layout-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userInterfaceLayoutDirection"))))
(define (nstextview-set-user-interface-layout-direction! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserInterfaceLayoutDirection:")) value))
(define (nstextview-uses-adaptive-color-mapping-for-dark-appearance self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "usesAdaptiveColorMappingForDarkAppearance"))))
(define (nstextview-set-uses-adaptive-color-mapping-for-dark-appearance! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUsesAdaptiveColorMappingForDarkAppearance:")) value))
(define (nstextview-uses-find-bar self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "usesFindBar"))))
(define (nstextview-set-uses-find-bar! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUsesFindBar:")) value))
(define (nstextview-uses-find-panel self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "usesFindPanel"))))
(define (nstextview-set-uses-find-panel! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUsesFindPanel:")) value))
(define (nstextview-uses-font-panel self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "usesFontPanel"))))
(define (nstextview-set-uses-font-panel! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUsesFontPanel:")) value))
(define (nstextview-uses-inspector-bar self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "usesInspectorBar"))))
(define (nstextview-set-uses-inspector-bar! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUsesInspectorBar:")) value))
(define (nstextview-uses-rollover-button-for-selection self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "usesRolloverButtonForSelection"))))
(define (nstextview-set-uses-rollover-button-for-selection! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUsesRolloverButtonForSelection:")) value))
(define (nstextview-uses-ruler self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "usesRuler"))))
(define (nstextview-set-uses-ruler! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUsesRuler:")) value))
(define (nstextview-vertical-content-size-constraint-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "verticalContentSizeConstraintActive"))))
(define (nstextview-set-vertical-content-size-constraint-active! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setVerticalContentSizeConstraintActive:")) value))
(define (nstextview-vertically-resizable self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "verticallyResizable"))))
(define (nstextview-set-vertically-resizable! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setVerticallyResizable:")) value))
(define (nstextview-visible-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "visibleRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-wants-best-resolution-open-gl-surface self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsBestResolutionOpenGLSurface"))))
(define (nstextview-set-wants-best-resolution-open-gl-surface! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsBestResolutionOpenGLSurface:")) value))
(define (nstextview-wants-default-clipping self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsDefaultClipping"))))
(define (nstextview-wants-extended-dynamic-range-open-gl-surface self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsExtendedDynamicRangeOpenGLSurface"))))
(define (nstextview-set-wants-extended-dynamic-range-open-gl-surface! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsExtendedDynamicRangeOpenGLSurface:")) value))
(define (nstextview-wants-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsLayer"))))
(define (nstextview-set-wants-layer! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsLayer:")) value))
(define (nstextview-wants-resting-touches self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsRestingTouches"))))
(define (nstextview-set-wants-resting-touches! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWantsRestingTouches:")) value))
(define (nstextview-wants-update-layer self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsUpdateLayer"))))
(define (nstextview-width-adjust-limit self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "widthAdjustLimit"))))
(define (nstextview-width-anchor self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "widthAnchor"))))))
(define (nstextview-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "window"))))))
(define (nstextview-writable-pasteboard-types self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writablePasteboardTypes"))))))
(define (nstextview-writing-tools-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writingToolsActive"))))
(define (nstextview-writing-tools-behavior self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writingToolsBehavior"))))
(define (nstextview-set-writing-tools-behavior! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWritingToolsBehavior:")) value))
(define (nstextview-writing-tools-coordinator self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writingToolsCoordinator"))))))
(define (nstextview-set-writing-tools-coordinator! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWritingToolsCoordinator:")) (id->ffi2-ptr (coerce-arg value))))

;; --- Instance methods ---
(define (nstextview-rtfd-from-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "RTFDFromRange:")) (id->ffi2-ptr range)))
   ))
(define (nstextview-rtf-from-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "RTFFromRange:")) (id->ffi2-ptr range)))
   ))
(define (nstextview-accepts-first-mouse self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsFirstMouse:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-accessibility-activation-point self)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_0_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityActivationPoint")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextview-accessibility-allowed-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAllowedValues"))))
   ))
(define (nstextview-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityApplicationFocusedUIElement"))))
   ))
(define (nstextview-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nstextview-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedUserInputLabels"))))
   ))
(define (nstextview-accessibility-cancel-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCancelButton"))))
   ))
(define (nstextview-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_qq_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCellForColumn:row:")) column row))
   ))
(define (nstextview-accessibility-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildren"))))
   ))
(define (nstextview-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildrenInNavigationOrder"))))
   ))
(define (nstextview-accessibility-clear-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityClearButton"))))
   ))
(define (nstextview-accessibility-close-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCloseButton"))))
   ))
(define (nstextview-accessibility-column-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnCount"))))
(define (nstextview-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnHeaderUIElements"))))
   ))
(define (nstextview-accessibility-column-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextview-accessibility-column-titles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnTitles"))))
   ))
(define (nstextview-accessibility-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumns"))))
   ))
(define (nstextview-accessibility-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityContents"))))
   ))
(define (nstextview-accessibility-critical-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCriticalValue"))))
   ))
(define (nstextview-accessibility-custom-actions self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomActions"))))
   ))
(define (nstextview-accessibility-custom-rotors self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomRotors"))))
   ))
(define (nstextview-accessibility-decrement-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDecrementButton"))))
   ))
(define (nstextview-accessibility-default-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDefaultButton"))))
   ))
(define (nstextview-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedByRow"))))
   ))
(define (nstextview-accessibility-disclosed-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedRows"))))
   ))
(define (nstextview-accessibility-disclosure-level self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosureLevel"))))
(define (nstextview-accessibility-document self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDocument"))))
   ))
(define (nstextview-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityExtrasMenuBar"))))
   ))
(define (nstextview-accessibility-filename self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFilename"))))
   ))
(define (nstextview-accessibility-focused-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFocusedWindow"))))
   ))
(define (nstextview-accessibility-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-accessibility-frame-for-range self range)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_G_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrameForRange:")) (id->ffi2-ptr range) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-accessibility-full-screen-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFullScreenButton"))))
   ))
(define (nstextview-accessibility-grow-area self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityGrowArea"))))
   ))
(define (nstextview-accessibility-handles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHandles"))))
   ))
(define (nstextview-accessibility-header self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHeader"))))
   ))
(define (nstextview-accessibility-help self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHelp"))))
   ))
(define (nstextview-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalScrollBar"))))
   ))
(define (nstextview-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnitDescription"))))
   ))
(define (nstextview-accessibility-horizontal-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnits"))))
(define (nstextview-accessibility-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIdentifier"))))
   ))
(define (nstextview-accessibility-increment-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIncrementButton"))))
   ))
(define (nstextview-accessibility-index self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIndex"))))
(define (nstextview-accessibility-insertion-point-line-number self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityInsertionPointLineNumber"))))
(define (nstextview-accessibility-label self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabel"))))
   ))
(define (nstextview-accessibility-label-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelUIElements"))))
   ))
(define (nstextview-accessibility-label-value self)
  (aw_racket_msg_0_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelValue"))))
(define (nstextview-accessibility-layout-point-for-screen-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutPointForScreenPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextview-accessibility-layout-size-for-screen-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutSizeForScreenSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextview-accessibility-line-for-index self index)
  (aw_racket_msg_q_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLineForIndex:")) index))
(define (nstextview-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLinkedUIElements"))))
   ))
(define (nstextview-accessibility-main-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMainWindow"))))
   ))
(define (nstextview-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerGroupUIElement"))))
   ))
(define (nstextview-accessibility-marker-type-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerTypeDescription"))))
   ))
(define (nstextview-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerUIElements"))))
   ))
(define (nstextview-accessibility-marker-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerValues"))))
   ))
(define (nstextview-accessibility-max-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMaxValue"))))
   ))
(define (nstextview-accessibility-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMenuBar"))))
   ))
(define (nstextview-accessibility-min-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinValue"))))
   ))
(define (nstextview-accessibility-minimize-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinimizeButton"))))
   ))
(define (nstextview-accessibility-next-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNextContents"))))
   ))
(define (nstextview-accessibility-number-of-characters self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNumberOfCharacters"))))
(define (nstextview-accessibility-orientation self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOrientation"))))
(define (nstextview-accessibility-overflow-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOverflowButton"))))
   ))
(define (nstextview-accessibility-parent self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityParent"))))
   ))
(define (nstextview-accessibility-perform-cancel self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformCancel"))))
(define (nstextview-accessibility-perform-confirm self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformConfirm"))))
(define (nstextview-accessibility-perform-decrement self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDecrement"))))
(define (nstextview-accessibility-perform-delete self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDelete"))))
(define (nstextview-accessibility-perform-increment self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformIncrement"))))
(define (nstextview-accessibility-perform-pick self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPick"))))
(define (nstextview-accessibility-perform-press self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPress"))))
(define (nstextview-accessibility-perform-raise self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformRaise"))))
(define (nstextview-accessibility-perform-show-alternate-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowAlternateUI"))))
(define (nstextview-accessibility-perform-show-default-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowDefaultUI"))))
(define (nstextview-accessibility-perform-show-menu self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowMenu"))))
(define (nstextview-accessibility-placeholder-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPlaceholderValue"))))
   ))
(define (nstextview-accessibility-previous-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPreviousContents"))))
   ))
(define (nstextview-accessibility-proxy self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityProxy"))))
   ))
(define (nstextview-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRTFForRange:")) (id->ffi2-ptr range)))
   ))
(define (nstextview-accessibility-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextview-accessibility-range-for-line self line-number)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForLine:")) line-number (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextview-accessibility-range-for-position self point)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_O_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForPosition:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextview-accessibility-role self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRole"))))
   ))
(define (nstextview-accessibility-role-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRoleDescription"))))
   ))
(define (nstextview-accessibility-row-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowCount"))))
(define (nstextview-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowHeaderUIElements"))))
   ))
(define (nstextview-accessibility-row-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextview-accessibility-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRows"))))
   ))
(define (nstextview-accessibility-ruler-marker-type self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRulerMarkerType"))))
(define (nstextview-accessibility-screen-point-for-layout-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenPointForLayoutPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextview-accessibility-screen-size-for-layout-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenSizeForLayoutSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextview-accessibility-search-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchButton"))))
   ))
(define (nstextview-accessibility-search-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchMenu"))))
   ))
(define (nstextview-accessibility-selected-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedCells"))))
   ))
(define (nstextview-accessibility-selected-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedChildren"))))
   ))
(define (nstextview-accessibility-selected-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedColumns"))))
   ))
(define (nstextview-accessibility-selected-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedRows"))))
   ))
(define (nstextview-accessibility-selected-text self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedText"))))
   ))
(define (nstextview-accessibility-selected-text-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextview-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRanges"))))
   ))
(define (nstextview-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityServesAsTitleForUIElements"))))
   ))
(define (nstextview-accessibility-shared-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextview-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedFocusElements"))))
   ))
(define (nstextview-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedTextUIElements"))))
   ))
(define (nstextview-accessibility-shown-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityShownMenu"))))
   ))
(define (nstextview-accessibility-sort-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySortDirection"))))
(define (nstextview-accessibility-splitters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySplitters"))))
   ))
(define (nstextview-accessibility-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nstextview-accessibility-style-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStyleRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextview-accessibility-subrole self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySubrole"))))
   ))
(define (nstextview-accessibility-tabs self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTabs"))))
   ))
(define (nstextview-accessibility-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitle"))))
   ))
(define (nstextview-accessibility-title-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitleUIElement"))))
   ))
(define (nstextview-accessibility-toolbar-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityToolbarButton"))))
   ))
(define (nstextview-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTopLevelUIElement"))))
   ))
(define (nstextview-accessibility-url self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityURL"))))
   ))
(define (nstextview-accessibility-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnitDescription"))))
   ))
(define (nstextview-accessibility-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnits"))))
(define (nstextview-accessibility-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUserInputLabels"))))
   ))
(define (nstextview-accessibility-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValue"))))
   ))
(define (nstextview-accessibility-value-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValueDescription"))))
   ))
(define (nstextview-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalScrollBar"))))
   ))
(define (nstextview-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnitDescription"))))
   ))
(define (nstextview-accessibility-vertical-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnits"))))
(define (nstextview-accessibility-visible-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCells"))))
   ))
(define (nstextview-accessibility-visible-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextview-accessibility-visible-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleChildren"))))
   ))
(define (nstextview-accessibility-visible-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleColumns"))))
   ))
(define (nstextview-accessibility-visible-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleRows"))))
   ))
(define (nstextview-accessibility-warning-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWarningValue"))))
   ))
(define (nstextview-accessibility-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindow"))))
   ))
(define (nstextview-accessibility-windows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindows"))))
   ))
(define (nstextview-accessibility-zoom-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityZoomButton"))))
   ))
(define (nstextview-add-subview! self view)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addSubview:")) (id->ffi2-ptr (coerce-arg view))))
(define (nstextview-add-subview-positioned-relative-to! self view place other-view)
  (aw_racket_msg_PqP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addSubview:positioned:relativeTo:")) (id->ffi2-ptr (coerce-arg view)) place (id->ffi2-ptr (coerce-arg other-view))))
(define (nstextview-add-tool-tip-rect-owner-user-data! self rect owner data)
  (aw_racket_msg_RPP_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addToolTipRect:owner:userData:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg owner)) (id->ffi2-ptr data)))
(define (nstextview-adjust-scroll self new-visible)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "adjustScroll:")) (id->ffi2-ptr new-visible) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-align-center self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignCenter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-align-justified self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignJustified:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-align-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-align-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alignRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-ancestor-shared-with-view self view)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "ancestorSharedWithView:")) (id->ffi2-ptr (coerce-arg view))))
   ))
(define (nstextview-animation-for-key self key)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animationForKey:")) (id->ffi2-ptr (coerce-arg key))))
   ))
(define (nstextview-animations self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animations"))))
   ))
(define (nstextview-animator self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animator"))))
   ))
(define (nstextview-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "appearance"))))
   ))
(define (nstextview-attributed-string self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "attributedString"))))
   ))
(define (nstextview-attributed-substring-for-proposed-range-actual-range self range actual-range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_GP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "attributedSubstringForProposedRange:actualRange:")) (id->ffi2-ptr range) (id->ffi2-ptr actual-range)))
   ))
(define (nstextview-autoscroll self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoscroll:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-backing-aligned-rect-options self rect options)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RQ_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backingAlignedRect:options:")) (id->ffi2-ptr rect) options (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-baseline-delta-for-character-at-index self an-index)
  (aw_racket_msg_Q_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "baselineDeltaForCharacterAtIndex:")) an-index))
(define (nstextview-become-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "becomeFirstResponder"))))
(define (nstextview-begin-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-bitmap-image-rep-for-caching-display-in-rect self rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "bitmapImageRepForCachingDisplayInRect:")) (id->ffi2-ptr rect)))
   ))
(define (nstextview-cache-display-in-rect-to-bitmap-image-rep self rect bitmap-image-rep)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cacheDisplayInRect:toBitmapImageRep:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg bitmap-image-rep))))
(define (nstextview-cancel-operation self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cancelOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-capitalize-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "capitalizeWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-center-scan-rect! self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerScanRect:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-center-selection-in-visible-area! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerSelectionInVisibleArea:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-change-attributes self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeAttributes:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-change-case-of-letter self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeCaseOfLetter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-change-color self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeColor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-change-document-background-color self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeDocumentBackgroundColor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-change-font self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeFont:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-change-layout-orientation self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeLayoutOrientation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-change-mode-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeModeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-change-spelling self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeSpelling:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-character-index-for-insertion-at-point self point)
  (aw_racket_msg_O_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "characterIndexForInsertionAtPoint:")) (id->ffi2-ptr point)))
(define (nstextview-character-index-for-point self point)
  (aw_racket_msg_O_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "characterIndexForPoint:")) (id->ffi2-ptr point)))
(define (nstextview-check-spelling self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "checkSpelling:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-clicked-on-link-at-index self link char-index)
  (aw_racket_msg_PQ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "clickedOnLink:atIndex:")) (id->ffi2-ptr (coerce-arg link)) char-index))
(define (nstextview-complete self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "complete:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-conclude-drag-operation self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "concludeDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-content-type self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentType"))))
   ))
(define (nstextview-context-menu-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contextMenuKeyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-convert-point-from-view self point view)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_OP_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPoint:fromView:")) (id->ffi2-ptr point) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextview-convert-point-to-view self point view)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_OP_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPoint:toView:")) (id->ffi2-ptr point) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextview-convert-point-from-backing self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointFromBacking:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextview-convert-point-from-layer self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointFromLayer:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextview-convert-point-to-backing self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointToBacking:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextview-convert-point-to-layer self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointToLayer:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nstextview-convert-rect-from-view self rect view)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RP_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRect:fromView:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-convert-rect-to-view self rect view)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RP_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRect:toView:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-convert-rect-from-backing self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectFromBacking:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-convert-rect-from-layer self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectFromLayer:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-convert-rect-to-backing self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectToBacking:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-convert-rect-to-layer self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectToLayer:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-convert-size-from-view self size view)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_ZP_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSize:fromView:")) (id->ffi2-ptr size) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextview-convert-size-to-view self size view)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_ZP_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSize:toView:")) (id->ffi2-ptr size) (id->ffi2-ptr (coerce-arg view)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextview-convert-size-from-backing self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeFromBacking:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextview-convert-size-from-layer self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeFromLayer:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextview-convert-size-to-backing self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeToBacking:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextview-convert-size-to-layer self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertSizeToLayer:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nstextview-copy self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "copy:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-copy-font self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "copyFont:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-copy-ruler self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "copyRuler:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-cursor-update self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cursorUpdate:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-cut self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cut:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-delete self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "delete:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-delete-backward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-delete-backward-by-decomposing-previous-character self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteBackwardByDecomposingPreviousCharacter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-delete-forward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-delete-to-beginning-of-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToBeginningOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-delete-to-beginning-of-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToBeginningOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-delete-to-end-of-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-delete-to-end-of-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToEndOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-delete-to-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-delete-word-backward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteWordBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-delete-word-forward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteWordForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-did-add-subview self subview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "didAddSubview:")) (id->ffi2-ptr (coerce-arg subview))))
(define (nstextview-did-close-menu-with-event self menu event)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "didCloseMenu:withEvent:")) (id->ffi2-ptr (coerce-arg menu)) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-display! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "display"))))
(define (nstextview-display-if-needed! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeeded"))))
(define (nstextview-display-if-needed-ignoring-opacity! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededIgnoringOpacity"))))
(define (nstextview-display-if-needed-in-rect! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededInRect:")) (id->ffi2-ptr rect)))
(define (nstextview-display-if-needed-in-rect-ignoring-opacity! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeededInRectIgnoringOpacity:")) (id->ffi2-ptr rect)))
(define (nstextview-display-rect! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRect:")) (id->ffi2-ptr rect)))
(define (nstextview-display-rect-ignoring-opacity! self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRectIgnoringOpacity:")) (id->ffi2-ptr rect)))
(define (nstextview-display-rect-ignoring-opacity-in-context! self rect context)
  (aw_racket_msg_RP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayRectIgnoringOpacity:inContext:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg context))))
(define (nstextview-do-command-by-selector self selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "doCommandBySelector:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nstextview-document-visible-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "documentVisibleRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-dragging-ended self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingEnded:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-dragging-entered self sender)
  (aw_racket_msg_P_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingEntered:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-dragging-exited self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingExited:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-dragging-session-ended-at-point-operation self session screen-point operation)
  (aw_racket_msg_POQ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingSession:endedAtPoint:operation:")) (id->ffi2-ptr (coerce-arg session)) (id->ffi2-ptr screen-point) operation))
(define (nstextview-dragging-session-moved-to-point self session screen-point)
  (aw_racket_msg_PO_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingSession:movedToPoint:")) (id->ffi2-ptr (coerce-arg session)) (id->ffi2-ptr screen-point)))
(define (nstextview-dragging-session-source-operation-mask-for-dragging-context self session context)
  (aw_racket_msg_Pq_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingSession:sourceOperationMaskForDraggingContext:")) (id->ffi2-ptr (coerce-arg session)) context))
(define (nstextview-dragging-session-will-begin-at-point self session screen-point)
  (aw_racket_msg_PO_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingSession:willBeginAtPoint:")) (id->ffi2-ptr (coerce-arg session)) (id->ffi2-ptr screen-point)))
(define (nstextview-dragging-updated self sender)
  (aw_racket_msg_P_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "draggingUpdated:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-draw-insertion-point-in-rect-color-turned-on self rect color flag)
  (aw_racket_msg_RPb_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawInsertionPointInRect:color:turnedOn:")) (id->ffi2-ptr rect) (id->ffi2-ptr (coerce-arg color)) flag))
(define (nstextview-draw-rect self dirty-rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawRect:")) (id->ffi2-ptr dirty-rect)))
(define (nstextview-draw-view-background-in-rect self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawViewBackgroundInRect:")) (id->ffi2-ptr rect)))
(define (nstextview-draws-vertically-for-character-at-index self char-index)
  (aw_racket_msg_Q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawsVerticallyForCharacterAtIndex:")) char-index))
(define (nstextview-effective-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "effectiveAppearance"))))
   ))
(define (nstextview-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nstextview-end-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-first-rect-for-character-range-actual-range self range actual-range)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_GP_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstRectForCharacterRange:actualRange:")) (id->ffi2-ptr range) (id->ffi2-ptr actual-range) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-flags-changed self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flagsChanged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-flush-buffered-key-events self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flushBufferedKeyEvents"))))
(define (nstextview-fraction-of-distance-through-glyph-for-point self point)
  (aw_racket_msg_O_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fractionOfDistanceThroughGlyphForPoint:")) (id->ffi2-ptr point)))
(define (nstextview-get-rects-being-drawn-count self rects count)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getRectsBeingDrawn:count:")) (id->ffi2-ptr rects) (id->ffi2-ptr count)))
(define (nstextview-get-rects-exposed-during-live-resize-count self exposed-rects count)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "getRectsExposedDuringLiveResize:count:")) (id->ffi2-ptr exposed-rects) (id->ffi2-ptr count)))
(define (nstextview-has-marked-text self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasMarkedText"))))
(define (nstextview-help-requested self event-ptr)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "helpRequested:")) (id->ffi2-ptr (coerce-arg event-ptr))))
(define (nstextview-hit-test self point)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_O_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hitTest:")) (id->ffi2-ptr point)))
   ))
(define (nstextview-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "identifier"))))
   ))
(define (nstextview-ignore-modifier-keys-for-dragging-session self session)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "ignoreModifierKeysForDraggingSession:")) (id->ffi2-ptr (coerce-arg session))))
(define (nstextview-ignore-spelling self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "ignoreSpelling:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-indent self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indent:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-init-using-text-layout-manager self using-text-layout-manager)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_b_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "initUsingTextLayoutManager:")) using-text-layout-manager))
   #:retained #t))
(define (nstextview-insert-adaptive-image-glyph-replacement-range! self adaptive-image-glyph replacement-range)
  (aw_racket_msg_PG_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertAdaptiveImageGlyph:replacementRange:")) (id->ffi2-ptr (coerce-arg adaptive-image-glyph)) (id->ffi2-ptr replacement-range)))
(define (nstextview-insert-backtab! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertBacktab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-insert-container-break! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertContainerBreak:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-insert-double-quote-ignoring-substitution! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertDoubleQuoteIgnoringSubstitution:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-insert-line-break! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertLineBreak:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-insert-newline! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertNewline:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-insert-newline-ignoring-field-editor! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertNewlineIgnoringFieldEditor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-insert-paragraph-separator! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertParagraphSeparator:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-insert-single-quote-ignoring-substitution! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertSingleQuoteIgnoringSubstitution:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-insert-tab! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-insert-tab-ignoring-field-editor! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTabIgnoringFieldEditor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-insert-text-replacement-range! self string replacement-range)
  (aw_racket_msg_PG_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertText:replacementRange:")) (id->ffi2-ptr (coerce-arg string)) (id->ffi2-ptr replacement-range)))
(define (nstextview-interpret-key-events self event-array)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "interpretKeyEvents:")) (id->ffi2-ptr (coerce-arg event-array))))
(define (nstextview-invalidate-text-container-origin self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "invalidateTextContainerOrigin"))))
(define (nstextview-is-accessibility-alternate-ui-visible self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityAlternateUIVisible"))))
(define (nstextview-is-accessibility-disclosed self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityDisclosed"))))
(define (nstextview-is-accessibility-edited self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEdited"))))
(define (nstextview-is-accessibility-element self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityElement"))))
(define (nstextview-is-accessibility-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEnabled"))))
(define (nstextview-is-accessibility-expanded self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityExpanded"))))
(define (nstextview-is-accessibility-focused self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFocused"))))
(define (nstextview-is-accessibility-frontmost self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFrontmost"))))
(define (nstextview-is-accessibility-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityHidden"))))
(define (nstextview-is-accessibility-main self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMain"))))
(define (nstextview-is-accessibility-minimized self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMinimized"))))
(define (nstextview-is-accessibility-modal self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityModal"))))
(define (nstextview-is-accessibility-ordered-by-row self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityOrderedByRow"))))
(define (nstextview-is-accessibility-protected-content self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityProtectedContent"))))
(define (nstextview-is-accessibility-required self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityRequired"))))
(define (nstextview-is-accessibility-selected self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelected"))))
(define (nstextview-is-accessibility-selector-allowed self selector)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelectorAllowed:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nstextview-is-descendant-of self view)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isDescendantOf:")) (id->ffi2-ptr (coerce-arg view))))
(define (nstextview-is-editable self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isEditable"))))
(define (nstextview-is-field-editor self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isFieldEditor"))))
(define (nstextview-is-flipped self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isFlipped"))))
(define (nstextview-is-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHidden"))))
(define (nstextview-is-hidden-or-has-hidden-ancestor self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHiddenOrHasHiddenAncestor"))))
(define (nstextview-is-horizontally-resizable self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHorizontallyResizable"))))
(define (nstextview-is-opaque self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isOpaque"))))
(define (nstextview-is-rich-text self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRichText"))))
(define (nstextview-is-rotated-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRotatedFromBase"))))
(define (nstextview-is-rotated-or-scaled-from-base self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRotatedOrScaledFromBase"))))
(define (nstextview-is-ruler-visible self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRulerVisible"))))
(define (nstextview-is-selectable self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isSelectable"))))
(define (nstextview-is-vertically-resizable self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isVerticallyResizable"))))
(define (nstextview-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-key-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-layout self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layout"))))
(define (nstextview-layout-orientation self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutOrientation"))))
(define (nstextview-layout-subtree-if-needed self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "layoutSubtreeIfNeeded"))))
(define (nstextview-loosen-kerning self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "loosenKerning:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-lower-baseline self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lowerBaseline:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-lowercase-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lowercaseWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "magnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-make-backing-layer self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBackingLayer"))))
   ))
(define (nstextview-make-base-writing-direction-left-to-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionLeftToRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-make-base-writing-direction-natural self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionNatural:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-make-base-writing-direction-right-to-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionRightToLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-make-text-writing-direction-left-to-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionLeftToRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-make-text-writing-direction-natural self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionNatural:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-make-text-writing-direction-right-to-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionRightToLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-marked-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "markedRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextview-menu-for-event self event)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menuForEvent:")) (id->ffi2-ptr (coerce-arg event))))
   ))
(define (nstextview-mouse-in-rect self point rect)
  (aw_racket_msg_OR_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouse:inRect:")) (id->ffi2-ptr point) (id->ffi2-ptr rect)))
(define (nstextview-mouse-cancelled self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseCancelled:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-mouse-entered self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseEntered:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-mouse-exited self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseExited:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-mouse-moved self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseMoved:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-move-backward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-down! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-down-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveDownAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-forward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-left! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-left-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveLeftAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-paragraph-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveParagraphBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-paragraph-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveParagraphForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-right! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-right-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRightAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-to-beginning-of-document! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-to-beginning-of-document-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfDocumentAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-to-beginning-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-to-beginning-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-to-beginning-of-paragraph! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfParagraphAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-to-end-of-document! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-to-end-of-document-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfDocumentAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-to-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-to-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-to-end-of-paragraph! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-to-end-of-paragraph-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfParagraphAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-to-left-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToLeftEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-to-left-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToLeftEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-to-right-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToRightEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-to-right-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToRightEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-up! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-up-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveUpAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-word-backward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-word-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-word-forward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-word-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-word-left! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-word-left-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordLeftAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-word-right! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-move-word-right-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordRightAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-needs-to-draw-rect self rect)
  (aw_racket_msg_R_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "needsToDrawRect:")) (id->ffi2-ptr rect)))
(define (nstextview-no-responder-for self event-selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "noResponderFor:")) (id->ffi2-ptr (sel_registerName event-selector))))
(define (nstextview-order-front-link-panel! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orderFrontLinkPanel:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-order-front-list-panel! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orderFrontListPanel:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-order-front-spacing-panel! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orderFrontSpacingPanel:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-order-front-table-panel! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orderFrontTablePanel:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-other-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-other-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-other-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-outline self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "outline:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-page-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-page-down-and-modify-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageDownAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-page-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-page-up-and-modify-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageUpAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-paste self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "paste:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-paste-font self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pasteFont:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-paste-ruler self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pasteRuler:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-perform-drag-operation! self sender)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-perform-find-panel-action! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performFindPanelAction:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-perform-key-equivalent! self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performKeyEquivalent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-perform-validated-replacement-in-range-with-attributed-string! self range attributed-string)
  (aw_racket_msg_GP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performValidatedReplacementInRange:withAttributedString:")) (id->ffi2-ptr range) (id->ffi2-ptr (coerce-arg attributed-string))))
(define (nstextview-preferred-text-accessory-placement self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preferredTextAccessoryPlacement"))))
(define (nstextview-prepare-content-in-rect self rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareContentInRect:")) (id->ffi2-ptr rect)))
(define (nstextview-prepare-for-drag-operation self sender)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareForDragOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-prepare-for-reuse self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareForReuse"))))
(define (nstextview-pressure-change-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pressureChangeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-quick-look-preview-items self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookPreviewItems:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-quick-look-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-raise-baseline self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "raiseBaseline:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-read-rtfd-from-file self path)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "readRTFDFromFile:")) (id->ffi2-ptr (coerce-arg path))))
(define (nstextview-rect-for-smart-magnification-at-point-in-rect self location visible-rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_OR_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rectForSmartMagnificationAtPoint:inRect:")) (id->ffi2-ptr location) (id->ffi2-ptr visible-rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-remove-all-tool-tips! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeAllToolTips"))))
(define (nstextview-remove-from-superview! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeFromSuperview"))))
(define (nstextview-remove-from-superview-without-needing-display! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeFromSuperviewWithoutNeedingDisplay"))))
(define (nstextview-remove-tool-tip! self tag)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeToolTip:")) tag))
(define (nstextview-replace-characters-in-range-with-rtf! self range rtf-data)
  (aw_racket_msg_GP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "replaceCharactersInRange:withRTF:")) (id->ffi2-ptr range) (id->ffi2-ptr (coerce-arg rtf-data))))
(define (nstextview-replace-characters-in-range-with-rtfd! self range rtfd-data)
  (aw_racket_msg_GP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "replaceCharactersInRange:withRTFD:")) (id->ffi2-ptr range) (id->ffi2-ptr (coerce-arg rtfd-data))))
(define (nstextview-replace-characters-in-range-with-string! self range string)
  (aw_racket_msg_GP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "replaceCharactersInRange:withString:")) (id->ffi2-ptr range) (id->ffi2-ptr (coerce-arg string))))
(define (nstextview-replace-subview-with! self old-view new-view)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "replaceSubview:with:")) (id->ffi2-ptr (coerce-arg old-view)) (id->ffi2-ptr (coerce-arg new-view))))
(define (nstextview-replace-text-container! self new-container)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "replaceTextContainer:")) (id->ffi2-ptr (coerce-arg new-container))))
(define (nstextview-resign-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resignFirstResponder"))))
(define (nstextview-resize-subviews-with-old-size self old-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resizeSubviewsWithOldSize:")) (id->ffi2-ptr old-size)))
(define (nstextview-resize-with-old-superview-size self old-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resizeWithOldSuperviewSize:")) (id->ffi2-ptr old-size)))
(define (nstextview-restore-user-activity-state self user-activity)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "restoreUserActivityState:")) (id->ffi2-ptr (coerce-arg user-activity))))
(define (nstextview-right-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-right-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-right-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-rotate-by-angle self angle)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotateByAngle:")) angle))
(define (nstextview-rotate-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotateWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-ruler-view-did-add-marker self ruler marker)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:didAddMarker:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker))))
(define (nstextview-ruler-view-did-move-marker self ruler marker)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:didMoveMarker:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker))))
(define (nstextview-ruler-view-did-remove-marker self ruler marker)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:didRemoveMarker:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker))))
(define (nstextview-ruler-view-handle-mouse-down self ruler event)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:handleMouseDown:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-ruler-view-should-add-marker self ruler marker)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:shouldAddMarker:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker))))
(define (nstextview-ruler-view-should-move-marker self ruler marker)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:shouldMoveMarker:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker))))
(define (nstextview-ruler-view-should-remove-marker self ruler marker)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:shouldRemoveMarker:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker))))
(define (nstextview-ruler-view-will-add-marker-at-location self ruler marker location)
  (aw_racket_msg_PPd_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:willAddMarker:atLocation:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker)) location))
(define (nstextview-ruler-view-will-move-marker-to-location self ruler marker location)
  (aw_racket_msg_PPd_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rulerView:willMoveMarker:toLocation:")) (id->ffi2-ptr (coerce-arg ruler)) (id->ffi2-ptr (coerce-arg marker)) location))
(define (nstextview-scale-unit-square-to-size self new-unit-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scaleUnitSquareToSize:")) (id->ffi2-ptr new-unit-size)))
(define (nstextview-scroll-line-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollLineDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-scroll-line-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollLineUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-scroll-page-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPageDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-scroll-page-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPageUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-scroll-point self point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPoint:")) (id->ffi2-ptr point)))
(define (nstextview-scroll-range-to-visible self range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollRangeToVisible:")) (id->ffi2-ptr range)))
(define (nstextview-scroll-rect-to-visible self rect)
  (aw_racket_msg_R_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollRectToVisible:")) (id->ffi2-ptr rect)))
(define (nstextview-scroll-to-beginning-of-document self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollToBeginningOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-scroll-to-end-of-document self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollToEndOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-scroll-wheel self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollWheel:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-select-all self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectAll:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-select-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-select-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-select-to-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectToMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-select-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-selection-range-for-proposed-range-granularity self proposed-char-range granularity)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_GQ_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectionRangeForProposedRange:granularity:")) (id->ffi2-ptr proposed-char-range) granularity (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nstextview-set-accessibility-activation-point! self accessibility-activation-point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityActivationPoint:")) (id->ffi2-ptr accessibility-activation-point)))
(define (nstextview-set-accessibility-allowed-values! self accessibility-allowed-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAllowedValues:")) (id->ffi2-ptr (coerce-arg accessibility-allowed-values))))
(define (nstextview-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAlternateUIVisible:")) accessibility-alternate-ui-visible))
(define (nstextview-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityApplicationFocusedUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-application-focused-ui-element))))
(define (nstextview-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAttributedUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-attributed-user-input-labels))))
(define (nstextview-set-accessibility-cancel-button! self accessibility-cancel-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCancelButton:")) (id->ffi2-ptr (coerce-arg accessibility-cancel-button))))
(define (nstextview-set-accessibility-children! self accessibility-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildren:")) (id->ffi2-ptr (coerce-arg accessibility-children))))
(define (nstextview-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildrenInNavigationOrder:")) (id->ffi2-ptr (coerce-arg accessibility-children-in-navigation-order))))
(define (nstextview-set-accessibility-clear-button! self accessibility-clear-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityClearButton:")) (id->ffi2-ptr (coerce-arg accessibility-clear-button))))
(define (nstextview-set-accessibility-close-button! self accessibility-close-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCloseButton:")) (id->ffi2-ptr (coerce-arg accessibility-close-button))))
(define (nstextview-set-accessibility-column-count! self accessibility-column-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnCount:")) accessibility-column-count))
(define (nstextview-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-column-header-ui-elements))))
(define (nstextview-set-accessibility-column-index-range! self accessibility-column-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnIndexRange:")) (id->ffi2-ptr accessibility-column-index-range)))
(define (nstextview-set-accessibility-column-titles! self accessibility-column-titles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnTitles:")) (id->ffi2-ptr (coerce-arg accessibility-column-titles))))
(define (nstextview-set-accessibility-columns! self accessibility-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumns:")) (id->ffi2-ptr (coerce-arg accessibility-columns))))
(define (nstextview-set-accessibility-contents! self accessibility-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityContents:")) (id->ffi2-ptr (coerce-arg accessibility-contents))))
(define (nstextview-set-accessibility-critical-value! self accessibility-critical-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCriticalValue:")) (id->ffi2-ptr (coerce-arg accessibility-critical-value))))
(define (nstextview-set-accessibility-custom-actions! self accessibility-custom-actions)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomActions:")) (id->ffi2-ptr (coerce-arg accessibility-custom-actions))))
(define (nstextview-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomRotors:")) (id->ffi2-ptr (coerce-arg accessibility-custom-rotors))))
(define (nstextview-set-accessibility-decrement-button! self accessibility-decrement-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDecrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-decrement-button))))
(define (nstextview-set-accessibility-default-button! self accessibility-default-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDefaultButton:")) (id->ffi2-ptr (coerce-arg accessibility-default-button))))
(define (nstextview-set-accessibility-disclosed! self accessibility-disclosed)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosed:")) accessibility-disclosed))
(define (nstextview-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedByRow:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-by-row))))
(define (nstextview-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedRows:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-rows))))
(define (nstextview-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosureLevel:")) accessibility-disclosure-level))
(define (nstextview-set-accessibility-document! self accessibility-document)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDocument:")) (id->ffi2-ptr (coerce-arg accessibility-document))))
(define (nstextview-set-accessibility-edited! self accessibility-edited)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEdited:")) accessibility-edited))
(define (nstextview-set-accessibility-element! self accessibility-element)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityElement:")) accessibility-element))
(define (nstextview-set-accessibility-enabled! self accessibility-enabled)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEnabled:")) accessibility-enabled))
(define (nstextview-set-accessibility-expanded! self accessibility-expanded)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExpanded:")) accessibility-expanded))
(define (nstextview-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExtrasMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-extras-menu-bar))))
(define (nstextview-set-accessibility-filename! self accessibility-filename)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFilename:")) (id->ffi2-ptr (coerce-arg accessibility-filename))))
(define (nstextview-set-accessibility-focused! self accessibility-focused)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocused:")) accessibility-focused))
(define (nstextview-set-accessibility-focused-window! self accessibility-focused-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocusedWindow:")) (id->ffi2-ptr (coerce-arg accessibility-focused-window))))
(define (nstextview-set-accessibility-frame! self accessibility-frame)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrame:")) (id->ffi2-ptr accessibility-frame)))
(define (nstextview-set-accessibility-frontmost! self accessibility-frontmost)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrontmost:")) accessibility-frontmost))
(define (nstextview-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFullScreenButton:")) (id->ffi2-ptr (coerce-arg accessibility-full-screen-button))))
(define (nstextview-set-accessibility-grow-area! self accessibility-grow-area)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityGrowArea:")) (id->ffi2-ptr (coerce-arg accessibility-grow-area))))
(define (nstextview-set-accessibility-handles! self accessibility-handles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHandles:")) (id->ffi2-ptr (coerce-arg accessibility-handles))))
(define (nstextview-set-accessibility-header! self accessibility-header)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHeader:")) (id->ffi2-ptr (coerce-arg accessibility-header))))
(define (nstextview-set-accessibility-help! self accessibility-help)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHelp:")) (id->ffi2-ptr (coerce-arg accessibility-help))))
(define (nstextview-set-accessibility-hidden! self accessibility-hidden)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHidden:")) accessibility-hidden))
(define (nstextview-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-scroll-bar))))
(define (nstextview-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-unit-description))))
(define (nstextview-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnits:")) accessibility-horizontal-units))
(define (nstextview-set-accessibility-identifier! self accessibility-identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIdentifier:")) (id->ffi2-ptr (coerce-arg accessibility-identifier))))
(define (nstextview-set-accessibility-increment-button! self accessibility-increment-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIncrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-increment-button))))
(define (nstextview-set-accessibility-index! self accessibility-index)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIndex:")) accessibility-index))
(define (nstextview-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityInsertionPointLineNumber:")) accessibility-insertion-point-line-number))
(define (nstextview-set-accessibility-label! self accessibility-label)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabel:")) (id->ffi2-ptr (coerce-arg accessibility-label))))
(define (nstextview-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-label-ui-elements))))
(define (nstextview-set-accessibility-label-value! self accessibility-label-value)
  (aw_racket_msg_f_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelValue:")) accessibility-label-value))
(define (nstextview-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLinkedUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-linked-ui-elements))))
(define (nstextview-set-accessibility-main! self accessibility-main)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMain:")) accessibility-main))
(define (nstextview-set-accessibility-main-window! self accessibility-main-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMainWindow:")) (id->ffi2-ptr (coerce-arg accessibility-main-window))))
(define (nstextview-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerGroupUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-marker-group-ui-element))))
(define (nstextview-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerTypeDescription:")) (id->ffi2-ptr (coerce-arg accessibility-marker-type-description))))
(define (nstextview-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-marker-ui-elements))))
(define (nstextview-set-accessibility-marker-values! self accessibility-marker-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerValues:")) (id->ffi2-ptr (coerce-arg accessibility-marker-values))))
(define (nstextview-set-accessibility-max-value! self accessibility-max-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMaxValue:")) (id->ffi2-ptr (coerce-arg accessibility-max-value))))
(define (nstextview-set-accessibility-menu-bar! self accessibility-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-menu-bar))))
(define (nstextview-set-accessibility-min-value! self accessibility-min-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinValue:")) (id->ffi2-ptr (coerce-arg accessibility-min-value))))
(define (nstextview-set-accessibility-minimize-button! self accessibility-minimize-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimizeButton:")) (id->ffi2-ptr (coerce-arg accessibility-minimize-button))))
(define (nstextview-set-accessibility-minimized! self accessibility-minimized)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimized:")) accessibility-minimized))
(define (nstextview-set-accessibility-modal! self accessibility-modal)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityModal:")) accessibility-modal))
(define (nstextview-set-accessibility-next-contents! self accessibility-next-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNextContents:")) (id->ffi2-ptr (coerce-arg accessibility-next-contents))))
(define (nstextview-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNumberOfCharacters:")) accessibility-number-of-characters))
(define (nstextview-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrderedByRow:")) accessibility-ordered-by-row))
(define (nstextview-set-accessibility-orientation! self accessibility-orientation)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrientation:")) accessibility-orientation))
(define (nstextview-set-accessibility-overflow-button! self accessibility-overflow-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOverflowButton:")) (id->ffi2-ptr (coerce-arg accessibility-overflow-button))))
(define (nstextview-set-accessibility-parent! self accessibility-parent)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityParent:")) (id->ffi2-ptr (coerce-arg accessibility-parent))))
(define (nstextview-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPlaceholderValue:")) (id->ffi2-ptr (coerce-arg accessibility-placeholder-value))))
(define (nstextview-set-accessibility-previous-contents! self accessibility-previous-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPreviousContents:")) (id->ffi2-ptr (coerce-arg accessibility-previous-contents))))
(define (nstextview-set-accessibility-protected-content! self accessibility-protected-content)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProtectedContent:")) accessibility-protected-content))
(define (nstextview-set-accessibility-proxy! self accessibility-proxy)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProxy:")) (id->ffi2-ptr (coerce-arg accessibility-proxy))))
(define (nstextview-set-accessibility-required! self accessibility-required)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRequired:")) accessibility-required))
(define (nstextview-set-accessibility-role! self accessibility-role)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRole:")) (id->ffi2-ptr (coerce-arg accessibility-role))))
(define (nstextview-set-accessibility-role-description! self accessibility-role-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRoleDescription:")) (id->ffi2-ptr (coerce-arg accessibility-role-description))))
(define (nstextview-set-accessibility-row-count! self accessibility-row-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowCount:")) accessibility-row-count))
(define (nstextview-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-row-header-ui-elements))))
(define (nstextview-set-accessibility-row-index-range! self accessibility-row-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowIndexRange:")) (id->ffi2-ptr accessibility-row-index-range)))
(define (nstextview-set-accessibility-rows! self accessibility-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRows:")) (id->ffi2-ptr (coerce-arg accessibility-rows))))
(define (nstextview-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRulerMarkerType:")) accessibility-ruler-marker-type))
(define (nstextview-set-accessibility-search-button! self accessibility-search-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchButton:")) (id->ffi2-ptr (coerce-arg accessibility-search-button))))
(define (nstextview-set-accessibility-search-menu! self accessibility-search-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchMenu:")) (id->ffi2-ptr (coerce-arg accessibility-search-menu))))
(define (nstextview-set-accessibility-selected! self accessibility-selected)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelected:")) accessibility-selected))
(define (nstextview-set-accessibility-selected-cells! self accessibility-selected-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedCells:")) (id->ffi2-ptr (coerce-arg accessibility-selected-cells))))
(define (nstextview-set-accessibility-selected-children! self accessibility-selected-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedChildren:")) (id->ffi2-ptr (coerce-arg accessibility-selected-children))))
(define (nstextview-set-accessibility-selected-columns! self accessibility-selected-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedColumns:")) (id->ffi2-ptr (coerce-arg accessibility-selected-columns))))
(define (nstextview-set-accessibility-selected-rows! self accessibility-selected-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedRows:")) (id->ffi2-ptr (coerce-arg accessibility-selected-rows))))
(define (nstextview-set-accessibility-selected-text! self accessibility-selected-text)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedText:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text))))
(define (nstextview-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRange:")) (id->ffi2-ptr accessibility-selected-text-range)))
(define (nstextview-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRanges:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text-ranges))))
(define (nstextview-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityServesAsTitleForUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-serves-as-title-for-ui-elements))))
(define (nstextview-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedCharacterRange:")) (id->ffi2-ptr accessibility-shared-character-range)))
(define (nstextview-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedFocusElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-focus-elements))))
(define (nstextview-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedTextUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-text-ui-elements))))
(define (nstextview-set-accessibility-shown-menu! self accessibility-shown-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityShownMenu:")) (id->ffi2-ptr (coerce-arg accessibility-shown-menu))))
(define (nstextview-set-accessibility-sort-direction! self accessibility-sort-direction)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySortDirection:")) accessibility-sort-direction))
(define (nstextview-set-accessibility-splitters! self accessibility-splitters)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySplitters:")) (id->ffi2-ptr (coerce-arg accessibility-splitters))))
(define (nstextview-set-accessibility-subrole! self accessibility-subrole)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySubrole:")) (id->ffi2-ptr (coerce-arg accessibility-subrole))))
(define (nstextview-set-accessibility-tabs! self accessibility-tabs)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTabs:")) (id->ffi2-ptr (coerce-arg accessibility-tabs))))
(define (nstextview-set-accessibility-title! self accessibility-title)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitle:")) (id->ffi2-ptr (coerce-arg accessibility-title))))
(define (nstextview-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitleUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-title-ui-element))))
(define (nstextview-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityToolbarButton:")) (id->ffi2-ptr (coerce-arg accessibility-toolbar-button))))
(define (nstextview-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTopLevelUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-top-level-ui-element))))
(define (nstextview-set-accessibility-url! self accessibility-url)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityURL:")) (id->ffi2-ptr (coerce-arg accessibility-url))))
(define (nstextview-set-accessibility-unit-description! self accessibility-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-unit-description))))
(define (nstextview-set-accessibility-units! self accessibility-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnits:")) accessibility-units))
(define (nstextview-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-user-input-labels))))
(define (nstextview-set-accessibility-value! self accessibility-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValue:")) (id->ffi2-ptr (coerce-arg accessibility-value))))
(define (nstextview-set-accessibility-value-description! self accessibility-value-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValueDescription:")) (id->ffi2-ptr (coerce-arg accessibility-value-description))))
(define (nstextview-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-scroll-bar))))
(define (nstextview-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-unit-description))))
(define (nstextview-set-accessibility-vertical-units! self accessibility-vertical-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnits:")) accessibility-vertical-units))
(define (nstextview-set-accessibility-visible-cells! self accessibility-visible-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCells:")) (id->ffi2-ptr (coerce-arg accessibility-visible-cells))))
(define (nstextview-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCharacterRange:")) (id->ffi2-ptr accessibility-visible-character-range)))
(define (nstextview-set-accessibility-visible-children! self accessibility-visible-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleChildren:")) (id->ffi2-ptr (coerce-arg accessibility-visible-children))))
(define (nstextview-set-accessibility-visible-columns! self accessibility-visible-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleColumns:")) (id->ffi2-ptr (coerce-arg accessibility-visible-columns))))
(define (nstextview-set-accessibility-visible-rows! self accessibility-visible-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleRows:")) (id->ffi2-ptr (coerce-arg accessibility-visible-rows))))
(define (nstextview-set-accessibility-warning-value! self accessibility-warning-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWarningValue:")) (id->ffi2-ptr (coerce-arg accessibility-warning-value))))
(define (nstextview-set-accessibility-window! self accessibility-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindow:")) (id->ffi2-ptr (coerce-arg accessibility-window))))
(define (nstextview-set-accessibility-windows! self accessibility-windows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindows:")) (id->ffi2-ptr (coerce-arg accessibility-windows))))
(define (nstextview-set-accessibility-zoom-button! self accessibility-zoom-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityZoomButton:")) (id->ffi2-ptr (coerce-arg accessibility-zoom-button))))
(define (nstextview-set-alignment-range! self alignment range)
  (aw_racket_msg_qG_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlignment:range:")) alignment (id->ffi2-ptr range)))
(define (nstextview-set-animations! self animations)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAnimations:")) (id->ffi2-ptr (coerce-arg animations))))
(define (nstextview-set-appearance! self appearance)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAppearance:")) (id->ffi2-ptr (coerce-arg appearance))))
(define (nstextview-set-base-writing-direction-range! self writing-direction range)
  (aw_racket_msg_qG_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBaseWritingDirection:range:")) writing-direction (id->ffi2-ptr range)))
(define (nstextview-set-bounds-origin! self new-origin)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsOrigin:")) (id->ffi2-ptr new-origin)))
(define (nstextview-set-bounds-size! self new-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBoundsSize:")) (id->ffi2-ptr new-size)))
(define (nstextview-set-constrained-frame-size! self desired-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setConstrainedFrameSize:")) (id->ffi2-ptr desired-size)))
(define (nstextview-set-content-type! self content-type)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentType:")) (id->ffi2-ptr (coerce-arg content-type))))
(define (nstextview-set-font-range! self font range)
  (aw_racket_msg_PG_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFont:range:")) (id->ffi2-ptr (coerce-arg font)) (id->ffi2-ptr range)))
(define (nstextview-set-frame-origin! self new-origin)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameOrigin:")) (id->ffi2-ptr new-origin)))
(define (nstextview-set-frame-size! self new-size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameSize:")) (id->ffi2-ptr new-size)))
(define (nstextview-set-identifier! self identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIdentifier:")) (id->ffi2-ptr (coerce-arg identifier))))
(define (nstextview-set-layout-orientation! self orientation)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLayoutOrientation:")) orientation))
(define (nstextview-set-mark! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-set-marked-text-selected-range-replacement-range! self string selected-range replacement-range)
  (aw_racket_msg_PGG_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMarkedText:selectedRange:replacementRange:")) (id->ffi2-ptr (coerce-arg string)) (id->ffi2-ptr selected-range) (id->ffi2-ptr replacement-range)))
(define (nstextview-set-needs-display-in-rect! self invalid-rect)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsDisplayInRect:")) (id->ffi2-ptr invalid-rect)))
(define (nstextview-set-needs-display-in-rect-avoid-additional-layout! self rect flag)
  (aw_racket_msg_Rb_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNeedsDisplayInRect:avoidAdditionalLayout:")) (id->ffi2-ptr rect) flag))
(define (nstextview-set-text-color-range! self color range)
  (aw_racket_msg_PG_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTextColor:range:")) (id->ffi2-ptr (coerce-arg color)) (id->ffi2-ptr range)))
(define (nstextview-should-be-treated-as-ink-event self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldBeTreatedAsInkEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-should-delay-window-ordering-for-event self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldDelayWindowOrderingForEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-show-context-help self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextHelp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-show-context-menu-for-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextMenuForSelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-show-guess-panel self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showGuessPanel:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-size-to-fit self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sizeToFit"))))
(define (nstextview-smart-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "smartMagnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-sort-subviews-using-function-context self compare context)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sortSubviewsUsingFunction:context:")) (id->ffi2-ptr compare) (id->ffi2-ptr context)))
(define (nstextview-start-speaking self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "startSpeaking:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-stop-speaking self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stopSpeaking:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-subscript self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "subscript:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-superscript self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "superscript:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "supplementalTargetForAction:sender:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg sender))))
   ))
(define (nstextview-supports-adaptive-image-glyph self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "supportsAdaptiveImageGlyph"))))
(define (nstextview-swap-with-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swapWithMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-swipe-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swipeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-tablet-point self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletPoint:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-tablet-proximity self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletProximity:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-tighten-kerning self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tightenKerning:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-toggle-ruler! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "toggleRuler:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-touches-began-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesBeganWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-touches-cancelled-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesCancelledWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-touches-ended-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesEndedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-touches-moved-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesMovedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-translate-origin-to-point self translation)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translateOriginToPoint:")) (id->ffi2-ptr translation)))
(define (nstextview-translate-rects-needing-display-in-rect-by self clip-rect delta)
  (aw_racket_msg_RZ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "translateRectsNeedingDisplayInRect:by:")) (id->ffi2-ptr clip-rect) (id->ffi2-ptr delta)))
(define (nstextview-transpose self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transpose:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-transpose-words self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transposeWords:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-try-to-perform-with self action object)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tryToPerform:with:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg object))))
(define (nstextview-turn-off-kerning self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "turnOffKerning:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-turn-off-ligatures self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "turnOffLigatures:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-underline self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "underline:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-union-rect-in-visible-selected-range self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "unionRectInVisibleSelectedRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nstextview-unmark-text self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "unmarkText"))))
(define (nstextview-unscript self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "unscript:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-update-drag-type-registration self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateDragTypeRegistration"))))
(define (nstextview-update-dragging-items-for-drag self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateDraggingItemsForDrag:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-update-font-panel self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateFontPanel"))))
(define (nstextview-update-layer self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateLayer"))))
(define (nstextview-update-ruler self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateRuler"))))
(define (nstextview-uppercase-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "uppercaseWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-use-all-ligatures self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "useAllLigatures:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-use-standard-kerning self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "useStandardKerning:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-use-standard-ligatures self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "useStandardLigatures:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nstextview-valid-attributes-for-marked-text self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validAttributesForMarkedText"))))
   ))
(define (nstextview-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validRequestorForSendType:returnType:")) (id->ffi2-ptr (coerce-arg send-type)) (id->ffi2-ptr (coerce-arg return-type))))
   ))
(define (nstextview-validate-menu-item self menu-item)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validateMenuItem:")) (id->ffi2-ptr (coerce-arg menu-item))))
(define (nstextview-validate-user-interface-item self item)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validateUserInterfaceItem:")) (id->ffi2-ptr (coerce-arg item))))
(define (nstextview-view-did-change-backing-properties self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidChangeBackingProperties"))))
(define (nstextview-view-did-change-effective-appearance self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidChangeEffectiveAppearance"))))
(define (nstextview-view-did-end-live-resize self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidEndLiveResize"))))
(define (nstextview-view-did-hide self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidHide"))))
(define (nstextview-view-did-move-to-superview self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidMoveToSuperview"))))
(define (nstextview-view-did-move-to-window self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidMoveToWindow"))))
(define (nstextview-view-did-unhide self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewDidUnhide"))))
(define (nstextview-view-will-draw self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillDraw"))))
(define (nstextview-view-will-move-to-superview self new-superview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillMoveToSuperview:")) (id->ffi2-ptr (coerce-arg new-superview))))
(define (nstextview-view-will-move-to-window self new-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillMoveToWindow:")) (id->ffi2-ptr (coerce-arg new-window))))
(define (nstextview-view-will-start-live-resize self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWillStartLiveResize"))))
(define (nstextview-view-with-tag self tag)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewWithTag:")) tag))
   ))
(define (nstextview-wants-forwarded-scroll-events-for-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsForwardedScrollEventsForAxis:")) axis))
(define (nstextview-wants-periodic-dragging-updates self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsPeriodicDraggingUpdates"))))
(define (nstextview-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:")) axis))
(define (nstextview-will-open-menu-with-event self menu event)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "willOpenMenu:withEvent:")) (id->ffi2-ptr (coerce-arg menu)) (id->ffi2-ptr (coerce-arg event))))
(define (nstextview-will-remove-subview self subview)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "willRemoveSubview:")) (id->ffi2-ptr (coerce-arg subview))))
(define (nstextview-window-level self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "windowLevel"))))
(define (nstextview-write-rtfd-to-file-atomically self path flag)
  (aw_racket_msg_Pb_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "writeRTFDToFile:atomically:")) (id->ffi2-ptr (coerce-arg path)) flag))
(define (nstextview-yank self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "yank:")) (id->ffi2-ptr (coerce-arg sender))))

;; --- Class methods ---
(define (nstextview-default-animation-for-key key)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSTextView) (id->ffi2-ptr (sel_registerName "defaultAnimationForKey:")) (id->ffi2-ptr (coerce-arg key))))
   ))
(define (nstextview-is-compatible-with-responsive-scrolling)
  (aw_racket_msg_0_b (id->ffi2-ptr NSTextView) (id->ffi2-ptr (sel_registerName "isCompatibleWithResponsiveScrolling"))))
(define (nstextview-text-view-using-text-layout-manager using-text-layout-manager)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_b_P (id->ffi2-ptr NSTextView) (id->ffi2-ptr (sel_registerName "textViewUsingTextLayoutManager:")) using-text-layout-manager))
   ))
