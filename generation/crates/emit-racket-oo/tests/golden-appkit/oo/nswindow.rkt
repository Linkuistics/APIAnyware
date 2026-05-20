#lang racket/base
;; Generated binding for NSWindow (AppKit)
;; Do not edit — regenerate from enriched IR

(require ffi/unsafe
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../../runtime/objc-base.rkt"
         "../../../runtime/coerce.rkt"
         "../../../runtime/block.rkt"
         "../../../runtime/type-mapping.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/AppKit.framework/AppKit"))
(define _objc-lib (ffi-lib "libobjc"))


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
  [nswindow-animation-behavior (c-> nswindow? exact-nonnegative-integer?)]
  [nswindow-set-animation-behavior! (c-> nswindow? exact-nonnegative-integer? void?)]
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
  [nswindow-default-depth-limit (c-> exact-nonnegative-integer?)]
  [nswindow-delegate (c-> nswindow? any/c)]
  [nswindow-set-delegate! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-depth-limit (c-> nswindow? exact-nonnegative-integer?)]
  [nswindow-set-depth-limit! (c-> nswindow? exact-nonnegative-integer? void?)]
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
  [nswindow-tabbing-mode (c-> nswindow? exact-nonnegative-integer?)]
  [nswindow-set-tabbing-mode! (c-> nswindow? exact-nonnegative-integer? void?)]
  [nswindow-title (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-set-title! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-title-visibility (c-> nswindow? exact-nonnegative-integer?)]
  [nswindow-set-title-visibility! (c-> nswindow? exact-nonnegative-integer? void?)]
  [nswindow-titlebar-accessory-view-controllers (c-> nswindow? any/c)]
  [nswindow-set-titlebar-accessory-view-controllers! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-titlebar-appears-transparent (c-> nswindow? boolean?)]
  [nswindow-set-titlebar-appears-transparent! (c-> nswindow? boolean? void?)]
  [nswindow-titlebar-separator-style (c-> nswindow? exact-nonnegative-integer?)]
  [nswindow-set-titlebar-separator-style! (c-> nswindow? exact-nonnegative-integer? void?)]
  [nswindow-toolbar (c-> nswindow? (or/c nstoolbar? objc-nil?))]
  [nswindow-set-toolbar! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-toolbar-style (c-> nswindow? exact-nonnegative-integer?)]
  [nswindow-set-toolbar-style! (c-> nswindow? exact-nonnegative-integer? void?)]
  [nswindow-touch-bar (c-> nswindow? (or/c nstouchbar? objc-nil?))]
  [nswindow-set-touch-bar! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-undo-manager (c-> nswindow? (or/c nsundomanager? objc-nil?))]
  [nswindow-user-activity (c-> nswindow? (or/c nsuseractivity? objc-nil?))]
  [nswindow-set-user-activity! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-user-tabbing-preference (c-> exact-nonnegative-integer?)]
  [nswindow-views-need-display (c-> nswindow? boolean?)]
  [nswindow-set-views-need-display! (c-> nswindow? boolean? void?)]
  [nswindow-visible (c-> nswindow? boolean?)]
  [nswindow-window-controller (c-> nswindow? any/c)]
  [nswindow-set-window-controller! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-window-number (c-> nswindow? exact-integer?)]
  [nswindow-window-ref (c-> nswindow? (or/c cpointer? #f))]
  [nswindow-window-titlebar-layout-direction (c-> nswindow? exact-nonnegative-integer?)]
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
  [nswindow-accessibility-horizontal-units (c-> nswindow? exact-nonnegative-integer?)]
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
  [nswindow-accessibility-orientation (c-> nswindow? exact-nonnegative-integer?)]
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
  [nswindow-accessibility-ruler-marker-type (c-> nswindow? exact-nonnegative-integer?)]
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
  [nswindow-accessibility-sort-direction (c-> nswindow? exact-nonnegative-integer?)]
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
  [nswindow-accessibility-units (c-> nswindow? exact-nonnegative-integer?)]
  [nswindow-accessibility-user-input-labels (c-> nswindow? any/c)]
  [nswindow-accessibility-value (c-> nswindow? any/c)]
  [nswindow-accessibility-value-description (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-vertical-scroll-bar (c-> nswindow? any/c)]
  [nswindow-accessibility-vertical-unit-description (c-> nswindow? (or/c nsstring? objc-nil?))]
  [nswindow-accessibility-vertical-units (c-> nswindow? exact-nonnegative-integer?)]
  [nswindow-accessibility-visible-cells (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-visible-character-range (c-> nswindow? any/c)]
  [nswindow-accessibility-visible-children (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-visible-columns (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-visible-rows (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-warning-value (c-> nswindow? any/c)]
  [nswindow-accessibility-window (c-> nswindow? any/c)]
  [nswindow-accessibility-windows (c-> nswindow? (or/c nsarray? objc-nil?))]
  [nswindow-accessibility-zoom-button (c-> nswindow? any/c)]
  [nswindow-add-child-window-ordered! (c-> nswindow? (or/c string? objc-object? #f) exact-nonnegative-integer? void?)]
  [nswindow-add-tabbed-window-ordered! (c-> nswindow? (or/c string? objc-object? #f) exact-nonnegative-integer? void?)]
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
  [nswindow-can-represent-display-gamut (c-> nswindow? exact-nonnegative-integer? boolean?)]
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
  [nswindow-order-window-relative-to! (c-> nswindow? exact-nonnegative-integer? exact-integer? void?)]
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
  [nswindow-set-accessibility-horizontal-units! (c-> nswindow? exact-nonnegative-integer? void?)]
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
  [nswindow-set-accessibility-orientation! (c-> nswindow? exact-nonnegative-integer? void?)]
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
  [nswindow-set-accessibility-ruler-marker-type! (c-> nswindow? exact-nonnegative-integer? void?)]
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
  [nswindow-set-accessibility-sort-direction! (c-> nswindow? exact-nonnegative-integer? void?)]
  [nswindow-set-accessibility-splitters! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-subrole! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-tabs! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-title! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-title-ui-element! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-toolbar-button! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-top-level-ui-element! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-url! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-unit-description! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-units! (c-> nswindow? exact-nonnegative-integer? void?)]
  [nswindow-set-accessibility-user-input-labels! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-value! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-value-description! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-vertical-scroll-bar! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-vertical-unit-description! (c-> nswindow? (or/c string? objc-object? #f) void?)]
  [nswindow-set-accessibility-vertical-units! (c-> nswindow? exact-nonnegative-integer? void?)]
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
  [nswindow-wants-forwarded-scroll-events-for-axis (c-> nswindow? exact-nonnegative-integer? boolean?)]
  [nswindow-wants-scroll-events-for-swipe-tracking-on-axis (c-> nswindow? exact-nonnegative-integer? boolean?)]
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
(define _msg-9  ; (_fun _pointer _pointer -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _uint64)))
(define _msg-10  ; (_fun _pointer _pointer _NSPoint -> _NSPoint)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _NSPoint)))
(define _msg-11  ; (_fun _pointer _pointer _NSPoint -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _NSRange)))
(define _msg-12  ; (_fun _pointer _pointer _NSPoint -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _void)))
(define _msg-13  ; (_fun _pointer _pointer _NSPoint _int64 -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint _int64 -> _int64)))
(define _msg-14  ; (_fun _pointer _pointer _NSRange -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _NSRect)))
(define _msg-15  ; (_fun _pointer _pointer _NSRange -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _id)))
(define _msg-16  ; (_fun _pointer _pointer _NSRange -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _void)))
(define _msg-17  ; (_fun _pointer _pointer _NSRect -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _NSRect)))
(define _msg-18  ; (_fun _pointer _pointer _NSRect -> _double)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _double)))
(define _msg-19  ; (_fun _pointer _pointer _NSRect -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _id)))
(define _msg-20  ; (_fun _pointer _pointer _NSRect -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _void)))
(define _msg-21  ; (_fun _pointer _pointer _NSRect _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _bool -> _void)))
(define _msg-22  ; (_fun _pointer _pointer _NSRect _bool _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _bool _bool -> _void)))
(define _msg-23  ; (_fun _pointer _pointer _NSRect _id -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _id -> _NSRect)))
(define _msg-24  ; (_fun _pointer _pointer _NSRect _uint64 -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _uint64 -> _NSRect)))
(define _msg-25  ; (_fun _pointer _pointer _NSRect _uint64 _uint64 _bool -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _uint64 _uint64 _bool -> _id)))
(define _msg-26  ; (_fun _pointer _pointer _NSRect _uint64 _uint64 _bool _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect _uint64 _uint64 _bool _id -> _id)))
(define _msg-27  ; (_fun _pointer _pointer _NSSize -> _NSSize)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize -> _NSSize)))
(define _msg-28  ; (_fun _pointer _pointer _NSSize -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize -> _void)))
(define _msg-29  ; (_fun _pointer _pointer _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _bool -> _void)))
(define _msg-30  ; (_fun _pointer _pointer _bool _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _bool _id -> _id)))
(define _msg-31  ; (_fun _pointer _pointer _bool _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _bool _uint64 -> _void)))
(define _msg-32  ; (_fun _pointer _pointer _double -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double -> _void)))
(define _msg-33  ; (_fun _pointer _pointer _double _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double _uint64 -> _void)))
(define _msg-34  ; (_fun _pointer _pointer _float -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _float -> _void)))
(define _msg-35  ; (_fun _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _bool)))
(define _msg-36  ; (_fun _pointer _pointer _id _bool -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _bool -> _bool)))
(define _msg-37  ; (_fun _pointer _pointer _id _id _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _id _pointer -> _void)))
(define _msg-38  ; (_fun _pointer _pointer _id _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _int64 -> _void)))
(define _msg-39  ; (_fun _pointer _pointer _id _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer -> _void)))
(define _msg-40  ; (_fun _pointer _pointer _id _uint64 -> _double)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _uint64 -> _double)))
(define _msg-41  ; (_fun _pointer _pointer _int32 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int32 -> _void)))
(define _msg-42  ; (_fun _pointer _pointer _int64 -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _NSRange)))
(define _msg-43  ; (_fun _pointer _pointer _int64 -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _bool)))
(define _msg-44  ; (_fun _pointer _pointer _int64 -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _int64)))
(define _msg-45  ; (_fun _pointer _pointer _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _void)))
(define _msg-46  ; (_fun _pointer _pointer _int64 _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _int64 -> _id)))
(define _msg-47  ; (_fun _pointer _pointer _int64 _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _int64 -> _void)))
(define _msg-48  ; (_fun _pointer _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _bool)))
(define _msg-49  ; (_fun _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _void)))
(define _msg-50  ; (_fun _pointer _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _bool)))
(define _msg-51  ; (_fun _pointer _pointer _pointer _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _id)))
(define _msg-52  ; (_fun _pointer _pointer _uint64 -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _bool)))
(define _msg-53  ; (_fun _pointer _pointer _uint64 -> _double)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _double)))
(define _msg-54  ; (_fun _pointer _pointer _uint64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _id)))
(define _msg-55  ; (_fun _pointer _pointer _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _void)))
(define _msg-56  ; (_fun _pointer _pointer _uint64 _uint64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 _uint64 -> _id)))

;; --- Constructors ---
(define (make-nswindow-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSWindow alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nswindow-init-with-content-rect-style-mask-backing-defer content-rect style backing-store-type flag)
  (wrap-objc-object
   (_msg-25 (tell NSWindow alloc)
       (sel_registerName "initWithContentRect:styleMask:backing:defer:")
       content-rect
       style
       backing-store-type
       flag)
   #:retained #t))

(define (make-nswindow-init-with-content-rect-style-mask-backing-defer-screen content-rect style backing-store-type flag screen)
  (wrap-objc-object
   (_msg-26 (tell NSWindow alloc)
       (sel_registerName "initWithContentRect:styleMask:backing:defer:screen:")
       content-rect
       style
       backing-store-type
       flag
       (coerce-arg screen))
   #:retained #t))


;; --- Properties ---
(define (nswindow-accepts-first-responder self)
  (tell #:type _bool (coerce-arg self) acceptsFirstResponder))
(define (nswindow-accepts-mouse-moved-events self)
  (tell #:type _bool (coerce-arg self) acceptsMouseMovedEvents))
(define (nswindow-set-accepts-mouse-moved-events! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setAcceptsMouseMovedEvents:") value))
(define (nswindow-allows-automatic-window-tabbing)
  (tell #:type _bool NSWindow allowsAutomaticWindowTabbing))
(define (nswindow-set-allows-automatic-window-tabbing! value)
  (_msg-29 NSWindow (sel_registerName "setAllowsAutomaticWindowTabbing:") value))
(define (nswindow-allows-concurrent-view-drawing self)
  (tell #:type _bool (coerce-arg self) allowsConcurrentViewDrawing))
(define (nswindow-set-allows-concurrent-view-drawing! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setAllowsConcurrentViewDrawing:") value))
(define (nswindow-allows-tool-tips-when-application-is-inactive self)
  (tell #:type _bool (coerce-arg self) allowsToolTipsWhenApplicationIsInactive))
(define (nswindow-set-allows-tool-tips-when-application-is-inactive! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setAllowsToolTipsWhenApplicationIsInactive:") value))
(define (nswindow-alpha-value self)
  (tell #:type _double (coerce-arg self) alphaValue))
(define (nswindow-set-alpha-value! self value)
  (_msg-32 (coerce-arg self) (sel_registerName "setAlphaValue:") value))
(define (nswindow-animation-behavior self)
  (tell #:type _int64 (coerce-arg self) animationBehavior))
(define (nswindow-set-animation-behavior! self value)
  (_msg-45 (coerce-arg self) (sel_registerName "setAnimationBehavior:") value))
(define (nswindow-appearance-source self)
  (wrap-objc-object
   (tell (coerce-arg self) appearanceSource)))
(define (nswindow-set-appearance-source! self value)
  (tell #:type _void (coerce-arg self) setAppearanceSource: (coerce-arg value)))
(define (nswindow-are-cursor-rects-enabled self)
  (tell #:type _bool (coerce-arg self) areCursorRectsEnabled))
(define (nswindow-aspect-ratio self)
  (tell #:type _NSSize (coerce-arg self) aspectRatio))
(define (nswindow-set-aspect-ratio! self value)
  (_msg-28 (coerce-arg self) (sel_registerName "setAspectRatio:") value))
(define (nswindow-attached-sheet self)
  (wrap-objc-object
   (tell (coerce-arg self) attachedSheet)))
(define (nswindow-autodisplay self)
  (tell #:type _bool (coerce-arg self) autodisplay))
(define (nswindow-set-autodisplay! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setAutodisplay:") value))
(define (nswindow-autorecalculates-key-view-loop self)
  (tell #:type _bool (coerce-arg self) autorecalculatesKeyViewLoop))
(define (nswindow-set-autorecalculates-key-view-loop! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setAutorecalculatesKeyViewLoop:") value))
(define (nswindow-background-color self)
  (wrap-objc-object
   (tell (coerce-arg self) backgroundColor)))
(define (nswindow-set-background-color! self value)
  (tell #:type _void (coerce-arg self) setBackgroundColor: (coerce-arg value)))
(define (nswindow-backing-location self)
  (tell #:type _uint64 (coerce-arg self) backingLocation))
(define (nswindow-backing-scale-factor self)
  (tell #:type _double (coerce-arg self) backingScaleFactor))
(define (nswindow-backing-type self)
  (tell #:type _uint64 (coerce-arg self) backingType))
(define (nswindow-set-backing-type! self value)
  (_msg-55 (coerce-arg self) (sel_registerName "setBackingType:") value))
(define (nswindow-can-become-key-window self)
  (tell #:type _bool (coerce-arg self) canBecomeKeyWindow))
(define (nswindow-can-become-main-window self)
  (tell #:type _bool (coerce-arg self) canBecomeMainWindow))
(define (nswindow-can-become-visible-without-login self)
  (tell #:type _bool (coerce-arg self) canBecomeVisibleWithoutLogin))
(define (nswindow-set-can-become-visible-without-login! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setCanBecomeVisibleWithoutLogin:") value))
(define (nswindow-can-hide self)
  (tell #:type _bool (coerce-arg self) canHide))
(define (nswindow-set-can-hide! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setCanHide:") value))
(define (nswindow-cascading-reference-frame self)
  (tell #:type _NSRect (coerce-arg self) cascadingReferenceFrame))
(define (nswindow-child-windows self)
  (wrap-objc-object
   (tell (coerce-arg self) childWindows)))
(define (nswindow-collection-behavior self)
  (tell #:type _uint64 (coerce-arg self) collectionBehavior))
(define (nswindow-set-collection-behavior! self value)
  (_msg-55 (coerce-arg self) (sel_registerName "setCollectionBehavior:") value))
(define (nswindow-color-space self)
  (wrap-objc-object
   (tell (coerce-arg self) colorSpace)))
(define (nswindow-set-color-space! self value)
  (tell #:type _void (coerce-arg self) setColorSpace: (coerce-arg value)))
(define (nswindow-content-aspect-ratio self)
  (tell #:type _NSSize (coerce-arg self) contentAspectRatio))
(define (nswindow-set-content-aspect-ratio! self value)
  (_msg-28 (coerce-arg self) (sel_registerName "setContentAspectRatio:") value))
(define (nswindow-content-layout-guide self)
  (wrap-objc-object
   (tell (coerce-arg self) contentLayoutGuide)))
(define (nswindow-content-layout-rect self)
  (tell #:type _NSRect (coerce-arg self) contentLayoutRect))
(define (nswindow-content-max-size self)
  (tell #:type _NSSize (coerce-arg self) contentMaxSize))
(define (nswindow-set-content-max-size! self value)
  (_msg-28 (coerce-arg self) (sel_registerName "setContentMaxSize:") value))
(define (nswindow-content-min-size self)
  (tell #:type _NSSize (coerce-arg self) contentMinSize))
(define (nswindow-set-content-min-size! self value)
  (_msg-28 (coerce-arg self) (sel_registerName "setContentMinSize:") value))
(define (nswindow-content-resize-increments self)
  (tell #:type _NSSize (coerce-arg self) contentResizeIncrements))
(define (nswindow-set-content-resize-increments! self value)
  (_msg-28 (coerce-arg self) (sel_registerName "setContentResizeIncrements:") value))
(define (nswindow-content-view self)
  (wrap-objc-object
   (tell (coerce-arg self) contentView)))
(define (nswindow-set-content-view! self value)
  (tell #:type _void (coerce-arg self) setContentView: (coerce-arg value)))
(define (nswindow-content-view-controller self)
  (wrap-objc-object
   (tell (coerce-arg self) contentViewController)))
(define (nswindow-set-content-view-controller! self value)
  (tell #:type _void (coerce-arg self) setContentViewController: (coerce-arg value)))
(define (nswindow-current-event self)
  (wrap-objc-object
   (tell (coerce-arg self) currentEvent)))
(define (nswindow-deepest-screen self)
  (wrap-objc-object
   (tell (coerce-arg self) deepestScreen)))
(define (nswindow-default-button-cell self)
  (wrap-objc-object
   (tell (coerce-arg self) defaultButtonCell)))
(define (nswindow-set-default-button-cell! self value)
  (tell #:type _void (coerce-arg self) setDefaultButtonCell: (coerce-arg value)))
(define (nswindow-default-depth-limit)
  (tell #:type _int32 NSWindow defaultDepthLimit))
(define (nswindow-delegate self)
  (wrap-objc-object
   (tell (coerce-arg self) delegate)))
(define (nswindow-set-delegate! self value)
  (tell #:type _void (coerce-arg self) setDelegate: (coerce-arg value)))
(define (nswindow-depth-limit self)
  (tell #:type _int32 (coerce-arg self) depthLimit))
(define (nswindow-set-depth-limit! self value)
  (_msg-41 (coerce-arg self) (sel_registerName "setDepthLimit:") value))
(define (nswindow-device-description self)
  (wrap-objc-object
   (tell (coerce-arg self) deviceDescription)))
(define (nswindow-displays-when-screen-profile-changes self)
  (tell #:type _bool (coerce-arg self) displaysWhenScreenProfileChanges))
(define (nswindow-set-displays-when-screen-profile-changes! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setDisplaysWhenScreenProfileChanges:") value))
(define (nswindow-dock-tile self)
  (wrap-objc-object
   (tell (coerce-arg self) dockTile)))
(define (nswindow-document-edited self)
  (tell #:type _bool (coerce-arg self) documentEdited))
(define (nswindow-set-document-edited! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setDocumentEdited:") value))
(define (nswindow-drawers self)
  (wrap-objc-object
   (tell (coerce-arg self) drawers)))
(define (nswindow-excluded-from-windows-menu self)
  (tell #:type _bool (coerce-arg self) excludedFromWindowsMenu))
(define (nswindow-set-excluded-from-windows-menu! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setExcludedFromWindowsMenu:") value))
(define (nswindow-first-responder self)
  (wrap-objc-object
   (tell (coerce-arg self) firstResponder)))
(define (nswindow-floating-panel self)
  (tell #:type _bool (coerce-arg self) floatingPanel))
(define (nswindow-flush-window-disabled self)
  (tell #:type _bool (coerce-arg self) flushWindowDisabled))
(define (nswindow-frame self)
  (tell #:type _NSRect (coerce-arg self) frame))
(define (nswindow-frame-autosave-name self)
  (wrap-objc-object
   (tell (coerce-arg self) frameAutosaveName)))
(define (nswindow-graphics-context self)
  (wrap-objc-object
   (tell (coerce-arg self) graphicsContext)))
(define (nswindow-has-active-window-sharing-session self)
  (tell #:type _bool (coerce-arg self) hasActiveWindowSharingSession))
(define (nswindow-has-close-box self)
  (tell #:type _bool (coerce-arg self) hasCloseBox))
(define (nswindow-has-dynamic-depth-limit self)
  (tell #:type _bool (coerce-arg self) hasDynamicDepthLimit))
(define (nswindow-has-shadow self)
  (tell #:type _bool (coerce-arg self) hasShadow))
(define (nswindow-set-has-shadow! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setHasShadow:") value))
(define (nswindow-has-title-bar self)
  (tell #:type _bool (coerce-arg self) hasTitleBar))
(define (nswindow-hides-on-deactivate self)
  (tell #:type _bool (coerce-arg self) hidesOnDeactivate))
(define (nswindow-set-hides-on-deactivate! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setHidesOnDeactivate:") value))
(define (nswindow-ignores-mouse-events self)
  (tell #:type _bool (coerce-arg self) ignoresMouseEvents))
(define (nswindow-set-ignores-mouse-events! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setIgnoresMouseEvents:") value))
(define (nswindow-in-live-resize self)
  (tell #:type _bool (coerce-arg self) inLiveResize))
(define (nswindow-initial-first-responder self)
  (wrap-objc-object
   (tell (coerce-arg self) initialFirstResponder)))
(define (nswindow-set-initial-first-responder! self value)
  (tell #:type _void (coerce-arg self) setInitialFirstResponder: (coerce-arg value)))
(define (nswindow-key-view-selection-direction self)
  (tell #:type _uint64 (coerce-arg self) keyViewSelectionDirection))
(define (nswindow-key-window self)
  (tell #:type _bool (coerce-arg self) keyWindow))
(define (nswindow-level self)
  (tell #:type _int64 (coerce-arg self) level))
(define (nswindow-set-level! self value)
  (_msg-45 (coerce-arg self) (sel_registerName "setLevel:") value))
(define (nswindow-main-window self)
  (tell #:type _bool (coerce-arg self) mainWindow))
(define (nswindow-max-full-screen-content-size self)
  (tell #:type _NSSize (coerce-arg self) maxFullScreenContentSize))
(define (nswindow-set-max-full-screen-content-size! self value)
  (_msg-28 (coerce-arg self) (sel_registerName "setMaxFullScreenContentSize:") value))
(define (nswindow-max-size self)
  (tell #:type _NSSize (coerce-arg self) maxSize))
(define (nswindow-set-max-size! self value)
  (_msg-28 (coerce-arg self) (sel_registerName "setMaxSize:") value))
(define (nswindow-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) menu)))
(define (nswindow-set-menu! self value)
  (tell #:type _void (coerce-arg self) setMenu: (coerce-arg value)))
(define (nswindow-min-full-screen-content-size self)
  (tell #:type _NSSize (coerce-arg self) minFullScreenContentSize))
(define (nswindow-set-min-full-screen-content-size! self value)
  (_msg-28 (coerce-arg self) (sel_registerName "setMinFullScreenContentSize:") value))
(define (nswindow-min-size self)
  (tell #:type _NSSize (coerce-arg self) minSize))
(define (nswindow-set-min-size! self value)
  (_msg-28 (coerce-arg self) (sel_registerName "setMinSize:") value))
(define (nswindow-miniaturizable self)
  (tell #:type _bool (coerce-arg self) miniaturizable))
(define (nswindow-miniaturized self)
  (tell #:type _bool (coerce-arg self) miniaturized))
(define (nswindow-miniwindow-image self)
  (wrap-objc-object
   (tell (coerce-arg self) miniwindowImage)))
(define (nswindow-set-miniwindow-image! self value)
  (tell #:type _void (coerce-arg self) setMiniwindowImage: (coerce-arg value)))
(define (nswindow-miniwindow-title self)
  (wrap-objc-object
   (tell (coerce-arg self) miniwindowTitle)))
(define (nswindow-set-miniwindow-title! self value)
  (tell #:type _void (coerce-arg self) setMiniwindowTitle: (coerce-arg value)))
(define (nswindow-modal-panel self)
  (tell #:type _bool (coerce-arg self) modalPanel))
(define (nswindow-mouse-location-outside-of-event-stream self)
  (tell #:type _NSPoint (coerce-arg self) mouseLocationOutsideOfEventStream))
(define (nswindow-movable self)
  (tell #:type _bool (coerce-arg self) movable))
(define (nswindow-set-movable! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setMovable:") value))
(define (nswindow-movable-by-window-background self)
  (tell #:type _bool (coerce-arg self) movableByWindowBackground))
(define (nswindow-set-movable-by-window-background! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setMovableByWindowBackground:") value))
(define (nswindow-next-responder self)
  (wrap-objc-object
   (tell (coerce-arg self) nextResponder)))
(define (nswindow-set-next-responder! self value)
  (tell #:type _void (coerce-arg self) setNextResponder: (coerce-arg value)))
(define (nswindow-occlusion-state self)
  (tell #:type _uint64 (coerce-arg self) occlusionState))
(define (nswindow-on-active-space self)
  (tell #:type _bool (coerce-arg self) onActiveSpace))
(define (nswindow-one-shot self)
  (tell #:type _bool (coerce-arg self) oneShot))
(define (nswindow-set-one-shot! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setOneShot:") value))
(define (nswindow-opaque self)
  (tell #:type _bool (coerce-arg self) opaque))
(define (nswindow-set-opaque! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setOpaque:") value))
(define (nswindow-ordered-index self)
  (tell #:type _int64 (coerce-arg self) orderedIndex))
(define (nswindow-set-ordered-index! self value)
  (_msg-45 (coerce-arg self) (sel_registerName "setOrderedIndex:") value))
(define (nswindow-parent-window self)
  (wrap-objc-object
   (tell (coerce-arg self) parentWindow)))
(define (nswindow-set-parent-window! self value)
  (tell #:type _void (coerce-arg self) setParentWindow: (coerce-arg value)))
(define (nswindow-preferred-backing-location self)
  (tell #:type _uint64 (coerce-arg self) preferredBackingLocation))
(define (nswindow-set-preferred-backing-location! self value)
  (_msg-55 (coerce-arg self) (sel_registerName "setPreferredBackingLocation:") value))
(define (nswindow-preserves-content-during-live-resize self)
  (tell #:type _bool (coerce-arg self) preservesContentDuringLiveResize))
(define (nswindow-set-preserves-content-during-live-resize! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setPreservesContentDuringLiveResize:") value))
(define (nswindow-prevents-application-termination-when-modal self)
  (tell #:type _bool (coerce-arg self) preventsApplicationTerminationWhenModal))
(define (nswindow-set-prevents-application-termination-when-modal! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setPreventsApplicationTerminationWhenModal:") value))
(define (nswindow-released-when-closed self)
  (tell #:type _bool (coerce-arg self) releasedWhenClosed))
(define (nswindow-set-released-when-closed! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setReleasedWhenClosed:") value))
(define (nswindow-represented-filename self)
  (wrap-objc-object
   (tell (coerce-arg self) representedFilename)))
(define (nswindow-set-represented-filename! self value)
  (tell #:type _void (coerce-arg self) setRepresentedFilename: (coerce-arg value)))
(define (nswindow-represented-url self)
  (wrap-objc-object
   (tell (coerce-arg self) representedURL)))
(define (nswindow-set-represented-url! self value)
  (tell #:type _void (coerce-arg self) setRepresentedURL: (coerce-arg value)))
(define (nswindow-resizable self)
  (tell #:type _bool (coerce-arg self) resizable))
(define (nswindow-resize-flags self)
  (tell #:type _uint64 (coerce-arg self) resizeFlags))
(define (nswindow-resize-increments self)
  (tell #:type _NSSize (coerce-arg self) resizeIncrements))
(define (nswindow-set-resize-increments! self value)
  (_msg-28 (coerce-arg self) (sel_registerName "setResizeIncrements:") value))
(define (nswindow-restorable self)
  (tell #:type _bool (coerce-arg self) restorable))
(define (nswindow-set-restorable! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setRestorable:") value))
(define (nswindow-restorable-state-key-paths)
  (wrap-objc-object
   (tell NSWindow restorableStateKeyPaths)))
(define (nswindow-restoration-class self)
  (wrap-objc-object
   (tell (coerce-arg self) restorationClass)))
(define (nswindow-set-restoration-class! self value)
  (tell #:type _void (coerce-arg self) setRestorationClass: (coerce-arg value)))
(define (nswindow-screen self)
  (wrap-objc-object
   (tell (coerce-arg self) screen)))
(define (nswindow-sharing-type self)
  (tell #:type _uint64 (coerce-arg self) sharingType))
(define (nswindow-set-sharing-type! self value)
  (_msg-55 (coerce-arg self) (sel_registerName "setSharingType:") value))
(define (nswindow-sheet self)
  (tell #:type _bool (coerce-arg self) sheet))
(define (nswindow-sheet-parent self)
  (wrap-objc-object
   (tell (coerce-arg self) sheetParent)))
(define (nswindow-sheets self)
  (wrap-objc-object
   (tell (coerce-arg self) sheets)))
(define (nswindow-shows-resize-indicator self)
  (tell #:type _bool (coerce-arg self) showsResizeIndicator))
(define (nswindow-set-shows-resize-indicator! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setShowsResizeIndicator:") value))
(define (nswindow-shows-toolbar-button self)
  (tell #:type _bool (coerce-arg self) showsToolbarButton))
(define (nswindow-set-shows-toolbar-button! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setShowsToolbarButton:") value))
(define (nswindow-string-with-saved-frame self)
  (wrap-objc-object
   (tell (coerce-arg self) stringWithSavedFrame)))
(define (nswindow-style-mask self)
  (tell #:type _uint64 (coerce-arg self) styleMask))
(define (nswindow-set-style-mask! self value)
  (_msg-55 (coerce-arg self) (sel_registerName "setStyleMask:") value))
(define (nswindow-subtitle self)
  (wrap-objc-object
   (tell (coerce-arg self) subtitle)))
(define (nswindow-set-subtitle! self value)
  (tell #:type _void (coerce-arg self) setSubtitle: (coerce-arg value)))
(define (nswindow-tab self)
  (wrap-objc-object
   (tell (coerce-arg self) tab)))
(define (nswindow-tab-group self)
  (wrap-objc-object
   (tell (coerce-arg self) tabGroup)))
(define (nswindow-tabbed-windows self)
  (wrap-objc-object
   (tell (coerce-arg self) tabbedWindows)))
(define (nswindow-tabbing-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) tabbingIdentifier)))
(define (nswindow-set-tabbing-identifier! self value)
  (tell #:type _void (coerce-arg self) setTabbingIdentifier: (coerce-arg value)))
(define (nswindow-tabbing-mode self)
  (tell #:type _int64 (coerce-arg self) tabbingMode))
(define (nswindow-set-tabbing-mode! self value)
  (_msg-45 (coerce-arg self) (sel_registerName "setTabbingMode:") value))
(define (nswindow-title self)
  (wrap-objc-object
   (tell (coerce-arg self) title)))
(define (nswindow-set-title! self value)
  (tell #:type _void (coerce-arg self) setTitle: (coerce-arg value)))
(define (nswindow-title-visibility self)
  (tell #:type _int64 (coerce-arg self) titleVisibility))
(define (nswindow-set-title-visibility! self value)
  (_msg-45 (coerce-arg self) (sel_registerName "setTitleVisibility:") value))
(define (nswindow-titlebar-accessory-view-controllers self)
  (wrap-objc-object
   (tell (coerce-arg self) titlebarAccessoryViewControllers)))
(define (nswindow-set-titlebar-accessory-view-controllers! self value)
  (tell #:type _void (coerce-arg self) setTitlebarAccessoryViewControllers: (coerce-arg value)))
(define (nswindow-titlebar-appears-transparent self)
  (tell #:type _bool (coerce-arg self) titlebarAppearsTransparent))
(define (nswindow-set-titlebar-appears-transparent! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setTitlebarAppearsTransparent:") value))
(define (nswindow-titlebar-separator-style self)
  (tell #:type _int64 (coerce-arg self) titlebarSeparatorStyle))
(define (nswindow-set-titlebar-separator-style! self value)
  (_msg-45 (coerce-arg self) (sel_registerName "setTitlebarSeparatorStyle:") value))
(define (nswindow-toolbar self)
  (wrap-objc-object
   (tell (coerce-arg self) toolbar)))
(define (nswindow-set-toolbar! self value)
  (tell #:type _void (coerce-arg self) setToolbar: (coerce-arg value)))
(define (nswindow-toolbar-style self)
  (tell #:type _int64 (coerce-arg self) toolbarStyle))
(define (nswindow-set-toolbar-style! self value)
  (_msg-45 (coerce-arg self) (sel_registerName "setToolbarStyle:") value))
(define (nswindow-touch-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) touchBar)))
(define (nswindow-set-touch-bar! self value)
  (tell #:type _void (coerce-arg self) setTouchBar: (coerce-arg value)))
(define (nswindow-undo-manager self)
  (wrap-objc-object
   (tell (coerce-arg self) undoManager)))
(define (nswindow-user-activity self)
  (wrap-objc-object
   (tell (coerce-arg self) userActivity)))
(define (nswindow-set-user-activity! self value)
  (tell #:type _void (coerce-arg self) setUserActivity: (coerce-arg value)))
(define (nswindow-user-tabbing-preference)
  (tell #:type _int64 NSWindow userTabbingPreference))
(define (nswindow-views-need-display self)
  (tell #:type _bool (coerce-arg self) viewsNeedDisplay))
(define (nswindow-set-views-need-display! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setViewsNeedDisplay:") value))
(define (nswindow-visible self)
  (tell #:type _bool (coerce-arg self) visible))
(define (nswindow-window-controller self)
  (wrap-objc-object
   (tell (coerce-arg self) windowController)))
(define (nswindow-set-window-controller! self value)
  (tell #:type _void (coerce-arg self) setWindowController: (coerce-arg value)))
(define (nswindow-window-number self)
  (tell #:type _int64 (coerce-arg self) windowNumber))
(define (nswindow-window-ref self)
  (tell #:type _pointer (coerce-arg self) windowRef))
(define (nswindow-window-titlebar-layout-direction self)
  (tell #:type _int64 (coerce-arg self) windowTitlebarLayoutDirection))
(define (nswindow-works-when-modal self)
  (tell #:type _bool (coerce-arg self) worksWhenModal))
(define (nswindow-zoomable self)
  (tell #:type _bool (coerce-arg self) zoomable))
(define (nswindow-zoomed self)
  (tell #:type _bool (coerce-arg self) zoomed))

;; --- Instance methods ---
(define (nswindow-accessibility-activation-point self)
  (_msg-0 (coerce-arg self) (sel_registerName "accessibilityActivationPoint")))
(define (nswindow-accessibility-allowed-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAllowedValues)))
(define (nswindow-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityApplicationFocusedUIElement)))
(define (nswindow-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (_msg-15 (coerce-arg self) (sel_registerName "accessibilityAttributedStringForRange:") range)
   ))
(define (nswindow-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAttributedUserInputLabels)))
(define (nswindow-accessibility-cancel-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCancelButton)))
(define (nswindow-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (_msg-46 (coerce-arg self) (sel_registerName "accessibilityCellForColumn:row:") column row)
   ))
(define (nswindow-accessibility-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildren)))
(define (nswindow-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildrenInNavigationOrder)))
(define (nswindow-accessibility-clear-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityClearButton)))
(define (nswindow-accessibility-close-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCloseButton)))
(define (nswindow-accessibility-column-count self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityColumnCount")))
(define (nswindow-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnHeaderUIElements)))
(define (nswindow-accessibility-column-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityColumnIndexRange")))
(define (nswindow-accessibility-column-titles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnTitles)))
(define (nswindow-accessibility-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumns)))
(define (nswindow-accessibility-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityContents)))
(define (nswindow-accessibility-critical-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCriticalValue)))
(define (nswindow-accessibility-custom-actions self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomActions)))
(define (nswindow-accessibility-custom-rotors self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomRotors)))
(define (nswindow-accessibility-decrement-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDecrementButton)))
(define (nswindow-accessibility-default-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDefaultButton)))
(define (nswindow-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedByRow)))
(define (nswindow-accessibility-disclosed-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedRows)))
(define (nswindow-accessibility-disclosure-level self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityDisclosureLevel")))
(define (nswindow-accessibility-document self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDocument)))
(define (nswindow-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityExtrasMenuBar)))
(define (nswindow-accessibility-filename self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFilename)))
(define (nswindow-accessibility-focused-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFocusedWindow)))
(define (nswindow-accessibility-frame self)
  (_msg-2 (coerce-arg self) (sel_registerName "accessibilityFrame")))
(define (nswindow-accessibility-frame-for-range self range)
  (_msg-14 (coerce-arg self) (sel_registerName "accessibilityFrameForRange:") range))
(define (nswindow-accessibility-full-screen-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFullScreenButton)))
(define (nswindow-accessibility-grow-area self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityGrowArea)))
(define (nswindow-accessibility-handles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHandles)))
(define (nswindow-accessibility-header self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHeader)))
(define (nswindow-accessibility-help self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHelp)))
(define (nswindow-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalScrollBar)))
(define (nswindow-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalUnitDescription)))
(define (nswindow-accessibility-horizontal-units self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityHorizontalUnits")))
(define (nswindow-accessibility-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIdentifier)))
(define (nswindow-accessibility-increment-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIncrementButton)))
(define (nswindow-accessibility-index self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityIndex")))
(define (nswindow-accessibility-insertion-point-line-number self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityInsertionPointLineNumber")))
(define (nswindow-accessibility-label self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabel)))
(define (nswindow-accessibility-label-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabelUIElements)))
(define (nswindow-accessibility-label-value self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityLabelValue")))
(define (nswindow-accessibility-layout-point-for-screen-point self point)
  (_msg-10 (coerce-arg self) (sel_registerName "accessibilityLayoutPointForScreenPoint:") point))
(define (nswindow-accessibility-layout-size-for-screen-size self size)
  (_msg-27 (coerce-arg self) (sel_registerName "accessibilityLayoutSizeForScreenSize:") size))
(define (nswindow-accessibility-line-for-index self index)
  (_msg-44 (coerce-arg self) (sel_registerName "accessibilityLineForIndex:") index))
(define (nswindow-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLinkedUIElements)))
(define (nswindow-accessibility-main-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMainWindow)))
(define (nswindow-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerGroupUIElement)))
(define (nswindow-accessibility-marker-type-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerTypeDescription)))
(define (nswindow-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerUIElements)))
(define (nswindow-accessibility-marker-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerValues)))
(define (nswindow-accessibility-max-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMaxValue)))
(define (nswindow-accessibility-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMenuBar)))
(define (nswindow-accessibility-min-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinValue)))
(define (nswindow-accessibility-minimize-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinimizeButton)))
(define (nswindow-accessibility-next-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityNextContents)))
(define (nswindow-accessibility-number-of-characters self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityNumberOfCharacters")))
(define (nswindow-accessibility-orientation self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityOrientation")))
(define (nswindow-accessibility-overflow-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityOverflowButton)))
(define (nswindow-accessibility-parent self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityParent)))
(define (nswindow-accessibility-perform-cancel self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformCancel")))
(define (nswindow-accessibility-perform-confirm self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformConfirm")))
(define (nswindow-accessibility-perform-decrement self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformDecrement")))
(define (nswindow-accessibility-perform-delete self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformDelete")))
(define (nswindow-accessibility-perform-increment self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformIncrement")))
(define (nswindow-accessibility-perform-pick self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformPick")))
(define (nswindow-accessibility-perform-press self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformPress")))
(define (nswindow-accessibility-perform-raise self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformRaise")))
(define (nswindow-accessibility-perform-show-alternate-ui self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformShowAlternateUI")))
(define (nswindow-accessibility-perform-show-default-ui self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformShowDefaultUI")))
(define (nswindow-accessibility-perform-show-menu self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformShowMenu")))
(define (nswindow-accessibility-placeholder-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPlaceholderValue)))
(define (nswindow-accessibility-previous-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPreviousContents)))
(define (nswindow-accessibility-proxy self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityProxy)))
(define (nswindow-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (_msg-15 (coerce-arg self) (sel_registerName "accessibilityRTFForRange:") range)
   ))
(define (nswindow-accessibility-range-for-index self index)
  (_msg-42 (coerce-arg self) (sel_registerName "accessibilityRangeForIndex:") index))
(define (nswindow-accessibility-range-for-line self line)
  (_msg-42 (coerce-arg self) (sel_registerName "accessibilityRangeForLine:") line))
(define (nswindow-accessibility-range-for-position self point)
  (_msg-11 (coerce-arg self) (sel_registerName "accessibilityRangeForPosition:") point))
(define (nswindow-accessibility-role self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRole)))
(define (nswindow-accessibility-role-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRoleDescription)))
(define (nswindow-accessibility-row-count self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityRowCount")))
(define (nswindow-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRowHeaderUIElements)))
(define (nswindow-accessibility-row-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityRowIndexRange")))
(define (nswindow-accessibility-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRows)))
(define (nswindow-accessibility-ruler-marker-type self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityRulerMarkerType")))
(define (nswindow-accessibility-screen-point-for-layout-point self point)
  (_msg-10 (coerce-arg self) (sel_registerName "accessibilityScreenPointForLayoutPoint:") point))
(define (nswindow-accessibility-screen-size-for-layout-size self size)
  (_msg-27 (coerce-arg self) (sel_registerName "accessibilityScreenSizeForLayoutSize:") size))
(define (nswindow-accessibility-search-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchButton)))
(define (nswindow-accessibility-search-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchMenu)))
(define (nswindow-accessibility-selected-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedCells)))
(define (nswindow-accessibility-selected-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedChildren)))
(define (nswindow-accessibility-selected-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedColumns)))
(define (nswindow-accessibility-selected-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedRows)))
(define (nswindow-accessibility-selected-text self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedText)))
(define (nswindow-accessibility-selected-text-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySelectedTextRange")))
(define (nswindow-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedTextRanges)))
(define (nswindow-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityServesAsTitleForUIElements)))
(define (nswindow-accessibility-shared-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySharedCharacterRange")))
(define (nswindow-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedFocusElements)))
(define (nswindow-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedTextUIElements)))
(define (nswindow-accessibility-shown-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityShownMenu)))
(define (nswindow-accessibility-sort-direction self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilitySortDirection")))
(define (nswindow-accessibility-splitters self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySplitters)))
(define (nswindow-accessibility-string-for-range self range)
  (wrap-objc-object
   (_msg-15 (coerce-arg self) (sel_registerName "accessibilityStringForRange:") range)
   ))
(define (nswindow-accessibility-style-range-for-index self index)
  (_msg-42 (coerce-arg self) (sel_registerName "accessibilityStyleRangeForIndex:") index))
(define (nswindow-accessibility-subrole self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySubrole)))
(define (nswindow-accessibility-tabs self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTabs)))
(define (nswindow-accessibility-title self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitle)))
(define (nswindow-accessibility-title-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitleUIElement)))
(define (nswindow-accessibility-toolbar-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityToolbarButton)))
(define (nswindow-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTopLevelUIElement)))
(define (nswindow-accessibility-url self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityURL)))
(define (nswindow-accessibility-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUnitDescription)))
(define (nswindow-accessibility-units self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityUnits")))
(define (nswindow-accessibility-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUserInputLabels)))
(define (nswindow-accessibility-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValue)))
(define (nswindow-accessibility-value-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValueDescription)))
(define (nswindow-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalScrollBar)))
(define (nswindow-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalUnitDescription)))
(define (nswindow-accessibility-vertical-units self)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityVerticalUnits")))
(define (nswindow-accessibility-visible-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleCells)))
(define (nswindow-accessibility-visible-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityVisibleCharacterRange")))
(define (nswindow-accessibility-visible-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleChildren)))
(define (nswindow-accessibility-visible-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleColumns)))
(define (nswindow-accessibility-visible-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleRows)))
(define (nswindow-accessibility-warning-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWarningValue)))
(define (nswindow-accessibility-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindow)))
(define (nswindow-accessibility-windows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindows)))
(define (nswindow-accessibility-zoom-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityZoomButton)))
(define (nswindow-add-child-window-ordered! self child-win place)
  (_msg-38 (coerce-arg self) (sel_registerName "addChildWindow:ordered:") (coerce-arg child-win) place))
(define (nswindow-add-tabbed-window-ordered! self window ordered)
  (_msg-38 (coerce-arg self) (sel_registerName "addTabbedWindow:ordered:") (coerce-arg window) ordered))
(define (nswindow-add-titlebar-accessory-view-controller! self child-view-controller)
  (tell #:type _void (coerce-arg self) addTitlebarAccessoryViewController: (coerce-arg child-view-controller)))
(define (nswindow-animation-for-key self key)
  (wrap-objc-object
   (tell (coerce-arg self) animationForKey: (coerce-arg key))))
(define (nswindow-animation-resize-time self new-frame)
  (_msg-18 (coerce-arg self) (sel_registerName "animationResizeTime:") new-frame))
(define (nswindow-animations self)
  (wrap-objc-object
   (tell (coerce-arg self) animations)))
(define (nswindow-animator self)
  (wrap-objc-object
   (tell (coerce-arg self) animator)))
(define (nswindow-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) appearance)))
(define (nswindow-autorecalculates-content-border-thickness-for-edge self edge)
  (_msg-52 (coerce-arg self) (sel_registerName "autorecalculatesContentBorderThicknessForEdge:") edge))
(define (nswindow-backing-aligned-rect-options self rect options)
  (_msg-24 (coerce-arg self) (sel_registerName "backingAlignedRect:options:") rect options))
(define (nswindow-become-first-responder self)
  (_msg-4 (coerce-arg self) (sel_registerName "becomeFirstResponder")))
(define (nswindow-become-key-window self)
  (tell #:type _void (coerce-arg self) becomeKeyWindow))
(define (nswindow-become-main-window self)
  (tell #:type _void (coerce-arg self) becomeMainWindow))
(define (nswindow-begin-critical-sheet-completion-handler! self sheet-window handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block handler (list _int64) _void))
  (_msg-39 (coerce-arg self) (sel_registerName "beginCriticalSheet:completionHandler:") (coerce-arg sheet-window) _blk1))
(define (nswindow-begin-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) beginGestureWithEvent: (coerce-arg event)))
(define (nswindow-begin-sheet-completion-handler! self sheet-window handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block handler (list _int64) _void))
  (_msg-39 (coerce-arg self) (sel_registerName "beginSheet:completionHandler:") (coerce-arg sheet-window) _blk1))
(define (nswindow-can-represent-display-gamut self display-gamut)
  (_msg-43 (coerce-arg self) (sel_registerName "canRepresentDisplayGamut:") display-gamut))
(define (nswindow-cascade-top-left-from-point self top-left-point)
  (_msg-10 (coerce-arg self) (sel_registerName "cascadeTopLeftFromPoint:") top-left-point))
(define (nswindow-center! self)
  (tell #:type _void (coerce-arg self) center))
(define (nswindow-change-mode-with-event self event)
  (tell #:type _void (coerce-arg self) changeModeWithEvent: (coerce-arg event)))
(define (nswindow-close! self)
  (tell #:type _void (coerce-arg self) close))
(define (nswindow-constrain-frame-rect-to-screen self frame-rect screen)
  (_msg-23 (coerce-arg self) (sel_registerName "constrainFrameRect:toScreen:") frame-rect (coerce-arg screen)))
(define (nswindow-content-border-thickness-for-edge self edge)
  (_msg-53 (coerce-arg self) (sel_registerName "contentBorderThicknessForEdge:") edge))
(define (nswindow-content-rect-for-frame-rect self frame-rect)
  (_msg-17 (coerce-arg self) (sel_registerName "contentRectForFrameRect:") frame-rect))
(define (nswindow-context-menu-key-down self event)
  (tell #:type _void (coerce-arg self) contextMenuKeyDown: (coerce-arg event)))
(define (nswindow-convert-point-from-backing self point)
  (_msg-10 (coerce-arg self) (sel_registerName "convertPointFromBacking:") point))
(define (nswindow-convert-point-from-screen self point)
  (_msg-10 (coerce-arg self) (sel_registerName "convertPointFromScreen:") point))
(define (nswindow-convert-point-to-backing self point)
  (_msg-10 (coerce-arg self) (sel_registerName "convertPointToBacking:") point))
(define (nswindow-convert-point-to-screen self point)
  (_msg-10 (coerce-arg self) (sel_registerName "convertPointToScreen:") point))
(define (nswindow-convert-rect-from-backing self rect)
  (_msg-17 (coerce-arg self) (sel_registerName "convertRectFromBacking:") rect))
(define (nswindow-convert-rect-from-screen self rect)
  (_msg-17 (coerce-arg self) (sel_registerName "convertRectFromScreen:") rect))
(define (nswindow-convert-rect-to-backing self rect)
  (_msg-17 (coerce-arg self) (sel_registerName "convertRectToBacking:") rect))
(define (nswindow-convert-rect-to-screen self rect)
  (_msg-17 (coerce-arg self) (sel_registerName "convertRectToScreen:") rect))
(define (nswindow-cursor-update self event)
  (tell #:type _void (coerce-arg self) cursorUpdate: (coerce-arg event)))
(define (nswindow-data-with-eps-inside-rect self rect)
  (wrap-objc-object
   (_msg-19 (coerce-arg self) (sel_registerName "dataWithEPSInsideRect:") rect)
   ))
(define (nswindow-data-with-pdf-inside-rect self rect)
  (wrap-objc-object
   (_msg-19 (coerce-arg self) (sel_registerName "dataWithPDFInsideRect:") rect)
   ))
(define (nswindow-deminiaturize self sender)
  (tell #:type _void (coerce-arg self) deminiaturize: (coerce-arg sender)))
(define (nswindow-disable-key-equivalent-for-default-button-cell self)
  (tell #:type _void (coerce-arg self) disableKeyEquivalentForDefaultButtonCell))
(define (nswindow-display! self)
  (tell #:type _void (coerce-arg self) display))
(define (nswindow-display-if-needed! self)
  (tell #:type _void (coerce-arg self) displayIfNeeded))
(define (nswindow-displays-when-screen-profile-changes! self)
  (_msg-4 (coerce-arg self) (sel_registerName "displaysWhenScreenProfileChanges")))
(define (nswindow-effective-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) effectiveAppearance)))
(define (nswindow-enable-key-equivalent-for-default-button-cell self)
  (tell #:type _void (coerce-arg self) enableKeyEquivalentForDefaultButtonCell))
(define (nswindow-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nswindow-end-editing-for! self object)
  (tell #:type _void (coerce-arg self) endEditingFor: (coerce-arg object)))
(define (nswindow-end-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) endGestureWithEvent: (coerce-arg event)))
(define (nswindow-end-sheet! self sheet-window)
  (tell #:type _void (coerce-arg self) endSheet: (coerce-arg sheet-window)))
(define (nswindow-end-sheet-return-code! self sheet-window return-code)
  (_msg-38 (coerce-arg self) (sel_registerName "endSheet:returnCode:") (coerce-arg sheet-window) return-code))
(define (nswindow-field-editor-for-object self create-flag object)
  (wrap-objc-object
   (_msg-30 (coerce-arg self) (sel_registerName "fieldEditor:forObject:") create-flag (coerce-arg object))
   ))
(define (nswindow-flags-changed self event)
  (tell #:type _void (coerce-arg self) flagsChanged: (coerce-arg event)))
(define (nswindow-flush-buffered-key-events self)
  (tell #:type _void (coerce-arg self) flushBufferedKeyEvents))
(define (nswindow-frame-rect-for-content-rect self content-rect)
  (_msg-17 (coerce-arg self) (sel_registerName "frameRectForContentRect:") content-rect))
(define (nswindow-help-requested self event-ptr)
  (tell #:type _void (coerce-arg self) helpRequested: (coerce-arg event-ptr)))
(define (nswindow-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) identifier)))
(define (nswindow-insert-titlebar-accessory-view-controller-at-index! self child-view-controller index)
  (_msg-38 (coerce-arg self) (sel_registerName "insertTitlebarAccessoryViewController:atIndex:") (coerce-arg child-view-controller) index))
(define (nswindow-interpret-key-events self event-array)
  (tell #:type _void (coerce-arg self) interpretKeyEvents: (coerce-arg event-array)))
(define (nswindow-invalidate-shadow self)
  (tell #:type _void (coerce-arg self) invalidateShadow))
(define (nswindow-is-accessibility-alternate-ui-visible self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityAlternateUIVisible")))
(define (nswindow-is-accessibility-disclosed self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityDisclosed")))
(define (nswindow-is-accessibility-edited self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityEdited")))
(define (nswindow-is-accessibility-element self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityElement")))
(define (nswindow-is-accessibility-enabled self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityEnabled")))
(define (nswindow-is-accessibility-expanded self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityExpanded")))
(define (nswindow-is-accessibility-focused self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityFocused")))
(define (nswindow-is-accessibility-frontmost self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityFrontmost")))
(define (nswindow-is-accessibility-hidden self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityHidden")))
(define (nswindow-is-accessibility-main self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityMain")))
(define (nswindow-is-accessibility-minimized self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityMinimized")))
(define (nswindow-is-accessibility-modal self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityModal")))
(define (nswindow-is-accessibility-ordered-by-row self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityOrderedByRow")))
(define (nswindow-is-accessibility-protected-content self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityProtectedContent")))
(define (nswindow-is-accessibility-required self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityRequired")))
(define (nswindow-is-accessibility-selected self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilitySelected")))
(define (nswindow-is-accessibility-selector-allowed self selector)
  (_msg-48 (coerce-arg self) (sel_registerName "isAccessibilitySelectorAllowed:") (sel_registerName selector)))
(define (nswindow-is-document-edited self)
  (_msg-4 (coerce-arg self) (sel_registerName "isDocumentEdited")))
(define (nswindow-is-excluded-from-windows-menu self)
  (_msg-4 (coerce-arg self) (sel_registerName "isExcludedFromWindowsMenu")))
(define (nswindow-is-key-window self)
  (_msg-4 (coerce-arg self) (sel_registerName "isKeyWindow")))
(define (nswindow-is-main-window self)
  (_msg-4 (coerce-arg self) (sel_registerName "isMainWindow")))
(define (nswindow-is-miniaturized self)
  (_msg-4 (coerce-arg self) (sel_registerName "isMiniaturized")))
(define (nswindow-is-movable self)
  (_msg-4 (coerce-arg self) (sel_registerName "isMovable")))
(define (nswindow-is-movable-by-window-background self)
  (_msg-4 (coerce-arg self) (sel_registerName "isMovableByWindowBackground")))
(define (nswindow-is-on-active-space self)
  (_msg-4 (coerce-arg self) (sel_registerName "isOnActiveSpace")))
(define (nswindow-is-opaque self)
  (_msg-4 (coerce-arg self) (sel_registerName "isOpaque")))
(define (nswindow-is-released-when-closed self)
  (_msg-4 (coerce-arg self) (sel_registerName "isReleasedWhenClosed")))
(define (nswindow-is-sheet self)
  (_msg-4 (coerce-arg self) (sel_registerName "isSheet")))
(define (nswindow-is-visible self)
  (_msg-4 (coerce-arg self) (sel_registerName "isVisible")))
(define (nswindow-is-zoomed self)
  (_msg-4 (coerce-arg self) (sel_registerName "isZoomed")))
(define (nswindow-key-down self event)
  (tell #:type _void (coerce-arg self) keyDown: (coerce-arg event)))
(define (nswindow-key-up self event)
  (tell #:type _void (coerce-arg self) keyUp: (coerce-arg event)))
(define (nswindow-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) magnifyWithEvent: (coerce-arg event)))
(define (nswindow-make-first-responder self responder)
  (_msg-35 (coerce-arg self) (sel_registerName "makeFirstResponder:") (coerce-arg responder)))
(define (nswindow-make-key-and-order-front self sender)
  (tell #:type _void (coerce-arg self) makeKeyAndOrderFront: (coerce-arg sender)))
(define (nswindow-make-key-window self)
  (tell #:type _void (coerce-arg self) makeKeyWindow))
(define (nswindow-make-main-window self)
  (tell #:type _void (coerce-arg self) makeMainWindow))
(define (nswindow-merge-all-windows self sender)
  (tell #:type _void (coerce-arg self) mergeAllWindows: (coerce-arg sender)))
(define (nswindow-miniaturize self sender)
  (tell #:type _void (coerce-arg self) miniaturize: (coerce-arg sender)))
(define (nswindow-mouse-cancelled self event)
  (tell #:type _void (coerce-arg self) mouseCancelled: (coerce-arg event)))
(define (nswindow-mouse-down self event)
  (tell #:type _void (coerce-arg self) mouseDown: (coerce-arg event)))
(define (nswindow-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) mouseDragged: (coerce-arg event)))
(define (nswindow-mouse-entered self event)
  (tell #:type _void (coerce-arg self) mouseEntered: (coerce-arg event)))
(define (nswindow-mouse-exited self event)
  (tell #:type _void (coerce-arg self) mouseExited: (coerce-arg event)))
(define (nswindow-mouse-moved self event)
  (tell #:type _void (coerce-arg self) mouseMoved: (coerce-arg event)))
(define (nswindow-mouse-up self event)
  (tell #:type _void (coerce-arg self) mouseUp: (coerce-arg event)))
(define (nswindow-move-tab-to-new-window! self sender)
  (tell #:type _void (coerce-arg self) moveTabToNewWindow: (coerce-arg sender)))
(define (nswindow-no-responder-for self event-selector)
  (_msg-49 (coerce-arg self) (sel_registerName "noResponderFor:") (sel_registerName event-selector)))
(define (nswindow-order-back! self sender)
  (tell #:type _void (coerce-arg self) orderBack: (coerce-arg sender)))
(define (nswindow-order-front! self sender)
  (tell #:type _void (coerce-arg self) orderFront: (coerce-arg sender)))
(define (nswindow-order-front-regardless! self)
  (tell #:type _void (coerce-arg self) orderFrontRegardless))
(define (nswindow-order-out! self sender)
  (tell #:type _void (coerce-arg self) orderOut: (coerce-arg sender)))
(define (nswindow-order-window-relative-to! self place other-win)
  (_msg-47 (coerce-arg self) (sel_registerName "orderWindow:relativeTo:") place other-win))
(define (nswindow-other-mouse-down self event)
  (tell #:type _void (coerce-arg self) otherMouseDown: (coerce-arg event)))
(define (nswindow-other-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) otherMouseDragged: (coerce-arg event)))
(define (nswindow-other-mouse-up self event)
  (tell #:type _void (coerce-arg self) otherMouseUp: (coerce-arg event)))
(define (nswindow-perform-close! self sender)
  (tell #:type _void (coerce-arg self) performClose: (coerce-arg sender)))
(define (nswindow-perform-key-equivalent! self event)
  (_msg-35 (coerce-arg self) (sel_registerName "performKeyEquivalent:") (coerce-arg event)))
(define (nswindow-perform-miniaturize! self sender)
  (tell #:type _void (coerce-arg self) performMiniaturize: (coerce-arg sender)))
(define (nswindow-perform-window-drag-with-event! self event)
  (tell #:type _void (coerce-arg self) performWindowDragWithEvent: (coerce-arg event)))
(define (nswindow-perform-zoom! self sender)
  (tell #:type _void (coerce-arg self) performZoom: (coerce-arg sender)))
(define (nswindow-pressure-change-with-event self event)
  (tell #:type _void (coerce-arg self) pressureChangeWithEvent: (coerce-arg event)))
(define (nswindow-print self sender)
  (tell #:type _void (coerce-arg self) print: (coerce-arg sender)))
(define (nswindow-quick-look-with-event self event)
  (tell #:type _void (coerce-arg self) quickLookWithEvent: (coerce-arg event)))
(define (nswindow-recalculate-key-view-loop self)
  (tell #:type _void (coerce-arg self) recalculateKeyViewLoop))
(define (nswindow-remove-child-window! self child-win)
  (tell #:type _void (coerce-arg self) removeChildWindow: (coerce-arg child-win)))
(define (nswindow-remove-titlebar-accessory-view-controller-at-index! self index)
  (_msg-45 (coerce-arg self) (sel_registerName "removeTitlebarAccessoryViewControllerAtIndex:") index))
(define (nswindow-request-sharing-of-window-completion-handler self window completion-handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block completion-handler (list _id) _void))
  (_msg-39 (coerce-arg self) (sel_registerName "requestSharingOfWindow:completionHandler:") (coerce-arg window) _blk1))
(define (nswindow-request-sharing-of-window-using-preview-title-completion-handler self image title completion-handler)
  (define-values (_blk2 _blk2-id)
    (make-objc-block completion-handler (list _id) _void))
  (_msg-37 (coerce-arg self) (sel_registerName "requestSharingOfWindowUsingPreview:title:completionHandler:") (coerce-arg image) (coerce-arg title) _blk2))
(define (nswindow-resign-first-responder self)
  (_msg-4 (coerce-arg self) (sel_registerName "resignFirstResponder")))
(define (nswindow-resign-key-window self)
  (tell #:type _void (coerce-arg self) resignKeyWindow))
(define (nswindow-resign-main-window self)
  (tell #:type _void (coerce-arg self) resignMainWindow))
(define (nswindow-right-mouse-down self event)
  (tell #:type _void (coerce-arg self) rightMouseDown: (coerce-arg event)))
(define (nswindow-right-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) rightMouseDragged: (coerce-arg event)))
(define (nswindow-right-mouse-up self event)
  (tell #:type _void (coerce-arg self) rightMouseUp: (coerce-arg event)))
(define (nswindow-rotate-with-event self event)
  (tell #:type _void (coerce-arg self) rotateWithEvent: (coerce-arg event)))
(define (nswindow-run-toolbar-customization-palette self sender)
  (tell #:type _void (coerce-arg self) runToolbarCustomizationPalette: (coerce-arg sender)))
(define (nswindow-save-frame-using-name self name)
  (tell #:type _void (coerce-arg self) saveFrameUsingName: (coerce-arg name)))
(define (nswindow-scroll-wheel self event)
  (tell #:type _void (coerce-arg self) scrollWheel: (coerce-arg event)))
(define (nswindow-select-key-view-following-view self view)
  (tell #:type _void (coerce-arg self) selectKeyViewFollowingView: (coerce-arg view)))
(define (nswindow-select-key-view-preceding-view self view)
  (tell #:type _void (coerce-arg self) selectKeyViewPrecedingView: (coerce-arg view)))
(define (nswindow-select-next-key-view self sender)
  (tell #:type _void (coerce-arg self) selectNextKeyView: (coerce-arg sender)))
(define (nswindow-select-next-tab self sender)
  (tell #:type _void (coerce-arg self) selectNextTab: (coerce-arg sender)))
(define (nswindow-select-previous-key-view self sender)
  (tell #:type _void (coerce-arg self) selectPreviousKeyView: (coerce-arg sender)))
(define (nswindow-select-previous-tab self sender)
  (tell #:type _void (coerce-arg self) selectPreviousTab: (coerce-arg sender)))
(define (nswindow-set-accessibility-activation-point! self accessibility-activation-point)
  (_msg-12 (coerce-arg self) (sel_registerName "setAccessibilityActivationPoint:") accessibility-activation-point))
(define (nswindow-set-accessibility-allowed-values! self accessibility-allowed-values)
  (tell #:type _void (coerce-arg self) setAccessibilityAllowedValues: (coerce-arg accessibility-allowed-values)))
(define (nswindow-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityAlternateUIVisible:") accessibility-alternate-ui-visible))
(define (nswindow-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityApplicationFocusedUIElement: (coerce-arg accessibility-application-focused-ui-element)))
(define (nswindow-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityAttributedUserInputLabels: (coerce-arg accessibility-attributed-user-input-labels)))
(define (nswindow-set-accessibility-cancel-button! self accessibility-cancel-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCancelButton: (coerce-arg accessibility-cancel-button)))
(define (nswindow-set-accessibility-children! self accessibility-children)
  (tell #:type _void (coerce-arg self) setAccessibilityChildren: (coerce-arg accessibility-children)))
(define (nswindow-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (tell #:type _void (coerce-arg self) setAccessibilityChildrenInNavigationOrder: (coerce-arg accessibility-children-in-navigation-order)))
(define (nswindow-set-accessibility-clear-button! self accessibility-clear-button)
  (tell #:type _void (coerce-arg self) setAccessibilityClearButton: (coerce-arg accessibility-clear-button)))
(define (nswindow-set-accessibility-close-button! self accessibility-close-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCloseButton: (coerce-arg accessibility-close-button)))
(define (nswindow-set-accessibility-column-count! self accessibility-column-count)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityColumnCount:") accessibility-column-count))
(define (nswindow-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnHeaderUIElements: (coerce-arg accessibility-column-header-ui-elements)))
(define (nswindow-set-accessibility-column-index-range! self accessibility-column-index-range)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityColumnIndexRange:") accessibility-column-index-range))
(define (nswindow-set-accessibility-column-titles! self accessibility-column-titles)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnTitles: (coerce-arg accessibility-column-titles)))
(define (nswindow-set-accessibility-columns! self accessibility-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityColumns: (coerce-arg accessibility-columns)))
(define (nswindow-set-accessibility-contents! self accessibility-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityContents: (coerce-arg accessibility-contents)))
(define (nswindow-set-accessibility-critical-value! self accessibility-critical-value)
  (tell #:type _void (coerce-arg self) setAccessibilityCriticalValue: (coerce-arg accessibility-critical-value)))
(define (nswindow-set-accessibility-custom-actions! self accessibility-custom-actions)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomActions: (coerce-arg accessibility-custom-actions)))
(define (nswindow-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomRotors: (coerce-arg accessibility-custom-rotors)))
(define (nswindow-set-accessibility-decrement-button! self accessibility-decrement-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDecrementButton: (coerce-arg accessibility-decrement-button)))
(define (nswindow-set-accessibility-default-button! self accessibility-default-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDefaultButton: (coerce-arg accessibility-default-button)))
(define (nswindow-set-accessibility-disclosed! self accessibility-disclosed)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityDisclosed:") accessibility-disclosed))
(define (nswindow-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedByRow: (coerce-arg accessibility-disclosed-by-row)))
(define (nswindow-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedRows: (coerce-arg accessibility-disclosed-rows)))
(define (nswindow-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityDisclosureLevel:") accessibility-disclosure-level))
(define (nswindow-set-accessibility-document! self accessibility-document)
  (tell #:type _void (coerce-arg self) setAccessibilityDocument: (coerce-arg accessibility-document)))
(define (nswindow-set-accessibility-edited! self accessibility-edited)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityEdited:") accessibility-edited))
(define (nswindow-set-accessibility-element! self accessibility-element)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityElement:") accessibility-element))
(define (nswindow-set-accessibility-enabled! self accessibility-enabled)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityEnabled:") accessibility-enabled))
(define (nswindow-set-accessibility-expanded! self accessibility-expanded)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityExpanded:") accessibility-expanded))
(define (nswindow-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityExtrasMenuBar: (coerce-arg accessibility-extras-menu-bar)))
(define (nswindow-set-accessibility-filename! self accessibility-filename)
  (tell #:type _void (coerce-arg self) setAccessibilityFilename: (coerce-arg accessibility-filename)))
(define (nswindow-set-accessibility-focused! self accessibility-focused)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityFocused:") accessibility-focused))
(define (nswindow-set-accessibility-focused-window! self accessibility-focused-window)
  (tell #:type _void (coerce-arg self) setAccessibilityFocusedWindow: (coerce-arg accessibility-focused-window)))
(define (nswindow-set-accessibility-frame! self accessibility-frame)
  (_msg-20 (coerce-arg self) (sel_registerName "setAccessibilityFrame:") accessibility-frame))
(define (nswindow-set-accessibility-frontmost! self accessibility-frontmost)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityFrontmost:") accessibility-frontmost))
(define (nswindow-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (tell #:type _void (coerce-arg self) setAccessibilityFullScreenButton: (coerce-arg accessibility-full-screen-button)))
(define (nswindow-set-accessibility-grow-area! self accessibility-grow-area)
  (tell #:type _void (coerce-arg self) setAccessibilityGrowArea: (coerce-arg accessibility-grow-area)))
(define (nswindow-set-accessibility-handles! self accessibility-handles)
  (tell #:type _void (coerce-arg self) setAccessibilityHandles: (coerce-arg accessibility-handles)))
(define (nswindow-set-accessibility-header! self accessibility-header)
  (tell #:type _void (coerce-arg self) setAccessibilityHeader: (coerce-arg accessibility-header)))
(define (nswindow-set-accessibility-help! self accessibility-help)
  (tell #:type _void (coerce-arg self) setAccessibilityHelp: (coerce-arg accessibility-help)))
(define (nswindow-set-accessibility-hidden! self accessibility-hidden)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityHidden:") accessibility-hidden))
(define (nswindow-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalScrollBar: (coerce-arg accessibility-horizontal-scroll-bar)))
(define (nswindow-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalUnitDescription: (coerce-arg accessibility-horizontal-unit-description)))
(define (nswindow-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityHorizontalUnits:") accessibility-horizontal-units))
(define (nswindow-set-accessibility-identifier! self accessibility-identifier)
  (tell #:type _void (coerce-arg self) setAccessibilityIdentifier: (coerce-arg accessibility-identifier)))
(define (nswindow-set-accessibility-increment-button! self accessibility-increment-button)
  (tell #:type _void (coerce-arg self) setAccessibilityIncrementButton: (coerce-arg accessibility-increment-button)))
(define (nswindow-set-accessibility-index! self accessibility-index)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityIndex:") accessibility-index))
(define (nswindow-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityInsertionPointLineNumber:") accessibility-insertion-point-line-number))
(define (nswindow-set-accessibility-label! self accessibility-label)
  (tell #:type _void (coerce-arg self) setAccessibilityLabel: (coerce-arg accessibility-label)))
(define (nswindow-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLabelUIElements: (coerce-arg accessibility-label-ui-elements)))
(define (nswindow-set-accessibility-label-value! self accessibility-label-value)
  (_msg-34 (coerce-arg self) (sel_registerName "setAccessibilityLabelValue:") accessibility-label-value))
(define (nswindow-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLinkedUIElements: (coerce-arg accessibility-linked-ui-elements)))
(define (nswindow-set-accessibility-main! self accessibility-main)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityMain:") accessibility-main))
(define (nswindow-set-accessibility-main-window! self accessibility-main-window)
  (tell #:type _void (coerce-arg self) setAccessibilityMainWindow: (coerce-arg accessibility-main-window)))
(define (nswindow-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerGroupUIElement: (coerce-arg accessibility-marker-group-ui-element)))
(define (nswindow-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerTypeDescription: (coerce-arg accessibility-marker-type-description)))
(define (nswindow-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerUIElements: (coerce-arg accessibility-marker-ui-elements)))
(define (nswindow-set-accessibility-marker-values! self accessibility-marker-values)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerValues: (coerce-arg accessibility-marker-values)))
(define (nswindow-set-accessibility-max-value! self accessibility-max-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMaxValue: (coerce-arg accessibility-max-value)))
(define (nswindow-set-accessibility-menu-bar! self accessibility-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityMenuBar: (coerce-arg accessibility-menu-bar)))
(define (nswindow-set-accessibility-min-value! self accessibility-min-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMinValue: (coerce-arg accessibility-min-value)))
(define (nswindow-set-accessibility-minimize-button! self accessibility-minimize-button)
  (tell #:type _void (coerce-arg self) setAccessibilityMinimizeButton: (coerce-arg accessibility-minimize-button)))
(define (nswindow-set-accessibility-minimized! self accessibility-minimized)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityMinimized:") accessibility-minimized))
(define (nswindow-set-accessibility-modal! self accessibility-modal)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityModal:") accessibility-modal))
(define (nswindow-set-accessibility-next-contents! self accessibility-next-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityNextContents: (coerce-arg accessibility-next-contents)))
(define (nswindow-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityNumberOfCharacters:") accessibility-number-of-characters))
(define (nswindow-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityOrderedByRow:") accessibility-ordered-by-row))
(define (nswindow-set-accessibility-orientation! self accessibility-orientation)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityOrientation:") accessibility-orientation))
(define (nswindow-set-accessibility-overflow-button! self accessibility-overflow-button)
  (tell #:type _void (coerce-arg self) setAccessibilityOverflowButton: (coerce-arg accessibility-overflow-button)))
(define (nswindow-set-accessibility-parent! self accessibility-parent)
  (tell #:type _void (coerce-arg self) setAccessibilityParent: (coerce-arg accessibility-parent)))
(define (nswindow-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (tell #:type _void (coerce-arg self) setAccessibilityPlaceholderValue: (coerce-arg accessibility-placeholder-value)))
(define (nswindow-set-accessibility-previous-contents! self accessibility-previous-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityPreviousContents: (coerce-arg accessibility-previous-contents)))
(define (nswindow-set-accessibility-protected-content! self accessibility-protected-content)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityProtectedContent:") accessibility-protected-content))
(define (nswindow-set-accessibility-proxy! self accessibility-proxy)
  (tell #:type _void (coerce-arg self) setAccessibilityProxy: (coerce-arg accessibility-proxy)))
(define (nswindow-set-accessibility-required! self accessibility-required)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityRequired:") accessibility-required))
(define (nswindow-set-accessibility-role! self accessibility-role)
  (tell #:type _void (coerce-arg self) setAccessibilityRole: (coerce-arg accessibility-role)))
(define (nswindow-set-accessibility-role-description! self accessibility-role-description)
  (tell #:type _void (coerce-arg self) setAccessibilityRoleDescription: (coerce-arg accessibility-role-description)))
(define (nswindow-set-accessibility-row-count! self accessibility-row-count)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityRowCount:") accessibility-row-count))
(define (nswindow-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityRowHeaderUIElements: (coerce-arg accessibility-row-header-ui-elements)))
(define (nswindow-set-accessibility-row-index-range! self accessibility-row-index-range)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityRowIndexRange:") accessibility-row-index-range))
(define (nswindow-set-accessibility-rows! self accessibility-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityRows: (coerce-arg accessibility-rows)))
(define (nswindow-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityRulerMarkerType:") accessibility-ruler-marker-type))
(define (nswindow-set-accessibility-search-button! self accessibility-search-button)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchButton: (coerce-arg accessibility-search-button)))
(define (nswindow-set-accessibility-search-menu! self accessibility-search-menu)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchMenu: (coerce-arg accessibility-search-menu)))
(define (nswindow-set-accessibility-selected! self accessibility-selected)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilitySelected:") accessibility-selected))
(define (nswindow-set-accessibility-selected-cells! self accessibility-selected-cells)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedCells: (coerce-arg accessibility-selected-cells)))
(define (nswindow-set-accessibility-selected-children! self accessibility-selected-children)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedChildren: (coerce-arg accessibility-selected-children)))
(define (nswindow-set-accessibility-selected-columns! self accessibility-selected-columns)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedColumns: (coerce-arg accessibility-selected-columns)))
(define (nswindow-set-accessibility-selected-rows! self accessibility-selected-rows)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedRows: (coerce-arg accessibility-selected-rows)))
(define (nswindow-set-accessibility-selected-text! self accessibility-selected-text)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedText: (coerce-arg accessibility-selected-text)))
(define (nswindow-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilitySelectedTextRange:") accessibility-selected-text-range))
(define (nswindow-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedTextRanges: (coerce-arg accessibility-selected-text-ranges)))
(define (nswindow-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityServesAsTitleForUIElements: (coerce-arg accessibility-serves-as-title-for-ui-elements)))
(define (nswindow-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilitySharedCharacterRange:") accessibility-shared-character-range))
(define (nswindow-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedFocusElements: (coerce-arg accessibility-shared-focus-elements)))
(define (nswindow-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedTextUIElements: (coerce-arg accessibility-shared-text-ui-elements)))
(define (nswindow-set-accessibility-shown-menu! self accessibility-shown-menu)
  (tell #:type _void (coerce-arg self) setAccessibilityShownMenu: (coerce-arg accessibility-shown-menu)))
(define (nswindow-set-accessibility-sort-direction! self accessibility-sort-direction)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilitySortDirection:") accessibility-sort-direction))
(define (nswindow-set-accessibility-splitters! self accessibility-splitters)
  (tell #:type _void (coerce-arg self) setAccessibilitySplitters: (coerce-arg accessibility-splitters)))
(define (nswindow-set-accessibility-subrole! self accessibility-subrole)
  (tell #:type _void (coerce-arg self) setAccessibilitySubrole: (coerce-arg accessibility-subrole)))
(define (nswindow-set-accessibility-tabs! self accessibility-tabs)
  (tell #:type _void (coerce-arg self) setAccessibilityTabs: (coerce-arg accessibility-tabs)))
(define (nswindow-set-accessibility-title! self accessibility-title)
  (tell #:type _void (coerce-arg self) setAccessibilityTitle: (coerce-arg accessibility-title)))
(define (nswindow-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTitleUIElement: (coerce-arg accessibility-title-ui-element)))
(define (nswindow-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (tell #:type _void (coerce-arg self) setAccessibilityToolbarButton: (coerce-arg accessibility-toolbar-button)))
(define (nswindow-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTopLevelUIElement: (coerce-arg accessibility-top-level-ui-element)))
(define (nswindow-set-accessibility-url! self accessibility-url)
  (tell #:type _void (coerce-arg self) setAccessibilityURL: (coerce-arg accessibility-url)))
(define (nswindow-set-accessibility-unit-description! self accessibility-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityUnitDescription: (coerce-arg accessibility-unit-description)))
(define (nswindow-set-accessibility-units! self accessibility-units)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityUnits:") accessibility-units))
(define (nswindow-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityUserInputLabels: (coerce-arg accessibility-user-input-labels)))
(define (nswindow-set-accessibility-value! self accessibility-value)
  (tell #:type _void (coerce-arg self) setAccessibilityValue: (coerce-arg accessibility-value)))
(define (nswindow-set-accessibility-value-description! self accessibility-value-description)
  (tell #:type _void (coerce-arg self) setAccessibilityValueDescription: (coerce-arg accessibility-value-description)))
(define (nswindow-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalScrollBar: (coerce-arg accessibility-vertical-scroll-bar)))
(define (nswindow-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalUnitDescription: (coerce-arg accessibility-vertical-unit-description)))
(define (nswindow-set-accessibility-vertical-units! self accessibility-vertical-units)
  (_msg-45 (coerce-arg self) (sel_registerName "setAccessibilityVerticalUnits:") accessibility-vertical-units))
(define (nswindow-set-accessibility-visible-cells! self accessibility-visible-cells)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleCells: (coerce-arg accessibility-visible-cells)))
(define (nswindow-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityVisibleCharacterRange:") accessibility-visible-character-range))
(define (nswindow-set-accessibility-visible-children! self accessibility-visible-children)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleChildren: (coerce-arg accessibility-visible-children)))
(define (nswindow-set-accessibility-visible-columns! self accessibility-visible-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleColumns: (coerce-arg accessibility-visible-columns)))
(define (nswindow-set-accessibility-visible-rows! self accessibility-visible-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleRows: (coerce-arg accessibility-visible-rows)))
(define (nswindow-set-accessibility-warning-value! self accessibility-warning-value)
  (tell #:type _void (coerce-arg self) setAccessibilityWarningValue: (coerce-arg accessibility-warning-value)))
(define (nswindow-set-accessibility-window! self accessibility-window)
  (tell #:type _void (coerce-arg self) setAccessibilityWindow: (coerce-arg accessibility-window)))
(define (nswindow-set-accessibility-windows! self accessibility-windows)
  (tell #:type _void (coerce-arg self) setAccessibilityWindows: (coerce-arg accessibility-windows)))
(define (nswindow-set-accessibility-zoom-button! self accessibility-zoom-button)
  (tell #:type _void (coerce-arg self) setAccessibilityZoomButton: (coerce-arg accessibility-zoom-button)))
(define (nswindow-set-animations! self animations)
  (tell #:type _void (coerce-arg self) setAnimations: (coerce-arg animations)))
(define (nswindow-set-appearance! self appearance)
  (tell #:type _void (coerce-arg self) setAppearance: (coerce-arg appearance)))
(define (nswindow-set-autorecalculates-content-border-thickness-for-edge! self flag edge)
  (_msg-31 (coerce-arg self) (sel_registerName "setAutorecalculatesContentBorderThickness:forEdge:") flag edge))
(define (nswindow-set-content-border-thickness-for-edge! self thickness edge)
  (_msg-33 (coerce-arg self) (sel_registerName "setContentBorderThickness:forEdge:") thickness edge))
(define (nswindow-set-content-size! self size)
  (_msg-28 (coerce-arg self) (sel_registerName "setContentSize:") size))
(define (nswindow-set-dynamic-depth-limit! self flag)
  (_msg-29 (coerce-arg self) (sel_registerName "setDynamicDepthLimit:") flag))
(define (nswindow-set-frame-display! self frame-rect flag)
  (_msg-21 (coerce-arg self) (sel_registerName "setFrame:display:") frame-rect flag))
(define (nswindow-set-frame-display-animate! self frame-rect display-flag animate-flag)
  (_msg-22 (coerce-arg self) (sel_registerName "setFrame:display:animate:") frame-rect display-flag animate-flag))
(define (nswindow-set-frame-autosave-name! self name)
  (_msg-35 (coerce-arg self) (sel_registerName "setFrameAutosaveName:") (coerce-arg name)))
(define (nswindow-set-frame-from-string! self string)
  (tell #:type _void (coerce-arg self) setFrameFromString: (coerce-arg string)))
(define (nswindow-set-frame-origin! self point)
  (_msg-12 (coerce-arg self) (sel_registerName "setFrameOrigin:") point))
(define (nswindow-set-frame-top-left-point! self point)
  (_msg-12 (coerce-arg self) (sel_registerName "setFrameTopLeftPoint:") point))
(define (nswindow-set-frame-using-name! self name)
  (_msg-35 (coerce-arg self) (sel_registerName "setFrameUsingName:") (coerce-arg name)))
(define (nswindow-set-frame-using-name-force! self name force)
  (_msg-36 (coerce-arg self) (sel_registerName "setFrameUsingName:force:") (coerce-arg name) force))
(define (nswindow-set-identifier! self identifier)
  (tell #:type _void (coerce-arg self) setIdentifier: (coerce-arg identifier)))
(define (nswindow-set-title-with-represented-filename! self filename)
  (tell #:type _void (coerce-arg self) setTitleWithRepresentedFilename: (coerce-arg filename)))
(define (nswindow-should-be-treated-as-ink-event self event)
  (_msg-35 (coerce-arg self) (sel_registerName "shouldBeTreatedAsInkEvent:") (coerce-arg event)))
(define (nswindow-show-context-help self sender)
  (tell #:type _void (coerce-arg self) showContextHelp: (coerce-arg sender)))
(define (nswindow-smart-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) smartMagnifyWithEvent: (coerce-arg event)))
(define (nswindow-standard-window-button self b)
  (wrap-objc-object
   (_msg-54 (coerce-arg self) (sel_registerName "standardWindowButton:") b)
   ))
(define (nswindow-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (_msg-51 (coerce-arg self) (sel_registerName "supplementalTargetForAction:sender:") (sel_registerName action) (coerce-arg sender))
   ))
(define (nswindow-swipe-with-event self event)
  (tell #:type _void (coerce-arg self) swipeWithEvent: (coerce-arg event)))
(define (nswindow-tablet-point self event)
  (tell #:type _void (coerce-arg self) tabletPoint: (coerce-arg event)))
(define (nswindow-tablet-proximity self event)
  (tell #:type _void (coerce-arg self) tabletProximity: (coerce-arg event)))
(define (nswindow-toggle-full-screen! self sender)
  (tell #:type _void (coerce-arg self) toggleFullScreen: (coerce-arg sender)))
(define (nswindow-toggle-tab-bar! self sender)
  (tell #:type _void (coerce-arg self) toggleTabBar: (coerce-arg sender)))
(define (nswindow-toggle-tab-overview! self sender)
  (tell #:type _void (coerce-arg self) toggleTabOverview: (coerce-arg sender)))
(define (nswindow-toggle-toolbar-shown! self sender)
  (tell #:type _void (coerce-arg self) toggleToolbarShown: (coerce-arg sender)))
(define (nswindow-touches-began-with-event self event)
  (tell #:type _void (coerce-arg self) touchesBeganWithEvent: (coerce-arg event)))
(define (nswindow-touches-cancelled-with-event self event)
  (tell #:type _void (coerce-arg self) touchesCancelledWithEvent: (coerce-arg event)))
(define (nswindow-touches-ended-with-event self event)
  (tell #:type _void (coerce-arg self) touchesEndedWithEvent: (coerce-arg event)))
(define (nswindow-touches-moved-with-event self event)
  (tell #:type _void (coerce-arg self) touchesMovedWithEvent: (coerce-arg event)))
(define (nswindow-transfer-window-sharing-to-window-completion-handler self window completion-handler)
  (define-values (_blk1 _blk1-id)
    (make-objc-block completion-handler (list _id) _void))
  (_msg-39 (coerce-arg self) (sel_registerName "transferWindowSharingToWindow:completionHandler:") (coerce-arg window) _blk1))
(define (nswindow-try-to-perform-with self action object)
  (_msg-50 (coerce-arg self) (sel_registerName "tryToPerform:with:") (sel_registerName action) (coerce-arg object)))
(define (nswindow-update self)
  (tell #:type _void (coerce-arg self) update))
(define (nswindow-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (tell (coerce-arg self) validRequestorForSendType: (coerce-arg send-type) returnType: (coerce-arg return-type))))
(define (nswindow-validate-menu-item self menu-item)
  (_msg-35 (coerce-arg self) (sel_registerName "validateMenuItem:") (coerce-arg menu-item)))
(define (nswindow-validate-user-interface-item self item)
  (_msg-35 (coerce-arg self) (sel_registerName "validateUserInterfaceItem:") (coerce-arg item)))
(define (nswindow-wants-forwarded-scroll-events-for-axis self axis)
  (_msg-43 (coerce-arg self) (sel_registerName "wantsForwardedScrollEventsForAxis:") axis))
(define (nswindow-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (_msg-43 (coerce-arg self) (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:") axis))
(define (nswindow-zoom self sender)
  (tell #:type _void (coerce-arg self) zoom: (coerce-arg sender)))

;; --- Class methods ---
(define (nswindow-content-rect-for-frame-rect-style-mask f-rect style)
  (_msg-24 NSWindow (sel_registerName "contentRectForFrameRect:styleMask:") f-rect style))
(define (nswindow-default-animation-for-key key)
  (wrap-objc-object
   (tell NSWindow defaultAnimationForKey: (coerce-arg key))))
(define (nswindow-frame-rect-for-content-rect-style-mask c-rect style)
  (_msg-24 NSWindow (sel_registerName "frameRectForContentRect:styleMask:") c-rect style))
(define (nswindow-min-frame-width-with-title-style-mask title style)
  (_msg-40 NSWindow (sel_registerName "minFrameWidthWithTitle:styleMask:") (coerce-arg title) style))
(define (nswindow-remove-frame-using-name! name)
  (tell #:type _void NSWindow removeFrameUsingName: (coerce-arg name)))
(define (nswindow-standard-window-button-for-style-mask b style-mask)
  (wrap-objc-object
   (_msg-56 NSWindow (sel_registerName "standardWindowButton:forStyleMask:") b style-mask)
   ))
(define (nswindow-window-number-at-point-below-window-with-window-number point window-number)
  (_msg-13 NSWindow (sel_registerName "windowNumberAtPoint:belowWindowWithWindowNumber:") point window-number))
(define (nswindow-window-numbers-with-options options)
  (wrap-objc-object
   (_msg-54 NSWindow (sel_registerName "windowNumbersWithOptions:") options)
   ))
(define (nswindow-window-with-content-view-controller content-view-controller)
  (wrap-objc-object
   (tell NSWindow windowWithContentViewController: (coerce-arg content-view-controller))))
