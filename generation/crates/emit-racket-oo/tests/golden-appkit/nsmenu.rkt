#lang racket/base
;; Generated binding for NSMenu (AppKit)
;; Do not edit — regenerate from enriched IR

(require ffi/unsafe
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../runtime/objc-base.rkt"
         "../../runtime/coerce.rkt"
         "../../runtime/block.rkt"
         "../../runtime/type-mapping.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/AppKit.framework/AppKit"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
(define (nsappearance? v) (objc-instance-of? v "NSAppearance"))
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nsattributedstring? v) (objc-instance-of? v "NSAttributedString"))
(define (nsdata? v) (objc-instance-of? v "NSData"))
(define (nsfont? v) (objc-instance-of? v "NSFont"))
(define (nsmenu? v) (objc-instance-of? v "NSMenu"))
(define (nsmenuitem? v) (objc-instance-of? v "NSMenuItem"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (nsurl? v) (objc-instance-of? v "NSURL"))
(provide NSMenu)
(provide/contract
  [make-nsmenu-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nsmenu-init-with-title (c-> (or/c string? objc-object? #f) any/c)]
  [nsmenu-allows-context-menu-plug-ins (c-> nsmenu? boolean?)]
  [nsmenu-set-allows-context-menu-plug-ins! (c-> nsmenu? boolean? void?)]
  [nsmenu-autoenables-items (c-> nsmenu? boolean?)]
  [nsmenu-set-autoenables-items! (c-> nsmenu? boolean? void?)]
  [nsmenu-automatically-inserts-writing-tools-items (c-> nsmenu? boolean?)]
  [nsmenu-set-automatically-inserts-writing-tools-items! (c-> nsmenu? boolean? void?)]
  [nsmenu-delegate (c-> nsmenu? any/c)]
  [nsmenu-set-delegate! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-font (c-> nsmenu? (or/c nsfont? objc-nil?))]
  [nsmenu-set-font! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-highlighted-item (c-> nsmenu? (or/c nsmenuitem? objc-nil?))]
  [nsmenu-item-array (c-> nsmenu? any/c)]
  [nsmenu-set-item-array! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-menu-bar-height (c-> nsmenu? real?)]
  [nsmenu-menu-changed-messages-enabled (c-> nsmenu? boolean?)]
  [nsmenu-set-menu-changed-messages-enabled! (c-> nsmenu? boolean? void?)]
  [nsmenu-minimum-width (c-> nsmenu? real?)]
  [nsmenu-set-minimum-width! (c-> nsmenu? real? void?)]
  [nsmenu-number-of-items (c-> nsmenu? exact-integer?)]
  [nsmenu-presentation-style (c-> nsmenu? exact-integer?)]
  [nsmenu-set-presentation-style! (c-> nsmenu? exact-integer? void?)]
  [nsmenu-properties-to-update (c-> nsmenu? exact-nonnegative-integer?)]
  [nsmenu-selected-items (c-> nsmenu? any/c)]
  [nsmenu-set-selected-items! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-selection-mode (c-> nsmenu? exact-integer?)]
  [nsmenu-set-selection-mode! (c-> nsmenu? exact-integer? void?)]
  [nsmenu-shows-state-column (c-> nsmenu? boolean?)]
  [nsmenu-set-shows-state-column! (c-> nsmenu? boolean? void?)]
  [nsmenu-size (c-> nsmenu? any/c)]
  [nsmenu-supermenu (c-> nsmenu? (or/c nsmenu? objc-nil?))]
  [nsmenu-set-supermenu! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-title (c-> nsmenu? (or/c nsstring? objc-nil?))]
  [nsmenu-set-title! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-torn-off (c-> nsmenu? boolean?)]
  [nsmenu-user-interface-layout-direction (c-> nsmenu? exact-integer?)]
  [nsmenu-set-user-interface-layout-direction! (c-> nsmenu? exact-integer? void?)]
  [nsmenu-accessibility-activation-point (c-> nsmenu? any/c)]
  [nsmenu-accessibility-allowed-values (c-> nsmenu? any/c)]
  [nsmenu-accessibility-application-focused-ui-element (c-> nsmenu? any/c)]
  [nsmenu-accessibility-attributed-string-for-range (c-> nsmenu? any/c (or/c nsattributedstring? objc-nil?))]
  [nsmenu-accessibility-attributed-user-input-labels (c-> nsmenu? any/c)]
  [nsmenu-accessibility-cancel-button (c-> nsmenu? any/c)]
  [nsmenu-accessibility-cell-for-column-row (c-> nsmenu? exact-integer? exact-integer? any/c)]
  [nsmenu-accessibility-children (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-children-in-navigation-order (c-> nsmenu? any/c)]
  [nsmenu-accessibility-clear-button (c-> nsmenu? any/c)]
  [nsmenu-accessibility-close-button (c-> nsmenu? any/c)]
  [nsmenu-accessibility-column-count (c-> nsmenu? exact-integer?)]
  [nsmenu-accessibility-column-header-ui-elements (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-column-index-range (c-> nsmenu? any/c)]
  [nsmenu-accessibility-column-titles (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-columns (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-contents (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-critical-value (c-> nsmenu? any/c)]
  [nsmenu-accessibility-custom-actions (c-> nsmenu? any/c)]
  [nsmenu-accessibility-custom-rotors (c-> nsmenu? any/c)]
  [nsmenu-accessibility-decrement-button (c-> nsmenu? any/c)]
  [nsmenu-accessibility-default-button (c-> nsmenu? any/c)]
  [nsmenu-accessibility-disclosed-by-row (c-> nsmenu? any/c)]
  [nsmenu-accessibility-disclosed-rows (c-> nsmenu? any/c)]
  [nsmenu-accessibility-disclosure-level (c-> nsmenu? exact-integer?)]
  [nsmenu-accessibility-document (c-> nsmenu? (or/c nsstring? objc-nil?))]
  [nsmenu-accessibility-extras-menu-bar (c-> nsmenu? any/c)]
  [nsmenu-accessibility-filename (c-> nsmenu? (or/c nsstring? objc-nil?))]
  [nsmenu-accessibility-focused-window (c-> nsmenu? any/c)]
  [nsmenu-accessibility-frame (c-> nsmenu? any/c)]
  [nsmenu-accessibility-frame-for-range (c-> nsmenu? any/c any/c)]
  [nsmenu-accessibility-full-screen-button (c-> nsmenu? any/c)]
  [nsmenu-accessibility-grow-area (c-> nsmenu? any/c)]
  [nsmenu-accessibility-handles (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-header (c-> nsmenu? any/c)]
  [nsmenu-accessibility-help (c-> nsmenu? (or/c nsstring? objc-nil?))]
  [nsmenu-accessibility-horizontal-scroll-bar (c-> nsmenu? any/c)]
  [nsmenu-accessibility-horizontal-unit-description (c-> nsmenu? (or/c nsstring? objc-nil?))]
  [nsmenu-accessibility-horizontal-units (c-> nsmenu? exact-integer?)]
  [nsmenu-accessibility-identifier (c-> nsmenu? (or/c nsstring? objc-nil?))]
  [nsmenu-accessibility-increment-button (c-> nsmenu? any/c)]
  [nsmenu-accessibility-index (c-> nsmenu? exact-integer?)]
  [nsmenu-accessibility-insertion-point-line-number (c-> nsmenu? exact-integer?)]
  [nsmenu-accessibility-label (c-> nsmenu? (or/c nsstring? objc-nil?))]
  [nsmenu-accessibility-label-ui-elements (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-label-value (c-> nsmenu? real?)]
  [nsmenu-accessibility-layout-point-for-screen-point (c-> nsmenu? any/c any/c)]
  [nsmenu-accessibility-layout-size-for-screen-size (c-> nsmenu? any/c any/c)]
  [nsmenu-accessibility-line-for-index (c-> nsmenu? exact-integer? exact-integer?)]
  [nsmenu-accessibility-linked-ui-elements (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-main-window (c-> nsmenu? any/c)]
  [nsmenu-accessibility-marker-group-ui-element (c-> nsmenu? any/c)]
  [nsmenu-accessibility-marker-type-description (c-> nsmenu? (or/c nsstring? objc-nil?))]
  [nsmenu-accessibility-marker-ui-elements (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-marker-values (c-> nsmenu? any/c)]
  [nsmenu-accessibility-max-value (c-> nsmenu? any/c)]
  [nsmenu-accessibility-menu-bar (c-> nsmenu? any/c)]
  [nsmenu-accessibility-min-value (c-> nsmenu? any/c)]
  [nsmenu-accessibility-minimize-button (c-> nsmenu? any/c)]
  [nsmenu-accessibility-next-contents (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-number-of-characters (c-> nsmenu? exact-integer?)]
  [nsmenu-accessibility-orientation (c-> nsmenu? exact-integer?)]
  [nsmenu-accessibility-overflow-button (c-> nsmenu? any/c)]
  [nsmenu-accessibility-parent (c-> nsmenu? any/c)]
  [nsmenu-accessibility-perform-cancel (c-> nsmenu? boolean?)]
  [nsmenu-accessibility-perform-confirm (c-> nsmenu? boolean?)]
  [nsmenu-accessibility-perform-decrement (c-> nsmenu? boolean?)]
  [nsmenu-accessibility-perform-delete (c-> nsmenu? boolean?)]
  [nsmenu-accessibility-perform-increment (c-> nsmenu? boolean?)]
  [nsmenu-accessibility-perform-pick (c-> nsmenu? boolean?)]
  [nsmenu-accessibility-perform-press (c-> nsmenu? boolean?)]
  [nsmenu-accessibility-perform-raise (c-> nsmenu? boolean?)]
  [nsmenu-accessibility-perform-show-alternate-ui (c-> nsmenu? boolean?)]
  [nsmenu-accessibility-perform-show-default-ui (c-> nsmenu? boolean?)]
  [nsmenu-accessibility-perform-show-menu (c-> nsmenu? boolean?)]
  [nsmenu-accessibility-placeholder-value (c-> nsmenu? (or/c nsstring? objc-nil?))]
  [nsmenu-accessibility-previous-contents (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-proxy (c-> nsmenu? any/c)]
  [nsmenu-accessibility-rtf-for-range (c-> nsmenu? any/c (or/c nsdata? objc-nil?))]
  [nsmenu-accessibility-range-for-index (c-> nsmenu? exact-integer? any/c)]
  [nsmenu-accessibility-range-for-line (c-> nsmenu? exact-integer? any/c)]
  [nsmenu-accessibility-range-for-position (c-> nsmenu? any/c any/c)]
  [nsmenu-accessibility-role (c-> nsmenu? (or/c nsstring? objc-nil?))]
  [nsmenu-accessibility-role-description (c-> nsmenu? (or/c nsstring? objc-nil?))]
  [nsmenu-accessibility-row-count (c-> nsmenu? exact-integer?)]
  [nsmenu-accessibility-row-header-ui-elements (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-row-index-range (c-> nsmenu? any/c)]
  [nsmenu-accessibility-rows (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-ruler-marker-type (c-> nsmenu? exact-integer?)]
  [nsmenu-accessibility-screen-point-for-layout-point (c-> nsmenu? any/c any/c)]
  [nsmenu-accessibility-screen-size-for-layout-size (c-> nsmenu? any/c any/c)]
  [nsmenu-accessibility-search-button (c-> nsmenu? any/c)]
  [nsmenu-accessibility-search-menu (c-> nsmenu? any/c)]
  [nsmenu-accessibility-selected-cells (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-selected-children (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-selected-columns (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-selected-rows (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-selected-text (c-> nsmenu? (or/c nsstring? objc-nil?))]
  [nsmenu-accessibility-selected-text-range (c-> nsmenu? any/c)]
  [nsmenu-accessibility-selected-text-ranges (c-> nsmenu? any/c)]
  [nsmenu-accessibility-serves-as-title-for-ui-elements (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-shared-character-range (c-> nsmenu? any/c)]
  [nsmenu-accessibility-shared-focus-elements (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-shared-text-ui-elements (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-shown-menu (c-> nsmenu? any/c)]
  [nsmenu-accessibility-sort-direction (c-> nsmenu? exact-integer?)]
  [nsmenu-accessibility-splitters (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-string-for-range (c-> nsmenu? any/c (or/c nsstring? objc-nil?))]
  [nsmenu-accessibility-style-range-for-index (c-> nsmenu? exact-integer? any/c)]
  [nsmenu-accessibility-subrole (c-> nsmenu? (or/c nsstring? objc-nil?))]
  [nsmenu-accessibility-tabs (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-title (c-> nsmenu? (or/c nsstring? objc-nil?))]
  [nsmenu-accessibility-title-ui-element (c-> nsmenu? any/c)]
  [nsmenu-accessibility-toolbar-button (c-> nsmenu? any/c)]
  [nsmenu-accessibility-top-level-ui-element (c-> nsmenu? any/c)]
  [nsmenu-accessibility-url (c-> nsmenu? (or/c nsurl? objc-nil?))]
  [nsmenu-accessibility-unit-description (c-> nsmenu? (or/c nsstring? objc-nil?))]
  [nsmenu-accessibility-units (c-> nsmenu? exact-integer?)]
  [nsmenu-accessibility-user-input-labels (c-> nsmenu? any/c)]
  [nsmenu-accessibility-value (c-> nsmenu? any/c)]
  [nsmenu-accessibility-value-description (c-> nsmenu? (or/c nsstring? objc-nil?))]
  [nsmenu-accessibility-vertical-scroll-bar (c-> nsmenu? any/c)]
  [nsmenu-accessibility-vertical-unit-description (c-> nsmenu? (or/c nsstring? objc-nil?))]
  [nsmenu-accessibility-vertical-units (c-> nsmenu? exact-integer?)]
  [nsmenu-accessibility-visible-cells (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-visible-character-range (c-> nsmenu? any/c)]
  [nsmenu-accessibility-visible-children (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-visible-columns (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-visible-rows (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-warning-value (c-> nsmenu? any/c)]
  [nsmenu-accessibility-window (c-> nsmenu? any/c)]
  [nsmenu-accessibility-windows (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-zoom-button (c-> nsmenu? any/c)]
  [nsmenu-add-item! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-add-item-with-title-action-key-equivalent! (c-> nsmenu? (or/c string? objc-object? #f) string? (or/c string? objc-object? #f) (or/c nsmenuitem? objc-nil?))]
  [nsmenu-appearance (c-> nsmenu? (or/c nsappearance? objc-nil?))]
  [nsmenu-cancel-tracking (c-> nsmenu? void?)]
  [nsmenu-cancel-tracking-without-animation (c-> nsmenu? void?)]
  [nsmenu-copy-with-zone (c-> nsmenu? (or/c cpointer? #f) any/c)]
  [nsmenu-effective-appearance (c-> nsmenu? (or/c nsappearance? objc-nil?))]
  [nsmenu-encode-with-coder (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-identifier (c-> nsmenu? (or/c nsstring? objc-nil?))]
  [nsmenu-index-of-item (c-> nsmenu? (or/c string? objc-object? #f) exact-integer?)]
  [nsmenu-index-of-item-with-represented-object (c-> nsmenu? (or/c string? objc-object? #f) exact-integer?)]
  [nsmenu-index-of-item-with-submenu (c-> nsmenu? (or/c string? objc-object? #f) exact-integer?)]
  [nsmenu-index-of-item-with-tag (c-> nsmenu? exact-integer? exact-integer?)]
  [nsmenu-index-of-item-with-target-and-action (c-> nsmenu? (or/c string? objc-object? #f) string? exact-integer?)]
  [nsmenu-index-of-item-with-title (c-> nsmenu? (or/c string? objc-object? #f) exact-integer?)]
  [nsmenu-insert-item-at-index! (c-> nsmenu? (or/c string? objc-object? #f) exact-integer? void?)]
  [nsmenu-insert-item-with-title-action-key-equivalent-at-index! (c-> nsmenu? (or/c string? objc-object? #f) string? (or/c string? objc-object? #f) exact-integer? (or/c nsmenuitem? objc-nil?))]
  [nsmenu-is-accessibility-alternate-ui-visible (c-> nsmenu? boolean?)]
  [nsmenu-is-accessibility-disclosed (c-> nsmenu? boolean?)]
  [nsmenu-is-accessibility-edited (c-> nsmenu? boolean?)]
  [nsmenu-is-accessibility-element (c-> nsmenu? boolean?)]
  [nsmenu-is-accessibility-enabled (c-> nsmenu? boolean?)]
  [nsmenu-is-accessibility-expanded (c-> nsmenu? boolean?)]
  [nsmenu-is-accessibility-focused (c-> nsmenu? boolean?)]
  [nsmenu-is-accessibility-frontmost (c-> nsmenu? boolean?)]
  [nsmenu-is-accessibility-hidden (c-> nsmenu? boolean?)]
  [nsmenu-is-accessibility-main (c-> nsmenu? boolean?)]
  [nsmenu-is-accessibility-minimized (c-> nsmenu? boolean?)]
  [nsmenu-is-accessibility-modal (c-> nsmenu? boolean?)]
  [nsmenu-is-accessibility-ordered-by-row (c-> nsmenu? boolean?)]
  [nsmenu-is-accessibility-protected-content (c-> nsmenu? boolean?)]
  [nsmenu-is-accessibility-required (c-> nsmenu? boolean?)]
  [nsmenu-is-accessibility-selected (c-> nsmenu? boolean?)]
  [nsmenu-is-accessibility-selector-allowed (c-> nsmenu? string? boolean?)]
  [nsmenu-item-at-index (c-> nsmenu? exact-integer? (or/c nsmenuitem? objc-nil?))]
  [nsmenu-item-changed (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-item-with-tag (c-> nsmenu? exact-integer? (or/c nsmenuitem? objc-nil?))]
  [nsmenu-item-with-title (c-> nsmenu? (or/c string? objc-object? #f) (or/c nsmenuitem? objc-nil?))]
  [nsmenu-perform-action-for-item-at-index! (c-> nsmenu? exact-integer? void?)]
  [nsmenu-perform-key-equivalent! (c-> nsmenu? (or/c string? objc-object? #f) boolean?)]
  [nsmenu-pop-up-menu-positioning-item-at-location-in-view (c-> nsmenu? (or/c string? objc-object? #f) any/c (or/c string? objc-object? #f) boolean?)]
  [nsmenu-remove-all-items! (c-> nsmenu? void?)]
  [nsmenu-remove-item! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-remove-item-at-index! (c-> nsmenu? exact-integer? void?)]
  [nsmenu-set-accessibility-activation-point! (c-> nsmenu? any/c void?)]
  [nsmenu-set-accessibility-allowed-values! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-alternate-ui-visible! (c-> nsmenu? boolean? void?)]
  [nsmenu-set-accessibility-application-focused-ui-element! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-attributed-user-input-labels! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-cancel-button! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-children! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-children-in-navigation-order! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-clear-button! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-close-button! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-column-count! (c-> nsmenu? exact-integer? void?)]
  [nsmenu-set-accessibility-column-header-ui-elements! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-column-index-range! (c-> nsmenu? any/c void?)]
  [nsmenu-set-accessibility-column-titles! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-columns! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-contents! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-critical-value! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-custom-actions! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-custom-rotors! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-decrement-button! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-default-button! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-disclosed! (c-> nsmenu? boolean? void?)]
  [nsmenu-set-accessibility-disclosed-by-row! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-disclosed-rows! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-disclosure-level! (c-> nsmenu? exact-integer? void?)]
  [nsmenu-set-accessibility-document! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-edited! (c-> nsmenu? boolean? void?)]
  [nsmenu-set-accessibility-element! (c-> nsmenu? boolean? void?)]
  [nsmenu-set-accessibility-enabled! (c-> nsmenu? boolean? void?)]
  [nsmenu-set-accessibility-expanded! (c-> nsmenu? boolean? void?)]
  [nsmenu-set-accessibility-extras-menu-bar! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-filename! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-focused! (c-> nsmenu? boolean? void?)]
  [nsmenu-set-accessibility-focused-window! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-frame! (c-> nsmenu? any/c void?)]
  [nsmenu-set-accessibility-frontmost! (c-> nsmenu? boolean? void?)]
  [nsmenu-set-accessibility-full-screen-button! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-grow-area! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-handles! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-header! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-help! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-hidden! (c-> nsmenu? boolean? void?)]
  [nsmenu-set-accessibility-horizontal-scroll-bar! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-horizontal-unit-description! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-horizontal-units! (c-> nsmenu? exact-integer? void?)]
  [nsmenu-set-accessibility-identifier! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-increment-button! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-index! (c-> nsmenu? exact-integer? void?)]
  [nsmenu-set-accessibility-insertion-point-line-number! (c-> nsmenu? exact-integer? void?)]
  [nsmenu-set-accessibility-label! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-label-ui-elements! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-label-value! (c-> nsmenu? real? void?)]
  [nsmenu-set-accessibility-linked-ui-elements! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-main! (c-> nsmenu? boolean? void?)]
  [nsmenu-set-accessibility-main-window! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-marker-group-ui-element! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-marker-type-description! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-marker-ui-elements! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-marker-values! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-max-value! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-menu-bar! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-min-value! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-minimize-button! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-minimized! (c-> nsmenu? boolean? void?)]
  [nsmenu-set-accessibility-modal! (c-> nsmenu? boolean? void?)]
  [nsmenu-set-accessibility-next-contents! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-number-of-characters! (c-> nsmenu? exact-integer? void?)]
  [nsmenu-set-accessibility-ordered-by-row! (c-> nsmenu? boolean? void?)]
  [nsmenu-set-accessibility-orientation! (c-> nsmenu? exact-integer? void?)]
  [nsmenu-set-accessibility-overflow-button! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-parent! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-placeholder-value! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-previous-contents! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-protected-content! (c-> nsmenu? boolean? void?)]
  [nsmenu-set-accessibility-proxy! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-required! (c-> nsmenu? boolean? void?)]
  [nsmenu-set-accessibility-role! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-role-description! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-row-count! (c-> nsmenu? exact-integer? void?)]
  [nsmenu-set-accessibility-row-header-ui-elements! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-row-index-range! (c-> nsmenu? any/c void?)]
  [nsmenu-set-accessibility-rows! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-ruler-marker-type! (c-> nsmenu? exact-integer? void?)]
  [nsmenu-set-accessibility-search-button! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-search-menu! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-selected! (c-> nsmenu? boolean? void?)]
  [nsmenu-set-accessibility-selected-cells! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-selected-children! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-selected-columns! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-selected-rows! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-selected-text! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-selected-text-range! (c-> nsmenu? any/c void?)]
  [nsmenu-set-accessibility-selected-text-ranges! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-serves-as-title-for-ui-elements! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-shared-character-range! (c-> nsmenu? any/c void?)]
  [nsmenu-set-accessibility-shared-focus-elements! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-shared-text-ui-elements! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-shown-menu! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-sort-direction! (c-> nsmenu? exact-integer? void?)]
  [nsmenu-set-accessibility-splitters! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-subrole! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-tabs! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-title! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-title-ui-element! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-toolbar-button! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-top-level-ui-element! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-url! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-unit-description! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-units! (c-> nsmenu? exact-integer? void?)]
  [nsmenu-set-accessibility-user-input-labels! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-value! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-value-description! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-vertical-scroll-bar! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-vertical-unit-description! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-vertical-units! (c-> nsmenu? exact-integer? void?)]
  [nsmenu-set-accessibility-visible-cells! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-visible-character-range! (c-> nsmenu? any/c void?)]
  [nsmenu-set-accessibility-visible-children! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-visible-columns! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-visible-rows! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-warning-value! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-window! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-windows! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-accessibility-zoom-button! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-appearance! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-identifier! (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-set-submenu-for-item! (c-> nsmenu? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsmenu-update (c-> nsmenu? void?)]
  [nsmenu-menu-bar-visible (c-> boolean?)]
  [nsmenu-pop-up-context-menu-with-event-for-view (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsmenu-pop-up-context-menu-with-event-for-view-with-font (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsmenu-set-menu-bar-visible! (c-> boolean? void?)]
  )

;; --- Class reference ---
(import-class NSMenu)

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
(define _msg-17  ; (_fun _pointer _pointer _double -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _double -> _void)))
(define _msg-18  ; (_fun _pointer _pointer _float -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _float -> _void)))
(define _msg-19  ; (_fun _pointer _pointer _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _bool)))
(define _msg-20  ; (_fun _pointer _pointer _id -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id -> _int64)))
(define _msg-21  ; (_fun _pointer _pointer _id _NSPoint _id -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _NSPoint _id -> _bool)))
(define _msg-22  ; (_fun _pointer _pointer _id _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _int64 -> _void)))
(define _msg-23  ; (_fun _pointer _pointer _id _pointer -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer -> _int64)))
(define _msg-24  ; (_fun _pointer _pointer _id _pointer _id -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer _id -> _id)))
(define _msg-25  ; (_fun _pointer _pointer _id _pointer _id _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _id _pointer _id _int64 -> _id)))
(define _msg-26  ; (_fun _pointer _pointer _int64 -> _NSRange)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _NSRange)))
(define _msg-27  ; (_fun _pointer _pointer _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _id)))
(define _msg-28  ; (_fun _pointer _pointer _int64 -> _int64)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _int64)))
(define _msg-29  ; (_fun _pointer _pointer _int64 -> _void)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 -> _void)))
(define _msg-30  ; (_fun _pointer _pointer _int64 _int64 -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _int64 _int64 -> _id)))
(define _msg-31  ; (_fun _pointer _pointer _pointer -> _bool)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _bool)))
(define _msg-32  ; (_fun _pointer _pointer _pointer -> _id)
  (get-ffi-obj "objc_msgSend" _objc-lib (_fun _pointer _pointer _pointer -> _id)))

;; --- Constructors ---
(define (make-nsmenu-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSMenu alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nsmenu-init-with-title title)
  (wrap-objc-object
   (tell (tell NSMenu alloc)
         initWithTitle: (coerce-arg title))
   #:retained #t))


;; --- Properties ---
(define (nsmenu-allows-context-menu-plug-ins self)
  (tell #:type _bool (coerce-arg self) allowsContextMenuPlugIns))
(define (nsmenu-set-allows-context-menu-plug-ins! self value)
  (_msg-16 (coerce-arg self) (sel_registerName "setAllowsContextMenuPlugIns:") value))
(define (nsmenu-autoenables-items self)
  (tell #:type _bool (coerce-arg self) autoenablesItems))
(define (nsmenu-set-autoenables-items! self value)
  (_msg-16 (coerce-arg self) (sel_registerName "setAutoenablesItems:") value))
(define (nsmenu-automatically-inserts-writing-tools-items self)
  (tell #:type _bool (coerce-arg self) automaticallyInsertsWritingToolsItems))
(define (nsmenu-set-automatically-inserts-writing-tools-items! self value)
  (_msg-16 (coerce-arg self) (sel_registerName "setAutomaticallyInsertsWritingToolsItems:") value))
(define (nsmenu-delegate self)
  (wrap-objc-object
   (tell (coerce-arg self) delegate)))
(define (nsmenu-set-delegate! self value)
  (tell #:type _void (coerce-arg self) setDelegate: (coerce-arg value)))
(define (nsmenu-font self)
  (wrap-objc-object
   (tell (coerce-arg self) font)))
(define (nsmenu-set-font! self value)
  (tell #:type _void (coerce-arg self) setFont: (coerce-arg value)))
(define (nsmenu-highlighted-item self)
  (wrap-objc-object
   (tell (coerce-arg self) highlightedItem)))
(define (nsmenu-item-array self)
  (wrap-objc-object
   (tell (coerce-arg self) itemArray)))
(define (nsmenu-set-item-array! self value)
  (tell #:type _void (coerce-arg self) setItemArray: (coerce-arg value)))
(define (nsmenu-menu-bar-height self)
  (tell #:type _double (coerce-arg self) menuBarHeight))
(define (nsmenu-menu-changed-messages-enabled self)
  (tell #:type _bool (coerce-arg self) menuChangedMessagesEnabled))
(define (nsmenu-set-menu-changed-messages-enabled! self value)
  (_msg-16 (coerce-arg self) (sel_registerName "setMenuChangedMessagesEnabled:") value))
(define (nsmenu-minimum-width self)
  (tell #:type _double (coerce-arg self) minimumWidth))
(define (nsmenu-set-minimum-width! self value)
  (_msg-17 (coerce-arg self) (sel_registerName "setMinimumWidth:") value))
(define (nsmenu-number-of-items self)
  (tell #:type _int64 (coerce-arg self) numberOfItems))
(define (nsmenu-presentation-style self)
  (tell #:type _int64 (coerce-arg self) presentationStyle))
(define (nsmenu-set-presentation-style! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setPresentationStyle:") value))
(define (nsmenu-properties-to-update self)
  (tell #:type _uint64 (coerce-arg self) propertiesToUpdate))
(define (nsmenu-selected-items self)
  (wrap-objc-object
   (tell (coerce-arg self) selectedItems)))
(define (nsmenu-set-selected-items! self value)
  (tell #:type _void (coerce-arg self) setSelectedItems: (coerce-arg value)))
(define (nsmenu-selection-mode self)
  (tell #:type _int64 (coerce-arg self) selectionMode))
(define (nsmenu-set-selection-mode! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setSelectionMode:") value))
(define (nsmenu-shows-state-column self)
  (tell #:type _bool (coerce-arg self) showsStateColumn))
(define (nsmenu-set-shows-state-column! self value)
  (_msg-16 (coerce-arg self) (sel_registerName "setShowsStateColumn:") value))
(define (nsmenu-size self)
  (tell #:type _NSSize (coerce-arg self) size))
(define (nsmenu-supermenu self)
  (wrap-objc-object
   (tell (coerce-arg self) supermenu)))
(define (nsmenu-set-supermenu! self value)
  (tell #:type _void (coerce-arg self) setSupermenu: (coerce-arg value)))
(define (nsmenu-title self)
  (wrap-objc-object
   (tell (coerce-arg self) title)))
(define (nsmenu-set-title! self value)
  (tell #:type _void (coerce-arg self) setTitle: (coerce-arg value)))
(define (nsmenu-torn-off self)
  (tell #:type _bool (coerce-arg self) tornOff))
(define (nsmenu-user-interface-layout-direction self)
  (tell #:type _int64 (coerce-arg self) userInterfaceLayoutDirection))
(define (nsmenu-set-user-interface-layout-direction! self value)
  (_msg-29 (coerce-arg self) (sel_registerName "setUserInterfaceLayoutDirection:") value))

;; --- Instance methods ---
(define (nsmenu-accessibility-activation-point self)
  (_msg-0 (coerce-arg self) (sel_registerName "accessibilityActivationPoint")))
(define (nsmenu-accessibility-allowed-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAllowedValues)))
(define (nsmenu-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityApplicationFocusedUIElement)))
(define (nsmenu-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (_msg-12 (coerce-arg self) (sel_registerName "accessibilityAttributedStringForRange:") range)
   ))
(define (nsmenu-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityAttributedUserInputLabels)))
(define (nsmenu-accessibility-cancel-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCancelButton)))
(define (nsmenu-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (_msg-30 (coerce-arg self) (sel_registerName "accessibilityCellForColumn:row:") column row)
   ))
(define (nsmenu-accessibility-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildren)))
(define (nsmenu-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityChildrenInNavigationOrder)))
(define (nsmenu-accessibility-clear-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityClearButton)))
(define (nsmenu-accessibility-close-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCloseButton)))
(define (nsmenu-accessibility-column-count self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityColumnCount")))
(define (nsmenu-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnHeaderUIElements)))
(define (nsmenu-accessibility-column-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityColumnIndexRange")))
(define (nsmenu-accessibility-column-titles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumnTitles)))
(define (nsmenu-accessibility-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityColumns)))
(define (nsmenu-accessibility-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityContents)))
(define (nsmenu-accessibility-critical-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCriticalValue)))
(define (nsmenu-accessibility-custom-actions self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomActions)))
(define (nsmenu-accessibility-custom-rotors self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityCustomRotors)))
(define (nsmenu-accessibility-decrement-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDecrementButton)))
(define (nsmenu-accessibility-default-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDefaultButton)))
(define (nsmenu-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedByRow)))
(define (nsmenu-accessibility-disclosed-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDisclosedRows)))
(define (nsmenu-accessibility-disclosure-level self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityDisclosureLevel")))
(define (nsmenu-accessibility-document self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityDocument)))
(define (nsmenu-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityExtrasMenuBar)))
(define (nsmenu-accessibility-filename self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFilename)))
(define (nsmenu-accessibility-focused-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFocusedWindow)))
(define (nsmenu-accessibility-frame self)
  (_msg-2 (coerce-arg self) (sel_registerName "accessibilityFrame")))
(define (nsmenu-accessibility-frame-for-range self range)
  (_msg-11 (coerce-arg self) (sel_registerName "accessibilityFrameForRange:") range))
(define (nsmenu-accessibility-full-screen-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityFullScreenButton)))
(define (nsmenu-accessibility-grow-area self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityGrowArea)))
(define (nsmenu-accessibility-handles self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHandles)))
(define (nsmenu-accessibility-header self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHeader)))
(define (nsmenu-accessibility-help self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHelp)))
(define (nsmenu-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalScrollBar)))
(define (nsmenu-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityHorizontalUnitDescription)))
(define (nsmenu-accessibility-horizontal-units self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityHorizontalUnits")))
(define (nsmenu-accessibility-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIdentifier)))
(define (nsmenu-accessibility-increment-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityIncrementButton)))
(define (nsmenu-accessibility-index self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityIndex")))
(define (nsmenu-accessibility-insertion-point-line-number self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityInsertionPointLineNumber")))
(define (nsmenu-accessibility-label self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabel)))
(define (nsmenu-accessibility-label-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLabelUIElements)))
(define (nsmenu-accessibility-label-value self)
  (_msg-6 (coerce-arg self) (sel_registerName "accessibilityLabelValue")))
(define (nsmenu-accessibility-layout-point-for-screen-point self point)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityLayoutPointForScreenPoint:") point))
(define (nsmenu-accessibility-layout-size-for-screen-size self size)
  (_msg-15 (coerce-arg self) (sel_registerName "accessibilityLayoutSizeForScreenSize:") size))
(define (nsmenu-accessibility-line-for-index self index)
  (_msg-28 (coerce-arg self) (sel_registerName "accessibilityLineForIndex:") index))
(define (nsmenu-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityLinkedUIElements)))
(define (nsmenu-accessibility-main-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMainWindow)))
(define (nsmenu-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerGroupUIElement)))
(define (nsmenu-accessibility-marker-type-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerTypeDescription)))
(define (nsmenu-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerUIElements)))
(define (nsmenu-accessibility-marker-values self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMarkerValues)))
(define (nsmenu-accessibility-max-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMaxValue)))
(define (nsmenu-accessibility-menu-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMenuBar)))
(define (nsmenu-accessibility-min-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinValue)))
(define (nsmenu-accessibility-minimize-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityMinimizeButton)))
(define (nsmenu-accessibility-next-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityNextContents)))
(define (nsmenu-accessibility-number-of-characters self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityNumberOfCharacters")))
(define (nsmenu-accessibility-orientation self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityOrientation")))
(define (nsmenu-accessibility-overflow-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityOverflowButton)))
(define (nsmenu-accessibility-parent self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityParent)))
(define (nsmenu-accessibility-perform-cancel self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformCancel")))
(define (nsmenu-accessibility-perform-confirm self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformConfirm")))
(define (nsmenu-accessibility-perform-decrement self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformDecrement")))
(define (nsmenu-accessibility-perform-delete self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformDelete")))
(define (nsmenu-accessibility-perform-increment self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformIncrement")))
(define (nsmenu-accessibility-perform-pick self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformPick")))
(define (nsmenu-accessibility-perform-press self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformPress")))
(define (nsmenu-accessibility-perform-raise self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformRaise")))
(define (nsmenu-accessibility-perform-show-alternate-ui self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformShowAlternateUI")))
(define (nsmenu-accessibility-perform-show-default-ui self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformShowDefaultUI")))
(define (nsmenu-accessibility-perform-show-menu self)
  (_msg-4 (coerce-arg self) (sel_registerName "accessibilityPerformShowMenu")))
(define (nsmenu-accessibility-placeholder-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPlaceholderValue)))
(define (nsmenu-accessibility-previous-contents self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityPreviousContents)))
(define (nsmenu-accessibility-proxy self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityProxy)))
(define (nsmenu-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (_msg-12 (coerce-arg self) (sel_registerName "accessibilityRTFForRange:") range)
   ))
(define (nsmenu-accessibility-range-for-index self index)
  (_msg-26 (coerce-arg self) (sel_registerName "accessibilityRangeForIndex:") index))
(define (nsmenu-accessibility-range-for-line self line)
  (_msg-26 (coerce-arg self) (sel_registerName "accessibilityRangeForLine:") line))
(define (nsmenu-accessibility-range-for-position self point)
  (_msg-9 (coerce-arg self) (sel_registerName "accessibilityRangeForPosition:") point))
(define (nsmenu-accessibility-role self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRole)))
(define (nsmenu-accessibility-role-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRoleDescription)))
(define (nsmenu-accessibility-row-count self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityRowCount")))
(define (nsmenu-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRowHeaderUIElements)))
(define (nsmenu-accessibility-row-index-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityRowIndexRange")))
(define (nsmenu-accessibility-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityRows)))
(define (nsmenu-accessibility-ruler-marker-type self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityRulerMarkerType")))
(define (nsmenu-accessibility-screen-point-for-layout-point self point)
  (_msg-8 (coerce-arg self) (sel_registerName "accessibilityScreenPointForLayoutPoint:") point))
(define (nsmenu-accessibility-screen-size-for-layout-size self size)
  (_msg-15 (coerce-arg self) (sel_registerName "accessibilityScreenSizeForLayoutSize:") size))
(define (nsmenu-accessibility-search-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchButton)))
(define (nsmenu-accessibility-search-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySearchMenu)))
(define (nsmenu-accessibility-selected-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedCells)))
(define (nsmenu-accessibility-selected-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedChildren)))
(define (nsmenu-accessibility-selected-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedColumns)))
(define (nsmenu-accessibility-selected-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedRows)))
(define (nsmenu-accessibility-selected-text self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedText)))
(define (nsmenu-accessibility-selected-text-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySelectedTextRange")))
(define (nsmenu-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySelectedTextRanges)))
(define (nsmenu-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityServesAsTitleForUIElements)))
(define (nsmenu-accessibility-shared-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilitySharedCharacterRange")))
(define (nsmenu-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedFocusElements)))
(define (nsmenu-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySharedTextUIElements)))
(define (nsmenu-accessibility-shown-menu self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityShownMenu)))
(define (nsmenu-accessibility-sort-direction self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilitySortDirection")))
(define (nsmenu-accessibility-splitters self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySplitters)))
(define (nsmenu-accessibility-string-for-range self range)
  (wrap-objc-object
   (_msg-12 (coerce-arg self) (sel_registerName "accessibilityStringForRange:") range)
   ))
(define (nsmenu-accessibility-style-range-for-index self index)
  (_msg-26 (coerce-arg self) (sel_registerName "accessibilityStyleRangeForIndex:") index))
(define (nsmenu-accessibility-subrole self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilitySubrole)))
(define (nsmenu-accessibility-tabs self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTabs)))
(define (nsmenu-accessibility-title self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitle)))
(define (nsmenu-accessibility-title-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTitleUIElement)))
(define (nsmenu-accessibility-toolbar-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityToolbarButton)))
(define (nsmenu-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityTopLevelUIElement)))
(define (nsmenu-accessibility-url self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityURL)))
(define (nsmenu-accessibility-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUnitDescription)))
(define (nsmenu-accessibility-units self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityUnits")))
(define (nsmenu-accessibility-user-input-labels self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityUserInputLabels)))
(define (nsmenu-accessibility-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValue)))
(define (nsmenu-accessibility-value-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityValueDescription)))
(define (nsmenu-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalScrollBar)))
(define (nsmenu-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVerticalUnitDescription)))
(define (nsmenu-accessibility-vertical-units self)
  (_msg-7 (coerce-arg self) (sel_registerName "accessibilityVerticalUnits")))
(define (nsmenu-accessibility-visible-cells self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleCells)))
(define (nsmenu-accessibility-visible-character-range self)
  (_msg-1 (coerce-arg self) (sel_registerName "accessibilityVisibleCharacterRange")))
(define (nsmenu-accessibility-visible-children self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleChildren)))
(define (nsmenu-accessibility-visible-columns self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleColumns)))
(define (nsmenu-accessibility-visible-rows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityVisibleRows)))
(define (nsmenu-accessibility-warning-value self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWarningValue)))
(define (nsmenu-accessibility-window self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindow)))
(define (nsmenu-accessibility-windows self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityWindows)))
(define (nsmenu-accessibility-zoom-button self)
  (wrap-objc-object
   (tell (coerce-arg self) accessibilityZoomButton)))
(define (nsmenu-add-item! self new-item)
  (tell #:type _void (coerce-arg self) addItem: (coerce-arg new-item)))
(define (nsmenu-add-item-with-title-action-key-equivalent! self string selector char-code)
  (wrap-objc-object
   (_msg-24 (coerce-arg self) (sel_registerName "addItemWithTitle:action:keyEquivalent:") (coerce-arg string) (sel_registerName selector) (coerce-arg char-code))
   ))
(define (nsmenu-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) appearance)))
(define (nsmenu-cancel-tracking self)
  (tell #:type _void (coerce-arg self) cancelTracking))
(define (nsmenu-cancel-tracking-without-animation self)
  (tell #:type _void (coerce-arg self) cancelTrackingWithoutAnimation))
(define (nsmenu-copy-with-zone self zone)
  (wrap-objc-object
   (_msg-32 (coerce-arg self) (sel_registerName "copyWithZone:") zone)
   #:retained #t))
(define (nsmenu-effective-appearance self)
  (wrap-objc-object
   (tell (coerce-arg self) effectiveAppearance)))
(define (nsmenu-encode-with-coder self coder)
  (tell #:type _void (coerce-arg self) encodeWithCoder: (coerce-arg coder)))
(define (nsmenu-identifier self)
  (wrap-objc-object
   (tell (coerce-arg self) identifier)))
(define (nsmenu-index-of-item self item)
  (_msg-20 (coerce-arg self) (sel_registerName "indexOfItem:") (coerce-arg item)))
(define (nsmenu-index-of-item-with-represented-object self object)
  (_msg-20 (coerce-arg self) (sel_registerName "indexOfItemWithRepresentedObject:") (coerce-arg object)))
(define (nsmenu-index-of-item-with-submenu self submenu)
  (_msg-20 (coerce-arg self) (sel_registerName "indexOfItemWithSubmenu:") (coerce-arg submenu)))
(define (nsmenu-index-of-item-with-tag self tag)
  (_msg-28 (coerce-arg self) (sel_registerName "indexOfItemWithTag:") tag))
(define (nsmenu-index-of-item-with-target-and-action self target action-selector)
  (_msg-23 (coerce-arg self) (sel_registerName "indexOfItemWithTarget:andAction:") (coerce-arg target) (sel_registerName action-selector)))
(define (nsmenu-index-of-item-with-title self title)
  (_msg-20 (coerce-arg self) (sel_registerName "indexOfItemWithTitle:") (coerce-arg title)))
(define (nsmenu-insert-item-at-index! self new-item index)
  (_msg-22 (coerce-arg self) (sel_registerName "insertItem:atIndex:") (coerce-arg new-item) index))
(define (nsmenu-insert-item-with-title-action-key-equivalent-at-index! self string selector char-code index)
  (wrap-objc-object
   (_msg-25 (coerce-arg self) (sel_registerName "insertItemWithTitle:action:keyEquivalent:atIndex:") (coerce-arg string) (sel_registerName selector) (coerce-arg char-code) index)
   ))
(define (nsmenu-is-accessibility-alternate-ui-visible self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityAlternateUIVisible")))
(define (nsmenu-is-accessibility-disclosed self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityDisclosed")))
(define (nsmenu-is-accessibility-edited self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityEdited")))
(define (nsmenu-is-accessibility-element self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityElement")))
(define (nsmenu-is-accessibility-enabled self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityEnabled")))
(define (nsmenu-is-accessibility-expanded self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityExpanded")))
(define (nsmenu-is-accessibility-focused self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityFocused")))
(define (nsmenu-is-accessibility-frontmost self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityFrontmost")))
(define (nsmenu-is-accessibility-hidden self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityHidden")))
(define (nsmenu-is-accessibility-main self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityMain")))
(define (nsmenu-is-accessibility-minimized self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityMinimized")))
(define (nsmenu-is-accessibility-modal self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityModal")))
(define (nsmenu-is-accessibility-ordered-by-row self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityOrderedByRow")))
(define (nsmenu-is-accessibility-protected-content self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityProtectedContent")))
(define (nsmenu-is-accessibility-required self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilityRequired")))
(define (nsmenu-is-accessibility-selected self)
  (_msg-4 (coerce-arg self) (sel_registerName "isAccessibilitySelected")))
(define (nsmenu-is-accessibility-selector-allowed self selector)
  (_msg-31 (coerce-arg self) (sel_registerName "isAccessibilitySelectorAllowed:") (sel_registerName selector)))
(define (nsmenu-item-at-index self index)
  (wrap-objc-object
   (_msg-27 (coerce-arg self) (sel_registerName "itemAtIndex:") index)
   ))
(define (nsmenu-item-changed self item)
  (tell #:type _void (coerce-arg self) itemChanged: (coerce-arg item)))
(define (nsmenu-item-with-tag self tag)
  (wrap-objc-object
   (_msg-27 (coerce-arg self) (sel_registerName "itemWithTag:") tag)
   ))
(define (nsmenu-item-with-title self title)
  (wrap-objc-object
   (tell (coerce-arg self) itemWithTitle: (coerce-arg title))))
(define (nsmenu-perform-action-for-item-at-index! self index)
  (_msg-29 (coerce-arg self) (sel_registerName "performActionForItemAtIndex:") index))
(define (nsmenu-perform-key-equivalent! self event)
  (_msg-19 (coerce-arg self) (sel_registerName "performKeyEquivalent:") (coerce-arg event)))
(define (nsmenu-pop-up-menu-positioning-item-at-location-in-view self item location view)
  (_msg-21 (coerce-arg self) (sel_registerName "popUpMenuPositioningItem:atLocation:inView:") (coerce-arg item) location (coerce-arg view)))
(define (nsmenu-remove-all-items! self)
  (tell #:type _void (coerce-arg self) removeAllItems))
(define (nsmenu-remove-item! self item)
  (tell #:type _void (coerce-arg self) removeItem: (coerce-arg item)))
(define (nsmenu-remove-item-at-index! self index)
  (_msg-29 (coerce-arg self) (sel_registerName "removeItemAtIndex:") index))
(define (nsmenu-set-accessibility-activation-point! self accessibility-activation-point)
  (_msg-10 (coerce-arg self) (sel_registerName "setAccessibilityActivationPoint:") accessibility-activation-point))
(define (nsmenu-set-accessibility-allowed-values! self accessibility-allowed-values)
  (tell #:type _void (coerce-arg self) setAccessibilityAllowedValues: (coerce-arg accessibility-allowed-values)))
(define (nsmenu-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityAlternateUIVisible:") accessibility-alternate-ui-visible))
(define (nsmenu-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityApplicationFocusedUIElement: (coerce-arg accessibility-application-focused-ui-element)))
(define (nsmenu-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityAttributedUserInputLabels: (coerce-arg accessibility-attributed-user-input-labels)))
(define (nsmenu-set-accessibility-cancel-button! self accessibility-cancel-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCancelButton: (coerce-arg accessibility-cancel-button)))
(define (nsmenu-set-accessibility-children! self accessibility-children)
  (tell #:type _void (coerce-arg self) setAccessibilityChildren: (coerce-arg accessibility-children)))
(define (nsmenu-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (tell #:type _void (coerce-arg self) setAccessibilityChildrenInNavigationOrder: (coerce-arg accessibility-children-in-navigation-order)))
(define (nsmenu-set-accessibility-clear-button! self accessibility-clear-button)
  (tell #:type _void (coerce-arg self) setAccessibilityClearButton: (coerce-arg accessibility-clear-button)))
(define (nsmenu-set-accessibility-close-button! self accessibility-close-button)
  (tell #:type _void (coerce-arg self) setAccessibilityCloseButton: (coerce-arg accessibility-close-button)))
(define (nsmenu-set-accessibility-column-count! self accessibility-column-count)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityColumnCount:") accessibility-column-count))
(define (nsmenu-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnHeaderUIElements: (coerce-arg accessibility-column-header-ui-elements)))
(define (nsmenu-set-accessibility-column-index-range! self accessibility-column-index-range)
  (_msg-13 (coerce-arg self) (sel_registerName "setAccessibilityColumnIndexRange:") accessibility-column-index-range))
(define (nsmenu-set-accessibility-column-titles! self accessibility-column-titles)
  (tell #:type _void (coerce-arg self) setAccessibilityColumnTitles: (coerce-arg accessibility-column-titles)))
(define (nsmenu-set-accessibility-columns! self accessibility-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityColumns: (coerce-arg accessibility-columns)))
(define (nsmenu-set-accessibility-contents! self accessibility-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityContents: (coerce-arg accessibility-contents)))
(define (nsmenu-set-accessibility-critical-value! self accessibility-critical-value)
  (tell #:type _void (coerce-arg self) setAccessibilityCriticalValue: (coerce-arg accessibility-critical-value)))
(define (nsmenu-set-accessibility-custom-actions! self accessibility-custom-actions)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomActions: (coerce-arg accessibility-custom-actions)))
(define (nsmenu-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (tell #:type _void (coerce-arg self) setAccessibilityCustomRotors: (coerce-arg accessibility-custom-rotors)))
(define (nsmenu-set-accessibility-decrement-button! self accessibility-decrement-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDecrementButton: (coerce-arg accessibility-decrement-button)))
(define (nsmenu-set-accessibility-default-button! self accessibility-default-button)
  (tell #:type _void (coerce-arg self) setAccessibilityDefaultButton: (coerce-arg accessibility-default-button)))
(define (nsmenu-set-accessibility-disclosed! self accessibility-disclosed)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityDisclosed:") accessibility-disclosed))
(define (nsmenu-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedByRow: (coerce-arg accessibility-disclosed-by-row)))
(define (nsmenu-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityDisclosedRows: (coerce-arg accessibility-disclosed-rows)))
(define (nsmenu-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityDisclosureLevel:") accessibility-disclosure-level))
(define (nsmenu-set-accessibility-document! self accessibility-document)
  (tell #:type _void (coerce-arg self) setAccessibilityDocument: (coerce-arg accessibility-document)))
(define (nsmenu-set-accessibility-edited! self accessibility-edited)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityEdited:") accessibility-edited))
(define (nsmenu-set-accessibility-element! self accessibility-element)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityElement:") accessibility-element))
(define (nsmenu-set-accessibility-enabled! self accessibility-enabled)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityEnabled:") accessibility-enabled))
(define (nsmenu-set-accessibility-expanded! self accessibility-expanded)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityExpanded:") accessibility-expanded))
(define (nsmenu-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityExtrasMenuBar: (coerce-arg accessibility-extras-menu-bar)))
(define (nsmenu-set-accessibility-filename! self accessibility-filename)
  (tell #:type _void (coerce-arg self) setAccessibilityFilename: (coerce-arg accessibility-filename)))
(define (nsmenu-set-accessibility-focused! self accessibility-focused)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityFocused:") accessibility-focused))
(define (nsmenu-set-accessibility-focused-window! self accessibility-focused-window)
  (tell #:type _void (coerce-arg self) setAccessibilityFocusedWindow: (coerce-arg accessibility-focused-window)))
(define (nsmenu-set-accessibility-frame! self accessibility-frame)
  (_msg-14 (coerce-arg self) (sel_registerName "setAccessibilityFrame:") accessibility-frame))
(define (nsmenu-set-accessibility-frontmost! self accessibility-frontmost)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityFrontmost:") accessibility-frontmost))
(define (nsmenu-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (tell #:type _void (coerce-arg self) setAccessibilityFullScreenButton: (coerce-arg accessibility-full-screen-button)))
(define (nsmenu-set-accessibility-grow-area! self accessibility-grow-area)
  (tell #:type _void (coerce-arg self) setAccessibilityGrowArea: (coerce-arg accessibility-grow-area)))
(define (nsmenu-set-accessibility-handles! self accessibility-handles)
  (tell #:type _void (coerce-arg self) setAccessibilityHandles: (coerce-arg accessibility-handles)))
(define (nsmenu-set-accessibility-header! self accessibility-header)
  (tell #:type _void (coerce-arg self) setAccessibilityHeader: (coerce-arg accessibility-header)))
(define (nsmenu-set-accessibility-help! self accessibility-help)
  (tell #:type _void (coerce-arg self) setAccessibilityHelp: (coerce-arg accessibility-help)))
(define (nsmenu-set-accessibility-hidden! self accessibility-hidden)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityHidden:") accessibility-hidden))
(define (nsmenu-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalScrollBar: (coerce-arg accessibility-horizontal-scroll-bar)))
(define (nsmenu-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityHorizontalUnitDescription: (coerce-arg accessibility-horizontal-unit-description)))
(define (nsmenu-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityHorizontalUnits:") accessibility-horizontal-units))
(define (nsmenu-set-accessibility-identifier! self accessibility-identifier)
  (tell #:type _void (coerce-arg self) setAccessibilityIdentifier: (coerce-arg accessibility-identifier)))
(define (nsmenu-set-accessibility-increment-button! self accessibility-increment-button)
  (tell #:type _void (coerce-arg self) setAccessibilityIncrementButton: (coerce-arg accessibility-increment-button)))
(define (nsmenu-set-accessibility-index! self accessibility-index)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityIndex:") accessibility-index))
(define (nsmenu-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityInsertionPointLineNumber:") accessibility-insertion-point-line-number))
(define (nsmenu-set-accessibility-label! self accessibility-label)
  (tell #:type _void (coerce-arg self) setAccessibilityLabel: (coerce-arg accessibility-label)))
(define (nsmenu-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLabelUIElements: (coerce-arg accessibility-label-ui-elements)))
(define (nsmenu-set-accessibility-label-value! self accessibility-label-value)
  (_msg-18 (coerce-arg self) (sel_registerName "setAccessibilityLabelValue:") accessibility-label-value))
(define (nsmenu-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityLinkedUIElements: (coerce-arg accessibility-linked-ui-elements)))
(define (nsmenu-set-accessibility-main! self accessibility-main)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityMain:") accessibility-main))
(define (nsmenu-set-accessibility-main-window! self accessibility-main-window)
  (tell #:type _void (coerce-arg self) setAccessibilityMainWindow: (coerce-arg accessibility-main-window)))
(define (nsmenu-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerGroupUIElement: (coerce-arg accessibility-marker-group-ui-element)))
(define (nsmenu-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerTypeDescription: (coerce-arg accessibility-marker-type-description)))
(define (nsmenu-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerUIElements: (coerce-arg accessibility-marker-ui-elements)))
(define (nsmenu-set-accessibility-marker-values! self accessibility-marker-values)
  (tell #:type _void (coerce-arg self) setAccessibilityMarkerValues: (coerce-arg accessibility-marker-values)))
(define (nsmenu-set-accessibility-max-value! self accessibility-max-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMaxValue: (coerce-arg accessibility-max-value)))
(define (nsmenu-set-accessibility-menu-bar! self accessibility-menu-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityMenuBar: (coerce-arg accessibility-menu-bar)))
(define (nsmenu-set-accessibility-min-value! self accessibility-min-value)
  (tell #:type _void (coerce-arg self) setAccessibilityMinValue: (coerce-arg accessibility-min-value)))
(define (nsmenu-set-accessibility-minimize-button! self accessibility-minimize-button)
  (tell #:type _void (coerce-arg self) setAccessibilityMinimizeButton: (coerce-arg accessibility-minimize-button)))
(define (nsmenu-set-accessibility-minimized! self accessibility-minimized)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityMinimized:") accessibility-minimized))
(define (nsmenu-set-accessibility-modal! self accessibility-modal)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityModal:") accessibility-modal))
(define (nsmenu-set-accessibility-next-contents! self accessibility-next-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityNextContents: (coerce-arg accessibility-next-contents)))
(define (nsmenu-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityNumberOfCharacters:") accessibility-number-of-characters))
(define (nsmenu-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityOrderedByRow:") accessibility-ordered-by-row))
(define (nsmenu-set-accessibility-orientation! self accessibility-orientation)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityOrientation:") accessibility-orientation))
(define (nsmenu-set-accessibility-overflow-button! self accessibility-overflow-button)
  (tell #:type _void (coerce-arg self) setAccessibilityOverflowButton: (coerce-arg accessibility-overflow-button)))
(define (nsmenu-set-accessibility-parent! self accessibility-parent)
  (tell #:type _void (coerce-arg self) setAccessibilityParent: (coerce-arg accessibility-parent)))
(define (nsmenu-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (tell #:type _void (coerce-arg self) setAccessibilityPlaceholderValue: (coerce-arg accessibility-placeholder-value)))
(define (nsmenu-set-accessibility-previous-contents! self accessibility-previous-contents)
  (tell #:type _void (coerce-arg self) setAccessibilityPreviousContents: (coerce-arg accessibility-previous-contents)))
(define (nsmenu-set-accessibility-protected-content! self accessibility-protected-content)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityProtectedContent:") accessibility-protected-content))
(define (nsmenu-set-accessibility-proxy! self accessibility-proxy)
  (tell #:type _void (coerce-arg self) setAccessibilityProxy: (coerce-arg accessibility-proxy)))
(define (nsmenu-set-accessibility-required! self accessibility-required)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilityRequired:") accessibility-required))
(define (nsmenu-set-accessibility-role! self accessibility-role)
  (tell #:type _void (coerce-arg self) setAccessibilityRole: (coerce-arg accessibility-role)))
(define (nsmenu-set-accessibility-role-description! self accessibility-role-description)
  (tell #:type _void (coerce-arg self) setAccessibilityRoleDescription: (coerce-arg accessibility-role-description)))
(define (nsmenu-set-accessibility-row-count! self accessibility-row-count)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityRowCount:") accessibility-row-count))
(define (nsmenu-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityRowHeaderUIElements: (coerce-arg accessibility-row-header-ui-elements)))
(define (nsmenu-set-accessibility-row-index-range! self accessibility-row-index-range)
  (_msg-13 (coerce-arg self) (sel_registerName "setAccessibilityRowIndexRange:") accessibility-row-index-range))
(define (nsmenu-set-accessibility-rows! self accessibility-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityRows: (coerce-arg accessibility-rows)))
(define (nsmenu-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityRulerMarkerType:") accessibility-ruler-marker-type))
(define (nsmenu-set-accessibility-search-button! self accessibility-search-button)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchButton: (coerce-arg accessibility-search-button)))
(define (nsmenu-set-accessibility-search-menu! self accessibility-search-menu)
  (tell #:type _void (coerce-arg self) setAccessibilitySearchMenu: (coerce-arg accessibility-search-menu)))
(define (nsmenu-set-accessibility-selected! self accessibility-selected)
  (_msg-16 (coerce-arg self) (sel_registerName "setAccessibilitySelected:") accessibility-selected))
(define (nsmenu-set-accessibility-selected-cells! self accessibility-selected-cells)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedCells: (coerce-arg accessibility-selected-cells)))
(define (nsmenu-set-accessibility-selected-children! self accessibility-selected-children)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedChildren: (coerce-arg accessibility-selected-children)))
(define (nsmenu-set-accessibility-selected-columns! self accessibility-selected-columns)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedColumns: (coerce-arg accessibility-selected-columns)))
(define (nsmenu-set-accessibility-selected-rows! self accessibility-selected-rows)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedRows: (coerce-arg accessibility-selected-rows)))
(define (nsmenu-set-accessibility-selected-text! self accessibility-selected-text)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedText: (coerce-arg accessibility-selected-text)))
(define (nsmenu-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (_msg-13 (coerce-arg self) (sel_registerName "setAccessibilitySelectedTextRange:") accessibility-selected-text-range))
(define (nsmenu-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (tell #:type _void (coerce-arg self) setAccessibilitySelectedTextRanges: (coerce-arg accessibility-selected-text-ranges)))
(define (nsmenu-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilityServesAsTitleForUIElements: (coerce-arg accessibility-serves-as-title-for-ui-elements)))
(define (nsmenu-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (_msg-13 (coerce-arg self) (sel_registerName "setAccessibilitySharedCharacterRange:") accessibility-shared-character-range))
(define (nsmenu-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedFocusElements: (coerce-arg accessibility-shared-focus-elements)))
(define (nsmenu-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (tell #:type _void (coerce-arg self) setAccessibilitySharedTextUIElements: (coerce-arg accessibility-shared-text-ui-elements)))
(define (nsmenu-set-accessibility-shown-menu! self accessibility-shown-menu)
  (tell #:type _void (coerce-arg self) setAccessibilityShownMenu: (coerce-arg accessibility-shown-menu)))
(define (nsmenu-set-accessibility-sort-direction! self accessibility-sort-direction)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilitySortDirection:") accessibility-sort-direction))
(define (nsmenu-set-accessibility-splitters! self accessibility-splitters)
  (tell #:type _void (coerce-arg self) setAccessibilitySplitters: (coerce-arg accessibility-splitters)))
(define (nsmenu-set-accessibility-subrole! self accessibility-subrole)
  (tell #:type _void (coerce-arg self) setAccessibilitySubrole: (coerce-arg accessibility-subrole)))
(define (nsmenu-set-accessibility-tabs! self accessibility-tabs)
  (tell #:type _void (coerce-arg self) setAccessibilityTabs: (coerce-arg accessibility-tabs)))
(define (nsmenu-set-accessibility-title! self accessibility-title)
  (tell #:type _void (coerce-arg self) setAccessibilityTitle: (coerce-arg accessibility-title)))
(define (nsmenu-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTitleUIElement: (coerce-arg accessibility-title-ui-element)))
(define (nsmenu-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (tell #:type _void (coerce-arg self) setAccessibilityToolbarButton: (coerce-arg accessibility-toolbar-button)))
(define (nsmenu-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (tell #:type _void (coerce-arg self) setAccessibilityTopLevelUIElement: (coerce-arg accessibility-top-level-ui-element)))
(define (nsmenu-set-accessibility-url! self accessibility-url)
  (tell #:type _void (coerce-arg self) setAccessibilityURL: (coerce-arg accessibility-url)))
(define (nsmenu-set-accessibility-unit-description! self accessibility-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityUnitDescription: (coerce-arg accessibility-unit-description)))
(define (nsmenu-set-accessibility-units! self accessibility-units)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityUnits:") accessibility-units))
(define (nsmenu-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (tell #:type _void (coerce-arg self) setAccessibilityUserInputLabels: (coerce-arg accessibility-user-input-labels)))
(define (nsmenu-set-accessibility-value! self accessibility-value)
  (tell #:type _void (coerce-arg self) setAccessibilityValue: (coerce-arg accessibility-value)))
(define (nsmenu-set-accessibility-value-description! self accessibility-value-description)
  (tell #:type _void (coerce-arg self) setAccessibilityValueDescription: (coerce-arg accessibility-value-description)))
(define (nsmenu-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalScrollBar: (coerce-arg accessibility-vertical-scroll-bar)))
(define (nsmenu-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (tell #:type _void (coerce-arg self) setAccessibilityVerticalUnitDescription: (coerce-arg accessibility-vertical-unit-description)))
(define (nsmenu-set-accessibility-vertical-units! self accessibility-vertical-units)
  (_msg-29 (coerce-arg self) (sel_registerName "setAccessibilityVerticalUnits:") accessibility-vertical-units))
(define (nsmenu-set-accessibility-visible-cells! self accessibility-visible-cells)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleCells: (coerce-arg accessibility-visible-cells)))
(define (nsmenu-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (_msg-13 (coerce-arg self) (sel_registerName "setAccessibilityVisibleCharacterRange:") accessibility-visible-character-range))
(define (nsmenu-set-accessibility-visible-children! self accessibility-visible-children)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleChildren: (coerce-arg accessibility-visible-children)))
(define (nsmenu-set-accessibility-visible-columns! self accessibility-visible-columns)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleColumns: (coerce-arg accessibility-visible-columns)))
(define (nsmenu-set-accessibility-visible-rows! self accessibility-visible-rows)
  (tell #:type _void (coerce-arg self) setAccessibilityVisibleRows: (coerce-arg accessibility-visible-rows)))
(define (nsmenu-set-accessibility-warning-value! self accessibility-warning-value)
  (tell #:type _void (coerce-arg self) setAccessibilityWarningValue: (coerce-arg accessibility-warning-value)))
(define (nsmenu-set-accessibility-window! self accessibility-window)
  (tell #:type _void (coerce-arg self) setAccessibilityWindow: (coerce-arg accessibility-window)))
(define (nsmenu-set-accessibility-windows! self accessibility-windows)
  (tell #:type _void (coerce-arg self) setAccessibilityWindows: (coerce-arg accessibility-windows)))
(define (nsmenu-set-accessibility-zoom-button! self accessibility-zoom-button)
  (tell #:type _void (coerce-arg self) setAccessibilityZoomButton: (coerce-arg accessibility-zoom-button)))
(define (nsmenu-set-appearance! self appearance)
  (tell #:type _void (coerce-arg self) setAppearance: (coerce-arg appearance)))
(define (nsmenu-set-identifier! self identifier)
  (tell #:type _void (coerce-arg self) setIdentifier: (coerce-arg identifier)))
(define (nsmenu-set-submenu-for-item! self menu item)
  (tell #:type _void (coerce-arg self) setSubmenu: (coerce-arg menu) forItem: (coerce-arg item)))
(define (nsmenu-update self)
  (tell #:type _void (coerce-arg self) update))

;; --- Class methods ---
(define (nsmenu-menu-bar-visible)
  (_msg-4 NSMenu (sel_registerName "menuBarVisible")))
(define (nsmenu-pop-up-context-menu-with-event-for-view menu event view)
  (tell #:type _void NSMenu popUpContextMenu: (coerce-arg menu) withEvent: (coerce-arg event) forView: (coerce-arg view)))
(define (nsmenu-pop-up-context-menu-with-event-for-view-with-font menu event view font)
  (tell #:type _void NSMenu popUpContextMenu: (coerce-arg menu) withEvent: (coerce-arg event) forView: (coerce-arg view) withFont: (coerce-arg font)))
(define (nsmenu-set-menu-bar-visible! visible)
  (_msg-16 NSMenu (sel_registerName "setMenuBarVisible:") visible))
