#lang racket/base
;; Generated binding for NSWindowController (AppKit)
;; Do not edit — regenerate from enriched IR

(require "../../runtime/ffi2-dispatch.rkt"
         (except-in ffi/unsafe ->)
         ffi/unsafe/objc
         (rename-in racket/contract [-> c->])
         "../../runtime/objc-base.rkt"
         "../../runtime/coerce.rkt")

;; Load framework and ObjC runtime
(define _fw-lib (ffi-lib "/System/Library/Frameworks/AppKit.framework/AppKit"))
(define _objc-lib (ffi-lib "libobjc"))


;; --- Class predicates ---
(define (nsarray? v) (objc-instance-of? v "NSArray"))
(define (nserror? v) (objc-instance-of? v "NSError"))
(define (nsmenu? v) (objc-instance-of? v "NSMenu"))
(define (nsresponder? v) (objc-instance-of? v "NSResponder"))
(define (nsstoryboard? v) (objc-instance-of? v "NSStoryboard"))
(define (nsstring? v) (objc-instance-of? v "NSString"))
(define (nstouchbar? v) (objc-instance-of? v "NSTouchBar"))
(define (nsundomanager? v) (objc-instance-of? v "NSUndoManager"))
(define (nsuseractivity? v) (objc-instance-of? v "NSUserActivity"))
(define (nsviewcontroller? v) (objc-instance-of? v "NSViewController"))
(define (nswindow? v) (objc-instance-of? v "NSWindow"))
(define (nswindowcontroller? v) (objc-instance-of? v "NSWindowController"))
(provide NSWindowController)
(provide/contract
  [make-nswindowcontroller-init-with-coder (c-> (or/c string? objc-object? #f) any/c)]
  [make-nswindowcontroller-init-with-window (c-> (or/c string? objc-object? #f) any/c)]
  [make-nswindowcontroller-init-with-window-nib-name (c-> (or/c string? objc-object? #f) any/c)]
  [make-nswindowcontroller-init-with-window-nib-name-owner (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [make-nswindowcontroller-init-with-window-nib-path-owner (c-> (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nswindowcontroller-accepts-first-responder (c-> nswindowcontroller? boolean?)]
  [nswindowcontroller-content-view-controller (c-> nswindowcontroller? (or/c nsviewcontroller? objc-nil?))]
  [nswindowcontroller-set-content-view-controller! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-document (c-> nswindowcontroller? any/c)]
  [nswindowcontroller-set-document! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-menu (c-> nswindowcontroller? (or/c nsmenu? objc-nil?))]
  [nswindowcontroller-set-menu! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-next-responder (c-> nswindowcontroller? (or/c nsresponder? objc-nil?))]
  [nswindowcontroller-set-next-responder! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-owner (c-> nswindowcontroller? any/c)]
  [nswindowcontroller-preview-representable-activity-items (c-> nswindowcontroller? (or/c nsarray? objc-nil?))]
  [nswindowcontroller-set-preview-representable-activity-items! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-restorable-state-key-paths (c-> (or/c nsarray? objc-nil?))]
  [nswindowcontroller-should-cascade-windows (c-> nswindowcontroller? boolean?)]
  [nswindowcontroller-set-should-cascade-windows! (c-> nswindowcontroller? boolean? void?)]
  [nswindowcontroller-should-close-document (c-> nswindowcontroller? boolean?)]
  [nswindowcontroller-set-should-close-document! (c-> nswindowcontroller? boolean? void?)]
  [nswindowcontroller-storyboard (c-> nswindowcontroller? (or/c nsstoryboard? objc-nil?))]
  [nswindowcontroller-touch-bar (c-> nswindowcontroller? (or/c nstouchbar? objc-nil?))]
  [nswindowcontroller-set-touch-bar! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-undo-manager (c-> nswindowcontroller? (or/c nsundomanager? objc-nil?))]
  [nswindowcontroller-user-activity (c-> nswindowcontroller? (or/c nsuseractivity? objc-nil?))]
  [nswindowcontroller-set-user-activity! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-window (c-> nswindowcontroller? (or/c nswindow? objc-nil?))]
  [nswindowcontroller-set-window! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-window-frame-autosave-name (c-> nswindowcontroller? (or/c nsstring? objc-nil?))]
  [nswindowcontroller-set-window-frame-autosave-name! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-window-loaded (c-> nswindowcontroller? boolean?)]
  [nswindowcontroller-window-nib-name (c-> nswindowcontroller? (or/c nsstring? objc-nil?))]
  [nswindowcontroller-window-nib-path (c-> nswindowcontroller? (or/c nsstring? objc-nil?))]
  [nswindowcontroller-become-first-responder (c-> nswindowcontroller? boolean?)]
  [nswindowcontroller-begin-gesture-with-event! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-cancel-operation (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-capitalize-word (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-center-selection-in-visible-area! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-change-case-of-letter (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-change-mode-with-event (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-close! (c-> nswindowcontroller? void?)]
  [nswindowcontroller-complete (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-context-menu-key-down (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-cursor-update (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-delete-backward (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-delete-backward-by-decomposing-previous-character (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-delete-forward (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-delete-to-beginning-of-line (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-delete-to-beginning-of-paragraph (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-delete-to-end-of-line (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-delete-to-end-of-paragraph (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-delete-to-mark (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-delete-word-backward (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-delete-word-forward (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-dismiss-controller (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-do-command-by-selector (c-> nswindowcontroller? string? void?)]
  [nswindowcontroller-encode-restorable-state-with-coder (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-encode-restorable-state-with-coder-background-queue (c-> nswindowcontroller? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-encode-with-coder (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-end-gesture-with-event! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-flags-changed (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-flush-buffered-key-events (c-> nswindowcontroller? void?)]
  [nswindowcontroller-help-requested (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-indent (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-insert-backtab! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-insert-container-break! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-insert-double-quote-ignoring-substitution! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-insert-line-break! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-insert-newline! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-insert-newline-ignoring-field-editor! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-insert-paragraph-separator! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-insert-single-quote-ignoring-substitution! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-insert-tab! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-insert-tab-ignoring-field-editor! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-insert-text! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-interpret-key-events (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-invalidate-restorable-state (c-> nswindowcontroller? void?)]
  [nswindowcontroller-is-window-loaded (c-> nswindowcontroller? boolean?)]
  [nswindowcontroller-key-down (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-key-up (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-load-window (c-> nswindowcontroller? void?)]
  [nswindowcontroller-lowercase-word (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-magnify-with-event (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-make-base-writing-direction-left-to-right (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-make-base-writing-direction-natural (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-make-base-writing-direction-right-to-left (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-make-text-writing-direction-left-to-right (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-make-text-writing-direction-natural (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-make-text-writing-direction-right-to-left (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-make-touch-bar (c-> nswindowcontroller? (or/c nstouchbar? objc-nil?))]
  [nswindowcontroller-mouse-cancelled (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-mouse-down (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-mouse-dragged (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-mouse-entered (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-mouse-exited (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-mouse-moved (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-mouse-up (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-backward! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-backward-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-down! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-down-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-forward! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-forward-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-left! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-left-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-paragraph-backward-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-paragraph-forward-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-right! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-right-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-to-beginning-of-document! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-to-beginning-of-document-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-to-beginning-of-line! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-to-beginning-of-line-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-to-beginning-of-paragraph! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-to-beginning-of-paragraph-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-to-end-of-document! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-to-end-of-document-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-to-end-of-line! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-to-end-of-line-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-to-end-of-paragraph! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-to-end-of-paragraph-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-to-left-end-of-line! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-to-left-end-of-line-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-to-right-end-of-line! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-to-right-end-of-line-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-up! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-up-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-word-backward! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-word-backward-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-word-forward! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-word-forward-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-word-left! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-word-left-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-word-right! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-move-word-right-and-modify-selection! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-new-window-for-tab (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-no-responder-for (c-> nswindowcontroller? string? void?)]
  [nswindowcontroller-other-mouse-down (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-other-mouse-dragged (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-other-mouse-up (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-page-down (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-page-down-and-modify-selection (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-page-up (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-page-up-and-modify-selection (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-perform-key-equivalent! (c-> nswindowcontroller? (or/c string? objc-object? #f) boolean?)]
  [nswindowcontroller-perform-segue-with-identifier-sender! (c-> nswindowcontroller? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-perform-text-finder-action! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-prepare-for-segue-sender (c-> nswindowcontroller? (or/c string? objc-object? #f) (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-present-error (c-> nswindowcontroller? (or/c string? objc-object? #f) boolean?)]
  [nswindowcontroller-present-error-modal-for-window-delegate-did-present-selector-context-info (c-> nswindowcontroller? (or/c string? objc-object? #f) (or/c string? objc-object? #f) (or/c string? objc-object? #f) string? (or/c cpointer? #f) void?)]
  [nswindowcontroller-pressure-change-with-event (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-quick-look-preview-items (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-quick-look-with-event (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-resign-first-responder (c-> nswindowcontroller? boolean?)]
  [nswindowcontroller-restore-state-with-coder (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-restore-user-activity-state (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-right-mouse-down (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-right-mouse-dragged (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-right-mouse-up (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-rotate-with-event (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-scroll-line-down (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-scroll-line-up (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-scroll-page-down (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-scroll-page-up (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-scroll-to-beginning-of-document (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-scroll-to-end-of-document (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-scroll-wheel (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-select-all (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-select-line (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-select-paragraph (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-select-to-mark (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-select-word (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-set-document-edited! (c-> nswindowcontroller? boolean? void?)]
  [nswindowcontroller-set-mark! (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-should-be-treated-as-ink-event (c-> nswindowcontroller? (or/c string? objc-object? #f) boolean?)]
  [nswindowcontroller-should-perform-segue-with-identifier-sender (c-> nswindowcontroller? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nswindowcontroller-show-context-help (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-show-context-menu-for-selection (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-show-window (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-show-writing-tools (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-smart-magnify-with-event (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-supplemental-target-for-action-sender (c-> nswindowcontroller? string? (or/c string? objc-object? #f) any/c)]
  [nswindowcontroller-swap-with-mark (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-swipe-with-event (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-synchronize-window-title-with-document-name (c-> nswindowcontroller? void?)]
  [nswindowcontroller-tablet-point (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-tablet-proximity (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-touches-began-with-event (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-touches-cancelled-with-event (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-touches-ended-with-event (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-touches-moved-with-event (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-transpose (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-transpose-words (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-try-to-perform-with (c-> nswindowcontroller? string? (or/c string? objc-object? #f) boolean?)]
  [nswindowcontroller-update-user-activity-state (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-uppercase-word (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-valid-requestor-for-send-type-return-type (c-> nswindowcontroller? (or/c string? objc-object? #f) (or/c string? objc-object? #f) any/c)]
  [nswindowcontroller-validate-proposed-first-responder-for-event (c-> nswindowcontroller? (or/c string? objc-object? #f) (or/c string? objc-object? #f) boolean?)]
  [nswindowcontroller-wants-forwarded-scroll-events-for-axis (c-> nswindowcontroller? exact-integer? boolean?)]
  [nswindowcontroller-wants-scroll-events-for-swipe-tracking-on-axis (c-> nswindowcontroller? exact-integer? boolean?)]
  [nswindowcontroller-will-present-error (c-> nswindowcontroller? (or/c string? objc-object? #f) (or/c nserror? objc-nil?))]
  [nswindowcontroller-window-did-load (c-> nswindowcontroller? void?)]
  [nswindowcontroller-window-title-for-document-display-name (c-> nswindowcontroller? (or/c string? objc-object? #f) (or/c nsstring? objc-nil?))]
  [nswindowcontroller-window-will-load (c-> nswindowcontroller? void?)]
  [nswindowcontroller-yank (c-> nswindowcontroller? (or/c string? objc-object? #f) void?)]
  [nswindowcontroller-allowed-classes-for-restorable-state-key-path (c-> (or/c string? objc-object? #f) (or/c nsarray? objc-nil?))]
  )

;; --- Class reference ---
(import-class NSWindowController)

;; --- Native dispatch bindings (generated objc_msgSend, ADR-0013) ---
(define-aw-msg aw_racket_msg_0_P (-> ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_0_b (-> ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_0_v (-> ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_P_P (-> ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_P_b (-> ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_P_v (-> ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PP_P (-> ptr_t ptr_t ptr_t ptr_t ptr_t))
(define-aw-msg aw_racket_msg_PP_b (-> ptr_t ptr_t ptr_t ptr_t bool_t))
(define-aw-msg aw_racket_msg_PP_v (-> ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_PPPPP_v (-> ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t ptr_t void_t))
(define-aw-msg aw_racket_msg_b_v (-> ptr_t ptr_t bool_t void_t))
(define-aw-msg aw_racket_msg_q_b (-> ptr_t ptr_t int64_t bool_t))

;; --- Constructors ---
(define (make-nswindowcontroller-init-with-coder coder)
  (wrap-objc-object
   (tell (tell NSWindowController alloc)
         initWithCoder: (coerce-arg coder))
   #:retained #t))

(define (make-nswindowcontroller-init-with-window window)
  (wrap-objc-object
   (tell (tell NSWindowController alloc)
         initWithWindow: (coerce-arg window))
   #:retained #t))

(define (make-nswindowcontroller-init-with-window-nib-name window-nib-name)
  (wrap-objc-object
   (tell (tell NSWindowController alloc)
         initWithWindowNibName: (coerce-arg window-nib-name))
   #:retained #t))

(define (make-nswindowcontroller-init-with-window-nib-name-owner window-nib-name owner)
  (wrap-objc-object
   (tell (tell NSWindowController alloc)
         initWithWindowNibName: (coerce-arg window-nib-name) owner: (coerce-arg owner))
   #:retained #t))

(define (make-nswindowcontroller-init-with-window-nib-path-owner window-nib-path owner)
  (wrap-objc-object
   (tell (tell NSWindowController alloc)
         initWithWindowNibPath: (coerce-arg window-nib-path) owner: (coerce-arg owner))
   #:retained #t))


;; --- Properties ---
(define (nswindowcontroller-accepts-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "acceptsFirstResponder"))))
(define (nswindowcontroller-content-view-controller self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contentViewController"))))))
(define (nswindowcontroller-set-content-view-controller! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setContentViewController:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindowcontroller-document self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "document"))))))
(define (nswindowcontroller-set-document! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDocument:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindowcontroller-menu self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "menu"))))))
(define (nswindowcontroller-set-menu! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMenu:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindowcontroller-next-responder self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "nextResponder"))))))
(define (nswindowcontroller-set-next-responder! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setNextResponder:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindowcontroller-owner self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "owner"))))))
(define (nswindowcontroller-preview-representable-activity-items self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "previewRepresentableActivityItems"))))))
(define (nswindowcontroller-set-preview-representable-activity-items! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setPreviewRepresentableActivityItems:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindowcontroller-restorable-state-key-paths)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr NSWindowController) (id->ffi2-ptr (sel_registerName "restorableStateKeyPaths"))))))
(define (nswindowcontroller-should-cascade-windows self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldCascadeWindows"))))
(define (nswindowcontroller-set-should-cascade-windows! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShouldCascadeWindows:")) value))
(define (nswindowcontroller-should-close-document self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldCloseDocument"))))
(define (nswindowcontroller-set-should-close-document! self value)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setShouldCloseDocument:")) value))
(define (nswindowcontroller-storyboard self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "storyboard"))))))
(define (nswindowcontroller-touch-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchBar"))))))
(define (nswindowcontroller-set-touch-bar! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setTouchBar:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindowcontroller-undo-manager self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "undoManager"))))))
(define (nswindowcontroller-user-activity self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "userActivity"))))))
(define (nswindowcontroller-set-user-activity! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setUserActivity:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindowcontroller-window self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "window"))))))
(define (nswindowcontroller-set-window! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWindow:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindowcontroller-window-frame-autosave-name self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "windowFrameAutosaveName"))))))
(define (nswindowcontroller-set-window-frame-autosave-name! self value)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setWindowFrameAutosaveName:")) (id->ffi2-ptr (coerce-arg value))))
(define (nswindowcontroller-window-loaded self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "windowLoaded"))))
(define (nswindowcontroller-window-nib-name self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "windowNibName"))))))
(define (nswindowcontroller-window-nib-path self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "windowNibPath"))))))

;; --- Instance methods ---
(define (nswindowcontroller-become-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "becomeFirstResponder"))))
(define (nswindowcontroller-begin-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "beginGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-cancel-operation self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cancelOperation:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-capitalize-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "capitalizeWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-center-selection-in-visible-area! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "centerSelectionInVisibleArea:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-change-case-of-letter self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeCaseOfLetter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-change-mode-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "changeModeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-close! self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "close"))))
(define (nswindowcontroller-complete self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "complete:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-context-menu-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "contextMenuKeyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-cursor-update self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "cursorUpdate:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-delete-backward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-delete-backward-by-decomposing-previous-character self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteBackwardByDecomposingPreviousCharacter:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-delete-forward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-delete-to-beginning-of-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToBeginningOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-delete-to-beginning-of-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToBeginningOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-delete-to-end-of-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-delete-to-end-of-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToEndOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-delete-to-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteToMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-delete-word-backward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteWordBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-delete-word-forward self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "deleteWordForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-dismiss-controller self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "dismissController:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-do-command-by-selector self selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "doCommandBySelector:")) (id->ffi2-ptr (sel_registerName selector))))
(define (nswindowcontroller-encode-restorable-state-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeRestorableStateWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nswindowcontroller-encode-restorable-state-with-coder-background-queue self coder queue)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeRestorableStateWithCoder:backgroundQueue:")) (id->ffi2-ptr (coerce-arg coder)) (id->ffi2-ptr (coerce-arg queue))))
(define (nswindowcontroller-encode-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "encodeWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nswindowcontroller-end-gesture-with-event! self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "endGestureWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-flags-changed self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flagsChanged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-flush-buffered-key-events self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "flushBufferedKeyEvents"))))
(define (nswindowcontroller-help-requested self event-ptr)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "helpRequested:")) (id->ffi2-ptr (coerce-arg event-ptr))))
(define (nswindowcontroller-indent self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "indent:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-insert-backtab! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertBacktab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-insert-container-break! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertContainerBreak:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-insert-double-quote-ignoring-substitution! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertDoubleQuoteIgnoringSubstitution:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-insert-line-break! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertLineBreak:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-insert-newline! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertNewline:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-insert-newline-ignoring-field-editor! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertNewlineIgnoringFieldEditor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-insert-paragraph-separator! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertParagraphSeparator:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-insert-single-quote-ignoring-substitution! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertSingleQuoteIgnoringSubstitution:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-insert-tab! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-insert-tab-ignoring-field-editor! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertTabIgnoringFieldEditor:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-insert-text! self insert-string)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "insertText:")) (id->ffi2-ptr (coerce-arg insert-string))))
(define (nswindowcontroller-interpret-key-events self event-array)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "interpretKeyEvents:")) (id->ffi2-ptr (coerce-arg event-array))))
(define (nswindowcontroller-invalidate-restorable-state self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "invalidateRestorableState"))))
(define (nswindowcontroller-is-window-loaded self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "isWindowLoaded"))))
(define (nswindowcontroller-key-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-key-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "keyUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-load-window self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "loadWindow"))))
(define (nswindowcontroller-lowercase-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "lowercaseWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "magnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-make-base-writing-direction-left-to-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionLeftToRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-make-base-writing-direction-natural self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionNatural:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-make-base-writing-direction-right-to-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeBaseWritingDirectionRightToLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-make-text-writing-direction-left-to-right self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionLeftToRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-make-text-writing-direction-natural self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionNatural:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-make-text-writing-direction-right-to-left self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTextWritingDirectionRightToLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-make-touch-bar self)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_0_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "makeTouchBar"))))
   ))
(define (nswindowcontroller-mouse-cancelled self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseCancelled:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-mouse-entered self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseEntered:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-mouse-exited self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseExited:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-mouse-moved self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseMoved:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "mouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-move-backward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-down! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-down-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveDownAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-forward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-left! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-left-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveLeftAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-paragraph-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveParagraphBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-paragraph-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveParagraphForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-right! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-right-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveRightAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-to-beginning-of-document! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-to-beginning-of-document-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfDocumentAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-to-beginning-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-to-beginning-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-to-beginning-of-paragraph! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-to-beginning-of-paragraph-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToBeginningOfParagraphAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-to-end-of-document! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-to-end-of-document-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfDocumentAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-to-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-to-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-to-end-of-paragraph! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-to-end-of-paragraph-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToEndOfParagraphAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-to-left-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToLeftEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-to-left-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToLeftEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-to-right-end-of-line! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToRightEndOfLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-to-right-end-of-line-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveToRightEndOfLineAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-up! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-up-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveUpAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-word-backward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordBackward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-word-backward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordBackwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-word-forward! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordForward:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-word-forward-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordForwardAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-word-left! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordLeft:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-word-left-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordLeftAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-word-right! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordRight:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-move-word-right-and-modify-selection! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "moveWordRightAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-new-window-for-tab self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "newWindowForTab:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-no-responder-for self event-selector)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "noResponderFor:")) (id->ffi2-ptr (sel_registerName event-selector))))
(define (nswindowcontroller-other-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-other-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-other-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "otherMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-page-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-page-down-and-modify-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageDownAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-page-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-page-up-and-modify-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pageUpAndModifySelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-perform-key-equivalent! self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performKeyEquivalent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-perform-segue-with-identifier-sender! self identifier sender)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performSegueWithIdentifier:sender:")) (id->ffi2-ptr (coerce-arg identifier)) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-perform-text-finder-action! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "performTextFinderAction:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-prepare-for-segue-sender self segue sender)
  (aw_racket_msg_PP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "prepareForSegue:sender:")) (id->ffi2-ptr (coerce-arg segue)) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-present-error self error)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "presentError:")) (id->ffi2-ptr (coerce-arg error))))
;; param 2: weak reference
(define (nswindowcontroller-present-error-modal-for-window-delegate-did-present-selector-context-info self error window delegate did-present-selector context-info)
  (aw_racket_msg_PPPPP_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "presentError:modalForWindow:delegate:didPresentSelector:contextInfo:")) (id->ffi2-ptr (coerce-arg error)) (id->ffi2-ptr (coerce-arg window)) (id->ffi2-ptr (coerce-arg delegate)) (id->ffi2-ptr (sel_registerName did-present-selector)) (id->ffi2-ptr context-info)))
(define (nswindowcontroller-pressure-change-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "pressureChangeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-quick-look-preview-items self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookPreviewItems:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-quick-look-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "quickLookWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-resign-first-responder self)
  (aw_racket_msg_0_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "resignFirstResponder"))))
(define (nswindowcontroller-restore-state-with-coder self coder)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "restoreStateWithCoder:")) (id->ffi2-ptr (coerce-arg coder))))
(define (nswindowcontroller-restore-user-activity-state self user-activity)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "restoreUserActivityState:")) (id->ffi2-ptr (coerce-arg user-activity))))
(define (nswindowcontroller-right-mouse-down self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDown:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-right-mouse-dragged self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseDragged:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-right-mouse-up self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rightMouseUp:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-rotate-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "rotateWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-scroll-line-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollLineDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-scroll-line-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollLineUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-scroll-page-down self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPageDown:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-scroll-page-up self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollPageUp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-scroll-to-beginning-of-document self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollToBeginningOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-scroll-to-end-of-document self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollToEndOfDocument:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-scroll-wheel self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "scrollWheel:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-select-all self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectAll:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-select-line self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectLine:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-select-paragraph self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectParagraph:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-select-to-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectToMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-select-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "selectWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-set-document-edited! self dirty-flag)
  (aw_racket_msg_b_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setDocumentEdited:")) dirty-flag))
(define (nswindowcontroller-set-mark! self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "setMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-should-be-treated-as-ink-event self event)
  (aw_racket_msg_P_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldBeTreatedAsInkEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-should-perform-segue-with-identifier-sender self identifier sender)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "shouldPerformSegueWithIdentifier:sender:")) (id->ffi2-ptr (coerce-arg identifier)) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-show-context-help self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextHelp:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-show-context-menu-for-selection self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showContextMenuForSelection:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-show-window self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showWindow:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-show-writing-tools self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "showWritingTools:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-smart-magnify-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "smartMagnifyWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-supplemental-target-for-action-sender self action sender)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "supplementalTargetForAction:sender:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg sender))))
   ))
(define (nswindowcontroller-swap-with-mark self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swapWithMark:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-swipe-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "swipeWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-synchronize-window-title-with-document-name self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "synchronizeWindowTitleWithDocumentName"))))
(define (nswindowcontroller-tablet-point self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletPoint:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-tablet-proximity self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tabletProximity:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-touches-began-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesBeganWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-touches-cancelled-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesCancelledWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-touches-ended-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesEndedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-touches-moved-with-event self event)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "touchesMovedWithEvent:")) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-transpose self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transpose:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-transpose-words self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "transposeWords:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-try-to-perform-with self action object)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "tryToPerform:with:")) (id->ffi2-ptr (sel_registerName action)) (id->ffi2-ptr (coerce-arg object))))
(define (nswindowcontroller-update-user-activity-state self user-activity)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "updateUserActivityState:")) (id->ffi2-ptr (coerce-arg user-activity))))
(define (nswindowcontroller-uppercase-word self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "uppercaseWord:")) (id->ffi2-ptr (coerce-arg sender))))
(define (nswindowcontroller-valid-requestor-for-send-type-return-type self send-type return-type)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_PP_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validRequestorForSendType:returnType:")) (id->ffi2-ptr (coerce-arg send-type)) (id->ffi2-ptr (coerce-arg return-type))))
   ))
(define (nswindowcontroller-validate-proposed-first-responder-for-event self responder event)
  (aw_racket_msg_PP_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "validateProposedFirstResponder:forEvent:")) (id->ffi2-ptr (coerce-arg responder)) (id->ffi2-ptr (coerce-arg event))))
(define (nswindowcontroller-wants-forwarded-scroll-events-for-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsForwardedScrollEventsForAxis:")) axis))
(define (nswindowcontroller-wants-scroll-events-for-swipe-tracking-on-axis self axis)
  (aw_racket_msg_q_b (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "wantsScrollEventsForSwipeTrackingOnAxis:")) axis))
(define (nswindowcontroller-will-present-error self error)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "willPresentError:")) (id->ffi2-ptr (coerce-arg error))))
   ))
(define (nswindowcontroller-window-did-load self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "windowDidLoad"))))
(define (nswindowcontroller-window-title-for-document-display-name self display-name)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "windowTitleForDocumentDisplayName:")) (id->ffi2-ptr (coerce-arg display-name))))
   ))
(define (nswindowcontroller-window-will-load self)
  (aw_racket_msg_0_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "windowWillLoad"))))
(define (nswindowcontroller-yank self sender)
  (aw_racket_msg_P_v (id->ffi2-ptr (coerce-arg self)) (id->ffi2-ptr (sel_registerName "yank:")) (id->ffi2-ptr (coerce-arg sender))))

;; --- Class methods ---
(define (nswindowcontroller-allowed-classes-for-restorable-state-key-path key-path)
  (wrap-objc-object
   (ffi2-ptr->id (aw_racket_msg_P_P (id->ffi2-ptr NSWindowController) (id->ffi2-ptr (sel_registerName "allowedClassesForRestorableStateKeyPath:")) (id->ffi2-ptr (coerce-arg key-path))))
   ))
