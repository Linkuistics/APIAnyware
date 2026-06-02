#lang racket/base
;; Generated binding for NSWindow (AppKit)
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
(define (nsappearance? v) (objc-instance-of? v "NSAppearance"))
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsattributedstring? v) (objc-instance-of? v "NSAttributedString"))
(define (nsbutton? v) (objc-instance-of? v "NSButton"))
(define (nsbuttoncell? v) (objc-instance-of? v "NSButtonCell"))
(define (nscolor? v) (objc-instance-of? v "NSColor"))
(define (nscolorspace? v) (objc-instance-of? v "NSColorSpace"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsdocktile? v) (objc-instance-of? v "NSDockTile"))
(define (nsevent? v) (objc-instance-of? v "NSEvent"))
(define (nsgraphicscontext? v) (objc-instance-of? v "NSGraphicsContext"))
(define (nsimage? v) (objc-instance-of? v "NSImage"))
(define (nsmenu? v) (objc-instance-of? v "NSMenu"))
(define (nsresponder? v) (objc-instance-of? v "NSResponder"))
(define (nsscreen? v) (objc-instance-of? v "NSScreen"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (nstext? v) (objc-instance-of? v "NSText"))
(define (nstoolbar? v) (objc-instance-of? v "NSToolbar"))
(define (nstouchbar? v) (objc-instance-of? v "NSTouchBar"))
(define (nsurl? v) (objc-instance-of? v "NSURL"))
(define (nsundomanager? v) (objc-instance-of? v "NSUndoManager"))
(define (nsuseractivity? v) (objc-instance-of? v "NSUserActivity"))
(define (nsview? v) (objc-instance-of? v "NSView"))
(define (nsviewcontroller? v) (objc-instance-of? v "NSViewController"))
(define (nswindow? v) (objc-instance-of? v "NSWindow"))
(define (nswindowtab? v) (objc-instance-of? v "NSWindowTab"))
(define (nswindowtabgroup? v) (objc-instance-of? v "NSWindowTabGroup"))
(provide NSWindow)
(provide/contract
  [make-nswindow-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nswindow-init-with-content-rect-style-mask-backing-defer (c-> any/c exact-nonnegative-integer? exact-nonnegative-integer? boolean? any/c)]
  [make-nswindow-init-with-content-rect-style-mask-backing-defer-screen (c-> any/c exact-nonnegative-integer? exact-nonnegative-integer? boolean? (or/c string? objc-object? #f) any/c)]
  [nswindow-accepts-first-responder (c-> nswindow? boolean?)]
  [nswindow-accepts-mouse-moved-events (c-> nswindow? boolean?)]
  [nswindow-set-accepts-mouse-moved-events! (c-> nswindow? boolean? void?)]
  [nswindow-allows-automatic-window-tabbing (c-> boolean?)]
  [nswindow-set-allows-automatic-window-tabbing! (c-> boolean? void?)]
  [nswindow-allows-concurrent-view-drawing (c-> nswindow? boolean?)]
  [nswindow-set-allows-concurrent-view-drawing! (c-> nswindow? boolean? void?)]
  [nswindow-allows-tool-tips-when-application-is-inactive (c-> nswindow? boolean?)]
  [nswindow-set-allows-tool-tips-when-application-is-inactive! (c-> nswindow? boolean? void?)]
  [nswindow-alpha-value (c-> nswindow? real?)]
  [nswindow-set-alpha-value! (c-> nswindow? real? void?)]
  [nswindow-animation-behavior (c-> nswindow? exact-integer?)]
  [nswindow-set-animation-behavior! (c-> nswindow? exact-integer? void?)]
  [nswindow-appearance-source (c-> nswindow? any/c)]
  [nswindow-set-appearance-source! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-are-cursor-rects-enabled (c-> nswindow? boolean?)]
  [nswindow-aspect-ratio (c-> nswindow? any/c)]
  [nswindow-set-aspect-ratio! (c-> nswindow? any/c void?)]
  [nswindow-attached-sheet (c-> nswindow? (or/c nswindow? objc-nil?))]
  [nswindow-autodisplay (c-> nswindow? boolean?)]
  [nswindow-set-autodisplay! (c-> nswindow? boolean? void?)]
  [nswindow-autorecalculates-key-view-loop (c-> nswindow? boolean?)]
  [nswindow-set-autorecalculates-key-view-loop! (c-> nswindow? boolean? void?)]
  [nswindow-background-color (c-> nswindow? (or/c nscolor? objc-nil?))]
  [nswindow-set-background-color! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-backing-location (c-> nswindow? exact-nonnegative-integer?)]
  [nswindow-backing-scale-factor (c-> nswindow? real?)]
  [nswindow-backing-type (c-> nswindow? exact-nonnegative-integer?)]
  [nswindow-set-backing-type! (c-> nswindow? exact-nonnegative-integer? void?)]
  [nswindow-can-become-key-window (c-> nswindow? boolean?)]
  [nswindow-can-become-main-window (c-> nswindow? boolean?)]
  [nswindow-can-become-visible-without-login (c-> nswindow? boolean?)]
  [nswindow-set-can-become-visible-without-login! (c-> nswindow? boolean? void?)]
  [nswindow-can-hide (c-> nswindow? boolean?)]
  [nswindow-set-can-hide! (c-> nswindow? boolean? void?)]
  [nswindow-cascading-reference-frame (c-> nswindow? any/c)]
  [nswindow-child-windows (c-> nswindow? any/c)]
  [nswindow-collection-behavior (c-> nswindow? exact-nonnegative-integer?)]
  [nswindow-set-collection-behavior! (c-> nswindow? exact-nonnegative-integer? void?)]
  [nswindow-color-space (c-> nswindow? (or/c nscolorspace? objc-nil?))]
  [nswindow-set-color-space! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-content-aspect-ratio (c-> nswindow? any/c)]
  [nswindow-set-content-aspect-ratio! (c-> nswindow? any/c void?)]
  [nswindow-content-layout-guide (c-> nswindow? any/c)]
  [nswindow-content-layout-rect (c-> nswindow? any/c)]
  [nswindow-content-max-size (c-> nswindow? any/c)]
  [nswindow-set-content-max-size! (c-> nswindow? any/c void?)]
  [nswindow-content-min-size (c-> nswindow? any/c)]
  [nswindow-set-content-min-size! (c-> nswindow? any/c void?)]
  [nswindow-content-resize-increments (c-> nswindow? any/c)]
  [nswindow-set-content-resize-increments! (c-> nswindow? any/c void?)]
  [nswindow-content-view (c-> nswindow? any/c)]
  [nswindow-set-content-view! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-content-view-controller (c-> nswindow? (or/c nsviewcontroller? objc-nil?))]
  [nswindow-set-content-view-controller! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-current-event (c-> nswindow? (or/c nsevent? objc-nil?))]
  [nswindow-deepest-screen (c-> nswindow? (or/c nsscreen? objc-nil?))]
  [nswindow-default-button-cell (c-> nswindow? (or/c nsbuttoncell? objc-nil?))]
  [nswindow-set-default-button-cell! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-default-depth-limit (c-> exact-integer?)]
  [nswindow-delegate (c-> nswindow? any/c)]
  [nswindow-set-delegate! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-depth-limit (c-> nswindow? exact-integer?)]
  [nswindow-set-depth-limit! (c-> nswindow? exact-integer? void?)]
  [nswindow-device-description (c-> nswindow? any/c)]
  [nswindow-displays-when-screen-profile-changes (c-> nswindow? boolean?)]
  [nswindow-set-displays-when-screen-profile-changes! (c-> nswindow? boolean? void?)]
  [nswindow-dock-tile (c-> nswindow? (or/c nsdocktile? objc-nil?))]
  [nswindow-document-edited (c-> nswindow? boolean?)]
  [nswindow-set-document-edited! (c-> nswindow? boolean? void?)]
  [nswindow-drawers (c-> nswindow? any/c)]
  [nswindow-excluded-from-windows-menu (c-> nswindow? boolean?)]
  [nswindow-set-excluded-from-windows-menu! (c-> nswindow? boolean? void?)]
  [nswindow-first-responder (c-> nswindow? (or/c nsresponder? objc-nil?))]
  [nswindow-floating-panel (c-> nswindow? boolean?)]
  [nswindow-flush-window-disabled (c-> nswindow? boolean?)]
  [nswindow-frame (c-> nswindow? any/c)]
  [nswindow-frame-autosave-name (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-graphics-context (c-> nswindow? (or/c nsgraphicscontext? objc-nil?))]
  [nswindow-has-active-window-sharing-session (c-> nswindow? boolean?)]
  [nswindow-has-close-box (c-> nswindow? boolean?)]
  [nswindow-has-dynamic-depth-limit (c-> nswindow? boolean?)]
  [nswindow-has-shadow (c-> nswindow? boolean?)]
  [nswindow-set-has-shadow! (c-> nswindow? boolean? void?)]
  [nswindow-has-title-bar (c-> nswindow? boolean?)]
  [nswindow-hides-on-deactivate (c-> nswindow? boolean?)]
  [nswindow-set-hides-on-deactivate! (c-> nswindow? boolean? void?)]
  [nswindow-ignores-mouse-events (c-> nswindow? boolean?)]
  [nswindow-set-ignores-mouse-events! (c-> nswindow? boolean? void?)]
  [nswindow-in-live-resize (c-> nswindow? boolean?)]
  [nswindow-initial-first-responder (c-> nswindow? (or/c nsview? objc-nil?))]
  [nswindow-set-initial-first-responder! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-key-view-selection-direction (c-> nswindow? exact-nonnegative-integer?)]
  [nswindow-key-window (c-> nswindow? boolean?)]
  [nswindow-level (c-> nswindow? exact-integer?)]
  [nswindow-set-level! (c-> nswindow? exact-integer? void?)]
  [nswindow-main-window (c-> nswindow? boolean?)]
  [nswindow-max-full-screen-content-size (c-> nswindow? any/c)]
  [nswindow-set-max-full-screen-content-size! (c-> nswindow? any/c void?)]
  [nswindow-max-size (c-> nswindow? any/c)]
  [nswindow-set-max-size! (c-> nswindow? any/c void?)]
  [nswindow-menu (c-> nswindow? (or/c nsmenu? objc-nil?))]
  [nswindow-set-menu! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-min-full-screen-content-size (c-> nswindow? any/c)]
  [nswindow-set-min-full-screen-content-size! (c-> nswindow? any/c void?)]
  [nswindow-min-size (c-> nswindow? any/c)]
  [nswindow-set-min-size! (c-> nswindow? any/c void?)]
  [nswindow-miniaturizable (c-> nswindow? boolean?)]
  [nswindow-miniaturized (c-> nswindow? boolean?)]
  [nswindow-miniwindow-image (c-> nswindow? (or/c nsimage? objc-nil?))]
  [nswindow-set-miniwindow-image! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-miniwindow-title (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-set-miniwindow-title! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-modal-panel (c-> nswindow? boolean?)]
  [nswindow-mouse-location-outside-of-event-stream (c-> nswindow? any/c)]
  [nswindow-movable (c-> nswindow? boolean?)]
  [nswindow-set-movable! (c-> nswindow? boolean? void?)]
  [nswindow-movable-by-window-background (c-> nswindow? boolean?)]
  [nswindow-set-movable-by-window-background! (c-> nswindow? boolean? void?)]
  [nswindow-next-responder (c-> nswindow? (or/c nsresponder? objc-nil?))]
  [nswindow-set-next-responder! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-occlusion-state (c-> nswindow? exact-nonnegative-integer?)]
  [nswindow-on-active-space (c-> nswindow? boolean?)]
  [nswindow-one-shot (c-> nswindow? boolean?)]
  [nswindow-set-one-shot! (c-> nswindow? boolean? void?)]
  [nswindow-opaque (c-> nswindow? boolean?)]
  [nswindow-set-opaque! (c-> nswindow? boolean? void?)]
  [nswindow-ordered-index (c-> nswindow? exact-integer?)]
  [nswindow-set-ordered-index! (c-> nswindow? exact-integer? void?)]
  [nswindow-parent-window (c-> nswindow? (or/c nswindow? objc-nil?))]
  [nswindow-set-parent-window! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-preferred-backing-location (c-> nswindow? exact-nonnegative-integer?)]
  [nswindow-set-preferred-backing-location! (c-> nswindow? exact-nonnegative-integer? void?)]
  [nswindow-preserves-content-during-live-resize (c-> nswindow? boolean?)]
  [nswindow-set-preserves-content-during-live-resize! (c-> nswindow? boolean? void?)]
  [nswindow-prevents-application-termination-when-modal (c-> nswindow? boolean?)]
  [nswindow-set-prevents-application-termination-when-modal! (c-> nswindow? boolean? void?)]
  [nswindow-released-when-closed (c-> nswindow? boolean?)]
  [nswindow-set-released-when-closed! (c-> nswindow? boolean? void?)]
  [nswindow-represented-filename (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-set-represented-filename! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-represented-url (c-> nswindow? (or/c nsurl? objc-nil?))]
  [nswindow-set-represented-url! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-resizable (c-> nswindow? boolean?)]
  [nswindow-resize-flags (c-> nswindow? exact-nonnegative-integer?)]
  [nswindow-resize-increments (c-> nswindow? any/c)]
  [nswindow-set-resize-increments! (c-> nswindow? any/c void?)]
  [nswindow-restorable (c-> nswindow? boolean?)]
  [nswindow-set-restorable! (c-> nswindow? boolean? void?)]
  [nswindow-restorable-state-key-paths (c-> any/c)]
  [nswindow-restoration-class (c-> nswindow? any/c)]
  [nswindow-set-restoration-class! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-screen (c-> nswindow? (or/c nsscreen? objc-nil?))]
  [nswindow-sharing-type (c-> nswindow? exact-nonnegative-integer?)]
  [nswindow-set-sharing-type! (c-> nswindow? exact-nonnegative-integer? void?)]
  [nswindow-sheet (c-> nswindow? boolean?)]
  [nswindow-sheet-parent (c-> nswindow? (or/c nswindow? objc-nil?))]
  [nswindow-sheets (c-> nswindow? any/c)]
  [nswindow-shows-resize-indicator (c-> nswindow? boolean?)]
  [nswindow-set-shows-resize-indicator! (c-> nswindow? boolean? void?)]
  [nswindow-shows-toolbar-button (c-> nswindow? boolean?)]
  [nswindow-set-shows-toolbar-button! (c-> nswindow? boolean? void?)]
  [nswindow-string-with-saved-frame (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-style-mask (c-> nswindow? exact-nonnegative-integer?)]
  [nswindow-set-style-mask! (c-> nswindow? exact-nonnegative-integer? void?)]
  [nswindow-subtitle (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-set-subtitle! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-tab (c-> nswindow? (or/c nswindowtab? objc-nil?))]
  [nswindow-tab-group (c-> nswindow? (or/c nswindowtabgroup? objc-nil?))]
  [nswindow-tabbed-windows (c-> nswindow? any/c)]
  [nswindow-tabbing-identifier (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-set-tabbing-identifier! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-tabbing-mode (c-> nswindow? exact-integer?)]
  [nswindow-set-tabbing-mode! (c-> nswindow? exact-integer? void?)]
  [nswindow-title (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-set-title! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-title-visibility (c-> nswindow? exact-integer?)]
  [nswindow-set-title-visibility! (c-> nswindow? exact-integer? void?)]
  [nswindow-titlebar-accessory-view-controllers (c-> nswindow? any/c)]
  [nswindow-set-titlebar-accessory-view-controllers! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-titlebar-appears-transparent (c-> nswindow? boolean?)]
  [nswindow-set-titlebar-appears-transparent! (c-> nswindow? boolean? void?)]
  [nswindow-titlebar-separator-style (c-> nswindow? exact-integer?)]
  [nswindow-set-titlebar-separator-style! (c-> nswindow? exact-integer? void?)]
  [nswindow-toolbar (c-> nswindow? (or/c nstoolbar? objc-nil?))]
  [nswindow-set-toolbar! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-toolbar-style (c-> nswindow? exact-integer?)]
  [nswindow-set-toolbar-style! (c-> nswindow? exact-integer? void?)]
  [nswindow-touch-bar (c-> nswindow? (or/c nstouchbar? objc-nil?))]
  [nswindow-set-touch-bar! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-undo-manager (c-> nswindow? (or/c nsundomanager? objc-nil?))]
  [nswindow-user-activity (c-> nswindow? (or/c nsuseractivity? objc-nil?))]
  [nswindow-set-user-activity! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-user-tabbing-preference (c-> exact-integer?)]
  [nswindow-views-need-display (c-> nswindow? boolean?)]
  [nswindow-set-views-need-display! (c-> nswindow? boolean? void?)]
  [nswindow-visible (c-> nswindow? boolean?)]
  [nswindow-window-controller (c-> nswindow? any/c)]
  [nswindow-set-window-controller! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-window-number (c-> nswindow? exact-integer?)]
  [nswindow-window-ref (c-> nswindow? (or/c cpointer? #f))]
  [nswindow-window-titlebar-layout-direction (c-> nswindow? exact-integer?)]
  [nswindow-works-when-modal (c-> nswindow? boolean?)]
  [nswindow-zoomable (c-> nswindow? boolean?)]
  [nswindow-zoomed (c-> nswindow? boolean?)]
  [nswindow-accessibility-activation-point (c-> nswindow? any/c)]
  [nswindow-accessibility-allowed-values (c-> nswindow? any/c)]
  [nswindow-accessibility-application-focused-ui-element (c-> nswindow? any/c)]
  [nswindow-accessibility-attributed-string-for-range (c-> nswindow? any/c (or/c nsattributedstring? objc-nil?))]
  [nswindow-accessibility-attributed-user-input-labels (c-> nswindow? any/c)]
  [nswindow-accessibility-cancel-button (c-> nswindow? any/c)]
  [nswindow-accessibility-cell-for-column-row (c-> nswindow? exact-integer? exact-integer? any/c)]
  [nswindow-accessibility-children (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-children-in-navigation-order (c-> nswindow? any/c)]
  [nswindow-accessibility-clear-button (c-> nswindow? any/c)]
  [nswindow-accessibility-close-button (c-> nswindow? any/c)]
  [nswindow-accessibility-column-count (c-> nswindow? exact-integer?)]
  [nswindow-accessibility-column-header-ui-elements (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-column-index-range (c-> nswindow? any/c)]
  [nswindow-accessibility-column-titles (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-columns (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-contents (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-critical-value (c-> nswindow? any/c)]
  [nswindow-accessibility-custom-actions (c-> nswindow? any/c)]
  [nswindow-accessibility-custom-rotors (c-> nswindow? any/c)]
  [nswindow-accessibility-decrement-button (c-> nswindow? any/c)]
  [nswindow-accessibility-default-button (c-> nswindow? any/c)]
  [nswindow-accessibility-disclosed-by-row (c-> nswindow? any/c)]
  [nswindow-accessibility-disclosed-rows (c-> nswindow? any/c)]
  [nswindow-accessibility-disclosure-level (c-> nswindow? exact-integer?)]
  [nswindow-accessibility-document (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-extras-menu-bar (c-> nswindow? any/c)]
  [nswindow-accessibility-filename (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-focused-window (c-> nswindow? any/c)]
  [nswindow-accessibility-frame (c-> nswindow? any/c)]
  [nswindow-accessibility-frame-for-range (c-> nswindow? any/c any/c)]
  [nswindow-accessibility-full-screen-button (c-> nswindow? any/c)]
  [nswindow-accessibility-grow-area (c-> nswindow? any/c)]
  [nswindow-accessibility-handles (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-header (c-> nswindow? any/c)]
  [nswindow-accessibility-help (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-horizontal-scroll-bar (c-> nswindow? any/c)]
  [nswindow-accessibility-horizontal-unit-description (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-horizontal-units (c-> nswindow? exact-integer?)]
  [nswindow-accessibility-identifier (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-increment-button (c-> nswindow? any/c)]
  [nswindow-accessibility-index (c-> nswindow? exact-integer?)]
  [nswindow-accessibility-insertion-point-line-number (c-> nswindow? exact-integer?)]
  [nswindow-accessibility-label (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-label-ui-elements (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-label-value (c-> nswindow? real?)]
  [nswindow-accessibility-layout-point-for-screen-point (c-> nswindow? any/c any/c)]
  [nswindow-accessibility-layout-size-for-screen-size (c-> nswindow? any/c any/c)]
  [nswindow-accessibility-line-for-index (c-> nswindow? exact-integer? exact-integer?)]
  [nswindow-accessibility-linked-ui-elements (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-main-window (c-> nswindow? any/c)]
  [nswindow-accessibility-marker-group-ui-element (c-> nswindow? any/c)]
  [nswindow-accessibility-marker-type-description (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-marker-ui-elements (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-marker-values (c-> nswindow? any/c)]
  [nswindow-accessibility-max-value (c-> nswindow? any/c)]
  [nswindow-accessibility-menu-bar (c-> nswindow? any/c)]
  [nswindow-accessibility-min-value (c-> nswindow? any/c)]
  [nswindow-accessibility-minimize-button (c-> nswindow? any/c)]
  [nswindow-accessibility-next-contents (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-number-of-characters (c-> nswindow? exact-integer?)]
  [nswindow-accessibility-orientation (c-> nswindow? exact-integer?)]
  [nswindow-accessibility-overflow-button (c-> nswindow? any/c)]
  [nswindow-accessibility-parent (c-> nswindow? any/c)]
  [nswindow-accessibility-perform-cancel (c-> nswindow? boolean?)]
  [nswindow-accessibility-perform-confirm (c-> nswindow? boolean?)]
  [nswindow-accessibility-perform-decrement (c-> nswindow? boolean?)]
  [nswindow-accessibility-perform-delete (c-> nswindow? boolean?)]
  [nswindow-accessibility-perform-increment (c-> nswindow? boolean?)]
  [nswindow-accessibility-perform-pick (c-> nswindow? boolean?)]
  [nswindow-accessibility-perform-press (c-> nswindow? boolean?)]
  [nswindow-accessibility-perform-raise (c-> nswindow? boolean?)]
  [nswindow-accessibility-perform-show-alternate-ui (c-> nswindow? boolean?)]
  [nswindow-accessibility-perform-show-default-ui (c-> nswindow? boolean?)]
  [nswindow-accessibility-perform-show-menu (c-> nswindow? boolean?)]
  [nswindow-accessibility-placeholder-value (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-previous-contents (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-proxy (c-> nswindow? any/c)]
  [nswindow-accessibility-rtf-for-range (c-> nswindow? any/c (or/c nsdata? objc-nil?))]
  [nswindow-accessibility-range-for-index (c-> nswindow? exact-integer? any/c)]
  [nswindow-accessibility-range-for-line (c-> nswindow? exact-integer? any/c)]
  [nswindow-accessibility-range-for-position (c-> nswindow? any/c any/c)]
  [nswindow-accessibility-role (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-role-description (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-row-count (c-> nswindow? exact-integer?)]
  [nswindow-accessibility-row-header-ui-elements (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-row-index-range (c-> nswindow? any/c)]
  [nswindow-accessibility-rows (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-ruler-marker-type (c-> nswindow? exact-integer?)]
  [nswindow-accessibility-screen-point-for-layout-point (c-> nswindow? any/c any/c)]
  [nswindow-accessibility-screen-size-for-layout-size (c-> nswindow? any/c any/c)]
  [nswindow-accessibility-search-button (c-> nswindow? any/c)]
  [nswindow-accessibility-search-menu (c-> nswindow? any/c)]
  [nswindow-accessibility-selected-cells (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-selected-children (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-selected-columns (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-selected-rows (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-selected-text (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-selected-text-range (c-> nswindow? any/c)]
  [nswindow-accessibility-selected-text-ranges (c-> nswindow? any/c)]
  [nswindow-accessibility-serves-as-title-for-ui-elements (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-shared-character-range (c-> nswindow? any/c)]
  [nswindow-accessibility-shared-focus-elements (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-shared-text-ui-elements (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-shown-menu (c-> nswindow? any/c)]
  [nswindow-accessibility-sort-direction (c-> nswindow? exact-integer?)]
  [nswindow-accessibility-splitters (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-string-for-range (c-> nswindow? any/c (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-style-range-for-index (c-> nswindow? exact-integer? any/c)]
  [nswindow-accessibility-subrole (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-tabs (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-title (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-title-ui-element (c-> nswindow? any/c)]
  [nswindow-accessibility-toolbar-button (c-> nswindow? any/c)]
  [nswindow-accessibility-top-level-ui-element (c-> nswindow? any/c)]
  [nswindow-accessibility-url (c-> nswindow? (or/c nsurl? objc-nil?))]
  [nswindow-accessibility-unit-description (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-units (c-> nswindow? exact-integer?)]
  [nswindow-accessibility-user-input-labels (c-> nswindow? any/c)]
  [nswindow-accessibility-value (c-> nswindow? any/c)]
  [nswindow-accessibility-value-description (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-vertical-scroll-bar (c-> nswindow? any/c)]
  [nswindow-accessibility-vertical-unit-description (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-vertical-units (c-> nswindow? exact-integer?)]
  [nswindow-accessibility-visible-cells (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-visible-character-range (c-> nswindow? any/c)]
  [nswindow-accessibility-visible-children (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-visible-columns (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-visible-rows (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-warning-value (c-> nswindow? any/c)]
  [nswindow-accessibility-window (c-> nswindow? any/c)]
  [nswindow-accessibility-windows (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-zoom-button (c-> nswindow? any/c)]
  [nswindow-add-child-window-ordered! (c-> nswindow? (or/c string? objc-object? #f) exact-integer? void?)]
  [nswindow-add-tabbed-window-ordered! (c-> nswindow? (or/c string? objc-object? #f) exact-integer? void?)]
  [nswindow-add-titlebar-accessory-view-controller! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-animation-for-key (c-> nswindow? (or/c string? objc-object? #f) any/c)]
  [nswindow-animation-resize-time (c-> nswindow? any/c real?)]
  [nswindow-animations (c-> nswindow? any/c)]
  [nswindow-animator (c-> nswindow? any/c)]
  [nswindow-appearance (c-> nswindow? (or/c nsappearance? objc-nil?))]
  [nswindow-autorecalculates-content-border-thickness-for-edge (c-> nswindow? exact-nonnegative-integer? boolean?)]
  [nswindow-backing-aligned-rect-options (c-> nswindow? any/c exact-nonnegative-integer? any/c)]
  [nswindow-become-first-responder (c-> nswindow? boolean?)]
  [nswindow-become-key-window (c-> nswindow? void?)]
  [nswindow-become-main-window (c-> nswindow? void?)]
  [nswindow-begin-critical-sheet-completion-handler! (c-> nswindow? (or/c string? objc-object? #f) (or/c procedure? #f) void?)]
  [nswindow-begin-gesture-with-event! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-begin-sheet-completion-handler! (c-> nswindow? (or/c string? objc-object? #f) (or/c procedure? #f) void?)]
  [nswindow-can-represent-display-gamut (c-> nswindow? exact-integer? boolean?)]
  [nswindow-cascade-top-left-from-point (c-> nswindow? any/c any/c)]
  [nswindow-center! (c-> nswindow? void?)]
  [nswindow-change-mode-with-event (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-close! (c-> nswindow? void?)]
  [nswindow-constrain-frame-rect-to-screen (c-> nswindow? any/c (or/c string? objc-object? #f) any/c)]
  [nswindow-content-border-thickness-for-edge (c-> nswindow? exact-nonnegative-integer? real?)]
  [nswindow-content-rect-for-frame-rect (c-> nswindow? any/c any/c)]
  [nswindow-context-menu-key-down (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-convert-point-from-backing (c-> nswindow? any/c any/c)]
  [nswindow-convert-point-from-screen (c-> nswindow? any/c any/c)]
  [nswindow-convert-point-to-backing (c-> nswindow? any/c any/c)]
  [nswindow-convert-point-to-screen (c-> nswindow? any/c any/c)]
  [nswindow-convert-rect-from-backing (c-> nswindow? any/c any/c)]
  [nswindow-convert-rect-from-screen (c-> nswindow? any/c any/c)]
  [nswindow-convert-rect-to-backing (c-> nswindow? any/c any/c)]
  [nswindow-convert-rect-to-screen (c-> nswindow? any/c any/c)]
  [nswindow-cursor-update (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-data-with-eps-inside-rect (c-> nswindow? any/c (or/c nsdata? objc-nil?))]
  [nswindow-data-with-pdf-inside-rect (c-> nswindow? any/c (or/c nsdata? objc-nil?))]
  [nswindow-deminiaturize (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-disable-key-equivalent-for-default-button-cell (c-> nswindow? void?)]
  [nswindow-display! (c-> nswindow? void?)]
  [nswindow-display-if-needed! (c-> nswindow? void?)]
  [nswindow-displays-when-screen-profile-changes! (c-> nswindow? boolean?)]
  [nswindow-effective-appearance (c-> nswindow? (or/c nsappearance? objc-nil?))]
  [nswindow-enable-key-equivalent-for-default-button-cell (c-> nswindow? void?)]
  [nswindow-encode-with-coder (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-end-editing-for! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-end-gesture-with-event! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-end-sheet! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-end-sheet-return-code! (c-> nswindow? (or/c string? objc-object? #f) exact-integer? void?)]
  [nswindow-field-editor-for-object (c-> nswindow? boolean? (or/c string? objc-object? #f) (or/c nstext? objc-nil?))]
  [nswindow-flags-changed (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-flush-buffered-key-events (c-> nswindow? void?)]
  [nswindow-frame-rect-for-content-rect (c-> nswindow? any/c any/c)]
  [nswindow-help-requested (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-identifier (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-insert-titlebar-accessory-view-controller-at-index! (c-> nswindow? (or/c string? objc-object? #f) exact-integer? void?)]
  [nswindow-interpret-key-events (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-invalidate-shadow (c-> nswindow? void?)]
  [nswindow-is-accessibility-alternate-ui-visible (c-> nswindow? boolean?)]
  [nswindow-is-accessibility-disclosed (c-> nswindow? boolean?)]
  [nswindow-is-accessibility-edited (c-> nswindow? boolean?)]
  [nswindow-is-accessibility-element (c-> nswindow? boolean?)]
  [nswindow-is-accessibility-enabled (c-> nswindow? boolean?)]
  [nswindow-is-accessibility-expanded (c-> nswindow? boolean?)]
  [nswindow-is-accessibility-focused (c-> nswindow? boolean?)]
  [nswindow-is-accessibility-frontmost (c-> nswindow? boolean?)]
  [nswindow-is-accessibility-hidden (c-> nswindow? boolean?)]
  [nswindow-is-accessibility-main (c-> nswindow? boolean?)]
  [nswindow-is-accessibility-minimized (c-> nswindow? boolean?)]
  [nswindow-is-accessibility-modal (c-> nswindow? boolean?)]
  [nswindow-is-accessibility-ordered-by-row (c-> nswindow? boolean?)]
  [nswindow-is-accessibility-protected-content (c-> nswindow? boolean?)]
  [nswindow-is-accessibility-required (c-> nswindow? boolean?)]
  [nswindow-is-accessibility-selected (c-> nswindow? boolean?)]
  [nswindow-is-accessibility-selector-allowed (c-> nswindow? string? boolean?)]
  [nswindow-is-document-edited (c-> nswindow? boolean?)]
  [nswindow-is-excluded-from-windows-menu (c-> nswindow? boolean?)]
  [nswindow-is-key-window (c-> nswindow? boolean?)]
  [nswindow-is-main-window (c-> nswindow? boolean?)]
  [nswindow-is-miniaturized (c-> nswindow? boolean?)]
  [nswindow-is-movable (c-> nswindow? boolean?)]
  [nswindow-is-movable-by-window-background (c-> nswindow? boolean?)]
  [nswindow-is-on-active-space (c-> nswindow? boolean?)]
  [nswindow-is-opaque (c-> nswindow? boolean?)]
  [nswindow-is-released-when-closed (c-> nswindow? boolean?)]
  [nswindow-is-sheet (c-> nswindow? boolean?)]
  [nswindow-is-visible (c-> nswindow? boolean?)]
  [nswindow-is-zoomed (c-> nswindow? boolean?)]
  [nswindow-key-down (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-key-up (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-magnify-with-event (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-make-first-responder (c-> nswindow? (or/c string? objc-object? #f) boolean?)]
  [nswindow-make-key-and-order-front (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-make-key-window (c-> nswindow? void?)]
  [nswindow-make-main-window (c-> nswindow? void?)]
  [nswindow-merge-all-windows (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-miniaturize (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-mouse-cancelled (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-mouse-down (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-mouse-dragged (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-mouse-entered (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-mouse-exited (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-mouse-moved (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-mouse-up (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-move-tab-to-new-window! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-no-responder-for (c-> nswindow? string? void?)]
  [nswindow-order-back! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-order-front! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-order-front-regardless! (c-> nswindow? void?)]
  [nswindow-order-out! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-order-window-relative-to! (c-> nswindow? exact-integer? exact-integer? void?)]
  [nswindow-other-mouse-down (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-other-mouse-dragged (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-other-mouse-up (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-perform-close! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-perform-key-equivalent! (c-> nswindow? (or/c string? objc-object? #f) boolean?)]
  [nswindow-perform-miniaturize! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-perform-window-drag-with-event! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-perform-zoom! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-pressure-change-with-event (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-print (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-quick-look-with-event (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-recalculate-key-view-loop (c-> nswindow? void?)]
  [nswindow-remove-child-window! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-remove-titlebar-accessory-view-controller-at-index! (c-> nswindow? exact-integer? void?)]
  [nswindow-request-sharing-of-window-completion-handler (c-> nswindow? (or/c string? objc-object? #f) (or/c procedure? #f) void?)]
  [nswindow-request-sharing-of-window-using-preview-title-completion-handler (c-> nswindow? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c procedure? #f) void?)]
  [nswindow-resign-first-responder (c-> nswindow? boolean?)]
  [nswindow-resign-key-window (c-> nswindow? void?)]
  [nswindow-resign-main-window (c-> nswindow? void?)]
  [nswindow-right-mouse-down (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-right-mouse-dragged (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-right-mouse-up (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-rotate-with-event (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-run-toolbar-customization-palette (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-save-frame-using-name (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-scroll-wheel (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-select-key-view-following-view (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-select-key-view-preceding-view (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-select-next-key-view (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-select-next-tab (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-select-previous-key-view (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-select-previous-tab (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-activation-point! (c-> nswindow? any/c void?)]
  [nswindow-set-accessibility-allowed-values! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-alternate-ui-visible! (c-> nswindow? boolean? void?)]
  [nswindow-set-accessibility-application-focused-ui-element! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-attributed-user-input-labels! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-cancel-button! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-children! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-children-in-navigation-order! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-clear-button! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-close-button! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-column-count! (c-> nswindow? exact-integer? void?)]
  [nswindow-set-accessibility-column-header-ui-elements! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-column-index-range! (c-> nswindow? any/c void?)]
  [nswindow-set-accessibility-column-titles! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-columns! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-contents! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-critical-value! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-custom-actions! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-custom-rotors! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-decrement-button! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-default-button! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-disclosed! (c-> nswindow? boolean? void?)]
  [nswindow-set-accessibility-disclosed-by-row! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-disclosed-rows! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-disclosure-level! (c-> nswindow? exact-integer? void?)]
  [nswindow-set-accessibility-document! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-edited! (c-> nswindow? boolean? void?)]
  [nswindow-set-accessibility-element! (c-> nswindow? boolean? void?)]
  [nswindow-set-accessibility-enabled! (c-> nswindow? boolean? void?)]
  [nswindow-set-accessibility-expanded! (c-> nswindow? boolean? void?)]
  [nswindow-set-accessibility-extras-menu-bar! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-filename! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-focused! (c-> nswindow? boolean? void?)]
  [nswindow-set-accessibility-focused-window! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-frame! (c-> nswindow? any/c void?)]
  [nswindow-set-accessibility-frontmost! (c-> nswindow? boolean? void?)]
  [nswindow-set-accessibility-full-screen-button! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-grow-area! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-handles! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-header! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-help! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-hidden! (c-> nswindow? boolean? void?)]
  [nswindow-set-accessibility-horizontal-scroll-bar! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-horizontal-unit-description! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-horizontal-units! (c-> nswindow? exact-integer? void?)]
  [nswindow-set-accessibility-identifier! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-increment-button! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-index! (c-> nswindow? exact-integer? void?)]
  [nswindow-set-accessibility-insertion-point-line-number! (c-> nswindow? exact-integer? void?)]
  [nswindow-set-accessibility-label! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-label-ui-elements! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-label-value! (c-> nswindow? real? void?)]
  [nswindow-set-accessibility-linked-ui-elements! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-main! (c-> nswindow? boolean? void?)]
  [nswindow-set-accessibility-main-window! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-marker-group-ui-element! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-marker-type-description! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-marker-ui-elements! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-marker-values! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-max-value! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-menu-bar! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-min-value! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-minimize-button! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-minimized! (c-> nswindow? boolean? void?)]
  [nswindow-set-accessibility-modal! (c-> nswindow? boolean? void?)]
  [nswindow-set-accessibility-next-contents! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-number-of-characters! (c-> nswindow? exact-integer? void?)]
  [nswindow-set-accessibility-ordered-by-row! (c-> nswindow? boolean? void?)]
  [nswindow-set-accessibility-orientation! (c-> nswindow? exact-integer? void?)]
  [nswindow-set-accessibility-overflow-button! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-parent! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-placeholder-value! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-previous-contents! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-protected-content! (c-> nswindow? boolean? void?)]
  [nswindow-set-accessibility-proxy! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-required! (c-> nswindow? boolean? void?)]
  [nswindow-set-accessibility-role! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-role-description! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-row-count! (c-> nswindow? exact-integer? void?)]
  [nswindow-set-accessibility-row-header-ui-elements! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-row-index-range! (c-> nswindow? any/c void?)]
  [nswindow-set-accessibility-rows! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-ruler-marker-type! (c-> nswindow? exact-integer? void?)]
  [nswindow-set-accessibility-search-button! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-search-menu! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-selected! (c-> nswindow? boolean? void?)]
  [nswindow-set-accessibility-selected-cells! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-selected-children! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-selected-columns! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-selected-rows! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-selected-text! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-selected-text-range! (c-> nswindow? any/c void?)]
  [nswindow-set-accessibility-selected-text-ranges! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-serves-as-title-for-ui-elements! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-shared-character-range! (c-> nswindow? any/c void?)]
  [nswindow-set-accessibility-shared-focus-elements! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-shared-text-ui-elements! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-shown-menu! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-sort-direction! (c-> nswindow? exact-integer? void?)]
  [nswindow-set-accessibility-splitters! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-subrole! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-tabs! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-title! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-title-ui-element! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-toolbar-button! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-top-level-ui-element! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-url! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-unit-description! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-units! (c-> nswindow? exact-integer? void?)]
  [nswindow-set-accessibility-user-input-labels! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-value! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-value-description! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-vertical-scroll-bar! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-vertical-unit-description! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-vertical-units! (c-> nswindow? exact-integer? void?)]
  [nswindow-set-accessibility-visible-cells! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-visible-character-range! (c-> nswindow? any/c void?)]
  [nswindow-set-accessibility-visible-children! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-visible-columns! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-visible-rows! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-warning-value! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-window! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-windows! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-zoom-button! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-animations! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-appearance! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-autorecalculates-content-border-thickness-for-edge! (c-> nswindow? boolean? exact-nonnegative-integer? void?)]
  [nswindow-set-content-border-thickness-for-edge! (c-> nswindow? real? exact-nonnegative-integer? void?)]
  [nswindow-set-content-size! (c-> nswindow? any/c void?)]
  [nswindow-set-dynamic-depth-limit! (c-> nswindow? boolean? void?)]
  [nswindow-set-frame-display! (c-> nswindow? any/c boolean? void?)]
  [nswindow-set-frame-display-animate! (c-> nswindow? any/c boolean? boolean? void?)]
  [nswindow-set-frame-autosave-name! (c-> nswindow? (or/c string? objc-object? #f) boolean?)]
  [nswindow-set-frame-from-string! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-frame-origin! (c-> nswindow? any/c void?)]
  [nswindow-set-frame-top-left-point! (c-> nswindow? any/c void?)]
  [nswindow-set-frame-using-name! (c-> nswindow? (or/c string? objc-object? #f) boolean?)]
  [nswindow-set-frame-using-name-force! (c-> nswindow? (or/c string? objc-object? #f) boolean? boolean?)]
  [nswindow-set-identifier! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-title-with-represented-filename! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-should-be-treated-as-ink-event (c-> nswindow? (or/c string? objc-object? #f) boolean?)]
  [nswindow-show-context-help (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-smart-magnify-with-event (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-standard-window-button (c-> nswindow? exact-nonnegative-integer? (or/c nsbutton? objc-nil?))]
  [nswindow-supplemental-target-for-action-sender (c-> nswindow? string? (or/c string? objc-object? #f) any/c)]
  [nswindow-swipe-with-event (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-tablet-point (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-tablet-proximity (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-toggle-full-screen! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-toggle-tab-bar! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-toggle-tab-overview! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-toggle-toolbar-shown! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-touches-began-with-event (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-touches-cancelled-with-event (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-touches-ended-with-event (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-touches-moved-with-event (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-transfer-window-sharing-to-window-completion-handler (c-> nswindow? (or/c string? objc-object? #f) (or/c procedure? #f) void?)]
  [nswindow-try-to-perform-with (c-> nswindow? string? (or/c string? objc-object? #f) boolean?)]
  [nswindow-update (c-> nswindow? void?)]
  [nswindow-valid-requestor-for-send-type-return-type (c-> nswindow? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nswindow-validate-menu-item (c-> nswindow? (or/c string? objc-object? #f) boolean?)]
  [nswindow-validate-user-interface-item (c-> nswindow? (or/c string? objc-object? #f) boolean?)]
  [nswindow-wants-forwarded-scroll-events-for-axis (c-> nswindow? exact-integer? boolean?)]
  [nswindow-wants-scroll-events-for-swipe-tracking-on-axis (c-> nswindow? exact-integer? boolean?)]
  [nswindow-zoom (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-content-rect-for-frame-rect-style-mask (c-> any/c exact-nonnegative-integer? any/c)]
  [nswindow-default-animation-for-key (c-> (or/c string? objc-object? #f) any/c)]
  [nswindow-frame-rect-for-content-rect-style-mask (c-> any/c exact-nonnegative-integer? any/c)]
  [nswindow-min-frame-width-with-title-style-mask (c-> (or/c string? objc-object? #f) exact-nonnegative-integer? real?)]
  [nswindow-remove-frame-using-name! (c-> (or/c string? objc-object? #f) void?)]
  [nswindow-standard-window-button-for-style-mask (c-> exact-nonnegative-integer? exact-nonnegative-integer? (or/c nsbutton? objc-nil?))]
  [nswindow-window-number-at-point-below-window-with-window-number (c-> any/c exact-integer? exact-integer?)]
  [nswindow-window-numbers-with-options (c-> exact-nonnegative-integer? any/c)]
  [nswindow-window-with-content-view-controller (c-> (or/c string? objc-object? #f) any/c)]
  )

;; --- Class reference ---
(import-class NSWindow)

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
(define-aw-msg aw_racket_msg_0_v (-> ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_b (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_b (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPP_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_Pb_b (-> ptr_t ptr_t ptr_t bool_t bool_t))
(define-aw-msg aw_racket_msg_Pq_v (-> ptr_t ptr_t ptr_t int64_t void_t))
(define-aw-msg aw_racket_msg_PQ_d (-> ptr_t ptr_t ptr_t uint64_t double_t))
(define-aw-msg aw_racket_msg_b_v (-> ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_bP_P (-> ptr_t ptr_t bool_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_bQ_v (-> ptr_t ptr_t bool_t uint64_t void_t))
(define-aw-msg aw_racket_msg_i_v (-> ptr_t ptr_t int32_t void_t))
(define-aw-msg aw_racket_msg_q_b (-> ptr_t ptr_t int64_t bool_t))
(define-aw-msg aw_racket_msg_q_q (-> ptr_t ptr_t int64_t int64_t))
(define-aw-msg aw_racket_msg_q_G (-> ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_q_v (-> ptr_t ptr_t int64_t void_t))
(define-aw-msg aw_racket_msg_qq_P (-> ptr_t ptr_t int64_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_qq_v (-> ptr_t ptr_t int64_t int64_t void_t))
(define-aw-msg aw_racket_msg_Q_P (-> ptr_t ptr_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_Q_b (-> ptr_t ptr_t uint64_t bool_t))
(define-aw-msg aw_racket_msg_Q_d (-> ptr_t ptr_t uint64_t double_t))
(define-aw-msg aw_racket_msg_Q_v (-> ptr_t ptr_t uint64_t void_t))
(define-aw-msg aw_racket_msg_QQ_P (-> ptr_t ptr_t uint64_t uint64_t ptr_t))
(define-aw-msg aw_racket_msg_f_v (-> ptr_t ptr_t float_t void_t))
(define-aw-msg aw_racket_msg_d_v (-> ptr_t ptr_t double_t void_t))
(define-aw-msg aw_racket_msg_dQ_v (-> ptr_t ptr_t double_t uint64_t void_t))
(define-aw-msg aw_racket_msg_R_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_R_d (-> ptr_t ptr_t ptr_t double_t))
(define-aw-msg aw_racket_msg_R_R (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_R_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RP_R (-> ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_Rb_v (-> ptr_t ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_Rbb_v (-> ptr_t ptr_t ptr_t bool_t bool_t void_t))
(define-aw-msg aw_racket_msg_RQ_R (-> ptr_t ptr_t ptr_t uint64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_RQQb_P (-> ptr_t ptr_t ptr_t uint64_t uint64_t bool_t ptr_t))
(define-aw-msg aw_racket_msg_RQQbP_P (-> ptr_t ptr_t ptr_t uint64_t uint64_t bool_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_O_O (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_O_G (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_O_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_Oq_q (-> ptr_t ptr_t ptr_t int64_t int64_t))
(define-aw-msg aw_racket_msg_Z_Z (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_Z_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_G_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_G_R (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_G_v (-> ptr_t ptr_t ptr_t void_t))

;; --- Constructors ---
(define (make-nswindow-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSWindow alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nswindow-init-with-content-rect-style-mask-backing-defer content-rect style backing-store-type flag)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_RQQb_P (id->ffi2-ptr (tell NSWindow alloc)) (id->ffi2-ptr (sel_registerName "initWithContentRect:styleMask:backing:defer:")) (id->ffi2-ptr content-rect) style backing-store-type flag))
   #:retained #t))

(define (make-nswindow-init-with-content-rect-style-mask-backing-defer-screen content-rect style backing-store-type flag screen)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_RQQbP_P (id->ffi2-ptr (tell NSWindow alloc)) (id->ffi2-ptr (sel_registerName "initWithContentRect:styleMask:backing:defer:screen:")) (id->ffi2-ptr content-rect) style backing-store-type flag (id->ffi2-ptr (coerce-arg screen))))
   #:retained #t))


;; --- Properties ---
(define (nswindow-accepts-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsFirstResponder"))))
(define (nswindow-accepts-mouse-moved-events self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsMouseMovedEvents"))))
(define (nswindow-set-accepts-mouse-moved-events! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAcceptsMouseMovedEvents:")) value))
(define (nswindow-allows-automatic-window-tabbing)
  (aw_racket_msg_0_b (id->ffi2-ptr NSWindow) (id->ffi2-ptr (sel_registerName "allowsAutomaticWindowTabbing"))))
(define (nswindow-set-allows-automatic-window-tabbing! value)
  (aw_racket_msg_b_v (id->ffi2-ptr NSWindow) (id->ffi2-ptr (sel_registerName "setAllowsAutomaticWindowTabbing:")) value))
(define (nswindow-allows-concurrent-view-drawing self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsConcurrentViewDrawing"))))
(define (nswindow-set-allows-concurrent-view-drawing! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsConcurrentViewDrawing:")) value))
(define (nswindow-allows-tool-tips-when-application-is-inactive self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsToolTipsWhenApplicationIsInactive"))))
(define (nswindow-set-allows-tool-tips-when-application-is-inactive! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsToolTipsWhenApplicationIsInactive:")) value))
(define (nswindow-alpha-value self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alphaValue"))))
(define (nswindow-set-alpha-value! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlphaValue:")) value))
(define (nswindow-animation-behavior self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animationBehavior"))))
(define (nswindow-set-animation-behavior! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAnimationBehavior:")) value))
(define (nswindow-appearance-source self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "appearanceSource"))))))
(define (nswindow-set-appearance-source! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAppearanceSource:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-are-cursor-rects-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "areCursorRectsEnabled"))))
(define (nswindow-aspect-ratio self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "aspectRatio")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nswindow-set-aspect-ratio! self value)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAspectRatio:")) (id->ffi2-ptr value)))
(define (nswindow-attached-sheet self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "attachedSheet"))))))
(define (nswindow-autodisplay self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autodisplay"))))
(define (nswindow-set-autodisplay! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutodisplay:")) value))
(define (nswindow-autorecalculates-key-view-loop self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autorecalculatesKeyViewLoop"))))
(define (nswindow-set-autorecalculates-key-view-loop! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutorecalculatesKeyViewLoop:")) value))
(define (nswindow-background-color self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backgroundColor"))))))
(define (nswindow-set-background-color! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBackgroundColor:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-backing-location self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backingLocation"))))
(define (nswindow-backing-scale-factor self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backingScaleFactor"))))
(define (nswindow-backing-type self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backingType"))))
(define (nswindow-set-backing-type! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBackingType:")) value))
(define (nswindow-can-become-key-window self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canBecomeKeyWindow"))))
(define (nswindow-can-become-main-window self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canBecomeMainWindow"))))
(define (nswindow-can-become-visible-without-login self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canBecomeVisibleWithoutLogin"))))
(define (nswindow-set-can-become-visible-without-login! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCanBecomeVisibleWithoutLogin:")) value))
(define (nswindow-can-hide self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canHide"))))
(define (nswindow-set-can-hide! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCanHide:")) value))
(define (nswindow-cascading-reference-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cascadingReferenceFrame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nswindow-child-windows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "childWindows"))))))
(define (nswindow-collection-behavior self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "collectionBehavior"))))
(define (nswindow-set-collection-behavior! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setCollectionBehavior:")) value))
(define (nswindow-color-space self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "colorSpace"))))))
(define (nswindow-set-color-space! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setColorSpace:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-content-aspect-ratio self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentAspectRatio")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nswindow-set-content-aspect-ratio! self value)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentAspectRatio:")) (id->ffi2-ptr value)))
(define (nswindow-content-layout-guide self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentLayoutGuide"))))))
(define (nswindow-content-layout-rect self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentLayoutRect")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nswindow-content-max-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentMaxSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nswindow-set-content-max-size! self value)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentMaxSize:")) (id->ffi2-ptr value)))
(define (nswindow-content-min-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentMinSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nswindow-set-content-min-size! self value)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentMinSize:")) (id->ffi2-ptr value)))
(define (nswindow-content-resize-increments self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentResizeIncrements")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nswindow-set-content-resize-increments! self value)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentResizeIncrements:")) (id->ffi2-ptr value)))
(define (nswindow-content-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentView"))))))
(define (nswindow-set-content-view! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentView:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-content-view-controller self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentViewController"))))))
(define (nswindow-set-content-view-controller! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentViewController:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-current-event self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "currentEvent"))))))
(define (nswindow-deepest-screen self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deepestScreen"))))))
(define (nswindow-default-button-cell self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "defaultButtonCell"))))))
(define (nswindow-set-default-button-cell! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDefaultButtonCell:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-default-depth-limit)
  (aw_racket_msg_0_i (id->ffi2-ptr NSWindow) (id->ffi2-ptr (sel_registerName "defaultDepthLimit"))))
(define (nswindow-delegate self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "delegate"))))))
(define (nswindow-set-delegate! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDelegate:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-depth-limit self)
  (aw_racket_msg_0_i (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "depthLimit"))))
(define (nswindow-set-depth-limit! self value)
  (aw_racket_msg_i_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDepthLimit:")) value))
(define (nswindow-device-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deviceDescription"))))))
(define (nswindow-displays-when-screen-profile-changes self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displaysWhenScreenProfileChanges"))))
(define (nswindow-set-displays-when-screen-profile-changes! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDisplaysWhenScreenProfileChanges:")) value))
(define (nswindow-dock-tile self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dockTile"))))))
(define (nswindow-document-edited self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "documentEdited"))))
(define (nswindow-set-document-edited! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDocumentEdited:")) value))
(define (nswindow-drawers self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "drawers"))))))
(define (nswindow-excluded-from-windows-menu self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "excludedFromWindowsMenu"))))
(define (nswindow-set-excluded-from-windows-menu! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setExcludedFromWindowsMenu:")) value))
(define (nswindow-first-responder self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "firstResponder"))))))
(define (nswindow-floating-panel self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "floatingPanel"))))
(define (nswindow-flush-window-disabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flushWindowDisabled"))))
(define (nswindow-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nswindow-frame-autosave-name self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameAutosaveName"))))))
(define (nswindow-graphics-context self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "graphicsContext"))))))
(define (nswindow-has-active-window-sharing-session self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasActiveWindowSharingSession"))))
(define (nswindow-has-close-box self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasCloseBox"))))
(define (nswindow-has-dynamic-depth-limit self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasDynamicDepthLimit"))))
(define (nswindow-has-shadow self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasShadow"))))
(define (nswindow-set-has-shadow! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHasShadow:")) value))
(define (nswindow-has-title-bar self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasTitleBar"))))
(define (nswindow-hides-on-deactivate self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hidesOnDeactivate"))))
(define (nswindow-set-hides-on-deactivate! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHidesOnDeactivate:")) value))
(define (nswindow-ignores-mouse-events self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "ignoresMouseEvents"))))
(define (nswindow-set-ignores-mouse-events! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIgnoresMouseEvents:")) value))
(define (nswindow-in-live-resize self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "inLiveResize"))))
(define (nswindow-initial-first-responder self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "initialFirstResponder"))))))
(define (nswindow-set-initial-first-responder! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setInitialFirstResponder:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-key-view-selection-direction self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyViewSelectionDirection"))))
(define (nswindow-key-window self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyWindow"))))
(define (nswindow-level self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "level"))))
(define (nswindow-set-level! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setLevel:")) value))
(define (nswindow-main-window self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mainWindow"))))
(define (nswindow-max-full-screen-content-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "maxFullScreenContentSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nswindow-set-max-full-screen-content-size! self value)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMaxFullScreenContentSize:")) (id->ffi2-ptr value)))
(define (nswindow-max-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "maxSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nswindow-set-max-size! self value)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMaxSize:")) (id->ffi2-ptr value)))
(define (nswindow-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menu"))))))
(define (nswindow-set-menu! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMenu:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-min-full-screen-content-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "minFullScreenContentSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nswindow-set-min-full-screen-content-size! self value)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMinFullScreenContentSize:")) (id->ffi2-ptr value)))
(define (nswindow-min-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "minSize")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nswindow-set-min-size! self value)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMinSize:")) (id->ffi2-ptr value)))
(define (nswindow-miniaturizable self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "miniaturizable"))))
(define (nswindow-miniaturized self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "miniaturized"))))
(define (nswindow-miniwindow-image self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "miniwindowImage"))))))
(define (nswindow-set-miniwindow-image! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMiniwindowImage:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-miniwindow-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "miniwindowTitle"))))))
(define (nswindow-set-miniwindow-title! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMiniwindowTitle:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-modal-panel self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "modalPanel"))))
(define (nswindow-mouse-location-outside-of-event-stream self)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_0_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseLocationOutsideOfEventStream")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nswindow-movable self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "movable"))))
(define (nswindow-set-movable! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMovable:")) value))
(define (nswindow-movable-by-window-background self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "movableByWindowBackground"))))
(define (nswindow-set-movable-by-window-background! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMovableByWindowBackground:")) value))
(define (nswindow-next-responder self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextResponder"))))))
(define (nswindow-set-next-responder! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextResponder:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-occlusion-state self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "occlusionState"))))
(define (nswindow-on-active-space self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "onActiveSpace"))))
(define (nswindow-one-shot self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "oneShot"))))
(define (nswindow-set-one-shot! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setOneShot:")) value))
(define (nswindow-opaque self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "opaque"))))
(define (nswindow-set-opaque! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setOpaque:")) value))
(define (nswindow-ordered-index self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orderedIndex"))))
(define (nswindow-set-ordered-index! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setOrderedIndex:")) value))
(define (nswindow-parent-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "parentWindow"))))))
(define (nswindow-set-parent-window! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setParentWindow:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-preferred-backing-location self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preferredBackingLocation"))))
(define (nswindow-set-preferred-backing-location! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPreferredBackingLocation:")) value))
(define (nswindow-preserves-content-during-live-resize self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preservesContentDuringLiveResize"))))
(define (nswindow-set-preserves-content-during-live-resize! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPreservesContentDuringLiveResize:")) value))
(define (nswindow-prevents-application-termination-when-modal self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preventsApplicationTerminationWhenModal"))))
(define (nswindow-set-prevents-application-termination-when-modal! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPreventsApplicationTerminationWhenModal:")) value))
(define (nswindow-released-when-closed self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "releasedWhenClosed"))))
(define (nswindow-set-released-when-closed! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setReleasedWhenClosed:")) value))
(define (nswindow-represented-filename self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "representedFilename"))))))
(define (nswindow-set-represented-filename! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setRepresentedFilename:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-represented-url self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "representedURL"))))))
(define (nswindow-set-represented-url! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setRepresentedURL:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-resizable self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resizable"))))
(define (nswindow-resize-flags self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resizeFlags"))))
(define (nswindow-resize-increments self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resizeIncrements")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nswindow-set-resize-increments! self value)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setResizeIncrements:")) (id->ffi2-ptr value)))
(define (nswindow-restorable self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "restorable"))))
(define (nswindow-set-restorable! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setRestorable:")) value))
(define (nswindow-restorable-state-key-paths)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSWindow) (id->ffi2-ptr (sel_registerName "restorableStateKeyPaths"))))))
(define (nswindow-restoration-class self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "restorationClass"))))))
(define (nswindow-set-restoration-class! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setRestorationClass:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-screen self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "screen"))))))
(define (nswindow-sharing-type self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sharingType"))))
(define (nswindow-set-sharing-type! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSharingType:")) value))
(define (nswindow-sheet self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sheet"))))
(define (nswindow-sheet-parent self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sheetParent"))))))
(define (nswindow-sheets self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sheets"))))))
(define (nswindow-shows-resize-indicator self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showsResizeIndicator"))))
(define (nswindow-set-shows-resize-indicator! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShowsResizeIndicator:")) value))
(define (nswindow-shows-toolbar-button self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showsToolbarButton"))))
(define (nswindow-set-shows-toolbar-button! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShowsToolbarButton:")) value))
(define (nswindow-string-with-saved-frame self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stringWithSavedFrame"))))))
(define (nswindow-style-mask self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "styleMask"))))
(define (nswindow-set-style-mask! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setStyleMask:")) value))
(define (nswindow-subtitle self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "subtitle"))))))
(define (nswindow-set-subtitle! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSubtitle:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-tab self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tab"))))))
(define (nswindow-tab-group self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabGroup"))))))
(define (nswindow-tabbed-windows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabbedWindows"))))))
(define (nswindow-tabbing-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabbingIdentifier"))))))
(define (nswindow-set-tabbing-identifier! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTabbingIdentifier:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-tabbing-mode self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabbingMode"))))
(define (nswindow-set-tabbing-mode! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTabbingMode:")) value))
(define (nswindow-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "title"))))))
(define (nswindow-set-title! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTitle:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-title-visibility self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "titleVisibility"))))
(define (nswindow-set-title-visibility! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTitleVisibility:")) value))
(define (nswindow-titlebar-accessory-view-controllers self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "titlebarAccessoryViewControllers"))))))
(define (nswindow-set-titlebar-accessory-view-controllers! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTitlebarAccessoryViewControllers:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-titlebar-appears-transparent self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "titlebarAppearsTransparent"))))
(define (nswindow-set-titlebar-appears-transparent! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTitlebarAppearsTransparent:")) value))
(define (nswindow-titlebar-separator-style self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "titlebarSeparatorStyle"))))
(define (nswindow-set-titlebar-separator-style! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTitlebarSeparatorStyle:")) value))
(define (nswindow-toolbar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "toolbar"))))))
(define (nswindow-set-toolbar! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setToolbar:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-toolbar-style self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "toolbarStyle"))))
(define (nswindow-set-toolbar-style! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setToolbarStyle:")) value))
(define (nswindow-touch-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchBar"))))))
(define (nswindow-set-touch-bar! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTouchBar:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-undo-manager self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "undoManager"))))))
(define (nswindow-user-activity self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userActivity"))))))
(define (nswindow-set-user-activity! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserActivity:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-user-tabbing-preference)
  (aw_racket_msg_0_q (id->ffi2-ptr NSWindow) (id->ffi2-ptr (sel_registerName "userTabbingPreference"))))
(define (nswindow-views-need-display self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "viewsNeedDisplay"))))
(define (nswindow-set-views-need-display! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setViewsNeedDisplay:")) value))
(define (nswindow-visible self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "visible"))))
(define (nswindow-window-controller self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "windowController"))))))
(define (nswindow-set-window-controller! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWindowController:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindow-window-number self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "windowNumber"))))
(define (nswindow-window-ref self)
  (ptr_t->cpointer (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "windowRef")))))
(define (nswindow-window-titlebar-layout-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "windowTitlebarLayoutDirection"))))
(define (nswindow-works-when-modal self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "worksWhenModal"))))
(define (nswindow-zoomable self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "zoomable"))))
(define (nswindow-zoomed self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "zoomed"))))

;; --- Instance methods ---
(define (nswindow-accessibility-activation-point self)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_0_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityActivationPoint")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nswindow-accessibility-allowed-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAllowedValues"))))
   ))
(define (nswindow-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityApplicationFocusedUIElement"))))
   ))
(define (nswindow-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nswindow-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedUserInputLabels"))))
   ))
(define (nswindow-accessibility-cancel-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCancelButton"))))
   ))
(define (nswindow-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_qq_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCellForColumn:row:")) column row))
   ))
(define (nswindow-accessibility-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildren"))))
   ))
(define (nswindow-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildrenInNavigationOrder"))))
   ))
(define (nswindow-accessibility-clear-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityClearButton"))))
   ))
(define (nswindow-accessibility-close-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCloseButton"))))
   ))
(define (nswindow-accessibility-column-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnCount"))))
(define (nswindow-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnHeaderUIElements"))))
   ))
(define (nswindow-accessibility-column-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nswindow-accessibility-column-titles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnTitles"))))
   ))
(define (nswindow-accessibility-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumns"))))
   ))
(define (nswindow-accessibility-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityContents"))))
   ))
(define (nswindow-accessibility-critical-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCriticalValue"))))
   ))
(define (nswindow-accessibility-custom-actions self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomActions"))))
   ))
(define (nswindow-accessibility-custom-rotors self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomRotors"))))
   ))
(define (nswindow-accessibility-decrement-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDecrementButton"))))
   ))
(define (nswindow-accessibility-default-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDefaultButton"))))
   ))
(define (nswindow-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedByRow"))))
   ))
(define (nswindow-accessibility-disclosed-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedRows"))))
   ))
(define (nswindow-accessibility-disclosure-level self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosureLevel"))))
(define (nswindow-accessibility-document self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDocument"))))
   ))
(define (nswindow-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityExtrasMenuBar"))))
   ))
(define (nswindow-accessibility-filename self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFilename"))))
   ))
(define (nswindow-accessibility-focused-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFocusedWindow"))))
   ))
(define (nswindow-accessibility-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nswindow-accessibility-frame-for-range self range)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_G_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrameForRange:")) (id->ffi2-ptr range) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nswindow-accessibility-full-screen-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFullScreenButton"))))
   ))
(define (nswindow-accessibility-grow-area self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityGrowArea"))))
   ))
(define (nswindow-accessibility-handles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHandles"))))
   ))
(define (nswindow-accessibility-header self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHeader"))))
   ))
(define (nswindow-accessibility-help self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHelp"))))
   ))
(define (nswindow-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalScrollBar"))))
   ))
(define (nswindow-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnitDescription"))))
   ))
(define (nswindow-accessibility-horizontal-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnits"))))
(define (nswindow-accessibility-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIdentifier"))))
   ))
(define (nswindow-accessibility-increment-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIncrementButton"))))
   ))
(define (nswindow-accessibility-index self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIndex"))))
(define (nswindow-accessibility-insertion-point-line-number self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityInsertionPointLineNumber"))))
(define (nswindow-accessibility-label self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabel"))))
   ))
(define (nswindow-accessibility-label-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelUIElements"))))
   ))
(define (nswindow-accessibility-label-value self)
  (aw_racket_msg_0_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelValue"))))
(define (nswindow-accessibility-layout-point-for-screen-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutPointForScreenPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nswindow-accessibility-layout-size-for-screen-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutSizeForScreenSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nswindow-accessibility-line-for-index self index)
  (aw_racket_msg_q_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLineForIndex:")) index))
(define (nswindow-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLinkedUIElements"))))
   ))
(define (nswindow-accessibility-main-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMainWindow"))))
   ))
(define (nswindow-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerGroupUIElement"))))
   ))
(define (nswindow-accessibility-marker-type-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerTypeDescription"))))
   ))
(define (nswindow-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerUIElements"))))
   ))
(define (nswindow-accessibility-marker-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerValues"))))
   ))
(define (nswindow-accessibility-max-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMaxValue"))))
   ))
(define (nswindow-accessibility-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMenuBar"))))
   ))
(define (nswindow-accessibility-min-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinValue"))))
   ))
(define (nswindow-accessibility-minimize-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinimizeButton"))))
   ))
(define (nswindow-accessibility-next-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNextContents"))))
   ))
(define (nswindow-accessibility-number-of-characters self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNumberOfCharacters"))))
(define (nswindow-accessibility-orientation self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOrientation"))))
(define (nswindow-accessibility-overflow-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOverflowButton"))))
   ))
(define (nswindow-accessibility-parent self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityParent"))))
   ))
(define (nswindow-accessibility-perform-cancel self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformCancel"))))
(define (nswindow-accessibility-perform-confirm self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformConfirm"))))
(define (nswindow-accessibility-perform-decrement self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDecrement"))))
(define (nswindow-accessibility-perform-delete self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDelete"))))
(define (nswindow-accessibility-perform-increment self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformIncrement"))))
(define (nswindow-accessibility-perform-pick self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPick"))))
(define (nswindow-accessibility-perform-press self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPress"))))
(define (nswindow-accessibility-perform-raise self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformRaise"))))
(define (nswindow-accessibility-perform-show-alternate-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowAlternateUI"))))
(define (nswindow-accessibility-perform-show-default-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowDefaultUI"))))
(define (nswindow-accessibility-perform-show-menu self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowMenu"))))
(define (nswindow-accessibility-placeholder-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPlaceholderValue"))))
   ))
(define (nswindow-accessibility-previous-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPreviousContents"))))
   ))
(define (nswindow-accessibility-proxy self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityProxy"))))
   ))
(define (nswindow-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRTFForRange:")) (id->ffi2-ptr range)))
   ))
(define (nswindow-accessibility-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nswindow-accessibility-range-for-line self line)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForLine:")) line (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nswindow-accessibility-range-for-position self point)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_O_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForPosition:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nswindow-accessibility-role self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRole"))))
   ))
(define (nswindow-accessibility-role-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRoleDescription"))))
   ))
(define (nswindow-accessibility-row-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowCount"))))
(define (nswindow-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowHeaderUIElements"))))
   ))
(define (nswindow-accessibility-row-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nswindow-accessibility-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRows"))))
   ))
(define (nswindow-accessibility-ruler-marker-type self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRulerMarkerType"))))
(define (nswindow-accessibility-screen-point-for-layout-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenPointForLayoutPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nswindow-accessibility-screen-size-for-layout-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenSizeForLayoutSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nswindow-accessibility-search-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchButton"))))
   ))
(define (nswindow-accessibility-search-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchMenu"))))
   ))
(define (nswindow-accessibility-selected-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedCells"))))
   ))
(define (nswindow-accessibility-selected-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedChildren"))))
   ))
(define (nswindow-accessibility-selected-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedColumns"))))
   ))
(define (nswindow-accessibility-selected-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedRows"))))
   ))
(define (nswindow-accessibility-selected-text self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedText"))))
   ))
(define (nswindow-accessibility-selected-text-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nswindow-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRanges"))))
   ))
(define (nswindow-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityServesAsTitleForUIElements"))))
   ))
(define (nswindow-accessibility-shared-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nswindow-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedFocusElements"))))
   ))
(define (nswindow-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedTextUIElements"))))
   ))
(define (nswindow-accessibility-shown-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityShownMenu"))))
   ))
(define (nswindow-accessibility-sort-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySortDirection"))))
(define (nswindow-accessibility-splitters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySplitters"))))
   ))
(define (nswindow-accessibility-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nswindow-accessibility-style-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStyleRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nswindow-accessibility-subrole self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySubrole"))))
   ))
(define (nswindow-accessibility-tabs self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTabs"))))
   ))
(define (nswindow-accessibility-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitle"))))
   ))
(define (nswindow-accessibility-title-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitleUIElement"))))
   ))
(define (nswindow-accessibility-toolbar-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityToolbarButton"))))
   ))
(define (nswindow-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTopLevelUIElement"))))
   ))
(define (nswindow-accessibility-url self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityURL"))))
   ))
(define (nswindow-accessibility-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnitDescription"))))
   ))
(define (nswindow-accessibility-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnits"))))
(define (nswindow-accessibility-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUserInputLabels"))))
   ))
(define (nswindow-accessibility-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValue"))))
   ))
(define (nswindow-accessibility-value-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValueDescription"))))
   ))
(define (nswindow-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalScrollBar"))))
   ))
(define (nswindow-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnitDescription"))))
   ))
(define (nswindow-accessibility-vertical-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnits"))))
(define (nswindow-accessibility-visible-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCells"))))
   ))
(define (nswindow-accessibility-visible-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nswindow-accessibility-visible-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleChildren"))))
   ))
(define (nswindow-accessibility-visible-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleColumns"))))
   ))
(define (nswindow-accessibility-visible-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleRows"))))
   ))
(define (nswindow-accessibility-warning-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWarningValue"))))
   ))
(define (nswindow-accessibility-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindow"))))
   ))
(define (nswindow-accessibility-windows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindows"))))
   ))
(define (nswindow-accessibility-zoom-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityZoomButton"))))
   ))
(define (nswindow-add-child-window-ordered! self child-win place)
  (aw_racket_msg_Pq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addChildWindow:ordered:")) (id->ffi2-ptr (coerce-arg child-win)) place))
(define (nswindow-add-tabbed-window-ordered! self window ordered)
  (aw_racket_msg_Pq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addTabbedWindow:ordered:")) (id->ffi2-ptr (coerce-arg window)) ordered))
(define (nswindow-add-titlebar-accessory-view-controller! self child-view-controller)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addTitlebarAccessoryViewController:")) (id->ffi2-ptr (coerce-arg child-view-controller))))
(define (nswindow-animation-for-key self key)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animationForKey:")) (id->ffi2-ptr (coerce-arg key))))
   ))
(define (nswindow-animation-resize-time self new-frame)
  (aw_racket_msg_R_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animationResizeTime:")) (id->ffi2-ptr new-frame)))
(define (nswindow-animations self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animations"))))
   ))
(define (nswindow-animator self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "animator"))))
   ))
(define (nswindow-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "appearance"))))
   ))
(define (nswindow-autorecalculates-content-border-thickness-for-edge self edge)
  (aw_racket_msg_Q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autorecalculatesContentBorderThicknessForEdge:")) edge))
(define (nswindow-backing-aligned-rect-options self rect options)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RQ_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "backingAlignedRect:options:")) (id->ffi2-ptr rect) options (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nswindow-become-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "becomeFirstResponder"))))
(define (nswindow-become-key-window self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "becomeKeyWindow"))))
(define (nswindow-become-main-window self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "becomeMainWindow"))))
;; block param 1: async-copied (runtime-managed)
(define (nswindow-begin-critical-sheet-completion-handler! self sheet-window handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block handler (list _int64) _void))
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginCriticalSheet:completionHandler:")) (id->ffi2-ptr (coerce-arg sheet-window)) (id->ffi2-ptr _blk1)))
(define (nswindow-begin-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
;; block param 1: async-copied (runtime-managed)
(define (nswindow-begin-sheet-completion-handler! self sheet-window handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block handler (list _int64) _void))
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginSheet:completionHandler:")) (id->ffi2-ptr (coerce-arg sheet-window)) (id->ffi2-ptr _blk1)))
(define (nswindow-can-represent-display-gamut self display-gamut)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "canRepresentDisplayGamut:")) display-gamut))
(define (nswindow-cascade-top-left-from-point self top-left-point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cascadeTopLeftFromPoint:")) (id->ffi2-ptr top-left-point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nswindow-center! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "center"))))
(define (nswindow-change-mode-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeModeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-close! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "close"))))
(define (nswindow-constrain-frame-rect-to-screen self frame-rect screen)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RP_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "constrainFrameRect:toScreen:")) (id->ffi2-ptr frame-rect) (id->ffi2-ptr (coerce-arg screen)) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nswindow-content-border-thickness-for-edge self edge)
  (aw_racket_msg_Q_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentBorderThicknessForEdge:")) edge))
(define (nswindow-content-rect-for-frame-rect self frame-rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentRectForFrameRect:")) (id->ffi2-ptr frame-rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nswindow-context-menu-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contextMenuKeyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-convert-point-from-backing self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointFromBacking:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nswindow-convert-point-from-screen self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointFromScreen:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nswindow-convert-point-to-backing self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointToBacking:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nswindow-convert-point-to-screen self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertPointToScreen:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nswindow-convert-rect-from-backing self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectFromBacking:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nswindow-convert-rect-from-screen self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectFromScreen:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nswindow-convert-rect-to-backing self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectToBacking:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nswindow-convert-rect-to-screen self rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "convertRectToScreen:")) (id->ffi2-ptr rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nswindow-cursor-update self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cursorUpdate:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-data-with-eps-inside-rect self rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dataWithEPSInsideRect:")) (id->ffi2-ptr rect)))
   ))
(define (nswindow-data-with-pdf-inside-rect self rect)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_R_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dataWithPDFInsideRect:")) (id->ffi2-ptr rect)))
   ))
(define (nswindow-deminiaturize self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deminiaturize:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-disable-key-equivalent-for-default-button-cell self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "disableKeyEquivalentForDefaultButtonCell"))))
(define (nswindow-display! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "display"))))
(define (nswindow-display-if-needed! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displayIfNeeded"))))
(define (nswindow-displays-when-screen-profile-changes! self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "displaysWhenScreenProfileChanges"))))
(define (nswindow-effective-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "effectiveAppearance"))))
   ))
(define (nswindow-enable-key-equivalent-for-default-button-cell self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enableKeyEquivalentForDefaultButtonCell"))))
(define (nswindow-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nswindow-end-editing-for! self object)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endEditingFor:")) (id->ffi2-ptr (coerce-arg object))))
(define (nswindow-end-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-end-sheet! self sheet-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endSheet:")) (id->ffi2-ptr (coerce-arg sheet-window))))
(define (nswindow-end-sheet-return-code! self sheet-window return-code)
  (aw_racket_msg_Pq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endSheet:returnCode:")) (id->ffi2-ptr (coerce-arg sheet-window)) return-code))
(define (nswindow-field-editor-for-object self create-flag object)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_bP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fieldEditor:forObject:")) create-flag (id->ffi2-ptr (coerce-arg object))))
   ))
(define (nswindow-flags-changed self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flagsChanged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-flush-buffered-key-events self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flushBufferedKeyEvents"))))
(define (nswindow-frame-rect-for-content-rect self content-rect)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_R_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "frameRectForContentRect:")) (id->ffi2-ptr content-rect) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nswindow-help-requested self event-ptr)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "helpRequested:")) (id->ffi2-ptr (coerce-arg event-ptr))))
(define (nswindow-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "identifier"))))
   ))
(define (nswindow-insert-titlebar-accessory-view-controller-at-index! self child-view-controller index)
  (aw_racket_msg_Pq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTitlebarAccessoryViewController:atIndex:")) (id->ffi2-ptr (coerce-arg child-view-controller)) index))
(define (nswindow-interpret-key-events self event-array)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "interpretKeyEvents:")) (id->ffi2-ptr (coerce-arg event-array))))
(define (nswindow-invalidate-shadow self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "invalidateShadow"))))
(define (nswindow-is-accessibility-alternate-ui-visible self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityAlternateUIVisible"))))
(define (nswindow-is-accessibility-disclosed self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityDisclosed"))))
(define (nswindow-is-accessibility-edited self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEdited"))))
(define (nswindow-is-accessibility-element self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityElement"))))
(define (nswindow-is-accessibility-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEnabled"))))
(define (nswindow-is-accessibility-expanded self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityExpanded"))))
(define (nswindow-is-accessibility-focused self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFocused"))))
(define (nswindow-is-accessibility-frontmost self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFrontmost"))))
(define (nswindow-is-accessibility-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityHidden"))))
(define (nswindow-is-accessibility-main self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMain"))))
(define (nswindow-is-accessibility-minimized self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMinimized"))))
(define (nswindow-is-accessibility-modal self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityModal"))))
(define (nswindow-is-accessibility-ordered-by-row self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityOrderedByRow"))))
(define (nswindow-is-accessibility-protected-content self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityProtectedContent"))))
(define (nswindow-is-accessibility-required self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityRequired"))))
(define (nswindow-is-accessibility-selected self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelected"))))
(define (nswindow-is-accessibility-selector-allowed self selector)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelectorAllowed:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nswindow-is-document-edited self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isDocumentEdited"))))
(define (nswindow-is-excluded-from-windows-menu self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isExcludedFromWindowsMenu"))))
(define (nswindow-is-key-window self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isKeyWindow"))))
(define (nswindow-is-main-window self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isMainWindow"))))
(define (nswindow-is-miniaturized self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isMiniaturized"))))
(define (nswindow-is-movable self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isMovable"))))
(define (nswindow-is-movable-by-window-background self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isMovableByWindowBackground"))))
(define (nswindow-is-on-active-space self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isOnActiveSpace"))))
(define (nswindow-is-opaque self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isOpaque"))))
(define (nswindow-is-released-when-closed self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isReleasedWhenClosed"))))
(define (nswindow-is-sheet self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isSheet"))))
(define (nswindow-is-visible self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isVisible"))))
(define (nswindow-is-zoomed self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isZoomed"))))
(define (nswindow-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-key-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "magnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-make-first-responder self responder)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeFirstResponder:")) (id->ffi2-ptr (coerce-arg responder))))
(define (nswindow-make-key-and-order-front self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeKeyAndOrderFront:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-make-key-window self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeKeyWindow"))))
(define (nswindow-make-main-window self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeMainWindow"))))
(define (nswindow-merge-all-windows self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mergeAllWindows:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-miniaturize self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "miniaturize:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-mouse-cancelled self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseCancelled:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-mouse-entered self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseEntered:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-mouse-exited self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseExited:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-mouse-moved self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseMoved:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-move-tab-to-new-window! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveTabToNewWindow:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-no-responder-for self event-selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "noResponderFor:")) (id->ffi2-ptr (sel_registerName event-selector))))
(define (nswindow-order-back! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orderBack:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-order-front! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orderFront:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-order-front-regardless! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orderFrontRegardless"))))
(define (nswindow-order-out! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orderOut:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-order-window-relative-to! self place other-win)
  (aw_racket_msg_qq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orderWindow:relativeTo:")) place other-win))
(define (nswindow-other-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-other-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-other-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-perform-close! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performClose:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-perform-key-equivalent! self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performKeyEquivalent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-perform-miniaturize! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performMiniaturize:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-perform-window-drag-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performWindowDragWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-perform-zoom! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performZoom:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-pressure-change-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pressureChangeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-print self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "print:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-quick-look-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-recalculate-key-view-loop self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "recalculateKeyViewLoop"))))
(define (nswindow-remove-child-window! self child-win)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeChildWindow:")) (id->ffi2-ptr (coerce-arg child-win))))
(define (nswindow-remove-titlebar-accessory-view-controller-at-index! self index)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeTitlebarAccessoryViewControllerAtIndex:")) index))
;; block param 1: async-copied (runtime-managed)
(define (nswindow-request-sharing-of-window-completion-handler self window completion-handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block completion-handler (list _id) _void))
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "requestSharingOfWindow:completionHandler:")) (id->ffi2-ptr (coerce-arg window)) (id->ffi2-ptr _blk1)))
;; block param 2: async-copied (runtime-managed)
(define (nswindow-request-sharing-of-window-using-preview-title-completion-handler self image title completion-handler)
  (define-values (_blk2 _blk2-id)
    (make-objc-block completion-handler (list _id) _void))
  (aw_racket_msg_PPP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "requestSharingOfWindowUsingPreview:title:completionHandler:")) (id->ffi2-ptr (coerce-arg image)) (id->ffi2-ptr (coerce-arg title)) (id->ffi2-ptr _blk2)))
(define (nswindow-resign-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resignFirstResponder"))))
(define (nswindow-resign-key-window self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resignKeyWindow"))))
(define (nswindow-resign-main-window self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resignMainWindow"))))
(define (nswindow-right-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-right-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-right-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-rotate-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotateWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-run-toolbar-customization-palette self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "runToolbarCustomizationPalette:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-save-frame-using-name self name)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "saveFrameUsingName:")) (id->ffi2-ptr (coerce-arg name))))
(define (nswindow-scroll-wheel self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollWheel:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-select-key-view-following-view self view)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectKeyViewFollowingView:")) (id->ffi2-ptr (coerce-arg view))))
(define (nswindow-select-key-view-preceding-view self view)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectKeyViewPrecedingView:")) (id->ffi2-ptr (coerce-arg view))))
(define (nswindow-select-next-key-view self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectNextKeyView:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-select-next-tab self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectNextTab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-select-previous-key-view self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectPreviousKeyView:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-select-previous-tab self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectPreviousTab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-set-accessibility-activation-point! self accessibility-activation-point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityActivationPoint:")) (id->ffi2-ptr accessibility-activation-point)))
(define (nswindow-set-accessibility-allowed-values! self accessibility-allowed-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAllowedValues:")) (id->ffi2-ptr (coerce-arg accessibility-allowed-values))))
(define (nswindow-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAlternateUIVisible:")) accessibility-alternate-ui-visible))
(define (nswindow-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityApplicationFocusedUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-application-focused-ui-element))))
(define (nswindow-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAttributedUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-attributed-user-input-labels))))
(define (nswindow-set-accessibility-cancel-button! self accessibility-cancel-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCancelButton:")) (id->ffi2-ptr (coerce-arg accessibility-cancel-button))))
(define (nswindow-set-accessibility-children! self accessibility-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildren:")) (id->ffi2-ptr (coerce-arg accessibility-children))))
(define (nswindow-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildrenInNavigationOrder:")) (id->ffi2-ptr (coerce-arg accessibility-children-in-navigation-order))))
(define (nswindow-set-accessibility-clear-button! self accessibility-clear-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityClearButton:")) (id->ffi2-ptr (coerce-arg accessibility-clear-button))))
(define (nswindow-set-accessibility-close-button! self accessibility-close-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCloseButton:")) (id->ffi2-ptr (coerce-arg accessibility-close-button))))
(define (nswindow-set-accessibility-column-count! self accessibility-column-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnCount:")) accessibility-column-count))
(define (nswindow-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-column-header-ui-elements))))
(define (nswindow-set-accessibility-column-index-range! self accessibility-column-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnIndexRange:")) (id->ffi2-ptr accessibility-column-index-range)))
(define (nswindow-set-accessibility-column-titles! self accessibility-column-titles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnTitles:")) (id->ffi2-ptr (coerce-arg accessibility-column-titles))))
(define (nswindow-set-accessibility-columns! self accessibility-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumns:")) (id->ffi2-ptr (coerce-arg accessibility-columns))))
(define (nswindow-set-accessibility-contents! self accessibility-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityContents:")) (id->ffi2-ptr (coerce-arg accessibility-contents))))
(define (nswindow-set-accessibility-critical-value! self accessibility-critical-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCriticalValue:")) (id->ffi2-ptr (coerce-arg accessibility-critical-value))))
(define (nswindow-set-accessibility-custom-actions! self accessibility-custom-actions)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomActions:")) (id->ffi2-ptr (coerce-arg accessibility-custom-actions))))
(define (nswindow-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomRotors:")) (id->ffi2-ptr (coerce-arg accessibility-custom-rotors))))
(define (nswindow-set-accessibility-decrement-button! self accessibility-decrement-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDecrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-decrement-button))))
(define (nswindow-set-accessibility-default-button! self accessibility-default-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDefaultButton:")) (id->ffi2-ptr (coerce-arg accessibility-default-button))))
(define (nswindow-set-accessibility-disclosed! self accessibility-disclosed)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosed:")) accessibility-disclosed))
(define (nswindow-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedByRow:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-by-row))))
(define (nswindow-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedRows:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-rows))))
(define (nswindow-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosureLevel:")) accessibility-disclosure-level))
(define (nswindow-set-accessibility-document! self accessibility-document)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDocument:")) (id->ffi2-ptr (coerce-arg accessibility-document))))
(define (nswindow-set-accessibility-edited! self accessibility-edited)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEdited:")) accessibility-edited))
(define (nswindow-set-accessibility-element! self accessibility-element)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityElement:")) accessibility-element))
(define (nswindow-set-accessibility-enabled! self accessibility-enabled)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEnabled:")) accessibility-enabled))
(define (nswindow-set-accessibility-expanded! self accessibility-expanded)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExpanded:")) accessibility-expanded))
(define (nswindow-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExtrasMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-extras-menu-bar))))
(define (nswindow-set-accessibility-filename! self accessibility-filename)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFilename:")) (id->ffi2-ptr (coerce-arg accessibility-filename))))
(define (nswindow-set-accessibility-focused! self accessibility-focused)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocused:")) accessibility-focused))
(define (nswindow-set-accessibility-focused-window! self accessibility-focused-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocusedWindow:")) (id->ffi2-ptr (coerce-arg accessibility-focused-window))))
(define (nswindow-set-accessibility-frame! self accessibility-frame)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrame:")) (id->ffi2-ptr accessibility-frame)))
(define (nswindow-set-accessibility-frontmost! self accessibility-frontmost)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrontmost:")) accessibility-frontmost))
(define (nswindow-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFullScreenButton:")) (id->ffi2-ptr (coerce-arg accessibility-full-screen-button))))
(define (nswindow-set-accessibility-grow-area! self accessibility-grow-area)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityGrowArea:")) (id->ffi2-ptr (coerce-arg accessibility-grow-area))))
(define (nswindow-set-accessibility-handles! self accessibility-handles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHandles:")) (id->ffi2-ptr (coerce-arg accessibility-handles))))
(define (nswindow-set-accessibility-header! self accessibility-header)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHeader:")) (id->ffi2-ptr (coerce-arg accessibility-header))))
(define (nswindow-set-accessibility-help! self accessibility-help)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHelp:")) (id->ffi2-ptr (coerce-arg accessibility-help))))
(define (nswindow-set-accessibility-hidden! self accessibility-hidden)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHidden:")) accessibility-hidden))
(define (nswindow-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-scroll-bar))))
(define (nswindow-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-unit-description))))
(define (nswindow-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnits:")) accessibility-horizontal-units))
(define (nswindow-set-accessibility-identifier! self accessibility-identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIdentifier:")) (id->ffi2-ptr (coerce-arg accessibility-identifier))))
(define (nswindow-set-accessibility-increment-button! self accessibility-increment-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIncrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-increment-button))))
(define (nswindow-set-accessibility-index! self accessibility-index)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIndex:")) accessibility-index))
(define (nswindow-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityInsertionPointLineNumber:")) accessibility-insertion-point-line-number))
(define (nswindow-set-accessibility-label! self accessibility-label)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabel:")) (id->ffi2-ptr (coerce-arg accessibility-label))))
(define (nswindow-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-label-ui-elements))))
(define (nswindow-set-accessibility-label-value! self accessibility-label-value)
  (aw_racket_msg_f_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelValue:")) accessibility-label-value))
(define (nswindow-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLinkedUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-linked-ui-elements))))
(define (nswindow-set-accessibility-main! self accessibility-main)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMain:")) accessibility-main))
(define (nswindow-set-accessibility-main-window! self accessibility-main-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMainWindow:")) (id->ffi2-ptr (coerce-arg accessibility-main-window))))
(define (nswindow-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerGroupUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-marker-group-ui-element))))
(define (nswindow-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerTypeDescription:")) (id->ffi2-ptr (coerce-arg accessibility-marker-type-description))))
(define (nswindow-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-marker-ui-elements))))
(define (nswindow-set-accessibility-marker-values! self accessibility-marker-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerValues:")) (id->ffi2-ptr (coerce-arg accessibility-marker-values))))
(define (nswindow-set-accessibility-max-value! self accessibility-max-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMaxValue:")) (id->ffi2-ptr (coerce-arg accessibility-max-value))))
(define (nswindow-set-accessibility-menu-bar! self accessibility-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-menu-bar))))
(define (nswindow-set-accessibility-min-value! self accessibility-min-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinValue:")) (id->ffi2-ptr (coerce-arg accessibility-min-value))))
(define (nswindow-set-accessibility-minimize-button! self accessibility-minimize-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimizeButton:")) (id->ffi2-ptr (coerce-arg accessibility-minimize-button))))
(define (nswindow-set-accessibility-minimized! self accessibility-minimized)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimized:")) accessibility-minimized))
(define (nswindow-set-accessibility-modal! self accessibility-modal)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityModal:")) accessibility-modal))
(define (nswindow-set-accessibility-next-contents! self accessibility-next-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNextContents:")) (id->ffi2-ptr (coerce-arg accessibility-next-contents))))
(define (nswindow-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNumberOfCharacters:")) accessibility-number-of-characters))
(define (nswindow-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrderedByRow:")) accessibility-ordered-by-row))
(define (nswindow-set-accessibility-orientation! self accessibility-orientation)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrientation:")) accessibility-orientation))
(define (nswindow-set-accessibility-overflow-button! self accessibility-overflow-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOverflowButton:")) (id->ffi2-ptr (coerce-arg accessibility-overflow-button))))
(define (nswindow-set-accessibility-parent! self accessibility-parent)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityParent:")) (id->ffi2-ptr (coerce-arg accessibility-parent))))
(define (nswindow-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPlaceholderValue:")) (id->ffi2-ptr (coerce-arg accessibility-placeholder-value))))
(define (nswindow-set-accessibility-previous-contents! self accessibility-previous-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPreviousContents:")) (id->ffi2-ptr (coerce-arg accessibility-previous-contents))))
(define (nswindow-set-accessibility-protected-content! self accessibility-protected-content)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProtectedContent:")) accessibility-protected-content))
(define (nswindow-set-accessibility-proxy! self accessibility-proxy)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProxy:")) (id->ffi2-ptr (coerce-arg accessibility-proxy))))
(define (nswindow-set-accessibility-required! self accessibility-required)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRequired:")) accessibility-required))
(define (nswindow-set-accessibility-role! self accessibility-role)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRole:")) (id->ffi2-ptr (coerce-arg accessibility-role))))
(define (nswindow-set-accessibility-role-description! self accessibility-role-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRoleDescription:")) (id->ffi2-ptr (coerce-arg accessibility-role-description))))
(define (nswindow-set-accessibility-row-count! self accessibility-row-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowCount:")) accessibility-row-count))
(define (nswindow-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-row-header-ui-elements))))
(define (nswindow-set-accessibility-row-index-range! self accessibility-row-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowIndexRange:")) (id->ffi2-ptr accessibility-row-index-range)))
(define (nswindow-set-accessibility-rows! self accessibility-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRows:")) (id->ffi2-ptr (coerce-arg accessibility-rows))))
(define (nswindow-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRulerMarkerType:")) accessibility-ruler-marker-type))
(define (nswindow-set-accessibility-search-button! self accessibility-search-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchButton:")) (id->ffi2-ptr (coerce-arg accessibility-search-button))))
(define (nswindow-set-accessibility-search-menu! self accessibility-search-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchMenu:")) (id->ffi2-ptr (coerce-arg accessibility-search-menu))))
(define (nswindow-set-accessibility-selected! self accessibility-selected)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelected:")) accessibility-selected))
(define (nswindow-set-accessibility-selected-cells! self accessibility-selected-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedCells:")) (id->ffi2-ptr (coerce-arg accessibility-selected-cells))))
(define (nswindow-set-accessibility-selected-children! self accessibility-selected-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedChildren:")) (id->ffi2-ptr (coerce-arg accessibility-selected-children))))
(define (nswindow-set-accessibility-selected-columns! self accessibility-selected-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedColumns:")) (id->ffi2-ptr (coerce-arg accessibility-selected-columns))))
(define (nswindow-set-accessibility-selected-rows! self accessibility-selected-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedRows:")) (id->ffi2-ptr (coerce-arg accessibility-selected-rows))))
(define (nswindow-set-accessibility-selected-text! self accessibility-selected-text)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedText:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text))))
(define (nswindow-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRange:")) (id->ffi2-ptr accessibility-selected-text-range)))
(define (nswindow-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRanges:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text-ranges))))
(define (nswindow-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityServesAsTitleForUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-serves-as-title-for-ui-elements))))
(define (nswindow-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedCharacterRange:")) (id->ffi2-ptr accessibility-shared-character-range)))
(define (nswindow-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedFocusElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-focus-elements))))
(define (nswindow-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedTextUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-text-ui-elements))))
(define (nswindow-set-accessibility-shown-menu! self accessibility-shown-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityShownMenu:")) (id->ffi2-ptr (coerce-arg accessibility-shown-menu))))
(define (nswindow-set-accessibility-sort-direction! self accessibility-sort-direction)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySortDirection:")) accessibility-sort-direction))
(define (nswindow-set-accessibility-splitters! self accessibility-splitters)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySplitters:")) (id->ffi2-ptr (coerce-arg accessibility-splitters))))
(define (nswindow-set-accessibility-subrole! self accessibility-subrole)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySubrole:")) (id->ffi2-ptr (coerce-arg accessibility-subrole))))
(define (nswindow-set-accessibility-tabs! self accessibility-tabs)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTabs:")) (id->ffi2-ptr (coerce-arg accessibility-tabs))))
(define (nswindow-set-accessibility-title! self accessibility-title)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitle:")) (id->ffi2-ptr (coerce-arg accessibility-title))))
(define (nswindow-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitleUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-title-ui-element))))
(define (nswindow-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityToolbarButton:")) (id->ffi2-ptr (coerce-arg accessibility-toolbar-button))))
(define (nswindow-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTopLevelUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-top-level-ui-element))))
(define (nswindow-set-accessibility-url! self accessibility-url)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityURL:")) (id->ffi2-ptr (coerce-arg accessibility-url))))
(define (nswindow-set-accessibility-unit-description! self accessibility-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-unit-description))))
(define (nswindow-set-accessibility-units! self accessibility-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnits:")) accessibility-units))
(define (nswindow-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-user-input-labels))))
(define (nswindow-set-accessibility-value! self accessibility-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValue:")) (id->ffi2-ptr (coerce-arg accessibility-value))))
(define (nswindow-set-accessibility-value-description! self accessibility-value-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValueDescription:")) (id->ffi2-ptr (coerce-arg accessibility-value-description))))
(define (nswindow-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-scroll-bar))))
(define (nswindow-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-unit-description))))
(define (nswindow-set-accessibility-vertical-units! self accessibility-vertical-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnits:")) accessibility-vertical-units))
(define (nswindow-set-accessibility-visible-cells! self accessibility-visible-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCells:")) (id->ffi2-ptr (coerce-arg accessibility-visible-cells))))
(define (nswindow-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCharacterRange:")) (id->ffi2-ptr accessibility-visible-character-range)))
(define (nswindow-set-accessibility-visible-children! self accessibility-visible-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleChildren:")) (id->ffi2-ptr (coerce-arg accessibility-visible-children))))
(define (nswindow-set-accessibility-visible-columns! self accessibility-visible-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleColumns:")) (id->ffi2-ptr (coerce-arg accessibility-visible-columns))))
(define (nswindow-set-accessibility-visible-rows! self accessibility-visible-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleRows:")) (id->ffi2-ptr (coerce-arg accessibility-visible-rows))))
(define (nswindow-set-accessibility-warning-value! self accessibility-warning-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWarningValue:")) (id->ffi2-ptr (coerce-arg accessibility-warning-value))))
(define (nswindow-set-accessibility-window! self accessibility-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindow:")) (id->ffi2-ptr (coerce-arg accessibility-window))))
(define (nswindow-set-accessibility-windows! self accessibility-windows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindows:")) (id->ffi2-ptr (coerce-arg accessibility-windows))))
(define (nswindow-set-accessibility-zoom-button! self accessibility-zoom-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityZoomButton:")) (id->ffi2-ptr (coerce-arg accessibility-zoom-button))))
(define (nswindow-set-animations! self animations)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAnimations:")) (id->ffi2-ptr (coerce-arg animations))))
(define (nswindow-set-appearance! self appearance)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAppearance:")) (id->ffi2-ptr (coerce-arg appearance))))
(define (nswindow-set-autorecalculates-content-border-thickness-for-edge! self flag edge)
  (aw_racket_msg_bQ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutorecalculatesContentBorderThickness:forEdge:")) flag edge))
(define (nswindow-set-content-border-thickness-for-edge! self thickness edge)
  (aw_racket_msg_dQ_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentBorderThickness:forEdge:")) thickness edge))
(define (nswindow-set-content-size! self size)
  (aw_racket_msg_Z_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentSize:")) (id->ffi2-ptr size)))
(define (nswindow-set-dynamic-depth-limit! self flag)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDynamicDepthLimit:")) flag))
(define (nswindow-set-frame-display! self frame-rect flag)
  (aw_racket_msg_Rb_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrame:display:")) (id->ffi2-ptr frame-rect) flag))
(define (nswindow-set-frame-display-animate! self frame-rect display-flag animate-flag)
  (aw_racket_msg_Rbb_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrame:display:animate:")) (id->ffi2-ptr frame-rect) display-flag animate-flag))
(define (nswindow-set-frame-autosave-name! self name)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameAutosaveName:")) (id->ffi2-ptr (coerce-arg name))))
(define (nswindow-set-frame-from-string! self string)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameFromString:")) (id->ffi2-ptr (coerce-arg string))))
(define (nswindow-set-frame-origin! self point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameOrigin:")) (id->ffi2-ptr point)))
(define (nswindow-set-frame-top-left-point! self point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameTopLeftPoint:")) (id->ffi2-ptr point)))
(define (nswindow-set-frame-using-name! self name)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameUsingName:")) (id->ffi2-ptr (coerce-arg name))))
(define (nswindow-set-frame-using-name-force! self name force)
  (aw_racket_msg_Pb_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFrameUsingName:force:")) (id->ffi2-ptr (coerce-arg name)) force))
(define (nswindow-set-identifier! self identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIdentifier:")) (id->ffi2-ptr (coerce-arg identifier))))
(define (nswindow-set-title-with-represented-filename! self filename)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTitleWithRepresentedFilename:")) (id->ffi2-ptr (coerce-arg filename))))
(define (nswindow-should-be-treated-as-ink-event self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldBeTreatedAsInkEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-show-context-help self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextHelp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-smart-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "smartMagnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-standard-window-button self b)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "standardWindowButton:")) b))
   ))
(define (nswindow-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "supplementalTargetForAction:sender:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg sender))))
   ))
(define (nswindow-swipe-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swipeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-tablet-point self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletPoint:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-tablet-proximity self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletProximity:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-toggle-full-screen! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "toggleFullScreen:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-toggle-tab-bar! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "toggleTabBar:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-toggle-tab-overview! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "toggleTabOverview:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-toggle-toolbar-shown! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "toggleToolbarShown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindow-touches-began-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesBeganWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-touches-cancelled-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesCancelledWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-touches-ended-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesEndedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindow-touches-moved-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesMovedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
;; block param 1: async-copied (runtime-managed)
(define (nswindow-transfer-window-sharing-to-window-completion-handler self window completion-handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block completion-handler (list _id) _void))
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transferWindowSharingToWindow:completionHandler:")) (id->ffi2-ptr (coerce-arg window)) (id->ffi2-ptr _blk1)))
(define (nswindow-try-to-perform-with self action object)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tryToPerform:with:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg object))))
(define (nswindow-update self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "update"))))
(define (nswindow-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validRequestorForSendType:returnType:")) (id->ffi2-ptr (coerce-arg send-type)) (id->ffi2-ptr (coerce-arg return-type))))
   ))
(define (nswindow-validate-menu-item self menu-item)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validateMenuItem:")) (id->ffi2-ptr (coerce-arg menu-item))))
(define (nswindow-validate-user-interface-item self item)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validateUserInterfaceItem:")) (id->ffi2-ptr (coerce-arg item))))
(define (nswindow-wants-forwarded-scroll-events-for-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsForwardedScrollEventsForAxis:")) axis))
(define (nswindow-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:")) axis))
(define (nswindow-zoom self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "zoom:")) (id->ffi2-ptr (coerce-arg sender))))

;; --- Class methods ---
(define (nswindow-content-rect-for-frame-rect-style-mask f-rect style)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RQ_R (id->ffi2-ptr NSWindow) (id->ffi2-ptr (sel_registerName "contentRectForFrameRect:styleMask:")) (id->ffi2-ptr f-rect) style (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nswindow-default-animation-for-key key)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSWindow) (id->ffi2-ptr (sel_registerName "defaultAnimationForKey:")) (id->ffi2-ptr (coerce-arg key))))
   ))
(define (nswindow-frame-rect-for-content-rect-style-mask c-rect style)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_RQ_R (id->ffi2-ptr NSWindow) (id->ffi2-ptr (sel_registerName "frameRectForContentRect:styleMask:")) (id->ffi2-ptr c-rect) style (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nswindow-min-frame-width-with-title-style-mask title style)
  (aw_racket_msg_PQ_d (id->ffi2-ptr NSWindow) (id->ffi2-ptr (sel_registerName "minFrameWidthWithTitle:styleMask:")) (id->ffi2-ptr (coerce-arg title)) style))
(define (nswindow-remove-frame-using-name! name)
  (aw_racket_msg_P_v (id->ffi2-ptr NSWindow) (id->ffi2-ptr (sel_registerName "removeFrameUsingName:")) (id->ffi2-ptr (coerce-arg name))))
(define (nswindow-standard-window-button-for-style-mask b style-mask)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_QQ_P (id->ffi2-ptr NSWindow) (id->ffi2-ptr (sel_registerName "standardWindowButton:forStyleMask:")) b style-mask))
   ))
(define (nswindow-window-number-at-point-below-window-with-window-number point window-number)
  (aw_racket_msg_Oq_q (id->ffi2-ptr NSWindow) (id->ffi2-ptr (sel_registerName "windowNumberAtPoint:belowWindowWithWindowNumber:")) (id->ffi2-ptr point) window-number))
(define (nswindow-window-numbers-with-options options)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_Q_P (id->ffi2-ptr NSWindow) (id->ffi2-ptr (sel_registerName "windowNumbersWithOptions:")) options))
   ))
(define (nswindow-window-with-content-view-controller content-view-controller)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSWindow) (id->ffi2-ptr (sel_registerName "windowWithContentViewController:")) (id->ffi2-ptr (coerce-arg content-view-controller))))
   ))
