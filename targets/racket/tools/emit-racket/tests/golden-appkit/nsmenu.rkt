#lang racket/base
;; Generated binding for NSMenu (AppKit)
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
  [nsmenu-item-array (c-> nsmenu? (or/c nsarray? objc-nil?))]
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
  [nsmenu-selected-items (c-> nsmenu? (or/c nsarray? objc-nil?))]
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
  [nsmenu-accessibility-allowed-values (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-application-focused-ui-element (c-> nsmenu? any/c)]
  [nsmenu-accessibility-attributed-string-for-range (c-> nsmenu? any/c (or/c nsattributedstring? objc-nil?))]
  [nsmenu-accessibility-attributed-user-input-labels (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-cancel-button (c-> nsmenu? any/c)]
  [nsmenu-accessibility-cell-for-column-row (c-> nsmenu? exact-integer? exact-integer? any/c)]
  [nsmenu-accessibility-children (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-children-in-navigation-order (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-clear-button (c-> nsmenu? any/c)]
  [nsmenu-accessibility-close-button (c-> nsmenu? any/c)]
  [nsmenu-accessibility-column-count (c-> nsmenu? exact-integer?)]
  [nsmenu-accessibility-column-header-ui-elements (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-column-index-range (c-> nsmenu? any/c)]
  [nsmenu-accessibility-column-titles (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-columns (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-contents (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-critical-value (c-> nsmenu? any/c)]
  [nsmenu-accessibility-custom-actions (c-> nsmenu? (or/c nsarray? objc-nil?))]
  [nsmenu-accessibility-custom-rotors (c-> nsmenu? (or/c nsarray? objc-nil?))]
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
  [nsmenu-accessibility-selected-text-ranges (c-> nsmenu? (or/c nsarray? objc-nil?))]
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
  [nsmenu-accessibility-user-input-labels (c-> nsmenu? (or/c nsarray? objc-nil?))]
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
  [nsmenu-submenu-action (c-> nsmenu? (or/c string? objc-object? #f) void?)]
  [nsmenu-update (c-> nsmenu? void?)]
  [nsmenu-menu-bar-visible (c-> boolean?)]
  [nsmenu-palette-menu-with-colors-titles-selection-handler (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c procedure? #f) any/c)]
  [nsmenu-palette-menu-with-colors-titles-template-image-selection-handler (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c procedure? #f) any/c)]
  [nsmenu-pop-up-context-menu-with-event-for-view (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsmenu-pop-up-context-menu-with-event-for-view-with-font (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nsmenu-set-menu-bar-visible! (c-> boolean? void?)]
  )

;; --- Class reference ---
(import-class NSMenu)

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
(define-aw-msg aw_racket_msg_0_v (-> ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_b (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_P_q (-> ptr_t ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_q (-> ptr_t ptr_t ptr_t ptr_t int64_t))
(define-aw-msg aw_racket_msg_PP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PPP_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPPP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PPPP_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPPq_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_Pq_v (-> ptr_t ptr_t ptr_t int64_t void_t))
(define-aw-msg aw_racket_msg_POP_b (-> ptr_t ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_b_v (-> ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_q_P (-> ptr_t ptr_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_q_q (-> ptr_t ptr_t int64_t int64_t))
(define-aw-msg aw_racket_msg_q_G (-> ptr_t ptr_t int64_t ptr_t void_t))
(define-aw-msg aw_racket_msg_q_v (-> ptr_t ptr_t int64_t void_t))
(define-aw-msg aw_racket_msg_qq_P (-> ptr_t ptr_t int64_t int64_t ptr_t))
(define-aw-msg aw_racket_msg_f_v (-> ptr_t ptr_t float_t void_t))
(define-aw-msg aw_racket_msg_d_v (-> ptr_t ptr_t double_t void_t))
(define-aw-msg aw_racket_msg_R_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_O_O (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_O_G (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_O_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_Z_Z (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_G_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_G_R (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_G_v (-> ptr_t ptr_t ptr_t void_t))

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
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "allowsContextMenuPlugIns"))))
(define (nsmenu-set-allows-context-menu-plug-ins! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAllowsContextMenuPlugIns:")) value))
(define (nsmenu-autoenables-items self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "autoenablesItems"))))
(define (nsmenu-set-autoenables-items! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutoenablesItems:")) value))
(define (nsmenu-automatically-inserts-writing-tools-items self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "automaticallyInsertsWritingToolsItems"))))
(define (nsmenu-set-automatically-inserts-writing-tools-items! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAutomaticallyInsertsWritingToolsItems:")) value))
(define (nsmenu-delegate self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "delegate"))))))
(define (nsmenu-set-delegate! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDelegate:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenu-font self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "font"))))))
(define (nsmenu-set-font! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setFont:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenu-highlighted-item self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "highlightedItem"))))))
(define (nsmenu-item-array self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "itemArray"))))))
(define (nsmenu-set-item-array! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setItemArray:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenu-menu-bar-height self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menuBarHeight"))))
(define (nsmenu-menu-changed-messages-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menuChangedMessagesEnabled"))))
(define (nsmenu-set-menu-changed-messages-enabled! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMenuChangedMessagesEnabled:")) value))
(define (nsmenu-minimum-width self)
  (aw_racket_msg_0_d (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "minimumWidth"))))
(define (nsmenu-set-minimum-width! self value)
  (aw_racket_msg_d_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMinimumWidth:")) value))
(define (nsmenu-number-of-items self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "numberOfItems"))))
(define (nsmenu-presentation-style self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "presentationStyle"))))
(define (nsmenu-set-presentation-style! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPresentationStyle:")) value))
(define (nsmenu-properties-to-update self)
  (aw_racket_msg_0_Q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "propertiesToUpdate"))))
(define (nsmenu-selected-items self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectedItems"))))))
(define (nsmenu-set-selected-items! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSelectedItems:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenu-selection-mode self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectionMode"))))
(define (nsmenu-set-selection-mode! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSelectionMode:")) value))
(define (nsmenu-shows-state-column self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showsStateColumn"))))
(define (nsmenu-set-shows-state-column! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShowsStateColumn:")) value))
(define (nsmenu-size self)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_0_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "size")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsmenu-supermenu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "supermenu"))))))
(define (nsmenu-set-supermenu! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSupermenu:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenu-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "title"))))))
(define (nsmenu-set-title! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTitle:")) (id->ffi2-ptr (coerce-arg value))))
(define (nsmenu-torn-off self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tornOff"))))
(define (nsmenu-user-interface-layout-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userInterfaceLayoutDirection"))))
(define (nsmenu-set-user-interface-layout-direction! self value)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserInterfaceLayoutDirection:")) value))

;; --- Instance methods ---
(define (nsmenu-accessibility-activation-point self)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_0_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityActivationPoint")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsmenu-accessibility-allowed-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAllowedValues"))))
   ))
(define (nsmenu-accessibility-application-focused-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityApplicationFocusedUIElement"))))
   ))
(define (nsmenu-accessibility-attributed-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nsmenu-accessibility-attributed-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityAttributedUserInputLabels"))))
   ))
(define (nsmenu-accessibility-cancel-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCancelButton"))))
   ))
(define (nsmenu-accessibility-cell-for-column-row self column row)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_qq_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCellForColumn:row:")) column row))
   ))
(define (nsmenu-accessibility-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildren"))))
   ))
(define (nsmenu-accessibility-children-in-navigation-order self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityChildrenInNavigationOrder"))))
   ))
(define (nsmenu-accessibility-clear-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityClearButton"))))
   ))
(define (nsmenu-accessibility-close-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCloseButton"))))
   ))
(define (nsmenu-accessibility-column-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnCount"))))
(define (nsmenu-accessibility-column-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnHeaderUIElements"))))
   ))
(define (nsmenu-accessibility-column-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsmenu-accessibility-column-titles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumnTitles"))))
   ))
(define (nsmenu-accessibility-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityColumns"))))
   ))
(define (nsmenu-accessibility-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityContents"))))
   ))
(define (nsmenu-accessibility-critical-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCriticalValue"))))
   ))
(define (nsmenu-accessibility-custom-actions self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomActions"))))
   ))
(define (nsmenu-accessibility-custom-rotors self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityCustomRotors"))))
   ))
(define (nsmenu-accessibility-decrement-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDecrementButton"))))
   ))
(define (nsmenu-accessibility-default-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDefaultButton"))))
   ))
(define (nsmenu-accessibility-disclosed-by-row self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedByRow"))))
   ))
(define (nsmenu-accessibility-disclosed-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosedRows"))))
   ))
(define (nsmenu-accessibility-disclosure-level self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDisclosureLevel"))))
(define (nsmenu-accessibility-document self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityDocument"))))
   ))
(define (nsmenu-accessibility-extras-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityExtrasMenuBar"))))
   ))
(define (nsmenu-accessibility-filename self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFilename"))))
   ))
(define (nsmenu-accessibility-focused-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFocusedWindow"))))
   ))
(define (nsmenu-accessibility-frame self)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_0_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrame")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsmenu-accessibility-frame-for-range self range)
  (let ([buf (malloc _NSRect)])
    (aw_racket_msg_G_R (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFrameForRange:")) (id->ffi2-ptr range) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRect)))
(define (nsmenu-accessibility-full-screen-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityFullScreenButton"))))
   ))
(define (nsmenu-accessibility-grow-area self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityGrowArea"))))
   ))
(define (nsmenu-accessibility-handles self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHandles"))))
   ))
(define (nsmenu-accessibility-header self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHeader"))))
   ))
(define (nsmenu-accessibility-help self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHelp"))))
   ))
(define (nsmenu-accessibility-horizontal-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalScrollBar"))))
   ))
(define (nsmenu-accessibility-horizontal-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnitDescription"))))
   ))
(define (nsmenu-accessibility-horizontal-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityHorizontalUnits"))))
(define (nsmenu-accessibility-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIdentifier"))))
   ))
(define (nsmenu-accessibility-increment-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIncrementButton"))))
   ))
(define (nsmenu-accessibility-index self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityIndex"))))
(define (nsmenu-accessibility-insertion-point-line-number self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityInsertionPointLineNumber"))))
(define (nsmenu-accessibility-label self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabel"))))
   ))
(define (nsmenu-accessibility-label-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelUIElements"))))
   ))
(define (nsmenu-accessibility-label-value self)
  (aw_racket_msg_0_f (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLabelValue"))))
(define (nsmenu-accessibility-layout-point-for-screen-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutPointForScreenPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsmenu-accessibility-layout-size-for-screen-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLayoutSizeForScreenSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsmenu-accessibility-line-for-index self index)
  (aw_racket_msg_q_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLineForIndex:")) index))
(define (nsmenu-accessibility-linked-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityLinkedUIElements"))))
   ))
(define (nsmenu-accessibility-main-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMainWindow"))))
   ))
(define (nsmenu-accessibility-marker-group-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerGroupUIElement"))))
   ))
(define (nsmenu-accessibility-marker-type-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerTypeDescription"))))
   ))
(define (nsmenu-accessibility-marker-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerUIElements"))))
   ))
(define (nsmenu-accessibility-marker-values self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMarkerValues"))))
   ))
(define (nsmenu-accessibility-max-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMaxValue"))))
   ))
(define (nsmenu-accessibility-menu-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMenuBar"))))
   ))
(define (nsmenu-accessibility-min-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinValue"))))
   ))
(define (nsmenu-accessibility-minimize-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityMinimizeButton"))))
   ))
(define (nsmenu-accessibility-next-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNextContents"))))
   ))
(define (nsmenu-accessibility-number-of-characters self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityNumberOfCharacters"))))
(define (nsmenu-accessibility-orientation self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOrientation"))))
(define (nsmenu-accessibility-overflow-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityOverflowButton"))))
   ))
(define (nsmenu-accessibility-parent self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityParent"))))
   ))
(define (nsmenu-accessibility-perform-cancel self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformCancel"))))
(define (nsmenu-accessibility-perform-confirm self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformConfirm"))))
(define (nsmenu-accessibility-perform-decrement self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDecrement"))))
(define (nsmenu-accessibility-perform-delete self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformDelete"))))
(define (nsmenu-accessibility-perform-increment self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformIncrement"))))
(define (nsmenu-accessibility-perform-pick self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPick"))))
(define (nsmenu-accessibility-perform-press self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformPress"))))
(define (nsmenu-accessibility-perform-raise self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformRaise"))))
(define (nsmenu-accessibility-perform-show-alternate-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowAlternateUI"))))
(define (nsmenu-accessibility-perform-show-default-ui self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowDefaultUI"))))
(define (nsmenu-accessibility-perform-show-menu self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPerformShowMenu"))))
(define (nsmenu-accessibility-placeholder-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPlaceholderValue"))))
   ))
(define (nsmenu-accessibility-previous-contents self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityPreviousContents"))))
   ))
(define (nsmenu-accessibility-proxy self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityProxy"))))
   ))
(define (nsmenu-accessibility-rtf-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRTFForRange:")) (id->ffi2-ptr range)))
   ))
(define (nsmenu-accessibility-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsmenu-accessibility-range-for-line self line)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForLine:")) line (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsmenu-accessibility-range-for-position self point)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_O_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRangeForPosition:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsmenu-accessibility-role self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRole"))))
   ))
(define (nsmenu-accessibility-role-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRoleDescription"))))
   ))
(define (nsmenu-accessibility-row-count self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowCount"))))
(define (nsmenu-accessibility-row-header-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowHeaderUIElements"))))
   ))
(define (nsmenu-accessibility-row-index-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRowIndexRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsmenu-accessibility-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRows"))))
   ))
(define (nsmenu-accessibility-ruler-marker-type self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityRulerMarkerType"))))
(define (nsmenu-accessibility-screen-point-for-layout-point self point)
  (let ([buf (malloc _NSPoint)])
    (aw_racket_msg_O_O (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenPointForLayoutPoint:")) (id->ffi2-ptr point) (cpointer->ptr_t buf))
    (ptr-ref buf _NSPoint)))
(define (nsmenu-accessibility-screen-size-for-layout-size self size)
  (let ([buf (malloc _NSSize)])
    (aw_racket_msg_Z_Z (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityScreenSizeForLayoutSize:")) (id->ffi2-ptr size) (cpointer->ptr_t buf))
    (ptr-ref buf _NSSize)))
(define (nsmenu-accessibility-search-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchButton"))))
   ))
(define (nsmenu-accessibility-search-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySearchMenu"))))
   ))
(define (nsmenu-accessibility-selected-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedCells"))))
   ))
(define (nsmenu-accessibility-selected-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedChildren"))))
   ))
(define (nsmenu-accessibility-selected-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedColumns"))))
   ))
(define (nsmenu-accessibility-selected-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedRows"))))
   ))
(define (nsmenu-accessibility-selected-text self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedText"))))
   ))
(define (nsmenu-accessibility-selected-text-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsmenu-accessibility-selected-text-ranges self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySelectedTextRanges"))))
   ))
(define (nsmenu-accessibility-serves-as-title-for-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityServesAsTitleForUIElements"))))
   ))
(define (nsmenu-accessibility-shared-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsmenu-accessibility-shared-focus-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedFocusElements"))))
   ))
(define (nsmenu-accessibility-shared-text-ui-elements self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySharedTextUIElements"))))
   ))
(define (nsmenu-accessibility-shown-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityShownMenu"))))
   ))
(define (nsmenu-accessibility-sort-direction self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySortDirection"))))
(define (nsmenu-accessibility-splitters self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySplitters"))))
   ))
(define (nsmenu-accessibility-string-for-range self range)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_G_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStringForRange:")) (id->ffi2-ptr range)))
   ))
(define (nsmenu-accessibility-style-range-for-index self index)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_q_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityStyleRangeForIndex:")) index (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsmenu-accessibility-subrole self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilitySubrole"))))
   ))
(define (nsmenu-accessibility-tabs self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTabs"))))
   ))
(define (nsmenu-accessibility-title self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitle"))))
   ))
(define (nsmenu-accessibility-title-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTitleUIElement"))))
   ))
(define (nsmenu-accessibility-toolbar-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityToolbarButton"))))
   ))
(define (nsmenu-accessibility-top-level-ui-element self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityTopLevelUIElement"))))
   ))
(define (nsmenu-accessibility-url self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityURL"))))
   ))
(define (nsmenu-accessibility-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnitDescription"))))
   ))
(define (nsmenu-accessibility-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUnits"))))
(define (nsmenu-accessibility-user-input-labels self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityUserInputLabels"))))
   ))
(define (nsmenu-accessibility-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValue"))))
   ))
(define (nsmenu-accessibility-value-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityValueDescription"))))
   ))
(define (nsmenu-accessibility-vertical-scroll-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalScrollBar"))))
   ))
(define (nsmenu-accessibility-vertical-unit-description self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnitDescription"))))
   ))
(define (nsmenu-accessibility-vertical-units self)
  (aw_racket_msg_0_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVerticalUnits"))))
(define (nsmenu-accessibility-visible-cells self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCells"))))
   ))
(define (nsmenu-accessibility-visible-character-range self)
  (let ([buf (malloc _NSRange)])
    (aw_racket_msg_0_G (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleCharacterRange")) (cpointer->ptr_t buf))
    (ptr-ref buf _NSRange)))
(define (nsmenu-accessibility-visible-children self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleChildren"))))
   ))
(define (nsmenu-accessibility-visible-columns self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleColumns"))))
   ))
(define (nsmenu-accessibility-visible-rows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityVisibleRows"))))
   ))
(define (nsmenu-accessibility-warning-value self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWarningValue"))))
   ))
(define (nsmenu-accessibility-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindow"))))
   ))
(define (nsmenu-accessibility-windows self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityWindows"))))
   ))
(define (nsmenu-accessibility-zoom-button self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "accessibilityZoomButton"))))
   ))
(define (nsmenu-add-item! self new-item)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addItem:")) (id->ffi2-ptr (coerce-arg new-item))))
(define (nsmenu-add-item-with-title-action-key-equivalent! self string selector char-code)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "addItemWithTitle:action:keyEquivalent:")) (id->ffi2-ptr (coerce-arg string)) (id->ffi2-ptr (sel_registerName selector)) (id->ffi2-ptr (coerce-arg char-code))))
   ))
(define (nsmenu-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "appearance"))))
   ))
(define (nsmenu-cancel-tracking self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cancelTracking"))))
(define (nsmenu-cancel-tracking-without-animation self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cancelTrackingWithoutAnimation"))))
(define (nsmenu-copy-with-zone self zone)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "copyWithZone:")) (id->ffi2-ptr zone)))
   #:retained #t))
(define (nsmenu-effective-appearance self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "effectiveAppearance"))))
   ))
(define (nsmenu-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nsmenu-identifier self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "identifier"))))
   ))
(define (nsmenu-index-of-item self item)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indexOfItem:")) (id->ffi2-ptr (coerce-arg item))))
(define (nsmenu-index-of-item-with-represented-object self object)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indexOfItemWithRepresentedObject:")) (id->ffi2-ptr (coerce-arg object))))
(define (nsmenu-index-of-item-with-submenu self submenu)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indexOfItemWithSubmenu:")) (id->ffi2-ptr (coerce-arg submenu))))
(define (nsmenu-index-of-item-with-tag self tag)
  (aw_racket_msg_q_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indexOfItemWithTag:")) tag))
(define (nsmenu-index-of-item-with-target-and-action self target action-selector)
  (aw_racket_msg_PP_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indexOfItemWithTarget:andAction:")) (id->ffi2-ptr (coerce-arg target)) (id->ffi2-ptr (sel_registerName action-selector))))
(define (nsmenu-index-of-item-with-title self title)
  (aw_racket_msg_P_q (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indexOfItemWithTitle:")) (id->ffi2-ptr (coerce-arg title))))
(define (nsmenu-insert-item-at-index! self new-item index)
  (aw_racket_msg_Pq_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertItem:atIndex:")) (id->ffi2-ptr (coerce-arg new-item)) index))
(define (nsmenu-insert-item-with-title-action-key-equivalent-at-index! self string selector char-code index)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPPq_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertItemWithTitle:action:keyEquivalent:atIndex:")) (id->ffi2-ptr (coerce-arg string)) (id->ffi2-ptr (sel_registerName selector)) (id->ffi2-ptr (coerce-arg char-code)) index))
   ))
(define (nsmenu-is-accessibility-alternate-ui-visible self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityAlternateUIVisible"))))
(define (nsmenu-is-accessibility-disclosed self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityDisclosed"))))
(define (nsmenu-is-accessibility-edited self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEdited"))))
(define (nsmenu-is-accessibility-element self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityElement"))))
(define (nsmenu-is-accessibility-enabled self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityEnabled"))))
(define (nsmenu-is-accessibility-expanded self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityExpanded"))))
(define (nsmenu-is-accessibility-focused self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFocused"))))
(define (nsmenu-is-accessibility-frontmost self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityFrontmost"))))
(define (nsmenu-is-accessibility-hidden self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityHidden"))))
(define (nsmenu-is-accessibility-main self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMain"))))
(define (nsmenu-is-accessibility-minimized self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityMinimized"))))
(define (nsmenu-is-accessibility-modal self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityModal"))))
(define (nsmenu-is-accessibility-ordered-by-row self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityOrderedByRow"))))
(define (nsmenu-is-accessibility-protected-content self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityProtectedContent"))))
(define (nsmenu-is-accessibility-required self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilityRequired"))))
(define (nsmenu-is-accessibility-selected self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelected"))))
(define (nsmenu-is-accessibility-selector-allowed self selector)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isAccessibilitySelectorAllowed:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nsmenu-item-at-index self index)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "itemAtIndex:")) index))
   ))
(define (nsmenu-item-changed self item)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "itemChanged:")) (id->ffi2-ptr (coerce-arg item))))
(define (nsmenu-item-with-tag self tag)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_q_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "itemWithTag:")) tag))
   ))
(define (nsmenu-item-with-title self title)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "itemWithTitle:")) (id->ffi2-ptr (coerce-arg title))))
   ))
(define (nsmenu-perform-action-for-item-at-index! self index)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performActionForItemAtIndex:")) index))
(define (nsmenu-perform-key-equivalent! self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performKeyEquivalent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nsmenu-pop-up-menu-positioning-item-at-location-in-view self item location view)
  (aw_racket_msg_POP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "popUpMenuPositioningItem:atLocation:inView:")) (id->ffi2-ptr (coerce-arg item)) (id->ffi2-ptr location) (id->ffi2-ptr (coerce-arg view))))
(define (nsmenu-remove-all-items! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeAllItems"))))
(define (nsmenu-remove-item! self item)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeItem:")) (id->ffi2-ptr (coerce-arg item))))
(define (nsmenu-remove-item-at-index! self index)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "removeItemAtIndex:")) index))
(define (nsmenu-set-accessibility-activation-point! self accessibility-activation-point)
  (aw_racket_msg_O_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityActivationPoint:")) (id->ffi2-ptr accessibility-activation-point)))
(define (nsmenu-set-accessibility-allowed-values! self accessibility-allowed-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAllowedValues:")) (id->ffi2-ptr (coerce-arg accessibility-allowed-values))))
(define (nsmenu-set-accessibility-alternate-ui-visible! self accessibility-alternate-ui-visible)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAlternateUIVisible:")) accessibility-alternate-ui-visible))
(define (nsmenu-set-accessibility-application-focused-ui-element! self accessibility-application-focused-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityApplicationFocusedUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-application-focused-ui-element))))
(define (nsmenu-set-accessibility-attributed-user-input-labels! self accessibility-attributed-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityAttributedUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-attributed-user-input-labels))))
(define (nsmenu-set-accessibility-cancel-button! self accessibility-cancel-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCancelButton:")) (id->ffi2-ptr (coerce-arg accessibility-cancel-button))))
(define (nsmenu-set-accessibility-children! self accessibility-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildren:")) (id->ffi2-ptr (coerce-arg accessibility-children))))
(define (nsmenu-set-accessibility-children-in-navigation-order! self accessibility-children-in-navigation-order)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityChildrenInNavigationOrder:")) (id->ffi2-ptr (coerce-arg accessibility-children-in-navigation-order))))
(define (nsmenu-set-accessibility-clear-button! self accessibility-clear-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityClearButton:")) (id->ffi2-ptr (coerce-arg accessibility-clear-button))))
(define (nsmenu-set-accessibility-close-button! self accessibility-close-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCloseButton:")) (id->ffi2-ptr (coerce-arg accessibility-close-button))))
(define (nsmenu-set-accessibility-column-count! self accessibility-column-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnCount:")) accessibility-column-count))
(define (nsmenu-set-accessibility-column-header-ui-elements! self accessibility-column-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-column-header-ui-elements))))
(define (nsmenu-set-accessibility-column-index-range! self accessibility-column-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnIndexRange:")) (id->ffi2-ptr accessibility-column-index-range)))
(define (nsmenu-set-accessibility-column-titles! self accessibility-column-titles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumnTitles:")) (id->ffi2-ptr (coerce-arg accessibility-column-titles))))
(define (nsmenu-set-accessibility-columns! self accessibility-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityColumns:")) (id->ffi2-ptr (coerce-arg accessibility-columns))))
(define (nsmenu-set-accessibility-contents! self accessibility-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityContents:")) (id->ffi2-ptr (coerce-arg accessibility-contents))))
(define (nsmenu-set-accessibility-critical-value! self accessibility-critical-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCriticalValue:")) (id->ffi2-ptr (coerce-arg accessibility-critical-value))))
(define (nsmenu-set-accessibility-custom-actions! self accessibility-custom-actions)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomActions:")) (id->ffi2-ptr (coerce-arg accessibility-custom-actions))))
(define (nsmenu-set-accessibility-custom-rotors! self accessibility-custom-rotors)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityCustomRotors:")) (id->ffi2-ptr (coerce-arg accessibility-custom-rotors))))
(define (nsmenu-set-accessibility-decrement-button! self accessibility-decrement-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDecrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-decrement-button))))
(define (nsmenu-set-accessibility-default-button! self accessibility-default-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDefaultButton:")) (id->ffi2-ptr (coerce-arg accessibility-default-button))))
(define (nsmenu-set-accessibility-disclosed! self accessibility-disclosed)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosed:")) accessibility-disclosed))
(define (nsmenu-set-accessibility-disclosed-by-row! self accessibility-disclosed-by-row)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedByRow:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-by-row))))
(define (nsmenu-set-accessibility-disclosed-rows! self accessibility-disclosed-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosedRows:")) (id->ffi2-ptr (coerce-arg accessibility-disclosed-rows))))
(define (nsmenu-set-accessibility-disclosure-level! self accessibility-disclosure-level)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDisclosureLevel:")) accessibility-disclosure-level))
(define (nsmenu-set-accessibility-document! self accessibility-document)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityDocument:")) (id->ffi2-ptr (coerce-arg accessibility-document))))
(define (nsmenu-set-accessibility-edited! self accessibility-edited)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEdited:")) accessibility-edited))
(define (nsmenu-set-accessibility-element! self accessibility-element)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityElement:")) accessibility-element))
(define (nsmenu-set-accessibility-enabled! self accessibility-enabled)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityEnabled:")) accessibility-enabled))
(define (nsmenu-set-accessibility-expanded! self accessibility-expanded)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExpanded:")) accessibility-expanded))
(define (nsmenu-set-accessibility-extras-menu-bar! self accessibility-extras-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityExtrasMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-extras-menu-bar))))
(define (nsmenu-set-accessibility-filename! self accessibility-filename)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFilename:")) (id->ffi2-ptr (coerce-arg accessibility-filename))))
(define (nsmenu-set-accessibility-focused! self accessibility-focused)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocused:")) accessibility-focused))
(define (nsmenu-set-accessibility-focused-window! self accessibility-focused-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFocusedWindow:")) (id->ffi2-ptr (coerce-arg accessibility-focused-window))))
(define (nsmenu-set-accessibility-frame! self accessibility-frame)
  (aw_racket_msg_R_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrame:")) (id->ffi2-ptr accessibility-frame)))
(define (nsmenu-set-accessibility-frontmost! self accessibility-frontmost)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFrontmost:")) accessibility-frontmost))
(define (nsmenu-set-accessibility-full-screen-button! self accessibility-full-screen-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityFullScreenButton:")) (id->ffi2-ptr (coerce-arg accessibility-full-screen-button))))
(define (nsmenu-set-accessibility-grow-area! self accessibility-grow-area)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityGrowArea:")) (id->ffi2-ptr (coerce-arg accessibility-grow-area))))
(define (nsmenu-set-accessibility-handles! self accessibility-handles)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHandles:")) (id->ffi2-ptr (coerce-arg accessibility-handles))))
(define (nsmenu-set-accessibility-header! self accessibility-header)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHeader:")) (id->ffi2-ptr (coerce-arg accessibility-header))))
(define (nsmenu-set-accessibility-help! self accessibility-help)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHelp:")) (id->ffi2-ptr (coerce-arg accessibility-help))))
(define (nsmenu-set-accessibility-hidden! self accessibility-hidden)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHidden:")) accessibility-hidden))
(define (nsmenu-set-accessibility-horizontal-scroll-bar! self accessibility-horizontal-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-scroll-bar))))
(define (nsmenu-set-accessibility-horizontal-unit-description! self accessibility-horizontal-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-horizontal-unit-description))))
(define (nsmenu-set-accessibility-horizontal-units! self accessibility-horizontal-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityHorizontalUnits:")) accessibility-horizontal-units))
(define (nsmenu-set-accessibility-identifier! self accessibility-identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIdentifier:")) (id->ffi2-ptr (coerce-arg accessibility-identifier))))
(define (nsmenu-set-accessibility-increment-button! self accessibility-increment-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIncrementButton:")) (id->ffi2-ptr (coerce-arg accessibility-increment-button))))
(define (nsmenu-set-accessibility-index! self accessibility-index)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityIndex:")) accessibility-index))
(define (nsmenu-set-accessibility-insertion-point-line-number! self accessibility-insertion-point-line-number)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityInsertionPointLineNumber:")) accessibility-insertion-point-line-number))
(define (nsmenu-set-accessibility-label! self accessibility-label)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabel:")) (id->ffi2-ptr (coerce-arg accessibility-label))))
(define (nsmenu-set-accessibility-label-ui-elements! self accessibility-label-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-label-ui-elements))))
(define (nsmenu-set-accessibility-label-value! self accessibility-label-value)
  (aw_racket_msg_f_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLabelValue:")) accessibility-label-value))
(define (nsmenu-set-accessibility-linked-ui-elements! self accessibility-linked-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityLinkedUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-linked-ui-elements))))
(define (nsmenu-set-accessibility-main! self accessibility-main)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMain:")) accessibility-main))
(define (nsmenu-set-accessibility-main-window! self accessibility-main-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMainWindow:")) (id->ffi2-ptr (coerce-arg accessibility-main-window))))
(define (nsmenu-set-accessibility-marker-group-ui-element! self accessibility-marker-group-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerGroupUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-marker-group-ui-element))))
(define (nsmenu-set-accessibility-marker-type-description! self accessibility-marker-type-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerTypeDescription:")) (id->ffi2-ptr (coerce-arg accessibility-marker-type-description))))
(define (nsmenu-set-accessibility-marker-ui-elements! self accessibility-marker-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-marker-ui-elements))))
(define (nsmenu-set-accessibility-marker-values! self accessibility-marker-values)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMarkerValues:")) (id->ffi2-ptr (coerce-arg accessibility-marker-values))))
(define (nsmenu-set-accessibility-max-value! self accessibility-max-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMaxValue:")) (id->ffi2-ptr (coerce-arg accessibility-max-value))))
(define (nsmenu-set-accessibility-menu-bar! self accessibility-menu-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMenuBar:")) (id->ffi2-ptr (coerce-arg accessibility-menu-bar))))
(define (nsmenu-set-accessibility-min-value! self accessibility-min-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinValue:")) (id->ffi2-ptr (coerce-arg accessibility-min-value))))
(define (nsmenu-set-accessibility-minimize-button! self accessibility-minimize-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimizeButton:")) (id->ffi2-ptr (coerce-arg accessibility-minimize-button))))
(define (nsmenu-set-accessibility-minimized! self accessibility-minimized)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityMinimized:")) accessibility-minimized))
(define (nsmenu-set-accessibility-modal! self accessibility-modal)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityModal:")) accessibility-modal))
(define (nsmenu-set-accessibility-next-contents! self accessibility-next-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNextContents:")) (id->ffi2-ptr (coerce-arg accessibility-next-contents))))
(define (nsmenu-set-accessibility-number-of-characters! self accessibility-number-of-characters)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityNumberOfCharacters:")) accessibility-number-of-characters))
(define (nsmenu-set-accessibility-ordered-by-row! self accessibility-ordered-by-row)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrderedByRow:")) accessibility-ordered-by-row))
(define (nsmenu-set-accessibility-orientation! self accessibility-orientation)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOrientation:")) accessibility-orientation))
(define (nsmenu-set-accessibility-overflow-button! self accessibility-overflow-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityOverflowButton:")) (id->ffi2-ptr (coerce-arg accessibility-overflow-button))))
(define (nsmenu-set-accessibility-parent! self accessibility-parent)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityParent:")) (id->ffi2-ptr (coerce-arg accessibility-parent))))
(define (nsmenu-set-accessibility-placeholder-value! self accessibility-placeholder-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPlaceholderValue:")) (id->ffi2-ptr (coerce-arg accessibility-placeholder-value))))
(define (nsmenu-set-accessibility-previous-contents! self accessibility-previous-contents)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityPreviousContents:")) (id->ffi2-ptr (coerce-arg accessibility-previous-contents))))
(define (nsmenu-set-accessibility-protected-content! self accessibility-protected-content)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProtectedContent:")) accessibility-protected-content))
(define (nsmenu-set-accessibility-proxy! self accessibility-proxy)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityProxy:")) (id->ffi2-ptr (coerce-arg accessibility-proxy))))
(define (nsmenu-set-accessibility-required! self accessibility-required)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRequired:")) accessibility-required))
(define (nsmenu-set-accessibility-role! self accessibility-role)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRole:")) (id->ffi2-ptr (coerce-arg accessibility-role))))
(define (nsmenu-set-accessibility-role-description! self accessibility-role-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRoleDescription:")) (id->ffi2-ptr (coerce-arg accessibility-role-description))))
(define (nsmenu-set-accessibility-row-count! self accessibility-row-count)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowCount:")) accessibility-row-count))
(define (nsmenu-set-accessibility-row-header-ui-elements! self accessibility-row-header-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowHeaderUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-row-header-ui-elements))))
(define (nsmenu-set-accessibility-row-index-range! self accessibility-row-index-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRowIndexRange:")) (id->ffi2-ptr accessibility-row-index-range)))
(define (nsmenu-set-accessibility-rows! self accessibility-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRows:")) (id->ffi2-ptr (coerce-arg accessibility-rows))))
(define (nsmenu-set-accessibility-ruler-marker-type! self accessibility-ruler-marker-type)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityRulerMarkerType:")) accessibility-ruler-marker-type))
(define (nsmenu-set-accessibility-search-button! self accessibility-search-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchButton:")) (id->ffi2-ptr (coerce-arg accessibility-search-button))))
(define (nsmenu-set-accessibility-search-menu! self accessibility-search-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySearchMenu:")) (id->ffi2-ptr (coerce-arg accessibility-search-menu))))
(define (nsmenu-set-accessibility-selected! self accessibility-selected)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelected:")) accessibility-selected))
(define (nsmenu-set-accessibility-selected-cells! self accessibility-selected-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedCells:")) (id->ffi2-ptr (coerce-arg accessibility-selected-cells))))
(define (nsmenu-set-accessibility-selected-children! self accessibility-selected-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedChildren:")) (id->ffi2-ptr (coerce-arg accessibility-selected-children))))
(define (nsmenu-set-accessibility-selected-columns! self accessibility-selected-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedColumns:")) (id->ffi2-ptr (coerce-arg accessibility-selected-columns))))
(define (nsmenu-set-accessibility-selected-rows! self accessibility-selected-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedRows:")) (id->ffi2-ptr (coerce-arg accessibility-selected-rows))))
(define (nsmenu-set-accessibility-selected-text! self accessibility-selected-text)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedText:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text))))
(define (nsmenu-set-accessibility-selected-text-range! self accessibility-selected-text-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRange:")) (id->ffi2-ptr accessibility-selected-text-range)))
(define (nsmenu-set-accessibility-selected-text-ranges! self accessibility-selected-text-ranges)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySelectedTextRanges:")) (id->ffi2-ptr (coerce-arg accessibility-selected-text-ranges))))
(define (nsmenu-set-accessibility-serves-as-title-for-ui-elements! self accessibility-serves-as-title-for-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityServesAsTitleForUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-serves-as-title-for-ui-elements))))
(define (nsmenu-set-accessibility-shared-character-range! self accessibility-shared-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedCharacterRange:")) (id->ffi2-ptr accessibility-shared-character-range)))
(define (nsmenu-set-accessibility-shared-focus-elements! self accessibility-shared-focus-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedFocusElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-focus-elements))))
(define (nsmenu-set-accessibility-shared-text-ui-elements! self accessibility-shared-text-ui-elements)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySharedTextUIElements:")) (id->ffi2-ptr (coerce-arg accessibility-shared-text-ui-elements))))
(define (nsmenu-set-accessibility-shown-menu! self accessibility-shown-menu)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityShownMenu:")) (id->ffi2-ptr (coerce-arg accessibility-shown-menu))))
(define (nsmenu-set-accessibility-sort-direction! self accessibility-sort-direction)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySortDirection:")) accessibility-sort-direction))
(define (nsmenu-set-accessibility-splitters! self accessibility-splitters)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySplitters:")) (id->ffi2-ptr (coerce-arg accessibility-splitters))))
(define (nsmenu-set-accessibility-subrole! self accessibility-subrole)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilitySubrole:")) (id->ffi2-ptr (coerce-arg accessibility-subrole))))
(define (nsmenu-set-accessibility-tabs! self accessibility-tabs)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTabs:")) (id->ffi2-ptr (coerce-arg accessibility-tabs))))
(define (nsmenu-set-accessibility-title! self accessibility-title)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitle:")) (id->ffi2-ptr (coerce-arg accessibility-title))))
(define (nsmenu-set-accessibility-title-ui-element! self accessibility-title-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTitleUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-title-ui-element))))
(define (nsmenu-set-accessibility-toolbar-button! self accessibility-toolbar-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityToolbarButton:")) (id->ffi2-ptr (coerce-arg accessibility-toolbar-button))))
(define (nsmenu-set-accessibility-top-level-ui-element! self accessibility-top-level-ui-element)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityTopLevelUIElement:")) (id->ffi2-ptr (coerce-arg accessibility-top-level-ui-element))))
(define (nsmenu-set-accessibility-url! self accessibility-url)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityURL:")) (id->ffi2-ptr (coerce-arg accessibility-url))))
(define (nsmenu-set-accessibility-unit-description! self accessibility-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-unit-description))))
(define (nsmenu-set-accessibility-units! self accessibility-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUnits:")) accessibility-units))
(define (nsmenu-set-accessibility-user-input-labels! self accessibility-user-input-labels)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityUserInputLabels:")) (id->ffi2-ptr (coerce-arg accessibility-user-input-labels))))
(define (nsmenu-set-accessibility-value! self accessibility-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValue:")) (id->ffi2-ptr (coerce-arg accessibility-value))))
(define (nsmenu-set-accessibility-value-description! self accessibility-value-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityValueDescription:")) (id->ffi2-ptr (coerce-arg accessibility-value-description))))
(define (nsmenu-set-accessibility-vertical-scroll-bar! self accessibility-vertical-scroll-bar)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalScrollBar:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-scroll-bar))))
(define (nsmenu-set-accessibility-vertical-unit-description! self accessibility-vertical-unit-description)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnitDescription:")) (id->ffi2-ptr (coerce-arg accessibility-vertical-unit-description))))
(define (nsmenu-set-accessibility-vertical-units! self accessibility-vertical-units)
  (aw_racket_msg_q_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVerticalUnits:")) accessibility-vertical-units))
(define (nsmenu-set-accessibility-visible-cells! self accessibility-visible-cells)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCells:")) (id->ffi2-ptr (coerce-arg accessibility-visible-cells))))
(define (nsmenu-set-accessibility-visible-character-range! self accessibility-visible-character-range)
  (aw_racket_msg_G_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleCharacterRange:")) (id->ffi2-ptr accessibility-visible-character-range)))
(define (nsmenu-set-accessibility-visible-children! self accessibility-visible-children)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleChildren:")) (id->ffi2-ptr (coerce-arg accessibility-visible-children))))
(define (nsmenu-set-accessibility-visible-columns! self accessibility-visible-columns)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleColumns:")) (id->ffi2-ptr (coerce-arg accessibility-visible-columns))))
(define (nsmenu-set-accessibility-visible-rows! self accessibility-visible-rows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityVisibleRows:")) (id->ffi2-ptr (coerce-arg accessibility-visible-rows))))
(define (nsmenu-set-accessibility-warning-value! self accessibility-warning-value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWarningValue:")) (id->ffi2-ptr (coerce-arg accessibility-warning-value))))
(define (nsmenu-set-accessibility-window! self accessibility-window)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindow:")) (id->ffi2-ptr (coerce-arg accessibility-window))))
(define (nsmenu-set-accessibility-windows! self accessibility-windows)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityWindows:")) (id->ffi2-ptr (coerce-arg accessibility-windows))))
(define (nsmenu-set-accessibility-zoom-button! self accessibility-zoom-button)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAccessibilityZoomButton:")) (id->ffi2-ptr (coerce-arg accessibility-zoom-button))))
(define (nsmenu-set-appearance! self appearance)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setAppearance:")) (id->ffi2-ptr (coerce-arg appearance))))
(define (nsmenu-set-identifier! self identifier)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setIdentifier:")) (id->ffi2-ptr (coerce-arg identifier))))
(define (nsmenu-set-submenu-for-item! self menu item)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setSubmenu:forItem:")) (id->ffi2-ptr (coerce-arg menu)) (id->ffi2-ptr (coerce-arg item))))
(define (nsmenu-submenu-action self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "submenuAction:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nsmenu-update self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "update"))))

;; --- Class methods ---
(define (nsmenu-menu-bar-visible)
  (aw_racket_msg_0_b (id->ffi2-ptr NSMenu) (id->ffi2-ptr (sel_registerName "menuBarVisible"))))
;; block param 2: async-copied (runtime-managed)
(define (nsmenu-palette-menu-with-colors-titles-selection-handler colors item-titles on-selection-change)
  (define-values (_blk2 _blk2-id)
    (make-objc-block on-selection-change (list _id) _void))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPP_P (id->ffi2-ptr NSMenu) (id->ffi2-ptr (sel_registerName "paletteMenuWithColors:titles:selectionHandler:")) (id->ffi2-ptr (coerce-arg colors)) (id->ffi2-ptr (coerce-arg item-titles)) (id->ffi2-ptr _blk2)))
   ))
;; block param 3: async-copied (runtime-managed)
(define (nsmenu-palette-menu-with-colors-titles-template-image-selection-handler colors item-titles image on-selection-change)
  (define-values (_blk3 _blk3-id)
    (make-objc-block on-selection-change (list _id) _void))
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PPPP_P (id->ffi2-ptr NSMenu) (id->ffi2-ptr (sel_registerName "paletteMenuWithColors:titles:templateImage:selectionHandler:")) (id->ffi2-ptr (coerce-arg colors)) (id->ffi2-ptr (coerce-arg item-titles)) (id->ffi2-ptr (coerce-arg image)) (id->ffi2-ptr _blk3)))
   ))
(define (nsmenu-pop-up-context-menu-with-event-for-view menu event view)
  (aw_racket_msg_PPP_v (id->ffi2-ptr NSMenu) (id->ffi2-ptr (sel_registerName "popUpContextMenu:withEvent:forView:")) (id->ffi2-ptr (coerce-arg menu)) (id->ffi2-ptr (coerce-arg event)) (id->ffi2-ptr (coerce-arg view))))
(define (nsmenu-pop-up-context-menu-with-event-for-view-with-font menu event view font)
  (aw_racket_msg_PPPP_v (id->ffi2-ptr NSMenu) (id->ffi2-ptr (sel_registerName "popUpContextMenu:withEvent:forView:withFont:")) (id->ffi2-ptr (coerce-arg menu)) (id->ffi2-ptr (coerce-arg event)) (id->ffi2-ptr (coerce-arg view)) (id->ffi2-ptr (coerce-arg font))))
(define (nsmenu-set-menu-bar-visible! visible)
  (aw_racket_msg_b_v (id->ffi2-ptr NSMenu) (id->ffi2-ptr (sel_registerName "setMenuBarVisible:")) visible))
