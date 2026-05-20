#lang racket/base
;; Generated binding for NSApplication (AppKit)
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
(define (nsapplication? v) (objc-instance-of? v "NSApplication"))
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsattributedstring? v) (objc-instance-of? v "NSAttributedString"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsdocktile? v) (objc-instance-of? v "NSDockTile"))
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
  [nsapplication-ordered-documents (c-> nsapplication? any/c)]
  [nsapplication-ordered-windows (c-> nsapplication? any/c)]
  [nsapplication-presentation-options (c-> nsapplication? exact-nonnegative-integer?)]
  [nsapplication-set-presentation-options! (c-> nsapplication? exact-nonnegative-integer? void?)]
  [nsapplication-protected-data-available (c-> nsapplication? boolean?)]
  [nsapplication-registered-for-remote-notifications (c-> nsapplication? boolean?)]
  [nsapplication-restorable-state-key-paths (c-> any/c)]
  [nsapplication-running (c-> nsapplication? boolean?)]
  [nsapplication-services-menu (c-> nsapplication? (or/c nsmenu? objc-nil?))]
  [nsapplication-set-services-menu! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-services-provider (c-> nsapplication? any/c)]
  [nsapplication-set-services-provider! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-shared-application (c-> any/c)]
  [nsapplication-touch-bar (c-> nsapplication? (or/c nstouchbar? objc-nil?))]
  [nsapplication-set-touch-bar! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-undo-manager (c-> nsapplication? (or/c nsundomanager? objc-nil?))]
  [nsapplication-user-activity (c-> nsapplication? (or/c nsuseractivity? objc-nil?))]
  [nsapplication-set-user-activity! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-user-interface-layout-direction (c-> nsapplication? exact-nonnegative-integer?)]
  [nsapplication-windows (c-> nsapplication? any/c)]
  [nsapplication-windows-menu (c-> nsapplication? (or/c nsmenu? objc-nil?))]
  [nsapplication-set-windows-menu! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-abort-modal (c-> nsapplication? void?)]
  [nsapplication-accessibility-activation-point (c-> nsapplication? any/c)]
  [nsapplication-accessibility-allowed-values (c-> nsapplication? any/c)]
  [nsapplication-accessibility-application-focused-ui-element (c-> nsapplication? any/c)]
  [nsapplication-accessibility-attributed-string-for-range (c-> nsapplication? any/c (or/c nsattributedstring? objc-nil?))]
  [nsapplication-accessibility-attributed-user-input-labels (c-> nsapplication? any/c)]
  [nsapplication-accessibility-cancel-button (c-> nsapplication? any/c)]
  [nsapplication-accessibility-cell-for-column-row (c-> nsapplication? exact-integer? exact-integer? any/c)]
  [nsapplication-accessibility-children (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-children-in-navigation-order (c-> nsapplication? any/c)]
  [nsapplication-accessibility-clear-button (c-> nsapplication? any/c)]
  [nsapplication-accessibility-close-button (c-> nsapplication? any/c)]
  [nsapplication-accessibility-column-count (c-> nsapplication? exact-integer?)]
  [nsapplication-accessibility-column-header-ui-elements (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-column-index-range (c-> nsapplication? any/c)]
  [nsapplication-accessibility-column-titles (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-columns (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-contents (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-critical-value (c-> nsapplication? any/c)]
  [nsapplication-accessibility-custom-actions (c-> nsapplication? any/c)]
  [nsapplication-accessibility-custom-rotors (c-> nsapplication? any/c)]
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
  [nsapplication-accessibility-horizontal-units (c-> nsapplication? exact-nonnegative-integer?)]
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
  [nsapplication-accessibility-orientation (c-> nsapplication? exact-nonnegative-integer?)]
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
  [nsapplication-accessibility-ruler-marker-type (c-> nsapplication? exact-nonnegative-integer?)]
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
  [nsapplication-accessibility-selected-text-ranges (c-> nsapplication? any/c)]
  [nsapplication-accessibility-serves-as-title-for-ui-elements (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-shared-character-range (c-> nsapplication? any/c)]
  [nsapplication-accessibility-shared-focus-elements (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-shared-text-ui-elements (c-> nsapplication? (or/c nsarray? objc-nil?))]
  [nsapplication-accessibility-shown-menu (c-> nsapplication? any/c)]
  [nsapplication-accessibility-sort-direction (c-> nsapplication? exact-nonnegative-integer?)]
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
  [nsapplication-accessibility-units (c-> nsapplication? exact-nonnegative-integer?)]
  [nsapplication-accessibility-user-input-labels (c-> nsapplication? any/c)]
  [nsapplication-accessibility-value (c-> nsapplication? any/c)]
  [nsapplication-accessibility-value-description (c-> nsapplication? (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-vertical-scroll-bar (c-> nsapplication? any/c)]
  [nsapplication-accessibility-vertical-unit-description (c-> nsapplication? (or/c nsstring? objc-nil?))]
  [nsapplication-accessibility-vertical-units (c-> nsapplication? exact-nonnegative-integer?)]
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
  [nsapplication-activate-ignoring-other-apps (c-> nsapplication? boolean? void?)]
  [nsapplication-activation-policy (c-> nsapplication? exact-nonnegative-integer?)]
  [nsapplication-become-first-responder (c-> nsapplication? boolean?)]
  [nsapplication-begin-gesture-with-event! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-begin-modal-session-for-window! (c-> nsapplication? (or/c string? objc-object? #f) (or/c cpointer? #f))]
  [nsapplication-cancel-operation (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-cancel-user-attention-request (c-> nsapplication? exact-integer? void?)]
  [nsapplication-capitalize-word (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-center-selection-in-visible-area! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-change-case-of-letter (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-change-mode-with-event (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-complete (c-> nsapplication? (or/c string? objc-object? #f) void?)]
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
  [nsapplication-do-command-by-selector (c-> nsapplication? string? void?)]
  [nsapplication-encode-with-coder (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-end-gesture-with-event! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-end-modal-session! (c-> nsapplication? (or/c cpointer? #f) void?)]
  [nsapplication-enumerate-windows-with-options-using-block (c-> nsapplication? exact-nonnegative-integer? (or/c procedure? #f) void?)]
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
  [nsapplication-is-hidden (c-> nsapplication? boolean?)]
  [nsapplication-is-protected-data-available (c-> nsapplication? boolean?)]
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
  [nsapplication-no-responder-for (c-> nsapplication? string? void?)]
  [nsapplication-order-front-character-palette! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-other-mouse-down (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-other-mouse-dragged (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-other-mouse-up (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-page-down (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-page-down-and-modify-selection (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-page-up (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-page-up-and-modify-selection (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-perform-key-equivalent! (c-> nsapplication? (or/c string? objc-object? #f) boolean?)]
  [nsapplication-pressure-change-with-event (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-prevent-window-ordering (c-> nsapplication? void?)]
  [nsapplication-quick-look-preview-items (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-quick-look-with-event (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-reply-to-application-should-terminate (c-> nsapplication? boolean? void?)]
  [nsapplication-reply-to-open-or-print (c-> nsapplication? exact-nonnegative-integer? void?)]
  [nsapplication-report-exception (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-request-user-attention (c-> nsapplication? exact-nonnegative-integer? exact-integer?)]
  [nsapplication-resign-first-responder (c-> nsapplication? boolean?)]
  [nsapplication-restore-user-activity-state (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-right-mouse-down (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-right-mouse-dragged (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-right-mouse-up (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-rotate-with-event (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-run (c-> nsapplication? void?)]
  [nsapplication-run-modal-for-window (c-> nsapplication? (or/c string? objc-object? #f) exact-integer?)]
  [nsapplication-run-modal-session (c-> nsapplication? (or/c cpointer? #f) exact-integer?)]
  [nsapplication-scroll-line-down (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-scroll-line-up (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-scroll-page-down (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-scroll-page-up (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-scroll-to-beginning-of-document (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-scroll-to-end-of-document (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-scroll-wheel (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-select-all (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-select-line (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-select-paragraph (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-select-to-mark (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-select-word (c-> nsapplication? (or/c string? objc-object? #f) void?)]
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
  [nsapplication-set-accessibility-horizontal-units! (c-> nsapplication? exact-nonnegative-integer? void?)]
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
  [nsapplication-set-accessibility-orientation! (c-> nsapplication? exact-nonnegative-integer? void?)]
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
  [nsapplication-set-accessibility-ruler-marker-type! (c-> nsapplication? exact-nonnegative-integer? void?)]
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
  [nsapplication-set-accessibility-sort-direction! (c-> nsapplication? exact-nonnegative-integer? void?)]
  [nsapplication-set-accessibility-splitters! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-subrole! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-tabs! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-title! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-title-ui-element! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-toolbar-button! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-top-level-ui-element! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-url! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-unit-description! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-units! (c-> nsapplication? exact-nonnegative-integer? void?)]
  [nsapplication-set-accessibility-user-input-labels! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-value! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-value-description! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-vertical-scroll-bar! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-vertical-unit-description! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-vertical-units! (c-> nsapplication? exact-nonnegative-integer? void?)]
  [nsapplication-set-accessibility-visible-cells! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-visible-character-range! (c-> nsapplication? any/c void?)]
  [nsapplication-set-accessibility-visible-children! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-visible-columns! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-visible-rows! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-warning-value! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-window! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-windows! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-accessibility-zoom-button! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-activation-policy! (c-> nsapplication? exact-nonnegative-integer? boolean?)]
  [nsapplication-set-mark! (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-set-windows-need-update! (c-> nsapplication? boolean? void?)]
  [nsapplication-should-be-treated-as-ink-event (c-> nsapplication? (or/c string? objc-object? #f) boolean?)]
  [nsapplication-show-context-help (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-show-context-menu-for-selection (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-smart-magnify-with-event (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-stop (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-stop-modal (c-> nsapplication? void?)]
  [nsapplication-stop-modal-with-code (c-> nsapplication? exact-integer? void?)]
  [nsapplication-supplemental-target-for-action-sender (c-> nsapplication? string? (or/c string? objc-object? #f) any/c)]
  [nsapplication-swap-with-mark (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-swipe-with-event (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-tablet-point (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-tablet-proximity (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-terminate (c-> nsapplication? (or/c string? objc-object? #f) void?)]
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
  [nsapplication-update-windows (c-> nsapplication? void?)]
  [nsapplication-uppercase-word (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-valid-requestor-for-send-type-return-type (c-> nsapplication? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nsapplication-validate-menu-item (c-> nsapplication? (or/c string? objc-object? #f) boolean?)]
  [nsapplication-validate-user-interface-item (c-> nsapplication? (or/c string? objc-object? #f) boolean?)]
  [nsapplication-wants-forwarded-scroll-events-for-axis (c-> nsapplication? exact-nonnegative-integer? boolean?)]
  [nsapplication-wants-scroll-events-for-swipe-tracking-on-axis (c-> nsapplication? exact-nonnegative-integer? boolean?)]
  [nsapplication-window-with-window-number (c-> nsapplication? exact-integer? (or/c nswindow? objc-nil?))]
  [nsapplication-yank (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-yield-activation-to-application (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-yield-activation-to-application-with-bundle-identifier (c-> nsapplication? (or/c string? objc-object? #f) void?)]
  [nsapplication-detach-drawing-thread-to-target-with-object (c-> string? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsapplication-load-application (c-> void?)]
  )

;; --- Class reference ---
(import-class NSApplication)

;; --- Shared typed objc_msgSend bindings ---
(define _msg-0  ; (_fun _pointer _pointer -> _NSPoint)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _NSPoint)))
(define _msg-1  ; (_fun _pointer _pointer -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _NSRange)))
(define _msg-2  ; (_fun _pointer _pointer -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _NSRect)))
(define _msg-3  ; (_fun _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _bool)))
(define _msg-4  ; (_fun _pointer _pointer -> _float)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _float)))
(define _msg-5  ; (_fun _pointer _pointer -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _int64)))
(define _msg-6  ; (_fun _pointer _pointer -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _uint64)))
(define _msg-7  ; (_fun _pointer _pointer _NSPoint -> _NSPoint)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _NSPoint)))
(define _msg-8  ; (_fun _pointer _pointer _NSPoint -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _NSRange)))
(define _msg-9  ; (_fun _pointer _pointer _NSPoint -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _void)))
(define _msg-10  ; (_fun _pointer _pointer _NSRange -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _NSRect)))
(define _msg-11  ; (_fun _pointer _pointer _NSRange -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _id)))
(define _msg-12  ; (_fun _pointer _pointer _NSRange -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _void)))
(define _msg-13  ; (_fun _pointer _pointer _NSRect -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _void)))
(define _msg-14  ; (_fun _pointer _pointer _NSSize -> _NSSize)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize -> _NSSize)))
(define _msg-15  ; (_fun _pointer _pointer _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _bool -> _void)))
(define _msg-16  ; (_fun _pointer _pointer _float -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _float -> _void)))
(define _msg-17  ; (_fun _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _bool)))
(define _msg-18  ; (_fun _pointer _pointer _id -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _int64)))
(define _msg-19  ; (_fun _pointer _pointer _id -> _pointer)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _pointer)))
(define _msg-20  ; (_fun _pointer _pointer _int64 -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _NSRange)))
(define _msg-21  ; (_fun _pointer _pointer _int64 -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _bool)))
(define _msg-22  ; (_fun _pointer _pointer _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _id)))
(define _msg-23  ; (_fun _pointer _pointer _int64 -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _int64)))
(define _msg-24  ; (_fun _pointer _pointer _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _void)))
(define _msg-25  ; (_fun _pointer _pointer _int64 _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _int64 -> _id)))
(define _msg-26  ; (_fun _pointer _pointer _int64 _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _pointer -> _void)))
(define _msg-27  ; (_fun _pointer _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _bool)))
(define _msg-28  ; (_fun _pointer _pointer _pointer -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _int64)))
(define _msg-29  ; (_fun _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _void)))
(define _msg-30  ; (_fun _pointer _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _bool)))
(define _msg-31  ; (_fun _pointer _pointer _pointer _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id -> _id)))
(define _msg-32  ; (_fun _pointer _pointer _pointer _id _id -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer _id _id -> _void)))
(define _msg-33  ; (_fun _pointer _pointer _uint64 -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _int64)))
(define _msg-34  ; (_fun _pointer _pointer _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _void)))

;; --- Constructors ---
(define (make-nsapplication-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSApplication alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))


;; --- Properties ---
(define (nsapplication-accepts-first-responder self)
  (tell #:type _bool (coerce-arg self) acceptsFirstResponder))
(define (nsapplication-active self)
  (tell #:type _bool (coerce-arg self) active))
(define (nsapplication-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) appearance)))
(define (nsapplication-set-appearance! self value)
  (tell #:type _void (coerce-arg self) setAppearance: (coerce-arg value)))
(define (nsapplication-application-icon-image self)
  (wrap-objc-object
   (tell (coerce-arg self) applicationIconImage)))
(define (nsapplication-set-application-icon-image! self value)
  (tell #:type _void (coerce-arg self) setApplicationIconImage: (coerce-arg value)))
(define (nsapplication-application-should-suppress-high-dynamic-range-content self)
  (tell #:type _bool (coerce-arg self) applicationShouldSuppressHighDynamicRangeContent))
(define (nsapplication-automatic-customize-touch-bar-menu-item-enabled self)
  (tell #:type _bool (coerce-arg self) automaticCustomizeTouchBarMenuItemEnabled))
(define (nsapplication-set-automatic-customize-touch-bar-menu-item-enabled! self value)
  (_msg-15 (coerce-arg self) (sel_registerName "setAutomaticCustomizeTouchBarMenuItemEnabled:") value))
(define (nsapplication-context self)
  (wrap-objc-object
   (tell (coerce-arg self) context)))
(define (nsapplication-current-event self)
  (wrap-objc-object
   (tell (coerce-arg self) currentEvent)))
(define (nsapplication-current-system-presentation-options self)
  (tell #:type _uint64 (coerce-arg self) currentSystemPresentationOptions))
(define (nsapplication-delegate self)
  (wrap-objc-object
   (tell (coerce-arg self) delegate)))
(define (nsapplication-set-delegate! self value)
  (tell #:type _void (coerce-arg self) setDelegate: (coerce-arg value)))
(define (nsapplication-dock-tile self)
  (wrap-objc-object
   (tell (coerce-arg self) dockTile)))
(define (nsapplication-effective-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) effectiveAppearance)))
(define (nsapplication-enabled-remote-notification-types self)
  (tell #:type _uint64 (coerce-arg self) enabledRemoteNotificationTypes))
(define (nsapplication-full-keyboard-access-enabled self)
  (tell #:type _bool (coerce-arg self) fullKeyboardAccessEnabled))
(define (nsapplication-help-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) helpMenu)))
(define (nsapplication-set-help-menu! self value)
  (tell #:type _void (coerce-arg self) setHelpMenu: (coerce-arg value)))
(define (nsapplication-hidden self)
  (tell #:type _bool (coerce-arg self) hidden))
(define (nsapplication-key-window self)
  (wrap-objc-object
   (tell (coerce-arg self) keyWindow)))
(define (nsapplication-main-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) mainMenu)))
(define (nsapplication-set-main-menu! self value)
  (tell #:type _void (coerce-arg self) setMainMenu: (coerce-arg value)))
(define (nsapplication-main-window self)
  (wrap-objc-object
   (tell (coerce-arg self) mainWindow)))
(define (nsapplication-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) menu)))
(define (nsapplication-set-menu! self value)
  (tell #:type _void (coerce-arg self) setMenu: (coerce-arg value)))
(define (nsapplication-modal-window self)
  (wrap-objc-object
   (tell (coerce-arg self) modalWindow)))
(define (nsapplication-next-responder self)
  (wrap-objc-object
   (tell (coerce-arg self) nextResponder)))
(define (nsapplication-set-next-responder! self value)
  (tell #:type _void (coerce-arg self) setNextResponder: (coerce-arg value)))
(define (nsapplication-occlusion-state self)
  (tell #:type _uint64 (coerce-arg self) occlusionState))
(define (nsapplication-ordered-documents self)
  (wrap-objc-object
   (tell (coerce-arg self) orderedDocuments)))
(define (nsapplication-ordered-windows self)
  (wrap-objc-object
   (tell (coerce-arg self) orderedWindows)))
(define (nsapplication-presentation-options self)
  (tell #:type _uint64 (coerce-arg self) presentationOptions))
(define (nsapplication-set-presentation-options! self value)
  (_msg-34 (coerce-arg self) (sel_registerName "setPresentationOptions:") value))
(define (nsapplication-protected-data-available self)
  (tell #:type _bool (coerce-arg self) protectedDataAvailable))
(define (nsapplication-registered-for-remote-notifications self)
  (tell #:type _bool (coerce-arg self) registeredForRemoteNotifications))
(define (nsapplication-restorable-state-key-paths)
  (wrap-objc-object
   (tell NSApplication restorableStateKeyPaths)))
(define (nsapplication-running self)
  (tell #:type _bool (coerce-arg self) running))
(define (nsapplication-services-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) servicesMenu)))
(define (nsapplication-set-services-menu! self value)
  (tell #:type _void (coerce-arg self) setServicesMenu: (coerce-arg value)))
(define (nsapplication-services-provider self)
  (wrap-objc-object
   (tell (coerce-arg self) servicesProvider)))
(define (nsapplication-set-services-provider! self value)
  (tell #:type _void (coerce-arg self) setServicesProvider: (coerce-arg value)))
(define (nsapplication-shared-application)
  (wrap-objc-object
   (tell NSApplication sharedApplication)))
(define (nsapplication-touch-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) touchBar)))
(define (nsapplication-set-touch-bar! self value)
  (tell #:type _void (coerce-arg self) setTouchBar: (coerce-arg value)))
(define (nsapplication-undo-manager self)
  (wrap-objc-object
   (tell (coerce-arg self) undoManager)))
(define (nsapplication-user-activity self)
  (wrap-objc-object
   (tell (coerce-arg self) userActivity)))
(define (nsapplication-set-user-activity! self value)
  (tell #:type _void (coerce-arg self) setUserActivity: (coerce-arg value)))
(define (nsapplication-user-interface-layout-direction self)
  (tell #:type _int64 (coerce-arg self) userInterfaceLayoutDirection))
(define (nsapplication-windows self)
  (wrap-objc-object
   (tell (coerce-arg self) windows)))
(define (nsapplication-windows-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) windowsMenu)))
(define (nsapplication-set-windows-menu! self value)
  (tell #:type _void (coerce-arg self) setWindowsMenu: (coerce-arg value)))

;; --- Instance methods ---
(define (nsapplication-abort-modal self)
  (tell #:type _void (coerce-arg self) abortModal))
(define (nsapplication-accessibility-activation-point self)
  (_msg-0 (coerce-arg self) (sel_registerName "accessibilityActivationPoint")))
(define (nsapplication-accessibility-allowed-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAllowedValues)))
(define (nsapplication-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityApplicationFocusedUIElement)))
(define (nsapplication-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (_msg-11 (coerce-arg self) (sel_registerName "accessibilityAttributedStringForRange:") range)
   ))
(define (nsapplication-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAttributedUserInputLabels)))
(define (nsapplication-accessibility-cancel-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCancelButton)))
(define (nsapplication-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (_msg-25 (coerce-arg self) (sel_registerName "accessibilityCellForColumn:row:") column row)
   ))
(define (nsapplication-accessibility-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildren)))
(define (nsapplication-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildrenInNavigationOrder)))
(define (nsapplication-accessibility-clear-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityClearButton)))
(define (nsapplication-accessibility-close-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCloseButton)))
(define (nsapplication-accessibility-column-count self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityColumnCount")))
(define (nsapplication-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnHeaderUIElements)))
(define (nsapplication-accessibility-column-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityColumnIndexRange")))
(define (nsapplication-accessibility-column-titles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnTitles)))
(define (nsapplication-accessibility-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumns)))
(define (nsapplication-accessibility-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityContents)))
(define (nsapplication-accessibility-critical-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCriticalValue)))
(define (nsapplication-accessibility-custom-actions self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomActions)))
(define (nsapplication-accessibility-custom-rotors self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomRotors)))
(define (nsapplication-accessibility-decrement-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDecrementButton)))
(define (nsapplication-accessibility-default-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDefaultButton)))
(define (nsapplication-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedByRow)))
(define (nsapplication-accessibility-disclosed-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedRows)))
(define (nsapplication-accessibility-disclosure-level self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityDisclosureLevel")))
(define (nsapplication-accessibility-document self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDocument)))
(define (nsapplication-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityExtrasMenuBar)))
(define (nsapplication-accessibility-filename self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFilename)))
(define (nsapplication-accessibility-focused-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFocusedWindow)))
(define (nsapplication-accessibility-frame self)
  (_msg-2 (coerce-arg self) (sel_registerName "accessibilityFrame")))
(define (nsapplication-accessibility-frame-for-range self range)
  (_msg-10 (coerce-arg self) (sel_registerName "accessibilityFrameForRange:") range))
(define (nsapplication-accessibility-full-screen-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFullScreenButton)))
(define (nsapplication-accessibility-grow-area self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityGrowArea)))
(define (nsapplication-accessibility-handles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHandles)))
(define (nsapplication-accessibility-header self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHeader)))
(define (nsapplication-accessibility-help self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHelp)))
(define (nsapplication-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalScrollBar)))
(define (nsapplication-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalUnitDescription)))
(define (nsapplication-accessibility-horizontal-units self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityHorizontalUnits")))
(define (nsapplication-accessibility-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIdentifier)))
(define (nsapplication-accessibility-increment-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIncrementButton)))
(define (nsapplication-accessibility-index self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityIndex")))
(define (nsapplication-accessibility-insertion-point-line-number self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityInsertionPointLineNumber")))
(define (nsapplication-accessibility-label self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabel)))
(define (nsapplication-accessibility-label-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabelUIElements)))
(define (nsapplication-accessibility-label-value self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityLabelValue")))
(define (nsapplication-accessibility-layout-point-for-screen-point self point)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityLayoutPointForScreenPoint:") point))
(define (nsapplication-accessibility-layout-size-for-screen-size self size)
  (_msg-14 (coerce-arg self) (sel_registerName "accessibilityLayoutSizeForScreenSize:") size))
(define (nsapplication-accessibility-line-for-index self index)
  (_msg-23 (coerce-arg self) (sel_registerName "accessibilityLineForIndex:") index))
(define (nsapplication-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLinkedUIElements)))
(define (nsapplication-accessibility-main-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMainWindow)))
(define (nsapplication-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerGroupUIElement)))
(define (nsapplication-accessibility-marker-type-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerTypeDescription)))
(define (nsapplication-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerUIElements)))
(define (nsapplication-accessibility-marker-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerValues)))
(define (nsapplication-accessibility-max-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMaxValue)))
(define (nsapplication-accessibility-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMenuBar)))
(define (nsapplication-accessibility-min-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinValue)))
(define (nsapplication-accessibility-minimize-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinimizeButton)))
(define (nsapplication-accessibility-next-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityNextContents)))
(define (nsapplication-accessibility-number-of-characters self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityNumberOfCharacters")))
(define (nsapplication-accessibility-orientation self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityOrientation")))
(define (nsapplication-accessibility-overflow-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityOverflowButton)))
(define (nsapplication-accessibility-parent self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityParent)))
(define (nsapplication-accessibility-perform-cancel self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformCancel")))
(define (nsapplication-accessibility-perform-confirm self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformConfirm")))
(define (nsapplication-accessibility-perform-decrement self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformDecrement")))
(define (nsapplication-accessibility-perform-delete self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformDelete")))
(define (nsapplication-accessibility-perform-increment self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformIncrement")))
(define (nsapplication-accessibility-perform-pick self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformPick")))
(define (nsapplication-accessibility-perform-press self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformPress")))
(define (nsapplication-accessibility-perform-raise self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformRaise")))
(define (nsapplication-accessibility-perform-show-alternate-ui self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowAlternateUI")))
(define (nsapplication-accessibility-perform-show-default-ui self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowDefaultUI")))
(define (nsapplication-accessibility-perform-show-menu self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowMenu")))
(define (nsapplication-accessibility-placeholder-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPlaceholderValue)))
(define (nsapplication-accessibility-previous-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPreviousContents)))
(define (nsapplication-accessibility-proxy self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityProxy)))
(define (nsapplication-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (_msg-11 (coerce-arg self) (sel_registerName "accessibilityRTFForRange:") range)
   ))
(define (nsapplication-accessibility-range-for-index self index)
  (_msg-20 (coerce-arg self) (sel_registerName "accessibilityRangeForIndex:") index))
(define (nsapplication-accessibility-range-for-line self line)
  (_msg-20 (coerce-arg self) (sel_registerName "accessibilityRangeForLine:") line))
(define (nsapplication-accessibility-range-for-position self point)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityRangeForPosition:") point))
(define (nsapplication-accessibility-role self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRole)))
(define (nsapplication-accessibility-role-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRoleDescription)))
(define (nsapplication-accessibility-row-count self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityRowCount")))
(define (nsapplication-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRowHeaderUIElements)))
(define (nsapplication-accessibility-row-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityRowIndexRange")))
(define (nsapplication-accessibility-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRows)))
(define (nsapplication-accessibility-ruler-marker-type self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityRulerMarkerType")))
(define (nsapplication-accessibility-screen-point-for-layout-point self point)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityScreenPointForLayoutPoint:") point))
(define (nsapplication-accessibility-screen-size-for-layout-size self size)
  (_msg-14 (coerce-arg self) (sel_registerName "accessibilityScreenSizeForLayoutSize:") size))
(define (nsapplication-accessibility-search-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchButton)))
(define (nsapplication-accessibility-search-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchMenu)))
(define (nsapplication-accessibility-selected-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedCells)))
(define (nsapplication-accessibility-selected-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedChildren)))
(define (nsapplication-accessibility-selected-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedColumns)))
(define (nsapplication-accessibility-selected-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedRows)))
(define (nsapplication-accessibility-selected-text self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedText)))
(define (nsapplication-accessibility-selected-text-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySelectedTextRange")))
(define (nsapplication-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedTextRanges)))
(define (nsapplication-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityServesAsTitleForUIElements)))
(define (nsapplication-accessibility-shared-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySharedCharacterRange")))
(define (nsapplication-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedFocusElements)))
(define (nsapplication-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedTextUIElements)))
(define (nsapplication-accessibility-shown-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityShownMenu)))
(define (nsapplication-accessibility-sort-direction self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilitySortDirection")))
(define (nsapplication-accessibility-splitters self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySplitters)))
(define (nsapplication-accessibility-string-for-range self range)
  (wrap-objc-object
   (_msg-11 (coerce-arg self) (sel_registerName "accessibilityStringForRange:") range)
   ))
(define (nsapplication-accessibility-style-range-for-index self index)
  (_msg-20 (coerce-arg self) (sel_registerName "accessibilityStyleRangeForIndex:") index))
(define (nsapplication-accessibility-subrole self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySubrole)))
(define (nsapplication-accessibility-tabs self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTabs)))
(define (nsapplication-accessibility-title self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitle)))
(define (nsapplication-accessibility-title-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitleUIElement)))
(define (nsapplication-accessibility-toolbar-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityToolbarButton)))
(define (nsapplication-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTopLevelUIElement)))
(define (nsapplication-accessibility-url self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityURL)))
(define (nsapplication-accessibility-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUnitDescription)))
(define (nsapplication-accessibility-units self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityUnits")))
(define (nsapplication-accessibility-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUserInputLabels)))
(define (nsapplication-accessibility-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValue)))
(define (nsapplication-accessibility-value-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValueDescription)))
(define (nsapplication-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalScrollBar)))
(define (nsapplication-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalUnitDescription)))
(define (nsapplication-accessibility-vertical-units self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityVerticalUnits")))
(define (nsapplication-accessibility-visible-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleCells)))
(define (nsapplication-accessibility-visible-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityVisibleCharacterRange")))
(define (nsapplication-accessibility-visible-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleChildren)))
(define (nsapplication-accessibility-visible-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleColumns)))
(define (nsapplication-accessibility-visible-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleRows)))
(define (nsapplication-accessibility-warning-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWarningValue)))
(define (nsapplication-accessibility-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindow)))
(define (nsapplication-accessibility-windows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindows)))
(define (nsapplication-accessibility-zoom-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityZoomButton)))
(define (nsapplication-activate self)
  (tell #:type _void (coerce-arg self) activate))
(define (nsapplication-activate-ignoring-other-apps self ignore-other-apps)
  (_msg-15 (coerce-arg self) (sel_registerName "activateIgnoringOtherApps:") ignore-other-apps))
(define (nsapplication-activation-policy self)
  (_msg-5 (coerce-arg self) (sel_registerName "activationPolicy")))
(define (nsapplication-become-first-responder self)
  (_msg-3 (coerce-arg self) (sel_registerName "becomeFirstResponder")))
(define (nsapplication-begin-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) beginGestureWithEvent: (coerce-arg event)))
(define (nsapplication-begin-modal-session-for-window! self window)
  (_msg-19 (coerce-arg self) (sel_registerName "beginModalSessionForWindow:") (coerce-arg window)))
(define (nsapplication-cancel-operation self sender)
  (tell #:type _void (coerce-arg self) cancelOperation: (coerce-arg sender)))
(define (nsapplication-cancel-user-attention-request self request)
  (_msg-24 (coerce-arg self) (sel_registerName "cancelUserAttentionRequest:") request))
(define (nsapplication-capitalize-word self sender)
  (tell #:type _void (coerce-arg self) capitalizeWord: (coerce-arg sender)))
(define (nsapplication-center-selection-in-visible-area! self sender)
  (tell #:type _void (coerce-arg self) centerSelectionInVisibleArea: (coerce-arg sender)))
(define (nsapplication-change-case-of-letter self sender)
  (tell #:type _void (coerce-arg self) changeCaseOfLetter: (coerce-arg sender)))
(define (nsapplication-change-mode-with-event self event)
  (tell #:type _void (coerce-arg self) changeModeWithEvent: (coerce-arg event)))
(define (nsapplication-complete self sender)
  (tell #:type _void (coerce-arg self) complete: (coerce-arg sender)))
(define (nsapplication-context-menu-key-down self event)
  (tell #:type _void (coerce-arg self) contextMenuKeyDown: (coerce-arg event)))
(define (nsapplication-cursor-update self event)
  (tell #:type _void (coerce-arg self) cursorUpdate: (coerce-arg event)))
(define (nsapplication-deactivate self)
  (tell #:type _void (coerce-arg self) deactivate))
(define (nsapplication-delete-backward self sender)
  (tell #:type _void (coerce-arg self) deleteBackward: (coerce-arg sender)))
(define (nsapplication-delete-backward-by-decomposing-previous-character self sender)
  (tell #:type _void (coerce-arg self) deleteBackwardByDecomposingPreviousCharacter: (coerce-arg sender)))
(define (nsapplication-delete-forward self sender)
  (tell #:type _void (coerce-arg self) deleteForward: (coerce-arg sender)))
(define (nsapplication-delete-to-beginning-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfLine: (coerce-arg sender)))
(define (nsapplication-delete-to-beginning-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToBeginningOfParagraph: (coerce-arg sender)))
(define (nsapplication-delete-to-end-of-line self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfLine: (coerce-arg sender)))
(define (nsapplication-delete-to-end-of-paragraph self sender)
  (tell #:type _void (coerce-arg self) deleteToEndOfParagraph: (coerce-arg sender)))
(define (nsapplication-delete-to-mark self sender)
  (tell #:type _void (coerce-arg self) deleteToMark: (coerce-arg sender)))
(define (nsapplication-delete-word-backward self sender)
  (tell #:type _void (coerce-arg self) deleteWordBackward: (coerce-arg sender)))
(define (nsapplication-delete-word-forward self sender)
  (tell #:type _void (coerce-arg self) deleteWordForward: (coerce-arg sender)))
(define (nsapplication-do-command-by-selector self selector)
  (_msg-29 (coerce-arg self) (sel_registerName "doCommandBySelector:") (sel_registerName selector)))
(define (nsapplication-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nsapplication-end-gesture-with-event! self event)
  (tell #:type _void (coerce-arg self) endGestureWithEvent: (coerce-arg event)))
(define (nsapplication-end-modal-session! self session)
  (_msg-29 (coerce-arg self) (sel_registerName "endModalSession:") session))
(define (nsapplication-enumerate-windows-with-options-using-block self options block)
  (define-values (_blk1 _blk1-id)
    (make-objc-block block (list _id _pointer) _void))
  (_msg-26 (coerce-arg self) (sel_registerName "enumerateWindowsWithOptions:usingBlock:") options _blk1))
(define (nsapplication-finish-launching self)
  (tell #:type _void (coerce-arg self) finishLaunching))
(define (nsapplication-flags-changed self event)
  (tell #:type _void (coerce-arg self) flagsChanged: (coerce-arg event)))
(define (nsapplication-flush-buffered-key-events self)
  (tell #:type _void (coerce-arg self) flushBufferedKeyEvents))
(define (nsapplication-help-requested self event-ptr)
  (tell #:type _void (coerce-arg self) helpRequested: (coerce-arg event-ptr)))
(define (nsapplication-hide self sender)
  (tell #:type _void (coerce-arg self) hide: (coerce-arg sender)))
(define (nsapplication-hide-other-applications self sender)
  (tell #:type _void (coerce-arg self) hideOtherApplications: (coerce-arg sender)))
(define (nsapplication-indent self sender)
  (tell #:type _void (coerce-arg self) indent: (coerce-arg sender)))
(define (nsapplication-insert-backtab! self sender)
  (tell #:type _void (coerce-arg self) insertBacktab: (coerce-arg sender)))
(define (nsapplication-insert-container-break! self sender)
  (tell #:type _void (coerce-arg self) insertContainerBreak: (coerce-arg sender)))
(define (nsapplication-insert-double-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertDoubleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nsapplication-insert-line-break! self sender)
  (tell #:type _void (coerce-arg self) insertLineBreak: (coerce-arg sender)))
(define (nsapplication-insert-newline! self sender)
  (tell #:type _void (coerce-arg self) insertNewline: (coerce-arg sender)))
(define (nsapplication-insert-newline-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertNewlineIgnoringFieldEditor: (coerce-arg sender)))
(define (nsapplication-insert-paragraph-separator! self sender)
  (tell #:type _void (coerce-arg self) insertParagraphSeparator: (coerce-arg sender)))
(define (nsapplication-insert-single-quote-ignoring-substitution! self sender)
  (tell #:type _void (coerce-arg self) insertSingleQuoteIgnoringSubstitution: (coerce-arg sender)))
(define (nsapplication-insert-tab! self sender)
  (tell #:type _void (coerce-arg self) insertTab: (coerce-arg sender)))
(define (nsapplication-insert-tab-ignoring-field-editor! self sender)
  (tell #:type _void (coerce-arg self) insertTabIgnoringFieldEditor: (coerce-arg sender)))
(define (nsapplication-insert-text! self insert-string)
  (tell #:type _void (coerce-arg self) insertText: (coerce-arg insert-string)))
(define (nsapplication-interpret-key-events self event-array)
  (tell #:type _void (coerce-arg self) interpretKeyEvents: (coerce-arg event-array)))
(define (nsapplication-is-accessibility-alternate-ui-visible self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityAlternateUIVisible")))
(define (nsapplication-is-accessibility-disclosed self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityDisclosed")))
(define (nsapplication-is-accessibility-edited self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityEdited")))
(define (nsapplication-is-accessibility-element self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityElement")))
(define (nsapplication-is-accessibility-enabled self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityEnabled")))
(define (nsapplication-is-accessibility-expanded self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityExpanded")))
(define (nsapplication-is-accessibility-focused self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityFocused")))
(define (nsapplication-is-accessibility-frontmost self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityFrontmost")))
(define (nsapplication-is-accessibility-hidden self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityHidden")))
(define (nsapplication-is-accessibility-main self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityMain")))
(define (nsapplication-is-accessibility-minimized self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityMinimized")))
(define (nsapplication-is-accessibility-modal self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityModal")))
(define (nsapplication-is-accessibility-ordered-by-row self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityOrderedByRow")))
(define (nsapplication-is-accessibility-protected-content self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityProtectedContent")))
(define (nsapplication-is-accessibility-required self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityRequired")))
(define (nsapplication-is-accessibility-selected self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilitySelected")))
(define (nsapplication-is-accessibility-selector-allowed self selector)
  (_msg-27 (coerce-arg self) (sel_registerName "isAccessibilitySelectorAllowed:") (sel_registerName selector)))
(define (nsapplication-is-active self)
  (_msg-3 (coerce-arg self) (sel_registerName "isActive")))
(define (nsapplication-is-hidden self)
  (_msg-3 (coerce-arg self) (sel_registerName "isHidden")))
(define (nsapplication-is-protected-data-available self)
  (_msg-3 (coerce-arg self) (sel_registerName "isProtectedDataAvailable")))
(define (nsapplication-is-running self)
  (_msg-3 (coerce-arg self) (sel_registerName "isRunning")))
(define (nsapplication-key-down self event)
  (tell #:type _void (coerce-arg self) keyDown: (coerce-arg event)))
(define (nsapplication-key-up self event)
  (tell #:type _void (coerce-arg self) keyUp: (coerce-arg event)))
(define (nsapplication-lowercase-word self sender)
  (tell #:type _void (coerce-arg self) lowercaseWord: (coerce-arg sender)))
(define (nsapplication-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) magnifyWithEvent: (coerce-arg event)))
(define (nsapplication-make-base-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nsapplication-make-base-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionNatural: (coerce-arg sender)))
(define (nsapplication-make-base-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeBaseWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nsapplication-make-text-writing-direction-left-to-right self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionLeftToRight: (coerce-arg sender)))
(define (nsapplication-make-text-writing-direction-natural self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionNatural: (coerce-arg sender)))
(define (nsapplication-make-text-writing-direction-right-to-left self sender)
  (tell #:type _void (coerce-arg self) makeTextWritingDirectionRightToLeft: (coerce-arg sender)))
(define (nsapplication-mouse-cancelled self event)
  (tell #:type _void (coerce-arg self) mouseCancelled: (coerce-arg event)))
(define (nsapplication-mouse-down self event)
  (tell #:type _void (coerce-arg self) mouseDown: (coerce-arg event)))
(define (nsapplication-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) mouseDragged: (coerce-arg event)))
(define (nsapplication-mouse-entered self event)
  (tell #:type _void (coerce-arg self) mouseEntered: (coerce-arg event)))
(define (nsapplication-mouse-exited self event)
  (tell #:type _void (coerce-arg self) mouseExited: (coerce-arg event)))
(define (nsapplication-mouse-moved self event)
  (tell #:type _void (coerce-arg self) mouseMoved: (coerce-arg event)))
(define (nsapplication-mouse-up self event)
  (tell #:type _void (coerce-arg self) mouseUp: (coerce-arg event)))
(define (nsapplication-move-backward! self sender)
  (tell #:type _void (coerce-arg self) moveBackward: (coerce-arg sender)))
(define (nsapplication-move-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveBackwardAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-down! self sender)
  (tell #:type _void (coerce-arg self) moveDown: (coerce-arg sender)))
(define (nsapplication-move-down-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveDownAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-forward! self sender)
  (tell #:type _void (coerce-arg self) moveForward: (coerce-arg sender)))
(define (nsapplication-move-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveForwardAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-left! self sender)
  (tell #:type _void (coerce-arg self) moveLeft: (coerce-arg sender)))
(define (nsapplication-move-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveLeftAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-paragraph-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphBackwardAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-paragraph-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveParagraphForwardAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-right! self sender)
  (tell #:type _void (coerce-arg self) moveRight: (coerce-arg sender)))
(define (nsapplication-move-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveRightAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-to-beginning-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocument: (coerce-arg sender)))
(define (nsapplication-move-to-beginning-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-to-beginning-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLine: (coerce-arg sender)))
(define (nsapplication-move-to-beginning-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfLineAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-to-beginning-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraph: (coerce-arg sender)))
(define (nsapplication-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToBeginningOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-to-end-of-document! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocument: (coerce-arg sender)))
(define (nsapplication-move-to-end-of-document-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfDocumentAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-to-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLine: (coerce-arg sender)))
(define (nsapplication-move-to-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-to-end-of-paragraph! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraph: (coerce-arg sender)))
(define (nsapplication-move-to-end-of-paragraph-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToEndOfParagraphAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-to-left-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLine: (coerce-arg sender)))
(define (nsapplication-move-to-left-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToLeftEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-to-right-end-of-line! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLine: (coerce-arg sender)))
(define (nsapplication-move-to-right-end-of-line-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveToRightEndOfLineAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-up! self sender)
  (tell #:type _void (coerce-arg self) moveUp: (coerce-arg sender)))
(define (nsapplication-move-up-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveUpAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-word-backward! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackward: (coerce-arg sender)))
(define (nsapplication-move-word-backward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordBackwardAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-word-forward! self sender)
  (tell #:type _void (coerce-arg self) moveWordForward: (coerce-arg sender)))
(define (nsapplication-move-word-forward-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordForwardAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-word-left! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeft: (coerce-arg sender)))
(define (nsapplication-move-word-left-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordLeftAndModifySelection: (coerce-arg sender)))
(define (nsapplication-move-word-right! self sender)
  (tell #:type _void (coerce-arg self) moveWordRight: (coerce-arg sender)))
(define (nsapplication-move-word-right-and-modify-selection! self sender)
  (tell #:type _void (coerce-arg self) moveWordRightAndModifySelection: (coerce-arg sender)))
(define (nsapplication-no-responder-for self event-selector)
  (_msg-29 (coerce-arg self) (sel_registerName "noResponderFor:") (sel_registerName event-selector)))
(define (nsapplication-order-front-character-palette! self sender)
  (tell #:type _void (coerce-arg self) orderFrontCharacterPalette: (coerce-arg sender)))
(define (nsapplication-other-mouse-down self event)
  (tell #:type _void (coerce-arg self) otherMouseDown: (coerce-arg event)))
(define (nsapplication-other-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) otherMouseDragged: (coerce-arg event)))
(define (nsapplication-other-mouse-up self event)
  (tell #:type _void (coerce-arg self) otherMouseUp: (coerce-arg event)))
(define (nsapplication-page-down self sender)
  (tell #:type _void (coerce-arg self) pageDown: (coerce-arg sender)))
(define (nsapplication-page-down-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageDownAndModifySelection: (coerce-arg sender)))
(define (nsapplication-page-up self sender)
  (tell #:type _void (coerce-arg self) pageUp: (coerce-arg sender)))
(define (nsapplication-page-up-and-modify-selection self sender)
  (tell #:type _void (coerce-arg self) pageUpAndModifySelection: (coerce-arg sender)))
(define (nsapplication-perform-key-equivalent! self event)
  (_msg-17 (coerce-arg self) (sel_registerName "performKeyEquivalent:") (coerce-arg event)))
(define (nsapplication-pressure-change-with-event self event)
  (tell #:type _void (coerce-arg self) pressureChangeWithEvent: (coerce-arg event)))
(define (nsapplication-prevent-window-ordering self)
  (tell #:type _void (coerce-arg self) preventWindowOrdering))
(define (nsapplication-quick-look-preview-items self sender)
  (tell #:type _void (coerce-arg self) quickLookPreviewItems: (coerce-arg sender)))
(define (nsapplication-quick-look-with-event self event)
  (tell #:type _void (coerce-arg self) quickLookWithEvent: (coerce-arg event)))
(define (nsapplication-reply-to-application-should-terminate self should-terminate)
  (_msg-15 (coerce-arg self) (sel_registerName "replyToApplicationShouldTerminate:") should-terminate))
(define (nsapplication-reply-to-open-or-print self reply)
  (_msg-34 (coerce-arg self) (sel_registerName "replyToOpenOrPrint:") reply))
(define (nsapplication-report-exception self exception)
  (tell #:type _void (coerce-arg self) reportException: (coerce-arg exception)))
(define (nsapplication-request-user-attention self request-type)
  (_msg-33 (coerce-arg self) (sel_registerName "requestUserAttention:") request-type))
(define (nsapplication-resign-first-responder self)
  (_msg-3 (coerce-arg self) (sel_registerName "resignFirstResponder")))
(define (nsapplication-restore-user-activity-state self user-activity)
  (tell #:type _void (coerce-arg self) restoreUserActivityState: (coerce-arg user-activity)))
(define (nsapplication-right-mouse-down self event)
  (tell #:type _void (coerce-arg self) rightMouseDown: (coerce-arg event)))
(define (nsapplication-right-mouse-dragged self event)
  (tell #:type _void (coerce-arg self) rightMouseDragged: (coerce-arg event)))
(define (nsapplication-right-mouse-up self event)
  (tell #:type _void (coerce-arg self) rightMouseUp: (coerce-arg event)))
(define (nsapplication-rotate-with-event self event)
  (tell #:type _void (coerce-arg self) rotateWithEvent: (coerce-arg event)))
(define (nsapplication-run self)
  (tell #:type _void (coerce-arg self) run))
(define (nsapplication-run-modal-for-window self window)
  (_msg-18 (coerce-arg self) (sel_registerName "runModalForWindow:") (coerce-arg window)))
(define (nsapplication-run-modal-session self session)
  (_msg-28 (coerce-arg self) (sel_registerName "runModalSession:") session))
(define (nsapplication-scroll-line-down self sender)
  (tell #:type _void (coerce-arg self) scrollLineDown: (coerce-arg sender)))
(define (nsapplication-scroll-line-up self sender)
  (tell #:type _void (coerce-arg self) scrollLineUp: (coerce-arg sender)))
(define (nsapplication-scroll-page-down self sender)
  (tell #:type _void (coerce-arg self) scrollPageDown: (coerce-arg sender)))
(define (nsapplication-scroll-page-up self sender)
  (tell #:type _void (coerce-arg self) scrollPageUp: (coerce-arg sender)))
(define (nsapplication-scroll-to-beginning-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToBeginningOfDocument: (coerce-arg sender)))
(define (nsapplication-scroll-to-end-of-document self sender)
  (tell #:type _void (coerce-arg self) scrollToEndOfDocument: (coerce-arg sender)))
(define (nsapplication-scroll-wheel self event)
  (tell #:type _void (coerce-arg self) scrollWheel: (coerce-arg event)))
(define (nsapplication-select-all self sender)
  (tell #:type _void (coerce-arg self) selectAll: (coerce-arg sender)))
(define (nsapplication-select-line self sender)
  (tell #:type _void (coerce-arg self) selectLine: (coerce-arg sender)))
(define (nsapplication-select-paragraph self sender)
  (tell #:type _void (coerce-arg self) selectParagraph: (coerce-arg sender)))
(define (nsapplication-select-to-mark self sender)
  (tell #:type _void (coerce-arg self) selectToMark: (coerce-arg sender)))
(define (nsapplication-select-word self sender)
  (tell #:type _void (coerce-arg self) selectWord: (coerce-arg sender)))
(define (nsapplication-set-accessibility-activation-point! self accessibility-activation-point)
  (_msg-9 (coerce-arg self) (sel_registerName "setAccessibilityActivationPoint:") accessibility-activation-point))
(define (nsapplication-set-accessibility-allowed-values! self accessibility-allowed-values)
  (tell #:type _void (coerce-arg self) setAccessibilityAllowedValues: (coerce-arg accessibility-allowed-values)))
(define (nsapplication-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (_msg-15 (coerce-arg self) (sel_registerName "setAccessibilityAlternateUIVisible:") accessibility-alternate-ui-visible))
(define (nsapplication-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityApplicationFocusedUIElement: (coerce-arg accessibility-application-focused-ui-element)))
(define (nsapplication-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityAttributedUserInputLabels: (coerce-arg accessibility-attributed-user-input-labels)))
(define (nsapplication-set-accessibility-cancel-button! self accessibility-cancel-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCancelButton: (coerce-arg accessibility-cancel-button)))
(define (nsapplication-set-accessibility-children! self accessibility-children)
  (tell #:type _void (coerce-arg self) setAccessibilityChildren: (coerce-arg accessibility-children)))
(define (nsapplication-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (tell #:type _void (coerce-arg self) setAccessibilityChildrenInNavigationOrder: (coerce-arg accessibility-children-in-navigation-order)))
(define (nsapplication-set-accessibility-clear-button! self accessibility-clear-button)
  (tell #:type _void (coerce-arg self) setAccessibilityClearButton: (coerce-arg accessibility-clear-button)))
(define (nsapplication-set-accessibility-close-button! self accessibility-close-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCloseButton: (coerce-arg accessibility-close-button)))
(define (nsapplication-set-accessibility-column-count! self accessibility-column-count)
  (_msg-24 (coerce-arg self) (sel_registerName "setAccessibilityColumnCount:") accessibility-column-count))
(define (nsapplication-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnHeaderUIElements: (coerce-arg accessibility-column-header-ui-elements)))
(define (nsapplication-set-accessibility-column-index-range! self accessibility-column-index-range)
  (_msg-12 (coerce-arg self) (sel_registerName "setAccessibilityColumnIndexRange:") accessibility-column-index-range))
(define (nsapplication-set-accessibility-column-titles! self accessibility-column-titles)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnTitles: (coerce-arg accessibility-column-titles)))
(define (nsapplication-set-accessibility-columns! self accessibility-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityColumns: (coerce-arg accessibility-columns)))
(define (nsapplication-set-accessibility-contents! self accessibility-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityContents: (coerce-arg accessibility-contents)))
(define (nsapplication-set-accessibility-critical-value! self accessibility-critical-value)
  (tell #:type _void (coerce-arg self) setAccessibilityCriticalValue: (coerce-arg accessibility-critical-value)))
(define (nsapplication-set-accessibility-custom-actions! self accessibility-custom-actions)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomActions: (coerce-arg accessibility-custom-actions)))
(define (nsapplication-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomRotors: (coerce-arg accessibility-custom-rotors)))
(define (nsapplication-set-accessibility-decrement-button! self accessibility-decrement-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDecrementButton: (coerce-arg accessibility-decrement-button)))
(define (nsapplication-set-accessibility-default-button! self accessibility-default-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDefaultButton: (coerce-arg accessibility-default-button)))
(define (nsapplication-set-accessibility-disclosed! self accessibility-disclosed)
  (_msg-15 (coerce-arg self) (sel_registerName "setAccessibilityDisclosed:") accessibility-disclosed))
(define (nsapplication-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedByRow: (coerce-arg accessibility-disclosed-by-row)))
(define (nsapplication-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedRows: (coerce-arg accessibility-disclosed-rows)))
(define (nsapplication-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (_msg-24 (coerce-arg self) (sel_registerName "setAccessibilityDisclosureLevel:") accessibility-disclosure-level))
(define (nsapplication-set-accessibility-document! self accessibility-document)
  (tell #:type _void (coerce-arg self) setAccessibilityDocument: (coerce-arg accessibility-document)))
(define (nsapplication-set-accessibility-edited! self accessibility-edited)
  (_msg-15 (coerce-arg self) (sel_registerName "setAccessibilityEdited:") accessibility-edited))
(define (nsapplication-set-accessibility-element! self accessibility-element)
  (_msg-15 (coerce-arg self) (sel_registerName "setAccessibilityElement:") accessibility-element))
(define (nsapplication-set-accessibility-enabled! self accessibility-enabled)
  (_msg-15 (coerce-arg self) (sel_registerName "setAccessibilityEnabled:") accessibility-enabled))
(define (nsapplication-set-accessibility-expanded! self accessibility-expanded)
  (_msg-15 (coerce-arg self) (sel_registerName "setAccessibilityExpanded:") accessibility-expanded))
(define (nsapplication-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityExtrasMenuBar: (coerce-arg accessibility-extras-menu-bar)))
(define (nsapplication-set-accessibility-filename! self accessibility-filename)
  (tell #:type _void (coerce-arg self) setAccessibilityFilename: (coerce-arg accessibility-filename)))
(define (nsapplication-set-accessibility-focused! self accessibility-focused)
  (_msg-15 (coerce-arg self) (sel_registerName "setAccessibilityFocused:") accessibility-focused))
(define (nsapplication-set-accessibility-focused-window! self accessibility-focused-window)
  (tell #:type _void (coerce-arg self) setAccessibilityFocusedWindow: (coerce-arg accessibility-focused-window)))
(define (nsapplication-set-accessibility-frame! self accessibility-frame)
  (_msg-13 (coerce-arg self) (sel_registerName "setAccessibilityFrame:") accessibility-frame))
(define (nsapplication-set-accessibility-frontmost! self accessibility-frontmost)
  (_msg-15 (coerce-arg self) (sel_registerName "setAccessibilityFrontmost:") accessibility-frontmost))
(define (nsapplication-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (tell #:type _void (coerce-arg self) setAccessibilityFullScreenButton: (coerce-arg accessibility-full-screen-button)))
(define (nsapplication-set-accessibility-grow-area! self accessibility-grow-area)
  (tell #:type _void (coerce-arg self) setAccessibilityGrowArea: (coerce-arg accessibility-grow-area)))
(define (nsapplication-set-accessibility-handles! self accessibility-handles)
  (tell #:type _void (coerce-arg self) setAccessibilityHandles: (coerce-arg accessibility-handles)))
(define (nsapplication-set-accessibility-header! self accessibility-header)
  (tell #:type _void (coerce-arg self) setAccessibilityHeader: (coerce-arg accessibility-header)))
(define (nsapplication-set-accessibility-help! self accessibility-help)
  (tell #:type _void (coerce-arg self) setAccessibilityHelp: (coerce-arg accessibility-help)))
(define (nsapplication-set-accessibility-hidden! self accessibility-hidden)
  (_msg-15 (coerce-arg self) (sel_registerName "setAccessibilityHidden:") accessibility-hidden))
(define (nsapplication-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalScrollBar: (coerce-arg accessibility-horizontal-scroll-bar)))
(define (nsapplication-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalUnitDescription: (coerce-arg accessibility-horizontal-unit-description)))
(define (nsapplication-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (_msg-24 (coerce-arg self) (sel_registerName "setAccessibilityHorizontalUnits:") accessibility-horizontal-units))
(define (nsapplication-set-accessibility-identifier! self accessibility-identifier)
  (tell #:type _void (coerce-arg self) setAccessibilityIdentifier: (coerce-arg accessibility-identifier)))
(define (nsapplication-set-accessibility-increment-button! self accessibility-increment-button)
  (tell #:type _void (coerce-arg self) setAccessibilityIncrementButton: (coerce-arg accessibility-increment-button)))
(define (nsapplication-set-accessibility-index! self accessibility-index)
  (_msg-24 (coerce-arg self) (sel_registerName "setAccessibilityIndex:") accessibility-index))
(define (nsapplication-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (_msg-24 (coerce-arg self) (sel_registerName "setAccessibilityInsertionPointLineNumber:") accessibility-insertion-point-line-number))
(define (nsapplication-set-accessibility-label! self accessibility-label)
  (tell #:type _void (coerce-arg self) setAccessibilityLabel: (coerce-arg accessibility-label)))
(define (nsapplication-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLabelUIElements: (coerce-arg accessibility-label-ui-elements)))
(define (nsapplication-set-accessibility-label-value! self accessibility-label-value)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityLabelValue:") accessibility-label-value))
(define (nsapplication-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLinkedUIElements: (coerce-arg accessibility-linked-ui-elements)))
(define (nsapplication-set-accessibility-main! self accessibility-main)
  (_msg-15 (coerce-arg self) (sel_registerName "setAccessibilityMain:") accessibility-main))
(define (nsapplication-set-accessibility-main-window! self accessibility-main-window)
  (tell #:type _void (coerce-arg self) setAccessibilityMainWindow: (coerce-arg accessibility-main-window)))
(define (nsapplication-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerGroupUIElement: (coerce-arg accessibility-marker-group-ui-element)))
(define (nsapplication-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerTypeDescription: (coerce-arg accessibility-marker-type-description)))
(define (nsapplication-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerUIElements: (coerce-arg accessibility-marker-ui-elements)))
(define (nsapplication-set-accessibility-marker-values! self accessibility-marker-values)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerValues: (coerce-arg accessibility-marker-values)))
(define (nsapplication-set-accessibility-max-value! self accessibility-max-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMaxValue: (coerce-arg accessibility-max-value)))
(define (nsapplication-set-accessibility-menu-bar! self accessibility-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityMenuBar: (coerce-arg accessibility-menu-bar)))
(define (nsapplication-set-accessibility-min-value! self accessibility-min-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMinValue: (coerce-arg accessibility-min-value)))
(define (nsapplication-set-accessibility-minimize-button! self accessibility-minimize-button)
  (tell #:type _void (coerce-arg self) setAccessibilityMinimizeButton: (coerce-arg accessibility-minimize-button)))
(define (nsapplication-set-accessibility-minimized! self accessibility-minimized)
  (_msg-15 (coerce-arg self) (sel_registerName "setAccessibilityMinimized:") accessibility-minimized))
(define (nsapplication-set-accessibility-modal! self accessibility-modal)
  (_msg-15 (coerce-arg self) (sel_registerName "setAccessibilityModal:") accessibility-modal))
(define (nsapplication-set-accessibility-next-contents! self accessibility-next-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityNextContents: (coerce-arg accessibility-next-contents)))
(define (nsapplication-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (_msg-24 (coerce-arg self) (sel_registerName "setAccessibilityNumberOfCharacters:") accessibility-number-of-characters))
(define (nsapplication-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (_msg-15 (coerce-arg self) (sel_registerName "setAccessibilityOrderedByRow:") accessibility-ordered-by-row))
(define (nsapplication-set-accessibility-orientation! self accessibility-orientation)
  (_msg-24 (coerce-arg self) (sel_registerName "setAccessibilityOrientation:") accessibility-orientation))
(define (nsapplication-set-accessibility-overflow-button! self accessibility-overflow-button)
  (tell #:type _void (coerce-arg self) setAccessibilityOverflowButton: (coerce-arg accessibility-overflow-button)))
(define (nsapplication-set-accessibility-parent! self accessibility-parent)
  (tell #:type _void (coerce-arg self) setAccessibilityParent: (coerce-arg accessibility-parent)))
(define (nsapplication-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (tell #:type _void (coerce-arg self) setAccessibilityPlaceholderValue: (coerce-arg accessibility-placeholder-value)))
(define (nsapplication-set-accessibility-previous-contents! self accessibility-previous-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityPreviousContents: (coerce-arg accessibility-previous-contents)))
(define (nsapplication-set-accessibility-protected-content! self accessibility-protected-content)
  (_msg-15 (coerce-arg self) (sel_registerName "setAccessibilityProtectedContent:") accessibility-protected-content))
(define (nsapplication-set-accessibility-proxy! self accessibility-proxy)
  (tell #:type _void (coerce-arg self) setAccessibilityProxy: (coerce-arg accessibility-proxy)))
(define (nsapplication-set-accessibility-required! self accessibility-required)
  (_msg-15 (coerce-arg self) (sel_registerName "setAccessibilityRequired:") accessibility-required))
(define (nsapplication-set-accessibility-role! self accessibility-role)
  (tell #:type _void (coerce-arg self) setAccessibilityRole: (coerce-arg accessibility-role)))
(define (nsapplication-set-accessibility-role-description! self accessibility-role-description)
  (tell #:type _void (coerce-arg self) setAccessibilityRoleDescription: (coerce-arg accessibility-role-description)))
(define (nsapplication-set-accessibility-row-count! self accessibility-row-count)
  (_msg-24 (coerce-arg self) (sel_registerName "setAccessibilityRowCount:") accessibility-row-count))
(define (nsapplication-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityRowHeaderUIElements: (coerce-arg accessibility-row-header-ui-elements)))
(define (nsapplication-set-accessibility-row-index-range! self accessibility-row-index-range)
  (_msg-12 (coerce-arg self) (sel_registerName "setAccessibilityRowIndexRange:") accessibility-row-index-range))
(define (nsapplication-set-accessibility-rows! self accessibility-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityRows: (coerce-arg accessibility-rows)))
(define (nsapplication-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (_msg-24 (coerce-arg self) (sel_registerName "setAccessibilityRulerMarkerType:") accessibility-ruler-marker-type))
(define (nsapplication-set-accessibility-search-button! self accessibility-search-button)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchButton: (coerce-arg accessibility-search-button)))
(define (nsapplication-set-accessibility-search-menu! self accessibility-search-menu)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchMenu: (coerce-arg accessibility-search-menu)))
(define (nsapplication-set-accessibility-selected! self accessibility-selected)
  (_msg-15 (coerce-arg self) (sel_registerName "setAccessibilitySelected:") accessibility-selected))
(define (nsapplication-set-accessibility-selected-cells! self accessibility-selected-cells)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedCells: (coerce-arg accessibility-selected-cells)))
(define (nsapplication-set-accessibility-selected-children! self accessibility-selected-children)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedChildren: (coerce-arg accessibility-selected-children)))
(define (nsapplication-set-accessibility-selected-columns! self accessibility-selected-columns)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedColumns: (coerce-arg accessibility-selected-columns)))
(define (nsapplication-set-accessibility-selected-rows! self accessibility-selected-rows)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedRows: (coerce-arg accessibility-selected-rows)))
(define (nsapplication-set-accessibility-selected-text! self accessibility-selected-text)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedText: (coerce-arg accessibility-selected-text)))
(define (nsapplication-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (_msg-12 (coerce-arg self) (sel_registerName "setAccessibilitySelectedTextRange:") accessibility-selected-text-range))
(define (nsapplication-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedTextRanges: (coerce-arg accessibility-selected-text-ranges)))
(define (nsapplication-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityServesAsTitleForUIElements: (coerce-arg accessibility-serves-as-title-for-ui-elements)))
(define (nsapplication-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (_msg-12 (coerce-arg self) (sel_registerName "setAccessibilitySharedCharacterRange:") accessibility-shared-character-range))
(define (nsapplication-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedFocusElements: (coerce-arg accessibility-shared-focus-elements)))
(define (nsapplication-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedTextUIElements: (coerce-arg accessibility-shared-text-ui-elements)))
(define (nsapplication-set-accessibility-shown-menu! self accessibility-shown-menu)
  (tell #:type _void (coerce-arg self) setAccessibilityShownMenu: (coerce-arg accessibility-shown-menu)))
(define (nsapplication-set-accessibility-sort-direction! self accessibility-sort-direction)
  (_msg-24 (coerce-arg self) (sel_registerName "setAccessibilitySortDirection:") accessibility-sort-direction))
(define (nsapplication-set-accessibility-splitters! self accessibility-splitters)
  (tell #:type _void (coerce-arg self) setAccessibilitySplitters: (coerce-arg accessibility-splitters)))
(define (nsapplication-set-accessibility-subrole! self accessibility-subrole)
  (tell #:type _void (coerce-arg self) setAccessibilitySubrole: (coerce-arg accessibility-subrole)))
(define (nsapplication-set-accessibility-tabs! self accessibility-tabs)
  (tell #:type _void (coerce-arg self) setAccessibilityTabs: (coerce-arg accessibility-tabs)))
(define (nsapplication-set-accessibility-title! self accessibility-title)
  (tell #:type _void (coerce-arg self) setAccessibilityTitle: (coerce-arg accessibility-title)))
(define (nsapplication-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTitleUIElement: (coerce-arg accessibility-title-ui-element)))
(define (nsapplication-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (tell #:type _void (coerce-arg self) setAccessibilityToolbarButton: (coerce-arg accessibility-toolbar-button)))
(define (nsapplication-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTopLevelUIElement: (coerce-arg accessibility-top-level-ui-element)))
(define (nsapplication-set-accessibility-url! self accessibility-url)
  (tell #:type _void (coerce-arg self) setAccessibilityURL: (coerce-arg accessibility-url)))
(define (nsapplication-set-accessibility-unit-description! self accessibility-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityUnitDescription: (coerce-arg accessibility-unit-description)))
(define (nsapplication-set-accessibility-units! self accessibility-units)
  (_msg-24 (coerce-arg self) (sel_registerName "setAccessibilityUnits:") accessibility-units))
(define (nsapplication-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityUserInputLabels: (coerce-arg accessibility-user-input-labels)))
(define (nsapplication-set-accessibility-value! self accessibility-value)
  (tell #:type _void (coerce-arg self) setAccessibilityValue: (coerce-arg accessibility-value)))
(define (nsapplication-set-accessibility-value-description! self accessibility-value-description)
  (tell #:type _void (coerce-arg self) setAccessibilityValueDescription: (coerce-arg accessibility-value-description)))
(define (nsapplication-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalScrollBar: (coerce-arg accessibility-vertical-scroll-bar)))
(define (nsapplication-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalUnitDescription: (coerce-arg accessibility-vertical-unit-description)))
(define (nsapplication-set-accessibility-vertical-units! self accessibility-vertical-units)
  (_msg-24 (coerce-arg self) (sel_registerName "setAccessibilityVerticalUnits:") accessibility-vertical-units))
(define (nsapplication-set-accessibility-visible-cells! self accessibility-visible-cells)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleCells: (coerce-arg accessibility-visible-cells)))
(define (nsapplication-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (_msg-12 (coerce-arg self) (sel_registerName "setAccessibilityVisibleCharacterRange:") accessibility-visible-character-range))
(define (nsapplication-set-accessibility-visible-children! self accessibility-visible-children)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleChildren: (coerce-arg accessibility-visible-children)))
(define (nsapplication-set-accessibility-visible-columns! self accessibility-visible-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleColumns: (coerce-arg accessibility-visible-columns)))
(define (nsapplication-set-accessibility-visible-rows! self accessibility-visible-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleRows: (coerce-arg accessibility-visible-rows)))
(define (nsapplication-set-accessibility-warning-value! self accessibility-warning-value)
  (tell #:type _void (coerce-arg self) setAccessibilityWarningValue: (coerce-arg accessibility-warning-value)))
(define (nsapplication-set-accessibility-window! self accessibility-window)
  (tell #:type _void (coerce-arg self) setAccessibilityWindow: (coerce-arg accessibility-window)))
(define (nsapplication-set-accessibility-windows! self accessibility-windows)
  (tell #:type _void (coerce-arg self) setAccessibilityWindows: (coerce-arg accessibility-windows)))
(define (nsapplication-set-accessibility-zoom-button! self accessibility-zoom-button)
  (tell #:type _void (coerce-arg self) setAccessibilityZoomButton: (coerce-arg accessibility-zoom-button)))
(define (nsapplication-set-activation-policy! self activation-policy)
  (_msg-21 (coerce-arg self) (sel_registerName "setActivationPolicy:") activation-policy))
(define (nsapplication-set-mark! self sender)
  (tell #:type _void (coerce-arg self) setMark: (coerce-arg sender)))
(define (nsapplication-set-windows-need-update! self need-update)
  (_msg-15 (coerce-arg self) (sel_registerName "setWindowsNeedUpdate:") need-update))
(define (nsapplication-should-be-treated-as-ink-event self event)
  (_msg-17 (coerce-arg self) (sel_registerName "shouldBeTreatedAsInkEvent:") (coerce-arg event)))
(define (nsapplication-show-context-help self sender)
  (tell #:type _void (coerce-arg self) showContextHelp: (coerce-arg sender)))
(define (nsapplication-show-context-menu-for-selection self sender)
  (tell #:type _void (coerce-arg self) showContextMenuForSelection: (coerce-arg sender)))
(define (nsapplication-smart-magnify-with-event self event)
  (tell #:type _void (coerce-arg self) smartMagnifyWithEvent: (coerce-arg event)))
(define (nsapplication-stop self sender)
  (tell #:type _void (coerce-arg self) stop: (coerce-arg sender)))
(define (nsapplication-stop-modal self)
  (tell #:type _void (coerce-arg self) stopModal))
(define (nsapplication-stop-modal-with-code self return-code)
  (_msg-24 (coerce-arg self) (sel_registerName "stopModalWithCode:") return-code))
(define (nsapplication-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (_msg-31 (coerce-arg self) (sel_registerName "supplementalTargetForAction:sender:") (sel_registerName action) (coerce-arg sender))
   ))
(define (nsapplication-swap-with-mark self sender)
  (tell #:type _void (coerce-arg self) swapWithMark: (coerce-arg sender)))
(define (nsapplication-swipe-with-event self event)
  (tell #:type _void (coerce-arg self) swipeWithEvent: (coerce-arg event)))
(define (nsapplication-tablet-point self event)
  (tell #:type _void (coerce-arg self) tabletPoint: (coerce-arg event)))
(define (nsapplication-tablet-proximity self event)
  (tell #:type _void (coerce-arg self) tabletProximity: (coerce-arg event)))
(define (nsapplication-terminate self sender)
  (tell #:type _void (coerce-arg self) terminate: (coerce-arg sender)))
(define (nsapplication-touches-began-with-event self event)
  (tell #:type _void (coerce-arg self) touchesBeganWithEvent: (coerce-arg event)))
(define (nsapplication-touches-cancelled-with-event self event)
  (tell #:type _void (coerce-arg self) touchesCancelledWithEvent: (coerce-arg event)))
(define (nsapplication-touches-ended-with-event self event)
  (tell #:type _void (coerce-arg self) touchesEndedWithEvent: (coerce-arg event)))
(define (nsapplication-touches-moved-with-event self event)
  (tell #:type _void (coerce-arg self) touchesMovedWithEvent: (coerce-arg event)))
(define (nsapplication-transpose self sender)
  (tell #:type _void (coerce-arg self) transpose: (coerce-arg sender)))
(define (nsapplication-transpose-words self sender)
  (tell #:type _void (coerce-arg self) transposeWords: (coerce-arg sender)))
(define (nsapplication-try-to-perform-with self action object)
  (_msg-30 (coerce-arg self) (sel_registerName "tryToPerform:with:") (sel_registerName action) (coerce-arg object)))
(define (nsapplication-unhide self sender)
  (tell #:type _void (coerce-arg self) unhide: (coerce-arg sender)))
(define (nsapplication-unhide-all-applications self sender)
  (tell #:type _void (coerce-arg self) unhideAllApplications: (coerce-arg sender)))
(define (nsapplication-unhide-without-activation self)
  (tell #:type _void (coerce-arg self) unhideWithoutActivation))
(define (nsapplication-update-windows self)
  (tell #:type _void (coerce-arg self) updateWindows))
(define (nsapplication-uppercase-word self sender)
  (tell #:type _void (coerce-arg self) uppercaseWord: (coerce-arg sender)))
(define (nsapplication-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (tell (coerce-arg self) validRequestorForSendType: (coerce-arg send-type) returnType: (coerce-arg return-type))))
(define (nsapplication-validate-menu-item self menu-item)
  (_msg-17 (coerce-arg self) (sel_registerName "validateMenuItem:") (coerce-arg menu-item)))
(define (nsapplication-validate-user-interface-item self item)
  (_msg-17 (coerce-arg self) (sel_registerName "validateUserInterfaceItem:") (coerce-arg item)))
(define (nsapplication-wants-forwarded-scroll-events-for-axis self axis)
  (_msg-21 (coerce-arg self) (sel_registerName "wantsForwardedScrollEventsForAxis:") axis))
(define (nsapplication-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (_msg-21 (coerce-arg self) (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:") axis))
(define (nsapplication-window-with-window-number self window-num)
  (wrap-objc-object
   (_msg-22 (coerce-arg self) (sel_registerName "windowWithWindowNumber:") window-num)
   ))
(define (nsapplication-yank self sender)
  (tell #:type _void (coerce-arg self) yank: (coerce-arg sender)))
(define (nsapplication-yield-activation-to-application self application)
  (tell #:type _void (coerce-arg self) yieldActivationToApplication: (coerce-arg application)))
(define (nsapplication-yield-activation-to-application-with-bundle-identifier self bundle-identifier)
  (tell #:type _void (coerce-arg self) yieldActivationToApplicationWithBundleIdentifier: (coerce-arg bundle-identifier)))

;; --- Class methods ---
(define (nsapplication-detach-drawing-thread-to-target-with-object selector target argument)
  (_msg-32 NSApplication (sel_registerName "detachDrawingThread:toTarget:withObject:") (sel_registerName selector) (coerce-arg target) (coerce-arg argument)))
(define (nsapplication-load-application)
  (tell #:type _void NSApplication loadApplication))
