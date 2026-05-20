#lang racket/base
;; Generated binding for NSMenuItem (AppKit)
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
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsattributedstring? v) (objc-instance-of? v "NSAttributedString"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsimage? v) (objc-instance-of? v "NSImage"))
(define (nsmenu? v) (objc-instance-of? v "NSMenu"))
(define (nsmenuitem? v) (objc-instance-of? v "NSMenuItem"))
(define (nsmenuitembadge? v) (objc-instance-of? v "NSMenuItemBadge"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (nsurl? v) (objc-instance-of? v "NSURL"))
(define (nsview? v) (objc-instance-of? v "NSView"))
(provide NSMenuItem)
(provide/contract
  [make-nsmenuitem-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsmenuitem-init-with-title-action-key-equivalent (c-> (or/c string? objc-object? #f) string? (or/c string? objc-object? #f) any/c)]
  [nsmenuitem-action (c-> nsmenuitem? cpointer?)]
  [nsmenuitem-set-action! (c-> nsmenuitem? string? void?)]
  [nsmenuitem-allows-automatic-key-equivalent-localization (c-> nsmenuitem? boolean?)]
  [nsmenuitem-set-allows-automatic-key-equivalent-localization! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-allows-automatic-key-equivalent-mirroring (c-> nsmenuitem? boolean?)]
  [nsmenuitem-set-allows-automatic-key-equivalent-mirroring! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-allows-key-equivalent-when-hidden (c-> nsmenuitem? boolean?)]
  [nsmenuitem-set-allows-key-equivalent-when-hidden! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-alternate (c-> nsmenuitem? boolean?)]
  [nsmenuitem-set-alternate! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-attributed-title (c-> nsmenuitem? (or/c nsattributedstring? objc-nil?))]
  [nsmenuitem-set-attributed-title! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-badge (c-> nsmenuitem? (or/c nsmenuitembadge? objc-nil?))]
  [nsmenuitem-set-badge! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-enabled (c-> nsmenuitem? boolean?)]
  [nsmenuitem-set-enabled! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-has-submenu (c-> nsmenuitem? boolean?)]
  [nsmenuitem-hidden (c-> nsmenuitem? boolean?)]
  [nsmenuitem-set-hidden! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-hidden-or-has-hidden-ancestor (c-> nsmenuitem? boolean?)]
  [nsmenuitem-highlighted (c-> nsmenuitem? boolean?)]
  [nsmenuitem-image (c-> nsmenuitem? (or/c nsimage? objc-nil?))]
  [nsmenuitem-set-image! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-indentation-level (c-> nsmenuitem? exact-integer?)]
  [nsmenuitem-set-indentation-level! (c-> nsmenuitem? exact-integer? void?)]
  [nsmenuitem-key-equivalent (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-set-key-equivalent! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-key-equivalent-modifier-mask (c-> nsmenuitem? exact-nonnegative-integer?)]
  [nsmenuitem-set-key-equivalent-modifier-mask! (c-> nsmenuitem? exact-nonnegative-integer? void?)]
  [nsmenuitem-menu (c-> nsmenuitem? (or/c nsmenu? objc-nil?))]
  [nsmenuitem-set-menu! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-mixed-state-image (c-> nsmenuitem? (or/c nsimage? objc-nil?))]
  [nsmenuitem-set-mixed-state-image! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-off-state-image (c-> nsmenuitem? (or/c nsimage? objc-nil?))]
  [nsmenuitem-set-off-state-image! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-on-state-image (c-> nsmenuitem? (or/c nsimage? objc-nil?))]
  [nsmenuitem-set-on-state-image! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-parent-item (c-> nsmenuitem? (or/c nsmenuitem? objc-nil?))]
  [nsmenuitem-represented-object (c-> nsmenuitem? any/c)]
  [nsmenuitem-set-represented-object! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-section-header (c-> nsmenuitem? boolean?)]
  [nsmenuitem-state (c-> nsmenuitem? exact-integer?)]
  [nsmenuitem-set-state! (c-> nsmenuitem? exact-integer? void?)]
  [nsmenuitem-submenu (c-> nsmenuitem? (or/c nsmenu? objc-nil?))]
  [nsmenuitem-set-submenu! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-subtitle (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-set-subtitle! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-tag (c-> nsmenuitem? exact-integer?)]
  [nsmenuitem-set-tag! (c-> nsmenuitem? exact-integer? void?)]
  [nsmenuitem-target (c-> nsmenuitem? any/c)]
  [nsmenuitem-set-target! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-title (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-set-title! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-tool-tip (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-set-tool-tip! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-user-key-equivalent (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-uses-user-key-equivalents (c-> boolean?)]
  [nsmenuitem-set-uses-user-key-equivalents! (c-> boolean? void?)]
  [nsmenuitem-view (c-> nsmenuitem? (or/c nsview? objc-nil?))]
  [nsmenuitem-set-view! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-writing-tools-items (c-> any/c)]
  [nsmenuitem-accessibility-activation-point (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-allowed-values (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-application-focused-ui-element (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-attributed-string-for-range (c-> nsmenuitem? any/c (or/c nsattributedstring? objc-nil?))]
  [nsmenuitem-accessibility-attributed-user-input-labels (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-cancel-button (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-cell-for-column-row (c-> nsmenuitem? exact-integer? exact-integer? any/c)]
  [nsmenuitem-accessibility-children (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-children-in-navigation-order (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-clear-button (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-close-button (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-column-count (c-> nsmenuitem? exact-integer?)]
  [nsmenuitem-accessibility-column-header-ui-elements (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-column-index-range (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-column-titles (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-columns (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-contents (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-critical-value (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-custom-actions (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-custom-rotors (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-decrement-button (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-default-button (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-disclosed-by-row (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-disclosed-rows (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-disclosure-level (c-> nsmenuitem? exact-integer?)]
  [nsmenuitem-accessibility-document (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-extras-menu-bar (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-filename (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-focused-window (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-frame (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-frame-for-range (c-> nsmenuitem? any/c any/c)]
  [nsmenuitem-accessibility-full-screen-button (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-grow-area (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-handles (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-header (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-help (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-horizontal-scroll-bar (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-horizontal-unit-description (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-horizontal-units (c-> nsmenuitem? exact-nonnegative-integer?)]
  [nsmenuitem-accessibility-identifier (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-increment-button (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-index (c-> nsmenuitem? exact-integer?)]
  [nsmenuitem-accessibility-insertion-point-line-number (c-> nsmenuitem? exact-integer?)]
  [nsmenuitem-accessibility-label (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-label-ui-elements (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-label-value (c-> nsmenuitem? real?)]
  [nsmenuitem-accessibility-layout-point-for-screen-point (c-> nsmenuitem? any/c any/c)]
  [nsmenuitem-accessibility-layout-size-for-screen-size (c-> nsmenuitem? any/c any/c)]
  [nsmenuitem-accessibility-line-for-index (c-> nsmenuitem? exact-integer? exact-integer?)]
  [nsmenuitem-accessibility-linked-ui-elements (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-main-window (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-marker-group-ui-element (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-marker-type-description (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-marker-ui-elements (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-marker-values (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-max-value (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-menu-bar (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-min-value (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-minimize-button (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-next-contents (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-number-of-characters (c-> nsmenuitem? exact-integer?)]
  [nsmenuitem-accessibility-orientation (c-> nsmenuitem? exact-nonnegative-integer?)]
  [nsmenuitem-accessibility-overflow-button (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-parent (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-perform-cancel (c-> nsmenuitem? boolean?)]
  [nsmenuitem-accessibility-perform-confirm (c-> nsmenuitem? boolean?)]
  [nsmenuitem-accessibility-perform-decrement (c-> nsmenuitem? boolean?)]
  [nsmenuitem-accessibility-perform-delete (c-> nsmenuitem? boolean?)]
  [nsmenuitem-accessibility-perform-increment (c-> nsmenuitem? boolean?)]
  [nsmenuitem-accessibility-perform-pick (c-> nsmenuitem? boolean?)]
  [nsmenuitem-accessibility-perform-press (c-> nsmenuitem? boolean?)]
  [nsmenuitem-accessibility-perform-raise (c-> nsmenuitem? boolean?)]
  [nsmenuitem-accessibility-perform-show-alternate-ui (c-> nsmenuitem? boolean?)]
  [nsmenuitem-accessibility-perform-show-default-ui (c-> nsmenuitem? boolean?)]
  [nsmenuitem-accessibility-perform-show-menu (c-> nsmenuitem? boolean?)]
  [nsmenuitem-accessibility-placeholder-value (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-previous-contents (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-proxy (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-rtf-for-range (c-> nsmenuitem? any/c (or/c nsdata? objc-nil?))]
  [nsmenuitem-accessibility-range-for-index (c-> nsmenuitem? exact-integer? any/c)]
  [nsmenuitem-accessibility-range-for-line (c-> nsmenuitem? exact-integer? any/c)]
  [nsmenuitem-accessibility-range-for-position (c-> nsmenuitem? any/c any/c)]
  [nsmenuitem-accessibility-role (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-role-description (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-row-count (c-> nsmenuitem? exact-integer?)]
  [nsmenuitem-accessibility-row-header-ui-elements (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-row-index-range (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-rows (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-ruler-marker-type (c-> nsmenuitem? exact-nonnegative-integer?)]
  [nsmenuitem-accessibility-screen-point-for-layout-point (c-> nsmenuitem? any/c any/c)]
  [nsmenuitem-accessibility-screen-size-for-layout-size (c-> nsmenuitem? any/c any/c)]
  [nsmenuitem-accessibility-search-button (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-search-menu (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-selected-cells (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-selected-children (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-selected-columns (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-selected-rows (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-selected-text (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-selected-text-range (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-selected-text-ranges (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-serves-as-title-for-ui-elements (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-shared-character-range (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-shared-focus-elements (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-shared-text-ui-elements (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-shown-menu (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-sort-direction (c-> nsmenuitem? exact-nonnegative-integer?)]
  [nsmenuitem-accessibility-splitters (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-string-for-range (c-> nsmenuitem? any/c (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-style-range-for-index (c-> nsmenuitem? exact-integer? any/c)]
  [nsmenuitem-accessibility-subrole (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-tabs (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-title (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-title-ui-element (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-toolbar-button (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-top-level-ui-element (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-url (c-> nsmenuitem? (or/c nsurl? objc-nil?))]
  [nsmenuitem-accessibility-unit-description (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-units (c-> nsmenuitem? exact-nonnegative-integer?)]
  [nsmenuitem-accessibility-user-input-labels (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-value (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-value-description (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-vertical-scroll-bar (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-vertical-unit-description (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-vertical-units (c-> nsmenuitem? exact-nonnegative-integer?)]
  [nsmenuitem-accessibility-visible-cells (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-visible-character-range (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-visible-children (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-visible-columns (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-visible-rows (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-warning-value (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-window (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-windows (c-> nsmenuitem? (or/c nsarray? objc-nil?))]
  [nsmenuitem-accessibility-zoom-button (c-> nsmenuitem? any/c)]
  [nsmenuitem-copy-with-zone (c-> nsmenuitem? (or/c cpointer? #f) any/c)]
  [nsmenuitem-encode-with-coder (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-identifier (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-is-accessibility-alternate-ui-visible (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-accessibility-disclosed (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-accessibility-edited (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-accessibility-element (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-accessibility-enabled (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-accessibility-expanded (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-accessibility-focused (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-accessibility-frontmost (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-accessibility-hidden (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-accessibility-main (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-accessibility-minimized (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-accessibility-modal (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-accessibility-ordered-by-row (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-accessibility-protected-content (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-accessibility-required (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-accessibility-selected (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-accessibility-selector-allowed (c-> nsmenuitem? string? boolean?)]
  [nsmenuitem-is-alternate (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-enabled (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-hidden (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-hidden-or-has-hidden-ancestor (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-highlighted (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-section-header (c-> nsmenuitem? boolean?)]
  [nsmenuitem-is-separator-item (c-> nsmenuitem? boolean?)]
  [nsmenuitem-set-accessibility-activation-point! (c-> nsmenuitem? any/c void?)]
  [nsmenuitem-set-accessibility-allowed-values! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-alternate-ui-visible! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-set-accessibility-application-focused-ui-element! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-attributed-user-input-labels! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-cancel-button! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-children! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-children-in-navigation-order! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-clear-button! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-close-button! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-column-count! (c-> nsmenuitem? exact-integer? void?)]
  [nsmenuitem-set-accessibility-column-header-ui-elements! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-column-index-range! (c-> nsmenuitem? any/c void?)]
  [nsmenuitem-set-accessibility-column-titles! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-columns! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-contents! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-critical-value! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-custom-actions! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-custom-rotors! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-decrement-button! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-default-button! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-disclosed! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-set-accessibility-disclosed-by-row! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-disclosed-rows! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-disclosure-level! (c-> nsmenuitem? exact-integer? void?)]
  [nsmenuitem-set-accessibility-document! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-edited! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-set-accessibility-element! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-set-accessibility-enabled! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-set-accessibility-expanded! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-set-accessibility-extras-menu-bar! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-filename! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-focused! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-set-accessibility-focused-window! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-frame! (c-> nsmenuitem? any/c void?)]
  [nsmenuitem-set-accessibility-frontmost! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-set-accessibility-full-screen-button! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-grow-area! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-handles! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-header! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-help! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-hidden! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-set-accessibility-horizontal-scroll-bar! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-horizontal-unit-description! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-horizontal-units! (c-> nsmenuitem? exact-nonnegative-integer? void?)]
  [nsmenuitem-set-accessibility-identifier! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-increment-button! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-index! (c-> nsmenuitem? exact-integer? void?)]
  [nsmenuitem-set-accessibility-insertion-point-line-number! (c-> nsmenuitem? exact-integer? void?)]
  [nsmenuitem-set-accessibility-label! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-label-ui-elements! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-label-value! (c-> nsmenuitem? real? void?)]
  [nsmenuitem-set-accessibility-linked-ui-elements! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-main! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-set-accessibility-main-window! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-marker-group-ui-element! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-marker-type-description! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-marker-ui-elements! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-marker-values! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-max-value! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-menu-bar! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-min-value! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-minimize-button! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-minimized! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-set-accessibility-modal! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-set-accessibility-next-contents! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-number-of-characters! (c-> nsmenuitem? exact-integer? void?)]
  [nsmenuitem-set-accessibility-ordered-by-row! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-set-accessibility-orientation! (c-> nsmenuitem? exact-nonnegative-integer? void?)]
  [nsmenuitem-set-accessibility-overflow-button! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-parent! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-placeholder-value! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-previous-contents! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-protected-content! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-set-accessibility-proxy! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-required! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-set-accessibility-role! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-role-description! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-row-count! (c-> nsmenuitem? exact-integer? void?)]
  [nsmenuitem-set-accessibility-row-header-ui-elements! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-row-index-range! (c-> nsmenuitem? any/c void?)]
  [nsmenuitem-set-accessibility-rows! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-ruler-marker-type! (c-> nsmenuitem? exact-nonnegative-integer? void?)]
  [nsmenuitem-set-accessibility-search-button! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-search-menu! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-selected! (c-> nsmenuitem? boolean? void?)]
  [nsmenuitem-set-accessibility-selected-cells! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-selected-children! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-selected-columns! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-selected-rows! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-selected-text! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-selected-text-range! (c-> nsmenuitem? any/c void?)]
  [nsmenuitem-set-accessibility-selected-text-ranges! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-serves-as-title-for-ui-elements! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-shared-character-range! (c-> nsmenuitem? any/c void?)]
  [nsmenuitem-set-accessibility-shared-focus-elements! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-shared-text-ui-elements! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-shown-menu! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-sort-direction! (c-> nsmenuitem? exact-nonnegative-integer? void?)]
  [nsmenuitem-set-accessibility-splitters! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-subrole! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-tabs! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-title! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-title-ui-element! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-toolbar-button! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-top-level-ui-element! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-url! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-unit-description! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-units! (c-> nsmenuitem? exact-nonnegative-integer? void?)]
  [nsmenuitem-set-accessibility-user-input-labels! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-value! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-value-description! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-vertical-scroll-bar! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-vertical-unit-description! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-vertical-units! (c-> nsmenuitem? exact-nonnegative-integer? void?)]
  [nsmenuitem-set-accessibility-visible-cells! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-visible-character-range! (c-> nsmenuitem? any/c void?)]
  [nsmenuitem-set-accessibility-visible-children! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-visible-columns! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-visible-rows! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-warning-value! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-window! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-windows! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-zoom-button! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-identifier! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-section-header-with-title (c-> (or/c string? objc-object? #f) any/c)]
  [nsmenuitem-separator-item (c-> (or/c nsmenuitem? objc-nil?))]
  )

;; --- Class reference ---
(import-class NSMenuItem)

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
(define _msg-6  ; (_fun _pointer _pointer -> _pointer)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _pointer)))
(define _msg-7  ; (_fun _pointer _pointer -> _uint64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer -> _uint64)))
(define _msg-8  ; (_fun _pointer _pointer _NSPoint -> _NSPoint)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _NSPoint)))
(define _msg-9  ; (_fun _pointer _pointer _NSPoint -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _NSRange)))
(define _msg-10  ; (_fun _pointer _pointer _NSPoint -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSPoint -> _void)))
(define _msg-11  ; (_fun _pointer _pointer _NSRange -> _NSRect)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _NSRect)))
(define _msg-12  ; (_fun _pointer _pointer _NSRange -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _id)))
(define _msg-13  ; (_fun _pointer _pointer _NSRange -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRange -> _void)))
(define _msg-14  ; (_fun _pointer _pointer _NSRect -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSRect -> _void)))
(define _msg-15  ; (_fun _pointer _pointer _NSSize -> _NSSize)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _NSSize -> _NSSize)))
(define _msg-16  ; (_fun _pointer _pointer _bool -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _bool -> _void)))
(define _msg-17  ; (_fun _pointer _pointer _float -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _float -> _void)))
(define _msg-18  ; (_fun _pointer _pointer _id _pointer _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer _id -> _id)))
(define _msg-19  ; (_fun _pointer _pointer _int64 -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _NSRange)))
(define _msg-20  ; (_fun _pointer _pointer _int64 -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _int64)))
(define _msg-21  ; (_fun _pointer _pointer _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _void)))
(define _msg-22  ; (_fun _pointer _pointer _int64 _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _int64 -> _id)))
(define _msg-23  ; (_fun _pointer _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _bool)))
(define _msg-24  ; (_fun _pointer _pointer _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _id)))
(define _msg-25  ; (_fun _pointer _pointer _pointer -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _void)))
(define _msg-26  ; (_fun _pointer _pointer _uint64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _uint64 -> _void)))

;; --- Constructors ---
(define (make-nsmenuitem-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSMenuItem alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nsmenuitem-init-with-title-action-key-equivalent string selector char-code)
  (wrap-objc-object
   (_msg-18 (tell NSMenuItem alloc)
       (sel_registerName "initWithTitle:action:keyEquivalent:")
       (coerce-arg string)
       (sel_registerName selector)
       (coerce-arg char-code))
   #:retained #t))


;; --- Properties ---
(define (nsmenuitem-action self)
  (tell #:type _pointer (coerce-arg self) action))
(define (nsmenuitem-set-action! self value)
  (_msg-25 (coerce-arg self) (sel_registerName "setAction:") (sel_registerName value)))
(define (nsmenuitem-allows-automatic-key-equivalent-localization self)
  (tell #:type _bool (coerce-arg self) allowsAutomaticKeyEquivalentLocalization))
(define (nsmenuitem-set-allows-automatic-key-equivalent-localization! self value)
  (_msg-16 (coerce-arg self) (sel_registerName "setAllowsAutomaticKeyEquivalentLocalization:") value))
(define (nsmenuitem-allows-automatic-key-equivalent-mirroring self)
  (tell #:type _bool (coerce-arg self) allowsAutomaticKeyEquivalentMirroring))
(define (nsmenuitem-set-allows-automatic-key-equivalent-mirroring! self value)
  (_msg-16 (coerce-arg self) (sel_registerName "setAllowsAutomaticKeyEquivalentMirroring:") value))
(define (nsmenuitem-allows-key-equivalent-when-hidden self)
  (tell #:type _bool (coerce-arg self) allowsKeyEquivalentWhenHidden))
(define (nsmenuitem-set-allows-key-equivalent-when-hidden! self value)
  (_msg-16 (coerce-arg self) (sel_registerName "setAllowsKeyEquivalentWhenHidden:") value))
(define (nsmenuitem-alternate self)
  (tell #:type _bool (coerce-arg self) alternate))
(define (nsmenuitem-set-alternate! self value)
  (_msg-16 (coerce-arg self) (sel_registerName "setAlternate:") value))
(define (nsmenuitem-attributed-title self)
  (wrap-objc-object
   (tell (coerce-arg self) attributedTitle)))
(define (nsmenuitem-set-attributed-title! self value)
  (tell #:type _void (coerce-arg self) setAttributedTitle: (coerce-arg value)))
(define (nsmenuitem-badge self)
  (wrap-objc-object
   (tell (coerce-arg self) badge)))
(define (nsmenuitem-set-badge! self value)
  (tell #:type _void (coerce-arg self) setBadge: (coerce-arg value)))
(define (nsmenuitem-enabled self)
  (tell #:type _bool (coerce-arg self) enabled))
(define (nsmenuitem-set-enabled! self value)
  (_msg-16 (coerce-arg self) (sel_registerName "setEnabled:") value))
(define (nsmenuitem-has-submenu self)
  (tell #:type _bool (coerce-arg self) hasSubmenu))
(define (nsmenuitem-hidden self)
  (tell #:type _bool (coerce-arg self) hidden))
(define (nsmenuitem-set-hidden! self value)
  (_msg-16 (coerce-arg self) (sel_registerName "setHidden:") value))
(define (nsmenuitem-hidden-or-has-hidden-ancestor self)
  (tell #:type _bool (coerce-arg self) hiddenOrHasHiddenAncestor))
(define (nsmenuitem-highlighted self)
  (tell #:type _bool (coerce-arg self) highlighted))
(define (nsmenuitem-image self)
  (wrap-objc-object
   (tell (coerce-arg self) image)))
(define (nsmenuitem-set-image! self value)
  (tell #:type _void (coerce-arg self) setImage: (coerce-arg value)))
(define (nsmenuitem-indentation-level self)
  (tell #:type _int64 (coerce-arg self) indentationLevel))
(define (nsmenuitem-set-indentation-level! self value)
  (_msg-21 (coerce-arg self) (sel_registerName "setIndentationLevel:") value))
(define (nsmenuitem-key-equivalent self)
  (wrap-objc-object
   (tell (coerce-arg self) keyEquivalent)))
(define (nsmenuitem-set-key-equivalent! self value)
  (tell #:type _void (coerce-arg self) setKeyEquivalent: (coerce-arg value)))
(define (nsmenuitem-key-equivalent-modifier-mask self)
  (tell #:type _uint64 (coerce-arg self) keyEquivalentModifierMask))
(define (nsmenuitem-set-key-equivalent-modifier-mask! self value)
  (_msg-26 (coerce-arg self) (sel_registerName "setKeyEquivalentModifierMask:") value))
(define (nsmenuitem-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) menu)))
(define (nsmenuitem-set-menu! self value)
  (tell #:type _void (coerce-arg self) setMenu: (coerce-arg value)))
(define (nsmenuitem-mixed-state-image self)
  (wrap-objc-object
   (tell (coerce-arg self) mixedStateImage)))
(define (nsmenuitem-set-mixed-state-image! self value)
  (tell #:type _void (coerce-arg self) setMixedStateImage: (coerce-arg value)))
(define (nsmenuitem-off-state-image self)
  (wrap-objc-object
   (tell (coerce-arg self) offStateImage)))
(define (nsmenuitem-set-off-state-image! self value)
  (tell #:type _void (coerce-arg self) setOffStateImage: (coerce-arg value)))
(define (nsmenuitem-on-state-image self)
  (wrap-objc-object
   (tell (coerce-arg self) onStateImage)))
(define (nsmenuitem-set-on-state-image! self value)
  (tell #:type _void (coerce-arg self) setOnStateImage: (coerce-arg value)))
(define (nsmenuitem-parent-item self)
  (wrap-objc-object
   (tell (coerce-arg self) parentItem)))
(define (nsmenuitem-represented-object self)
  (wrap-objc-object
   (tell (coerce-arg self) representedObject)))
(define (nsmenuitem-set-represented-object! self value)
  (tell #:type _void (coerce-arg self) setRepresentedObject: (coerce-arg value)))
(define (nsmenuitem-section-header self)
  (tell #:type _bool (coerce-arg self) sectionHeader))
(define (nsmenuitem-state self)
  (tell #:type _int64 (coerce-arg self) state))
(define (nsmenuitem-set-state! self value)
  (_msg-21 (coerce-arg self) (sel_registerName "setState:") value))
(define (nsmenuitem-submenu self)
  (wrap-objc-object
   (tell (coerce-arg self) submenu)))
(define (nsmenuitem-set-submenu! self value)
  (tell #:type _void (coerce-arg self) setSubmenu: (coerce-arg value)))
(define (nsmenuitem-subtitle self)
  (wrap-objc-object
   (tell (coerce-arg self) subtitle)))
(define (nsmenuitem-set-subtitle! self value)
  (tell #:type _void (coerce-arg self) setSubtitle: (coerce-arg value)))
(define (nsmenuitem-tag self)
  (tell #:type _int64 (coerce-arg self) tag))
(define (nsmenuitem-set-tag! self value)
  (_msg-21 (coerce-arg self) (sel_registerName "setTag:") value))
(define (nsmenuitem-target self)
  (wrap-objc-object
   (tell (coerce-arg self) target)))
(define (nsmenuitem-set-target! self value)
  (tell #:type _void (coerce-arg self) setTarget: (coerce-arg value)))
(define (nsmenuitem-title self)
  (wrap-objc-object
   (tell (coerce-arg self) title)))
(define (nsmenuitem-set-title! self value)
  (tell #:type _void (coerce-arg self) setTitle: (coerce-arg value)))
(define (nsmenuitem-tool-tip self)
  (wrap-objc-object
   (tell (coerce-arg self) toolTip)))
(define (nsmenuitem-set-tool-tip! self value)
  (tell #:type _void (coerce-arg self) setToolTip: (coerce-arg value)))
(define (nsmenuitem-user-key-equivalent self)
  (wrap-objc-object
   (tell (coerce-arg self) userKeyEquivalent)))
(define (nsmenuitem-uses-user-key-equivalents)
  (tell #:type _bool NSMenuItem usesUserKeyEquivalents))
(define (nsmenuitem-set-uses-user-key-equivalents! value)
  (_msg-16 NSMenuItem (sel_registerName "setUsesUserKeyEquivalents:") value))
(define (nsmenuitem-view self)
  (wrap-objc-object
   (tell (coerce-arg self) view)))
(define (nsmenuitem-set-view! self value)
  (tell #:type _void (coerce-arg self) setView: (coerce-arg value)))
(define (nsmenuitem-writing-tools-items)
  (wrap-objc-object
   (tell NSMenuItem writingToolsItems)))

;; --- Instance methods ---
(define (nsmenuitem-accessibility-activation-point self)
  (_msg-0 (coerce-arg self) (sel_registerName "accessibilityActivationPoint")))
(define (nsmenuitem-accessibility-allowed-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAllowedValues)))
(define (nsmenuitem-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityApplicationFocusedUIElement)))
(define (nsmenuitem-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (_msg-12 (coerce-arg self) (sel_registerName "accessibilityAttributedStringForRange:") range)
   ))
(define (nsmenuitem-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAttributedUserInputLabels)))
(define (nsmenuitem-accessibility-cancel-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCancelButton)))
(define (nsmenuitem-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (_msg-22 (coerce-arg self) (sel_registerName "accessibilityCellForColumn:row:") column row)
   ))
(define (nsmenuitem-accessibility-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildren)))
(define (nsmenuitem-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildrenInNavigationOrder)))
(define (nsmenuitem-accessibility-clear-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityClearButton)))
(define (nsmenuitem-accessibility-close-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCloseButton)))
(define (nsmenuitem-accessibility-column-count self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityColumnCount")))
(define (nsmenuitem-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnHeaderUIElements)))
(define (nsmenuitem-accessibility-column-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityColumnIndexRange")))
(define (nsmenuitem-accessibility-column-titles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnTitles)))
(define (nsmenuitem-accessibility-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumns)))
(define (nsmenuitem-accessibility-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityContents)))
(define (nsmenuitem-accessibility-critical-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCriticalValue)))
(define (nsmenuitem-accessibility-custom-actions self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomActions)))
(define (nsmenuitem-accessibility-custom-rotors self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomRotors)))
(define (nsmenuitem-accessibility-decrement-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDecrementButton)))
(define (nsmenuitem-accessibility-default-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDefaultButton)))
(define (nsmenuitem-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedByRow)))
(define (nsmenuitem-accessibility-disclosed-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedRows)))
(define (nsmenuitem-accessibility-disclosure-level self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityDisclosureLevel")))
(define (nsmenuitem-accessibility-document self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDocument)))
(define (nsmenuitem-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityExtrasMenuBar)))
(define (nsmenuitem-accessibility-filename self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFilename)))
(define (nsmenuitem-accessibility-focused-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFocusedWindow)))
(define (nsmenuitem-accessibility-frame self)
  (_msg-2 (coerce-arg self) (sel_registerName "accessibilityFrame")))
(define (nsmenuitem-accessibility-frame-for-range self range)
  (_msg-11 (coerce-arg self) (sel_registerName "accessibilityFrameForRange:") range))
(define (nsmenuitem-accessibility-full-screen-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFullScreenButton)))
(define (nsmenuitem-accessibility-grow-area self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityGrowArea)))
(define (nsmenuitem-accessibility-handles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHandles)))
(define (nsmenuitem-accessibility-header self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHeader)))
(define (nsmenuitem-accessibility-help self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHelp)))
(define (nsmenuitem-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalScrollBar)))
(define (nsmenuitem-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalUnitDescription)))
(define (nsmenuitem-accessibility-horizontal-units self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityHorizontalUnits")))
(define (nsmenuitem-accessibility-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIdentifier)))
(define (nsmenuitem-accessibility-increment-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIncrementButton)))
(define (nsmenuitem-accessibility-index self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityIndex")))
(define (nsmenuitem-accessibility-insertion-point-line-number self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityInsertionPointLineNumber")))
(define (nsmenuitem-accessibility-label self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabel)))
(define (nsmenuitem-accessibility-label-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabelUIElements)))
(define (nsmenuitem-accessibility-label-value self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityLabelValue")))
(define (nsmenuitem-accessibility-layout-point-for-screen-point self point)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityLayoutPointForScreenPoint:") point))
(define (nsmenuitem-accessibility-layout-size-for-screen-size self size)
  (_msg-15 (coerce-arg self) (sel_registerName "accessibilityLayoutSizeForScreenSize:") size))
(define (nsmenuitem-accessibility-line-for-index self index)
  (_msg-20 (coerce-arg self) (sel_registerName "accessibilityLineForIndex:") index))
(define (nsmenuitem-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLinkedUIElements)))
(define (nsmenuitem-accessibility-main-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMainWindow)))
(define (nsmenuitem-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerGroupUIElement)))
(define (nsmenuitem-accessibility-marker-type-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerTypeDescription)))
(define (nsmenuitem-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerUIElements)))
(define (nsmenuitem-accessibility-marker-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerValues)))
(define (nsmenuitem-accessibility-max-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMaxValue)))
(define (nsmenuitem-accessibility-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMenuBar)))
(define (nsmenuitem-accessibility-min-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinValue)))
(define (nsmenuitem-accessibility-minimize-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinimizeButton)))
(define (nsmenuitem-accessibility-next-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityNextContents)))
(define (nsmenuitem-accessibility-number-of-characters self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityNumberOfCharacters")))
(define (nsmenuitem-accessibility-orientation self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityOrientation")))
(define (nsmenuitem-accessibility-overflow-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityOverflowButton)))
(define (nsmenuitem-accessibility-parent self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityParent)))
(define (nsmenuitem-accessibility-perform-cancel self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformCancel")))
(define (nsmenuitem-accessibility-perform-confirm self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformConfirm")))
(define (nsmenuitem-accessibility-perform-decrement self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformDecrement")))
(define (nsmenuitem-accessibility-perform-delete self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformDelete")))
(define (nsmenuitem-accessibility-perform-increment self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformIncrement")))
(define (nsmenuitem-accessibility-perform-pick self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformPick")))
(define (nsmenuitem-accessibility-perform-press self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformPress")))
(define (nsmenuitem-accessibility-perform-raise self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformRaise")))
(define (nsmenuitem-accessibility-perform-show-alternate-ui self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowAlternateUI")))
(define (nsmenuitem-accessibility-perform-show-default-ui self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowDefaultUI")))
(define (nsmenuitem-accessibility-perform-show-menu self)
  (_msg-3 (coerce-arg self) (sel_registerName "accessibilityPerformShowMenu")))
(define (nsmenuitem-accessibility-placeholder-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPlaceholderValue)))
(define (nsmenuitem-accessibility-previous-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPreviousContents)))
(define (nsmenuitem-accessibility-proxy self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityProxy)))
(define (nsmenuitem-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (_msg-12 (coerce-arg self) (sel_registerName "accessibilityRTFForRange:") range)
   ))
(define (nsmenuitem-accessibility-range-for-index self index)
  (_msg-19 (coerce-arg self) (sel_registerName "accessibilityRangeForIndex:") index))
(define (nsmenuitem-accessibility-range-for-line self line)
  (_msg-19 (coerce-arg self) (sel_registerName "accessibilityRangeForLine:") line))
(define (nsmenuitem-accessibility-range-for-position self point)
  (_msg-9 (coerce-arg self) (sel_registerName "accessibilityRangeForPosition:") point))
(define (nsmenuitem-accessibility-role self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRole)))
(define (nsmenuitem-accessibility-role-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRoleDescription)))
(define (nsmenuitem-accessibility-row-count self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityRowCount")))
(define (nsmenuitem-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRowHeaderUIElements)))
(define (nsmenuitem-accessibility-row-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityRowIndexRange")))
(define (nsmenuitem-accessibility-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRows)))
(define (nsmenuitem-accessibility-ruler-marker-type self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityRulerMarkerType")))
(define (nsmenuitem-accessibility-screen-point-for-layout-point self point)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityScreenPointForLayoutPoint:") point))
(define (nsmenuitem-accessibility-screen-size-for-layout-size self size)
  (_msg-15 (coerce-arg self) (sel_registerName "accessibilityScreenSizeForLayoutSize:") size))
(define (nsmenuitem-accessibility-search-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchButton)))
(define (nsmenuitem-accessibility-search-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchMenu)))
(define (nsmenuitem-accessibility-selected-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedCells)))
(define (nsmenuitem-accessibility-selected-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedChildren)))
(define (nsmenuitem-accessibility-selected-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedColumns)))
(define (nsmenuitem-accessibility-selected-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedRows)))
(define (nsmenuitem-accessibility-selected-text self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedText)))
(define (nsmenuitem-accessibility-selected-text-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySelectedTextRange")))
(define (nsmenuitem-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedTextRanges)))
(define (nsmenuitem-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityServesAsTitleForUIElements)))
(define (nsmenuitem-accessibility-shared-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySharedCharacterRange")))
(define (nsmenuitem-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedFocusElements)))
(define (nsmenuitem-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedTextUIElements)))
(define (nsmenuitem-accessibility-shown-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityShownMenu)))
(define (nsmenuitem-accessibility-sort-direction self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilitySortDirection")))
(define (nsmenuitem-accessibility-splitters self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySplitters)))
(define (nsmenuitem-accessibility-string-for-range self range)
  (wrap-objc-object
   (_msg-12 (coerce-arg self) (sel_registerName "accessibilityStringForRange:") range)
   ))
(define (nsmenuitem-accessibility-style-range-for-index self index)
  (_msg-19 (coerce-arg self) (sel_registerName "accessibilityStyleRangeForIndex:") index))
(define (nsmenuitem-accessibility-subrole self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySubrole)))
(define (nsmenuitem-accessibility-tabs self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTabs)))
(define (nsmenuitem-accessibility-title self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitle)))
(define (nsmenuitem-accessibility-title-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitleUIElement)))
(define (nsmenuitem-accessibility-toolbar-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityToolbarButton)))
(define (nsmenuitem-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTopLevelUIElement)))
(define (nsmenuitem-accessibility-url self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityURL)))
(define (nsmenuitem-accessibility-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUnitDescription)))
(define (nsmenuitem-accessibility-units self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityUnits")))
(define (nsmenuitem-accessibility-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUserInputLabels)))
(define (nsmenuitem-accessibility-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValue)))
(define (nsmenuitem-accessibility-value-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValueDescription)))
(define (nsmenuitem-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalScrollBar)))
(define (nsmenuitem-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalUnitDescription)))
(define (nsmenuitem-accessibility-vertical-units self)
  (_msg-5 (coerce-arg self) (sel_registerName "accessibilityVerticalUnits")))
(define (nsmenuitem-accessibility-visible-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleCells)))
(define (nsmenuitem-accessibility-visible-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityVisibleCharacterRange")))
(define (nsmenuitem-accessibility-visible-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleChildren)))
(define (nsmenuitem-accessibility-visible-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleColumns)))
(define (nsmenuitem-accessibility-visible-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleRows)))
(define (nsmenuitem-accessibility-warning-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWarningValue)))
(define (nsmenuitem-accessibility-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindow)))
(define (nsmenuitem-accessibility-windows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindows)))
(define (nsmenuitem-accessibility-zoom-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityZoomButton)))
(define (nsmenuitem-copy-with-zone self zone)
  (wrap-objc-object
   (_msg-24 (coerce-arg self) (sel_registerName "copyWithZone:") zone)
   #:retained #t))
(define (nsmenuitem-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nsmenuitem-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) identifier)))
(define (nsmenuitem-is-accessibility-alternate-ui-visible self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityAlternateUIVisible")))
(define (nsmenuitem-is-accessibility-disclosed self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityDisclosed")))
(define (nsmenuitem-is-accessibility-edited self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityEdited")))
(define (nsmenuitem-is-accessibility-element self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityElement")))
(define (nsmenuitem-is-accessibility-enabled self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityEnabled")))
(define (nsmenuitem-is-accessibility-expanded self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityExpanded")))
(define (nsmenuitem-is-accessibility-focused self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityFocused")))
(define (nsmenuitem-is-accessibility-frontmost self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityFrontmost")))
(define (nsmenuitem-is-accessibility-hidden self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityHidden")))
(define (nsmenuitem-is-accessibility-main self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityMain")))
(define (nsmenuitem-is-accessibility-minimized self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityMinimized")))
(define (nsmenuitem-is-accessibility-modal self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityModal")))
(define (nsmenuitem-is-accessibility-ordered-by-row self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityOrderedByRow")))
(define (nsmenuitem-is-accessibility-protected-content self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityProtectedContent")))
(define (nsmenuitem-is-accessibility-required self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilityRequired")))
(define (nsmenuitem-is-accessibility-selected self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAccessibilitySelected")))
(define (nsmenuitem-is-accessibility-selector-allowed self selector)
  (_msg-23 (coerce-arg self) (sel_registerName "isAccessibilitySelectorAllowed:") (sel_registerName selector)))
(define (nsmenuitem-is-alternate self)
  (_msg-3 (coerce-arg self) (sel_registerName "isAlternate")))
(define (nsmenuitem-is-enabled self)
  (_msg-3 (coerce-arg self) (sel_registerName "isEnabled")))
(define (nsmenuitem-is-hidden self)
  (_msg-3 (coerce-arg self) (sel_registerName "isHidden")))
(define (nsmenuitem-is-hidden-or-has-hidden-ancestor self)
  (_msg-3 (coerce-arg self) (sel_registerName "isHiddenOrHasHiddenAncestor")))
(define (nsmenuitem-is-highlighted self)
  (_msg-3 (coerce-arg self) (sel_registerName "isHighlighted")))
(define (nsmenuitem-is-section-header self)
  (_msg-3 (coerce-arg self) (sel_registerName "isSectionHeader")))
(define (nsmenuitem-is-separator-item self)
  (_msg-3 (coerce-arg self) (sel_registerName "isSeparatorItem")))
(define (nsmenuitem-set-accessibility-activation-point! self accessibility-activation-point)
  (_msg-10 (coerce-arg self) (sel_registerName "setAccessibilityActivationPoint:") accessibility-activation-point))
(define (nsmenuitem-set-accessibility-allowed-values! self accessibility-allowed-values)
  (tell #:type _void (coerce-arg self) setAccessibilityAllowedValues: (coerce-arg accessibility-allowed-values)))
(define (nsmenuitem-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityAlternateUIVisible:") accessibility-alternate-ui-visible))
(define (nsmenuitem-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityApplicationFocusedUIElement: (coerce-arg accessibility-application-focused-ui-element)))
(define (nsmenuitem-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityAttributedUserInputLabels: (coerce-arg accessibility-attributed-user-input-labels)))
(define (nsmenuitem-set-accessibility-cancel-button! self accessibility-cancel-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCancelButton: (coerce-arg accessibility-cancel-button)))
(define (nsmenuitem-set-accessibility-children! self accessibility-children)
  (tell #:type _void (coerce-arg self) setAccessibilityChildren: (coerce-arg accessibility-children)))
(define (nsmenuitem-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (tell #:type _void (coerce-arg self) setAccessibilityChildrenInNavigationOrder: (coerce-arg accessibility-children-in-navigation-order)))
(define (nsmenuitem-set-accessibility-clear-button! self accessibility-clear-button)
  (tell #:type _void (coerce-arg self) setAccessibilityClearButton: (coerce-arg accessibility-clear-button)))
(define (nsmenuitem-set-accessibility-close-button! self accessibility-close-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCloseButton: (coerce-arg accessibility-close-button)))
(define (nsmenuitem-set-accessibility-column-count! self accessibility-column-count)
  (_msg-21 (coerce-arg self) (sel_registerName "setAccessibilityColumnCount:") accessibility-column-count))
(define (nsmenuitem-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnHeaderUIElements: (coerce-arg accessibility-column-header-ui-elements)))
(define (nsmenuitem-set-accessibility-column-index-range! self accessibility-column-index-range)
  (_msg-13 (coerce-arg self) (sel_registerName "setAccessibilityColumnIndexRange:") accessibility-column-index-range))
(define (nsmenuitem-set-accessibility-column-titles! self accessibility-column-titles)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnTitles: (coerce-arg accessibility-column-titles)))
(define (nsmenuitem-set-accessibility-columns! self accessibility-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityColumns: (coerce-arg accessibility-columns)))
(define (nsmenuitem-set-accessibility-contents! self accessibility-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityContents: (coerce-arg accessibility-contents)))
(define (nsmenuitem-set-accessibility-critical-value! self accessibility-critical-value)
  (tell #:type _void (coerce-arg self) setAccessibilityCriticalValue: (coerce-arg accessibility-critical-value)))
(define (nsmenuitem-set-accessibility-custom-actions! self accessibility-custom-actions)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomActions: (coerce-arg accessibility-custom-actions)))
(define (nsmenuitem-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomRotors: (coerce-arg accessibility-custom-rotors)))
(define (nsmenuitem-set-accessibility-decrement-button! self accessibility-decrement-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDecrementButton: (coerce-arg accessibility-decrement-button)))
(define (nsmenuitem-set-accessibility-default-button! self accessibility-default-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDefaultButton: (coerce-arg accessibility-default-button)))
(define (nsmenuitem-set-accessibility-disclosed! self accessibility-disclosed)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityDisclosed:") accessibility-disclosed))
(define (nsmenuitem-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedByRow: (coerce-arg accessibility-disclosed-by-row)))
(define (nsmenuitem-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedRows: (coerce-arg accessibility-disclosed-rows)))
(define (nsmenuitem-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (_msg-21 (coerce-arg self) (sel_registerName "setAccessibilityDisclosureLevel:") accessibility-disclosure-level))
(define (nsmenuitem-set-accessibility-document! self accessibility-document)
  (tell #:type _void (coerce-arg self) setAccessibilityDocument: (coerce-arg accessibility-document)))
(define (nsmenuitem-set-accessibility-edited! self accessibility-edited)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityEdited:") accessibility-edited))
(define (nsmenuitem-set-accessibility-element! self accessibility-element)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityElement:") accessibility-element))
(define (nsmenuitem-set-accessibility-enabled! self accessibility-enabled)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityEnabled:") accessibility-enabled))
(define (nsmenuitem-set-accessibility-expanded! self accessibility-expanded)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityExpanded:") accessibility-expanded))
(define (nsmenuitem-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityExtrasMenuBar: (coerce-arg accessibility-extras-menu-bar)))
(define (nsmenuitem-set-accessibility-filename! self accessibility-filename)
  (tell #:type _void (coerce-arg self) setAccessibilityFilename: (coerce-arg accessibility-filename)))
(define (nsmenuitem-set-accessibility-focused! self accessibility-focused)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityFocused:") accessibility-focused))
(define (nsmenuitem-set-accessibility-focused-window! self accessibility-focused-window)
  (tell #:type _void (coerce-arg self) setAccessibilityFocusedWindow: (coerce-arg accessibility-focused-window)))
(define (nsmenuitem-set-accessibility-frame! self accessibility-frame)
  (_msg-14 (coerce-arg self) (sel_registerName "setAccessibilityFrame:") accessibility-frame))
(define (nsmenuitem-set-accessibility-frontmost! self accessibility-frontmost)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityFrontmost:") accessibility-frontmost))
(define (nsmenuitem-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (tell #:type _void (coerce-arg self) setAccessibilityFullScreenButton: (coerce-arg accessibility-full-screen-button)))
(define (nsmenuitem-set-accessibility-grow-area! self accessibility-grow-area)
  (tell #:type _void (coerce-arg self) setAccessibilityGrowArea: (coerce-arg accessibility-grow-area)))
(define (nsmenuitem-set-accessibility-handles! self accessibility-handles)
  (tell #:type _void (coerce-arg self) setAccessibilityHandles: (coerce-arg accessibility-handles)))
(define (nsmenuitem-set-accessibility-header! self accessibility-header)
  (tell #:type _void (coerce-arg self) setAccessibilityHeader: (coerce-arg accessibility-header)))
(define (nsmenuitem-set-accessibility-help! self accessibility-help)
  (tell #:type _void (coerce-arg self) setAccessibilityHelp: (coerce-arg accessibility-help)))
(define (nsmenuitem-set-accessibility-hidden! self accessibility-hidden)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityHidden:") accessibility-hidden))
(define (nsmenuitem-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalScrollBar: (coerce-arg accessibility-horizontal-scroll-bar)))
(define (nsmenuitem-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalUnitDescription: (coerce-arg accessibility-horizontal-unit-description)))
(define (nsmenuitem-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (_msg-21 (coerce-arg self) (sel_registerName "setAccessibilityHorizontalUnits:") accessibility-horizontal-units))
(define (nsmenuitem-set-accessibility-identifier! self accessibility-identifier)
  (tell #:type _void (coerce-arg self) setAccessibilityIdentifier: (coerce-arg accessibility-identifier)))
(define (nsmenuitem-set-accessibility-increment-button! self accessibility-increment-button)
  (tell #:type _void (coerce-arg self) setAccessibilityIncrementButton: (coerce-arg accessibility-increment-button)))
(define (nsmenuitem-set-accessibility-index! self accessibility-index)
  (_msg-21 (coerce-arg self) (sel_registerName "setAccessibilityIndex:") accessibility-index))
(define (nsmenuitem-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (_msg-21 (coerce-arg self) (sel_registerName "setAccessibilityInsertionPointLineNumber:") accessibility-insertion-point-line-number))
(define (nsmenuitem-set-accessibility-label! self accessibility-label)
  (tell #:type _void (coerce-arg self) setAccessibilityLabel: (coerce-arg accessibility-label)))
(define (nsmenuitem-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLabelUIElements: (coerce-arg accessibility-label-ui-elements)))
(define (nsmenuitem-set-accessibility-label-value! self accessibility-label-value)
  (_msg-17 (coerce-arg self) (sel_registerName "setAccessibilityLabelValue:") accessibility-label-value))
(define (nsmenuitem-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLinkedUIElements: (coerce-arg accessibility-linked-ui-elements)))
(define (nsmenuitem-set-accessibility-main! self accessibility-main)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityMain:") accessibility-main))
(define (nsmenuitem-set-accessibility-main-window! self accessibility-main-window)
  (tell #:type _void (coerce-arg self) setAccessibilityMainWindow: (coerce-arg accessibility-main-window)))
(define (nsmenuitem-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerGroupUIElement: (coerce-arg accessibility-marker-group-ui-element)))
(define (nsmenuitem-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerTypeDescription: (coerce-arg accessibility-marker-type-description)))
(define (nsmenuitem-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerUIElements: (coerce-arg accessibility-marker-ui-elements)))
(define (nsmenuitem-set-accessibility-marker-values! self accessibility-marker-values)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerValues: (coerce-arg accessibility-marker-values)))
(define (nsmenuitem-set-accessibility-max-value! self accessibility-max-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMaxValue: (coerce-arg accessibility-max-value)))
(define (nsmenuitem-set-accessibility-menu-bar! self accessibility-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityMenuBar: (coerce-arg accessibility-menu-bar)))
(define (nsmenuitem-set-accessibility-min-value! self accessibility-min-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMinValue: (coerce-arg accessibility-min-value)))
(define (nsmenuitem-set-accessibility-minimize-button! self accessibility-minimize-button)
  (tell #:type _void (coerce-arg self) setAccessibilityMinimizeButton: (coerce-arg accessibility-minimize-button)))
(define (nsmenuitem-set-accessibility-minimized! self accessibility-minimized)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityMinimized:") accessibility-minimized))
(define (nsmenuitem-set-accessibility-modal! self accessibility-modal)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityModal:") accessibility-modal))
(define (nsmenuitem-set-accessibility-next-contents! self accessibility-next-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityNextContents: (coerce-arg accessibility-next-contents)))
(define (nsmenuitem-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (_msg-21 (coerce-arg self) (sel_registerName "setAccessibilityNumberOfCharacters:") accessibility-number-of-characters))
(define (nsmenuitem-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityOrderedByRow:") accessibility-ordered-by-row))
(define (nsmenuitem-set-accessibility-orientation! self accessibility-orientation)
  (_msg-21 (coerce-arg self) (sel_registerName "setAccessibilityOrientation:") accessibility-orientation))
(define (nsmenuitem-set-accessibility-overflow-button! self accessibility-overflow-button)
  (tell #:type _void (coerce-arg self) setAccessibilityOverflowButton: (coerce-arg accessibility-overflow-button)))
(define (nsmenuitem-set-accessibility-parent! self accessibility-parent)
  (tell #:type _void (coerce-arg self) setAccessibilityParent: (coerce-arg accessibility-parent)))
(define (nsmenuitem-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (tell #:type _void (coerce-arg self) setAccessibilityPlaceholderValue: (coerce-arg accessibility-placeholder-value)))
(define (nsmenuitem-set-accessibility-previous-contents! self accessibility-previous-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityPreviousContents: (coerce-arg accessibility-previous-contents)))
(define (nsmenuitem-set-accessibility-protected-content! self accessibility-protected-content)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityProtectedContent:") accessibility-protected-content))
(define (nsmenuitem-set-accessibility-proxy! self accessibility-proxy)
  (tell #:type _void (coerce-arg self) setAccessibilityProxy: (coerce-arg accessibility-proxy)))
(define (nsmenuitem-set-accessibility-required! self accessibility-required)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityRequired:") accessibility-required))
(define (nsmenuitem-set-accessibility-role! self accessibility-role)
  (tell #:type _void (coerce-arg self) setAccessibilityRole: (coerce-arg accessibility-role)))
(define (nsmenuitem-set-accessibility-role-description! self accessibility-role-description)
  (tell #:type _void (coerce-arg self) setAccessibilityRoleDescription: (coerce-arg accessibility-role-description)))
(define (nsmenuitem-set-accessibility-row-count! self accessibility-row-count)
  (_msg-21 (coerce-arg self) (sel_registerName "setAccessibilityRowCount:") accessibility-row-count))
(define (nsmenuitem-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityRowHeaderUIElements: (coerce-arg accessibility-row-header-ui-elements)))
(define (nsmenuitem-set-accessibility-row-index-range! self accessibility-row-index-range)
  (_msg-13 (coerce-arg self) (sel_registerName "setAccessibilityRowIndexRange:") accessibility-row-index-range))
(define (nsmenuitem-set-accessibility-rows! self accessibility-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityRows: (coerce-arg accessibility-rows)))
(define (nsmenuitem-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (_msg-21 (coerce-arg self) (sel_registerName "setAccessibilityRulerMarkerType:") accessibility-ruler-marker-type))
(define (nsmenuitem-set-accessibility-search-button! self accessibility-search-button)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchButton: (coerce-arg accessibility-search-button)))
(define (nsmenuitem-set-accessibility-search-menu! self accessibility-search-menu)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchMenu: (coerce-arg accessibility-search-menu)))
(define (nsmenuitem-set-accessibility-selected! self accessibility-selected)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilitySelected:") accessibility-selected))
(define (nsmenuitem-set-accessibility-selected-cells! self accessibility-selected-cells)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedCells: (coerce-arg accessibility-selected-cells)))
(define (nsmenuitem-set-accessibility-selected-children! self accessibility-selected-children)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedChildren: (coerce-arg accessibility-selected-children)))
(define (nsmenuitem-set-accessibility-selected-columns! self accessibility-selected-columns)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedColumns: (coerce-arg accessibility-selected-columns)))
(define (nsmenuitem-set-accessibility-selected-rows! self accessibility-selected-rows)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedRows: (coerce-arg accessibility-selected-rows)))
(define (nsmenuitem-set-accessibility-selected-text! self accessibility-selected-text)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedText: (coerce-arg accessibility-selected-text)))
(define (nsmenuitem-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (_msg-13 (coerce-arg self) (sel_registerName "setAccessibilitySelectedTextRange:") accessibility-selected-text-range))
(define (nsmenuitem-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedTextRanges: (coerce-arg accessibility-selected-text-ranges)))
(define (nsmenuitem-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityServesAsTitleForUIElements: (coerce-arg accessibility-serves-as-title-for-ui-elements)))
(define (nsmenuitem-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (_msg-13 (coerce-arg self) (sel_registerName "setAccessibilitySharedCharacterRange:") accessibility-shared-character-range))
(define (nsmenuitem-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedFocusElements: (coerce-arg accessibility-shared-focus-elements)))
(define (nsmenuitem-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedTextUIElements: (coerce-arg accessibility-shared-text-ui-elements)))
(define (nsmenuitem-set-accessibility-shown-menu! self accessibility-shown-menu)
  (tell #:type _void (coerce-arg self) setAccessibilityShownMenu: (coerce-arg accessibility-shown-menu)))
(define (nsmenuitem-set-accessibility-sort-direction! self accessibility-sort-direction)
  (_msg-21 (coerce-arg self) (sel_registerName "setAccessibilitySortDirection:") accessibility-sort-direction))
(define (nsmenuitem-set-accessibility-splitters! self accessibility-splitters)
  (tell #:type _void (coerce-arg self) setAccessibilitySplitters: (coerce-arg accessibility-splitters)))
(define (nsmenuitem-set-accessibility-subrole! self accessibility-subrole)
  (tell #:type _void (coerce-arg self) setAccessibilitySubrole: (coerce-arg accessibility-subrole)))
(define (nsmenuitem-set-accessibility-tabs! self accessibility-tabs)
  (tell #:type _void (coerce-arg self) setAccessibilityTabs: (coerce-arg accessibility-tabs)))
(define (nsmenuitem-set-accessibility-title! self accessibility-title)
  (tell #:type _void (coerce-arg self) setAccessibilityTitle: (coerce-arg accessibility-title)))
(define (nsmenuitem-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTitleUIElement: (coerce-arg accessibility-title-ui-element)))
(define (nsmenuitem-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (tell #:type _void (coerce-arg self) setAccessibilityToolbarButton: (coerce-arg accessibility-toolbar-button)))
(define (nsmenuitem-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTopLevelUIElement: (coerce-arg accessibility-top-level-ui-element)))
(define (nsmenuitem-set-accessibility-url! self accessibility-url)
  (tell #:type _void (coerce-arg self) setAccessibilityURL: (coerce-arg accessibility-url)))
(define (nsmenuitem-set-accessibility-unit-description! self accessibility-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityUnitDescription: (coerce-arg accessibility-unit-description)))
(define (nsmenuitem-set-accessibility-units! self accessibility-units)
  (_msg-21 (coerce-arg self) (sel_registerName "setAccessibilityUnits:") accessibility-units))
(define (nsmenuitem-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityUserInputLabels: (coerce-arg accessibility-user-input-labels)))
(define (nsmenuitem-set-accessibility-value! self accessibility-value)
  (tell #:type _void (coerce-arg self) setAccessibilityValue: (coerce-arg accessibility-value)))
(define (nsmenuitem-set-accessibility-value-description! self accessibility-value-description)
  (tell #:type _void (coerce-arg self) setAccessibilityValueDescription: (coerce-arg accessibility-value-description)))
(define (nsmenuitem-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalScrollBar: (coerce-arg accessibility-vertical-scroll-bar)))
(define (nsmenuitem-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalUnitDescription: (coerce-arg accessibility-vertical-unit-description)))
(define (nsmenuitem-set-accessibility-vertical-units! self accessibility-vertical-units)
  (_msg-21 (coerce-arg self) (sel_registerName "setAccessibilityVerticalUnits:") accessibility-vertical-units))
(define (nsmenuitem-set-accessibility-visible-cells! self accessibility-visible-cells)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleCells: (coerce-arg accessibility-visible-cells)))
(define (nsmenuitem-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (_msg-13 (coerce-arg self) (sel_registerName "setAccessibilityVisibleCharacterRange:") accessibility-visible-character-range))
(define (nsmenuitem-set-accessibility-visible-children! self accessibility-visible-children)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleChildren: (coerce-arg accessibility-visible-children)))
(define (nsmenuitem-set-accessibility-visible-columns! self accessibility-visible-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleColumns: (coerce-arg accessibility-visible-columns)))
(define (nsmenuitem-set-accessibility-visible-rows! self accessibility-visible-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleRows: (coerce-arg accessibility-visible-rows)))
(define (nsmenuitem-set-accessibility-warning-value! self accessibility-warning-value)
  (tell #:type _void (coerce-arg self) setAccessibilityWarningValue: (coerce-arg accessibility-warning-value)))
(define (nsmenuitem-set-accessibility-window! self accessibility-window)
  (tell #:type _void (coerce-arg self) setAccessibilityWindow: (coerce-arg accessibility-window)))
(define (nsmenuitem-set-accessibility-windows! self accessibility-windows)
  (tell #:type _void (coerce-arg self) setAccessibilityWindows: (coerce-arg accessibility-windows)))
(define (nsmenuitem-set-accessibility-zoom-button! self accessibility-zoom-button)
  (tell #:type _void (coerce-arg self) setAccessibilityZoomButton: (coerce-arg accessibility-zoom-button)))
(define (nsmenuitem-set-identifier! self identifier)
  (tell #:type _void (coerce-arg self) setIdentifier: (coerce-arg identifier)))

;; --- Class methods ---
(define (nsmenuitem-section-header-with-title title)
  (wrap-objc-object
   (tell NSMenuItem sectionHeaderWithTitle: (coerce-arg title))))
(define (nsmenuitem-separator-item)
  (wrap-objc-object
   (tell NSMenuItem separatorItem)))
