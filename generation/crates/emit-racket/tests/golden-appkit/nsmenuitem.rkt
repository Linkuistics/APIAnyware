#lang racket/base
;; Generated binding for NSMenuItem (AppKit)
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
  [nsmenuitem-accessibility-horizontal-units (c-> nsmenuitem? exact-integer?)]
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
  [nsmenuitem-accessibility-orientation (c-> nsmenuitem? exact-integer?)]
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
  [nsmenuitem-accessibility-ruler-marker-type (c-> nsmenuitem? exact-integer?)]
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
  [nsmenuitem-accessibility-sort-direction (c-> nsmenuitem? exact-integer?)]
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
  [nsmenuitem-accessibility-units (c-> nsmenuitem? exact-integer?)]
  [nsmenuitem-accessibility-user-input-labels (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-value (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-value-description (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-vertical-scroll-bar (c-> nsmenuitem? any/c)]
  [nsmenuitem-accessibility-vertical-unit-description (c-> nsmenuitem? (or/c nsstring? objc-nil?))]
  [nsmenuitem-accessibility-vertical-units (c-> nsmenuitem? exact-integer?)]
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
  [nsmenuitem-set-accessibility-horizontal-units! (c-> nsmenuitem? exact-integer? void?)]
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
  [nsmenuitem-set-accessibility-orientation! (c-> nsmenuitem? exact-integer? void?)]
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
  [nsmenuitem-set-accessibility-ruler-marker-type! (c-> nsmenuitem? exact-integer? void?)]
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
  [nsmenuitem-set-accessibility-sort-direction! (c-> nsmenuitem? exact-integer? void?)]
  [nsmenuitem-set-accessibility-splitters! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-subrole! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-tabs! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-title! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-title-ui-element! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-toolbar-button! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-top-level-ui-element! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-url! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-unit-description! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-units! (c-> nsmenuitem? exact-integer? void?)]
  [nsmenuitem-set-accessibility-user-input-labels! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-value! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-value-description! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-vertical-scroll-bar! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-vertical-unit-description! (c-> nsmenuitem? (or/c string? objc-object? #f) void?)]
  [nsmenuitem-set-accessibility-vertical-units! (c-> nsmenuitem? exact-integer? void?)]
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

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_q (-> ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_0_Q (-> ptr_t ptr_t uint64_t))
(define-aw-msg aw_racket_msg_0_f (-> ptr_t ptr_t float_t))
(define-aw-msg aw_racket_msg_0_R (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_0_O (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_0_G (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_b (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_b_v (-> ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_q_q (-> ptr_t ptr_t int64_t int64_t))
(define-aw-msg aw_racket_msg_q_G (-> ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_q_v (-> ptr_t ptr_t int64_t void_t))
(define-aw-msg aw_racket_msg_qq_P (-> ptr_t ptr_t int64_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_Q_v (-> ptr_t ptr_t uint64_t void_t))
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
(define (make-nsmenuitem-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSMenuItem alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nsmenuitem-init-with-title-action-key-equivalent string selector char-code)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPP_P (id->ffi2-ptr (tell NSMenuItem alloc)) (id->ffi2-ptr (sel_registerName "initWithTitle:action:keyEquivalent:")) (id->ffi2-ptr (coerce-arg string)) (id->ffi2-ptr (sel_registerName selector)) (id->ffi2-ptr (coerce-arg char-code))))
   #:retained #t))


;; --- Properties ---
(define (nsmenuitem-action self)
  (ptr_t->cpointer (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "action")))))
(define (nsmenuitem-set-action! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAction:")) (id->ffi2-ptr (sel_registerName value))))
(define (nsmenuitem-allows-automatic-key-equivalent-localization self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsAutomaticKeyEquivalentLocalization"))))
(define (nsmenuitem-set-allows-automatic-key-equivalent-localization! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsAutomaticKeyEquivalentLocalization:")) value))
(define (nsmenuitem-allows-automatic-key-equivalent-mirroring self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsAutomaticKeyEquivalentMirroring"))))
(define (nsmenuitem-set-allows-automatic-key-equivalent-mirroring! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsAutomaticKeyEquivalentMirroring:")) value))
(define (nsmenuitem-allows-key-equivalent-when-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsKeyEquivalentWhenHidden"))))
(define (nsmenuitem-set-allows-key-equivalent-when-hidden! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsKeyEquivalentWhenHidden:")) value))
(define (nsmenuitem-alternate self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "alternate"))))
(define (nsmenuitem-set-alternate! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAlternate:")) value))
(define (nsmenuitem-attributed-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "attributedTitle"))))))
(define (nsmenuitem-set-attributed-title! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAttributedTitle:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenuitem-badge self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "badge"))))))
(define (nsmenuitem-set-badge! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setBadge:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenuitem-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "enabled"))))
(define (nsmenuitem-set-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setEnabled:")) value))
(define (nsmenuitem-has-submenu self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hasSubmenu"))))
(define (nsmenuitem-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hidden"))))
(define (nsmenuitem-set-hidden! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setHidden:")) value))
(define (nsmenuitem-hidden-or-has-hidden-ancestor self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "hiddenOrHasHiddenAncestor"))))
(define (nsmenuitem-highlighted self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "highlighted"))))
(define (nsmenuitem-image self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "image"))))))
(define (nsmenuitem-set-image! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setImage:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenuitem-indentation-level self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indentationLevel"))))
(define (nsmenuitem-set-indentation-level! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIndentationLevel:")) value))
(define (nsmenuitem-key-equivalent self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyEquivalent"))))))
(define (nsmenuitem-set-key-equivalent! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setKeyEquivalent:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenuitem-key-equivalent-modifier-mask self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyEquivalentModifierMask"))))
(define (nsmenuitem-set-key-equivalent-modifier-mask! self value)
  (aw_racket_msg_Q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setKeyEquivalentModifierMask:")) value))
(define (nsmenuitem-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menu"))))))
(define (nsmenuitem-set-menu! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMenu:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenuitem-mixed-state-image self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mixedStateImage"))))))
(define (nsmenuitem-set-mixed-state-image! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMixedStateImage:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenuitem-off-state-image self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "offStateImage"))))))
(define (nsmenuitem-set-off-state-image! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setOffStateImage:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenuitem-on-state-image self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "onStateImage"))))))
(define (nsmenuitem-set-on-state-image! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setOnStateImage:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenuitem-parent-item self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "parentItem"))))))
(define (nsmenuitem-represented-object self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "representedObject"))))))
(define (nsmenuitem-set-represented-object! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setRepresentedObject:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenuitem-section-header self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "sectionHeader"))))
(define (nsmenuitem-state self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "state"))))
(define (nsmenuitem-set-state! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setState:")) value))
(define (nsmenuitem-submenu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "submenu"))))))
(define (nsmenuitem-set-submenu! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSubmenu:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenuitem-subtitle self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "subtitle"))))))
(define (nsmenuitem-set-subtitle! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSubtitle:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenuitem-tag self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tag"))))
(define (nsmenuitem-set-tag! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTag:")) value))
(define (nsmenuitem-target self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "target"))))))
(define (nsmenuitem-set-target! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTarget:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenuitem-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "title"))))))
(define (nsmenuitem-set-title! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTitle:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenuitem-tool-tip self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "toolTip"))))))
(define (nsmenuitem-set-tool-tip! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setToolTip:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenuitem-user-key-equivalent self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userKeyEquivalent"))))))
(define (nsmenuitem-uses-user-key-equivalents)
  (aw_racket_msg_0_b (id->ffi2-ptr NSMenuItem) (id->ffi2-ptr (sel_registerName "usesUserKeyEquivalents"))))
(define (nsmenuitem-set-uses-user-key-equivalents! value)
  (aw_racket_msg_b_v (id->ffi2-ptr NSMenuItem) (id->ffi2-ptr (sel_registerName "setUsesUserKeyEquivalents:")) value))
(define (nsmenuitem-view self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "view"))))))
(define (nsmenuitem-set-view! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setView:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenuitem-writing-tools-items)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSMenuItem) (id->ffi2-ptr (sel_registerName "writingToolsItems"))))))

;; --- Instance methods ---
(define (nsmenuitem-accessibility-activation-point self)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_0_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityActivationPoint")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsmenuitem-accessibility-allowed-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAllowedValues"))))
   ))
(define (nsmenuitem-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityApplicationFocusedUIElement"))))
   ))
(define (nsmenuitem-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nsmenuitem-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedUserInputLabels"))))
   ))
(define (nsmenuitem-accessibility-cancel-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCancelButton"))))
   ))
(define (nsmenuitem-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_qq_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCellForColumn:row:")) column row))
   ))
(define (nsmenuitem-accessibility-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildren"))))
   ))
(define (nsmenuitem-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildrenInNavigationOrder"))))
   ))
(define (nsmenuitem-accessibility-clear-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityClearButton"))))
   ))
(define (nsmenuitem-accessibility-close-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCloseButton"))))
   ))
(define (nsmenuitem-accessibility-column-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnCount"))))
(define (nsmenuitem-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnHeaderUIElements"))))
   ))
(define (nsmenuitem-accessibility-column-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsmenuitem-accessibility-column-titles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnTitles"))))
   ))
(define (nsmenuitem-accessibility-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumns"))))
   ))
(define (nsmenuitem-accessibility-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityContents"))))
   ))
(define (nsmenuitem-accessibility-critical-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCriticalValue"))))
   ))
(define (nsmenuitem-accessibility-custom-actions self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomActions"))))
   ))
(define (nsmenuitem-accessibility-custom-rotors self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomRotors"))))
   ))
(define (nsmenuitem-accessibility-decrement-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDecrementButton"))))
   ))
(define (nsmenuitem-accessibility-default-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDefaultButton"))))
   ))
(define (nsmenuitem-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedByRow"))))
   ))
(define (nsmenuitem-accessibility-disclosed-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedRows"))))
   ))
(define (nsmenuitem-accessibility-disclosure-level self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosureLevel"))))
(define (nsmenuitem-accessibility-document self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDocument"))))
   ))
(define (nsmenuitem-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityExtrasMenuBar"))))
   ))
(define (nsmenuitem-accessibility-filename self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFilename"))))
   ))
(define (nsmenuitem-accessibility-focused-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFocusedWindow"))))
   ))
(define (nsmenuitem-accessibility-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsmenuitem-accessibility-frame-for-range self range)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_G_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrameForRange:")) (id->ffi2-ptr range) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsmenuitem-accessibility-full-screen-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFullScreenButton"))))
   ))
(define (nsmenuitem-accessibility-grow-area self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityGrowArea"))))
   ))
(define (nsmenuitem-accessibility-handles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHandles"))))
   ))
(define (nsmenuitem-accessibility-header self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHeader"))))
   ))
(define (nsmenuitem-accessibility-help self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHelp"))))
   ))
(define (nsmenuitem-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalScrollBar"))))
   ))
(define (nsmenuitem-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnitDescription"))))
   ))
(define (nsmenuitem-accessibility-horizontal-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnits"))))
(define (nsmenuitem-accessibility-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIdentifier"))))
   ))
(define (nsmenuitem-accessibility-increment-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIncrementButton"))))
   ))
(define (nsmenuitem-accessibility-index self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIndex"))))
(define (nsmenuitem-accessibility-insertion-point-line-number self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityInsertionPointLineNumber"))))
(define (nsmenuitem-accessibility-label self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabel"))))
   ))
(define (nsmenuitem-accessibility-label-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelUIElements"))))
   ))
(define (nsmenuitem-accessibility-label-value self)
  (aw_racket_msg_0_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelValue"))))
(define (nsmenuitem-accessibility-layout-point-for-screen-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutPointForScreenPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsmenuitem-accessibility-layout-size-for-screen-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutSizeForScreenSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsmenuitem-accessibility-line-for-index self index)
  (aw_racket_msg_q_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLineForIndex:")) index))
(define (nsmenuitem-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLinkedUIElements"))))
   ))
(define (nsmenuitem-accessibility-main-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMainWindow"))))
   ))
(define (nsmenuitem-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerGroupUIElement"))))
   ))
(define (nsmenuitem-accessibility-marker-type-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerTypeDescription"))))
   ))
(define (nsmenuitem-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerUIElements"))))
   ))
(define (nsmenuitem-accessibility-marker-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerValues"))))
   ))
(define (nsmenuitem-accessibility-max-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMaxValue"))))
   ))
(define (nsmenuitem-accessibility-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMenuBar"))))
   ))
(define (nsmenuitem-accessibility-min-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinValue"))))
   ))
(define (nsmenuitem-accessibility-minimize-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinimizeButton"))))
   ))
(define (nsmenuitem-accessibility-next-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNextContents"))))
   ))
(define (nsmenuitem-accessibility-number-of-characters self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNumberOfCharacters"))))
(define (nsmenuitem-accessibility-orientation self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOrientation"))))
(define (nsmenuitem-accessibility-overflow-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOverflowButton"))))
   ))
(define (nsmenuitem-accessibility-parent self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityParent"))))
   ))
(define (nsmenuitem-accessibility-perform-cancel self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformCancel"))))
(define (nsmenuitem-accessibility-perform-confirm self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformConfirm"))))
(define (nsmenuitem-accessibility-perform-decrement self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDecrement"))))
(define (nsmenuitem-accessibility-perform-delete self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDelete"))))
(define (nsmenuitem-accessibility-perform-increment self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformIncrement"))))
(define (nsmenuitem-accessibility-perform-pick self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPick"))))
(define (nsmenuitem-accessibility-perform-press self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPress"))))
(define (nsmenuitem-accessibility-perform-raise self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformRaise"))))
(define (nsmenuitem-accessibility-perform-show-alternate-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowAlternateUI"))))
(define (nsmenuitem-accessibility-perform-show-default-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowDefaultUI"))))
(define (nsmenuitem-accessibility-perform-show-menu self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowMenu"))))
(define (nsmenuitem-accessibility-placeholder-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPlaceholderValue"))))
   ))
(define (nsmenuitem-accessibility-previous-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPreviousContents"))))
   ))
(define (nsmenuitem-accessibility-proxy self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityProxy"))))
   ))
(define (nsmenuitem-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRTFForRange:")) (id->ffi2-ptr range)))
   ))
(define (nsmenuitem-accessibility-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsmenuitem-accessibility-range-for-line self line)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForLine:")) line (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsmenuitem-accessibility-range-for-position self point)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_O_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForPosition:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsmenuitem-accessibility-role self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRole"))))
   ))
(define (nsmenuitem-accessibility-role-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRoleDescription"))))
   ))
(define (nsmenuitem-accessibility-row-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowCount"))))
(define (nsmenuitem-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowHeaderUIElements"))))
   ))
(define (nsmenuitem-accessibility-row-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsmenuitem-accessibility-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRows"))))
   ))
(define (nsmenuitem-accessibility-ruler-marker-type self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRulerMarkerType"))))
(define (nsmenuitem-accessibility-screen-point-for-layout-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenPointForLayoutPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsmenuitem-accessibility-screen-size-for-layout-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenSizeForLayoutSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsmenuitem-accessibility-search-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchButton"))))
   ))
(define (nsmenuitem-accessibility-search-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchMenu"))))
   ))
(define (nsmenuitem-accessibility-selected-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedCells"))))
   ))
(define (nsmenuitem-accessibility-selected-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedChildren"))))
   ))
(define (nsmenuitem-accessibility-selected-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedColumns"))))
   ))
(define (nsmenuitem-accessibility-selected-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedRows"))))
   ))
(define (nsmenuitem-accessibility-selected-text self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedText"))))
   ))
(define (nsmenuitem-accessibility-selected-text-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsmenuitem-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRanges"))))
   ))
(define (nsmenuitem-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityServesAsTitleForUIElements"))))
   ))
(define (nsmenuitem-accessibility-shared-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsmenuitem-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedFocusElements"))))
   ))
(define (nsmenuitem-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedTextUIElements"))))
   ))
(define (nsmenuitem-accessibility-shown-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityShownMenu"))))
   ))
(define (nsmenuitem-accessibility-sort-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySortDirection"))))
(define (nsmenuitem-accessibility-splitters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySplitters"))))
   ))
(define (nsmenuitem-accessibility-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nsmenuitem-accessibility-style-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStyleRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsmenuitem-accessibility-subrole self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySubrole"))))
   ))
(define (nsmenuitem-accessibility-tabs self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTabs"))))
   ))
(define (nsmenuitem-accessibility-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitle"))))
   ))
(define (nsmenuitem-accessibility-title-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitleUIElement"))))
   ))
(define (nsmenuitem-accessibility-toolbar-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityToolbarButton"))))
   ))
(define (nsmenuitem-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTopLevelUIElement"))))
   ))
(define (nsmenuitem-accessibility-url self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityURL"))))
   ))
(define (nsmenuitem-accessibility-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnitDescription"))))
   ))
(define (nsmenuitem-accessibility-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnits"))))
(define (nsmenuitem-accessibility-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUserInputLabels"))))
   ))
(define (nsmenuitem-accessibility-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValue"))))
   ))
(define (nsmenuitem-accessibility-value-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValueDescription"))))
   ))
(define (nsmenuitem-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalScrollBar"))))
   ))
(define (nsmenuitem-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnitDescription"))))
   ))
(define (nsmenuitem-accessibility-vertical-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnits"))))
(define (nsmenuitem-accessibility-visible-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCells"))))
   ))
(define (nsmenuitem-accessibility-visible-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsmenuitem-accessibility-visible-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleChildren"))))
   ))
(define (nsmenuitem-accessibility-visible-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleColumns"))))
   ))
(define (nsmenuitem-accessibility-visible-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleRows"))))
   ))
(define (nsmenuitem-accessibility-warning-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWarningValue"))))
   ))
(define (nsmenuitem-accessibility-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindow"))))
   ))
(define (nsmenuitem-accessibility-windows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindows"))))
   ))
(define (nsmenuitem-accessibility-zoom-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityZoomButton"))))
   ))
(define (nsmenuitem-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "copyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))
(define (nsmenuitem-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nsmenuitem-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "identifier"))))
   ))
(define (nsmenuitem-is-accessibility-alternate-ui-visible self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityAlternateUIVisible"))))
(define (nsmenuitem-is-accessibility-disclosed self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityDisclosed"))))
(define (nsmenuitem-is-accessibility-edited self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEdited"))))
(define (nsmenuitem-is-accessibility-element self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityElement"))))
(define (nsmenuitem-is-accessibility-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEnabled"))))
(define (nsmenuitem-is-accessibility-expanded self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityExpanded"))))
(define (nsmenuitem-is-accessibility-focused self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFocused"))))
(define (nsmenuitem-is-accessibility-frontmost self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFrontmost"))))
(define (nsmenuitem-is-accessibility-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityHidden"))))
(define (nsmenuitem-is-accessibility-main self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMain"))))
(define (nsmenuitem-is-accessibility-minimized self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMinimized"))))
(define (nsmenuitem-is-accessibility-modal self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityModal"))))
(define (nsmenuitem-is-accessibility-ordered-by-row self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityOrderedByRow"))))
(define (nsmenuitem-is-accessibility-protected-content self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityProtectedContent"))))
(define (nsmenuitem-is-accessibility-required self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityRequired"))))
(define (nsmenuitem-is-accessibility-selected self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelected"))))
(define (nsmenuitem-is-accessibility-selector-allowed self selector)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelectorAllowed:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nsmenuitem-is-alternate self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAlternate"))))
(define (nsmenuitem-is-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isEnabled"))))
(define (nsmenuitem-is-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHidden"))))
(define (nsmenuitem-is-hidden-or-has-hidden-ancestor self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHiddenOrHasHiddenAncestor"))))
(define (nsmenuitem-is-highlighted self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isHighlighted"))))
(define (nsmenuitem-is-section-header self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isSectionHeader"))))
(define (nsmenuitem-is-separator-item self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isSeparatorItem"))))
(define (nsmenuitem-set-accessibility-activation-point! self accessibility-activation-point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityActivationPoint:")) (id->ffi2-ptr accessibility-activation-point)))
(define (nsmenuitem-set-accessibility-allowed-values! self accessibility-allowed-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAllowedValues:")) (id->ffi2-ptr (coerce-arg accessibility-allowed-values))))
(define (nsmenuitem-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAlternateUIVisible:")) accessibility-alternate-ui-visible))
(define (nsmenuitem-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityApplicationFocusedUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-application-focused-ui-element))))
(define (nsmenuitem-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAttributedUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-attributed-user-input-labels))))
(define (nsmenuitem-set-accessibility-cancel-button! self accessibility-cancel-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCancelButton:")) (id->ffi2-ptr (coerce-arg accessibility-cancel-button))))
(define (nsmenuitem-set-accessibility-children! self accessibility-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildren:")) (id->ffi2-ptr (coerce-arg accessibility-children))))
(define (nsmenuitem-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildrenInNavigationOrder:")) (id->ffi2-ptr (coerce-arg accessibility-children-in-navigation-order))))
(define (nsmenuitem-set-accessibility-clear-button! self accessibility-clear-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityClearButton:")) (id->ffi2-ptr (coerce-arg accessibility-clear-button))))
(define (nsmenuitem-set-accessibility-close-button! self accessibility-close-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCloseButton:")) (id->ffi2-ptr (coerce-arg accessibility-close-button))))
(define (nsmenuitem-set-accessibility-column-count! self accessibility-column-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnCount:")) accessibility-column-count))
(define (nsmenuitem-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-column-header-ui-elements))))
(define (nsmenuitem-set-accessibility-column-index-range! self accessibility-column-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnIndexRange:")) (id->ffi2-ptr accessibility-column-index-range)))
(define (nsmenuitem-set-accessibility-column-titles! self accessibility-column-titles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnTitles:")) (id->ffi2-ptr (coerce-arg accessibility-column-titles))))
(define (nsmenuitem-set-accessibility-columns! self accessibility-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumns:")) (id->ffi2-ptr (coerce-arg accessibility-columns))))
(define (nsmenuitem-set-accessibility-contents! self accessibility-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityContents:")) (id->ffi2-ptr (coerce-arg accessibility-contents))))
(define (nsmenuitem-set-accessibility-critical-value! self accessibility-critical-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCriticalValue:")) (id->ffi2-ptr (coerce-arg accessibility-critical-value))))
(define (nsmenuitem-set-accessibility-custom-actions! self accessibility-custom-actions)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomActions:")) (id->ffi2-ptr (coerce-arg accessibility-custom-actions))))
(define (nsmenuitem-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomRotors:")) (id->ffi2-ptr (coerce-arg accessibility-custom-rotors))))
(define (nsmenuitem-set-accessibility-decrement-button! self accessibility-decrement-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDecrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-decrement-button))))
(define (nsmenuitem-set-accessibility-default-button! self accessibility-default-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDefaultButton:")) (id->ffi2-ptr (coerce-arg accessibility-default-button))))
(define (nsmenuitem-set-accessibility-disclosed! self accessibility-disclosed)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosed:")) accessibility-disclosed))
(define (nsmenuitem-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedByRow:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-by-row))))
(define (nsmenuitem-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedRows:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-rows))))
(define (nsmenuitem-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosureLevel:")) accessibility-disclosure-level))
(define (nsmenuitem-set-accessibility-document! self accessibility-document)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDocument:")) (id->ffi2-ptr (coerce-arg accessibility-document))))
(define (nsmenuitem-set-accessibility-edited! self accessibility-edited)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEdited:")) accessibility-edited))
(define (nsmenuitem-set-accessibility-element! self accessibility-element)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityElement:")) accessibility-element))
(define (nsmenuitem-set-accessibility-enabled! self accessibility-enabled)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEnabled:")) accessibility-enabled))
(define (nsmenuitem-set-accessibility-expanded! self accessibility-expanded)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExpanded:")) accessibility-expanded))
(define (nsmenuitem-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExtrasMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-extras-menu-bar))))
(define (nsmenuitem-set-accessibility-filename! self accessibility-filename)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFilename:")) (id->ffi2-ptr (coerce-arg accessibility-filename))))
(define (nsmenuitem-set-accessibility-focused! self accessibility-focused)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocused:")) accessibility-focused))
(define (nsmenuitem-set-accessibility-focused-window! self accessibility-focused-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocusedWindow:")) (id->ffi2-ptr (coerce-arg accessibility-focused-window))))
(define (nsmenuitem-set-accessibility-frame! self accessibility-frame)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrame:")) (id->ffi2-ptr accessibility-frame)))
(define (nsmenuitem-set-accessibility-frontmost! self accessibility-frontmost)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrontmost:")) accessibility-frontmost))
(define (nsmenuitem-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFullScreenButton:")) (id->ffi2-ptr (coerce-arg accessibility-full-screen-button))))
(define (nsmenuitem-set-accessibility-grow-area! self accessibility-grow-area)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityGrowArea:")) (id->ffi2-ptr (coerce-arg accessibility-grow-area))))
(define (nsmenuitem-set-accessibility-handles! self accessibility-handles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHandles:")) (id->ffi2-ptr (coerce-arg accessibility-handles))))
(define (nsmenuitem-set-accessibility-header! self accessibility-header)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHeader:")) (id->ffi2-ptr (coerce-arg accessibility-header))))
(define (nsmenuitem-set-accessibility-help! self accessibility-help)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHelp:")) (id->ffi2-ptr (coerce-arg accessibility-help))))
(define (nsmenuitem-set-accessibility-hidden! self accessibility-hidden)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHidden:")) accessibility-hidden))
(define (nsmenuitem-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-scroll-bar))))
(define (nsmenuitem-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-unit-description))))
(define (nsmenuitem-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnits:")) accessibility-horizontal-units))
(define (nsmenuitem-set-accessibility-identifier! self accessibility-identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIdentifier:")) (id->ffi2-ptr (coerce-arg accessibility-identifier))))
(define (nsmenuitem-set-accessibility-increment-button! self accessibility-increment-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIncrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-increment-button))))
(define (nsmenuitem-set-accessibility-index! self accessibility-index)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIndex:")) accessibility-index))
(define (nsmenuitem-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityInsertionPointLineNumber:")) accessibility-insertion-point-line-number))
(define (nsmenuitem-set-accessibility-label! self accessibility-label)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabel:")) (id->ffi2-ptr (coerce-arg accessibility-label))))
(define (nsmenuitem-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-label-ui-elements))))
(define (nsmenuitem-set-accessibility-label-value! self accessibility-label-value)
  (aw_racket_msg_f_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelValue:")) accessibility-label-value))
(define (nsmenuitem-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLinkedUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-linked-ui-elements))))
(define (nsmenuitem-set-accessibility-main! self accessibility-main)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMain:")) accessibility-main))
(define (nsmenuitem-set-accessibility-main-window! self accessibility-main-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMainWindow:")) (id->ffi2-ptr (coerce-arg accessibility-main-window))))
(define (nsmenuitem-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerGroupUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-marker-group-ui-element))))
(define (nsmenuitem-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerTypeDescription:")) (id->ffi2-ptr (coerce-arg accessibility-marker-type-description))))
(define (nsmenuitem-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-marker-ui-elements))))
(define (nsmenuitem-set-accessibility-marker-values! self accessibility-marker-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerValues:")) (id->ffi2-ptr (coerce-arg accessibility-marker-values))))
(define (nsmenuitem-set-accessibility-max-value! self accessibility-max-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMaxValue:")) (id->ffi2-ptr (coerce-arg accessibility-max-value))))
(define (nsmenuitem-set-accessibility-menu-bar! self accessibility-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-menu-bar))))
(define (nsmenuitem-set-accessibility-min-value! self accessibility-min-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinValue:")) (id->ffi2-ptr (coerce-arg accessibility-min-value))))
(define (nsmenuitem-set-accessibility-minimize-button! self accessibility-minimize-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimizeButton:")) (id->ffi2-ptr (coerce-arg accessibility-minimize-button))))
(define (nsmenuitem-set-accessibility-minimized! self accessibility-minimized)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimized:")) accessibility-minimized))
(define (nsmenuitem-set-accessibility-modal! self accessibility-modal)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityModal:")) accessibility-modal))
(define (nsmenuitem-set-accessibility-next-contents! self accessibility-next-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNextContents:")) (id->ffi2-ptr (coerce-arg accessibility-next-contents))))
(define (nsmenuitem-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNumberOfCharacters:")) accessibility-number-of-characters))
(define (nsmenuitem-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrderedByRow:")) accessibility-ordered-by-row))
(define (nsmenuitem-set-accessibility-orientation! self accessibility-orientation)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrientation:")) accessibility-orientation))
(define (nsmenuitem-set-accessibility-overflow-button! self accessibility-overflow-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOverflowButton:")) (id->ffi2-ptr (coerce-arg accessibility-overflow-button))))
(define (nsmenuitem-set-accessibility-parent! self accessibility-parent)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityParent:")) (id->ffi2-ptr (coerce-arg accessibility-parent))))
(define (nsmenuitem-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPlaceholderValue:")) (id->ffi2-ptr (coerce-arg accessibility-placeholder-value))))
(define (nsmenuitem-set-accessibility-previous-contents! self accessibility-previous-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPreviousContents:")) (id->ffi2-ptr (coerce-arg accessibility-previous-contents))))
(define (nsmenuitem-set-accessibility-protected-content! self accessibility-protected-content)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProtectedContent:")) accessibility-protected-content))
(define (nsmenuitem-set-accessibility-proxy! self accessibility-proxy)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProxy:")) (id->ffi2-ptr (coerce-arg accessibility-proxy))))
(define (nsmenuitem-set-accessibility-required! self accessibility-required)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRequired:")) accessibility-required))
(define (nsmenuitem-set-accessibility-role! self accessibility-role)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRole:")) (id->ffi2-ptr (coerce-arg accessibility-role))))
(define (nsmenuitem-set-accessibility-role-description! self accessibility-role-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRoleDescription:")) (id->ffi2-ptr (coerce-arg accessibility-role-description))))
(define (nsmenuitem-set-accessibility-row-count! self accessibility-row-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowCount:")) accessibility-row-count))
(define (nsmenuitem-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-row-header-ui-elements))))
(define (nsmenuitem-set-accessibility-row-index-range! self accessibility-row-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowIndexRange:")) (id->ffi2-ptr accessibility-row-index-range)))
(define (nsmenuitem-set-accessibility-rows! self accessibility-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRows:")) (id->ffi2-ptr (coerce-arg accessibility-rows))))
(define (nsmenuitem-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRulerMarkerType:")) accessibility-ruler-marker-type))
(define (nsmenuitem-set-accessibility-search-button! self accessibility-search-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchButton:")) (id->ffi2-ptr (coerce-arg accessibility-search-button))))
(define (nsmenuitem-set-accessibility-search-menu! self accessibility-search-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchMenu:")) (id->ffi2-ptr (coerce-arg accessibility-search-menu))))
(define (nsmenuitem-set-accessibility-selected! self accessibility-selected)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelected:")) accessibility-selected))
(define (nsmenuitem-set-accessibility-selected-cells! self accessibility-selected-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedCells:")) (id->ffi2-ptr (coerce-arg accessibility-selected-cells))))
(define (nsmenuitem-set-accessibility-selected-children! self accessibility-selected-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedChildren:")) (id->ffi2-ptr (coerce-arg accessibility-selected-children))))
(define (nsmenuitem-set-accessibility-selected-columns! self accessibility-selected-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedColumns:")) (id->ffi2-ptr (coerce-arg accessibility-selected-columns))))
(define (nsmenuitem-set-accessibility-selected-rows! self accessibility-selected-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedRows:")) (id->ffi2-ptr (coerce-arg accessibility-selected-rows))))
(define (nsmenuitem-set-accessibility-selected-text! self accessibility-selected-text)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedText:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text))))
(define (nsmenuitem-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRange:")) (id->ffi2-ptr accessibility-selected-text-range)))
(define (nsmenuitem-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRanges:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text-ranges))))
(define (nsmenuitem-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityServesAsTitleForUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-serves-as-title-for-ui-elements))))
(define (nsmenuitem-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedCharacterRange:")) (id->ffi2-ptr accessibility-shared-character-range)))
(define (nsmenuitem-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedFocusElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-focus-elements))))
(define (nsmenuitem-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedTextUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-text-ui-elements))))
(define (nsmenuitem-set-accessibility-shown-menu! self accessibility-shown-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityShownMenu:")) (id->ffi2-ptr (coerce-arg accessibility-shown-menu))))
(define (nsmenuitem-set-accessibility-sort-direction! self accessibility-sort-direction)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySortDirection:")) accessibility-sort-direction))
(define (nsmenuitem-set-accessibility-splitters! self accessibility-splitters)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySplitters:")) (id->ffi2-ptr (coerce-arg accessibility-splitters))))
(define (nsmenuitem-set-accessibility-subrole! self accessibility-subrole)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySubrole:")) (id->ffi2-ptr (coerce-arg accessibility-subrole))))
(define (nsmenuitem-set-accessibility-tabs! self accessibility-tabs)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTabs:")) (id->ffi2-ptr (coerce-arg accessibility-tabs))))
(define (nsmenuitem-set-accessibility-title! self accessibility-title)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitle:")) (id->ffi2-ptr (coerce-arg accessibility-title))))
(define (nsmenuitem-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitleUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-title-ui-element))))
(define (nsmenuitem-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityToolbarButton:")) (id->ffi2-ptr (coerce-arg accessibility-toolbar-button))))
(define (nsmenuitem-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTopLevelUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-top-level-ui-element))))
(define (nsmenuitem-set-accessibility-url! self accessibility-url)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityURL:")) (id->ffi2-ptr (coerce-arg accessibility-url))))
(define (nsmenuitem-set-accessibility-unit-description! self accessibility-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-unit-description))))
(define (nsmenuitem-set-accessibility-units! self accessibility-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnits:")) accessibility-units))
(define (nsmenuitem-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-user-input-labels))))
(define (nsmenuitem-set-accessibility-value! self accessibility-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValue:")) (id->ffi2-ptr (coerce-arg accessibility-value))))
(define (nsmenuitem-set-accessibility-value-description! self accessibility-value-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValueDescription:")) (id->ffi2-ptr (coerce-arg accessibility-value-description))))
(define (nsmenuitem-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-scroll-bar))))
(define (nsmenuitem-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-unit-description))))
(define (nsmenuitem-set-accessibility-vertical-units! self accessibility-vertical-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnits:")) accessibility-vertical-units))
(define (nsmenuitem-set-accessibility-visible-cells! self accessibility-visible-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCells:")) (id->ffi2-ptr (coerce-arg accessibility-visible-cells))))
(define (nsmenuitem-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCharacterRange:")) (id->ffi2-ptr accessibility-visible-character-range)))
(define (nsmenuitem-set-accessibility-visible-children! self accessibility-visible-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleChildren:")) (id->ffi2-ptr (coerce-arg accessibility-visible-children))))
(define (nsmenuitem-set-accessibility-visible-columns! self accessibility-visible-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleColumns:")) (id->ffi2-ptr (coerce-arg accessibility-visible-columns))))
(define (nsmenuitem-set-accessibility-visible-rows! self accessibility-visible-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleRows:")) (id->ffi2-ptr (coerce-arg accessibility-visible-rows))))
(define (nsmenuitem-set-accessibility-warning-value! self accessibility-warning-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWarningValue:")) (id->ffi2-ptr (coerce-arg accessibility-warning-value))))
(define (nsmenuitem-set-accessibility-window! self accessibility-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindow:")) (id->ffi2-ptr (coerce-arg accessibility-window))))
(define (nsmenuitem-set-accessibility-windows! self accessibility-windows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindows:")) (id->ffi2-ptr (coerce-arg accessibility-windows))))
(define (nsmenuitem-set-accessibility-zoom-button! self accessibility-zoom-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityZoomButton:")) (id->ffi2-ptr (coerce-arg accessibility-zoom-button))))
(define (nsmenuitem-set-identifier! self identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIdentifier:")) (id->ffi2-ptr (coerce-arg identifier))))

;; --- Class methods ---
(define (nsmenuitem-section-header-with-title title)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSMenuItem) (id->ffi2-ptr (sel_registerName "sectionHeaderWithTitle:")) (id->ffi2-ptr (coerce-arg title))))
   ))
(define (nsmenuitem-separator-item)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSMenuItem) (id->ffi2-ptr (sel_registerName "separatorItem"))))
   ))
