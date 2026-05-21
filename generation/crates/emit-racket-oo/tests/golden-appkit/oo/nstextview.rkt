#lang racket/base
;; Generated binding for NSTextView (AppKit)
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
(define _msg-12  ; (_fun _pointer _pointer _NSPoint -> _double)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _double)))
(define _msg-13  ; (_fun _pointer _pointer _NSPoint -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _id)))
(define _msg-14  ; (_fun _pointer _pointer _NSPoint -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _uint64)))
(define _msg-15  ; (_fun _pointer _pointer _NSPoint -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _void)))
(define _msg-16  ; (_fun _pointer _pointer _NSPoint _NSRect -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint _NSRect -> _NSRect)))
(define _msg-17  ; (_fun _pointer _pointer _NSPoint _NSRect -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint _NSRect -> _bool)))
(define _msg-18  ; (_fun _pointer _pointer _NSPoint _id -> _NSPoint)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint _id -> _NSPoint)))
(define _msg-19  ; (_fun _pointer _pointer _NSRange -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _NSRect)))
(define _msg-20  ; (_fun _pointer _pointer _NSRange -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _id)))
(define _msg-21  ; (_fun _pointer _pointer _NSRange -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _void)))
(define _msg-22  ; (_fun _pointer _pointer _NSRange _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange _id -> _bool)))
(define _msg-23  ; (_fun _pointer _pointer _NSRange _id -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange _id -> _void)))
(define _msg-24  ; (_fun _pointer _pointer _NSRange _pointer -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange _pointer -> _NSRect)))
(define _msg-25  ; (_fun _pointer _pointer _NSRange _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange _pointer -> _id)))
(define _msg-26  ; (_fun _pointer _pointer _NSRange _uint64 -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange _uint64 -> _NSRange)))
(define _msg-27  ; (_fun _pointer _pointer _NSRect -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _NSRect)))
(define _msg-28  ; (_fun _pointer _pointer _NSRect -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _bool)))
(define _msg-29  ; (_fun _pointer _pointer _NSRect -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _id)))
(define _msg-30  ; (_fun _pointer _pointer _NSRect -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _void)))
(define _msg-31  ; (_fun _pointer _pointer _NSRect _NSSize -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _NSSize -> _void)))
(define _msg-32  ; (_fun _pointer _pointer _NSRect _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _bool -> _void)))
(define _msg-33  ; (_fun _pointer _pointer _NSRect _id -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id -> _NSRect)))
(define _msg-34  ; (_fun _pointer _pointer _NSRect _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id -> _id)))
(define _msg-35  ; (_fun _pointer _pointer _NSRect _id -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id -> _void)))
(define _msg-36  ; (_fun _pointer _pointer _NSRect _id _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id _bool -> _void)))
(define _msg-37  ; (_fun _pointer _pointer _NSRect _id _pointer -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id _pointer -> _int64)))
(define _msg-38  ; (_fun _pointer _pointer _NSRect _uint64 -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _uint64 -> _NSRect)))
(define _msg-39  ; (_fun _pointer _pointer _NSSize -> _NSSize)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize -> _NSSize)))
(define _msg-40  ; (_fun _pointer _pointer _NSSize -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize -> _void)))
(define _msg-41  ; (_fun _pointer _pointer _NSSize _id -> _NSSize)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize _id -> _NSSize)))
(define _msg-42  ; (_fun _pointer _pointer _bool -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _bool -> _id)))
(define _msg-43  ; (_fun _pointer _pointer _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _bool -> _void)))
(define _msg-44  ; (_fun _pointer _pointer _double -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double -> _void)))
(define _msg-45  ; (_fun _pointer _pointer _float -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _float -> _void)))
(define _msg-46  ; (_fun _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _bool)))
(define _msg-47  ; (_fun _pointer _pointer _id -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _uint64)))
(define _msg-48  ; (_fun _pointer _pointer _id _NSPoint -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _NSPoint -> _void)))
(define _msg-49  ; (_fun _pointer _pointer _id _NSPoint _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _NSPoint _uint64 -> _void)))
(define _msg-50  ; (_fun _pointer _pointer _id _NSRange -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _NSRange -> _void)))
(define _msg-51  ; (_fun _pointer _pointer _id _NSRange _NSRange -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _NSRange _NSRange -> _void)))
(define _msg-52  ; (_fun _pointer _pointer _id _bool -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _bool -> _bool)))
(define _msg-53  ; (_fun _pointer _pointer _id _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id -> _bool)))
(define _msg-54  ; (_fun _pointer _pointer _id _id _double -> _double)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _double -> _double)))
(define _msg-55  ; (_fun _pointer _pointer _id _int64 -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _int64 -> _uint64)))
(define _msg-56  ; (_fun _pointer _pointer _id _int64 _id -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _int64 _id -> _void)))
(define _msg-57  ; (_fun _pointer _pointer _id _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _uint64 -> _void)))
(define _msg-58  ; (_fun _pointer _pointer _int64 -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _NSRange)))
(define _msg-59  ; (_fun _pointer _pointer _int64 -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _bool)))
(define _msg-60  ; (_fun _pointer _pointer _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _id)))
(define _msg-61  ; (_fun _pointer _pointer _int64 -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _int64)))
(define _msg-62  ; (_fun _pointer _pointer _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _void)))
(define _msg-63  ; (_fun _pointer _pointer _int64 _NSRange -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _NSRange -> _void)))
(define _msg-64  ; (_fun _pointer _pointer _int64 _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _int64 -> _id)))
(define _msg-65  ; (_fun _pointer _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _bool)))
(define _msg-66  ; (_fun _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _void)))
(define _msg-67  ; (_fun _pointer _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _bool)))
(define _msg-68  ; (_fun _pointer _pointer _pointer _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _id)))
(define _msg-69  ; (_fun _pointer _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _pointer -> _void)))
(define _msg-70  ; (_fun _pointer _pointer _uint64 -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _bool)))
(define _msg-71  ; (_fun _pointer _pointer _uint64 -> _double)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _double)))
(define _msg-72  ; (_fun _pointer _pointer _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _void)))

;; --- Constructors ---
(define (make-nstextview-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSTextView alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nstextview-init-with-frame frame-rect)
  (wrap-objc-object
   (_msg-29 (tell NSTextView alloc)
       (sel_registerName "initWithFrame:")
       frame-rect)
   #:retained #t))

(define (make-nstextview-init-with-frame-text-container frame-rect container)
  (wrap-objc-object
   (_msg-34 (tell NSTextView alloc)
       (sel_registerName "initWithFrame:textContainer:")
       frame-rect
       (coerce-arg container))
   #:retained #t))


;; --- Properties ---
(define (nstextview-acceptable-drag-types self)
  (wrap-objc-object
   (tell (coerce-arg self) acceptableDragTypes)))
(define (nstextview-accepts-first-responder self)
  (tell #:type _bool (coerce-arg self) acceptsFirstResponder))
(define (nstextview-accepts-glyph-info self)
  (tell #:type _bool (coerce-arg self) acceptsGlyphInfo))
(define (nstextview-set-accepts-glyph-info! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setAcceptsGlyphInfo:") value))
(define (nstextview-accepts-touch-events self)
  (tell #:type _bool (coerce-arg self) acceptsTouchEvents))
(define (nstextview-set-accepts-touch-events! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setAcceptsTouchEvents:") value))
(define (nstextview-additional-safe-area-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) additionalSafeAreaInsets))
(define (nstextview-set-additional-safe-area-insets! self value)
  (_msg-9 (coerce-arg self) (sel_registerName "setAdditionalSafeAreaInsets:") value))
(define (nstextview-alignment self)
  (tell #:type _int64 (coerce-arg self) alignment))
(define (nstextview-set-alignment! self value)
  (_msg-62 (coerce-arg self) (sel_registerName "setAlignment:") value))
(define (nstextview-alignment-rect-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) alignmentRectInsets))
(define (nstextview-allowed-input-source-locales self)
  (wrap-objc-object
   (tell (coerce-arg self) allowedInputSourceLocales)))
(define (nstextview-set-allowed-input-source-locales! self value)
  (tell #:type _void (coerce-arg self) setAllowedInputSourceLocales: (coerce-arg value)))
(define (nstextview-allowed-touch-types self)
  (tell #:type _uint64 (coerce-arg self) allowedTouchTypes))
(define (nstextview-set-allowed-touch-types! self value)
  (_msg-72 (coerce-arg self) (sel_registerName "setAllowedTouchTypes:") value))
(define (nstextview-allowed-writing-tools-result-options self)
  (tell #:type _uint64 (coerce-arg self) allowedWritingToolsResultOptions))
(define (nstextview-set-allowed-writing-tools-result-options! self value)
  (_msg-72 (coerce-arg self) (sel_registerName "setAllowedWritingToolsResultOptions:") value))
(define (nstextview-allows-character-picker-touch-bar-item self)
  (tell #:type _bool (coerce-arg self) allowsCharacterPickerTouchBarItem))
(define (nstextview-set-allows-character-picker-touch-bar-item! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setAllowsCharacterPickerTouchBarItem:") value))
(define (nstextview-allows-document-background-color-change self)
  (tell #:type _bool (coerce-arg self) allowsDocumentBackgroundColorChange))
(define (nstextview-set-allows-document-background-color-change! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setAllowsDocumentBackgroundColorChange:") value))
(define (nstextview-allows-image-editing self)
  (tell #:type _bool (coerce-arg self) allowsImageEditing))
(define (nstextview-set-allows-image-editing! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setAllowsImageEditing:") value))
(define (nstextview-allows-undo self)
  (tell #:type _bool (coerce-arg self) allowsUndo))
(define (nstextview-set-allows-undo! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setAllowsUndo:") value))
(define (nstextview-allows-vibrancy self)
  (tell #:type _bool (coerce-arg self) allowsVibrancy))
(define (nstextview-alpha-value self)
  (tell #:type _double (coerce-arg self) alphaValue))
(define (nstextview-set-alpha-value! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setAlphaValue:") value))
(define (nstextview-automatic-dash-substitution-enabled self)
  (tell #:type _bool (coerce-arg self) automaticDashSubstitutionEnabled))
(define (nstextview-set-automatic-dash-substitution-enabled! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setAutomaticDashSubstitutionEnabled:") value))
(define (nstextview-automatic-data-detection-enabled self)
  (tell #:type _bool (coerce-arg self) automaticDataDetectionEnabled))
(define (nstextview-set-automatic-data-detection-enabled! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setAutomaticDataDetectionEnabled:") value))
(define (nstextview-automatic-link-detection-enabled self)
  (tell #:type _bool (coerce-arg self) automaticLinkDetectionEnabled))
(define (nstextview-set-automatic-link-detection-enabled! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setAutomaticLinkDetectionEnabled:") value))
(define (nstextview-automatic-quote-substitution-enabled self)
  (tell #:type _bool (coerce-arg self) automaticQuoteSubstitutionEnabled))
(define (nstextview-set-automatic-quote-substitution-enabled! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setAutomaticQuoteSubstitutionEnabled:") value))
(define (nstextview-automatic-spelling-correction-enabled self)
  (tell #:type _bool (coerce-arg self) automaticSpellingCorrectionEnabled))
(define (nstextview-set-automatic-spelling-correction-enabled! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setAutomaticSpellingCorrectionEnabled:") value))
(define (nstextview-automatic-text-completion-enabled self)
  (tell #:type _bool (coerce-arg self) automaticTextCompletionEnabled))
(define (nstextview-set-automatic-text-completion-enabled! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setAutomaticTextCompletionEnabled:") value))
(define (nstextview-automatic-text-replacement-enabled self)
  (tell #:type _bool (coerce-arg self) automaticTextReplacementEnabled))
(define (nstextview-set-automatic-text-replacement-enabled! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setAutomaticTextReplacementEnabled:") value))
(define (nstextview-autoresizes-subviews self)
  (tell #:type _bool (coerce-arg self) autoresizesSubviews))
(define (nstextview-set-autoresizes-subviews! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setAutoresizesSubviews:") value))
(define (nstextview-autoresizing-mask self)
  (tell #:type _uint64 (coerce-arg self) autoresizingMask))
(define (nstextview-set-autoresizing-mask! self value)
  (_msg-72 (coerce-arg self) (sel_registerName "setAutoresizingMask:") value))
(define (nstextview-background-color self)
  (wrap-objc-object
   (tell (coerce-arg self) backgroundColor)))
(define (nstextview-set-background-color! self value)
  (tell #:type _void (coerce-arg self) setBackgroundColor: (coerce-arg value)))
(define (nstextview-background-filters self)
  (wrap-objc-object
   (tell (coerce-arg self) backgroundFilters)))
(define (nstextview-set-background-filters! self value)
  (tell #:type _void (coerce-arg self) setBackgroundFilters: (coerce-arg value)))
(define (nstextview-base-writing-direction self)
  (tell #:type _int64 (coerce-arg self) baseWritingDirection))
(define (nstextview-set-base-writing-direction! self value)
  (_msg-62 (coerce-arg self) (sel_registerName "setBaseWritingDirection:") value))
(define (nstextview-baseline-offset-from-bottom self)
  (tell #:type _double (coerce-arg self) baselineOffsetFromBottom))
(define (nstextview-bottom-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) bottomAnchor)))
(define (nstextview-bounds self)
  (tell #:type _NSRect (coerce-arg self) bounds))
(define (nstextview-set-bounds! self value)
  (_msg-30 (coerce-arg self) (sel_registerName "setBounds:") value))
(define (nstextview-bounds-rotation self)
  (tell #:type _double (coerce-arg self) boundsRotation))
(define (nstextview-set-bounds-rotation! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setBoundsRotation:") value))
(define (nstextview-can-become-key-view self)
  (tell #:type _bool (coerce-arg self) canBecomeKeyView))
(define (nstextview-can-draw self)
  (tell #:type _bool (coerce-arg self) canDraw))
(define (nstextview-can-draw-concurrently self)
  (tell #:type _bool (coerce-arg self) canDrawConcurrently))
(define (nstextview-set-can-draw-concurrently! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setCanDrawConcurrently:") value))
(define (nstextview-can-draw-subviews-into-layer self)
  (tell #:type _bool (coerce-arg self) canDrawSubviewsIntoLayer))
(define (nstextview-set-can-draw-subviews-into-layer! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setCanDrawSubviewsIntoLayer:") value))
(define (nstextview-candidate-list-touch-bar-item self)
  (wrap-objc-object
   (tell (coerce-arg self) candidateListTouchBarItem)))
(define (nstextview-center-x-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) centerXAnchor)))
(define (nstextview-center-y-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) centerYAnchor)))
(define (nstextview-clips-to-bounds self)
  (tell #:type _bool (coerce-arg self) clipsToBounds))
(define (nstextview-set-clips-to-bounds! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setClipsToBounds:") value))
(define (nstextview-coalescing-undo self)
  (tell #:type _bool (coerce-arg self) coalescingUndo))
(define (nstextview-compatible-with-responsive-scrolling)
  (tell #:type _bool NSTextView compatibleWithResponsiveScrolling))
(define (nstextview-compositing-filter self)
  (wrap-objc-object
   (tell (coerce-arg self) compositingFilter)))
(define (nstextview-set-compositing-filter! self value)
  (tell #:type _void (coerce-arg self) setCompositingFilter: (coerce-arg value)))
(define (nstextview-constraints self)
  (wrap-objc-object
   (tell (coerce-arg self) constraints)))
(define (nstextview-content-filters self)
  (wrap-objc-object
   (tell (coerce-arg self) contentFilters)))
(define (nstextview-set-content-filters! self value)
  (tell #:type _void (coerce-arg self) setContentFilters: (coerce-arg value)))
(define (nstextview-continuous-spell-checking-enabled self)
  (tell #:type _bool (coerce-arg self) continuousSpellCheckingEnabled))
(define (nstextview-set-continuous-spell-checking-enabled! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setContinuousSpellCheckingEnabled:") value))
(define (nstextview-default-focus-ring-type)
  (tell #:type _uint64 NSTextView defaultFocusRingType))
(define (nstextview-default-menu)
  (wrap-objc-object
   (tell NSTextView defaultMenu)))
(define (nstextview-default-paragraph-style self)
  (wrap-objc-object
   (tell (coerce-arg self) defaultParagraphStyle)))
(define (nstextview-set-default-paragraph-style! self value)
  (tell #:type _void (coerce-arg self) setDefaultParagraphStyle: (coerce-arg value)))
(define (nstextview-delegate self)
  (wrap-objc-object
   (tell (coerce-arg self) delegate)))
(define (nstextview-set-delegate! self value)
  (tell #:type _void (coerce-arg self) setDelegate: (coerce-arg value)))
(define (nstextview-displays-link-tool-tips self)
  (tell #:type _bool (coerce-arg self) displaysLinkToolTips))
(define (nstextview-set-displays-link-tool-tips! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setDisplaysLinkToolTips:") value))
(define (nstextview-drawing-find-indicator self)
  (tell #:type _bool (coerce-arg self) drawingFindIndicator))
(define (nstextview-draws-background self)
  (tell #:type _bool (coerce-arg self) drawsBackground))
(define (nstextview-set-draws-background! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setDrawsBackground:") value))
(define (nstextview-editable self)
  (tell #:type _bool (coerce-arg self) editable))
(define (nstextview-set-editable! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setEditable:") value))
(define (nstextview-enabled-text-checking-types self)
  (tell #:type _uint64 (coerce-arg self) enabledTextCheckingTypes))
(define (nstextview-set-enabled-text-checking-types! self value)
  (_msg-72 (coerce-arg self) (sel_registerName "setEnabledTextCheckingTypes:") value))
(define (nstextview-enclosing-menu-item self)
  (wrap-objc-object
   (tell (coerce-arg self) enclosingMenuItem)))
(define (nstextview-enclosing-scroll-view self)
  (wrap-objc-object
   (tell (coerce-arg self) enclosingScrollView)))
(define (nstextview-field-editor self)
  (tell #:type _bool (coerce-arg self) fieldEditor))
(define (nstextview-set-field-editor! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setFieldEditor:") value))
(define (nstextview-first-baseline-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) firstBaselineAnchor)))
(define (nstextview-first-baseline-offset-from-top self)
  (tell #:type _double (coerce-arg self) firstBaselineOffsetFromTop))
(define (nstextview-fitting-size self)
  (tell #:type _NSSize (coerce-arg self) fittingSize))
(define (nstextview-flipped self)
  (tell #:type _bool (coerce-arg self) flipped))
(define (nstextview-focus-ring-mask-bounds self)
  (tell #:type _NSRect (coerce-arg self) focusRingMaskBounds))
(define (nstextview-focus-ring-type self)
  (tell #:type _uint64 (coerce-arg self) focusRingType))
(define (nstextview-set-focus-ring-type! self value)
  (_msg-72 (coerce-arg self) (sel_registerName "setFocusRingType:") value))
(define (nstextview-focus-view)
  (wrap-objc-object
   (tell NSTextView focusView)))
(define (nstextview-font self)
  (wrap-objc-object
   (tell (coerce-arg self) font)))
(define (nstextview-set-font! self value)
  (tell #:type _void (coerce-arg self) setFont: (coerce-arg value)))
(define (nstextview-frame self)
  (tell #:type _NSRect (coerce-arg self) frame))
(define (nstextview-set-frame! self value)
  (_msg-30 (coerce-arg self) (sel_registerName "setFrame:") value))
(define (nstextview-frame-center-rotation self)
  (tell #:type _double (coerce-arg self) frameCenterRotation))
(define (nstextview-set-frame-center-rotation! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setFrameCenterRotation:") value))
(define (nstextview-frame-rotation self)
  (tell #:type _double (coerce-arg self) frameRotation))
(define (nstextview-set-frame-rotation! self value)
  (_msg-44 (coerce-arg self) (sel_registerName "setFrameRotation:") value))
(define (nstextview-gesture-recognizers self)
  (wrap-objc-object
   (tell (coerce-arg self) gestureRecognizers)))
(define (nstextview-set-gesture-recognizers! self value)
  (tell #:type _void (coerce-arg self) setGestureRecognizers: (coerce-arg value)))
(define (nstextview-grammar-checking-enabled self)
  (tell #:type _bool (coerce-arg self) grammarCheckingEnabled))
(define (nstextview-set-grammar-checking-enabled! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setGrammarCheckingEnabled:") value))
(define (nstextview-has-ambiguous-layout self)
  (tell #:type _bool (coerce-arg self) hasAmbiguousLayout))
(define (nstextview-height-adjust-limit self)
  (tell #:type _double (coerce-arg self) heightAdjustLimit))
(define (nstextview-height-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) heightAnchor)))
(define (nstextview-hidden self)
  (tell #:type _bool (coerce-arg self) hidden))
(define (nstextview-set-hidden! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setHidden:") value))
(define (nstextview-hidden-or-has-hidden-ancestor self)
  (tell #:type _bool (coerce-arg self) hiddenOrHasHiddenAncestor))
(define (nstextview-horizontal-content-size-constraint-active self)
  (tell #:type _bool (coerce-arg self) horizontalContentSizeConstraintActive))
(define (nstextview-set-horizontal-content-size-constraint-active! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setHorizontalContentSizeConstraintActive:") value))
(define (nstextview-horizontally-resizable self)
  (tell #:type _bool (coerce-arg self) horizontallyResizable))
(define (nstextview-set-horizontally-resizable! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setHorizontallyResizable:") value))
(define (nstextview-imports-graphics self)
  (tell #:type _bool (coerce-arg self) importsGraphics))
(define (nstextview-set-imports-graphics! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setImportsGraphics:") value))
(define (nstextview-in-full-screen-mode self)
  (tell #:type _bool (coerce-arg self) inFullScreenMode))
(define (nstextview-in-live-resize self)
  (tell #:type _bool (coerce-arg self) inLiveResize))
(define (nstextview-incremental-searching-enabled self)
  (tell #:type _bool (coerce-arg self) incrementalSearchingEnabled))
(define (nstextview-set-incremental-searching-enabled! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setIncrementalSearchingEnabled:") value))
(define (nstextview-inline-prediction-type self)
  (tell #:type _int64 (coerce-arg self) inlinePredictionType))
(define (nstextview-set-inline-prediction-type! self value)
  (_msg-62 (coerce-arg self) (sel_registerName "setInlinePredictionType:") value))
(define (nstextview-input-context self)
  (wrap-objc-object
   (tell (coerce-arg self) inputContext)))
(define (nstextview-insertion-point-color self)
  (wrap-objc-object
   (tell (coerce-arg self) insertionPointColor)))
(define (nstextview-set-insertion-point-color! self value)
  (tell #:type _void (coerce-arg self) setInsertionPointColor: (coerce-arg value)))
(define (nstextview-intrinsic-content-size self)
  (tell #:type _NSSize (coerce-arg self) intrinsicContentSize))
(define (nstextview-last-baseline-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) lastBaselineAnchor)))
(define (nstextview-last-baseline-offset-from-bottom self)
  (tell #:type _double (coerce-arg self) lastBaselineOffsetFromBottom))
(define (nstextview-layer self)
  (wrap-objc-object
   (tell (coerce-arg self) layer)))
(define (nstextview-set-layer! self value)
  (tell #:type _void (coerce-arg self) setLayer: (coerce-arg value)))
(define (nstextview-layer-contents-placement self)
  (tell #:type _int64 (coerce-arg self) layerContentsPlacement))
(define (nstextview-set-layer-contents-placement! self value)
  (_msg-62 (coerce-arg self) (sel_registerName "setLayerContentsPlacement:") value))
(define (nstextview-layer-contents-redraw-policy self)
  (tell #:type _int64 (coerce-arg self) layerContentsRedrawPolicy))
(define (nstextview-set-layer-contents-redraw-policy! self value)
  (_msg-62 (coerce-arg self) (sel_registerName "setLayerContentsRedrawPolicy:") value))
(define (nstextview-layer-uses-core-image-filters self)
  (tell #:type _bool (coerce-arg self) layerUsesCoreImageFilters))
(define (nstextview-set-layer-uses-core-image-filters! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setLayerUsesCoreImageFilters:") value))
(define (nstextview-layout-guides self)
  (wrap-objc-object
   (tell (coerce-arg self) layoutGuides)))
(define (nstextview-layout-manager self)
  (wrap-objc-object
   (tell (coerce-arg self) layoutManager)))
(define (nstextview-layout-margins-guide self)
  (wrap-objc-object
   (tell (coerce-arg self) layoutMarginsGuide)))
(define (nstextview-leading-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) leadingAnchor)))
(define (nstextview-left-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) leftAnchor)))
(define (nstextview-link-text-attributes self)
  (wrap-objc-object
   (tell (coerce-arg self) linkTextAttributes)))
(define (nstextview-set-link-text-attributes! self value)
  (tell #:type _void (coerce-arg self) setLinkTextAttributes: (coerce-arg value)))
(define (nstextview-marked-text-attributes self)
  (wrap-objc-object
   (tell (coerce-arg self) markedTextAttributes)))
(define (nstextview-set-marked-text-attributes! self value)
  (tell #:type _void (coerce-arg self) setMarkedTextAttributes: (coerce-arg value)))
(define (nstextview-math-expression-completion-type self)
  (tell #:type _int64 (coerce-arg self) mathExpressionCompletionType))
(define (nstextview-set-math-expression-completion-type! self value)
  (_msg-62 (coerce-arg self) (sel_registerName "setMathExpressionCompletionType:") value))
(define (nstextview-max-size self)
  (tell #:type _NSSize (coerce-arg self) maxSize))
(define (nstextview-set-max-size! self value)
  (_msg-40 (coerce-arg self) (sel_registerName "setMaxSize:") value))
(define (nstextview-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) menu)))
(define (nstextview-set-menu! self value)
  (tell #:type _void (coerce-arg self) setMenu: (coerce-arg value)))
(define (nstextview-min-size self)
  (tell #:type _NSSize (coerce-arg self) minSize))
(define (nstextview-set-min-size! self value)
  (_msg-40 (coerce-arg self) (sel_registerName "setMinSize:") value))
(define (nstextview-mouse-down-can-move-window self)
  (tell #:type _bool (coerce-arg self) mouseDownCanMoveWindow))
(define (nstextview-needs-display self)
  (tell #:type _bool (coerce-arg self) needsDisplay))
(define (nstextview-set-needs-display! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setNeedsDisplay:") value))
(define (nstextview-needs-layout self)
  (tell #:type _bool (coerce-arg self) needsLayout))
(define (nstextview-set-needs-layout! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setNeedsLayout:") value))
(define (nstextview-needs-panel-to-become-key self)
  (tell #:type _bool (coerce-arg self) needsPanelToBecomeKey))
(define (nstextview-needs-update-constraints self)
  (tell #:type _bool (coerce-arg self) needsUpdateConstraints))
(define (nstextview-set-needs-update-constraints! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setNeedsUpdateConstraints:") value))
(define (nstextview-next-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) nextKeyView)))
(define (nstextview-set-next-key-view! self value)
  (tell #:type _void (coerce-arg self) setNextKeyView: (coerce-arg value)))
(define (nstextview-next-responder self)
  (wrap-objc-object
   (tell (coerce-arg self) nextResponder)))
(define (nstextview-set-next-responder! self value)
  (tell #:type _void (coerce-arg self) setNextResponder: (coerce-arg value)))
(define (nstextview-next-valid-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) nextValidKeyView)))
(define (nstextview-opaque self)
  (tell #:type _bool (coerce-arg self) opaque))
(define (nstextview-opaque-ancestor self)
  (wrap-objc-object
   (tell (coerce-arg self) opaqueAncestor)))
(define (nstextview-page-footer self)
  (wrap-objc-object
   (tell (coerce-arg self) pageFooter)))
(define (nstextview-page-header self)
  (wrap-objc-object
   (tell (coerce-arg self) pageHeader)))
(define (nstextview-posts-bounds-changed-notifications self)
  (tell #:type _bool (coerce-arg self) postsBoundsChangedNotifications))
(define (nstextview-set-posts-bounds-changed-notifications! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setPostsBoundsChangedNotifications:") value))
(define (nstextview-posts-frame-changed-notifications self)
  (tell #:type _bool (coerce-arg self) postsFrameChangedNotifications))
(define (nstextview-set-posts-frame-changed-notifications! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setPostsFrameChangedNotifications:") value))
(define (nstextview-prefers-compact-control-size-metrics self)
  (tell #:type _bool (coerce-arg self) prefersCompactControlSizeMetrics))
(define (nstextview-set-prefers-compact-control-size-metrics! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setPrefersCompactControlSizeMetrics:") value))
(define (nstextview-prepared-content-rect self)
  (tell #:type _NSRect (coerce-arg self) preparedContentRect))
(define (nstextview-set-prepared-content-rect! self value)
  (_msg-30 (coerce-arg self) (sel_registerName "setPreparedContentRect:") value))
(define (nstextview-preserves-content-during-live-resize self)
  (tell #:type _bool (coerce-arg self) preservesContentDuringLiveResize))
(define (nstextview-pressure-configuration self)
  (wrap-objc-object
   (tell (coerce-arg self) pressureConfiguration)))
(define (nstextview-set-pressure-configuration! self value)
  (tell #:type _void (coerce-arg self) setPressureConfiguration: (coerce-arg value)))
(define (nstextview-previous-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) previousKeyView)))
(define (nstextview-previous-valid-key-view self)
  (wrap-objc-object
   (tell (coerce-arg self) previousValidKeyView)))
(define (nstextview-print-job-title self)
  (wrap-objc-object
   (tell (coerce-arg self) printJobTitle)))
(define (nstextview-range-for-user-character-attribute-change self)
  (tell #:type _NSRange (coerce-arg self) rangeForUserCharacterAttributeChange))
(define (nstextview-range-for-user-completion self)
  (tell #:type _NSRange (coerce-arg self) rangeForUserCompletion))
(define (nstextview-range-for-user-paragraph-attribute-change self)
  (tell #:type _NSRange (coerce-arg self) rangeForUserParagraphAttributeChange))
(define (nstextview-range-for-user-text-change self)
  (tell #:type _NSRange (coerce-arg self) rangeForUserTextChange))
(define (nstextview-ranges-for-user-character-attribute-change self)
  (wrap-objc-object
   (tell (coerce-arg self) rangesForUserCharacterAttributeChange)))
(define (nstextview-ranges-for-user-paragraph-attribute-change self)
  (wrap-objc-object
   (tell (coerce-arg self) rangesForUserParagraphAttributeChange)))
(define (nstextview-ranges-for-user-text-change self)
  (wrap-objc-object
   (tell (coerce-arg self) rangesForUserTextChange)))
(define (nstextview-readable-pasteboard-types self)
  (wrap-objc-object
   (tell (coerce-arg self) readablePasteboardTypes)))
(define (nstextview-rect-preserved-during-live-resize self)
  (tell #:type _NSRect (coerce-arg self) rectPreservedDuringLiveResize))
(define (nstextview-registered-dragged-types self)
  (wrap-objc-object
   (tell (coerce-arg self) registeredDraggedTypes)))
(define (nstextview-requires-constraint-based-layout)
  (tell #:type _bool NSTextView requiresConstraintBasedLayout))
(define (nstextview-restorable-state-key-paths)
  (wrap-objc-object
   (tell NSTextView restorableStateKeyPaths)))
(define (nstextview-rich-text self)
  (tell #:type _bool (coerce-arg self) richText))
(define (nstextview-set-rich-text! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setRichText:") value))
(define (nstextview-right-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) rightAnchor)))
(define (nstextview-rotated-from-base self)
  (tell #:type _bool (coerce-arg self) rotatedFromBase))
(define (nstextview-rotated-or-scaled-from-base self)
  (tell #:type _bool (coerce-arg self) rotatedOrScaledFromBase))
(define (nstextview-ruler-visible self)
  (tell #:type _bool (coerce-arg self) rulerVisible))
(define (nstextview-set-ruler-visible! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setRulerVisible:") value))
(define (nstextview-safe-area-insets self)
  (tell #:type _NSEdgeInsets (coerce-arg self) safeAreaInsets))
(define (nstextview-safe-area-layout-guide self)
  (wrap-objc-object
   (tell (coerce-arg self) safeAreaLayoutGuide)))
(define (nstextview-safe-area-rect self)
  (tell #:type _NSRect (coerce-arg self) safeAreaRect))
(define (nstextview-selectable self)
  (tell #:type _bool (coerce-arg self) selectable))
(define (nstextview-set-selectable! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setSelectable:") value))
(define (nstextview-selected-range self)
  (tell #:type _NSRange (coerce-arg self) selectedRange))
(define (nstextview-set-selected-range! self value)
  (_msg-21 (coerce-arg self) (sel_registerName "setSelectedRange:") value))
(define (nstextview-selected-ranges self)
  (wrap-objc-object
   (tell (coerce-arg self) selectedRanges)))
(define (nstextview-set-selected-ranges! self value)
  (tell #:type _void (coerce-arg self) setSelectedRanges: (coerce-arg value)))
(define (nstextview-selected-text-attributes self)
  (wrap-objc-object
   (tell (coerce-arg self) selectedTextAttributes)))
(define (nstextview-set-selected-text-attributes! self value)
  (tell #:type _void (coerce-arg self) setSelectedTextAttributes: (coerce-arg value)))
(define (nstextview-selection-affinity self)
  (tell #:type _uint64 (coerce-arg self) selectionAffinity))
(define (nstextview-selection-granularity self)
  (tell #:type _uint64 (coerce-arg self) selectionGranularity))
(define (nstextview-set-selection-granularity! self value)
  (_msg-72 (coerce-arg self) (sel_registerName "setSelectionGranularity:") value))
(define (nstextview-shadow self)
  (wrap-objc-object
   (tell (coerce-arg self) shadow)))
(define (nstextview-set-shadow! self value)
  (tell #:type _void (coerce-arg self) setShadow: (coerce-arg value)))
(define (nstextview-should-draw-insertion-point self)
  (tell #:type _bool (coerce-arg self) shouldDrawInsertionPoint))
(define (nstextview-smart-insert-delete-enabled self)
  (tell #:type _bool (coerce-arg self) smartInsertDeleteEnabled))
(define (nstextview-set-smart-insert-delete-enabled! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setSmartInsertDeleteEnabled:") value))
(define (nstextview-spell-checker-document-tag self)
  (tell #:type _int64 (coerce-arg self) spellCheckerDocumentTag))
(define (nstextview-string self)
  (wrap-objc-object
   (tell (coerce-arg self) string)))
(define (nstextview-set-string! self value)
  (tell #:type _void (coerce-arg self) setString: (coerce-arg value)))
(define (nstextview-strongly-references-text-storage)
  (tell #:type _bool NSTextView stronglyReferencesTextStorage))
(define (nstextview-subviews self)
  (wrap-objc-object
   (tell (coerce-arg self) subviews)))
(define (nstextview-set-subviews! self value)
  (tell #:type _void (coerce-arg self) setSubviews: (coerce-arg value)))
(define (nstextview-superview self)
  (wrap-objc-object
   (tell (coerce-arg self) superview)))
(define (nstextview-tag self)
  (tell #:type _int64 (coerce-arg self) tag))
(define (nstextview-text-color self)
  (wrap-objc-object
   (tell (coerce-arg self) textColor)))
(define (nstextview-set-text-color! self value)
  (tell #:type _void (coerce-arg self) setTextColor: (coerce-arg value)))
(define (nstextview-text-container self)
  (wrap-objc-object
   (tell (coerce-arg self) textContainer)))
(define (nstextview-set-text-container! self value)
  (tell #:type _void (coerce-arg self) setTextContainer: (coerce-arg value)))
(define (nstextview-text-container-inset self)
  (tell #:type _NSSize (coerce-arg self) textContainerInset))
(define (nstextview-set-text-container-inset! self value)
  (_msg-40 (coerce-arg self) (sel_registerName "setTextContainerInset:") value))
(define (nstextview-text-container-origin self)
  (tell #:type _NSPoint (coerce-arg self) textContainerOrigin))
(define (nstextview-text-content-storage self)
  (wrap-objc-object
   (tell (coerce-arg self) textContentStorage)))
(define (nstextview-text-highlight-attributes self)
  (wrap-objc-object
   (tell (coerce-arg self) textHighlightAttributes)))
(define (nstextview-set-text-highlight-attributes! self value)
  (tell #:type _void (coerce-arg self) setTextHighlightAttributes: (coerce-arg value)))
(define (nstextview-text-layout-manager self)
  (wrap-objc-object
   (tell (coerce-arg self) textLayoutManager)))
(define (nstextview-text-storage self)
  (wrap-objc-object
   (tell (coerce-arg self) textStorage)))
(define (nstextview-tool-tip self)
  (wrap-objc-object
   (tell (coerce-arg self) toolTip)))
(define (nstextview-set-tool-tip! self value)
  (tell #:type _void (coerce-arg self) setToolTip: (coerce-arg value)))
(define (nstextview-top-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) topAnchor)))
(define (nstextview-touch-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) touchBar)))
(define (nstextview-set-touch-bar! self value)
  (tell #:type _void (coerce-arg self) setTouchBar: (coerce-arg value)))
(define (nstextview-tracking-areas self)
  (wrap-objc-object
   (tell (coerce-arg self) trackingAreas)))
(define (nstextview-trailing-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) trailingAnchor)))
(define (nstextview-translates-autoresizing-mask-into-constraints self)
  (tell #:type _bool (coerce-arg self) translatesAutoresizingMaskIntoConstraints))
(define (nstextview-set-translates-autoresizing-mask-into-constraints! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setTranslatesAutoresizingMaskIntoConstraints:") value))
(define (nstextview-typing-attributes self)
  (wrap-objc-object
   (tell (coerce-arg self) typingAttributes)))
(define (nstextview-set-typing-attributes! self value)
  (tell #:type _void (coerce-arg self) setTypingAttributes: (coerce-arg value)))
(define (nstextview-undo-manager self)
  (wrap-objc-object
   (tell (coerce-arg self) undoManager)))
(define (nstextview-user-activity self)
  (wrap-objc-object
   (tell (coerce-arg self) userActivity)))
(define (nstextview-set-user-activity! self value)
  (tell #:type _void (coerce-arg self) setUserActivity: (coerce-arg value)))
(define (nstextview-user-interface-layout-direction self)
  (tell #:type _int64 (coerce-arg self) userInterfaceLayoutDirection))
(define (nstextview-set-user-interface-layout-direction! self value)
  (_msg-62 (coerce-arg self) (sel_registerName "setUserInterfaceLayoutDirection:") value))
(define (nstextview-uses-adaptive-color-mapping-for-dark-appearance self)
  (tell #:type _bool (coerce-arg self) usesAdaptiveColorMappingForDarkAppearance))
(define (nstextview-set-uses-adaptive-color-mapping-for-dark-appearance! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setUsesAdaptiveColorMappingForDarkAppearance:") value))
(define (nstextview-uses-find-bar self)
  (tell #:type _bool (coerce-arg self) usesFindBar))
(define (nstextview-set-uses-find-bar! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setUsesFindBar:") value))
(define (nstextview-uses-find-panel self)
  (tell #:type _bool (coerce-arg self) usesFindPanel))
(define (nstextview-set-uses-find-panel! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setUsesFindPanel:") value))
(define (nstextview-uses-font-panel self)
  (tell #:type _bool (coerce-arg self) usesFontPanel))
(define (nstextview-set-uses-font-panel! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setUsesFontPanel:") value))
(define (nstextview-uses-inspector-bar self)
  (tell #:type _bool (coerce-arg self) usesInspectorBar))
(define (nstextview-set-uses-inspector-bar! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setUsesInspectorBar:") value))
(define (nstextview-uses-rollover-button-for-selection self)
  (tell #:type _bool (coerce-arg self) usesRolloverButtonForSelection))
(define (nstextview-set-uses-rollover-button-for-selection! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setUsesRolloverButtonForSelection:") value))
(define (nstextview-uses-ruler self)
  (tell #:type _bool (coerce-arg self) usesRuler))
(define (nstextview-set-uses-ruler! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setUsesRuler:") value))
(define (nstextview-vertical-content-size-constraint-active self)
  (tell #:type _bool (coerce-arg self) verticalContentSizeConstraintActive))
(define (nstextview-set-vertical-content-size-constraint-active! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setVerticalContentSizeConstraintActive:") value))
(define (nstextview-vertically-resizable self)
  (tell #:type _bool (coerce-arg self) verticallyResizable))
(define (nstextview-set-vertically-resizable! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setVerticallyResizable:") value))
(define (nstextview-visible-rect self)
  (tell #:type _NSRect (coerce-arg self) visibleRect))
(define (nstextview-wants-best-resolution-open-gl-surface self)
  (tell #:type _bool (coerce-arg self) wantsBestResolutionOpenGLSurface))
(define (nstextview-set-wants-best-resolution-open-gl-surface! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setWantsBestResolutionOpenGLSurface:") value))
(define (nstextview-wants-default-clipping self)
  (tell #:type _bool (coerce-arg self) wantsDefaultClipping))
(define (nstextview-wants-extended-dynamic-range-open-gl-surface self)
  (tell #:type _bool (coerce-arg self) wantsExtendedDynamicRangeOpenGLSurface))
(define (nstextview-set-wants-extended-dynamic-range-open-gl-surface! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setWantsExtendedDynamicRangeOpenGLSurface:") value))
(define (nstextview-wants-layer self)
  (tell #:type _bool (coerce-arg self) wantsLayer))
(define (nstextview-set-wants-layer! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setWantsLayer:") value))
(define (nstextview-wants-resting-touches self)
  (tell #:type _bool (coerce-arg self) wantsRestingTouches))
(define (nstextview-set-wants-resting-touches! self value)
  (_msg-43 (coerce-arg self) (sel_registerName "setWantsRestingTouches:") value))
(define (nstextview-wants-update-layer self)
  (tell #:type _bool (coerce-arg self) wantsUpdateLayer))
(define (nstextview-width-adjust-limit self)
  (tell #:type _double (coerce-arg self) widthAdjustLimit))
(define (nstextview-width-anchor self)
  (wrap-objc-object
   (tell (coerce-arg self) widthAnchor)))
(define (nstextview-window self)
  (wrap-objc-object
   (tell (coerce-arg self) window)))
(define (nstextview-writable-pasteboard-types self)
  (wrap-objc-object
   (tell (coerce-arg self) writablePasteboardTypes)))
(define (nstextview-writing-tools-active self)
  (tell #:type _bool (coerce-arg self) writingToolsActive))
(define (nstextview-writing-tools-behavior self)
  (tell #:type _int64 (coerce-arg self) writingToolsBehavior))
(define (nstextview-set-writing-tools-behavior! self value)
  (_msg-62 (coerce-arg self) (sel_registerName "setWritingToolsBehavior:") value))
(define (nstextview-writing-tools-coordinator self)
  (wrap-objc-object
   (tell (coerce-arg self) writingToolsCoordinator)))
(define (nstextview-set-writing-tools-coordinator! self value)
  (tell #:type _void (coerce-arg self) setWritingToolsCoordinator: (coerce-arg value)))

;; --- Instance methods ---
(define (nstextview-rtfd-from-range self range)
  (wrap-objc-object
   (_msg-20 (coerce-arg self) (sel_registerName "RTFDFromRange:") range)
   ))
(define (nstextview-rtf-from-range self range)
  (wrap-objc-object
   (_msg-20 (coerce-arg self) (sel_registerName "RTFFromRange:") range)
   ))
(define (nstextview-accepts-first-mouse self event)
  (_msg-46 (coerce-arg self) (sel_registerName "acceptsFirstMouse:") (coerce-arg event)))
(define (nstextview-accessibility-activation-point self)
  (_msg-0 (coerce-arg self) (sel_registerName "accessibilityActivationPoint")))
(define (nstextview-accessibility-allowed-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAllowedValues)))
(define (nstextview-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityApplicationFocusedUIElement)))
(define (nstextview-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (_msg-20 (coerce-arg self) (sel_registerName "accessibilityAttributedStringForRange:") range)
   ))
(define (nstextview-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAttributedUserInputLabels)))
(define (nstextview-accessibility-cancel-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCancelButton)))
(define (nstextview-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (_msg-64 (coerce-arg self) (sel_registerName "accessibilityCellForColumn:row:") column row)
   ))
(define (nstextview-accessibility-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildren)))
(define (nstextview-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildrenInNavigationOrder)))
(define (nstextview-accessibility-clear-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityClearButton)))
(define (nstextview-accessibility-close-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCloseButton)))
(define (nstextview-accessibility-column-count self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityColumnCount")))
(define (nstextview-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnHeaderUIElements)))
(define (nstextview-accessibility-column-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityColumnIndexRange")))
(define (nstextview-accessibility-column-titles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnTitles)))
(define (nstextview-accessibility-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumns)))
(define (nstextview-accessibility-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityContents)))
(define (nstextview-accessibility-critical-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCriticalValue)))
(define (nstextview-accessibility-custom-actions self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomActions)))
(define (nstextview-accessibility-custom-rotors self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomRotors)))
(define (nstextview-accessibility-decrement-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDecrementButton)))
(define (nstextview-accessibility-default-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDefaultButton)))
(define (nstextview-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedByRow)))
(define (nstextview-accessibility-disclosed-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedRows)))
(define (nstextview-accessibility-disclosure-level self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityDisclosureLevel")))
(define (nstextview-accessibility-document self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDocument)))
(define (nstextview-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityExtrasMenuBar)))
(define (nstextview-accessibility-filename self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFilename)))
(define (nstextview-accessibility-focused-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFocusedWindow)))
(define (nstextview-accessibility-frame self)
  (_msg-2 (coerce-arg self) (sel_registerName "accessibilityFrame")))
(define (nstextview-accessibility-frame-for-range self range)
  (_msg-19 (coerce-arg self) (sel_registerName "accessibilityFrameForRange:") range))
(define (nstextview-accessibility-full-screen-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFullScreenButton)))
(define (nstextview-accessibility-grow-area self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityGrowArea)))
(define (nstextview-accessibility-handles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHandles)))
(define (nstextview-accessibility-header self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHeader)))
(define (nstextview-accessibility-help self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHelp)))
(define (nstextview-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalScrollBar)))
(define (nstextview-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalUnitDescription)))
(define (nstextview-accessibility-horizontal-units self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityHorizontalUnits")))
(define (nstextview-accessibility-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIdentifier)))
(define (nstextview-accessibility-increment-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIncrementButton)))
(define (nstextview-accessibility-index self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityIndex")))
(define (nstextview-accessibility-insertion-point-line-number self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityInsertionPointLineNumber")))
(define (nstextview-accessibility-label self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabel)))
(define (nstextview-accessibility-label-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabelUIElements)))
(define (nstextview-accessibility-label-value self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityLabelValue")))
(define (nstextview-accessibility-layout-point-for-screen-point self point)
  (_msg-10 (coerce-arg self) (sel_registerName "accessibilityLayoutPointForScreenPoint:") point))
(define (nstextview-accessibility-layout-size-for-screen-size self size)
  (_msg-39 (coerce-arg self) (sel_registerName "accessibilityLayoutSizeForScreenSize:") size))
(define (nstextview-accessibility-line-for-index self index)
  (_msg-61 (coerce-arg self) (sel_registerName "accessibilityLineForIndex:") index))
(define (nstextview-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLinkedUIElements)))
(define (nstextview-accessibility-main-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMainWindow)))
(define (nstextview-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerGroupUIElement)))
(define (nstextview-accessibility-marker-type-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerTypeDescription)))
(define (nstextview-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerUIElements)))
(define (nstextview-accessibility-marker-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerValues)))
(define (nstextview-accessibility-max-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMaxValue)))
(define (nstextview-accessibility-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMenuBar)))
(define (nstextview-accessibility-min-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinValue)))
(define (nstextview-accessibility-minimize-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinimizeButton)))
(define (nstextview-accessibility-next-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityNextContents)))
(define (nstextview-accessibility-number-of-characters self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityNumberOfCharacters")))
(define (nstextview-accessibility-orientation self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityOrientation")))
(define (nstextview-accessibility-overflow-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityOverflowButton)))
(define (nstextview-accessibility-parent self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityParent)))
(define (nstextview-accessibility-perform-cancel self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformCancel")))
(define (nstextview-accessibility-perform-confirm self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformConfirm")))
(define (nstextview-accessibility-perform-decrement self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformDecrement")))
(define (nstextview-accessibility-perform-delete self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformDelete")))
(define (nstextview-accessibility-perform-increment self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformIncrement")))
(define (nstextview-accessibility-perform-pick self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformPick")))
(define (nstextview-accessibility-perform-press self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformPress")))
(define (nstextview-accessibility-perform-raise self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformRaise")))
(define (nstextview-accessibility-perform-show-alternate-ui self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformShowAlternateUI")))
(define (nstextview-accessibility-perform-show-default-ui self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformShowDefaultUI")))
(define (nstextview-accessibility-perform-show-menu self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformShowMenu")))
(define (nstextview-accessibility-placeholder-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPlaceholderValue)))
(define (nstextview-accessibility-previous-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPreviousContents)))
(define (nstextview-accessibility-proxy self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityProxy)))
(define (nstextview-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (_msg-20 (coerce-arg self) (sel_registerName "accessibilityRTFForRange:") range)
   ))
(define (nstextview-accessibility-range-for-index self index)
  (_msg-58 (coerce-arg self) (sel_registerName "accessibilityRangeForIndex:") index))
(define (nstextview-accessibility-range-for-line self line-number)
  (_msg-58 (coerce-arg self) (sel_registerName "accessibilityRangeForLine:") line-number))
(define (nstextview-accessibility-range-for-position self point)
  (_msg-11 (coerce-arg self) (sel_registerName "accessibilityRangeForPosition:") point))
(define (nstextview-accessibility-role self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRole)))
(define (nstextview-accessibility-role-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRoleDescription)))
(define (nstextview-accessibility-row-count self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityRowCount")))
(define (nstextview-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRowHeaderUIElements)))
(define (nstextview-accessibility-row-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityRowIndexRange")))
(define (nstextview-accessibility-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRows)))
(define (nstextview-accessibility-ruler-marker-type self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityRulerMarkerType")))
(define (nstextview-accessibility-screen-point-for-layout-point self point)
  (_msg-10 (coerce-arg self) (sel_registerName "accessibilityScreenPointForLayoutPoint:") point))
(define (nstextview-accessibility-screen-size-for-layout-size self size)
  (_msg-39 (coerce-arg self) (sel_registerName "accessibilityScreenSizeForLayoutSize:") size))
(define (nstextview-accessibility-search-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchButton)))
(define (nstextview-accessibility-search-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchMenu)))
(define (nstextview-accessibility-selected-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedCells)))
(define (nstextview-accessibility-selected-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedChildren)))
(define (nstextview-accessibility-selected-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedColumns)))
(define (nstextview-accessibility-selected-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedRows)))
(define (nstextview-accessibility-selected-text self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedText)))
(define (nstextview-accessibility-selected-text-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySelectedTextRange")))
(define (nstextview-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedTextRanges)))
(define (nstextview-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityServesAsTitleForUIElements)))
(define (nstextview-accessibility-shared-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySharedCharacterRange")))
(define (nstextview-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedFocusElements)))
(define (nstextview-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedTextUIElements)))
(define (nstextview-accessibility-shown-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityShownMenu)))
(define (nstextview-accessibility-sort-direction self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilitySortDirection")))
(define (nstextview-accessibility-splitters self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySplitters)))
(define (nstextview-accessibility-string-for-range self range)
  (wrap-objc-object
   (_msg-20 (coerce-arg self) (sel_registerName "accessibilityStringForRange:") range)
   ))
(define (nstextview-accessibility-style-range-for-index self index)
  (_msg-58 (coerce-arg self) (sel_registerName "accessibilityStyleRangeForIndex:") index))
(define (nstextview-accessibility-subrole self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySubrole)))
(define (nstextview-accessibility-tabs self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTabs)))
(define (nstextview-accessibility-title self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitle)))
(define (nstextview-accessibility-title-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitleUIElement)))
(define (nstextview-accessibility-toolbar-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityToolbarButton)))
(define (nstextview-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTopLevelUIElement)))
(define (nstextview-accessibility-url self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityURL)))
(define (nstextview-accessibility-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUnitDescription)))
(define (nstextview-accessibility-units self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityUnits")))
(define (nstextview-accessibility-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUserInputLabels)))
(define (nstextview-accessibility-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValue)))
(define (nstextview-accessibility-value-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValueDescription)))
(define (nstextview-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalScrollBar)))
(define (nstextview-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalUnitDescription)))
(define (nstextview-accessibility-vertical-units self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityVerticalUnits")))
(define (nstextview-accessibility-visible-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleCells)))
(define (nstextview-accessibility-visible-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityVisibleCharacterRange")))
(define (nstextview-accessibility-visible-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleChildren)))
(define (nstextview-accessibility-visible-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleColumns)))
(define (nstextview-accessibility-visible-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleRows)))
(define (nstextview-accessibility-warning-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWarningValue)))
(define (nstextview-accessibility-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindow)))
(define (nstextview-accessibility-windows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindows)))
(define (nstextview-accessibility-zoom-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityZoomButton)))
(define (nstextview-add-subview! self view)
  (tell #:type _void (coerce-arg self) addSubview: (coerce-arg view)))
(define (nstextview-add-subview-positioned-relative-to! self view place other-view)
  (_msg-56 (coerce-arg self) (sel_registerName "addSubview:positioned:relativeTo:") (coerce-arg view) place (coerce-arg other-view)))
(define (nstextview-add-tool-tip-rect-owner-user-data! self rect owner data)
  (_msg-37 (coerce-arg self) (sel_registerName "addToolTipRect:owner:userData:") rect (coerce-arg owner) data))
(define (nstextview-adjust-scroll self new-visible)
  (_msg-27 (coerce-arg self) (sel_registerName "adjustScroll:") new-visible))
(define (nstextview-align-center self sender)
  (tell #:type _void (coerce-arg self) alignCenter: (coerce-arg sender)))
(define (nstextview-align-justified self sender)
  (tell #:type _void (coerce-arg self) alignJustified: (coerce-arg sender)))
(define (nstextview-align-left self sender)
  (tell #:type _void (coerce-arg self) alignLeft: (coerce-arg sender)))
(define (nstextview-align-right self sender)
  (tell #:type _void (coerce-arg self) alignRight: (coerce-arg sender)))
(define (nstextview-ancestor-shared-with-view self view)
  (wrap-objc-object
   (tell (coerce-arg self) ancestorSharedWithView: (coerce-arg view))))
(define (nstextview-animation-for-key self key)
  (wrap-objc-object
   (tell (coerce-arg self) animationForKey: (coerce-arg key))))
(define (nstextview-animations self)
  (wrap-objc-object
   (tell (coerce-arg self) animations)))
(define (nstextview-animator self)
  (wrap-objc-object
   (tell (coerce-arg self) animator)))
(define (nstextview-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) appearance)))
(define (nstextview-attributed-string self)
  (wrap-objc-object
   (tell (coerce-arg self) attributedString)))
(define (nstextview-attributed-substring-for-proposed-range-actual-range self range actual-range)
  (wrap-objc-object
   (_msg-25 (coerce-arg self) (sel_registerName "attributedSubstringForProposedRange:actualRange:") range actual-range)
   ))
(define (nstextview-autoscroll self event)
  (_msg-46 (coerce-arg self) (sel_registerName "autoscroll:") (coerce-arg event)))
(define (nstextview-backing-aligned-rect-options self rect options)
  (_msg-38 (coerce-arg self) (sel_registerName "backingAlignedRect:options:") rect options))
(define (nstextview-baseline-delta-for-character-at-index self an-index)
  (_msg-71 (coerce-arg self) (sel_registerName "baselineDeltaForCharacterAtIndex:") an-index))
(define (nstextview-become-first-responder self)
  (_msg-4 (coerce-arg self) (sel_registerName "becomeFirstResponder")))
(define (nstextview-begin-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) beginGestureWithEvent: (coerce-arg event)))
(define (nstextview-bitmap-image-rep-for-caching-display-in-rect self rect)
  (wrap-objc-object
   (_msg-29 (coerce-arg self) (sel_registerName "bitmapImageRepForCachingDisplayInRect:") rect)
   ))
(define (nstextview-cache-display-in-rect-to-bitmap-image-rep self rect bitmap-image-rep)
  (_msg-35 (coerce-arg self) (sel_registerName "cacheDisplayInRect:toBitmapImageRep:") rect (coerce-arg bitmap-image-rep)))
(define (nstextview-cancel-operation self sender)
  (tell #:type _void (coerce-arg self) cancelOperation: (coerce-arg sender)))
(define (nstextview-capitalize-word self sender)
  (tell #:type _void (coerce-arg self) capitalizeWord: (coerce-arg sender)))
(define (nstextview-center-scan-rect! self rect)
  (_msg-27 (coerce-arg self) (sel_registerName "centerScanRect:") rect))
(define (nstextview-center-selection-in-visible-area! self sender)
  (tell #:type _void (coerce-arg self) centerSelectionInVisibleArea: (coerce-arg sender)))
(define (nstextview-change-attributes self sender)
  (tell #:type _void (coerce-arg self) changeAttributes: (coerce-arg sender)))
(define (nstextview-change-case-of-letter self sender)
  (tell #:type _void (coerce-arg self) changeCaseOfLetter: (coerce-arg sender)))
(define (nstextview-change-color self sender)
  (tell #:type _void (coerce-arg self) changeColor: (coerce-arg sender)))
(define (nstextview-change-document-background-color self sender)
  (tell #:type _void (coerce-arg self) changeDocumentBackgroundColor: (coerce-arg sender)))
(define (nstextview-change-font self sender)
  (tell #:type _void (coerce-arg self) changeFont: (coerce-arg sender)))
(define (nstextview-change-layout-orientation self sender)
  (tell #:type _void (coerce-arg self) changeLayoutOrientation: (coerce-arg sender)))
(define (nstextview-change-mode-with-event self event)
  (tell #:type _void (coerce-arg self) changeModeWithEvent: (coerce-arg event)))
(define (nstextview-change-spelling self sender)
  (tell #:type _void (coerce-arg self) changeSpelling: (coerce-arg sender)))
(define (nstextview-character-index-for-insertion-at-point self point)
  (_msg-14 (coerce-arg self) (sel_registerName "characterIndexForInsertionAtPoint:") point))
(define (nstextview-check-spelling self sender)
  (tell #:type _void (coerce-arg self) checkSpelling: (coerce-arg sender)))
(define (nstextview-clicked-on-link-at-index self link char-index)
  (_msg-57 (coerce-arg self) (sel_registerName "clickedOnLink:atIndex:") (coerce-arg link) char-index))
(define (nstextview-complete self sender)
  (tell #:type _void (coerce-arg self) complete: (coerce-arg sender)))
(define (nstextview-conclude-drag-operation self sender)
  (tell #:type _void (coerce-arg self) concludeDragOperation: (coerce-arg sender)))
(define (nstextview-content-type self)
  (wrap-objc-object
   (tell (coerce-arg self) contentType)))
(define (nstextview-context-menu-key-down self event)
  (tell #:type _void (coerce-arg self) contextMenuKeyDown: (coerce-arg event)))
(define (nstextview-convert-point-from-view self point view)
  (_msg-18 (coerce-arg self) (sel_registerName "convertPoint:fromView:") point (coerce-arg view)))
(define (nstextview-convert-point-to-view self point view)
  (_msg-18 (coerce-arg self) (sel_registerName "convertPoint:toView:") point (coerce-arg view)))
(define (nstextview-convert-point-from-backing self point)
  (_msg-10 (coerce-arg self) (sel_registerName "convertPointFromBacking:") point))
(define (nstextview-convert-point-from-layer self point)
  (_msg-10 (coerce-arg self) (sel_registerName "convertPointFromLayer:") point))
(define (nstextview-convert-point-to-backing self point)
  (_msg-10 (coerce-arg self) (sel_registerName "convertPointToBacking:") point))
(define (nstextview-convert-point-to-layer self point)
  (_msg-10 (coerce-arg self) (sel_registerName "convertPointToLayer:") point))
(define (nstextview-convert-rect-from-view self rect view)
  (_msg-33 (coerce-arg self) (sel_registerName "convertRect:fromView:") rect (coerce-arg view)))
(define (nstextview-convert-rect-to-view self rect view)
  (_msg-33 (coerce-arg self) (sel_registerName "convertRect:toView:") rect (coerce-arg view)))
(define (nstextview-convert-rect-from-backing self rect)
  (_msg-27 (coerce-arg self) (sel_registerName "convertRectFromBacking:") rect))
(define (nstextview-convert-rect-from-layer self rect)
  (_msg-27 (coerce-arg self) (sel_registerName "convertRectFromLayer:") rect))
(define (nstextview-convert-rect-to-backing self rect)
  (_msg-27 (coerce-arg self) (sel_registerName "convertRectToBacking:") rect))
(define (nstextview-convert-rect-to-layer self rect)
  (_msg-27 (coerce-arg self) (sel_registerName "convertRectToLayer:") rect))
(define (nstextview-convert-size-from-view self size view)
  (_msg-41 (coerce-arg self) (sel_registerName "convertSize:fromView:") size (coerce-arg view)))
(define (nstextview-convert-size-to-view self size view)
  (_msg-41 (coerce-arg self) (sel_registerName "convertSize:toView:") size (coerce-arg view)))
(define (nstextview-convert-size-from-backing self size)
  (_msg-39 (coerce-arg self) (sel_registerName "convertSizeFromBacking:") size))
(define (nstextview-convert-size-from-layer self size)
  (_msg-39 (coerce-arg self) (sel_registerName "convertSizeFromLayer:") size))
(define (nstextview-convert-size-to-backing self size)
  (_msg-39 (coerce-arg self) (sel_registerName "convertSizeToBacking:") size))
(define (nstextview-convert-size-to-layer self size)
  (_msg-39 (coerce-arg self) (sel_registerName "convertSizeToLayer:") size))
(define (nstextview-copy self sender)
  (tell #:type _void (coerce-arg self) copy: (coerce-arg sender)))
(define (nstextview-copy-font self sender)
  (tell #:type _void (coerce-arg self) copyFont: (coerce-arg sender)))
(define (nstextview-copy-ruler self sender)
  (tell #:type _void (coerce-arg self) copyRuler: (coerce-arg sender)))
(define (nstextview-cursor-update self event)
  (tell #:type _void (coerce-arg self) cursorUpdate: (coerce-arg event)))
(define (nstextview-cut self sender)
  (tell #:type _void (coerce-arg self) cut: (coerce-arg sender)))
(define (nstextview-delete self sender)
  (tell #:type _void (coerce-arg self) delete: (coerce-arg sender)))
(define (nstextview-delete-backward self sender)
  (tell #:type _void (coerce-arg self) deleteBackward: (coerce-arg sender)))
(define (nstextview-delete-backward-by-decomposing-previous-character self sender)
  (tell #:type _void (coerce-arg self) deleteBackwardByDecomposingPreviousCharacter: (coerce-arg sender)))
(define (nstextview-delete-forward self sender)
  (tell #:type _void (coerce-arg self) deleteForward: (coerce-arg sender)))
(define (nstextview-delete-to-beginning-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfLine: (coerce-arg sender)))
(define (nstextview-delete-to-beginning-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfParagraph: (coerce-arg sender)))
(define (nstextview-delete-to-end-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfLine: (coerce-arg sender)))
(define (nstextview-delete-to-end-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfParagraph: (coerce-arg sender)))
(define (nstextview-delete-to-mark self sender)
  (tell #:type _void (coerce-arg self) deleteToMark: (coerce-arg sender)))
(define (nstextview-delete-word-backward self sender)
  (tell #:type _void (coerce-arg self) deleteWordBackward: (coerce-arg sender)))
(define (nstextview-delete-word-forward self sender)
  (tell #:type _void (coerce-arg self) deleteWordForward: (coerce-arg sender)))
(define (nstextview-did-add-subview self subview)
  (tell #:type _void (coerce-arg self) didAddSubview: (coerce-arg subview)))
(define (nstextview-did-close-menu-with-event self menu event)
  (tell #:type _void (coerce-arg self) didCloseMenu: (coerce-arg menu) withEvent: (coerce-arg event)))
(define (nstextview-display! self)
  (tell #:type _void (coerce-arg self) display))
(define (nstextview-display-if-needed! self)
  (tell #:type _void (coerce-arg self) displayIfNeeded))
(define (nstextview-display-if-needed-ignoring-opacity! self)
  (tell #:type _void (coerce-arg self) displayIfNeededIgnoringOpacity))
(define (nstextview-display-if-needed-in-rect! self rect)
  (_msg-30 (coerce-arg self) (sel_registerName "displayIfNeededInRect:") rect))
(define (nstextview-display-if-needed-in-rect-ignoring-opacity! self rect)
  (_msg-30 (coerce-arg self) (sel_registerName "displayIfNeededInRectIgnoringOpacity:") rect))
(define (nstextview-display-rect! self rect)
  (_msg-30 (coerce-arg self) (sel_registerName "displayRect:") rect))
(define (nstextview-display-rect-ignoring-opacity! self rect)
  (_msg-30 (coerce-arg self) (sel_registerName "displayRectIgnoringOpacity:") rect))
(define (nstextview-display-rect-ignoring-opacity-in-context! self rect context)
  (_msg-35 (coerce-arg self) (sel_registerName "displayRectIgnoringOpacity:inContext:") rect (coerce-arg context)))
(define (nstextview-document-visible-rect self)
  (_msg-2 (coerce-arg self) (sel_registerName "documentVisibleRect")))
(define (nstextview-dragging-ended self sender)
  (tell #:type _void (coerce-arg self) draggingEnded: (coerce-arg sender)))
(define (nstextview-dragging-entered self sender)
  (_msg-47 (coerce-arg self) (sel_registerName "draggingEntered:") (coerce-arg sender)))
(define (nstextview-dragging-exited self sender)
  (tell #:type _void (coerce-arg self) draggingExited: (coerce-arg sender)))
(define (nstextview-dragging-session-ended-at-point-operation self session screen-point operation)
  (_msg-49 (coerce-arg self) (sel_registerName "draggingSession:endedAtPoint:operation:") (coerce-arg session) screen-point operation))
(define (nstextview-dragging-session-moved-to-point self session screen-point)
  (_msg-48 (coerce-arg self) (sel_registerName "draggingSession:movedToPoint:") (coerce-arg session) screen-point))
(define (nstextview-dragging-session-source-operation-mask-for-dragging-context self session context)
  (_msg-55 (coerce-arg self) (sel_registerName "draggingSession:sourceOperationMaskForDraggingContext:") (coerce-arg session) context))
(define (nstextview-dragging-session-will-begin-at-point self session screen-point)
  (_msg-48 (coerce-arg self) (sel_registerName "draggingSession:willBeginAtPoint:") (coerce-arg session) screen-point))
(define (nstextview-dragging-updated self sender)
  (_msg-47 (coerce-arg self) (sel_registerName "draggingUpdated:") (coerce-arg sender)))
(define (nstextview-draw-insertion-point-in-rect-color-turned-on self rect color flag)
  (_msg-36 (coerce-arg self) (sel_registerName "drawInsertionPointInRect:color:turnedOn:") rect (coerce-arg color) flag))
(define (nstextview-draw-rect self dirty-rect)
  (_msg-30 (coerce-arg self) (sel_registerName "drawRect:") dirty-rect))
(define (nstextview-draw-view-background-in-rect self rect)
  (_msg-30 (coerce-arg self) (sel_registerName "drawViewBackgroundInRect:") rect))
(define (nstextview-draws-vertically-for-character-at-index self char-index)
  (_msg-70 (coerce-arg self) (sel_registerName "drawsVerticallyForCharacterAtIndex:") char-index))
(define (nstextview-effective-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) effectiveAppearance)))
(define (nstextview-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nstextview-end-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) endGestureWithEvent: (coerce-arg event)))
(define (nstextview-first-rect-for-character-range-actual-range self range actual-range)
  (_msg-24 (coerce-arg self) (sel_registerName "firstRectForCharacterRange:actualRange:") range actual-range))
(define (nstextview-flags-changed self event)
  (tell #:type _void (coerce-arg self) flagsChanged: (coerce-arg event)))
(define (nstextview-flush-buffered-key-events self)
  (tell #:type _void (coerce-arg self) flushBufferedKeyEvents))
(define (nstextview-fraction-of-distance-through-glyph-for-point self point)
  (_msg-12 (coerce-arg self) (sel_registerName "fractionOfDistanceThroughGlyphForPoint:") point))
(define (nstextview-get-rects-being-drawn-count self rects count)
  (_msg-69 (coerce-arg self) (sel_registerName "getRectsBeingDrawn:count:") rects count))
(define (nstextview-get-rects-exposed-during-live-resize-count self exposed-rects count)
  (_msg-69 (coerce-arg self) (sel_registerName "getRectsExposedDuringLiveResize:count:") exposed-rects count))
(define (nstextview-help-requested self event-ptr)
  (tell #:type _void (coerce-arg self) helpRequested: (coerce-arg event-ptr)))
(define (nstextview-hit-test self point)
  (wrap-objc-object
   (_msg-13 (coerce-arg self) (sel_registerName "hitTest:") point)
   ))
(define (nstextview-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) identifier)))
(define (nstextview-ignore-modifier-keys-for-dragging-session self session)
  (_msg-46 (coerce-arg self) (sel_registerName "ignoreModifierKeysForDraggingSession:") (coerce-arg session)))
(define (nstextview-ignore-spelling self sender)
  (tell #:type _void (coerce-arg self) ignoreSpelling: (coerce-arg sender)))
(define (nstextview-indent self sender)
  (tell #:type _void (coerce-arg self) indent: (coerce-arg sender)))
(define (nstextview-init-using-text-layout-manager self using-text-layout-manager)
  (wrap-objc-object
   (_msg-42 (coerce-arg self) (sel_registerName "initUsingTextLayoutManager:") using-text-layout-manager)
   #:retained #t))
(define (nstextview-insert-adaptive-image-glyph-replacement-range! self adaptive-image-glyph replacement-range)
  (_msg-50 (coerce-arg self) (sel_registerName "insertAdaptiveImageGlyph:replacementRange:") (coerce-arg adaptive-image-glyph) replacement-range))
(define (nstextview-insert-backtab! self sender)
  (tell #:type _void (coerce-arg self) insertBacktab: (coerce-arg sender)))
(define (nstextview-insert-container-break! self sender)
  (tell #:type _void (coerce-arg self) insertContainerBreak: (coerce-arg sender)))
(define (nstextview-insert-double-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertDoubleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nstextview-insert-line-break! self sender)
  (tell #:type _void (coerce-arg self) insertLineBreak: (coerce-arg sender)))
(define (nstextview-insert-newline! self sender)
  (tell #:type _void (coerce-arg self) insertNewline: (coerce-arg sender)))
(define (nstextview-insert-newline-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertNewlineIgnoringFieldEditor: (coerce-arg sender)))
(define (nstextview-insert-paragraph-separator! self sender)
  (tell #:type _void (coerce-arg self) insertParagraphSeparator: (coerce-arg sender)))
(define (nstextview-insert-single-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertSingleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nstextview-insert-tab! self sender)
  (tell #:type _void (coerce-arg self) insertTab: (coerce-arg sender)))
(define (nstextview-insert-tab-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertTabIgnoringFieldEditor: (coerce-arg sender)))
(define (nstextview-insert-text-replacement-range! self string replacement-range)
  (_msg-50 (coerce-arg self) (sel_registerName "insertText:replacementRange:") (coerce-arg string) replacement-range))
(define (nstextview-interpret-key-events self event-array)
  (tell #:type _void (coerce-arg self) interpretKeyEvents: (coerce-arg event-array)))
(define (nstextview-invalidate-text-container-origin self)
  (tell #:type _void (coerce-arg self) invalidateTextContainerOrigin))
(define (nstextview-is-accessibility-alternate-ui-visible self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityAlternateUIVisible")))
(define (nstextview-is-accessibility-disclosed self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityDisclosed")))
(define (nstextview-is-accessibility-edited self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityEdited")))
(define (nstextview-is-accessibility-element self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityElement")))
(define (nstextview-is-accessibility-enabled self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityEnabled")))
(define (nstextview-is-accessibility-expanded self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityExpanded")))
(define (nstextview-is-accessibility-focused self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityFocused")))
(define (nstextview-is-accessibility-frontmost self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityFrontmost")))
(define (nstextview-is-accessibility-hidden self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityHidden")))
(define (nstextview-is-accessibility-main self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityMain")))
(define (nstextview-is-accessibility-minimized self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityMinimized")))
(define (nstextview-is-accessibility-modal self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityModal")))
(define (nstextview-is-accessibility-ordered-by-row self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityOrderedByRow")))
(define (nstextview-is-accessibility-protected-content self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityProtectedContent")))
(define (nstextview-is-accessibility-required self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityRequired")))
(define (nstextview-is-accessibility-selected self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilitySelected")))
(define (nstextview-is-accessibility-selector-allowed self selector)
  (_msg-65 (coerce-arg self) (sel_registerName "isAccessibilitySelectorAllowed:") (sel_registerName selector)))
(define (nstextview-is-descendant-of self view)
  (_msg-46 (coerce-arg self) (sel_registerName "isDescendantOf:") (coerce-arg view)))
(define (nstextview-is-editable self)
  (_msg-4 (coerce-arg self) (sel_registerName "isEditable")))
(define (nstextview-is-field-editor self)
  (_msg-4 (coerce-arg self) (sel_registerName "isFieldEditor")))
(define (nstextview-is-flipped self)
  (_msg-4 (coerce-arg self) (sel_registerName "isFlipped")))
(define (nstextview-is-hidden self)
  (_msg-4 (coerce-arg self) (sel_registerName "isHidden")))
(define (nstextview-is-hidden-or-has-hidden-ancestor self)
  (_msg-4 (coerce-arg self) (sel_registerName "isHiddenOrHasHiddenAncestor")))
(define (nstextview-is-horizontally-resizable self)
  (_msg-4 (coerce-arg self) (sel_registerName "isHorizontallyResizable")))
(define (nstextview-is-opaque self)
  (_msg-4 (coerce-arg self) (sel_registerName "isOpaque")))
(define (nstextview-is-rich-text self)
  (_msg-4 (coerce-arg self) (sel_registerName "isRichText")))
(define (nstextview-is-rotated-from-base self)
  (_msg-4 (coerce-arg self) (sel_registerName "isRotatedFromBase")))
(define (nstextview-is-rotated-or-scaled-from-base self)
  (_msg-4 (coerce-arg self) (sel_registerName "isRotatedOrScaledFromBase")))
(define (nstextview-is-ruler-visible self)
  (_msg-4 (coerce-arg self) (sel_registerName "isRulerVisible")))
(define (nstextview-is-selectable self)
  (_msg-4 (coerce-arg self) (sel_registerName "isSelectable")))
(define (nstextview-is-vertically-resizable self)
  (_msg-4 (coerce-arg self) (sel_registerName "isVerticallyResizable")))
(define (nstextview-key-down self event)
  (tell #:type _void (coerce-arg self) keyDown: (coerce-arg event)))
(define (nstextview-key-up self event)
  (tell #:type _void (coerce-arg self) keyUp: (coerce-arg event)))
(define (nstextview-layout self)
  (tell #:type _void (coerce-arg self) layout))
(define (nstextview-layout-orientation self)
  (_msg-7 (coerce-arg self) (sel_registerName "layoutOrientation")))
(define (nstextview-layout-subtree-if-needed self)
  (tell #:type _void (coerce-arg self) layoutSubtreeIfNeeded))
(define (nstextview-loosen-kerning self sender)
  (tell #:type _void (coerce-arg self) loosenKerning: (coerce-arg sender)))
(define (nstextview-lower-baseline self sender)
  (tell #:type _void (coerce-arg self) lowerBaseline: (coerce-arg sender)))
(define (nstextview-lowercase-word self sender)
  (tell #:type _void (coerce-arg self) lowercaseWord: (coerce-arg sender)))
(define (nstextview-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) magnifyWithEvent: (coerce-arg event)))
(define (nstextview-make-backing-layer self)
  (wrap-objc-object
   (tell (coerce-arg self) makeBackingLayer)))
(define (nstextview-make-base-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nstextview-make-base-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionNatural: (coerce-arg sender)))
(define (nstextview-make-base-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nstextview-make-text-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nstextview-make-text-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionNatural: (coerce-arg sender)))
(define (nstextview-make-text-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nstextview-menu-for-event self event)
  (wrap-objc-object
   (tell (coerce-arg self) menuForEvent: (coerce-arg event))))
(define (nstextview-mouse-in-rect self point rect)
  (_msg-17 (coerce-arg self) (sel_registerName "mouse:inRect:") point rect))
(define (nstextview-mouse-cancelled self event)
  (tell #:type _void (coerce-arg self) mouseCancelled: (coerce-arg event)))
(define (nstextview-mouse-down self event)
  (tell #:type _void (coerce-arg self) mouseDown: (coerce-arg event)))
(define (nstextview-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) mouseDragged: (coerce-arg event)))
(define (nstextview-mouse-entered self event)
  (tell #:type _void (coerce-arg self) mouseEntered: (coerce-arg event)))
(define (nstextview-mouse-exited self event)
  (tell #:type _void (coerce-arg self) mouseExited: (coerce-arg event)))
(define (nstextview-mouse-moved self event)
  (tell #:type _void (coerce-arg self) mouseMoved: (coerce-arg event)))
(define (nstextview-mouse-up self event)
  (tell #:type _void (coerce-arg self) mouseUp: (coerce-arg event)))
(define (nstextview-move-backward! self sender)
  (tell #:type _void (coerce-arg self) moveBackward: (coerce-arg sender)))
(define (nstextview-move-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveBackwardAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-down! self sender)
  (tell #:type _void (coerce-arg self) moveDown: (coerce-arg sender)))
(define (nstextview-move-down-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveDownAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-forward! self sender)
  (tell #:type _void (coerce-arg self) moveForward: (coerce-arg sender)))
(define (nstextview-move-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveForwardAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-left! self sender)
  (tell #:type _void (coerce-arg self) moveLeft: (coerce-arg sender)))
(define (nstextview-move-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveLeftAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-paragraph-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphBackwardAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-paragraph-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphForwardAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-right! self sender)
  (tell #:type _void (coerce-arg self) moveRight: (coerce-arg sender)))
(define (nstextview-move-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveRightAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-to-beginning-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocument: (coerce-arg sender)))
(define (nstextview-move-to-beginning-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-to-beginning-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLine: (coerce-arg sender)))
(define (nstextview-move-to-beginning-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLineAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-to-beginning-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraph: (coerce-arg sender)))
(define (nstextview-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-to-end-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocument: (coerce-arg sender)))
(define (nstextview-move-to-end-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-to-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLine: (coerce-arg sender)))
(define (nstextview-move-to-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-to-end-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraph: (coerce-arg sender)))
(define (nstextview-move-to-end-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-to-left-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLine: (coerce-arg sender)))
(define (nstextview-move-to-left-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-to-right-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLine: (coerce-arg sender)))
(define (nstextview-move-to-right-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-up! self sender)
  (tell #:type _void (coerce-arg self) moveUp: (coerce-arg sender)))
(define (nstextview-move-up-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveUpAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-word-backward! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackward: (coerce-arg sender)))
(define (nstextview-move-word-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackwardAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-word-forward! self sender)
  (tell #:type _void (coerce-arg self) moveWordForward: (coerce-arg sender)))
(define (nstextview-move-word-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordForwardAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-word-left! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeft: (coerce-arg sender)))
(define (nstextview-move-word-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeftAndModifySelection: (coerce-arg sender)))
(define (nstextview-move-word-right! self sender)
  (tell #:type _void (coerce-arg self) moveWordRight: (coerce-arg sender)))
(define (nstextview-move-word-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordRightAndModifySelection: (coerce-arg sender)))
(define (nstextview-needs-to-draw-rect self rect)
  (_msg-28 (coerce-arg self) (sel_registerName "needsToDrawRect:") rect))
(define (nstextview-no-responder-for self event-selector)
  (_msg-66 (coerce-arg self) (sel_registerName "noResponderFor:") (sel_registerName event-selector)))
(define (nstextview-order-front-link-panel! self sender)
  (tell #:type _void (coerce-arg self) orderFrontLinkPanel: (coerce-arg sender)))
(define (nstextview-order-front-list-panel! self sender)
  (tell #:type _void (coerce-arg self) orderFrontListPanel: (coerce-arg sender)))
(define (nstextview-order-front-spacing-panel! self sender)
  (tell #:type _void (coerce-arg self) orderFrontSpacingPanel: (coerce-arg sender)))
(define (nstextview-order-front-table-panel! self sender)
  (tell #:type _void (coerce-arg self) orderFrontTablePanel: (coerce-arg sender)))
(define (nstextview-other-mouse-down self event)
  (tell #:type _void (coerce-arg self) otherMouseDown: (coerce-arg event)))
(define (nstextview-other-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) otherMouseDragged: (coerce-arg event)))
(define (nstextview-other-mouse-up self event)
  (tell #:type _void (coerce-arg self) otherMouseUp: (coerce-arg event)))
(define (nstextview-outline self sender)
  (tell #:type _void (coerce-arg self) outline: (coerce-arg sender)))
(define (nstextview-page-down self sender)
  (tell #:type _void (coerce-arg self) pageDown: (coerce-arg sender)))
(define (nstextview-page-down-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageDownAndModifySelection: (coerce-arg sender)))
(define (nstextview-page-up self sender)
  (tell #:type _void (coerce-arg self) pageUp: (coerce-arg sender)))
(define (nstextview-page-up-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageUpAndModifySelection: (coerce-arg sender)))
(define (nstextview-paste self sender)
  (tell #:type _void (coerce-arg self) paste: (coerce-arg sender)))
(define (nstextview-paste-font self sender)
  (tell #:type _void (coerce-arg self) pasteFont: (coerce-arg sender)))
(define (nstextview-paste-ruler self sender)
  (tell #:type _void (coerce-arg self) pasteRuler: (coerce-arg sender)))
(define (nstextview-perform-drag-operation! self sender)
  (_msg-46 (coerce-arg self) (sel_registerName "performDragOperation:") (coerce-arg sender)))
(define (nstextview-perform-find-panel-action! self sender)
  (tell #:type _void (coerce-arg self) performFindPanelAction: (coerce-arg sender)))
(define (nstextview-perform-key-equivalent! self event)
  (_msg-46 (coerce-arg self) (sel_registerName "performKeyEquivalent:") (coerce-arg event)))
(define (nstextview-perform-validated-replacement-in-range-with-attributed-string! self range attributed-string)
  (_msg-22 (coerce-arg self) (sel_registerName "performValidatedReplacementInRange:withAttributedString:") range (coerce-arg attributed-string)))
(define (nstextview-preferred-text-accessory-placement self)
  (_msg-7 (coerce-arg self) (sel_registerName "preferredTextAccessoryPlacement")))
(define (nstextview-prepare-content-in-rect self rect)
  (_msg-30 (coerce-arg self) (sel_registerName "prepareContentInRect:") rect))
(define (nstextview-prepare-for-drag-operation self sender)
  (_msg-46 (coerce-arg self) (sel_registerName "prepareForDragOperation:") (coerce-arg sender)))
(define (nstextview-prepare-for-reuse self)
  (tell #:type _void (coerce-arg self) prepareForReuse))
(define (nstextview-pressure-change-with-event self event)
  (tell #:type _void (coerce-arg self) pressureChangeWithEvent: (coerce-arg event)))
(define (nstextview-quick-look-preview-items self sender)
  (tell #:type _void (coerce-arg self) quickLookPreviewItems: (coerce-arg sender)))
(define (nstextview-quick-look-with-event self event)
  (tell #:type _void (coerce-arg self) quickLookWithEvent: (coerce-arg event)))
(define (nstextview-raise-baseline self sender)
  (tell #:type _void (coerce-arg self) raiseBaseline: (coerce-arg sender)))
(define (nstextview-read-rtfd-from-file self path)
  (_msg-46 (coerce-arg self) (sel_registerName "readRTFDFromFile:") (coerce-arg path)))
(define (nstextview-rect-for-smart-magnification-at-point-in-rect self location visible-rect)
  (_msg-16 (coerce-arg self) (sel_registerName "rectForSmartMagnificationAtPoint:inRect:") location visible-rect))
(define (nstextview-remove-all-tool-tips! self)
  (tell #:type _void (coerce-arg self) removeAllToolTips))
(define (nstextview-remove-from-superview! self)
  (tell #:type _void (coerce-arg self) removeFromSuperview))
(define (nstextview-remove-from-superview-without-needing-display! self)
  (tell #:type _void (coerce-arg self) removeFromSuperviewWithoutNeedingDisplay))
(define (nstextview-remove-tool-tip! self tag)
  (_msg-62 (coerce-arg self) (sel_registerName "removeToolTip:") tag))
(define (nstextview-replace-characters-in-range-with-rtf! self range rtf-data)
  (_msg-23 (coerce-arg self) (sel_registerName "replaceCharactersInRange:withRTF:") range (coerce-arg rtf-data)))
(define (nstextview-replace-characters-in-range-with-rtfd! self range rtfd-data)
  (_msg-23 (coerce-arg self) (sel_registerName "replaceCharactersInRange:withRTFD:") range (coerce-arg rtfd-data)))
(define (nstextview-replace-characters-in-range-with-string! self range string)
  (_msg-23 (coerce-arg self) (sel_registerName "replaceCharactersInRange:withString:") range (coerce-arg string)))
(define (nstextview-replace-subview-with! self old-view new-view)
  (tell #:type _void (coerce-arg self) replaceSubview: (coerce-arg old-view) with: (coerce-arg new-view)))
(define (nstextview-replace-text-container! self new-container)
  (tell #:type _void (coerce-arg self) replaceTextContainer: (coerce-arg new-container)))
(define (nstextview-resign-first-responder self)
  (_msg-4 (coerce-arg self) (sel_registerName "resignFirstResponder")))
(define (nstextview-resize-subviews-with-old-size self old-size)
  (_msg-40 (coerce-arg self) (sel_registerName "resizeSubviewsWithOldSize:") old-size))
(define (nstextview-resize-with-old-superview-size self old-size)
  (_msg-40 (coerce-arg self) (sel_registerName "resizeWithOldSuperviewSize:") old-size))
(define (nstextview-restore-user-activity-state self user-activity)
  (tell #:type _void (coerce-arg self) restoreUserActivityState: (coerce-arg user-activity)))
(define (nstextview-right-mouse-down self event)
  (tell #:type _void (coerce-arg self) rightMouseDown: (coerce-arg event)))
(define (nstextview-right-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) rightMouseDragged: (coerce-arg event)))
(define (nstextview-right-mouse-up self event)
  (tell #:type _void (coerce-arg self) rightMouseUp: (coerce-arg event)))
(define (nstextview-rotate-by-angle self angle)
  (_msg-44 (coerce-arg self) (sel_registerName "rotateByAngle:") angle))
(define (nstextview-rotate-with-event self event)
  (tell #:type _void (coerce-arg self) rotateWithEvent: (coerce-arg event)))
(define (nstextview-ruler-view-did-add-marker self ruler marker)
  (tell #:type _void (coerce-arg self) rulerView: (coerce-arg ruler) didAddMarker: (coerce-arg marker)))
(define (nstextview-ruler-view-did-move-marker self ruler marker)
  (tell #:type _void (coerce-arg self) rulerView: (coerce-arg ruler) didMoveMarker: (coerce-arg marker)))
(define (nstextview-ruler-view-did-remove-marker self ruler marker)
  (tell #:type _void (coerce-arg self) rulerView: (coerce-arg ruler) didRemoveMarker: (coerce-arg marker)))
(define (nstextview-ruler-view-handle-mouse-down self ruler event)
  (tell #:type _void (coerce-arg self) rulerView: (coerce-arg ruler) handleMouseDown: (coerce-arg event)))
(define (nstextview-ruler-view-should-add-marker self ruler marker)
  (_msg-53 (coerce-arg self) (sel_registerName "rulerView:shouldAddMarker:") (coerce-arg ruler) (coerce-arg marker)))
(define (nstextview-ruler-view-should-move-marker self ruler marker)
  (_msg-53 (coerce-arg self) (sel_registerName "rulerView:shouldMoveMarker:") (coerce-arg ruler) (coerce-arg marker)))
(define (nstextview-ruler-view-should-remove-marker self ruler marker)
  (_msg-53 (coerce-arg self) (sel_registerName "rulerView:shouldRemoveMarker:") (coerce-arg ruler) (coerce-arg marker)))
(define (nstextview-ruler-view-will-add-marker-at-location self ruler marker location)
  (_msg-54 (coerce-arg self) (sel_registerName "rulerView:willAddMarker:atLocation:") (coerce-arg ruler) (coerce-arg marker) location))
(define (nstextview-ruler-view-will-move-marker-to-location self ruler marker location)
  (_msg-54 (coerce-arg self) (sel_registerName "rulerView:willMoveMarker:toLocation:") (coerce-arg ruler) (coerce-arg marker) location))
(define (nstextview-scale-unit-square-to-size self new-unit-size)
  (_msg-40 (coerce-arg self) (sel_registerName "scaleUnitSquareToSize:") new-unit-size))
(define (nstextview-scroll-line-down self sender)
  (tell #:type _void (coerce-arg self) scrollLineDown: (coerce-arg sender)))
(define (nstextview-scroll-line-up self sender)
  (tell #:type _void (coerce-arg self) scrollLineUp: (coerce-arg sender)))
(define (nstextview-scroll-page-down self sender)
  (tell #:type _void (coerce-arg self) scrollPageDown: (coerce-arg sender)))
(define (nstextview-scroll-page-up self sender)
  (tell #:type _void (coerce-arg self) scrollPageUp: (coerce-arg sender)))
(define (nstextview-scroll-point self point)
  (_msg-15 (coerce-arg self) (sel_registerName "scrollPoint:") point))
(define (nstextview-scroll-range-to-visible self range)
  (_msg-21 (coerce-arg self) (sel_registerName "scrollRangeToVisible:") range))
(define (nstextview-scroll-rect-to-visible self rect)
  (_msg-28 (coerce-arg self) (sel_registerName "scrollRectToVisible:") rect))
(define (nstextview-scroll-to-beginning-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToBeginningOfDocument: (coerce-arg sender)))
(define (nstextview-scroll-to-end-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToEndOfDocument: (coerce-arg sender)))
(define (nstextview-scroll-wheel self event)
  (tell #:type _void (coerce-arg self) scrollWheel: (coerce-arg event)))
(define (nstextview-select-all self sender)
  (tell #:type _void (coerce-arg self) selectAll: (coerce-arg sender)))
(define (nstextview-select-line self sender)
  (tell #:type _void (coerce-arg self) selectLine: (coerce-arg sender)))
(define (nstextview-select-paragraph self sender)
  (tell #:type _void (coerce-arg self) selectParagraph: (coerce-arg sender)))
(define (nstextview-select-to-mark self sender)
  (tell #:type _void (coerce-arg self) selectToMark: (coerce-arg sender)))
(define (nstextview-select-word self sender)
  (tell #:type _void (coerce-arg self) selectWord: (coerce-arg sender)))
(define (nstextview-selection-range-for-proposed-range-granularity self proposed-char-range granularity)
  (_msg-26 (coerce-arg self) (sel_registerName "selectionRangeForProposedRange:granularity:") proposed-char-range granularity))
(define (nstextview-set-accessibility-activation-point! self accessibility-activation-point)
  (_msg-15 (coerce-arg self) (sel_registerName "setAccessibilityActivationPoint:") accessibility-activation-point))
(define (nstextview-set-accessibility-allowed-values! self accessibility-allowed-values)
  (tell #:type _void (coerce-arg self) setAccessibilityAllowedValues: (coerce-arg accessibility-allowed-values)))
(define (nstextview-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (_msg-43 (coerce-arg self) (sel_registerName "setAccessibilityAlternateUIVisible:") accessibility-alternate-ui-visible))
(define (nstextview-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityApplicationFocusedUIElement: (coerce-arg accessibility-application-focused-ui-element)))
(define (nstextview-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityAttributedUserInputLabels: (coerce-arg accessibility-attributed-user-input-labels)))
(define (nstextview-set-accessibility-cancel-button! self accessibility-cancel-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCancelButton: (coerce-arg accessibility-cancel-button)))
(define (nstextview-set-accessibility-children! self accessibility-children)
  (tell #:type _void (coerce-arg self) setAccessibilityChildren: (coerce-arg accessibility-children)))
(define (nstextview-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (tell #:type _void (coerce-arg self) setAccessibilityChildrenInNavigationOrder: (coerce-arg accessibility-children-in-navigation-order)))
(define (nstextview-set-accessibility-clear-button! self accessibility-clear-button)
  (tell #:type _void (coerce-arg self) setAccessibilityClearButton: (coerce-arg accessibility-clear-button)))
(define (nstextview-set-accessibility-close-button! self accessibility-close-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCloseButton: (coerce-arg accessibility-close-button)))
(define (nstextview-set-accessibility-column-count! self accessibility-column-count)
  (_msg-62 (coerce-arg self) (sel_registerName "setAccessibilityColumnCount:") accessibility-column-count))
(define (nstextview-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnHeaderUIElements: (coerce-arg accessibility-column-header-ui-elements)))
(define (nstextview-set-accessibility-column-index-range! self accessibility-column-index-range)
  (_msg-21 (coerce-arg self) (sel_registerName "setAccessibilityColumnIndexRange:") accessibility-column-index-range))
(define (nstextview-set-accessibility-column-titles! self accessibility-column-titles)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnTitles: (coerce-arg accessibility-column-titles)))
(define (nstextview-set-accessibility-columns! self accessibility-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityColumns: (coerce-arg accessibility-columns)))
(define (nstextview-set-accessibility-contents! self accessibility-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityContents: (coerce-arg accessibility-contents)))
(define (nstextview-set-accessibility-critical-value! self accessibility-critical-value)
  (tell #:type _void (coerce-arg self) setAccessibilityCriticalValue: (coerce-arg accessibility-critical-value)))
(define (nstextview-set-accessibility-custom-actions! self accessibility-custom-actions)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomActions: (coerce-arg accessibility-custom-actions)))
(define (nstextview-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomRotors: (coerce-arg accessibility-custom-rotors)))
(define (nstextview-set-accessibility-decrement-button! self accessibility-decrement-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDecrementButton: (coerce-arg accessibility-decrement-button)))
(define (nstextview-set-accessibility-default-button! self accessibility-default-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDefaultButton: (coerce-arg accessibility-default-button)))
(define (nstextview-set-accessibility-disclosed! self accessibility-disclosed)
  (_msg-43 (coerce-arg self) (sel_registerName "setAccessibilityDisclosed:") accessibility-disclosed))
(define (nstextview-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedByRow: (coerce-arg accessibility-disclosed-by-row)))
(define (nstextview-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedRows: (coerce-arg accessibility-disclosed-rows)))
(define (nstextview-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (_msg-62 (coerce-arg self) (sel_registerName "setAccessibilityDisclosureLevel:") accessibility-disclosure-level))
(define (nstextview-set-accessibility-document! self accessibility-document)
  (tell #:type _void (coerce-arg self) setAccessibilityDocument: (coerce-arg accessibility-document)))
(define (nstextview-set-accessibility-edited! self accessibility-edited)
  (_msg-43 (coerce-arg self) (sel_registerName "setAccessibilityEdited:") accessibility-edited))
(define (nstextview-set-accessibility-element! self accessibility-element)
  (_msg-43 (coerce-arg self) (sel_registerName "setAccessibilityElement:") accessibility-element))
(define (nstextview-set-accessibility-enabled! self accessibility-enabled)
  (_msg-43 (coerce-arg self) (sel_registerName "setAccessibilityEnabled:") accessibility-enabled))
(define (nstextview-set-accessibility-expanded! self accessibility-expanded)
  (_msg-43 (coerce-arg self) (sel_registerName "setAccessibilityExpanded:") accessibility-expanded))
(define (nstextview-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityExtrasMenuBar: (coerce-arg accessibility-extras-menu-bar)))
(define (nstextview-set-accessibility-filename! self accessibility-filename)
  (tell #:type _void (coerce-arg self) setAccessibilityFilename: (coerce-arg accessibility-filename)))
(define (nstextview-set-accessibility-focused! self accessibility-focused)
  (_msg-43 (coerce-arg self) (sel_registerName "setAccessibilityFocused:") accessibility-focused))
(define (nstextview-set-accessibility-focused-window! self accessibility-focused-window)
  (tell #:type _void (coerce-arg self) setAccessibilityFocusedWindow: (coerce-arg accessibility-focused-window)))
(define (nstextview-set-accessibility-frame! self accessibility-frame)
  (_msg-30 (coerce-arg self) (sel_registerName "setAccessibilityFrame:") accessibility-frame))
(define (nstextview-set-accessibility-frontmost! self accessibility-frontmost)
  (_msg-43 (coerce-arg self) (sel_registerName "setAccessibilityFrontmost:") accessibility-frontmost))
(define (nstextview-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (tell #:type _void (coerce-arg self) setAccessibilityFullScreenButton: (coerce-arg accessibility-full-screen-button)))
(define (nstextview-set-accessibility-grow-area! self accessibility-grow-area)
  (tell #:type _void (coerce-arg self) setAccessibilityGrowArea: (coerce-arg accessibility-grow-area)))
(define (nstextview-set-accessibility-handles! self accessibility-handles)
  (tell #:type _void (coerce-arg self) setAccessibilityHandles: (coerce-arg accessibility-handles)))
(define (nstextview-set-accessibility-header! self accessibility-header)
  (tell #:type _void (coerce-arg self) setAccessibilityHeader: (coerce-arg accessibility-header)))
(define (nstextview-set-accessibility-help! self accessibility-help)
  (tell #:type _void (coerce-arg self) setAccessibilityHelp: (coerce-arg accessibility-help)))
(define (nstextview-set-accessibility-hidden! self accessibility-hidden)
  (_msg-43 (coerce-arg self) (sel_registerName "setAccessibilityHidden:") accessibility-hidden))
(define (nstextview-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalScrollBar: (coerce-arg accessibility-horizontal-scroll-bar)))
(define (nstextview-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalUnitDescription: (coerce-arg accessibility-horizontal-unit-description)))
(define (nstextview-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (_msg-62 (coerce-arg self) (sel_registerName "setAccessibilityHorizontalUnits:") accessibility-horizontal-units))
(define (nstextview-set-accessibility-identifier! self accessibility-identifier)
  (tell #:type _void (coerce-arg self) setAccessibilityIdentifier: (coerce-arg accessibility-identifier)))
(define (nstextview-set-accessibility-increment-button! self accessibility-increment-button)
  (tell #:type _void (coerce-arg self) setAccessibilityIncrementButton: (coerce-arg accessibility-increment-button)))
(define (nstextview-set-accessibility-index! self accessibility-index)
  (_msg-62 (coerce-arg self) (sel_registerName "setAccessibilityIndex:") accessibility-index))
(define (nstextview-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (_msg-62 (coerce-arg self) (sel_registerName "setAccessibilityInsertionPointLineNumber:") accessibility-insertion-point-line-number))
(define (nstextview-set-accessibility-label! self accessibility-label)
  (tell #:type _void (coerce-arg self) setAccessibilityLabel: (coerce-arg accessibility-label)))
(define (nstextview-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLabelUIElements: (coerce-arg accessibility-label-ui-elements)))
(define (nstextview-set-accessibility-label-value! self accessibility-label-value)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityLabelValue:") accessibility-label-value))
(define (nstextview-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLinkedUIElements: (coerce-arg accessibility-linked-ui-elements)))
(define (nstextview-set-accessibility-main! self accessibility-main)
  (_msg-43 (coerce-arg self) (sel_registerName "setAccessibilityMain:") accessibility-main))
(define (nstextview-set-accessibility-main-window! self accessibility-main-window)
  (tell #:type _void (coerce-arg self) setAccessibilityMainWindow: (coerce-arg accessibility-main-window)))
(define (nstextview-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerGroupUIElement: (coerce-arg accessibility-marker-group-ui-element)))
(define (nstextview-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerTypeDescription: (coerce-arg accessibility-marker-type-description)))
(define (nstextview-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerUIElements: (coerce-arg accessibility-marker-ui-elements)))
(define (nstextview-set-accessibility-marker-values! self accessibility-marker-values)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerValues: (coerce-arg accessibility-marker-values)))
(define (nstextview-set-accessibility-max-value! self accessibility-max-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMaxValue: (coerce-arg accessibility-max-value)))
(define (nstextview-set-accessibility-menu-bar! self accessibility-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityMenuBar: (coerce-arg accessibility-menu-bar)))
(define (nstextview-set-accessibility-min-value! self accessibility-min-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMinValue: (coerce-arg accessibility-min-value)))
(define (nstextview-set-accessibility-minimize-button! self accessibility-minimize-button)
  (tell #:type _void (coerce-arg self) setAccessibilityMinimizeButton: (coerce-arg accessibility-minimize-button)))
(define (nstextview-set-accessibility-minimized! self accessibility-minimized)
  (_msg-43 (coerce-arg self) (sel_registerName "setAccessibilityMinimized:") accessibility-minimized))
(define (nstextview-set-accessibility-modal! self accessibility-modal)
  (_msg-43 (coerce-arg self) (sel_registerName "setAccessibilityModal:") accessibility-modal))
(define (nstextview-set-accessibility-next-contents! self accessibility-next-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityNextContents: (coerce-arg accessibility-next-contents)))
(define (nstextview-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (_msg-62 (coerce-arg self) (sel_registerName "setAccessibilityNumberOfCharacters:") accessibility-number-of-characters))
(define (nstextview-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (_msg-43 (coerce-arg self) (sel_registerName "setAccessibilityOrderedByRow:") accessibility-ordered-by-row))
(define (nstextview-set-accessibility-orientation! self accessibility-orientation)
  (_msg-62 (coerce-arg self) (sel_registerName "setAccessibilityOrientation:") accessibility-orientation))
(define (nstextview-set-accessibility-overflow-button! self accessibility-overflow-button)
  (tell #:type _void (coerce-arg self) setAccessibilityOverflowButton: (coerce-arg accessibility-overflow-button)))
(define (nstextview-set-accessibility-parent! self accessibility-parent)
  (tell #:type _void (coerce-arg self) setAccessibilityParent: (coerce-arg accessibility-parent)))
(define (nstextview-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (tell #:type _void (coerce-arg self) setAccessibilityPlaceholderValue: (coerce-arg accessibility-placeholder-value)))
(define (nstextview-set-accessibility-previous-contents! self accessibility-previous-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityPreviousContents: (coerce-arg accessibility-previous-contents)))
(define (nstextview-set-accessibility-protected-content! self accessibility-protected-content)
  (_msg-43 (coerce-arg self) (sel_registerName "setAccessibilityProtectedContent:") accessibility-protected-content))
(define (nstextview-set-accessibility-proxy! self accessibility-proxy)
  (tell #:type _void (coerce-arg self) setAccessibilityProxy: (coerce-arg accessibility-proxy)))
(define (nstextview-set-accessibility-required! self accessibility-required)
  (_msg-43 (coerce-arg self) (sel_registerName "setAccessibilityRequired:") accessibility-required))
(define (nstextview-set-accessibility-role! self accessibility-role)
  (tell #:type _void (coerce-arg self) setAccessibilityRole: (coerce-arg accessibility-role)))
(define (nstextview-set-accessibility-role-description! self accessibility-role-description)
  (tell #:type _void (coerce-arg self) setAccessibilityRoleDescription: (coerce-arg accessibility-role-description)))
(define (nstextview-set-accessibility-row-count! self accessibility-row-count)
  (_msg-62 (coerce-arg self) (sel_registerName "setAccessibilityRowCount:") accessibility-row-count))
(define (nstextview-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityRowHeaderUIElements: (coerce-arg accessibility-row-header-ui-elements)))
(define (nstextview-set-accessibility-row-index-range! self accessibility-row-index-range)
  (_msg-21 (coerce-arg self) (sel_registerName "setAccessibilityRowIndexRange:") accessibility-row-index-range))
(define (nstextview-set-accessibility-rows! self accessibility-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityRows: (coerce-arg accessibility-rows)))
(define (nstextview-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (_msg-62 (coerce-arg self) (sel_registerName "setAccessibilityRulerMarkerType:") accessibility-ruler-marker-type))
(define (nstextview-set-accessibility-search-button! self accessibility-search-button)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchButton: (coerce-arg accessibility-search-button)))
(define (nstextview-set-accessibility-search-menu! self accessibility-search-menu)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchMenu: (coerce-arg accessibility-search-menu)))
(define (nstextview-set-accessibility-selected! self accessibility-selected)
  (_msg-43 (coerce-arg self) (sel_registerName "setAccessibilitySelected:") accessibility-selected))
(define (nstextview-set-accessibility-selected-cells! self accessibility-selected-cells)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedCells: (coerce-arg accessibility-selected-cells)))
(define (nstextview-set-accessibility-selected-children! self accessibility-selected-children)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedChildren: (coerce-arg accessibility-selected-children)))
(define (nstextview-set-accessibility-selected-columns! self accessibility-selected-columns)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedColumns: (coerce-arg accessibility-selected-columns)))
(define (nstextview-set-accessibility-selected-rows! self accessibility-selected-rows)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedRows: (coerce-arg accessibility-selected-rows)))
(define (nstextview-set-accessibility-selected-text! self accessibility-selected-text)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedText: (coerce-arg accessibility-selected-text)))
(define (nstextview-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (_msg-21 (coerce-arg self) (sel_registerName "setAccessibilitySelectedTextRange:") accessibility-selected-text-range))
(define (nstextview-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedTextRanges: (coerce-arg accessibility-selected-text-ranges)))
(define (nstextview-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityServesAsTitleForUIElements: (coerce-arg accessibility-serves-as-title-for-ui-elements)))
(define (nstextview-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (_msg-21 (coerce-arg self) (sel_registerName "setAccessibilitySharedCharacterRange:") accessibility-shared-character-range))
(define (nstextview-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedFocusElements: (coerce-arg accessibility-shared-focus-elements)))
(define (nstextview-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedTextUIElements: (coerce-arg accessibility-shared-text-ui-elements)))
(define (nstextview-set-accessibility-shown-menu! self accessibility-shown-menu)
  (tell #:type _void (coerce-arg self) setAccessibilityShownMenu: (coerce-arg accessibility-shown-menu)))
(define (nstextview-set-accessibility-sort-direction! self accessibility-sort-direction)
  (_msg-62 (coerce-arg self) (sel_registerName "setAccessibilitySortDirection:") accessibility-sort-direction))
(define (nstextview-set-accessibility-splitters! self accessibility-splitters)
  (tell #:type _void (coerce-arg self) setAccessibilitySplitters: (coerce-arg accessibility-splitters)))
(define (nstextview-set-accessibility-subrole! self accessibility-subrole)
  (tell #:type _void (coerce-arg self) setAccessibilitySubrole: (coerce-arg accessibility-subrole)))
(define (nstextview-set-accessibility-tabs! self accessibility-tabs)
  (tell #:type _void (coerce-arg self) setAccessibilityTabs: (coerce-arg accessibility-tabs)))
(define (nstextview-set-accessibility-title! self accessibility-title)
  (tell #:type _void (coerce-arg self) setAccessibilityTitle: (coerce-arg accessibility-title)))
(define (nstextview-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTitleUIElement: (coerce-arg accessibility-title-ui-element)))
(define (nstextview-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (tell #:type _void (coerce-arg self) setAccessibilityToolbarButton: (coerce-arg accessibility-toolbar-button)))
(define (nstextview-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTopLevelUIElement: (coerce-arg accessibility-top-level-ui-element)))
(define (nstextview-set-accessibility-url! self accessibility-url)
  (tell #:type _void (coerce-arg self) setAccessibilityURL: (coerce-arg accessibility-url)))
(define (nstextview-set-accessibility-unit-description! self accessibility-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityUnitDescription: (coerce-arg accessibility-unit-description)))
(define (nstextview-set-accessibility-units! self accessibility-units)
  (_msg-62 (coerce-arg self) (sel_registerName "setAccessibilityUnits:") accessibility-units))
(define (nstextview-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityUserInputLabels: (coerce-arg accessibility-user-input-labels)))
(define (nstextview-set-accessibility-value! self accessibility-value)
  (tell #:type _void (coerce-arg self) setAccessibilityValue: (coerce-arg accessibility-value)))
(define (nstextview-set-accessibility-value-description! self accessibility-value-description)
  (tell #:type _void (coerce-arg self) setAccessibilityValueDescription: (coerce-arg accessibility-value-description)))
(define (nstextview-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalScrollBar: (coerce-arg accessibility-vertical-scroll-bar)))
(define (nstextview-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalUnitDescription: (coerce-arg accessibility-vertical-unit-description)))
(define (nstextview-set-accessibility-vertical-units! self accessibility-vertical-units)
  (_msg-62 (coerce-arg self) (sel_registerName "setAccessibilityVerticalUnits:") accessibility-vertical-units))
(define (nstextview-set-accessibility-visible-cells! self accessibility-visible-cells)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleCells: (coerce-arg accessibility-visible-cells)))
(define (nstextview-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (_msg-21 (coerce-arg self) (sel_registerName "setAccessibilityVisibleCharacterRange:") accessibility-visible-character-range))
(define (nstextview-set-accessibility-visible-children! self accessibility-visible-children)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleChildren: (coerce-arg accessibility-visible-children)))
(define (nstextview-set-accessibility-visible-columns! self accessibility-visible-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleColumns: (coerce-arg accessibility-visible-columns)))
(define (nstextview-set-accessibility-visible-rows! self accessibility-visible-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleRows: (coerce-arg accessibility-visible-rows)))
(define (nstextview-set-accessibility-warning-value! self accessibility-warning-value)
  (tell #:type _void (coerce-arg self) setAccessibilityWarningValue: (coerce-arg accessibility-warning-value)))
(define (nstextview-set-accessibility-window! self accessibility-window)
  (tell #:type _void (coerce-arg self) setAccessibilityWindow: (coerce-arg accessibility-window)))
(define (nstextview-set-accessibility-windows! self accessibility-windows)
  (tell #:type _void (coerce-arg self) setAccessibilityWindows: (coerce-arg accessibility-windows)))
(define (nstextview-set-accessibility-zoom-button! self accessibility-zoom-button)
  (tell #:type _void (coerce-arg self) setAccessibilityZoomButton: (coerce-arg accessibility-zoom-button)))
(define (nstextview-set-alignment-range! self alignment range)
  (_msg-63 (coerce-arg self) (sel_registerName "setAlignment:range:") alignment range))
(define (nstextview-set-animations! self animations)
  (tell #:type _void (coerce-arg self) setAnimations: (coerce-arg animations)))
(define (nstextview-set-appearance! self appearance)
  (tell #:type _void (coerce-arg self) setAppearance: (coerce-arg appearance)))
(define (nstextview-set-base-writing-direction-range! self writing-direction range)
  (_msg-63 (coerce-arg self) (sel_registerName "setBaseWritingDirection:range:") writing-direction range))
(define (nstextview-set-bounds-origin! self new-origin)
  (_msg-15 (coerce-arg self) (sel_registerName "setBoundsOrigin:") new-origin))
(define (nstextview-set-bounds-size! self new-size)
  (_msg-40 (coerce-arg self) (sel_registerName "setBoundsSize:") new-size))
(define (nstextview-set-constrained-frame-size! self desired-size)
  (_msg-40 (coerce-arg self) (sel_registerName "setConstrainedFrameSize:") desired-size))
(define (nstextview-set-content-type! self content-type)
  (tell #:type _void (coerce-arg self) setContentType: (coerce-arg content-type)))
(define (nstextview-set-font-range! self font range)
  (_msg-50 (coerce-arg self) (sel_registerName "setFont:range:") (coerce-arg font) range))
(define (nstextview-set-frame-origin! self new-origin)
  (_msg-15 (coerce-arg self) (sel_registerName "setFrameOrigin:") new-origin))
(define (nstextview-set-frame-size! self new-size)
  (_msg-40 (coerce-arg self) (sel_registerName "setFrameSize:") new-size))
(define (nstextview-set-identifier! self identifier)
  (tell #:type _void (coerce-arg self) setIdentifier: (coerce-arg identifier)))
(define (nstextview-set-layout-orientation! self orientation)
  (_msg-62 (coerce-arg self) (sel_registerName "setLayoutOrientation:") orientation))
(define (nstextview-set-mark! self sender)
  (tell #:type _void (coerce-arg self) setMark: (coerce-arg sender)))
(define (nstextview-set-marked-text-selected-range-replacement-range! self string selected-range replacement-range)
  (_msg-51 (coerce-arg self) (sel_registerName "setMarkedText:selectedRange:replacementRange:") (coerce-arg string) selected-range replacement-range))
(define (nstextview-set-needs-display-in-rect! self invalid-rect)
  (_msg-30 (coerce-arg self) (sel_registerName "setNeedsDisplayInRect:") invalid-rect))
(define (nstextview-set-needs-display-in-rect-avoid-additional-layout! self rect flag)
  (_msg-32 (coerce-arg self) (sel_registerName "setNeedsDisplayInRect:avoidAdditionalLayout:") rect flag))
(define (nstextview-set-text-color-range! self color range)
  (_msg-50 (coerce-arg self) (sel_registerName "setTextColor:range:") (coerce-arg color) range))
(define (nstextview-should-be-treated-as-ink-event self event)
  (_msg-46 (coerce-arg self) (sel_registerName "shouldBeTreatedAsInkEvent:") (coerce-arg event)))
(define (nstextview-should-delay-window-ordering-for-event self event)
  (_msg-46 (coerce-arg self) (sel_registerName "shouldDelayWindowOrderingForEvent:") (coerce-arg event)))
(define (nstextview-show-context-help self sender)
  (tell #:type _void (coerce-arg self) showContextHelp: (coerce-arg sender)))
(define (nstextview-show-context-menu-for-selection self sender)
  (tell #:type _void (coerce-arg self) showContextMenuForSelection: (coerce-arg sender)))
(define (nstextview-show-guess-panel self sender)
  (tell #:type _void (coerce-arg self) showGuessPanel: (coerce-arg sender)))
(define (nstextview-size-to-fit self)
  (tell #:type _void (coerce-arg self) sizeToFit))
(define (nstextview-smart-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) smartMagnifyWithEvent: (coerce-arg event)))
(define (nstextview-sort-subviews-using-function-context self compare context)
  (_msg-69 (coerce-arg self) (sel_registerName "sortSubviewsUsingFunction:context:") compare context))
(define (nstextview-start-speaking self sender)
  (tell #:type _void (coerce-arg self) startSpeaking: (coerce-arg sender)))
(define (nstextview-stop-speaking self sender)
  (tell #:type _void (coerce-arg self) stopSpeaking: (coerce-arg sender)))
(define (nstextview-subscript self sender)
  (tell #:type _void (coerce-arg self) subscript: (coerce-arg sender)))
(define (nstextview-superscript self sender)
  (tell #:type _void (coerce-arg self) superscript: (coerce-arg sender)))
(define (nstextview-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (_msg-68 (coerce-arg self) (sel_registerName "supplementalTargetForAction:sender:") (sel_registerName action) (coerce-arg sender))
   ))
(define (nstextview-supports-adaptive-image-glyph self)
  (_msg-4 (coerce-arg self) (sel_registerName "supportsAdaptiveImageGlyph")))
(define (nstextview-swap-with-mark self sender)
  (tell #:type _void (coerce-arg self) swapWithMark: (coerce-arg sender)))
(define (nstextview-swipe-with-event self event)
  (tell #:type _void (coerce-arg self) swipeWithEvent: (coerce-arg event)))
(define (nstextview-tablet-point self event)
  (tell #:type _void (coerce-arg self) tabletPoint: (coerce-arg event)))
(define (nstextview-tablet-proximity self event)
  (tell #:type _void (coerce-arg self) tabletProximity: (coerce-arg event)))
(define (nstextview-tighten-kerning self sender)
  (tell #:type _void (coerce-arg self) tightenKerning: (coerce-arg sender)))
(define (nstextview-toggle-ruler! self sender)
  (tell #:type _void (coerce-arg self) toggleRuler: (coerce-arg sender)))
(define (nstextview-touches-began-with-event self event)
  (tell #:type _void (coerce-arg self) touchesBeganWithEvent: (coerce-arg event)))
(define (nstextview-touches-cancelled-with-event self event)
  (tell #:type _void (coerce-arg self) touchesCancelledWithEvent: (coerce-arg event)))
(define (nstextview-touches-ended-with-event self event)
  (tell #:type _void (coerce-arg self) touchesEndedWithEvent: (coerce-arg event)))
(define (nstextview-touches-moved-with-event self event)
  (tell #:type _void (coerce-arg self) touchesMovedWithEvent: (coerce-arg event)))
(define (nstextview-translate-origin-to-point self translation)
  (_msg-15 (coerce-arg self) (sel_registerName "translateOriginToPoint:") translation))
(define (nstextview-translate-rects-needing-display-in-rect-by self clip-rect delta)
  (_msg-31 (coerce-arg self) (sel_registerName "translateRectsNeedingDisplayInRect:by:") clip-rect delta))
(define (nstextview-transpose self sender)
  (tell #:type _void (coerce-arg self) transpose: (coerce-arg sender)))
(define (nstextview-transpose-words self sender)
  (tell #:type _void (coerce-arg self) transposeWords: (coerce-arg sender)))
(define (nstextview-try-to-perform-with self action object)
  (_msg-67 (coerce-arg self) (sel_registerName "tryToPerform:with:") (sel_registerName action) (coerce-arg object)))
(define (nstextview-turn-off-kerning self sender)
  (tell #:type _void (coerce-arg self) turnOffKerning: (coerce-arg sender)))
(define (nstextview-turn-off-ligatures self sender)
  (tell #:type _void (coerce-arg self) turnOffLigatures: (coerce-arg sender)))
(define (nstextview-underline self sender)
  (tell #:type _void (coerce-arg self) underline: (coerce-arg sender)))
(define (nstextview-union-rect-in-visible-selected-range self)
  (_msg-2 (coerce-arg self) (sel_registerName "unionRectInVisibleSelectedRange")))
(define (nstextview-unscript self sender)
  (tell #:type _void (coerce-arg self) unscript: (coerce-arg sender)))
(define (nstextview-update-drag-type-registration self)
  (tell #:type _void (coerce-arg self) updateDragTypeRegistration))
(define (nstextview-update-dragging-items-for-drag self sender)
  (tell #:type _void (coerce-arg self) updateDraggingItemsForDrag: (coerce-arg sender)))
(define (nstextview-update-font-panel self)
  (tell #:type _void (coerce-arg self) updateFontPanel))
(define (nstextview-update-layer self)
  (tell #:type _void (coerce-arg self) updateLayer))
(define (nstextview-update-ruler self)
  (tell #:type _void (coerce-arg self) updateRuler))
(define (nstextview-uppercase-word self sender)
  (tell #:type _void (coerce-arg self) uppercaseWord: (coerce-arg sender)))
(define (nstextview-use-all-ligatures self sender)
  (tell #:type _void (coerce-arg self) useAllLigatures: (coerce-arg sender)))
(define (nstextview-use-standard-kerning self sender)
  (tell #:type _void (coerce-arg self) useStandardKerning: (coerce-arg sender)))
(define (nstextview-use-standard-ligatures self sender)
  (tell #:type _void (coerce-arg self) useStandardLigatures: (coerce-arg sender)))
(define (nstextview-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (tell (coerce-arg self) validRequestorForSendType: (coerce-arg send-type) returnType: (coerce-arg return-type))))
(define (nstextview-validate-menu-item self menu-item)
  (_msg-46 (coerce-arg self) (sel_registerName "validateMenuItem:") (coerce-arg menu-item)))
(define (nstextview-validate-user-interface-item self item)
  (_msg-46 (coerce-arg self) (sel_registerName "validateUserInterfaceItem:") (coerce-arg item)))
(define (nstextview-view-did-change-backing-properties self)
  (tell #:type _void (coerce-arg self) viewDidChangeBackingProperties))
(define (nstextview-view-did-change-effective-appearance self)
  (tell #:type _void (coerce-arg self) viewDidChangeEffectiveAppearance))
(define (nstextview-view-did-end-live-resize self)
  (tell #:type _void (coerce-arg self) viewDidEndLiveResize))
(define (nstextview-view-did-hide self)
  (tell #:type _void (coerce-arg self) viewDidHide))
(define (nstextview-view-did-move-to-superview self)
  (tell #:type _void (coerce-arg self) viewDidMoveToSuperview))
(define (nstextview-view-did-move-to-window self)
  (tell #:type _void (coerce-arg self) viewDidMoveToWindow))
(define (nstextview-view-did-unhide self)
  (tell #:type _void (coerce-arg self) viewDidUnhide))
(define (nstextview-view-will-draw self)
  (tell #:type _void (coerce-arg self) viewWillDraw))
(define (nstextview-view-will-move-to-superview self new-superview)
  (tell #:type _void (coerce-arg self) viewWillMoveToSuperview: (coerce-arg new-superview)))
(define (nstextview-view-will-move-to-window self new-window)
  (tell #:type _void (coerce-arg self) viewWillMoveToWindow: (coerce-arg new-window)))
(define (nstextview-view-will-start-live-resize self)
  (tell #:type _void (coerce-arg self) viewWillStartLiveResize))
(define (nstextview-view-with-tag self tag)
  (wrap-objc-object
   (_msg-60 (coerce-arg self) (sel_registerName "viewWithTag:") tag)
   ))
(define (nstextview-wants-forwarded-scroll-events-for-axis self axis)
  (_msg-59 (coerce-arg self) (sel_registerName "wantsForwardedScrollEventsForAxis:") axis))
(define (nstextview-wants-periodic-dragging-updates self)
  (_msg-4 (coerce-arg self) (sel_registerName "wantsPeriodicDraggingUpdates")))
(define (nstextview-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (_msg-59 (coerce-arg self) (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:") axis))
(define (nstextview-will-open-menu-with-event self menu event)
  (tell #:type _void (coerce-arg self) willOpenMenu: (coerce-arg menu) withEvent: (coerce-arg event)))
(define (nstextview-will-remove-subview self subview)
  (tell #:type _void (coerce-arg self) willRemoveSubview: (coerce-arg subview)))
(define (nstextview-window-level self)
  (_msg-7 (coerce-arg self) (sel_registerName "windowLevel")))
(define (nstextview-write-rtfd-to-file-atomically self path flag)
  (_msg-52 (coerce-arg self) (sel_registerName "writeRTFDToFile:atomically:") (coerce-arg path) flag))
(define (nstextview-yank self sender)
  (tell #:type _void (coerce-arg self) yank: (coerce-arg sender)))

;; --- Class methods ---
(define (nstextview-default-animation-for-key key)
  (wrap-objc-object
   (tell NSTextView defaultAnimationForKey: (coerce-arg key))))
(define (nstextview-is-compatible-with-responsive-scrolling)
  (_msg-4 NSTextView (sel_registerName "isCompatibleWithResponsiveScrolling")))
(define (nstextview-text-view-using-text-layout-manager using-text-layout-manager)
  (wrap-objc-object
   (_msg-42 NSTextView (sel_registerName "textViewUsingTextLayoutManager:") using-text-layout-manager)
   ))
