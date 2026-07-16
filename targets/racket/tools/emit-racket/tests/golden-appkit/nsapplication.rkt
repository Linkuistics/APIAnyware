#lang racket/base
;; Generated binding for NSApplication (AppKit)
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
(define (nsapplication? v) (objc-instance-of? v "NSApplication"))
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsattributedstring? v) (objc-instance-of? v "NSAttributedString"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsdocktile? v) (objc-instance-of? v "NSDockTile"))
(define (nserror? v) (objc-instance-of? v "NSError"))
(define (nsevent? v) (objc-instance-of? v "NSEvent"))
(define (nsgraphicscontext? v) (objc-instance-of? v "NSGraphicsContext"))
(define (nsimage? v) (objc-instance-of? v "NSImage"))
(define (nsmenu? v) (objc-instance-of? v "NSMenu"))
(define (nsresponder? v) (objc-instance-of? v "NSResponder"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (nstouchbar? v) (objc-instance-of? v "NSTouchBar"))
(define (nsurl? v) (objc-instance-of? v "NSURL"))
(define (nsundomanager? v) (objc-instance-of? v "NSUndoManager"))
(define (nsuseractivity? v) (objc-instance-of? v "NSUserActivity"))
(define (nswindow? v) (objc-instance-of? v "NSWindow"))
(provide NSApplication)
(provide/contract
  [make-nsapplication-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [nsapplication-accepts-first-responder (c-> nsapplication? boolean?)]
  [nsapplication-active (c-> nsapplication? boolean?)]
  [nsapplication-appearance (c-> nsapplication? (or/c nsappearance? objc-nil?))]
  [nsapplication-set-appearance! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-application-icon-image (c-> nsapplication? (or/c nsimage? objc-nil?))]
  [nsapplication-set-application-icon-image! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-application-should-suppress-high-dynamic-range-content (c-> nsapplication? boolean?)]
  [nsapplication-automatic-customize-touch-bar-menu-item-enabled (c-> nsapplication? boolean?)]
  [nsapplication-set-automatic-customize-touch-bar-menu-item-enabled! (c-> nsapplication? boolean? void?)]
  [nsapplication-context (c-> nsapplication? (or/c nsgraphicscontext? objc-nil?))]
  [nsapplication-current-event (c-> nsapplication? (or/c nsevent? objc-nil?))]
  [nsapplication-current-system-presentation-options (c-> nsapplication? exact-nonnegative-integer?)]
  [nsapplication-delegate (c-> nsapplication? any/c)]
  [nsapplication-set-delegate! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-dock-tile (c-> nsapplication? (or/c nsdocktile? objc-nil?))]
  [nsapplication-effective-appearance (c-> nsapplication? (or/c nsappearance? objc-nil?))]
  [nsapplication-enabled-remote-notification-types (c-> nsapplication? exact-nonnegative-integer?)]
  [nsapplication-full-keyboard-access-enabled (c-> nsapplication? boolean?)]
  [nsapplication-help-menu (c-> nsapplication? (or/c nsmenu? objc-nil?))]
  [nsapplication-set-help-menu! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-hidden (c-> nsapplication? boolean?)]
  [nsapplication-key-window (c-> nsapplication? (or/c nswindow? objc-nil?))]
  [nsapplication-main-menu (c-> nsapplication? (or/c nsmenu? objc-nil?))]
  [nsapplication-set-main-menu! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-main-window (c-> nsapplication? (or/c nswindow? objc-nil?))]
  [nsapplication-menu (c-> nsapplication? (or/c nsmenu? objc-nil?))]
  [nsapplication-set-menu! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-modal-window (c-> nsapplication? (or/c nswindow? objc-nil?))]
  [nsapplication-next-responder (c-> nsapplication? (or/c nsresponder? objc-nil?))]
  [nsapplication-set-next-responder! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-occlusion-state (c-> nsapplication? exact-nonnegative-integer?)]
  [nsapplication-ordered-documents (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-ordered-windows (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-presentation-options (c-> nsapplication? exact-nonnegative-integer?)]
  [nsapplication-set-presentation-options! (c-> nsapplication? exact-nonnegative-integer? void?)]
  [nsapplication-protected-data-available (c-> nsapplication? boolean?)]
  [nsapplication-registered-for-remote-notifications (c-> nsapplication? boolean?)]
  [nsapplication-restorable-state-key-paths (c-> (or/c nsarray? objc-nil?))]
  [nsapplication-running (c-> nsapplication? boolean?)]
  [nsapplication-services-menu (c-> nsapplication? (or/c nsmenu? objc-nil?))]
  [nsapplication-set-services-menu! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-services-provider (c-> nsapplication? any/c)]
  [nsapplication-set-services-provider! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-shared-application (c-> (or/c nsapplication? objc-nil?))]
  [nsapplication-touch-bar (c-> nsapplication? (or/c nstouchbar? objc-nil?))]
  [nsapplication-set-touch-bar! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-undo-manager (c-> nsapplication? (or/c nsundomanager? objc-nil?))]
  [nsapplication-user-activity (c-> nsapplication? (or/c nsuseractivity? objc-nil?))]
  [nsapplication-set-user-activity! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-user-interface-layout-direction (c-> nsapplication? exact-integer?)]
  [nsapplication-windows (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-windows-menu (c-> nsapplication? (or/c nsmenu? objc-nil?))]
  [nsapplication-set-windows-menu! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-abort-modal (c-> nsapplication? void?)]
  [nsapplication-accessibility-activation-point (c-> nsapplication? any/c)]
  [nsapplication-accessibility-allowed-values (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-application-focused-ui-element (c-> nsapplication? any/c)]
  [nsapplication-accessibility-attributed-string-for-range (c-> nsapplication? any/c (or/c nsattributedstring? objc-nil?))]
  [nsapplication-accessibility-attributed-user-input-labels (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-cancel-button (c-> nsapplication? any/c)]
  [nsapplication-accessibility-cell-for-column-row (c-> nsapplication? exact-integer? exact-integer? any/c)]
  [nsapplication-accessibility-children (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-children-in-navigation-order (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-clear-button (c-> nsapplication? any/c)]
  [nsapplication-accessibility-close-button (c-> nsapplication? any/c)]
  [nsapplication-accessibility-column-count (c-> nsapplication? exact-integer?)]
  [nsapplication-accessibility-column-header-ui-elements (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-column-index-range (c-> nsapplication? any/c)]
  [nsapplication-accessibility-column-titles (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-columns (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-contents (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-critical-value (c-> nsapplication? any/c)]
  [nsapplication-accessibility-custom-actions (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-custom-rotors (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-decrement-button (c-> nsapplication? any/c)]
  [nsapplication-accessibility-default-button (c-> nsapplication? any/c)]
  [nsapplication-accessibility-disclosed-by-row (c-> nsapplication? any/c)]
  [nsapplication-accessibility-disclosed-rows (c-> nsapplication? any/c)]
  [nsapplication-accessibility-disclosure-level (c-> nsapplication? exact-integer?)]
  [nsapplication-accessibility-document (c-> nsapplication? (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-extras-menu-bar (c-> nsapplication? any/c)]
  [nsapplication-accessibility-filename (c-> nsapplication? (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-focused-window (c-> nsapplication? any/c)]
  [nsapplication-accessibility-frame (c-> nsapplication? any/c)]
  [nsapplication-accessibility-frame-for-range (c-> nsapplication? any/c any/c)]
  [nsapplication-accessibility-full-screen-button (c-> nsapplication? any/c)]
  [nsapplication-accessibility-grow-area (c-> nsapplication? any/c)]
  [nsapplication-accessibility-handles (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-header (c-> nsapplication? any/c)]
  [nsapplication-accessibility-help (c-> nsapplication? (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-horizontal-scroll-bar (c-> nsapplication? any/c)]
  [nsapplication-accessibility-horizontal-unit-description (c-> nsapplication? (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-horizontal-units (c-> nsapplication? exact-integer?)]
  [nsapplication-accessibility-identifier (c-> nsapplication? (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-increment-button (c-> nsapplication? any/c)]
  [nsapplication-accessibility-index (c-> nsapplication? exact-integer?)]
  [nsapplication-accessibility-insertion-point-line-number (c-> nsapplication? exact-integer?)]
  [nsapplication-accessibility-label (c-> nsapplication? (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-label-ui-elements (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-label-value (c-> nsapplication? real?)]
  [nsapplication-accessibility-layout-point-for-screen-point (c-> nsapplication? any/c any/c)]
  [nsapplication-accessibility-layout-size-for-screen-size (c-> nsapplication? any/c any/c)]
  [nsapplication-accessibility-line-for-index (c-> nsapplication? exact-integer? exact-integer?)]
  [nsapplication-accessibility-linked-ui-elements (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-main-window (c-> nsapplication? any/c)]
  [nsapplication-accessibility-marker-group-ui-element (c-> nsapplication? any/c)]
  [nsapplication-accessibility-marker-type-description (c-> nsapplication? (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-marker-ui-elements (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-marker-values (c-> nsapplication? any/c)]
  [nsapplication-accessibility-max-value (c-> nsapplication? any/c)]
  [nsapplication-accessibility-menu-bar (c-> nsapplication? any/c)]
  [nsapplication-accessibility-min-value (c-> nsapplication? any/c)]
  [nsapplication-accessibility-minimize-button (c-> nsapplication? any/c)]
  [nsapplication-accessibility-next-contents (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-number-of-characters (c-> nsapplication? exact-integer?)]
  [nsapplication-accessibility-orientation (c-> nsapplication? exact-integer?)]
  [nsapplication-accessibility-overflow-button (c-> nsapplication? any/c)]
  [nsapplication-accessibility-parent (c-> nsapplication? any/c)]
  [nsapplication-accessibility-perform-cancel (c-> nsapplication? boolean?)]
  [nsapplication-accessibility-perform-confirm (c-> nsapplication? boolean?)]
  [nsapplication-accessibility-perform-decrement (c-> nsapplication? boolean?)]
  [nsapplication-accessibility-perform-delete (c-> nsapplication? boolean?)]
  [nsapplication-accessibility-perform-increment (c-> nsapplication? boolean?)]
  [nsapplication-accessibility-perform-pick (c-> nsapplication? boolean?)]
  [nsapplication-accessibility-perform-press (c-> nsapplication? boolean?)]
  [nsapplication-accessibility-perform-raise (c-> nsapplication? boolean?)]
  [nsapplication-accessibility-perform-show-alternate-ui (c-> nsapplication? boolean?)]
  [nsapplication-accessibility-perform-show-default-ui (c-> nsapplication? boolean?)]
  [nsapplication-accessibility-perform-show-menu (c-> nsapplication? boolean?)]
  [nsapplication-accessibility-placeholder-value (c-> nsapplication? (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-previous-contents (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-proxy (c-> nsapplication? any/c)]
  [nsapplication-accessibility-rtf-for-range (c-> nsapplication? any/c (or/c nsdata? objc-nil?))]
  [nsapplication-accessibility-range-for-index (c-> nsapplication? exact-integer? any/c)]
  [nsapplication-accessibility-range-for-line (c-> nsapplication? exact-integer? any/c)]
  [nsapplication-accessibility-range-for-position (c-> nsapplication? any/c any/c)]
  [nsapplication-accessibility-role (c-> nsapplication? (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-role-description (c-> nsapplication? (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-row-count (c-> nsapplication? exact-integer?)]
  [nsapplication-accessibility-row-header-ui-elements (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-row-index-range (c-> nsapplication? any/c)]
  [nsapplication-accessibility-rows (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-ruler-marker-type (c-> nsapplication? exact-integer?)]
  [nsapplication-accessibility-screen-point-for-layout-point (c-> nsapplication? any/c any/c)]
  [nsapplication-accessibility-screen-size-for-layout-size (c-> nsapplication? any/c any/c)]
  [nsapplication-accessibility-search-button (c-> nsapplication? any/c)]
  [nsapplication-accessibility-search-menu (c-> nsapplication? any/c)]
  [nsapplication-accessibility-selected-cells (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-selected-children (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-selected-columns (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-selected-rows (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-selected-text (c-> nsapplication? (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-selected-text-range (c-> nsapplication? any/c)]
  [nsapplication-accessibility-selected-text-ranges (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-serves-as-title-for-ui-elements (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-shared-character-range (c-> nsapplication? any/c)]
  [nsapplication-accessibility-shared-focus-elements (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-shared-text-ui-elements (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-shown-menu (c-> nsapplication? any/c)]
  [nsapplication-accessibility-sort-direction (c-> nsapplication? exact-integer?)]
  [nsapplication-accessibility-splitters (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-string-for-range (c-> nsapplication? any/c (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-style-range-for-index (c-> nsapplication? exact-integer? any/c)]
  [nsapplication-accessibility-subrole (c-> nsapplication? (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-tabs (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-title (c-> nsapplication? (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-title-ui-element (c-> nsapplication? any/c)]
  [nsapplication-accessibility-toolbar-button (c-> nsapplication? any/c)]
  [nsapplication-accessibility-top-level-ui-element (c-> nsapplication? any/c)]
  [nsapplication-accessibility-url (c-> nsapplication? (or/c nsurl? objc-nil?))]
  [nsapplication-accessibility-unit-description (c-> nsapplication? (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-units (c-> nsapplication? exact-integer?)]
  [nsapplication-accessibility-user-input-labels (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-value (c-> nsapplication? any/c)]
  [nsapplication-accessibility-value-description (c-> nsapplication? (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-vertical-scroll-bar (c-> nsapplication? any/c)]
  [nsapplication-accessibility-vertical-unit-description (c-> nsapplication? (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-vertical-units (c-> nsapplication? exact-integer?)]
  [nsapplication-accessibility-visible-cells (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-visible-character-range (c-> nsapplication? any/c)]
  [nsapplication-accessibility-visible-children (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-visible-columns (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-visible-rows (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-warning-value (c-> nsapplication? any/c)]
  [nsapplication-accessibility-window (c-> nsapplication? any/c)]
  [nsapplication-accessibility-windows (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-zoom-button (c-> nsapplication? any/c)]
  [nsapplication-activate (c-> nsapplication? void?)]
  [nsapplication-activate-context-help-mode (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-activate-ignoring-other-apps (c-> nsapplication? boolean? void?)]
  [nsapplication-activation-policy (c-> nsapplication? exact-integer?)]
  [nsapplication-add-windows-item-title-filename! (c-> nsapplication? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean? void?)]
  [nsapplication-arrange-in-front (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-become-first-responder (c-> nsapplication? boolean?)]
  [nsapplication-begin-gesture-with-event! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-begin-modal-session-for-window! (c-> nsapplication? (or/c string? objc-object? #f) (or/c cpointer? #f))]
  [nsapplication-cancel-operation (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-cancel-user-attention-request (c-> nsapplication? exact-integer? void?)]
  [nsapplication-capitalize-word (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-center-selection-in-visible-area! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-change-case-of-letter (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-change-mode-with-event (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-change-windows-item-title-filename (c-> nsapplication? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean? void?)]
  [nsapplication-complete (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-complete-state-restoration (c-> nsapplication? void?)]
  [nsapplication-context-menu-key-down (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-cursor-update (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-deactivate (c-> nsapplication? void?)]
  [nsapplication-delete-backward (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-delete-backward-by-decomposing-previous-character (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-delete-forward (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-delete-to-beginning-of-line (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-delete-to-beginning-of-paragraph (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-delete-to-end-of-line (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-delete-to-end-of-paragraph (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-delete-to-mark (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-delete-word-backward (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-delete-word-forward (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-disable-relaunch-on-login (c-> nsapplication? void?)]
  [nsapplication-discard-events-matching-mask-before-event (c-> nsapplication? exact-nonnegative-integer? (or/c string? objc-object? #f) void?)]
  [nsapplication-do-command-by-selector (c-> nsapplication? string? void?)]
  [nsapplication-enable-relaunch-on-login (c-> nsapplication? void?)]
  [nsapplication-encode-restorable-state-with-coder (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-encode-restorable-state-with-coder-background-queue (c-> nsapplication? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsapplication-encode-with-coder (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-end-gesture-with-event! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-end-modal-session! (c-> nsapplication? (or/c cpointer? #f) void?)]
  [nsapplication-enumerate-windows-with-options-using-block (c-> nsapplication? exact-integer? (or/c procedure? #f) void?)]
  [nsapplication-extend-state-restoration (c-> nsapplication? void?)]
  [nsapplication-finish-launching (c-> nsapplication? void?)]
  [nsapplication-flags-changed (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-flush-buffered-key-events (c-> nsapplication? void?)]
  [nsapplication-help-requested (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-hide (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-hide-other-applications (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-indent (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-insert-backtab! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-insert-container-break! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-insert-double-quote-ignoring-substitution! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-insert-line-break! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-insert-newline! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-insert-newline-ignoring-field-editor! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-insert-paragraph-separator! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-insert-single-quote-ignoring-substitution! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-insert-tab! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-insert-tab-ignoring-field-editor! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-insert-text! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-interpret-key-events (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-invalidate-restorable-state (c-> nsapplication? void?)]
  [nsapplication-is-accessibility-alternate-ui-visible (c-> nsapplication? boolean?)]
  [nsapplication-is-accessibility-disclosed (c-> nsapplication? boolean?)]
  [nsapplication-is-accessibility-edited (c-> nsapplication? boolean?)]
  [nsapplication-is-accessibility-element (c-> nsapplication? boolean?)]
  [nsapplication-is-accessibility-enabled (c-> nsapplication? boolean?)]
  [nsapplication-is-accessibility-expanded (c-> nsapplication? boolean?)]
  [nsapplication-is-accessibility-focused (c-> nsapplication? boolean?)]
  [nsapplication-is-accessibility-frontmost (c-> nsapplication? boolean?)]
  [nsapplication-is-accessibility-hidden (c-> nsapplication? boolean?)]
  [nsapplication-is-accessibility-main (c-> nsapplication? boolean?)]
  [nsapplication-is-accessibility-minimized (c-> nsapplication? boolean?)]
  [nsapplication-is-accessibility-modal (c-> nsapplication? boolean?)]
  [nsapplication-is-accessibility-ordered-by-row (c-> nsapplication? boolean?)]
  [nsapplication-is-accessibility-protected-content (c-> nsapplication? boolean?)]
  [nsapplication-is-accessibility-required (c-> nsapplication? boolean?)]
  [nsapplication-is-accessibility-selected (c-> nsapplication? boolean?)]
  [nsapplication-is-accessibility-selector-allowed (c-> nsapplication? string? boolean?)]
  [nsapplication-is-active (c-> nsapplication? boolean?)]
  [nsapplication-is-automatic-customize-touch-bar-menu-item-enabled (c-> nsapplication? boolean?)]
  [nsapplication-is-full-keyboard-access-enabled (c-> nsapplication? boolean?)]
  [nsapplication-is-hidden (c-> nsapplication? boolean?)]
  [nsapplication-is-protected-data-available (c-> nsapplication? boolean?)]
  [nsapplication-is-registered-for-remote-notifications (c-> nsapplication? boolean?)]
  [nsapplication-is-running (c-> nsapplication? boolean?)]
  [nsapplication-key-down (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-key-up (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-lowercase-word (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-magnify-with-event (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-make-base-writing-direction-left-to-right (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-make-base-writing-direction-natural (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-make-base-writing-direction-right-to-left (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-make-text-writing-direction-left-to-right (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-make-text-writing-direction-natural (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-make-text-writing-direction-right-to-left (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-make-touch-bar (c-> nsapplication? (or/c nstouchbar? objc-nil?))]
  [nsapplication-miniaturize-all (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-mouse-cancelled (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-mouse-down (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-mouse-dragged (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-mouse-entered (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-mouse-exited (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-mouse-moved (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-mouse-up (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-backward! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-backward-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-down! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-down-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-forward! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-forward-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-left! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-left-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-paragraph-backward-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-paragraph-forward-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-right! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-right-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-to-beginning-of-document! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-to-beginning-of-document-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-to-beginning-of-line! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-to-beginning-of-line-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-to-beginning-of-paragraph! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-to-beginning-of-paragraph-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-to-end-of-document! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-to-end-of-document-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-to-end-of-line! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-to-end-of-line-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-to-end-of-paragraph! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-to-end-of-paragraph-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-to-left-end-of-line! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-to-left-end-of-line-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-to-right-end-of-line! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-to-right-end-of-line-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-up! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-up-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-word-backward! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-word-backward-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-word-forward! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-word-forward-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-word-left! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-word-left-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-word-right! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-move-word-right-and-modify-selection! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-new-window-for-tab (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-next-event-matching-mask-until-date-in-mode-dequeue (c-> nsapplication? exact-nonnegative-integer? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean? (or/c nsevent? objc-nil?))]
  [nsapplication-no-responder-for (c-> nsapplication? string? void?)]
  [nsapplication-order-front-character-palette! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-order-front-color-panel! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-order-front-standard-about-panel! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-order-front-standard-about-panel-with-options! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-ordered-documents! (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-ordered-windows! (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-other-mouse-down (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-other-mouse-dragged (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-other-mouse-up (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-page-down (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-page-down-and-modify-selection (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-page-up (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-page-up-and-modify-selection (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-perform-key-equivalent! (c-> nsapplication? (or/c string? objc-object? #f) boolean?)]
  [nsapplication-perform-text-finder-action! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-post-event-at-start (c-> nsapplication? (or/c string? objc-object? #f) boolean? void?)]
  [nsapplication-present-error (c-> nsapplication? (or/c string? objc-object? #f) boolean?)]
  [nsapplication-present-error-modal-for-window-delegate-did-present-selector-context-info (c-> nsapplication? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) string? (or/c cpointer? #f) void?)]
  [nsapplication-pressure-change-with-event (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-prevent-window-ordering (c-> nsapplication? void?)]
  [nsapplication-quick-look-preview-items (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-quick-look-with-event (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-register-for-remote-notification-types (c-> nsapplication? exact-nonnegative-integer? void?)]
  [nsapplication-register-for-remote-notifications (c-> nsapplication? void?)]
  [nsapplication-register-services-menu-send-types-return-types (c-> nsapplication? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsapplication-register-user-interface-item-search-handler (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-remove-windows-item! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-reply-to-application-should-terminate (c-> nsapplication? boolean? void?)]
  [nsapplication-reply-to-open-or-print (c-> nsapplication? exact-nonnegative-integer? void?)]
  [nsapplication-report-exception (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-request-user-attention (c-> nsapplication? exact-nonnegative-integer? exact-integer?)]
  [nsapplication-resign-first-responder (c-> nsapplication? boolean?)]
  [nsapplication-restore-state-with-coder (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-restore-user-activity-state (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-restore-window-with-identifier-state-completion-handler (c-> nsapplication? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c procedure? #f) boolean?)]
  [nsapplication-right-mouse-down (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-right-mouse-dragged (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-right-mouse-up (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-rotate-with-event (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-run (c-> nsapplication? void?)]
  [nsapplication-run-modal-for-window (c-> nsapplication? (or/c string? objc-object? #f) exact-integer?)]
  [nsapplication-run-modal-session (c-> nsapplication? (or/c cpointer? #f) exact-integer?)]
  [nsapplication-run-page-layout (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-scroll-line-down (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-scroll-line-up (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-scroll-page-down (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-scroll-page-up (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-scroll-to-beginning-of-document (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-scroll-to-end-of-document (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-scroll-wheel (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-search-string-in-user-interface-item-string-search-range-found-range (c-> nsapplication? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c (or/c cpointer? #f) boolean?)]
  [nsapplication-select-all (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-select-line (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-select-paragraph (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-select-to-mark (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-select-word (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-send-action-to-from (c-> nsapplication? string? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nsapplication-send-event (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-activation-point! (c-> nsapplication? any/c void?)]
  [nsapplication-set-accessibility-allowed-values! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-alternate-ui-visible! (c-> nsapplication? boolean? void?)]
  [nsapplication-set-accessibility-application-focused-ui-element! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-attributed-user-input-labels! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-cancel-button! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-children! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-children-in-navigation-order! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-clear-button! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-close-button! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-column-count! (c-> nsapplication? exact-integer? void?)]
  [nsapplication-set-accessibility-column-header-ui-elements! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-column-index-range! (c-> nsapplication? any/c void?)]
  [nsapplication-set-accessibility-column-titles! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-columns! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-contents! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-critical-value! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-custom-actions! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-custom-rotors! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-decrement-button! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-default-button! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-disclosed! (c-> nsapplication? boolean? void?)]
  [nsapplication-set-accessibility-disclosed-by-row! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-disclosed-rows! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-disclosure-level! (c-> nsapplication? exact-integer? void?)]
  [nsapplication-set-accessibility-document! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-edited! (c-> nsapplication? boolean? void?)]
  [nsapplication-set-accessibility-element! (c-> nsapplication? boolean? void?)]
  [nsapplication-set-accessibility-enabled! (c-> nsapplication? boolean? void?)]
  [nsapplication-set-accessibility-expanded! (c-> nsapplication? boolean? void?)]
  [nsapplication-set-accessibility-extras-menu-bar! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-filename! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-focused! (c-> nsapplication? boolean? void?)]
  [nsapplication-set-accessibility-focused-window! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-frame! (c-> nsapplication? any/c void?)]
  [nsapplication-set-accessibility-frontmost! (c-> nsapplication? boolean? void?)]
  [nsapplication-set-accessibility-full-screen-button! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-grow-area! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-handles! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-header! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-help! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-hidden! (c-> nsapplication? boolean? void?)]
  [nsapplication-set-accessibility-horizontal-scroll-bar! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-horizontal-unit-description! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-horizontal-units! (c-> nsapplication? exact-integer? void?)]
  [nsapplication-set-accessibility-identifier! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-increment-button! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-index! (c-> nsapplication? exact-integer? void?)]
  [nsapplication-set-accessibility-insertion-point-line-number! (c-> nsapplication? exact-integer? void?)]
  [nsapplication-set-accessibility-label! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-label-ui-elements! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-label-value! (c-> nsapplication? real? void?)]
  [nsapplication-set-accessibility-linked-ui-elements! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-main! (c-> nsapplication? boolean? void?)]
  [nsapplication-set-accessibility-main-window! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-marker-group-ui-element! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-marker-type-description! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-marker-ui-elements! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-marker-values! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-max-value! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-menu-bar! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-min-value! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-minimize-button! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-minimized! (c-> nsapplication? boolean? void?)]
  [nsapplication-set-accessibility-modal! (c-> nsapplication? boolean? void?)]
  [nsapplication-set-accessibility-next-contents! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-number-of-characters! (c-> nsapplication? exact-integer? void?)]
  [nsapplication-set-accessibility-ordered-by-row! (c-> nsapplication? boolean? void?)]
  [nsapplication-set-accessibility-orientation! (c-> nsapplication? exact-integer? void?)]
  [nsapplication-set-accessibility-overflow-button! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-parent! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-placeholder-value! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-previous-contents! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-protected-content! (c-> nsapplication? boolean? void?)]
  [nsapplication-set-accessibility-proxy! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-required! (c-> nsapplication? boolean? void?)]
  [nsapplication-set-accessibility-role! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-role-description! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-row-count! (c-> nsapplication? exact-integer? void?)]
  [nsapplication-set-accessibility-row-header-ui-elements! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-row-index-range! (c-> nsapplication? any/c void?)]
  [nsapplication-set-accessibility-rows! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-ruler-marker-type! (c-> nsapplication? exact-integer? void?)]
  [nsapplication-set-accessibility-search-button! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-search-menu! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-selected! (c-> nsapplication? boolean? void?)]
  [nsapplication-set-accessibility-selected-cells! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-selected-children! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-selected-columns! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-selected-rows! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-selected-text! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-selected-text-range! (c-> nsapplication? any/c void?)]
  [nsapplication-set-accessibility-selected-text-ranges! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-serves-as-title-for-ui-elements! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-shared-character-range! (c-> nsapplication? any/c void?)]
  [nsapplication-set-accessibility-shared-focus-elements! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-shared-text-ui-elements! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-shown-menu! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-sort-direction! (c-> nsapplication? exact-integer? void?)]
  [nsapplication-set-accessibility-splitters! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-subrole! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-tabs! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-title! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-title-ui-element! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-toolbar-button! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-top-level-ui-element! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-url! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-unit-description! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-units! (c-> nsapplication? exact-integer? void?)]
  [nsapplication-set-accessibility-user-input-labels! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-value! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-value-description! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-vertical-scroll-bar! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-vertical-unit-description! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-vertical-units! (c-> nsapplication? exact-integer? void?)]
  [nsapplication-set-accessibility-visible-cells! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-visible-character-range! (c-> nsapplication? any/c void?)]
  [nsapplication-set-accessibility-visible-children! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-visible-columns! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-visible-rows! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-warning-value! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-window! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-windows! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-zoom-button! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-activation-policy! (c-> nsapplication? exact-integer? boolean?)]
  [nsapplication-set-mark! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-windows-need-update! (c-> nsapplication? boolean? void?)]
  [nsapplication-should-be-treated-as-ink-event (c-> nsapplication? (or/c string? objc-object? #f) boolean?)]
  [nsapplication-show-context-help (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-show-context-menu-for-selection (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-show-help (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-show-writing-tools (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-smart-magnify-with-event (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-stop (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-stop-modal (c-> nsapplication? void?)]
  [nsapplication-stop-modal-with-code (c-> nsapplication? exact-integer? void?)]
  [nsapplication-supplemental-target-for-action-sender (c-> nsapplication? string? (or/c string? objc-object? #f) any/c)]
  [nsapplication-swap-with-mark (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-swipe-with-event (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-tablet-point (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-tablet-proximity (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-target-for-action (c-> nsapplication? string? any/c)]
  [nsapplication-target-for-action-to-from (c-> nsapplication? string? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nsapplication-terminate (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-toggle-touch-bar-customization-palette! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-touches-began-with-event (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-touches-cancelled-with-event (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-touches-ended-with-event (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-touches-moved-with-event (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-transpose (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-transpose-words (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-try-to-perform-with (c-> nsapplication? string? (or/c string? objc-object? #f) boolean?)]
  [nsapplication-unhide (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-unhide-all-applications (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-unhide-without-activation (c-> nsapplication? void?)]
  [nsapplication-unregister-for-remote-notifications (c-> nsapplication? void?)]
  [nsapplication-unregister-user-interface-item-search-handler (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-update-user-activity-state (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-update-windows (c-> nsapplication? void?)]
  [nsapplication-update-windows-item (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-uppercase-word (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-valid-requestor-for-send-type-return-type (c-> nsapplication? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nsapplication-validate-menu-item (c-> nsapplication? (or/c string? objc-object? #f) boolean?)]
  [nsapplication-validate-proposed-first-responder-for-event (c-> nsapplication? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nsapplication-validate-user-interface-item (c-> nsapplication? (or/c string? objc-object? #f) boolean?)]
  [nsapplication-wants-forwarded-scroll-events-for-axis (c-> nsapplication? exact-integer? boolean?)]
  [nsapplication-wants-scroll-events-for-swipe-tracking-on-axis (c-> nsapplication? exact-integer? boolean?)]
  [nsapplication-will-present-error (c-> nsapplication? (or/c string? objc-object? #f) (or/c nserror? objc-nil?))]
  [nsapplication-window-with-window-number (c-> nsapplication? exact-integer? (or/c nswindow? objc-nil?))]
  [nsapplication-yank (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-yield-activation-to-application (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-yield-activation-to-application-with-bundle-identifier (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-allowed-classes-for-restorable-state-key-path (c-> (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  [nsapplication-detach-drawing-thread-to-target-with-object (c-> string? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  )

;; --- Class reference ---
(import-class NSApplication)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_q (-> ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_0_Q (-> ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_0_f (-> ptr_t ptr_t float_t))
(define-aw-msg aw_racket_msg_0_R (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_0_O (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_0_G (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_0_v (-> ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_b (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_P_q (-> ptr_t ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_b (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PPP_b (-> ptr_t ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PPP_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPPPP_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPb_v (-> ptr_t ptr_t ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_PPGP_b (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_Pb_v (-> ptr_t ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_b_v (-> ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_q_P (-> ptr_t ptr_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_q_b (-> ptr_t ptr_t int64_t bool_t))
(define-aw-msg aw_racket_msg_q_q (-> ptr_t ptr_t int64_t int64_t))
(define-aw-msg aw_racket_msg_q_G (-> ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_q_v (-> ptr_t ptr_t int64_t void_t))
(define-aw-msg aw_racket_msg_qP_v (-> ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_qq_P (-> ptr_t ptr_t int64_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_Q_q (-> ptr_t ptr_t uint64_t int64_t))
(define-aw-msg aw_racket_msg_Q_v (-> ptr_t ptr_t uint64_t void_t))
(define-aw-msg aw_racket_msg_QP_v (-> ptr_t ptr_t uint64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_QPPb_P (-> ptr_t ptr_t uint64_t ptr_t ptr_t bool_t ptr_t))
(define-aw-msg aw_racket_msg_f_v (-> ptr_t ptr_t float_t void_t))
(define-aw-msg aw_racket_msg_R_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_O_O (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_O_G (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_O_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_Z_Z (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_G_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_G_R (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_G_v (-> ptr_t ptr_t ptr_t void_t))

;; --- Constructors ---
(define (make-nsapplication-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSApplication alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))


;; --- Properties ---
(define (nsapplication-accepts-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsFirstResponder"))))
(define (nsapplication-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "active"))))
(define (nsapplication-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "appearance"))))))
(define (nsapplication-set-appearance! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAppearance:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsapplication-application-icon-image self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "applicationIconImage"))))))
(define (nsapplication-set-application-icon-image! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setApplicationIconImage:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsapplication-application-should-suppress-high-dynamic-range-content self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "applicationShouldSuppressHighDynamicRangeContent"))))
(define (nsapplication-automatic-customize-touch-bar-menu-item-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "automaticCustomizeTouchBarMenuItemEnabled"))))
(define (nsapplication-set-automatic-customize-touch-bar-menu-item-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutomaticCustomizeTouchBarMenuItemEnabled:")) value))
(define (nsapplication-context self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "context"))))))
(define (nsapplication-current-event self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "currentEvent"))))))
(define (nsapplication-current-system-presentation-options self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "currentSystemPresentationOptions"))))
(define (nsapplication-delegate self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "delegate"))))))
(define (nsapplication-set-delegate! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDelegate:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsapplication-dock-tile self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dockTile"))))))
(define (nsapplication-effective-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "effectiveAppearance"))))))
(define (nsapplication-enabled-remote-notification-types self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enabledRemoteNotificationTypes"))))
(define (nsapplication-full-keyboard-access-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "fullKeyboardAccessEnabled"))))
(define (nsapplication-help-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "helpMenu"))))))
(define (nsapplication-set-help-menu! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHelpMenu:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsapplication-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hidden"))))
(define (nsapplication-key-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyWindow"))))))
(define (nsapplication-main-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mainMenu"))))))
(define (nsapplication-set-main-menu! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMainMenu:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsapplication-main-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mainWindow"))))))
(define (nsapplication-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menu"))))))
(define (nsapplication-set-menu! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMenu:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsapplication-modal-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "modalWindow"))))))
(define (nsapplication-next-responder self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextResponder"))))))
(define (nsapplication-set-next-responder! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextResponder:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsapplication-occlusion-state self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "occlusionState"))))
(define (nsapplication-ordered-documents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orderedDocuments"))))))
(define (nsapplication-ordered-windows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orderedWindows"))))))
(define (nsapplication-presentation-options self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "presentationOptions"))))
(define (nsapplication-set-presentation-options! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPresentationOptions:")) value))
(define (nsapplication-protected-data-available self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "protectedDataAvailable"))))
(define (nsapplication-registered-for-remote-notifications self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "registeredForRemoteNotifications"))))
(define (nsapplication-restorable-state-key-paths)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSApplication) (id->ffi2-ptr (sel_registerName "restorableStateKeyPaths"))))))
(define (nsapplication-running self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "running"))))
(define (nsapplication-services-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "servicesMenu"))))))
(define (nsapplication-set-services-menu! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setServicesMenu:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsapplication-services-provider self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "servicesProvider"))))))
(define (nsapplication-set-services-provider! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setServicesProvider:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsapplication-shared-application)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSApplication) (id->ffi2-ptr (sel_registerName "sharedApplication"))))))
(define (nsapplication-touch-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchBar"))))))
(define (nsapplication-set-touch-bar! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTouchBar:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsapplication-undo-manager self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "undoManager"))))))
(define (nsapplication-user-activity self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userActivity"))))))
(define (nsapplication-set-user-activity! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserActivity:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsapplication-user-interface-layout-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userInterfaceLayoutDirection"))))
(define (nsapplication-windows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "windows"))))))
(define (nsapplication-windows-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "windowsMenu"))))))
(define (nsapplication-set-windows-menu! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWindowsMenu:")) (id->ffi2-ptr (coerce-arg value))))

;; --- Instance methods ---
(define (nsapplication-abort-modal self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "abortModal"))))
(define (nsapplication-accessibility-activation-point self)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_0_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityActivationPoint")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsapplication-accessibility-allowed-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAllowedValues"))))
   ))
(define (nsapplication-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityApplicationFocusedUIElement"))))
   ))
(define (nsapplication-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nsapplication-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedUserInputLabels"))))
   ))
(define (nsapplication-accessibility-cancel-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCancelButton"))))
   ))
(define (nsapplication-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_qq_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCellForColumn:row:")) column row))
   ))
(define (nsapplication-accessibility-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildren"))))
   ))
(define (nsapplication-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildrenInNavigationOrder"))))
   ))
(define (nsapplication-accessibility-clear-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityClearButton"))))
   ))
(define (nsapplication-accessibility-close-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCloseButton"))))
   ))
(define (nsapplication-accessibility-column-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnCount"))))
(define (nsapplication-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnHeaderUIElements"))))
   ))
(define (nsapplication-accessibility-column-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsapplication-accessibility-column-titles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnTitles"))))
   ))
(define (nsapplication-accessibility-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumns"))))
   ))
(define (nsapplication-accessibility-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityContents"))))
   ))
(define (nsapplication-accessibility-critical-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCriticalValue"))))
   ))
(define (nsapplication-accessibility-custom-actions self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomActions"))))
   ))
(define (nsapplication-accessibility-custom-rotors self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomRotors"))))
   ))
(define (nsapplication-accessibility-decrement-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDecrementButton"))))
   ))
(define (nsapplication-accessibility-default-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDefaultButton"))))
   ))
(define (nsapplication-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedByRow"))))
   ))
(define (nsapplication-accessibility-disclosed-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedRows"))))
   ))
(define (nsapplication-accessibility-disclosure-level self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosureLevel"))))
(define (nsapplication-accessibility-document self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDocument"))))
   ))
(define (nsapplication-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityExtrasMenuBar"))))
   ))
(define (nsapplication-accessibility-filename self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFilename"))))
   ))
(define (nsapplication-accessibility-focused-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFocusedWindow"))))
   ))
(define (nsapplication-accessibility-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsapplication-accessibility-frame-for-range self range)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_G_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrameForRange:")) (id->ffi2-ptr range) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsapplication-accessibility-full-screen-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFullScreenButton"))))
   ))
(define (nsapplication-accessibility-grow-area self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityGrowArea"))))
   ))
(define (nsapplication-accessibility-handles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHandles"))))
   ))
(define (nsapplication-accessibility-header self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHeader"))))
   ))
(define (nsapplication-accessibility-help self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHelp"))))
   ))
(define (nsapplication-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalScrollBar"))))
   ))
(define (nsapplication-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnitDescription"))))
   ))
(define (nsapplication-accessibility-horizontal-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnits"))))
(define (nsapplication-accessibility-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIdentifier"))))
   ))
(define (nsapplication-accessibility-increment-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIncrementButton"))))
   ))
(define (nsapplication-accessibility-index self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIndex"))))
(define (nsapplication-accessibility-insertion-point-line-number self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityInsertionPointLineNumber"))))
(define (nsapplication-accessibility-label self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabel"))))
   ))
(define (nsapplication-accessibility-label-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelUIElements"))))
   ))
(define (nsapplication-accessibility-label-value self)
  (aw_racket_msg_0_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelValue"))))
(define (nsapplication-accessibility-layout-point-for-screen-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutPointForScreenPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsapplication-accessibility-layout-size-for-screen-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutSizeForScreenSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsapplication-accessibility-line-for-index self index)
  (aw_racket_msg_q_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLineForIndex:")) index))
(define (nsapplication-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLinkedUIElements"))))
   ))
(define (nsapplication-accessibility-main-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMainWindow"))))
   ))
(define (nsapplication-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerGroupUIElement"))))
   ))
(define (nsapplication-accessibility-marker-type-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerTypeDescription"))))
   ))
(define (nsapplication-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerUIElements"))))
   ))
(define (nsapplication-accessibility-marker-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerValues"))))
   ))
(define (nsapplication-accessibility-max-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMaxValue"))))
   ))
(define (nsapplication-accessibility-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMenuBar"))))
   ))
(define (nsapplication-accessibility-min-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinValue"))))
   ))
(define (nsapplication-accessibility-minimize-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinimizeButton"))))
   ))
(define (nsapplication-accessibility-next-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNextContents"))))
   ))
(define (nsapplication-accessibility-number-of-characters self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNumberOfCharacters"))))
(define (nsapplication-accessibility-orientation self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOrientation"))))
(define (nsapplication-accessibility-overflow-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOverflowButton"))))
   ))
(define (nsapplication-accessibility-parent self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityParent"))))
   ))
(define (nsapplication-accessibility-perform-cancel self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformCancel"))))
(define (nsapplication-accessibility-perform-confirm self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformConfirm"))))
(define (nsapplication-accessibility-perform-decrement self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDecrement"))))
(define (nsapplication-accessibility-perform-delete self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDelete"))))
(define (nsapplication-accessibility-perform-increment self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformIncrement"))))
(define (nsapplication-accessibility-perform-pick self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPick"))))
(define (nsapplication-accessibility-perform-press self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPress"))))
(define (nsapplication-accessibility-perform-raise self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformRaise"))))
(define (nsapplication-accessibility-perform-show-alternate-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowAlternateUI"))))
(define (nsapplication-accessibility-perform-show-default-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowDefaultUI"))))
(define (nsapplication-accessibility-perform-show-menu self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowMenu"))))
(define (nsapplication-accessibility-placeholder-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPlaceholderValue"))))
   ))
(define (nsapplication-accessibility-previous-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPreviousContents"))))
   ))
(define (nsapplication-accessibility-proxy self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityProxy"))))
   ))
(define (nsapplication-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRTFForRange:")) (id->ffi2-ptr range)))
   ))
(define (nsapplication-accessibility-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsapplication-accessibility-range-for-line self line)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForLine:")) line (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsapplication-accessibility-range-for-position self point)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_O_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForPosition:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsapplication-accessibility-role self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRole"))))
   ))
(define (nsapplication-accessibility-role-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRoleDescription"))))
   ))
(define (nsapplication-accessibility-row-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowCount"))))
(define (nsapplication-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowHeaderUIElements"))))
   ))
(define (nsapplication-accessibility-row-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsapplication-accessibility-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRows"))))
   ))
(define (nsapplication-accessibility-ruler-marker-type self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRulerMarkerType"))))
(define (nsapplication-accessibility-screen-point-for-layout-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenPointForLayoutPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsapplication-accessibility-screen-size-for-layout-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenSizeForLayoutSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsapplication-accessibility-search-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchButton"))))
   ))
(define (nsapplication-accessibility-search-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchMenu"))))
   ))
(define (nsapplication-accessibility-selected-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedCells"))))
   ))
(define (nsapplication-accessibility-selected-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedChildren"))))
   ))
(define (nsapplication-accessibility-selected-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedColumns"))))
   ))
(define (nsapplication-accessibility-selected-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedRows"))))
   ))
(define (nsapplication-accessibility-selected-text self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedText"))))
   ))
(define (nsapplication-accessibility-selected-text-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsapplication-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRanges"))))
   ))
(define (nsapplication-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityServesAsTitleForUIElements"))))
   ))
(define (nsapplication-accessibility-shared-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsapplication-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedFocusElements"))))
   ))
(define (nsapplication-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedTextUIElements"))))
   ))
(define (nsapplication-accessibility-shown-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityShownMenu"))))
   ))
(define (nsapplication-accessibility-sort-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySortDirection"))))
(define (nsapplication-accessibility-splitters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySplitters"))))
   ))
(define (nsapplication-accessibility-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nsapplication-accessibility-style-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStyleRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsapplication-accessibility-subrole self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySubrole"))))
   ))
(define (nsapplication-accessibility-tabs self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTabs"))))
   ))
(define (nsapplication-accessibility-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitle"))))
   ))
(define (nsapplication-accessibility-title-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitleUIElement"))))
   ))
(define (nsapplication-accessibility-toolbar-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityToolbarButton"))))
   ))
(define (nsapplication-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTopLevelUIElement"))))
   ))
(define (nsapplication-accessibility-url self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityURL"))))
   ))
(define (nsapplication-accessibility-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnitDescription"))))
   ))
(define (nsapplication-accessibility-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnits"))))
(define (nsapplication-accessibility-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUserInputLabels"))))
   ))
(define (nsapplication-accessibility-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValue"))))
   ))
(define (nsapplication-accessibility-value-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValueDescription"))))
   ))
(define (nsapplication-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalScrollBar"))))
   ))
(define (nsapplication-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnitDescription"))))
   ))
(define (nsapplication-accessibility-vertical-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnits"))))
(define (nsapplication-accessibility-visible-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCells"))))
   ))
(define (nsapplication-accessibility-visible-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsapplication-accessibility-visible-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleChildren"))))
   ))
(define (nsapplication-accessibility-visible-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleColumns"))))
   ))
(define (nsapplication-accessibility-visible-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleRows"))))
   ))
(define (nsapplication-accessibility-warning-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWarningValue"))))
   ))
(define (nsapplication-accessibility-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindow"))))
   ))
(define (nsapplication-accessibility-windows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindows"))))
   ))
(define (nsapplication-accessibility-zoom-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityZoomButton"))))
   ))
(define (nsapplication-activate self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "activate"))))
(define (nsapplication-activate-context-help-mode self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "activateContextHelpMode:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-activate-ignoring-other-apps self ignore-other-apps)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "activateIgnoringOtherApps:")) ignore-other-apps))
(define (nsapplication-activation-policy self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "activationPolicy"))))
(define (nsapplication-add-windows-item-title-filename! self win string is-filename)
  (aw_racket_msg_PPb_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addWindowsItem:title:filename:")) (id->ffi2-ptr (coerce-arg win)) (id->ffi2-ptr (coerce-arg string)) is-filename))
(define (nsapplication-arrange-in-front self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "arrangeInFront:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-become-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "becomeFirstResponder"))))
(define (nsapplication-begin-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-begin-modal-session-for-window! self window)
  (ptr_t->cpointer (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginModalSessionForWindow:")) (id->ffi2-ptr (coerce-arg window)))))
(define (nsapplication-cancel-operation self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cancelOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-cancel-user-attention-request self request)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cancelUserAttentionRequest:")) request))
(define (nsapplication-capitalize-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "capitalizeWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-center-selection-in-visible-area! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerSelectionInVisibleArea:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-change-case-of-letter self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeCaseOfLetter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-change-mode-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeModeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-change-windows-item-title-filename self win string is-filename)
  (aw_racket_msg_PPb_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeWindowsItem:title:filename:")) (id->ffi2-ptr (coerce-arg win)) (id->ffi2-ptr (coerce-arg string)) is-filename))
(define (nsapplication-complete self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "complete:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-complete-state-restoration self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "completeStateRestoration"))))
(define (nsapplication-context-menu-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contextMenuKeyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-cursor-update self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cursorUpdate:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-deactivate self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deactivate"))))
(define (nsapplication-delete-backward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-delete-backward-by-decomposing-previous-character self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteBackwardByDecomposingPreviousCharacter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-delete-forward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-delete-to-beginning-of-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToBeginningOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-delete-to-beginning-of-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToBeginningOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-delete-to-end-of-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-delete-to-end-of-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToEndOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-delete-to-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-delete-word-backward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteWordBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-delete-word-forward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteWordForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-disable-relaunch-on-login self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "disableRelaunchOnLogin"))))
(define (nsapplication-discard-events-matching-mask-before-event self mask last-event)
  (aw_racket_msg_QP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "discardEventsMatchingMask:beforeEvent:")) mask (id->ffi2-ptr (coerce-arg last-event))))
(define (nsapplication-do-command-by-selector self selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "doCommandBySelector:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nsapplication-enable-relaunch-on-login self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enableRelaunchOnLogin"))))
(define (nsapplication-encode-restorable-state-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeRestorableStateWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nsapplication-encode-restorable-state-with-coder-background-queue self coder queue)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeRestorableStateWithCoder:backgroundQueue:")) (id->ffi2-ptr (coerce-arg coder)) (id->ffi2-ptr (coerce-arg queue))))
(define (nsapplication-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nsapplication-end-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-end-modal-session! self session)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endModalSession:")) (id->ffi2-ptr session)))
;; block param 1: synchronous (caller frees)
(define (nsapplication-enumerate-windows-with-options-using-block self options block)
  (define-values (_blk1 _blk1-id)
    (make-objc-block block (list _id _pointer) _void))
  (aw_racket_msg_qP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enumerateWindowsWithOptions:usingBlock:")) options (id->ffi2-ptr _blk1)))
(define (nsapplication-extend-state-restoration self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "extendStateRestoration"))))
(define (nsapplication-finish-launching self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "finishLaunching"))))
(define (nsapplication-flags-changed self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flagsChanged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-flush-buffered-key-events self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flushBufferedKeyEvents"))))
(define (nsapplication-help-requested self event-ptr)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "helpRequested:")) (id->ffi2-ptr (coerce-arg event-ptr))))
(define (nsapplication-hide self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hide:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-hide-other-applications self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hideOtherApplications:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-indent self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indent:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-insert-backtab! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertBacktab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-insert-container-break! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertContainerBreak:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-insert-double-quote-ignoring-substitution! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertDoubleQuoteIgnoringSubstitution:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-insert-line-break! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertLineBreak:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-insert-newline! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertNewline:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-insert-newline-ignoring-field-editor! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertNewlineIgnoringFieldEditor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-insert-paragraph-separator! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertParagraphSeparator:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-insert-single-quote-ignoring-substitution! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertSingleQuoteIgnoringSubstitution:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-insert-tab! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-insert-tab-ignoring-field-editor! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTabIgnoringFieldEditor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-insert-text! self insert-string)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertText:")) (id->ffi2-ptr (coerce-arg insert-string))))
(define (nsapplication-interpret-key-events self event-array)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "interpretKeyEvents:")) (id->ffi2-ptr (coerce-arg event-array))))
(define (nsapplication-invalidate-restorable-state self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "invalidateRestorableState"))))
(define (nsapplication-is-accessibility-alternate-ui-visible self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityAlternateUIVisible"))))
(define (nsapplication-is-accessibility-disclosed self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityDisclosed"))))
(define (nsapplication-is-accessibility-edited self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEdited"))))
(define (nsapplication-is-accessibility-element self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityElement"))))
(define (nsapplication-is-accessibility-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEnabled"))))
(define (nsapplication-is-accessibility-expanded self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityExpanded"))))
(define (nsapplication-is-accessibility-focused self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFocused"))))
(define (nsapplication-is-accessibility-frontmost self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFrontmost"))))
(define (nsapplication-is-accessibility-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityHidden"))))
(define (nsapplication-is-accessibility-main self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMain"))))
(define (nsapplication-is-accessibility-minimized self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMinimized"))))
(define (nsapplication-is-accessibility-modal self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityModal"))))
(define (nsapplication-is-accessibility-ordered-by-row self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityOrderedByRow"))))
(define (nsapplication-is-accessibility-protected-content self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityProtectedContent"))))
(define (nsapplication-is-accessibility-required self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityRequired"))))
(define (nsapplication-is-accessibility-selected self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelected"))))
(define (nsapplication-is-accessibility-selector-allowed self selector)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelectorAllowed:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nsapplication-is-active self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isActive"))))
(define (nsapplication-is-automatic-customize-touch-bar-menu-item-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAutomaticCustomizeTouchBarMenuItemEnabled"))))
(define (nsapplication-is-full-keyboard-access-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isFullKeyboardAccessEnabled"))))
(define (nsapplication-is-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHidden"))))
(define (nsapplication-is-protected-data-available self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isProtectedDataAvailable"))))
(define (nsapplication-is-registered-for-remote-notifications self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRegisteredForRemoteNotifications"))))
(define (nsapplication-is-running self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isRunning"))))
(define (nsapplication-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-key-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-lowercase-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lowercaseWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "magnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-make-base-writing-direction-left-to-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionLeftToRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-make-base-writing-direction-natural self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionNatural:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-make-base-writing-direction-right-to-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionRightToLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-make-text-writing-direction-left-to-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionLeftToRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-make-text-writing-direction-natural self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionNatural:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-make-text-writing-direction-right-to-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionRightToLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-make-touch-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTouchBar"))))
   ))
(define (nsapplication-miniaturize-all self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "miniaturizeAll:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-mouse-cancelled self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseCancelled:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-mouse-entered self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseEntered:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-mouse-exited self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseExited:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-mouse-moved self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseMoved:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-move-backward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-down! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-down-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveDownAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-forward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-left! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-left-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveLeftAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-paragraph-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveParagraphBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-paragraph-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveParagraphForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-right! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-right-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRightAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-to-beginning-of-document! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-to-beginning-of-document-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfDocumentAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-to-beginning-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-to-beginning-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-to-beginning-of-paragraph! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfParagraphAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-to-end-of-document! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-to-end-of-document-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfDocumentAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-to-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-to-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-to-end-of-paragraph! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-to-end-of-paragraph-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfParagraphAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-to-left-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToLeftEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-to-left-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToLeftEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-to-right-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToRightEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-to-right-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToRightEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-up! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-up-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveUpAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-word-backward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-word-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-word-forward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-word-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-word-left! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-word-left-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordLeftAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-word-right! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-move-word-right-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordRightAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-new-window-for-tab self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "newWindowForTab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-next-event-matching-mask-until-date-in-mode-dequeue self mask expiration mode deq-flag)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_QPPb_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextEventMatchingMask:untilDate:inMode:dequeue:")) mask (id->ffi2-ptr (coerce-arg expiration)) (id->ffi2-ptr (coerce-arg mode)) deq-flag))
   ))
(define (nsapplication-no-responder-for self event-selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "noResponderFor:")) (id->ffi2-ptr (sel_registerName event-selector))))
(define (nsapplication-order-front-character-palette! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orderFrontCharacterPalette:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-order-front-color-panel! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orderFrontColorPanel:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-order-front-standard-about-panel! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orderFrontStandardAboutPanel:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-order-front-standard-about-panel-with-options! self options-dictionary)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orderFrontStandardAboutPanelWithOptions:")) (id->ffi2-ptr (coerce-arg options-dictionary))))
(define (nsapplication-ordered-documents! self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orderedDocuments"))))
   ))
(define (nsapplication-ordered-windows! self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "orderedWindows"))))
   ))
(define (nsapplication-other-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-other-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-other-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-page-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-page-down-and-modify-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageDownAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-page-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-page-up-and-modify-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageUpAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-perform-key-equivalent! self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performKeyEquivalent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-perform-text-finder-action! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performTextFinderAction:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-post-event-at-start self event at-start)
  (aw_racket_msg_Pb_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "postEvent:atStart:")) (id->ffi2-ptr (coerce-arg event)) at-start))
(define (nsapplication-present-error self error)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "presentError:")) (id->ffi2-ptr (coerce-arg error))))
;; param 2: weak reference
(define (nsapplication-present-error-modal-for-window-delegate-did-present-selector-context-info self error window delegate did-present-selector context-info)
  (aw_racket_msg_PPPPP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "presentError:modalForWindow:delegate:didPresentSelector:contextInfo:")) (id->ffi2-ptr (coerce-arg error)) (id->ffi2-ptr (coerce-arg window)) (id->ffi2-ptr (coerce-arg delegate)) (id->ffi2-ptr (sel_registerName did-present-selector)) (id->ffi2-ptr context-info)))
(define (nsapplication-pressure-change-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pressureChangeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-prevent-window-ordering self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "preventWindowOrdering"))))
(define (nsapplication-quick-look-preview-items self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookPreviewItems:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-quick-look-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-register-for-remote-notification-types self types)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "registerForRemoteNotificationTypes:")) types))
(define (nsapplication-register-for-remote-notifications self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "registerForRemoteNotifications"))))
(define (nsapplication-register-services-menu-send-types-return-types self send-types return-types)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "registerServicesMenuSendTypes:returnTypes:")) (id->ffi2-ptr (coerce-arg send-types)) (id->ffi2-ptr (coerce-arg return-types))))
(define (nsapplication-register-user-interface-item-search-handler self handler)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "registerUserInterfaceItemSearchHandler:")) (id->ffi2-ptr (coerce-arg handler))))
(define (nsapplication-remove-windows-item! self win)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeWindowsItem:")) (id->ffi2-ptr (coerce-arg win))))
(define (nsapplication-reply-to-application-should-terminate self should-terminate)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "replyToApplicationShouldTerminate:")) should-terminate))
(define (nsapplication-reply-to-open-or-print self reply)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "replyToOpenOrPrint:")) reply))
(define (nsapplication-report-exception self exception)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "reportException:")) (id->ffi2-ptr (coerce-arg exception))))
(define (nsapplication-request-user-attention self request-type)
  (aw_racket_msg_Q_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "requestUserAttention:")) request-type))
(define (nsapplication-resign-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resignFirstResponder"))))
(define (nsapplication-restore-state-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "restoreStateWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nsapplication-restore-user-activity-state self user-activity)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "restoreUserActivityState:")) (id->ffi2-ptr (coerce-arg user-activity))))
;; block param 2: async-copied (runtime-managed)
(define (nsapplication-restore-window-with-identifier-state-completion-handler self identifier state completion-handler)
  (define-values (_blk2 _blk2-id)
    (make-objc-block completion-handler (list _id _id) _void))
  (aw_racket_msg_PPP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "restoreWindowWithIdentifier:state:completionHandler:")) (id->ffi2-ptr (coerce-arg identifier)) (id->ffi2-ptr (coerce-arg state)) (id->ffi2-ptr _blk2)))
(define (nsapplication-right-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-right-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-right-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-rotate-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotateWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-run self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "run"))))
(define (nsapplication-run-modal-for-window self window)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "runModalForWindow:")) (id->ffi2-ptr (coerce-arg window))))
(define (nsapplication-run-modal-session self session)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "runModalSession:")) (id->ffi2-ptr session)))
(define (nsapplication-run-page-layout self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "runPageLayout:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-scroll-line-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollLineDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-scroll-line-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollLineUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-scroll-page-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPageDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-scroll-page-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPageUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-scroll-to-beginning-of-document self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollToBeginningOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-scroll-to-end-of-document self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollToEndOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-scroll-wheel self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollWheel:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-search-string-in-user-interface-item-string-search-range-found-range self search-string string-to-search search-range found-range)
  (aw_racket_msg_PPGP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "searchString:inUserInterfaceItemString:searchRange:foundRange:")) (id->ffi2-ptr (coerce-arg search-string)) (id->ffi2-ptr (coerce-arg string-to-search)) (id->ffi2-ptr search-range) (id->ffi2-ptr found-range)))
(define (nsapplication-select-all self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectAll:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-select-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-select-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-select-to-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectToMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-select-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-send-action-to-from self action target sender)
  (aw_racket_msg_PPP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sendAction:to:from:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg target)) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-send-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sendEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-set-accessibility-activation-point! self accessibility-activation-point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityActivationPoint:")) (id->ffi2-ptr accessibility-activation-point)))
(define (nsapplication-set-accessibility-allowed-values! self accessibility-allowed-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAllowedValues:")) (id->ffi2-ptr (coerce-arg accessibility-allowed-values))))
(define (nsapplication-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAlternateUIVisible:")) accessibility-alternate-ui-visible))
(define (nsapplication-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityApplicationFocusedUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-application-focused-ui-element))))
(define (nsapplication-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAttributedUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-attributed-user-input-labels))))
(define (nsapplication-set-accessibility-cancel-button! self accessibility-cancel-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCancelButton:")) (id->ffi2-ptr (coerce-arg accessibility-cancel-button))))
(define (nsapplication-set-accessibility-children! self accessibility-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildren:")) (id->ffi2-ptr (coerce-arg accessibility-children))))
(define (nsapplication-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildrenInNavigationOrder:")) (id->ffi2-ptr (coerce-arg accessibility-children-in-navigation-order))))
(define (nsapplication-set-accessibility-clear-button! self accessibility-clear-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityClearButton:")) (id->ffi2-ptr (coerce-arg accessibility-clear-button))))
(define (nsapplication-set-accessibility-close-button! self accessibility-close-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCloseButton:")) (id->ffi2-ptr (coerce-arg accessibility-close-button))))
(define (nsapplication-set-accessibility-column-count! self accessibility-column-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnCount:")) accessibility-column-count))
(define (nsapplication-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-column-header-ui-elements))))
(define (nsapplication-set-accessibility-column-index-range! self accessibility-column-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnIndexRange:")) (id->ffi2-ptr accessibility-column-index-range)))
(define (nsapplication-set-accessibility-column-titles! self accessibility-column-titles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnTitles:")) (id->ffi2-ptr (coerce-arg accessibility-column-titles))))
(define (nsapplication-set-accessibility-columns! self accessibility-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumns:")) (id->ffi2-ptr (coerce-arg accessibility-columns))))
(define (nsapplication-set-accessibility-contents! self accessibility-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityContents:")) (id->ffi2-ptr (coerce-arg accessibility-contents))))
(define (nsapplication-set-accessibility-critical-value! self accessibility-critical-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCriticalValue:")) (id->ffi2-ptr (coerce-arg accessibility-critical-value))))
(define (nsapplication-set-accessibility-custom-actions! self accessibility-custom-actions)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomActions:")) (id->ffi2-ptr (coerce-arg accessibility-custom-actions))))
(define (nsapplication-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomRotors:")) (id->ffi2-ptr (coerce-arg accessibility-custom-rotors))))
(define (nsapplication-set-accessibility-decrement-button! self accessibility-decrement-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDecrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-decrement-button))))
(define (nsapplication-set-accessibility-default-button! self accessibility-default-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDefaultButton:")) (id->ffi2-ptr (coerce-arg accessibility-default-button))))
(define (nsapplication-set-accessibility-disclosed! self accessibility-disclosed)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosed:")) accessibility-disclosed))
(define (nsapplication-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedByRow:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-by-row))))
(define (nsapplication-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedRows:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-rows))))
(define (nsapplication-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosureLevel:")) accessibility-disclosure-level))
(define (nsapplication-set-accessibility-document! self accessibility-document)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDocument:")) (id->ffi2-ptr (coerce-arg accessibility-document))))
(define (nsapplication-set-accessibility-edited! self accessibility-edited)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEdited:")) accessibility-edited))
(define (nsapplication-set-accessibility-element! self accessibility-element)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityElement:")) accessibility-element))
(define (nsapplication-set-accessibility-enabled! self accessibility-enabled)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEnabled:")) accessibility-enabled))
(define (nsapplication-set-accessibility-expanded! self accessibility-expanded)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExpanded:")) accessibility-expanded))
(define (nsapplication-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExtrasMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-extras-menu-bar))))
(define (nsapplication-set-accessibility-filename! self accessibility-filename)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFilename:")) (id->ffi2-ptr (coerce-arg accessibility-filename))))
(define (nsapplication-set-accessibility-focused! self accessibility-focused)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocused:")) accessibility-focused))
(define (nsapplication-set-accessibility-focused-window! self accessibility-focused-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocusedWindow:")) (id->ffi2-ptr (coerce-arg accessibility-focused-window))))
(define (nsapplication-set-accessibility-frame! self accessibility-frame)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrame:")) (id->ffi2-ptr accessibility-frame)))
(define (nsapplication-set-accessibility-frontmost! self accessibility-frontmost)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrontmost:")) accessibility-frontmost))
(define (nsapplication-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFullScreenButton:")) (id->ffi2-ptr (coerce-arg accessibility-full-screen-button))))
(define (nsapplication-set-accessibility-grow-area! self accessibility-grow-area)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityGrowArea:")) (id->ffi2-ptr (coerce-arg accessibility-grow-area))))
(define (nsapplication-set-accessibility-handles! self accessibility-handles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHandles:")) (id->ffi2-ptr (coerce-arg accessibility-handles))))
(define (nsapplication-set-accessibility-header! self accessibility-header)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHeader:")) (id->ffi2-ptr (coerce-arg accessibility-header))))
(define (nsapplication-set-accessibility-help! self accessibility-help)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHelp:")) (id->ffi2-ptr (coerce-arg accessibility-help))))
(define (nsapplication-set-accessibility-hidden! self accessibility-hidden)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHidden:")) accessibility-hidden))
(define (nsapplication-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-scroll-bar))))
(define (nsapplication-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-unit-description))))
(define (nsapplication-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnits:")) accessibility-horizontal-units))
(define (nsapplication-set-accessibility-identifier! self accessibility-identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIdentifier:")) (id->ffi2-ptr (coerce-arg accessibility-identifier))))
(define (nsapplication-set-accessibility-increment-button! self accessibility-increment-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIncrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-increment-button))))
(define (nsapplication-set-accessibility-index! self accessibility-index)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIndex:")) accessibility-index))
(define (nsapplication-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityInsertionPointLineNumber:")) accessibility-insertion-point-line-number))
(define (nsapplication-set-accessibility-label! self accessibility-label)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabel:")) (id->ffi2-ptr (coerce-arg accessibility-label))))
(define (nsapplication-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-label-ui-elements))))
(define (nsapplication-set-accessibility-label-value! self accessibility-label-value)
  (aw_racket_msg_f_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelValue:")) accessibility-label-value))
(define (nsapplication-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLinkedUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-linked-ui-elements))))
(define (nsapplication-set-accessibility-main! self accessibility-main)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMain:")) accessibility-main))
(define (nsapplication-set-accessibility-main-window! self accessibility-main-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMainWindow:")) (id->ffi2-ptr (coerce-arg accessibility-main-window))))
(define (nsapplication-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerGroupUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-marker-group-ui-element))))
(define (nsapplication-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerTypeDescription:")) (id->ffi2-ptr (coerce-arg accessibility-marker-type-description))))
(define (nsapplication-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-marker-ui-elements))))
(define (nsapplication-set-accessibility-marker-values! self accessibility-marker-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerValues:")) (id->ffi2-ptr (coerce-arg accessibility-marker-values))))
(define (nsapplication-set-accessibility-max-value! self accessibility-max-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMaxValue:")) (id->ffi2-ptr (coerce-arg accessibility-max-value))))
(define (nsapplication-set-accessibility-menu-bar! self accessibility-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-menu-bar))))
(define (nsapplication-set-accessibility-min-value! self accessibility-min-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinValue:")) (id->ffi2-ptr (coerce-arg accessibility-min-value))))
(define (nsapplication-set-accessibility-minimize-button! self accessibility-minimize-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimizeButton:")) (id->ffi2-ptr (coerce-arg accessibility-minimize-button))))
(define (nsapplication-set-accessibility-minimized! self accessibility-minimized)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimized:")) accessibility-minimized))
(define (nsapplication-set-accessibility-modal! self accessibility-modal)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityModal:")) accessibility-modal))
(define (nsapplication-set-accessibility-next-contents! self accessibility-next-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNextContents:")) (id->ffi2-ptr (coerce-arg accessibility-next-contents))))
(define (nsapplication-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNumberOfCharacters:")) accessibility-number-of-characters))
(define (nsapplication-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrderedByRow:")) accessibility-ordered-by-row))
(define (nsapplication-set-accessibility-orientation! self accessibility-orientation)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrientation:")) accessibility-orientation))
(define (nsapplication-set-accessibility-overflow-button! self accessibility-overflow-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOverflowButton:")) (id->ffi2-ptr (coerce-arg accessibility-overflow-button))))
(define (nsapplication-set-accessibility-parent! self accessibility-parent)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityParent:")) (id->ffi2-ptr (coerce-arg accessibility-parent))))
(define (nsapplication-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPlaceholderValue:")) (id->ffi2-ptr (coerce-arg accessibility-placeholder-value))))
(define (nsapplication-set-accessibility-previous-contents! self accessibility-previous-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPreviousContents:")) (id->ffi2-ptr (coerce-arg accessibility-previous-contents))))
(define (nsapplication-set-accessibility-protected-content! self accessibility-protected-content)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProtectedContent:")) accessibility-protected-content))
(define (nsapplication-set-accessibility-proxy! self accessibility-proxy)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProxy:")) (id->ffi2-ptr (coerce-arg accessibility-proxy))))
(define (nsapplication-set-accessibility-required! self accessibility-required)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRequired:")) accessibility-required))
(define (nsapplication-set-accessibility-role! self accessibility-role)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRole:")) (id->ffi2-ptr (coerce-arg accessibility-role))))
(define (nsapplication-set-accessibility-role-description! self accessibility-role-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRoleDescription:")) (id->ffi2-ptr (coerce-arg accessibility-role-description))))
(define (nsapplication-set-accessibility-row-count! self accessibility-row-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowCount:")) accessibility-row-count))
(define (nsapplication-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-row-header-ui-elements))))
(define (nsapplication-set-accessibility-row-index-range! self accessibility-row-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowIndexRange:")) (id->ffi2-ptr accessibility-row-index-range)))
(define (nsapplication-set-accessibility-rows! self accessibility-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRows:")) (id->ffi2-ptr (coerce-arg accessibility-rows))))
(define (nsapplication-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRulerMarkerType:")) accessibility-ruler-marker-type))
(define (nsapplication-set-accessibility-search-button! self accessibility-search-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchButton:")) (id->ffi2-ptr (coerce-arg accessibility-search-button))))
(define (nsapplication-set-accessibility-search-menu! self accessibility-search-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchMenu:")) (id->ffi2-ptr (coerce-arg accessibility-search-menu))))
(define (nsapplication-set-accessibility-selected! self accessibility-selected)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelected:")) accessibility-selected))
(define (nsapplication-set-accessibility-selected-cells! self accessibility-selected-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedCells:")) (id->ffi2-ptr (coerce-arg accessibility-selected-cells))))
(define (nsapplication-set-accessibility-selected-children! self accessibility-selected-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedChildren:")) (id->ffi2-ptr (coerce-arg accessibility-selected-children))))
(define (nsapplication-set-accessibility-selected-columns! self accessibility-selected-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedColumns:")) (id->ffi2-ptr (coerce-arg accessibility-selected-columns))))
(define (nsapplication-set-accessibility-selected-rows! self accessibility-selected-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedRows:")) (id->ffi2-ptr (coerce-arg accessibility-selected-rows))))
(define (nsapplication-set-accessibility-selected-text! self accessibility-selected-text)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedText:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text))))
(define (nsapplication-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRange:")) (id->ffi2-ptr accessibility-selected-text-range)))
(define (nsapplication-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRanges:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text-ranges))))
(define (nsapplication-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityServesAsTitleForUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-serves-as-title-for-ui-elements))))
(define (nsapplication-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedCharacterRange:")) (id->ffi2-ptr accessibility-shared-character-range)))
(define (nsapplication-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedFocusElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-focus-elements))))
(define (nsapplication-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedTextUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-text-ui-elements))))
(define (nsapplication-set-accessibility-shown-menu! self accessibility-shown-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityShownMenu:")) (id->ffi2-ptr (coerce-arg accessibility-shown-menu))))
(define (nsapplication-set-accessibility-sort-direction! self accessibility-sort-direction)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySortDirection:")) accessibility-sort-direction))
(define (nsapplication-set-accessibility-splitters! self accessibility-splitters)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySplitters:")) (id->ffi2-ptr (coerce-arg accessibility-splitters))))
(define (nsapplication-set-accessibility-subrole! self accessibility-subrole)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySubrole:")) (id->ffi2-ptr (coerce-arg accessibility-subrole))))
(define (nsapplication-set-accessibility-tabs! self accessibility-tabs)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTabs:")) (id->ffi2-ptr (coerce-arg accessibility-tabs))))
(define (nsapplication-set-accessibility-title! self accessibility-title)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitle:")) (id->ffi2-ptr (coerce-arg accessibility-title))))
(define (nsapplication-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitleUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-title-ui-element))))
(define (nsapplication-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityToolbarButton:")) (id->ffi2-ptr (coerce-arg accessibility-toolbar-button))))
(define (nsapplication-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTopLevelUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-top-level-ui-element))))
(define (nsapplication-set-accessibility-url! self accessibility-url)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityURL:")) (id->ffi2-ptr (coerce-arg accessibility-url))))
(define (nsapplication-set-accessibility-unit-description! self accessibility-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-unit-description))))
(define (nsapplication-set-accessibility-units! self accessibility-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnits:")) accessibility-units))
(define (nsapplication-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-user-input-labels))))
(define (nsapplication-set-accessibility-value! self accessibility-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValue:")) (id->ffi2-ptr (coerce-arg accessibility-value))))
(define (nsapplication-set-accessibility-value-description! self accessibility-value-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValueDescription:")) (id->ffi2-ptr (coerce-arg accessibility-value-description))))
(define (nsapplication-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-scroll-bar))))
(define (nsapplication-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-unit-description))))
(define (nsapplication-set-accessibility-vertical-units! self accessibility-vertical-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnits:")) accessibility-vertical-units))
(define (nsapplication-set-accessibility-visible-cells! self accessibility-visible-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCells:")) (id->ffi2-ptr (coerce-arg accessibility-visible-cells))))
(define (nsapplication-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCharacterRange:")) (id->ffi2-ptr accessibility-visible-character-range)))
(define (nsapplication-set-accessibility-visible-children! self accessibility-visible-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleChildren:")) (id->ffi2-ptr (coerce-arg accessibility-visible-children))))
(define (nsapplication-set-accessibility-visible-columns! self accessibility-visible-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleColumns:")) (id->ffi2-ptr (coerce-arg accessibility-visible-columns))))
(define (nsapplication-set-accessibility-visible-rows! self accessibility-visible-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleRows:")) (id->ffi2-ptr (coerce-arg accessibility-visible-rows))))
(define (nsapplication-set-accessibility-warning-value! self accessibility-warning-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWarningValue:")) (id->ffi2-ptr (coerce-arg accessibility-warning-value))))
(define (nsapplication-set-accessibility-window! self accessibility-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindow:")) (id->ffi2-ptr (coerce-arg accessibility-window))))
(define (nsapplication-set-accessibility-windows! self accessibility-windows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindows:")) (id->ffi2-ptr (coerce-arg accessibility-windows))))
(define (nsapplication-set-accessibility-zoom-button! self accessibility-zoom-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityZoomButton:")) (id->ffi2-ptr (coerce-arg accessibility-zoom-button))))
(define (nsapplication-set-activation-policy! self activation-policy)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setActivationPolicy:")) activation-policy))
(define (nsapplication-set-mark! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-set-windows-need-update! self need-update)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWindowsNeedUpdate:")) need-update))
(define (nsapplication-should-be-treated-as-ink-event self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldBeTreatedAsInkEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-show-context-help self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextHelp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-show-context-menu-for-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextMenuForSelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-show-help self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showHelp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-show-writing-tools self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showWritingTools:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-smart-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "smartMagnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-stop self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stop:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-stop-modal self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stopModal"))))
(define (nsapplication-stop-modal-with-code self return-code)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "stopModalWithCode:")) return-code))
(define (nsapplication-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "supplementalTargetForAction:sender:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg sender))))
   ))
(define (nsapplication-swap-with-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swapWithMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-swipe-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swipeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-tablet-point self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletPoint:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-tablet-proximity self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletProximity:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-target-for-action self action)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "targetForAction:")) (id->ffi2-ptr (sel_registerName action))))
   ))
(define (nsapplication-target-for-action-to-from self action target sender)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "targetForAction:to:from:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg target)) (id->ffi2-ptr (coerce-arg sender))))
   ))
(define (nsapplication-terminate self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "terminate:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-toggle-touch-bar-customization-palette! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "toggleTouchBarCustomizationPalette:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-touches-began-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesBeganWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-touches-cancelled-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesCancelledWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-touches-ended-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesEndedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-touches-moved-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesMovedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-transpose self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transpose:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-transpose-words self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transposeWords:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-try-to-perform-with self action object)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tryToPerform:with:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg object))))
(define (nsapplication-unhide self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "unhide:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-unhide-all-applications self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "unhideAllApplications:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-unhide-without-activation self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "unhideWithoutActivation"))))
(define (nsapplication-unregister-for-remote-notifications self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "unregisterForRemoteNotifications"))))
(define (nsapplication-unregister-user-interface-item-search-handler self handler)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "unregisterUserInterfaceItemSearchHandler:")) (id->ffi2-ptr (coerce-arg handler))))
(define (nsapplication-update-user-activity-state self user-activity)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateUserActivityState:")) (id->ffi2-ptr (coerce-arg user-activity))))
(define (nsapplication-update-windows self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateWindows"))))
(define (nsapplication-update-windows-item self win)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateWindowsItem:")) (id->ffi2-ptr (coerce-arg win))))
(define (nsapplication-uppercase-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "uppercaseWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validRequestorForSendType:returnType:")) (id->ffi2-ptr (coerce-arg send-type)) (id->ffi2-ptr (coerce-arg return-type))))
   ))
(define (nsapplication-validate-menu-item self menu-item)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validateMenuItem:")) (id->ffi2-ptr (coerce-arg menu-item))))
(define (nsapplication-validate-proposed-first-responder-for-event self responder event)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validateProposedFirstResponder:forEvent:")) (id->ffi2-ptr (coerce-arg responder)) (id->ffi2-ptr (coerce-arg event))))
(define (nsapplication-validate-user-interface-item self item)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validateUserInterfaceItem:")) (id->ffi2-ptr (coerce-arg item))))
(define (nsapplication-wants-forwarded-scroll-events-for-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsForwardedScrollEventsForAxis:")) axis))
(define (nsapplication-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:")) axis))
(define (nsapplication-will-present-error self error)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "willPresentError:")) (id->ffi2-ptr (coerce-arg error))))
   ))
(define (nsapplication-window-with-window-number self window-num)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "windowWithWindowNumber:")) window-num))
   ))
(define (nsapplication-yank self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "yank:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsapplication-yield-activation-to-application self application)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "yieldActivationToApplication:")) (id->ffi2-ptr (coerce-arg application))))
(define (nsapplication-yield-activation-to-application-with-bundle-identifier self bundle-identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "yieldActivationToApplicationWithBundleIdentifier:")) (id->ffi2-ptr (coerce-arg bundle-identifier))))

;; --- Class methods ---
(define (nsapplication-allowed-classes-for-restorable-state-key-path key-path)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSApplication) (id->ffi2-ptr (sel_registerName "allowedClassesForRestorableStateKeyPath:")) (id->ffi2-ptr (coerce-arg key-path))))
   ))
(define (nsapplication-detach-drawing-thread-to-target-with-object selector target argument)
  (aw_racket_msg_PPP_v (id->ffi2-ptr NSApplication) (id->ffi2-ptr (sel_registerName "detachDrawingThread:toTarget:withObject:")) (id->ffi2-ptr (sel_registerName selector)) (id->ffi2-ptr (coerce-arg target)) (id->ffi2-ptr (coerce-arg argument))))
